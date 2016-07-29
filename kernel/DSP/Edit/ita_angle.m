function varargout = ita_angle(varargin)
%ITA_ANGLE - Phase angle in radians of spectrum
%  This function calculates the phase values of the signal in the 
%  frequency domain.
%
%  Syntax: itaAudio = ita_angle(itaAudio)
%
%   See also ita_real, ita_abs.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_imag">doc ita_imag</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  12-Nov-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,3);
sArgs        = struct('pos1_data','itaSuper','unwrap',false);
[result,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 

if sArgs.unwrap
    result.freq = unwrap(angle(result.freq));
else
    result.freq = angle(result.freq);
    result.freq(result.freq < -0.999* pi) = abs(result.freq(result.freq < -0.999 * pi));
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end