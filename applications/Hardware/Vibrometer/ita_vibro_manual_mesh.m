function pos = ita_vibro_manual_mesh(varargin)

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization and Input Parsing
sArgs = struct('pos1_filename','string','nPoints',3);
[filename,sArgs] = ita_parse_arguments(sArgs,varargin);

global interface_serial;
if isempty(interface_serial)
    ita_vibro_init;
end

points = zeros(sArgs.nPoints,2); % Phi, Theta

%% get the positions as long as the user wants
for iPoint = 1:sArgs.nPoints
    if iPoint == 1
        % start the lasergui
        L = ita_vibro_lasergui('I');
    end
    
    disp('As soon as the laser is in correct position, hit any key');
    pause
    % read out the current laser position
    points(iPoint,:)  = ita_vibro_getPosition();
    disp(['Angles for this node are (ID,phi,theta) -> (' num2str(iPoint) ',' num2str(points(iPoint,1)) ',' num2str(points(iPoint,2)) ')']);
end

% close the lasergui
close(L);

pos = itaCoordinates([points zeros(sArgs.nPoints,1)]); % x is phi, y is theta

%% writing
[dir,name] = fileparts(filename);
if isempty(dir)
    dir = '.';
end
dir = [dir filesep];
filename_unv = [dir lower(name) '.unv'];
filename_viv = [dir lower(name) '.viv'];
ita_verbose_info(['results will be saved to: ' filename_viv],1);

ita_write(pos,filename_unv);

fid = fopen(filename_viv,'wt');
if fid ~= -1 % if the file could be created or opened
    for i = 1:sArgs.nPoints % for each node, write the command
        fprintf(fid,'%s\n',num2str(i));
        % write angles
        fprintf(fid,'%s,%s\n',num2str(points(i,1)),num2str(points(i,2)));
    end
else
    error('error, cannot create file');
end
fclose(fid);

end % function