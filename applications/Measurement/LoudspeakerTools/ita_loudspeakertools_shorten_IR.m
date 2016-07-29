function varargout = ita_loudspeakertools_shorten_IR(varargin)
%ITA_LOUDSPEAKERTOOLS_SHORTEN_IR - find optimum short IR
%  This function searches for the best way to shorten an impulse repsponse
%  (IR), usually a filter. This will be done by shifting the impulse
%  response, then windowing and comparing to the original. The optimization
%  goal is a minimum variation in level and group delay.
%
%  Syntax:
%   audioObjOut = ita_loudspeakertools_shorten_IR(audioObjIn, options)
%
%   Options (default):
%           'fftDegree' (13)        : final FFT degree of IR
%           'freqRange' ([20 500])  : freq range for error analysis
%           'minimumphase' (false)  : first make IRs minimumphase
%
%  Example:
%   audioObjOut = ita_loudspeakertools_shorten_IR(audioObjIn,'fftDegree',10)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_shorten_fir_filter">doc ita_shorten_fir_filter</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  08-Nov-2011

%% Initialization and Input Parsing
sArgs        = struct('pos1_input','itaAudio', 'minimumphase', false, 'fftDegree', 13, 'freqRange', [20 500]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

if input.nChannels > 1
    error('For now only one channel please (this is probably the only thing that makes sense)');
end

if sArgs.minimumphase
    input = ita_minimumphase(input);
end

%% constants
tWin = 2^(sArgs.fftDegree-1);
deltaOffset = 8;
winVec = [floor(0.9*tWin) floor(0.99*tWin)];

freqIds = input.freq2index(sArgs.freqRange(1),sArgs.freqRange(2));

%% get a short filter by (acausal) shifting, windowing and extracting
[maxVal, maxIdx] = max(abs(input.time)); %#ok<ASGLU>
if any(maxIdx > 0.9*input.nSamples) % then auto shift will not work
    initialDelay = -max(maxIdx)+1;
else
    initialDelay = -max(ita_start_IR(input))+1;
end
input = ita_time_shift(input,initialDelay,'samples'); % IR might be acausal now

%% optimize
lb = -max(winVec);
ub = max(winVec);

% goal function
f = @(x) sum(abs(optimFunc(x,input,winVec,freqIds)).^2);

shiftSamples = lb:deltaOffset:ub;
errRes = zeros(numel(shiftSamples),1);

for iShift = 1:numel(shiftSamples)
    errRes(iShift) = f(shiftSamples(iShift));
end
% find optimum
[minErr,minIdx] = min(errRes); %#ok<ASGLU>
offset = shiftSamples(minIdx);

%% extract the windowed filter response
input_win   = ita_time_window(ita_time_shift(input,offset,'samples'),winVec,'symmetric');
input_win = ita_extract_dat(ita_time_shift(input_win,tWin,'samples'),sArgs.fftDegree);

finalDelay = tWin+offset;
if finalDelay < 0
    finalDelay = input_win.nSamples + finalDelay;
end

%% Add history line
input_win = ita_metainfo_add_historyline(input_win,mfilename,varargin);

%% Set Output
varargout(1) = {input_win};
if nargout > 1 % also return the delay
    varargout{2} = finalDelay;
end

%end function
end

%% subfunctions
function err = optimFunc(offset,input,winVec,freqIndex)

input_shift = ita_time_shift(input,round(offset),'samples');
input_win   = ita_time_window(input_shift,winVec,'symmetric');
result      = input_win/input_shift;

ampl_dB     = result.freqData_dB;
groupDelay  = ita_groupdelay(result);

errAmpl     = ampl_dB(freqIndex,:);
errGr       = groupDelay(freqIndex,:);

% group delay in milliseconds
err = [(errAmpl-mean(errAmpl)); 1000.*(errGr - mean(errGr))];
end