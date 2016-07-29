function varargout = ita_automatic_time_window(varargin)
%ITA_AUTOMATIC_TIME_WINDOW - do time windowing automatically
%  This function uses the function ita_frequency_dependent_time_window
%  together with the knowledge about the desired crossfade frequencies to
%  generate automatic values for the time windowing.
%
%  Syntax:
%   audioObjOut = ita_automatic_time_window(audioObjIn, options)
%
%   Options (default):
%           'degree' (defaultopt1)      : determines the number of frequencies
%                                         to use for crossfading / time windowing
%                                         (only used if crossfadeFrequencies are empty)
%           'freqRange' ([20 20000])    : overall frequency limits
%           'periods' (4)               : description
%           'crossfadeFrequencies ([])  : directly enter the desired
%                                         frequencies
%           'crossfadeRange' (100)      : fading region for crossfading
%           'dc' (true)                 : use dc correction for time window
%           'symmetric' (false)         : use symmetric windows
%           'crop' (false)              : crop after windowing
%
%  Example:
%   audioObjOut = ita_automatic_time_window(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_automatic_time_window">doc ita_automatic_time_window</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  18-Nov-2011 


%% Initialization and Input Parsing
sArgs        = struct('pos1_input','itaAudio', 'degree', 3, 'freqRange', [20 20000],'periods',4,'crossfadeRange',100,'crossfadeFrequencies',[],'dc',true,'symmetric',false,'crop',false);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

if isempty(sArgs.crossfadeFrequencies)
    freqs = logspace(log10(sArgs.freqRange(1)),log10(sArgs.freqRange(2)),max(sArgs.degree,3));
else
    freqs = sArgs.crossfadeFrequencies;
end

%% do the time windowing for the different frequency intervals
% determine the length of one period for each frequency
Ts    = 1./freqs(1:end-1);
initialWinMatrix = bsxfun(@times,[0.9 1],sArgs.periods.*Ts(:));

% if the fading region is to wide
if sArgs.crossfadeRange/2 > min(diff(freqs))
    sArgs.crossfadeRange = min(diff(freqs))*0.9;
end

% determine location of impulse
impulseTimes = ita_start_IR(input)./input.samplingRate;

% do the processing for each channel
result = itaAudio([input.nChannels 1]);
for iCh = 1:input.nChannels
    % shift the windows accordingly
    winMatrix = impulseTimes(iCh) + initialWinMatrix;
    % do the frequency dependent windowing 
    result(iCh) = ita_frequency_dependent_time_window(input.ch(iCh),winMatrix,freqs(2:end-1),'range',sArgs.crossfadeRange,'dc',sArgs.dc,'symmetric',sArgs.symmetric);
    % apply final window to eliminate effect of crossfading
    result(iCh) = ita_time_window(result(iCh),winMatrix(1,:),'symmetric',sArgs.symmetric,'crop',sArgs.crop);
end

result = merge(result);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Set Output
varargout(1) = {result}; 

%end function
end