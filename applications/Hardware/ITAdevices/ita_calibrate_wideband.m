function varargout = ita_calibrate_wideband(varargin)
%ITA_CALIBRATE_WIDEBAND - Wideband calibration of microphones
%  This function calibrates a microphone using an already calibrated reference.
%
%  Syntax: spectrum = ita_calibrate_wideband(measurementSetup)
%        spectrum = ita_calibrate_wideband(measurementSetup,'referenceChannel',chNr)
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_calibrate_wideband">doc ita_calibrate_wideband</a>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  24-Aug-2009 (Henrik Behm)
% Rewrite:  07-Apr-2014 (MMT)

%% Initialization and Input Parsing
narginchk(0,8);
sArgs        = struct('pos1_MS','itaMSTF','referenceChannel',1,'windowVector',[0.025 0.03],'plot',false);
[MS,sArgs] = ita_parse_arguments(sArgs,varargin);

% will always be a 2-channel setup
if numel(MS.inputChannels) ~= 2
    error('You need a measurement setup with two iput channels (one reference, one DUT)');
end

% check for out-of-range channel
if ~ismember(MS.inputChannels,sArgs.referenceChannel)
    error('Wrong reference channel, is not in the measurement setup');
else
    referenceIdx = find(MS.inputChannels == sArgs.referenceChannel);
end

% only makes sense for calibrated devices (except for DUT)
if ~MS.inputMeasurementChain(referenceIdx).calibrated
    MS.calibrate_input;
end

%% Measurement ...
ita_verbose_info('Measuring impulse responses ... ',0);
pause(2);

res = MS.run;
ita_verbose_info('Measuring impulse responses ... done ',0);

%% ... and post-processing
% check for high latency (no output calibration)
latencySamples = max(ita_start_IR(res));

if latencySamples/MS.samplingRate > MS.stopMargin
    ita_verbose_info('Careful! High latency detected, please do output calibration',0);
    ita_verbose_info('Results may not be reliable');
end
res = ita_time_shift(res,-latencySamples,'samples');

res_win = ita_time_window(res,sArgs.windowVector,'time','symmetric');
ref = res_win.ch(referenceIdx);
cal = res_win.ch(setdiff(1:numel(MS.inputChannels),referenceIdx));

result = cal*ita_invert_spk_regularization(ref,MS.finalFreqRange);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% plot
if sArgs.plot
    tmp = merge(ref,cal,result);
    tmp.freq = bsxfun(@rdivide,tmp.freq,mean(abs(tmp.freq2value(950,1050))));
    tmp.channelUnits(:) = {''};
    tmp.comment = 'Normalized Results';
    tmp.channelNames = {'Reference response','Specimen response','Calibration result'};
    tmp.plot_freq_phase;
end

varargout(1) = {result};
%end function
end