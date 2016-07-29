function this = getPositions(this, varargin)
% reads rotationAngle out of a set of measurement data set by
% measurementDataFolder = {'folder1', 'folder2',...}
%
% you can use 'ita_roomacoustics_correlation_coefficient_longtime to select good
% speaker positions 
%
% settings: 
%       'nPos'     :    maximum number of rotations per folder to build a synthSuperSpeaker
%       'corcoef' :    the result of
%                       "ita_roomacoustics_correlation_coefficient_longtime", that
%                       determines the best correlating measurement positions

sArgs = struct('corcoef',[], 'nPos',[]);

%% init
check_empty(this)

if nargin > 1
    sArgs = ita_parse_arguments(sArgs,varargin);
end

if isempty(this.measurementDataFolder)
    error('give me some "measurementDataFolder"'); 
end

if ~isempty(sArgs.corcoef)
    % select speaker positions via correlation analyis
    [dummy idxPositions] = sort(sArgs.corcoef.timeData,'descend'); %#ok<ASGLU>
    if ~isempty(sArgs.nPos)
        idxPositions = idxPositions(1:sArgs.nPos);
    end
else
    idxPositions = []; lastIndex = 0;
    for idxF = 1:length(this.measurementDataFolder)
        nFiles = numel(dir([this.measurementDataFolder{idxF} filesep this.filemask '*.ita']));
        if ~nFiles, error(['can not find no file "' this.measurementDataFolder{idxF} filesep this.filemask '*.ita"']); end
        
        % select speaker positions via a maximum number of positions
        if ~isempty(sArgs.nPos)
            
            idxPositions = [idxPositions, lastIndex + (1:floor(nFiles/sArgs.nPos):nFiles)]; %#ok<AGROW>
            if length(idxPositions) > sArgs.nPos
                idxPositions = idxPositions(1:sArgs.nPos);
            end
            
            if length(idxPositions) ~= sArgs.nPos
                disp('check');
            end
            
            % take all measured data
        else
            idxPositions = [idxPositions, lastIndex + (1:nFiles)]; %#ok<AGROW>
        end
        lastIndex = lastIndex + nFiles;
    end
end

% routing : position 2 folder/file
idxPos2idxFolderFile = zeros(0,2);
for idxF = 1:length(this.measurementDataFolder)
    nFiles = numel(dir([this.measurementDataFolder{idxF} filesep this.filemask '*.ita']));
    if ~nFiles, error(['can not find no file "' this.measurementDataFolder{idxF} filesep this.filemask '*.ita"']); end
    idxPos2idxFolderFile = [idxPos2idxFolderFile; ones(nFiles,1)*idxF (1:nFiles).']; %#ok<AGROW>
end

idxPos2idxFolderFile = idxPos2idxFolderFile(idxPositions,:);

%% read rotation angle out of measurement data

% (*) Im Moment gilt noch: idxTilt = idxFolder.
%     Später sollte / könnte man auch idxTilt mal aus den Messdaten auslesen (?)
nTilt = length(this.measurementDataFolder);
nRotMax = 0;
for idxT = 1:nTilt
    nRotMax = max(nRotMax, length(idxPos2idxFolderFile(idxPos2idxFolderFile(:,1) == idxT, 2)));
end

this.idxTiltRot2idxFolderFile = cell(nTilt, nRotMax);
this.rotationAngle = cell(nTilt,1);

%get rotation angles from channel data.coordinates
for idxP = 1:length(idxPositions)
    idxFolder = idxPos2idxFolderFile(idxP,1);
    idxFile   = idxPos2idxFolderFile(idxP,2);
    data = ita_read([this.measurementDataFolder{idxFolder} filesep this.filemask int2str(idxFile) '.ita']);
    
    if ~this.rotationAngle_counterClockWise
        phi = mod(10*pi - data(1).channelCoordinates.phi(1), 2*pi);
    else
        phi = mod(data(1).channelCoordinates.phi(1), 2*pi);
    end
    
    % (*)
    idxTilt = idxFolder;
    this.rotationAngle{idxTilt} = [this.rotationAngle{idxTilt} phi];
    this.idxTiltRot2idxFolderFile{idxTilt, length(this.rotationAngle{idxTilt})} = [idxFolder idxFile];
end