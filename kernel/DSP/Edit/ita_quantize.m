function varargout = ita_quantize(varargin)
%ITA_QUANTIZE - Reduce resolution of audio signal
%  This function will reduce the resolution of your audio signal. It will
%  however only quantize the signal, the data-type will not be changed, so
%  it won't reduce space or memory consumption
%
%  Syntax:
%   audioObj = ita_quantize(audioObj,Options)
%
%   Options (default): 
%    'bits' (24):        number of bits, will lead to 2^bits- intervalls
%    'intervalls' ([]):  number of intervalls to use
%    'method' ():        only 'linear' supported yet, more to come %TODO HUHU
%
%
%  Example:
%   audioObj = ita_quantize(audioObj,'bits',12)
%   audioObj = ita_quantize(audioObj,'intervalls',4)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_quantize">doc ita_quantize</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  22-May-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions
sArgs        = struct('pos1_data','itaAudioTime','bits',24,'intervalls',[]);

%% Initialization and Input Parsing
narginchk(1,5);

[data,sArgs] = ita_parse_arguments(sArgs,varargin);

if isempty(sArgs.intervalls) && isempty(sArgs.bits)
    error([thisFuncStr ' I need bits or intervalls!']);
end
if ~isempty(sArgs.intervalls) && ~isempty(sArgs.bits)
     error([thisFuncStr ' I need bits OR intervalls!']);
end


if isempty(sArgs.intervalls)
    sArgs.intervalls = 2^(sArgs.bits-1)+1;
end

%% Quantize
timeData = data.timeData;

maxvalue = max(max(abs(timeData)));
timeData = timeData ./ maxvalue;

timeData = round(timeData.*sArgs.intervalls./2)./sArgs.intervalls.*2;

timeData = timeData.*maxvalue;

data.timeData = timeData;

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find output parameters

varargout(1) = {data};

%end function
end
