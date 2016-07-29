function result = ita_invert_spk_regularization(varargin)
%ita_invert_spk_regularization - Invert spectrum (Kirkeby method)
%  This function inverts a spectrum in Frequency domain, commonly used for
%  sweep excitation signals, after a method proposed by Angelo Farina.
%  Farina's method is only a one-dimensional look on Kirkeby's method.
%  Given a frequency vector consisting of lower and higher cutoff frequency
%  this functions operates in the given frequency range by inverting the
%  signal. The resulting spectrum is therefore a compensation spectrum.
%  Multiplied with the input spectrum, the obtained impulse response is
%  very compact.
%

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%  Syntax:
%   itaAudio = ita_invert_spk_regularization(itaAudio, [low_freq high_freq])
%
%  Example:
%   audioObj = ita_invert_spk_regularization(audioObj,[40 10000])
%
%   See also: ita_invert_spk_regularization_old, ita_divide_spk, ita_generate.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_invert_spk_regularization">doc ita_invert_spk_regularization</a>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-May-2009 
% Modified: 31-Aug-2009 - guski - Added warning if nSamples ~= 2^N
% Modified: 09-Dec-2009 - pdi - odd nSamples problem solved

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudioFrequency','pos2_freqvec','vector','beta_pass',0,'beta_stop',1,'filter',false,'pzmode',false,'zerophase',true);
[data,freq_vec,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Init
data.signalType = 'energy';

b = data * 0 + sArgs.beta_pass;
a = data * 0 + sArgs.beta_stop;

f_low  = freq_vec(1); 
f_high = freq_vec(2);

%% Generate epsilon for regularization
epsilon = ita_xfade_spk(a,b,[f_low/sqrt(2),f_low]);
epsilon = ita_xfade_spk(epsilon,a,[f_high, min(f_high*sqrt(2),epsilon.samplingRate/2)]);

epsilon = epsilon + 1*eps;

%% Minimum-phase regularization

rms = data.rms;
% data = data/rms;

% calculate effect of regularization on spectrum
R = 1 / (1 + (epsilon*rms)^2 / (ita_conj(data)*data));

% find minimum phase for this "filter"

aux = R.timeData;
R.timeData = ifft(log(abs(fft(aux) + 3*eps)));
N = R.nSamples;

% define the size of the window
% 0 gives a rectangular window at the middle of the sequence while 1 gives
% a hann window with the same period as the whole sequence
w_size = .9;
T = round(w_size*N);
if T >= N-3
    T = N-3;
end
if rem(T-1,2) == 1
    T = T+1;
end

% in cepstrum domain, shift the non-causal components
u = [1; 2*ones((N-T-1)/2,1); cos(pi*(0:T-1)'/T)+1; zeros((N-T-1)/2,1)]; %pode colocar uma transicao mais suave no meio.
R.timeData = R.timeData.*u;
H = R;
H.timeData = ifft(exp(fft(R.timeData)),'symmetric');

% invert signal and apply regularization
result = H / data;

%% ChannelName handling
for idx = 1:data.nChannels
   result.channelNames{idx} = ['1 / ' data.channelNames{idx} ];
   result.channelUnits{idx} = ita_deal_units('',data.channelUnits{idx},'/');
end

%% Add history line
result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%end function
end