function this = makeBalloon(this)
% Initialises itaBalloon object, imports measurement data and calculats a
% some stuff like positions, position's weights, normalization...
%
% Just do all the settings in "itaBalloon.makeSetup" and proceed this
% function.
% 
% see also:
% itaBalloon.tutorial

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%check input data, path settings
if ~exist(this.makeSetup.dataFolderNorth, 'dir') || ~numel(dir([this.makeSetup.dataFolderNorth filesep '*.ita']))
    error('no data in "dataFolderNorth"');
end
if ~isempty(this.makeSetup.dataFolderSouth)
    if ~exist(this.makeSetup.dataFolderSouth, 'dir') || ~numel(dir([this.makeSetup.dataFolderSouth filesep '*.ita']))
        error('no data in "dataFolderSouth"');
    end
end

%set general settings
dataFiles = dir([this.makeSetup.dataFolderNorth filesep '*.ita']);
ao = ita_read([this.makeSetup.dataFolderNorth filesep dataFiles(1).name]);
this.freqVector   = ao.freqVector;
this.nChannels    = ao.nChannels;
this.channelNames = ao.channelNames;
this.nBins        = ao.nBins;

if isa(ao, 'itaAudio')
    this.samplingRate  = ao.samplingRate;
    this.fftDegree     = ao.fftDegree;
    this.inputDataType = 'itaAudio';
elseif isa(ao, 'itaResult')
    this.eleminateLatencySamples = false;
    this.inputDataType = 'itaResult';
else
    ita_verbose_info('itaBalloon:makeBalloon:WARNING: unknown data format, I do not know, if I can handle this', 0);
end
this.unit = ao.channelUnits{1};


%% initialise positions-stuff
ita_verbose_info('itaBalloon:makeBalloon:Initialise positions', 0);

% northern hemisphere
files = dir([this.makeSetup.dataFolderNorth filesep '*.ita']);
this.nPointsNorth = numel(files);
positionsNorth    = itaSamplingSph(this.nPointsNorth);

% southern hemisphere
if ~isempty(this.makeSetup.dataFolderSouth)
    files = dir([this.makeSetup.dataFolderSouth filesep '*.ita']);
    this.nPointsSouth = numel(files);
    positionsSouth    = itaSamplingSph(this.nPointsSouth);
end

this.nPoints = this.nPointsNorth + this.nPointsSouth;


%% initialize data structure
this.mData.dataFolderName = 'balloonData';
this.mData.dataFileName   = 'freqData_';
if ~exist(this.mBalloonFolder , 'dir')
    mkdir(this.mBalloonFolder);
    
elseif ~this.mData.isempty
    error('There are already data files in the balloonFolder. Please delete them');
end

this.mData.dimension = [this.nPoints this.nChannels this.nBins];
this.mData.splitDimension = 3;

%% read all measurement data to a temporary data structure
tmpData = itaFatSplitMatrix([this.nPoints this.nChannels this.nBins], 1, this.precision);
tmpData.folder = [this.balloonFolder filesep 'tmp'];
tmpData.MBytesPerSegment = this.mData.MBytesPerSegment;
allLatencySamples = zeros(this.nPoints,this.nChannels);

% read all measurement data to a temporary data structure
ita_verbose_info('itaBalloon:makeBalloon:Read measurement data (this will take some time)',0);

filesNorth = dir([this.makeSetup.dataFolderNorth filesep '*.ita']);
if this.nPointsSouth
    filesSouth = dir([this.makeSetup.dataFolderSouth filesep '*.ita']); 
end

% if latency samples shall be eliminated, read data twice
if this.eleminateLatencySamples 
    turns = [0 1]; % initialize latency samples
else
    turns = 1;
end

% read all data
for idxT = turns
    for idxP = 1:this.nPoints
        
        if idxP<= this.nPointsNorth
            data = ita_read([this.makeSetup.dataFolderNorth filesep filesNorth(idxP).name]);
        else
            data = ita_read([this.makeSetup.dataFolderSouth filesep filesSouth(idxP-this.nPointsNorth).name]);
        end
      
        
        if ~idxT
            % initialize latency samples (I)
            allLatencySamples(idxP,:) = ita_start_IR(data)-1;
        else
            % copy data to temporary data structure 
            if this.eleminateLatencySamples
                data = ita_time_shift(data, - this.latencySamples, 'samples');
            end
            
            tmpData.set_data(idxP, 1:this.nChannels, 1:this.nBins, permute(data.freqData, [3 2 1]));
            
            % copy position data
            if idxP <= this.nPointsNorth
                positionsNorth.sph(idxP,:) = data.channelCoordinates.sph(1,:);
            else
                positionsSouth.sph(idxP-this.nPointsNorth,:) = data.channelCoordinates.sph(1,:);
            end
        end
    end
    
    if ~idxT % set latency samples (II)
        this.latencySamples = min(min(allLatencySamples));
    end
end
save(tmpData);

%% copy temporary data to final data 
for idxS = 1:this.mData.nSegments
    index = {1:this.nPoints, 1:this.nChannels, this.mData.segment2index(idxS)};
    data = tmpData.get_data(index{:});
    this.mData.set_data(index{:}, data); 
end
remove(tmpData);

%% positions
ita_verbose_info('itaBalloon:makeBalloon:Set positions');
this.positions = itaCoordinates(this.nPoints);
this.positions.sph(1:this.nPointsNorth,:) = positionsNorth.sph;
if this.nPointsSouth
    posSouth = positionsSouth;
    phi0 = mod(this.makeSetup.phi0,pi);
    posSouth.phi = 2*(pi-phi0) - posSouth.phi;
    posSouth.theta = pi - posSouth.theta;
    this.positions.sph(this.nPointsNorth+1 : this.nPoints,:) = posSouth.sph;
end

% weights of points
if isempty(positionsNorth.weights)  || this.nPointsSouth && isempty(positionsSouth.weights)
    ita_verbose_info('itaBalloon:makeBalloon:Your sampling contains no weights. I calculate them for you.', 0);
    [dummy this.positions.weights] = this.positions.spherical_voronoi; %#ok<ASGLU>
    
else
    weights = [positionsNorth.weights; positionsSouth.weights];
    if sum(weights) ~= 1 || sum(weights) ~= 4*pi
        ita_verbose_info('itaBalloon:makeBalloon:Your weights weights have a wrong sum. I normalize them for you',0);
        this.positions.weights = weights/sum(weights)*4*pi;
    end
end

% hull for plot function
this.create_hull;

if this.normalizeData
    % equalize
    ita_verbose_info('itaBalloon:makeBalloon:equalize Balloon');
    this.equalizeBalloon;
end
save(this);