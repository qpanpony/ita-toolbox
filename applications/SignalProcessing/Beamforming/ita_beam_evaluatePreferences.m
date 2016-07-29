function varargout = ita_beam_evaluatePreferences(varargin)
%ITA_BEAM_EVALUATEPREFERENCES - converts preferences into doubles to be used in the beamforming routines
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   double = ita_beam_evaluatePreferences(String)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   methodNr = ita_beam_evaluatePreferences('Method')
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_beam_evaluatePreferences">doc ita_beam_evaluatePreferences</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  24-May-2011 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_field','string');
[field,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% first get the valid preferences
prefs = ita_preferences('beamforming*');
prefNames = fieldnames(prefs);
definedPrefs = ita_preferences_beamforming;
prefix = 'beamforming_';
prefixLength = length(prefix);

% search for the given field
found = false;
for foundIdx = 1:numel(prefNames)
    if strcmp(prefNames{foundIdx}(prefixLength+1:end),field)
        found = true;
        break;
    end
end

if found % if there was a match, determine the current setting
    choice = prefs.([prefix field]); % this is the current choice
    % now determine the possible choices ...
    tmp = definedPrefs(find(strcmp(definedPrefs(2:end,1),[prefix field]))+1,:);
    possibleChoices = tmp{5};
    idx1 = strfind(possibleChoices,'[')+1;
    idx2 = strfind(possibleChoices,']')-1;
    possibleChoices = regexp(possibleChoices(idx1:idx2),'\|','split');
    % ... and compare to the current choice
    val = find(strcmpi(possibleChoices,choice));
    if isempty(val)
        error([thisFuncStr 'the current preference value of ' tmp{1}(prefixLength+1:end) ' seems to be incorrect']);
    end
else
    error([thisFuncStr 'the specified preference (' field ') does not exist']);
end

%% Set Output
varargout(1) = {val};

%end function
end