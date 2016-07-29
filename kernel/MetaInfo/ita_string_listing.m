function varargout = ita_string_listing(varargin)
%ITA_STRING_LISTING - creates a list from a string cell
%  This function creates a listing from a cell of stings. 
%  
%
%  Syntax:
%   outString = ita_string_listing(cellString, options)
%
%   Options (default):
%           'seperator' (', ')        : seperator of strings
%           'noSeperatorAtEnd' (true) : seperator at the end of the listing
%
%  Example:
%   
%   ita_string_listing(cellString)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_string_listing">doc ita_string_listing</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  11-Nov-2012 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_data','cell', 'seperator', ', ', 'noSeperatorAtEnd', true);
[cellString ,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% 

cellString = ita_sprintf('%s%s', cellString, sArgs.seperator);

outString = [cellString{:}];

if sArgs.noSeperatorAtEnd 
    outString = outString(1:end-length(sArgs.seperator));
end

%% Set Output
varargout(1) = {outString}; 

%end function
end