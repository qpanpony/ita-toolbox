function varargout = ita_real(varargin)
%ITA_REAL - Real part of signal
%  This function calculates the real part of a signal's spectrum.
%
%  Syntax: itaAudio = ita_real(itaAudio)
%
%   See also ita_imag, ita_abs.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_real">doc ita_real</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  27-Feb-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaSuper');
[result,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% real part
result.freqData = real(result.freqData) ;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);
resChannelNames = result.channelNames;
for iChannel=1:result.nChannels
    resChannelNames{iChannel} = ['real(',resChannelNames{iChannel},')'];
end
result.channelNames = resChannelNames;

varargout(1) = {result};
%end function
end