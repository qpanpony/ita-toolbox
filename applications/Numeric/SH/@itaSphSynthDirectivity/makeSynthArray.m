function makeSynthArray(this,freq)
% After you've done all the important settings, proceed this function and
% the spherical harmonic coefficients of your array's speakers will be
% calculated.
% 
% input: freq (optional, if your array is an itaBalloonSH)
%        frequency bins for which the synthetic array will be calculated
%        default : this.array.freqVector in the frequency range
%        this.freqRange
%
%
% see also: tutorial, makeSHfilter

if isempty(this.folder) || isempty(this.array) || isempty(this.arrayNmax) || isempty(this.nmax)...
    || isempty(this.arrayChannels) || isempty(this.freqRange) && isa(this.array,'itaBalloon')
    error('first you must set stuff like "folder", "array", "arrayNmax", "freqRange" and "arrayChannels"');
end

if length(this.tiltAngle) ~= length(this.rotationAngle) || ...
        (~isempty(this.measurementDataFolder) &&  length(this.tiltAngle) ~= length(this.measurementDataFolder))
    error('size of "tiltAngle", "rotationAngle" and "measurementDataFolder" must be equal!!');
end

if this.mArrayNmax < this.nmax
    error('"this.nmax" must be smaller than "this.mArrayNmax"');
end

%% initialize
if isa(this.array,'itaBalloonSH')
    if ~exist('freq','var')
        this.freqVector         = this.array.freqVector;
        this.freqVector         = this.freqVector(this.freqVector >= this.internalFreqRange(1));
        this.freqVector         = this.freqVector(this.freqVector <= this.internalFreqRange(2));
        this.outputFormat       = 'itaAudio';
    else
        this.freqVector         = freq;
        this.outputFormat       = 'itaResult';
    end
    
elseif isa(this.array,'itaSphericalLoudspeaker')
    if ~exist('freq','var')
        error('Hep, give me a "frequencyVector" !!')
    end
    this.freqVector             = freq;
    this.freqRange              = [min(freq) max(freq)];
    this.outputFormat           = 'itaResult';
end
this.nBins                      = length(this.freqVector);

this.myWaitbar(this.nBins+1, 'makeSynthArray');

nChannels = length(this.arrayChannels);
nTilt = length(this.tiltAngle);

%% set rooting: channel of synthetic array -> array orientation, array channel ...
this.speaker2idxTiltRotCh = zeros(0,3);
for idxT = 1:nTilt
    newPart = zeros(length(this.rotationAngle{idxT})*nChannels, 3);
    for idxR = 1:length(this.rotationAngle{idxT})
        newPart((idxR-1)*nChannels + (1:nChannels), :) = ...
            [ones(nChannels, 1)*[idxT idxR] (1:nChannels).'];
    end
    this.speaker2idxTiltRotCh = [this.speaker2idxTiltRotCh; newPart];
end
this.nSpeakers = size(this.speaker2idxTiltRotCh,1);
    
    
%% matrices to tilt the array
tiltMatrix = cell(nTilt,1);
for idxT = 1:nTilt
    if size(this.tiltAngle{idxT},2) ~= 3, error('All tilt angles must have size [x 3] !'); end
    if strcmpi(this.SHType, 'complex')
        tiltMatrix{idxT} = ita_sph_rotate_complex_valued_spherical_harmonics(this.mArrayNmax, this.tiltAngle{idxT});
    elseif strcmpi(this.SHType, 'real')
        tiltMatrix{idxT} = ita_sph_rotate_real_valued_spherical_harmonics(this.mArrayNmax, this.tiltAngle{idxT});
    else
        error(' ');
    end
end
    
%% Synthesise the super array
this.mDataSH.dimension          = [(this.arrayNmax+1)^2, this.nSpeakers, this.nBins];
this.mDataSH.splitDimension     = 3;
this.mDataSH.dataFolderName     = 'dataSH';
for idxF = 1:length(this.freqVector)
    this.myWaitbar(idxF);
    
    if isa(this.array,'itaBalloonSH')
        %read spherical coefs (from a measured array)
        singleArray = this.array.freq2coefSH(this.freqVector(idxF), 'nmax',this.arrayNmax,...
            'channels',this.arrayChannels);
        
    elseif isa(this.array,'itaSphericalLoudspeaker')
        pressureFactor = this.array.pressureFactor(2*pi/344*this.freqVector(idxF));
        if size(pressureFactor,1) == 1, pressureFactor = pressureFactor.'; end
        singleArray = ...
            this.array.apertureSH(1:(this.arrayNmax+1)^2,this.arrayChannels) .*...
            pressureFactor(1:(this.mArrayNmax+1)^2,:);        
    end
    
    for idxA = 1:nChannels:this.nSpeakers
        idT = this.speaker2idxTiltRotCh(idxA,1);
        idR = this.speaker2idxTiltRotCh(idxA,2);
        
        if strcmpi(this.SHType, 'complex')
            this.mDataSH.set_data(1:(this.arrayNmax+1)^2, idxA-1+(1:nChannels), idxF, ...
                ita_sph_rotate_complex_valued_spherical_harmonics(tiltMatrix{idT}*singleArray, [this.rotationAngle{idT}(idR) 0 0]));
        else
            this.mDataSH.set_data(1:(this.arrayNmax+1)^2, idxA-1+(1:nChannels), idxF, ...
                ita_sph_rotate_real_valued_spherical_harmonics(tiltMatrix{idT}*singleArray,    [this.rotationAngle{idT}(idR) 0 0]));
        end
    end
end

%conclude
this.myWaitbar(this.nBins+1);
save(this);
this.myWaitbar([]);
end
