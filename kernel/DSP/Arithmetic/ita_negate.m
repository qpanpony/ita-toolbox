function varargout = ita_negate(a)
%ITA_NEGATE - Negate audio data (Minus)
%  This function multiplies the audio data by -1. Both frequency and time
%  data can be used.
%
%  Syntax: itaAudio = ita_negate(itaAudio)
%
%   See also ita_subtract, ita_add, ita_multiply_spk, ita_multiply_dat.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_negate">doc ita_negate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  24-Jun-2008

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

narginchk(1,1);

varargout{1} = -a;
% end