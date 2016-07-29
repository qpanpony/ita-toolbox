function varargout = ita_negTozero(varargin)
%ITA_NEGTOZERO - makes the negative entries in all channels vectors zero
%  This function makes the negative entries in all channels vectors zero.
%
%  Syntax: itaAudio = ita_negTozero(itaAudio)
%
%   See also 
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_negTozero">doc ita_negTozero</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Matthias Lievens -- Email: mli@akustik.rwth-aachen.de
% Created:  16-Mar-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaAudioFrequency');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Positive side
result = data;
result.freqData = data.freqData.*(sign(data.freqData)+1)/2;

for iChannel=1:result.nChannels
    result.channelNames{iChannel}=['positive(',result.channelNames{iChannel},')'];
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result}; 

%end function
end