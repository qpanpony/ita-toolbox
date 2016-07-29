function varargout = ita_zerophase(varargin)
%ITA_ZEROPHASE - Change phase to zero
%  This function deletes the phase of a filter to be zero.
%  The output is always in frequency domain.
%
%  Syntax: itaAudio = ita_zerophase(itaAudio)
%
%   See also ita_mpb_filter, ita_minimumphase.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_zerophase">doc ita_zerophase</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  04-Jul-2008 


%% Initialization
narginchk(1,1); 
sArgs   = struct('pos1_num','itaAudioFrequency');
[result, sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<ASGLU>

%% Body
result.freq = abs(result.freq);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
end
