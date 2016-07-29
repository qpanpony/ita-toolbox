function varargout = ita_freqfromchannelname(varargin)
%ITA_FREQFROMCHANNELNAME - Return frequency(s) from channel name(s)
%
%  Syntax:
%  frequencies = ita_freqfromchannelname(audioObj)
%
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_freqfromchannelname">doc ita_freqfromchannelname</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-May-2009 

%% HUHU delete soon
ita_verbose_obsolete('Please use class functions instead')

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaAudio');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 
ChannelNames = data.channelNames;

for idx = 1:numel(ChannelNames)
    %split Number from ChannelName
   Name = ChannelNames{idx};
   digits = isstrprop(Name,'digit');
   num = str2double(Name(digits(1:find(digits == 0,1,'first'))));
   text = (Name(~digits));
   if numel(text) >= 5
       if strcmpi(text(1:5),'Hz - ') %Remove Hz unit
           text(1:5) = [];
       end
   end
   result(idx) = num; %#ok<AGROW>  
end



%% Find output parameters
disp(result)
varargout(1) = {result};

%end function
end