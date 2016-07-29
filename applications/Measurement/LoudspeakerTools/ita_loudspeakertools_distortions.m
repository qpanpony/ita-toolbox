function varargout = ita_loudspeakertools_distortions(varargin)
% ita_loudspeakertools_distortions - Calculate the THD, THD-N and HD's with
% noise of a loudspeaker
% This function takes a sine of a specified excitation frequency and
% calculates various distortion values out of a measurement.
%
% Syntax: [uSPL THD THDN HD k_factor] = ita_loudspeakertools_distortion(sine,excitationFreq,nHarmonics,impLS,ampVoltage);
% Explanations:
% sine              - excitation signal
% excitationFreq    - excitation frequency
% nHarmonics        - number of harmonics to calculate
% impLS             - nominal loudspeaker impedance
% ampVoltage        - input voltage for the amp
%
%   See also
%      ita_portaudio, ita_measurement, ita_time_shift, ita_time_window,
%      ita_generate, ita_invert_spk_regularization, ita_amplify, itaResult
%
% Author: Christian Haar -- christian.haar@akustik.rwth-aachen.de
% Created: May-2011

% Update to new measurement setup structure in 2014
% MMT -- mmt@akustik.rwth-aachen.de

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Organize Input
sArgs = struct('pos1_MS','itaMSPlaybackRecord','pos2_outputVoltage','anything','excitationFreq',1000,'nHarmonics',4,'windowSamples',[]);
[MS,outputVoltage,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Measurement, HD, THD, THDN Calculation
% measurement
outputVoltage = double(outputVoltage);
sine = ita_generate('sine',1,sArgs.excitationFreq,MS.samplingRate,MS.fftDegree,'fullperiod');
if ~(isempty(sArgs.windowSamples) || sArgs.windowSamples == 0)
    sine = ita_time_window(sine,[sArgs.windowSamples,1,sine.nSamples-sArgs.windowSamples,sine.nSamples-1],@hann,'samples');  % windowing to avoid "clac" in the LS because beginning and end of the sine are not smoothly cross-faded
end

excitationFreq = sine.freqVector(sine.freq2index(str2double(sine.comment(7:end-3))));
% set correct outputVoltage (take care of the correct calibration!)
MS.excitation = sine;
MS.outputVoltage = outputVoltage;

if str2double(MS.outputamplification(1:end-4)) > -1
    error('The desired output voltage cannot be reached with the current settings!');
end

ita_verbose_info(['Play and record a sine with a frequency of ' num2str(excitationFreq) ' Hz, at a voltage of ' num2str(MS.outputVoltage) 'V.'],1);
[distortedSine,maxLevel] = MS.run_raw_imc;

if maxLevel >= 1
    error('Clipping ocurred, result is unreliable!');
end

[THD, HD, THDN, THD_F] = ita_nonlinear_calculate_thd(distortedSine, 'degree', sArgs.nHarmonics, 'excitation', 'sine', 'excitationFrequency', excitationFreq);

%% set output variables
varargout{1} = distortedSine.freq2value(excitationFreq); % for MAX SPL
varargout{2} = THD;
varargout{3} = THDN;
varargout{4} = THD_F;
varargout{5} = HD;

end % function
