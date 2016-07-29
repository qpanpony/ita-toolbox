function varargout = ita_nonlinear_time_window(varargin)
%ITA_NONLINEAR_TIME_WINDOW - Applies a time window to a IR which preserves harmonics up to a specified degree
%  This function applies a time window to a impulse response but preserves
%  harmonics up to a specified degree by applying a left and a right
%  window. This is done via a left and a right window, both of which are 
%  set corresponding to the positions of the number of harmonics. 
%  The start time and length of the left window can be set
%  manually. Additionally, the normalized window length and relative 
%  starting time of both windows can be specified. 
%
%  Syntax:
%   audioObjOut = ita_nonlinear_time_window(audioObjIn, sweeprate, options)
%
%   Options (default):
%           'windowFactor' (0.9)    : normalized window length
%           'windowStart' (0.7)     : window start relative to the window length calculated for each harmonic
%           'leftWindowLength' ([]) : length of the left window
%           'leftWindowStart' ([])  : start time of the left time window
%
%  Example:
%   audioObjOut = ita_nonlinear_time_window(audioObjIn, sweeprate, options)
%   audioObjOut = ita_nonlinear_time_window(audioObjIn, sweep, options)
%
%  See also:
%   ita_nonlinear_extract_harmonics, ita_nonlinear_reconstruct_ir,
%   ita_time_window
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_nonlinear_time_window">doc ita_nonlinear_time_window</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  15-Dec-2014 


%% Initialization and Input Parsing
sArgs = struct('pos1_audioObjIn','itaAudio','pos2_data', '*','degree',5, ...
               'windowFactor',0.6,'windowStart',0.7,'leftWindowLength',[],'leftWindowStart',[]);

[audioObjIn, sweeprate, sArgs] = ita_parse_arguments(sArgs, varargin);

if isa(sweeprate,'itaAudio')
    sweeprate = ita_sweep_rate(sweeprate,[200 sweeprate.freqVector(end)]);
else
    sweeprate = double(sweeprate);
end


degree = 1:sArgs.degree;
tLength = diff([0 log2(degree+1)/sweeprate]);

if ~isempty(sArgs.leftWindowLength) && ~isempty(sArgs.leftWindowStart)
    windowLeft = [sArgs.leftWindowStart sArgs.leftWindowStart+sArgs.leftWindowLength];
else
    windowLeft = [sArgs.windowStart 1] * sArgs.windowFactor * tLength(1);
end
windowRight = audioObjIn.trackLength - sum(tLength(1:sArgs.degree-1)) - tLength(sArgs.degree)/4 - [sArgs.windowStart 1] * sArgs.windowFactor * tLength(sArgs.degree);

channelName = audioObjIn.channelNames{1};
audioObjIn = ita_time_window(audioObjIn, windowLeft, 'time') + ita_time_window(audioObjIn, windowRight, 'time');
audioObjIn.channelNames = {channelName};
audioObjIn = ita_metainfo_add_historyline(audioObjIn,mfilename,varargin);
varargout{1} = audioObjIn;

%end function
end