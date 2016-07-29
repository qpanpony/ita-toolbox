function ita_vibro_triangulation(varargin)
%ITA_VIBRO_TRIANGULATION - converts mesh coordinates into commands for the polytec laser-vibrometer
%  This function takes a serial object and the name of a mesh file as input
%  arguments and converts the mesh coordinates into angles for the
%  polytec laser-vibrometer. The angles will be saved for each node together
%  with the node ID, the file name will be the same as the mesh file with
%  the file extension .viv instead of .unv.
%  The function uses the ITA_VIBRO_LASERGUI to enable the user to move the
%  laser to three nodes of the mesh and then calculates the angles that the
%  laser has to move for each node.
%
%  Call: ita_vibro_triangulation(meshFilename)
%
%  Directly give the IDs of the three triangulation nodes
%        ita_vibro_triangulation(meshFilename,ID1,ID2,ID3)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_vibro_triangulation">doc ita_vibro_triangulation</a>

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

%% calculate the geometry
c = @(xl,zl,x,z) sqrt((xl - x).^2 + (zl - z).^2);
b = @(xl,zl,x0,d) c(xl,zl,x0,d);
a = @(x0,d,x,z) sqrt((x0 - x).^2 + (d - z).^2);

phi = @(x0,d,xl,zl,x,z) sign(x-xl).*acos((a(x0,d,x,z).^2 + b(xl,zl,x0,d).^2 - c(xl,zl,x,z).^2)./(2.*a(x0,d,x,z).*b(xl,zl,x0,d)));
theta = @(y0,d,yl,zl,y,z) sign(y-yl).*acos((a(y0,d,y,z).^2 + b(yl,zl,y0,d).^2 - c(yl,zl,y,z).^2)./(2.*a(y0,d,y,z).*b(yl,zl,y0,d)));

eq = @(x0,y0,d,xl,yl,zl) [c(xl,zl,points(:,2),points(:,4)).^2 - a(x0,d,points(:,2),points(:,4)).^2 - b(xl,zl,x0,d).^2 + 2.*a(x0,d,points(:,2),points(:,4)).*b(xl,zl,x0,d).*cos(points(:,5).*pi/180); ...
    c(yl,zl,points(:,3),points(:,4)).^2 - a(y0,d,points(:,3),points(:,4)).^2 - b(yl,zl,y0,d).^2 + 2.*a(y0,d,points(:,3),points(:,4)).*b(yl,zl,y0,d).*cos(points(:,6).*pi/180); ...
    phi(x0,d,xl,zl,points(:,2),points(:,4)) - points(:,5).*pi/180; ...
    theta(y0,d,yl,zl,points(:,3),points(:,4)) - points(:,6).*pi/180];

[res,eqVal] = fsolve(@(x) eq(x(1),x(2),x(3),x(4),x(5),x(6)),[0,0,2,0,0,0]);

ita_verbose_info(['Maximum error of optimization is ' num2str(max(eqVal))],1);

x0 = res(1);
y0 = res(2);
d  = res(3);
xl = res(4);
yl = res(5);
zl = res(6);

ita_verbose_info(['Distance is approximately: ' num2str(round(d*1000)/1000)],0);
ita_verbose_info(['Laser zero position is at: xl = ' num2str(round(xl*1000)/1000) ', yl = ' num2str(round(yl*1000)/1000) ', zl = ' num2str(round(zl*1000)/1000)],0);

%% use to calculate desired angles
phiSolved = @(x,z) phi(x0,d,xl,zl,x,z);
thetaSolved = @(y,z) theta(y0,d,yl,zl,y,z);

angles = [phiSolved(Mesh.x,Mesh.z), thetaSolved(Mesh.y,Mesh.z)].*180/pi;
angles = round(angles.*100)./100;

if any(angles(:)) > 20
    error('ITA_VIBRO_TRIANGULATION:error, angles larger than 20 degrees detected, please restart calibration');
end

%% save to the vivFile
[dir,name] = fileparts(meshFilename);
if isempty(dir)
    dir = '.';
end
dir = [dir filesep];
vivFilename = [dir lower(name) '.viv'];
ita_verbose_info(['ITA_VIBRO_TRIANGULATION::results will be saved to: ' vivFilename],1);

nNodes = numel(Mesh.ID);
ita_verbose_info('ITA_VIBRO_TRIANGULATION::writing ...',2);
fid = fopen(vivFilename,'wt');
if fid ~= -1 % if the file could be created or opened
    for i = 1:nNodes % for each node, write the command
        fprintf(fid,'%s\n',num2str(Mesh.ID(i)));
        % write angles
        fprintf(fid,'%s,%s\n',num2str(angles(i,1),'%05.2f'),num2str(angles(i,2),'%05.2f'));
    end
else
    error('ITA_VIBRO_TRIANGULATION::error, cannot create file');
end
fclose(fid);

%end function
end
