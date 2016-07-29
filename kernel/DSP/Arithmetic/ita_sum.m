function varargout = ita_sum(varargin)
%ITA_SUM - Sum up all channels
%  This function sums up over all channels in an itaAudioStruct
%
%  Syntax: itaAudio = ita_sum(itaAudio)
%
%   See also ita_add, ita_subtract, ita_power.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sum">doc ita_sum</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de

%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization
narginchk(1,1);
sArgs        = struct('pos1_data','itaSuper');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

data = sum(data);

%% Find output parameters
varargout(1) = {data};

%end function
end