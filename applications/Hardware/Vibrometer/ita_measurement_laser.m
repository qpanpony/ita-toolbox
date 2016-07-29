function ita_measurement_laser(varargin)
%ITA_MEASUREMENT_LASER Run a measurement with the laser-vibrometer
%  This function takes a mesh file, a vivo output file, two serial objects
%  and a measurement setup as input arguments and performs a measurement
%  for each mesh node with the settings from the measurement setup.
%  The mesh file and the .viv-file are used to get information for each
%  mesh node, including the laser commands necessary to move the laser to
%  each node.
%  The first serial object is the one that commmunicates with the controller,
%  the second is for the interface and moves the laser. The controller
%  serial will be used by ITA_VIBRO_FINDGOODSPOT to find a spot with an
%  acceptable signal level.
%
%  Call: ita_measurement_laser(meshFilename,vivFilename,measurementSetup)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_measurement_laser">doc ita_measurement_laser</a>

% <ITA-Toolbox>
% This file is part of the application Vibrometer for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus M-T -- Email: mmt@akustik.rwth-aachen.de
% Created: 25-Nov-2008

%% Initialization
global controller_serial;
global interface_serial;

sArgs        = struct('pos1_meshFilename','string', 'pos2_vivFilename','string','pos3_measurementSetup','itaMSRecord','user', '');
[meshFilename,vivFilename,MS,sArgs] = ita_parse_arguments(sArgs,varargin); 
Mesh            = ita_readunv2411(meshFilename);
saveNodes       = repmat(Mesh,[numel(MS.inputChannels),1]);
nodeIdx         = reshape(1:saveNodes.nPoints,Mesh.nPoints,numel(MS.inputChannels));
laserCommands   = ita_vibro_convertViv(vivFilename,Mesh.ID);

%% RS232
if isempty(controller_serial) || isempty(interface_serial)
    ita_vibro_init;
end

set(controller_serial,'Timeout',3);
set(interface_serial,'Timeout',3);

%% Now we can start measuring
noiseAns = merge(repmat(ita_generate('flat',10^-10,MS.samplingRate,MS.fftDegree),numel(MS.inputChannels),1));
nNodes = size(laserCommands,1);
zerCount = floor(log10(max(Mesh.ID)))+1;
dir = fileparts(vivFilename);
if isempty(dir)
    dir = '.';
end
dir = [dir filesep];

if ~isempty(sArgs.user)
    diaryFile=['\\verdi\scratch\' user '\vibrometerLog_' datestr(now,'yyyy-mm-dd_HH-MM-SS') '.log'];
end    
targetDir = ['laserFiles_' datestr(now,'yyyy-mm-dd_HH-MM')];
success = mkdir(dir,targetDir);
t1 = tic;
if success
    ita_vibro_moveTo(laserCommands{1,2}(1),laserCommands{1,2}(2));
    ita_vibro_findGoodSpot();
    ita_plot_freq(MS.run);
    ita_verbose_info(['results will be saved to: ' dir targetDir],1);
    comeFrom = pwd;
    cd([dir targetDir]);
    for i=1:nNodes
        resp = ita_vibro_moveTo(laserCommands{i,2}(1),laserCommands{i,2}(2));
        if strcmp(resp(1),'*')
            pause(1);
            err = ita_vibro_findGoodSpot();
            if isempty(err)
                levelBefore = str2double(getSignalLevel());
                result = MS.run;
                levelAfter = str2double(getSignalLevel());
                if abs(levelAfter- levelBefore) > 5
                    pause(1);
                    levelBefore = str2double(getSignalLevel());
                    result = MS.run;
                    levelAfter = str2double(getSignalLevel());
                    if abs(levelAfter- levelBefore) > 5
                        pause(1);
                        result = MS.run;
                    end
                end
            else
                ita_verbose_info(['warning, no acceptable signal level, skipping node no. ' num2str(laserCommands{i,1})],0);
                result = noiseAns;
            end
        else
            ita_verbose_info(['warning, command not accepted, skipping node no. ' num2str(laserCommands{i,1})],0);
            result = noiseAns;
        end
        result.channelNames(:) = {[result.channelNames{1} ' node ' num2str(laserCommands{i,1})]};
        result.channelCoordinates = repmat(saveNodes.n(nodeIdx(i,:)),[result.nChannels,1]);
        ita_write(result,['VIB' num2str(laserCommands{i,1},['%.' num2str(zerCount) 'd']) '.ita']);
        ita_verbose_info(['ETA: ' num2str(toc(t1)/i*(nNodes-i)) ' Seconds'],1);
        if ~isempty(sArgs.user)
            diary off;
            diary(diaryFile);
        end
    end
end
ita_vibro_moveTo(0,0);
fclose(controller_serial);
fclose(interface_serial);
cd(comeFrom);
end

function lev = getSignalLevel()
global controller_serial;
sent = ita_vibro_sendCommand('LEV','controller');
if sent
    lev = fgetl(controller_serial);
else
    lev = '0';
end
end
