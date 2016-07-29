function varargout = ita_minimumamplitude(varargin)
%ITA_UNCLE_HILBERT - Get minimum phase response
%  This function is similar to Monkey Forest' Uncle Hilbert function. It
%  produces the minimum phase response as a real, causal time function of a
%  signal with a given spectrum.
%
%  This function calculates the minimum phase respresentation of a given
%  filter spectrum. Internally, it takes the natural logarithm of the
%  magnitude of the spectrum and brings it to time domain. There the signal
%  is processed to aim the hilbert transformation in frequency domain by
%  its counterpart in time domain. The result is brought ot frequency
%  domain and applied as the new phase to the magnitude given before.
%
%  Syntax: audioObj = ita_uncle_hilbert(audioObj, options)
%  Options (default):
%   'window' (0):      apply window
%
%  This function is linked in ita_minimumphase().
%
%   See also ita_minimumphase, ita_zerophase, ita_get_envelope.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_uncle_hilbert">doc ita_uncle_hilbert</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 29-Sep-2008 


%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU>
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU>

%% Initialization and Input Parsing
sArgs         = struct('pos1_a','itaAudioFrequency','cutoff','false','window',0);
[data, sArgs] = ita_parse_arguments(sArgs,varargin); 

if strcmp(data.signalType,'power')
    error('Are you sure you know what you are doing? This makes no sense with power signals!')
end

start = ita_start_IR(data);
data = ita_time_shift(data,-start+1,'samples');
data = ita_time_window(data,round([.4 .6]*data.nSamples),'samples');

if sArgs.cutoff
    data = ita_extend_dat(data,data.nSamples * 2,'symmetric','nozero');
end

%% Produce causal real response 
data_pha     = data;
data_pha.freqData = 1i*angle(data.freqData); %amplitude is now 1
data_pha.spk = 1i*unwrap(data_pha.spk/1i); %unwrap phase

%% Check for singularities
d = data_pha.spk;
d(~isfinite( d )) = 0;
data_pha.spk      = d;

%% Do the Hilbert Transformation - manually

flat = data_pha;
flat.time = flat.timeVector * 0 + 1;

% nice window - relative values in win vector
T = 0.8;
mid = round(flat.nSamples/2);
begin = max(round(mid*(1 - T)),1) ;
ende = min(round(mid*(1 + T)),flat.nSamples);
windata = 2*ita_time_window(flat,[begin ende],@hann,'samples');

windata.timeData(1,1) = 1;
hilb_data = data_pha .* windata;

%% Make the amplitude
result = data;
result.freqData = exp(hilb_data.freqData);
result.spk = abs(result.spk)/result.spk(1)*data.spk(1) .* exp(1i*angle(data.spk));

if sArgs.cutoff
    result = ita_extract_dat(result,result.nSamples / 2,'symmetric');
end

result = ita_time_shift(result,start-1,'samples');

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end