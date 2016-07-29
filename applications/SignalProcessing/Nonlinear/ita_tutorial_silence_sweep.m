%% Tutorial how to use ITA_SILENCE_SWEEP (from Farina)
% 
%% ITA_SILENCE_SWEEP
% Draft of the Silence Sweep Method from Farina. This algorithm was created
% to perform a comparison between Silence Sweep and other existing Methods
% by using virtually distorted signals.
%
%
% See also
%   ita_generate, ita_extend_dat, ita_time_shift, ita_time_crop
%   ita_invert_spk_regularization, ita_get_value,
%   ita_nonlinear_power_series

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Alexandre Bleus -- alexandre.bleus@akustik.rwth-aachen.de
%         Pascal Dietrich -- pdi@akustik.rwth-aachen.de
% Created: June-2010

%% Initialization
ccx
amp         = 1;
sr          = 44100;
MLS_order   = 18;
freq_vec    = [20 20000];
stop_margin = 1;
NTIcoeffs   = [1 0.2];

%% Generating a long MLS signal
mls = ita_generate_mls('fftDegree', MLS_order, 'samplingRate', sr) * amp;
mlslength = mls.nSamples;

%% Performing a hole in the MLS signal
hlength = round(mlslength/10);
hmls = ita_extend_dat(mls,mlslength+1);
hmls.timeData(1:hlength) = 0;

%% Sweep and compensation
sweep = amp*ita_generate_sweep('mode','exp','freqRange',freq_vec,'stopMargin',stop_margin,'samplingRate',sr,'fftDegree',mlslength+1);
sweep = ita_time_shift(sweep,stop_margin/4);
sweep.signalType = 'energy'; % because acts as a filter
comp = ita_invert_spk_regularization(sweep,freq_vec);

%% Silence Sweep
silencesweep = hmls*sweep;
silencesweep = silencesweep/ita_get_value(silencesweep,'rms');

%% Distortion
record = ita_nonlinear_power_series(silencesweep,NTIcoeffs);

%% Deconvolution and windowing
result = record*comp;
result_silence_sweep = ita_time_crop(result,[1, hlength], 'samples');
result_silence_sweep.signalType = ['energy'];
result_silence_sweep.channelNames{1} = 'Result of the Silence Sweep';


%% Multiple Silence Sweep
nMax = 20;
for idx = 1:nMax
    hlength = round(mlslength/10);
    hmls = ita_extend_dat(ita_time_shift(mls,idx*round(mls.nSamples/(nMax+1)),'samples'),mlslength+1);
    hmls.timeData(1:hlength) = 0;
    silencesweep = hmls*sweep;
    silencesweep = silencesweep/ita_get_value(silencesweep,'rms');
    record = ita_nonlinear_power_series(silencesweep,NTIcoeffs);
    result = record*comp;
    result_idx(idx) = ita_time_crop(result,[1, hlength], 'samples');
    result_idx(idx).signalType = 'energy';
end

result_silence_sweep_av = sum(abs(result_idx'))/nMax;
result_silence_sweep_av.channelNames{1} = ['Result of the Multiple Silence Sweep - Averages: ' num2str(nMax) ];

