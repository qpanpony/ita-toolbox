function varargout = ita_frequency_dependent_time_window(varargin)
%ITA_FREQUENCY_DEPENDENT_TIME_WINDOW - Frequency dependent Time Windows
%  This function applies time windows for different frequency ranges and
%  cross-fades the final result
%
%  Syntax:
%   audioObj = ita_frequency_dependent_time_window(audioObj,options)
%  Options:
%   'symmetric' ('false'):   symmetric windowing for each frequency band   
%   'range' (0):             range/2 below and above fading frequency
%                            define the fading area
%
%  Example:
%   audioObj = ita_frequency_dependent_time_window(audioObj,[0.1 0.11; 0.2 0.21],[500],'range',100)
%
%   The audioObj is duplicated and windowed at 0.1 sec and 0.2 sec. After that the
%   frequency responses of both are faded at 500 Hz in the range 450 up to
%   550 Hz.
%
%   See also: ita_time_window, ita_extract_dat, ita_mpb_filter.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_frequency_dependent_time_window">doc ita_frequency_dependent_time_window</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  26-Jun-2009 


%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,10);
sArgs        = struct('pos1_data','itaAudio','pos2_winvec','int','pos3_freqvec','int','symmetric','false','range',0,'dc',0);
[data,winvec,freqvec,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% check for consistent input
if min(size(freqvec)) == 1
   freqvec = freqvec(:); %only one dimension 
end
if numel(freqvec) ~= size(winvec,1)-1
    error('shit happened, winvec and freqvec do not fit together')
end

%% frequency dependent time windowing
data = data.';
a = itaAudio([size(winvec,1) 1]);
for idx = 1:size(winvec,1);
    if sum(winvec(idx,:)) == 0
        a(idx) = data;
    else
        a(idx) = ita_fft(ita_time_window(data,winvec(idx,:),'time','symmetric',sArgs.symmetric,'dc',sArgs.dc));  %#ok<*AGROW>
    end
end
result = a(1);
for idx = 1:size(freqvec,1)
    result = ita_xfade_spk(result,a(idx+1),[freqvec(idx,:) - sArgs.range/2 freqvec(idx,:) + sArgs.range/2]);
end

% final window to cancel crossfade effects
result = ita_time_window(result,max(winvec),'time','symmetric',sArgs.symmetric,'dc',sArgs.dc);

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);
result.channelNames = data.channelNames;

varargout(1) = {result};
%end function
end