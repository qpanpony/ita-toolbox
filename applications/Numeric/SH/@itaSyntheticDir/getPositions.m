function this = getPositions(this, varargin)
% uses 'ita_roomacoustics_correlation_coefficient_longtime to select good
% speaker positions out of the data in 'this.measurementDataFolder'
%
% settings: 
%       'nPos' : number of rotations to build a synthSuperSpeaker
%       'filemask', 'sd_' : filemasking the data of your reference speaker
% 
% I promise, in january there will be a documentaion !

sArgs = struct('corcoef',[], 'nPos',[], 'filemask', 'sd_');

%% init
this.stillempty; % check
if nargin > 1
    sArgs = ita_parse_arguments(sArgs,varargin);
end

if isempty(this.measurementDataFolder)
    error('give me some "measurementDataFolder"'); 
end

idxPos2idxFile = zeros(0,2);
for idxF = 1:length(this.measurementDataFolder)
    nFiles = numel(dir([this.measurementDataFolder{idxF} filesep sArgs.filemask '*.ita']));
    if ~nFiles, error(['can not find no file "' this.measurementDataFolder{idxF} filesep sArgs.filemask '1.ita"']); end
    idxPos2idxFile = [idxPos2idxFile; ones(nFiles,1)*idxF (1:nFiles).']; %#ok<AGROW>
end

% %% calculate correlation coefficient
% if isempty(sArgs.corcoef) || ~isa(sArgs.corcoef, 'itaResult') || sArgs.corcoef.nSamples ~= nAllFiles
%     cc_filemask = cell(length(this.measurementDataFolder),1);
%     for idxF = 1:length(this.measurementDataFolder)
%         cc_filemask{idxF} = [this.measurementDataFolder{idxF} filesep sArgs.filemask];
%     end
%     
%     sArgs.corcoef = ita_roomacoustics_correlation_coefficient_longtime('filemask', cc_filemask, ...
%         'refPos', 'last_1', 'nRef', 5, 'freqRange', this.freqRange_intern);
% end
%     
% %% get positions
% [dummy idxPositions] = sort(sArgs.corcoef.timeData,'descend'); %#ok<ASGLU>
idxPositions = 174:188;
if ~isempty(sArgs.nPos), 
    nPos = min(sArgs.nPos, length(idxPositions));
    idxPositions = idxPositions(1:nPos); 
end
idxApplied2idxFile = idxPos2idxFile(idxPositions,:);

% (*) Im Moment gilt noch: idxTilt = idxFolder.
%     Später sollte man auch idxTilt mal aus den Messdaten auslesen (?)
nTilt = length(this.measurementDataFolder);
nRotMax = 0;
for idxT = 1:nTilt
    nRotMax = max(nRotMax, length(idxApplied2idxFile(idxApplied2idxFile(:,1) == idxT, 2)));
end
this.idxTiltRot2idxFolderFile = cell(nTilt, nRotMax);
this.angle_rot = cell(nTilt,1);

%get rotation angles from channel data.coordinates
for idxP = 1:length(idxPositions)
    idxFolder = idxPos2idxFile(idxPositions(idxP),1);
    idxFile   = idxPos2idxFile(idxPositions(idxP),2);
    data = ita_read([this.measurementDataFolder{idxFolder} filesep sArgs.filemask int2str(idxFile) '.ita']);
    
    if this.measurementCoordinates_are_itaItalian
        phi = mod(10*pi - data(1).channelCoordinates.phi(1), 2*pi);
    else
        phi = mod(data(1).channelCoordinates.phi(1), 2*pi);
    end
    
    % (*)
    idxTilt = idxFolder;
    this.angle_rot{idxTilt} = [this.angle_rot{idxTilt} phi];
    this.idxTiltRot2idxFolderFile{idxTilt, length(this.angle_rot{idxTilt})} = [idxFolder idxFile];
end

