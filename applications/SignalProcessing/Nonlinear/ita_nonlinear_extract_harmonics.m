function varargout = ita_nonlinear_extract_harmonics(varargin)
%ITA_NONLINEAR_EXTRACT_HARMONICS - Find harmonic peaks in IR (exp. sweep measurements) and extract them.
%  This function finds the peaks or IR of the harmonics (non-linear system)
%  in an impulse response measured with an exp. sweep and extracts them.
%  The output is an itaAudio Object with number of channels corresponding
%  to the maximum degree specified to be extracted.
%
%  Syntax:
%   [audioObjOut preShiftSamples] = ita_nonlinear_extract_harmonics(IR, sweeprate, options)
%   [audioObjOut preShiftSamples] = ita_nonlinear_extract_harmonics(IR, sweep_used, options)
%
%   Options (default):
%           'degree' (5)            : maximum order of harmonics
%           'windowFactor' (0.9)    : normalized window length
%           'windowStart' (0.7)     : window start relative to the window length calculated for each harmonic
%           'compPreShift' (false)  : compensate pre shift of IR to zero
%           'shift2samples' (false) : shift by samples instead of subsamples
%
%  See also:
%   ita_generate_sweep, ita_nonlinear_limiter
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_extract_harmonics">doc ita_nonlinearities_find_harmonics</a>

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Jul-2011 

% renamed from ita_nonlinearities_find_harmonics
% 18-Dec-2014 -- Marco Berzborn -- marco.berzborn@akustik.rwth-aachen.de

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'pos2_data', '*','compPreShift',false, ...
               'windowFactor',0.6,'windowStart',0.7,'degree',5,'shift',true,'shift2samples',false);
[h_nonlin, sweeprate, sArgs] = ita_parse_arguments(sArgs,varargin); 

if isa(sweeprate,'itaAudio')
    sweeprate = ita_sweep_rate(sweeprate,[200 sweeprate.freqVector(end)]);
else
    sweeprate = double(sweeprate);
end
%% shift the IR to position zero
%  needed since the applied window will be symmetric around zero
preShiftSamples = ita_start_IR(h_nonlin);
h_nonlin = ita_time_shift(h_nonlin,-preShiftSamples,'samples');

%% find harmonics and shift
degree = 1:sArgs.degree;         
delta_t  = log2(degree) / sweeprate; % shifts of harmonics relative to fundamental

delta_samples = delta_t*h_nonlin.samplingRate;
if sArgs.shift2samples
   delta_samples = round(delta_samples);
end

t_length = diff([0 log2(degree+1)/sweeprate]);

%% shift harmonic IRs to beginning
harmonics(sArgs.degree, 1) = itaAudio();
for idx = 1:sArgs.degree
    harmonics(idx) = ita_time_shift(h_nonlin,delta_samples(idx),'samples','frequencydomain'); %compensate delta t shift of harmonic IRs, pdi: frequencydomain for subsample shifts!
    if sArgs.windowFactor
        harmonics(idx) = ita_time_window(harmonics(idx), [sArgs.windowStart 1] * sArgs.windowFactor * t_length(idx), 'time', 'symmetric');
    end
    if ~sArgs.shift
        harmonics(idx) = ita_time_shift(harmonics(idx),-delta_samples(idx),'samples','frequencydomain'); % shift back, if no shift is wanted
    end
    harmonics(idx).channelNames{1} = ['harmonic: ' num2str(idx) ];
end
harmonics = harmonics.merge;

%% compensate pre-shift
if sArgs.compPreShift
    harmonics = ita_time_shift(harmonics,preShiftSamples,'samples');
end
%% Add history line
harmonics = ita_metainfo_add_historyline(harmonics,mfilename,varargin);

%% Set Output
varargout{1} = harmonics;
varargout{2} = preShiftSamples;

%end function
end
