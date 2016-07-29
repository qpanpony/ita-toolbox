function son = interpolateBalloon(this, newSampling, newBalloonFolder, varargin)
% function son = interpolateBalloon(this, newSampling, newBalloonFolder)
% interpolates a directivity on a new sampling
%
% input: newSampling (itaCoordinates)
%        newBalloonFolder (a directory)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sArgs = struct('nmax',this.nmax);
if nargin < 3
    error('not enough input arguments');
end
if nargin > 3
    sArgs = ita_parse_arguments(sArgs, varargin);
end

if ~this.existSH
    error('This function works on spherical harmonics, proceed "this.makeSH" first');
end

if ~isdir(newBalloonFolder)
    mkdir(newBalloonFolder);
end

son = itaBalloonSH(this);
son.balloonFolder = newBalloonFolder;
if strcmpi(son.SHType,'complex')
    son.positions = itaSamplingSph(newSampling);
elseif strcmpi(son.SHType,'real')
    son.positions = itaSamplingSphReal(newSampling);
else
    error('unknown spherical harmonic base type');
end
son.positions.nmax = son.nmax;
son.nPoints   = newSampling.nPoints;

%copy spherical coefficients and basefunctions
son.mDataSH = copy(this.mDataSH, son.mDataSH.folder);

% initialize new data structures
son.mData = itaFatSplitMatrix([son.nPoints son.nChannels son.nBins], 3, son.precision);
son.mData.folder = son.balloonFolder;
son.mData.dataFolderName = this.mData.dataFolderName;
son.mData.dataFileName   = this.mData.dataFileName;
son.mData.MBytesPerSegment = this.mData.MBytesPerSegment;

son.mY = itaFatSplitMatrix([son.nPoints son.nCoef],2,son.precision);
son.mY.dataFolderName = 'baseFunctions';
son.mY.folder = son.balloonFolder;
if ~isempty(son.mY) && isa(son.mY, 'itaFatSplitMatrix')
    son.mY.remove;
end

% calculate new spatial data
for idxF = 1:son.nBins    
    dataSH = son.mDataSH.get_data(1:(sArgs.nmax+1)^2, 1:this.nChannels, idxF);
    data   = son.positions.Y(:,1:(sArgs.nmax+1)^2) * dataSH;
    son.mData.set_data(1:son.nPoints, 1:son.nChannels, idxF, data); 
end

% swap basefunctions
dum = son.positions.Y; %#ok<NASGU>
dum = whos('dum');
son.mY.MBytesPerSegment = ceil(dum.bytes/2^20);
son.mY.set_data(1:son.nPoints, 1:son.nCoef, son.positions.Y);
son.mY.save_currentData;
son.positions.Y = [];   

save(son);


