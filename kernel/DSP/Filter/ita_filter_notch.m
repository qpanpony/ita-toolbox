function varargout = ita_filter_notch(varargin)
%ITA_FILTER_NOTCH - build equalization filter of type notch
%  This function produces a filter for equalization. The parameters are
%  center frequency and quality factor.
%
%  The filter is implemented as biquad filters using freqz.
%
%  Syntax:
%   audioObjOut = ita_filter_notch(audioObj, options)
%
%   Options (default):
%           'Q' (10)                        : quality factor
%           'fc' (1000)                     : center frequency
%
%  Example:
%   audioObjOut = ita_filter_notch(audioObj,'Q',100,'gain',-8.5)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_filter_notch">doc ita_filter_notch</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  08-May-2011 

%% Initialization and Input Parsing
sArgs        = struct('pos1_input','itaAudio','Q', 2,'fc',1000);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Variables
omega_0 = 2*pi*sArgs.fc/input.samplingRate;
alpha = sin(omega_0)/(2*sArgs.Q);
freqVector = input.freqVector;

%% Filter coefficients
% H(s) = (s^2 + 1)/(s^2 + s/Q + 1)
b0 = 1;
b1 = -2*cos(omega_0);
b2 = 1;
a0 = 1 + alpha;
a1 = -2*cos(omega_0);
a2 = 1 - alpha;

h = freqz([b0 b1 b2],[a0 a1 a2],freqVector,input.samplingRate);
% specsString = ['f0 = ' num2str(sArgs.f0) ', Q = ' num2str(sArgs.Q) ', Gain = ' num2str(sArgs.gain) ' dB'];
input.freqData = bsxfun(@times,h,input.freqData);

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input}; 

%end function
end