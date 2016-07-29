function result = ita_analytic_directivity_freefield(this, direction)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


result = itaAudio;
result.domain = 'freq';
result.samplingRate = this.samplingRate;
result.freqData = zeros(this.nBins,this.nChannels);

d = this.channelCoordinates - direction;
d = d.r;

delta_t = double(d ./ ita_constants('c'));

f = result.freqVector;
omega = repmat(2*pi*f,1,this.nChannels);
delta_t = repmat(delta_t.',this.nBins,1);
result.freqData =  1 .* exp(-1i*omega.*delta_t);

ita_verbose_info('ita_time_shift: shifting in frequency domain, please be very careful with this one!',1)

result.channelNames = this.channelNames;
result.channelUnits = this.channelUnits;
result.channelCoordinates = this.channelCoordinates;
result.signalType = this.signalType;
