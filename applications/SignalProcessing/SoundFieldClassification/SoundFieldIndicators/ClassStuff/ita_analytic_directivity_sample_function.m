function result = ita_analytic_directivity_sample_function(this, direction,minphase)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if ~exist('minphase','var')
    minphase = 1;
end

result = itaAudio;
result.domain = 'freq';
result.samplingRate = this.samplingRate;
result.freqData = zeros(this.nBins,this.nChannels);

d = this.channelCoordinates - direction;
d = d.r;

delta_t = double(d ./ ita_constants('c'));
delta_t = delta_t - min(delta_t);
if ~minphase
    delta_t = delta_t + result.trackLength/4;
end

f = result.freqVector;
omega = repmat(2*pi*f,1,this.nChannels);
delta_t = repmat(delta_t.',this.nBins,1);

result.freqData =  bsxfun(@times, 1./d.' , exp(-1i*omega.*delta_t));
%result.freqData =  bsxfun(@times, 1./(1+d.') , exp(-1i*omega.*delta_t));

result = result / mean(result.rms);

%ita_verbose_info('ita_time_shift: shifting in frequency domain, please be very careful with this one!',1)

result.channelNames = this.channelNames;
result.channelUnits = this.channelUnits;
result.channelCoordinates = this.channelCoordinates;

