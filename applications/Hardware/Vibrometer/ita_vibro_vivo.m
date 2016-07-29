function ita_vibro_vivo(varargin)
%ITA_VIBRO_VIVO - converts mesh coordinates into commands for the polytec laser-vibrometer
%  This function takes a serial object and the name of a mesh file as input
%  arguments and converts the mesh coordinates into commands for the
%  polytec laser-vibrometer. A command will be saved for each node together
%  with the node ID, the file name will be the same as the mesh file with
%  the file extension .viv instead of .unv.
%  The function uses the ITA_VIBRO_LASERGUI to enable the user to move the
%  laser to three nodes of the mesh and then calculates the angles that the
%  laser has to move for each node.
%
%  Call: ita_vibro_vivo(meshFilename)
%
%  Directly give the IDs of the three triangulation nodes
%        ita_vibro_vivo(meshFilename)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_vibro_vivo">doc ita_vibro_vivo</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 27-Nov-2008

%% Initialization and Input Parsing
sArgs = struct('pos1_meshFilename','string','IDs',[],'nPoints',3);
[meshFilename,sArgs] = ita_parse_arguments(sArgs,varargin);

global interface_serial;
if isempty(interface_serial)
    ita_vibro_init;
end

%% get positions of points with user interaction
points = zeros(sArgs.nPoints,6); % nodeID,x,y,z,posPhi,posTheta
Mesh = ita_read(meshFilename); % read in the mesh
message = ['Use the GUI to steer the laser to three or more mesh nodes, which\n', ...
    '(1) are not on a straight line, and\n', ...
    '(2) have maximum distance between each other\n\n', ...
    'Enter the node ID, move the laser to the correct position\nand then return to this command window and press any key to continue!\n'];
clc;
fprintf(message);

for iPoint = 1:sArgs.nPoints
    % enter the nodeID
    if isempty(sArgs.IDs) || numel(sArgs.IDs) < iPoint
        points(iPoint,1) = str2double(input(['Enter the node ID of node no. ' num2str(iPoint) ': '],'s'));
        if iPoint > 1
            % make sure we don't have that node yet
            while ismember(points(iPoint,1),points(1:iPoint-1,1))
                disp('This node has already been entered, please choose another one');
                points(iPoint,1) = str2double(input(['Enter the node ID of node no. ' num2str(iPoint) ': '],'s'));
            end
        end
    else
        points(iPoint,1) = sArgs.IDs(iPoint);
    end
    
    idx = find(Mesh.ID == points(iPoint,1));
    if ~isempty(idx) % if the ID exists, get the coordinates
        points(iPoint,2:4) = Mesh.n(idx).cart;
        disp(['Node coordinates (x,y,z) -> (' num2str(points(iPoint,2)) ',' num2str(points(iPoint,3)) ',' num2str(points(iPoint,4)) ')']);
    else
        error('ITA_VIBRO_TRIANGULATION::error, cannot find that node');
    end
    
    if iPoint == 1
        % start the lasergui
        L = ita_vibro_lasergui('I');
        f = figure();
        Mesh.scatter;
        view(0,90);
        hold all;
        Mesh.n(idx).scatter('filled');
    else
        figure(f);
        Mesh.n(idx).scatter('filled');
    end
    
    disp('As soon as the laser is in correct position, hit any key');
    pause
    % read out the current laser position
    points(iPoint,5:6) = ita_vibro_getPosition();
    disp(['Angles for this node are (phi,theta) -> (' num2str(points(iPoint,5)) ',' num2str(points(iPoint,6)) ')']);
end

% close the lasergui
close(L);
%%
% get the maximum x and y differences between the three points
[node_x1,node_x2,node_y1,node_y2] = getMaxDifferences(points);
% determine the angles for all nodes and round them to two decimal places
angles = triangulation(Mesh,points,node_x1,node_x2,node_y1,node_y2);
angles = round(angles.*100)./100;

% save to the vivFile
[dir,name] = fileparts(meshFilename);
if isempty(dir)
    dir = '.';
end
dir = [dir filesep];
vivFilename = [dir lower(name) '.viv'];
ita_verbose_info(['ITA_VIBRO_VIVO::results will be saved to: ' vivFilename],2);

nNodes = numel(Mesh.ID);
ita_verbose_info('ITA_VIBRO_VIVO::writing ...',2);
fid = fopen(vivFilename,'wt');
if fid ~= -1 % if the file could be created or opened
    for i = 1:nNodes % for each node, write the command
        fprintf(fid,'%s\n',num2str(Mesh.ID(i)));
        % write angles
        fprintf(fid,'%s,%s\n',num2str(angles(i,1),'%05.2f'),num2str(angles(i,2),'%05.2f'));
    end
