function varargout = ita_split_frequencies(varargin)
%ITA_SPLIT_FREQUENCIES - Split itaAudio into array, accoring to frequencies
%  This function will split an itaAudio according to the frequencies from the channelname
%
%  Syntax:
%   audioObjArray = ita_split_frequencies(audioObj,options)
%  Options (default):
%   'remove_freq' (false):      remove number from channelname
%
%  Example:
%   Array = ita_split_frequencies(ita_mpb_filter(ita_demosound,'oct',1))
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_split_frequencies">doc ita_split_frequencies</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-May-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaAudio','remove_freq',false);
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 

while ~isempty(data) && data.nChannels > 0
    %split Number from ChannelNames
   Name = data.channelNames{1};
   digits = isstrprop(Name,'digit');
   num = str2double(Name(digits(1:find(digits == 0,1,'first'))));
   text = (Name(~digits));
   if numel(text) >= 5
       if strcmpi(text(1:5),'Hz - ') %Remove Hz unit
           text(1:5) = [];
       end
   end
   if isnan(num)
       [thisfreq, data] = ita_split(data,text);
   else
       [thisfreq, data] = ita_split(data,[num2str(num) 'Hz -'],[],'substring');
   end
   
   if sArgs.remove_freq
       %Remove Number from Channelname
       for idch = 1:thisfreq.nChannels
           [egal thisfreq.Channel(idch).Name] = strtok(thisfreq.Channel(idch).Name,'-');
           thisfreq.Channel(idch).Name(1) = [];
       end
   end
   
   if exist('result','var')
       result(end+1) = thisfreq; %#ok<*AGROW>
   else
       result = thisfreq;
   end
end

%% Find output parameters
varargout(1) = {result};
%end function
end