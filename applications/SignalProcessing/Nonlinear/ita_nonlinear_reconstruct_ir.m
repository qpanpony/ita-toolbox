function varargout = ita_nonlinear_reconstruct_ir(varargin)
% Reconstruct a nonlinear impulse response from a set of harmonics. The
% time domain position of the harmonics is either given to the function or
% calculated from the sweep used excitation. This function is the 
% counterpart to ita_nonlinear_extract_harmonics.
%
%  Syntax:
%   audioObjOut = ita_nonlinear_reconstruct_nonlinear_impulse_response(audioObjIn,sweeprate,options)
%
%   Options (default):
%           'shift2samples' (false) : shift by samples instead of subsamples
%
%  Example:
%   audioObjOut = ita_nonlinear_reconstruct_ir(audioObjIn,sweeprate)
%   audioObjOut = ita_nonlinear_reconstruct_ir(audioObjIn,sweep)
%
%  See also:
%   ita_sweep_rate, ita_nonlinear_extract_harmonics,
%   ita_nonlinear_power_to_harmonic_series,
%   ita_nonlinear_harmonic_to_power_series
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_reconstruct_nonlinear_impulse_response">doc ita_nonlinear_reconstruct_nonlinear_impulse_response</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  12-Dec-2014 


%% Initialization and Input Parsing
sArgs        = struct('pos1_audioObjIn','itaAudio', 'pos2_sweeprate', '*','shift2samples',false);
[harmonics, sweeprate, sArgs] = ita_parse_arguments(sArgs,varargin); 

if isa(sweeprate,'itaAudio')
    sweeprate = ita_sweep_rate(sweeprate,[200 sweeprate.freqVector(end)]);
else
    sweeprate = double(sweeprate);
end

%% calculate IR positions
degree = 1:harmonics.nChannels;         
delta_t  = log2(degree) / sweeprate; % shifts of harmonics relative to fundamental

delta_samples = delta_t*harmonics.samplingRate;
if sArgs.shift2samples
   delta_samples = round(delta_samples);
end

%% shift harmonics to the corresponding positions 

harmonicsVector(harmonics.nChannels, 1) = itaAudio();
for idx = 1:harmonics.nChannels
    harmonicsVector(idx) = ita_time_shift(harmonics.ch(idx),-delta_samples(idx),'samples','frequencydomain');
end

nonlinearIR = sum(harmonicsVector);
%% Add history line
nonlinearIR = ita_metainfo_add_historyline(nonlinearIR,mfilename,varargin);

%% Set Output
varargout(1) = {nonlinearIR}; 

%end function
end