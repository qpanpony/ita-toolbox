function this = makeSpeakerSampling(this,varargin)
% This function trys to get the center-points of the apertures of the
% synthSpeaker. It works on the assumption, that each chassis' pressure has a
% distinctive major lobe in the center of the chassis
% at the given frequency 'freq'


sArgs = struct('freq', 3500);
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

%freq choose a high frequency
sampling = ita_sph_sampling_gaussian(80,'noSH',true);

SH = ita_sph_realvalued_basefunctions(sampling, this.speaker_nmax);
coef = this.freq2coefSH_synthSpeaker(sArgs.freq, 'nmax', this.speaker_nmax,'normalized');
this.speakerSampling = itaCoordinates(this.nApertures);

for idxC = 1:this.nApertures
    [dummy idxMax] = max(abs(SH*coef(:,idxC))); %#ok<ASGLU>
    this.speakerSampling.sph(idxC,:) = sampling.sph(idxMax,:);
end

this.speakerSampling_basefunctions = ita_sph_realvalued_basefunctions(this.speakerSampling, this.encode_nmax);
save(this);
end