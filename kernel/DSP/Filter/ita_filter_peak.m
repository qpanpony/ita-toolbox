function varargout = ita_filter_peak(varargin)
%ITA_FILTER_PEAK - Peak/Bell-Filter / Parametric-EQ
%  This function realizes a parametric EQ
%
%  Syntax:
%   audioObjOut = ita_filter_peak(audioObjIn, options)
%
%   Options (default):
%           'Q' (2):         description
%           'fc' (1000):     description
%           'gain' (20):     description
%
%  Example:
%   audioObjOut = ita_filter_peak(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_filter_peak">doc ita_filter_peak</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  06-May-2011 

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'Q', 2,'fc',1000,'gain',20);
if nargin == 0
    [input, sArgs] = ita_parse_arguments_gui(sArgs);
    
else
    [input,sArgs] = ita_parse_arguments(sArgs,varargin);
end

%% call boost
fc      = sArgs.fc;
fs      = input.samplingRate;
gain    = sArgs.gain;
Q       = sArgs.Q;

wcT     = 2*pi*fc/fs;

K  = tan(wcT/2);
V  = 10^(gain/20);

b0 =  1 + V*K/Q + K^2;
b1 =  2*(K^2 - 1);
b2 =  1 - V*K/Q + K^2;
a0 =  1 + K/Q + K^2;
a1 =  2*(K^2 - 1);
a2 =  1 - K/Q + K^2;
A  =  [a0 a1 a2] / a0;
B  =  [b0 b1 b2] / a0;

h  = freqz(B,A,input.freqVector,fs);

%% back to itaAudio
input.freqData = bsxfun(@times,h,input.freqData);

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end

