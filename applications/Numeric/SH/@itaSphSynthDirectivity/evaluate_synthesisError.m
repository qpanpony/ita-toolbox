function varargout = evaluate_synthesisError(this, varargin)
% returns and plots the relative root mean square error of the synthesis of
% abstract directivities with the surface of spherical harmonics.
%
% options: freq: vector of frequencies beeing evaluated 
%                degault : this.freqRange in 1/3-octave steps
%          namx: maximum degree of evaluation
%
sArgs = struct('freq', [], 'nmax', this.nmax);
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end
if isempty(sArgs.freq)
    sArgs.freq = ita_ANSI_center_frequencies(this.freqRange, 3);
end

RMS = zeros((sArgs.nmax+1)^2, length(sArgs.freq), this.precision); 

filter = this.mFilterData.get_data(this.freq2idxFreq(sArgs.freq), 1:this.nSpeakers, 1:(sArgs.nmax+1)^2);

for idxF = 1:length(sArgs.freq)
   RMS(:,idxF) = sum(abs(eye((sArgs.nmax+1)^2) - this.freq2coefSH_synthArray(sArgs.freq(idxF), 'nmax', sArgs.nmax)...
       * permute(filter(idxF,:,:), [2 3 1])).^2,2);
end

RMS = sqrt(RMS);
ita_sph_plot_coefs_over_freq(RMS, sArgs.freq, 'type','max');

if nargout
    varargout = {RMS};
else
    varargout = {};
end
