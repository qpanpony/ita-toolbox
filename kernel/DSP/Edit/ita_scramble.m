function varargout = ita_scramble(varargin)
%ITA_SCRAMBLE - add random phase in overlaping blocks
%  This function scrambles the phase in a signal. Used to preserve signal
%  parameters but you cannot listen to the signal content anymore.
%
%  Syntax:
%   audioObj = ita_scramble(audioObj,options)
% 
%  Options (default):
%   'precision' ('double'):     wordlength
% 
%   See also: ita_zerophase, ita_minimumphase
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_scramble">doc ita_scramble</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  17-Jul-2009

persistent ita_scramble_window_buffer;

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
%narginchk(1,1);
sArgs        = struct('pos1_data','itaAudioTime','precision','double');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

overlap = 0.5;
blocksize = 2^15;
orig_samples = data.nSamples;
precision = class(data.data);

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
%% Precalc window (and cache in memory)
if isempty(ita_scramble_window_buffer)
    ita_scramble_window_buffer = window(@hann,blocksize+1);
    ita_scramble_window_buffer(end) = [];
    ita_scramble_window_buffer = sqrt(ita_scramble_window_buffer);
    ita_scramble_window_buffer = repmat(ita_scramble_window_buffer,1,data.nChannels);
end
ita_scramble_window_buffer = cast(ita_scramble_window_buffer,precision);

%% Data preparation
data.dat = [zeros(data.nChannels,blocksize/2) data.dat zeros(data.nChannels,blocksize/2)];
%data = ita_metainfo_check(data);

segments = ceil(data.nSamples/(blocksize*(1-overlap))); %How many segments will we have?


resultdata = zeros(size(data.data),precision);

new_phase = zeros([blocksize,1],precision) + 1i *zeros([blocksize,1],precision);


for iSegment = 1:segments %Process every segment
    iLow = ceil((iSegment-1)*(1-overlap)*blocksize)+1; %Calc inds
    iHigh = iLow+blocksize-1;
    
    if iHigh > orig_samples+blocksize % Expand if last segment is too small
        data.data(end+1:iHigh,:) = 0;
    end
    
    time_segment = data.data(iLow:iHigh,:) .* ita_scramble_window_buffer; %Extract that time segment from the whole audio
    
    tsd = fft(time_segment); %Go to freq-domain
    
    % Calc new (random) phase
    new_phase(1:end/2) = exp(1j.*  2 * pi .* rand(size(tsd,1)/2,1,precision));
    new_phase(end/2+2:end) = conj(new_phase(end/2:-1:2));
    new_phase(1,:) = 1;
    new_phase(end/2+1,:) = 1;
    
    % Apply new phase, remove old
    tsd = abs(tsd) .* repmat(new_phase,1,size(tsd,2));
    
    % back to time domain
    time_segment = ifft(tsd,'symmetric');
    time_segment = time_segment .* ita_scramble_window_buffer; %Reapply window
    
    if iHigh > size(resultdata,1)
        resultdata(end+1:iHigh,:) = 0;
    end
    resultdata(iLow:iHigh,:) = resultdata(iLow:iHigh,:) + time_segment;
end

data.timeData = resultdata;

data.dat = data.dat(:,blocksize/2+(1:orig_samples));
data = ita_amplify(data,'+3dB'); %To get same level as before (because of 2nd Hanning-Window)

%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);

%% Find output parameters
varargout(1) = {data};

%end function
end