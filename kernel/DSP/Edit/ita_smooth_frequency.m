function varargout = ita_smooth_frequency(varargin)
%ITA_SMOOTH_FREQUENCY - Simple smoothing in frequency domain
%  This function is a simple frontend for ita_smooth
%
%  Syntax:
%   audioObjOut = ita_smooth_frequency(audioObjIn, options)
%
%   Options (default):
%           'bandwidth' (1): fractional octaves (e.g. 1/3; 1/12)
%
%  Example:
%   audioObjOut = ita_smooth_frequency(audioObjIn)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_smooth_frequency">doc ita_smooth_frequency</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  29-Mar-2010 

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'bandwidth', 1);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Set Output
if all(all(isreal(input.freqData)))
    varargout(1) = {ita_smooth(input,'LogFreqOctave1',sArgs.bandwidth,'real')}; 
else
    varargout(1) = {ita_smooth(input,'LogFreqOctave1',sArgs.bandwidth,'abs')};
end
%end function
end