function str = ita_metainfo_units_exponent_check(str)
%ITA_HEADER_UNITS_EXPONENT_CHECK - Convert ^2 and ^3 strings
%  This function converts ² and ³ to ^2 and ^3 in strings
%
%  Syntax:
%   string = ita_header_units_exponent_check(string)
%
%  Example:
%   string = ita_header_units_exponent_check('kg²/s³')
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_header_units_exponent_check">doc ita_header_units_exponent_check</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  07-Dec-2009 

% For some more help read the 'ITA Toolbox Getting Started.pdf' 
% delivered with the ITA-Toolbox in the documentation directory, or use the
% wiki which provides more or less actual informations about the
% development. (https://www.akustik.rwth-aachen.de/ITA-Toolbox/wiki)

% ********************* NEVER CHANGE THIS FILE ****************************

% this should work for pc, mac and linux. Never change this file

%% find and replace
str = strrep(str,'²','^2');
str = strrep(str,'³','^3');

% ********************* NEVER CHANGE THIS FILE ****************************

%end function
end