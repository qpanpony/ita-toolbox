function varargout = ita_icepstrum(varargin)
%ITA_ICEPSTRUM - Calculate inverse complex cepstrum
%  This function calculates the signal from a cepstrum.
%
%  Call: itaAudio = ita_icepstrum(itaAudio)
%
%   See also ita_cepstrum, icceps, rceps.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_cepstrum">doc ita_cepstrum</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Feb-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
if nargin >= 1
    result = varargin{1};
end

if nargin >= 2
    delay = varargin{2};
else
    delay = 0;
end

if length(delay) ~= result.nChannels
    delay = repmat(delay,result.nChannels);
end

%% Calculate inverse complex cepstrum
for idx = 1:result.nChannels
    result.time(:,idx) = icceps(result.time(:,idx),delay(idx));
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Check header
%result = ita_metainfo_check(result);

%% Find output parameters
varargout(1) = {result};
%end function
end