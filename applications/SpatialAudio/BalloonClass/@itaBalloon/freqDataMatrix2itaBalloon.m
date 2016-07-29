function this = freqDataMatrix2itaBalloon(this, positions, freqData, freqVector, varargin)
% function freqDataMatrix2itaBalloon(this, positions, freqData, freqVector)
% makes a itaBalloon out of some frequency dependent data
% input: - positions (an itaCoordinate)
%        - freqData(idPoints, idChannel, idFrequency) or freqData(idPoints, idFrequency)
%          matrix that contains complex valued amplitudes
%        - freqVector: Vector of frequency bins.
% optional: 
%        - 'samplingRate' : If your inputData was once an
%          itaAudio, setting the 'samplingRate' will allow to export the object 
%          itaAudio-format. If not, exporting as itaResult is still
%          possible.
%        - MBytePerSegment : size of data structure's segments on disc

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sArgs = struct('MBytePerSegment',this.mData.MBytesPerSegment, 'samplingRate', []);
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

%Initialize
if isempty(this.balloonFolder)
    error('Please give me a balloonFolder');
end
if ~isdir(this.balloonFolder)
    mkdir(this.balloonFolder);
end

%set positions
this.positions = positions;
this.nPoints = this.positions.nPoints;
this.nPoints
if isempty(this.positions.weights)
    [dummy this.positions.weights] = this.positions.spherical_voronoi; %#ok<ASGLU>
    
else
    if sum(this.positions.weights) ~= 1 || sum(this.positions.weights) ~= 4*pi
        disp('Your weights weights have a wrong sum. I normalize them for you');
        this.positions.weights = this.positions.weights/sum(this.positions.weights)*4*pi;
    end
end

% channels
if length(size(freqData)) == 3
    this.nChannels = size(freqData,2);
else
    this.nChannels = 1;
    freqData = permute(freqData, [1 3 2]);
end

%frequency bins
this.freqVector = freqVector;
this.nBins = length(freqVector);
if isempty(sArgs.samplingRate)
    this.inputDataType = 'itaResult';
else
    this.inputDataType = 'itaAudio';
    this.samplingRate = sArgs.samplingRate;
end

if size(freqData,1) ~= this.nPoints || ...
        size(freqData, 3) ~= this.nBins
    error('input data size mismatch'); 
end

% equalize data
if this.normalizeData
    this.equalizeBalloon;
end

this.mData = itaFatSplitMatrix([this.nPoints this.nChannels this.nBins],3,this.precision);
this.mData.folder = this.balloonFolder;
this.mData.set_data(1:this.nPoints, 1:this.nChannels, 1:this.nBins, freqData);
this.samplingRate = sArgs.samplingRate;
this.create_hull;
save(this);
end