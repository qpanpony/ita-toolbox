function makeSynthSpeaker(this,freq)
% I promise, in january there will be a documentaion!
% have a look on itaSyntheticDir.tutorial

if ~isdir([this.folder filesep 'synthSuperSpeaker']),
    mkdir([this.folder filesep 'synthSuperSpeaker']);
end

if length(this.euler_tilt) ~= length(this.angle_rot) || ...
        (~isempty(this.measurementDataFolder) &&  length(this.euler_tilt) ~= length(this.measurementDataFolder))
    error('size of "euler_tilt", "angle_rot" and "measurementDataFolder" must be equal!!');
end

if isempty(this.speaker_channels) || isempty(this.freqRange) && isa(this.speaker,'itaBalloon')
    error('first you must set stuff like "speaker_nmax", "freq_range" and "speaker_channels"');
end

%% initialize, set data structure
if isa(this.speaker,'itaBalloon')
    if ~exist('freq','var')
        idxFreq = this.speaker.freq2idxFreq(min(this.freqRange_intern)) : this.speaker.freq2idxFreq(max(this.freqRange_intern));
        this.freqVector	= this.speaker.freqVector(idxFreq);
        this.spherical_harmonics_type = this.speaker.SHType;
    else
        this.freqVector	= freq;
        this.spherical_harmonics_type = this.speaker.spherical_harmonics_type;
    end
    
elseif isa(this.speaker,'itaSphericalLoudspeaker')
    if ~exist('freq','var')
        error('Help, give me a "frequencyVector" !!')
    end
    this.freqVector	= freq;
    this.freqRange = [min(freq) max(freq)];
    this.spherical_harmonics_type = 'complex'; %itaSphericalLaudspeaker deals only with complex valued stuff
    
else
    error('"this.speaker" must be either an itaBalloon or an itaSphericalLoudspeaker - object!!"');
end

if this.speaker_nmax < this.nmax
    error('"this.nmax" must be smaller than "this.speaker_nmax"');
end

myWaitbar(length(this.freqVector)+1);
this.setDataStructure;

nChannels = length(this.speaker_channels);
nTilt = length(this.euler_tilt);

%% set rooting: channel of synthetic speaker -> speaker orientation, speaker channel ...
this.aperture2idxTiltRotCh = zeros(0,3);
for idxT = 1:nTilt
    newPart = zeros(length(this.angle_rot{idxT})*nChannels, 3);
    for idxR = 1:length(this.angle_rot{idxT})
        newPart((idxR-1)*nChannels + (1:nChannels), :) = ...
            [ones(nChannels, 2)*diag([idxT idxR]) (1:nChannels).'];
    end
    this.aperture2idxTiltRotCh = [this.aperture2idxTiltRotCh; newPart];
end
this.nApertures = size(this.aperture2idxTiltRotCh,1);
    
    
%% matrices to tilt the speaker
tiltMatrix = cell(nTilt,1);
for idxT = 1:nTilt
    if size(this.euler_tilt{idxT},2) ~= 3, error('All tilt and rotation angles must have size [x 3] !'); end
    if strcmpi(this.spherical_harmonics_type, 'complex')
        tiltMatrix{idxT} = ita_sph_rotate_complex_valued_spherical_harmonics(this.speaker_nmax, this.euler_tilt{idxT});
    else
        tiltMatrix{idxT} = ita_sph_rotate_real_valued_spherical_harmonics(this.speaker_nmax, this.euler_tilt{idxT});
    end
end
    
%% Synthesise the super speaker
for idxB = 1:this.nDataBlock
    nFreq = length(this.block2idxFreq(idxB));
    if isa(this.speaker,'itaBalloon')
        %read spherical coefs (from a measured speaker)
        single_sp = this.speaker.freq2coefSH(...
            this.freqVector(this.block2idxFreq(idxB)), 'nmax',this.speaker_nmax,'channels',this.speaker_channels, 'normalized');
        
    elseif isa(this.speaker,'itaSphericalLoudspeaker')
        pressureFactor = this.speaker.pressureFactor(2*pi/344*this.freqVector(this.block2idxFreq(idxB)));
        single_sp = ...
            repmat(this.speaker.apertureSH(1:(this.speaker_nmax+1)^2,this.speaker_channels), [1 1 nFreq]) .*...
            repmat(permute(pressureFactor(1:(this.speaker_nmax+1)^2,:), [1 3 2]), [1 nChannels 1]);
        
    end
    
    
    %superspeaker's frequencyBlock
    super_sp = zeros((this.speaker_nmax+1)^2, this.nApertures, nFreq);
    for idxF = 1:nFreq
        myWaitbar(this.block2idxFreq(idxB,idxF));
        
        for idxA = 1:nChannels:this.nApertures
            idT = this.aperture2idxTiltRotCh(idxA,1);
            idR = this.aperture2idxTiltRotCh(idxA,2);
            
            if strcmpi(this.spherical_harmonics_type, 'complex')
                super_sp(:, idxA-1+(1:nChannels), idxF) = ...
                    ita_sph_rotate_complex_valued_spherical_harmonics(tiltMatrix{idT}*single_sp(:,:,idxF), [this.angle_rot{idT}(idR) 0 0]);
            else
                super_sp(:, idxA-1+(1:nChannels), idxF) = ...
                    ita_sph_rotate_real_valued_spherical_harmonics(tiltMatrix{idT}*single_sp(:,:,idxF), [this.angle_rot{idT}(idR) 0 0]);
            end
        end
    end
    save([this.folder filesep 'synthSuperSpeaker' filesep 'freqDataSH_' int2str(idxB)], 'super_sp');
end

%conclude
myWaitbar(length(this.freqVector)+1);
save(this);
myWaitbar([]);
end

function myWaitbar(in)
persistent WB maxN;

if ~exist('maxN','var') || isempty(maxN)...
        || exist('WB','var') && ~ishandle(WB);
    maxN = in;
    WB = waitbar(0, 'makeSynthSpeaker (initialize)');
    
elseif in < maxN
    waitbar(in/maxN, WB, ['makeSynthSpeaker (proceed frequency ' int2str(in) ' / ' int2str(maxN-1) ')']);
    
else
    waitbar(1, WB, ['makeSynthSpeaker (finish)']);
end

if isempty(in)
    close(WB);
end
end

% function lin = nm2N(n,m)
% if length(n) > 1, error(' '); end
% lin = n^2+n+1+m;
% end

% function value = rotate_z(value, nmax, phi)
% % according to Dis Zotter, chapter 3.1.4
% % compare: ita_sph_rotate_real_valued_spherical_harmonics	
% %  (there it is a bit different because there (first) the coordinate system
% %  and not the spherical function is rotated
% %
% %Idea: Fs,m = [cos(m phi) -sin(m phi)] * [Fs,mo ; Fc,mo]
% %      Fc,m = [sin(m phi)  cos(m phi)] * [Fs,mo ; Fc,mo]
% 
% % value(nm2N(n,0),nm2N(n,0)) does not change
% for n = 0:nmax
%     for m = 1:n
%         value(nm2N(n,-m),:) = [cos(m*phi) -sin(m*phi)] * value(nm2N(n,[-m m]),:);    
%         value(nm2N(n, m),:) = [sin(m*phi)  cos(m*phi)] * value(nm2N(n,[-m m]),:);
%     end
% end
% end