else
    error('ITA_VIBRO_VIVO::error, cannot create file');
end
fclose(fid);

%end function
end


%% Subfunctions -- taken from the original vivo source code
function [node_x1,node_x2,node_y1,node_y2] = getMaxDifferences(points)
% max phi and theta difference
dphi = abs([points(1,5)-points(2,5);points(2,5)-points(3,5);points(1,5)-points(3,5)]);
dtheta = abs([points(1,6)-points(2,6);points(2,6)-points(3,6);points(1,6)-points(3,6)]);

switch (find(dphi == max(dphi),1))
    case 1
        node_x1 = points(1,:);
        node_x2 = points(2,:);
    case 2
        node_x1 = points(2,:);
        node_x2 = points(3,:);
    case 3
        node_x1 = points(1,:);
        node_x2 = points(3,:);
end

switch (find(dtheta == max(dtheta),1))
    case 1
        node_y1 = points(1,:);
        node_y2 = points(2,:);
    case 2
        node_y1 = points(2,:);
        node_y2 = points(3,:);
    case 3
        node_y1 = points(1,:);
        node_y2 = points(3,:);
end
end


function angles = triangulation(Mesh,points,node_x1,node_x2,node_y1,node_y2)
% xl = ((x2.z-x1.z)*tan(x1.phi)*tan(x2.phi)+x2.x*tan(x1.phi)-x1.x*tan(x2.phi))/(tan(x1.phi)-tan(x2.phi))
% yl = ((y2.z-y1.z)*tan(y1.theta)*tan(y2.theta)+y2.y*tan(y1.theta)-y1.y*tan(y2.theta))/(tan(y1.theta)-tan(y2.theta))

if max(points(:,4))-min(points(:,4)) == 0 % easier equations for planar scans
    xl = (node_x2(2)*tan(node_x1(5)*pi/180)-node_x1(2)*tan(node_x2(5)*pi/180))/ ...
        (tan(node_x1(5)*pi/180)-tan(node_x2(5)*pi/180));
    yl = (node_y2(3)*tan(node_y1(6)*pi/180)-node_y1(3)*tan(node_y2(6)*pi/180))/ ...
        (tan(node_y1(6)*pi/180)-tan(node_y2(6)*pi/180));
else
    xl = ((node_x2(4)-node_x1(4))*tan(node_x1(5)*pi/180)*tan(node_x2(5)*pi/180) ...
        +node_x2(2)*tan(node_x1(5)*pi/180)-node_x1(2)*tan(node_x2(5)*pi/180))/ ...
        (tan(node_x1(5)*pi/180)-tan(node_x2(5)*pi/180));
    yl = ((node_y2(4)-node_y1(4))*tan(node_y1(6)*pi/180)*tan(node_y2(6)*pi/180) ...
        +node_y2(3)*tan(node_y1(6)*pi/180)-node_y1(3)*tan(node_y2(6)*pi/180))/ ...
        (tan(node_y1(6)*pi/180)-tan(node_y2(6)*pi/180));
end
% maxima
phiIdx = find(abs(points(:,5)) == max(abs(points(:,5))),1);
thetaIdx = find(abs(points(:,6)) == max(abs(points(:,6))),1);

vxmax = points(phiIdx,2);
zVonXMax = points(phiIdx,4);
wxmax = points(phiIdx,5);
vymax = points(thetaIdx,3);
zVonYMax = points(thetaIdx,4);
wymax = points(thetaIdx,6);
dxl = (vxmax - xl)/tan(wxmax*pi/180);
zxl = dxl + zVonXMax;
dyl = (vymax - yl)/tan(wymax*pi/180);
zyl = dyl + zVonYMax;

disp(['Distance is approximately: ' num2str(mean([dxl dyl]))]);

nNodes = numel(Mesh.ID);
angles  = zeros(nNodes,2);

for i = 1:nNodes
    angles(i,1) = (180/pi)*atan((Mesh.x(i) - xl)/(zxl - Mesh.z(i)));
    angles(i,2) = (180/pi)*atan((Mesh.y(i) - yl)/(zyl - Mesh.z(i)));
    
    if (angles(i,1) > 20) || (angles(i,2) > 20)
        error('ITA_VIBRO_VIVO::error, angles larger than 20 degrees detected, please restart calibration');
    end
end

end
