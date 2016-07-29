function ita_vibro_testScan(varargin)
%ITA_VIBRO_TESTSCAN - move the laser to all mesh points
%  This function takes the interface serial object, a mesh filename and a
%  viv filename as input arguments and then performs a test scan by moving
%  the laser to all points of the mesh.
%  The viv file is the output of the ITA_VIBRO_VIVO function.
%  The mesh file has to be a .unv-file.
%
%  Call: ita_vibro_testScan(meshFilename,vivFilename)
%
%   Options: (default)
%       continuous  (true)      : continuously run the testscan
%       speed       (60)         : points per minute
%
%   See also ita_vibro.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_vibro_testScan">doc ita_vibro_testScan</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created: 07-Jan-2009 

%% Initialization and Input Parsing
sArgs = struct('pos1_meshFilename','string','pos2_vivFilename','string','continuous',true,'speed',60);
[meshFilename,vivFilename,sArgs] = ita_parse_arguments(sArgs,varargin);

global interface_serial;

if isempty(interface_serial)
    ita_vibro_init;
end

%% RS232
% try to open the serial port if not open yet
if ~strcmp(interface_serial.Status,'open')
    fopen(interface_serial);
end
if ~strcmp(interface_serial.Status,'open')
    error('ita_vibro_testScan::serial connection could not be opened');
end

%% Body
Mesh = ita_readunv2411(meshFilename); % read in the mesh
nodes = Mesh.ID;
vivStruct = ita_vibro_convertViv(vivFilename,nodes); % get the commands

if sArgs.continuous
    ita_verbose_info('ita_vibro_testScan::performing a test scan.\nHit any key to start\nHit Ctrl+C to stop ...\n',0);
    pause;    
    while true
        for i=1:numel(nodes) % for each node
            ita_vibro_moveTo(vivStruct{i,2}(1),vivStruct{i,2}(2)); % send the command
            pause(60/sArgs.speed);
        end
    end
else
    for i=1:numel(nodes) % for each node
        ita_vibro_moveTo(vivStruct{i,2}(1),vivStruct{i,2}(2)); % send the command
        pause();
    end
end

%end function
end