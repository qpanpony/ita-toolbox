function varargout = ita_single(varargin)
%ITA_SINGLE - Convert data to single precision
%  This function converts the data to single precision
%
%  Syntax:
%   audioObj = ita_single(audioObj)
%
%  Example:
%   audioObj = ita_single(audioObj)
%
%   See also: ita_double.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_single">doc ita_single</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  22-Jul-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaAudio');
[result,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Conversion
%result.data = single(result.data); %RSC - unnecessary, won't do anything anyway
result.dataType = 'single';
result.dataTypeOutput = 'single';

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};

%end function
end