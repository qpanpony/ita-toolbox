function varargout = ita_cepstrum(varargin)
%ITA_CEPSTRUM - Calculate cepstrum
%  This function calculates the cepstrum of a signal. Output is the
%  Quefrency domain.
%
%  Syntax: itaAudio = ita_cepstrum(itaAudio)
%    options 'mode' ('complex') or 'real'
%   See also ita_icepstrum, cceps, rceps.
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
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaAudioTime','mode','complex');
[result,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Calculate Cepstrum
switch(lower(sArgs.mode))
    case 'complex'
        cepstrum = @cceps;
    case 'real'
        cepstrum = @rceps;
end
    
for idx = 1:result.nChannels
    [result.time(:,idx),ND(idx)] = cepstrum(result.time(:,idx));
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    ita_plot_time(result);
elseif nargout == 1
    % Write Data
    varargout(1) = {result};
elseif nargout == 2
    % Write Data
    varargout(1) = {result};
    varargout(2) = {ND};
end

%end function
end