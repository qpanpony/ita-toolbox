function varargout = ita_time_reverse(varargin)
%ITA_TIME_REVERSE - Reverse time data
%  This function reverses the time audio information. Therefore, the end
%  becomes the beginning and vice versa.
%
%  Call: itaAudio = ita_time_reverse(itaAudio)
%
%   See also ita_time_window, ita_invert_spk, ita_negate.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_time_reverse">doc ita_time_reverse</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 03-Jul-2008


%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization
%Inarg checking
narginchk(1,1);
sArgs   = struct('pos1_num','itaAudioTime');
[result, sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Time Reversing
result.dat = result.dat(:,end:-1:1);

%% Add History Line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
