function audioObj = ita_result2audio_spk(resultObj, samplingRate, nBins, varargin)
%ita_result2audio_spk - Converts an itaResult with frequency data into
%itaAudio using interpolation and extrapolation in the frequency domain
% Data outside of the valid frequency range is extrapolated with zeros.
% Optionally, a filter can be applied.
%
%   Syntax: itaResult = ita_result2audio_spk(itaResult, samplingRate, nBins, Options)
%
%       Options (default):
%           filter ('none'):    'none', 'lowpass', 'highpass', 'bandpass'
%           filterorder (20):   order for the filtering
%
%   See also ita_result2audio, ita_interpolate_spk_result
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_result2audio_spk">doc ita_result2audio_spk</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%% For error handling
thisFuncStr  = [upper(mfilename) ':'];

%% Initialization and Input Parsing
sArgs = struct('pos1_data','itaResult','pos2_samplingRate','integer', 'pos3_nBins','integer');
ita_parse_arguments(sArgs,{resultObj, samplingRate, nBins});
assert(logical(resultObj.isFreq), [thisFuncStr 'Data must be in frequency domain.'])

sArgs  = struct('filter', 'none', 'filterorder', 20);
sArgs = ita_parse_arguments(sArgs,varargin);
doLowPass = isequal(sArgs.filter, 'bandpass') || isequal(sArgs.filter, 'lowpass');
doHighPass = isequal(sArgs.filter, 'bandpass') || isequal(sArgs.filter, 'highpass');
doBandPass = isequal(sArgs.filter, 'bandpass');

fMin = resultObj.freqVector(1);
fMax = resultObj.freqVector(end);

%% Interpolation
newFreqs = linspace(0,samplingRate/2,nBins);
resultObj = ita_interpolate_spk_result(resultObj, newFreqs, 'absphase', true, 'extrap', 'zeros');

%% Conversion
sObj = saveobj(resultObj);
sObj = rmfield(sObj,[{'classname','classrevision'},itaResult.propertiesSaved]);
audioObj = itaAudio(sObj);
audioObj.signalType = 'energy';
audioObj.samplingRate = samplingRate;

%% Filter
upperExtrapDone = fMax < audioObj.freqVector(end);
lowerExtrapDone = fMin > audioObj.freqVector(1);

if doBandPass && upperExtrapDone && lowerExtrapDone
    audioObj = ita_mpb_filter(audioObj, [fMin, fMax], 'order', sArgs.filterorder);
elseif doHighPass && upperExtrapDone
    audioObj = ita_mpb_filter(audioObj, [0, fMax], 'order', sArgs.filterorder);
elseif doLowPass && lowerExtrapDone
    audioObj = ita_mpb_filter(audioObj, [fMin, 0], 'order', sArgs.filterorder);
end