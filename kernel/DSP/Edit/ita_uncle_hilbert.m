function varargout = ita_uncle_hilbert(varargin)
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
data = ita_zerophase(data); %without the phase everyting is symmetric

if sArgs.cutoff
    data_orig = data;
    data = ita_extend_dat(data,data.nSamples * 2,'symmetric','nozero');
end

%% Produce causal real response 
data_abs     = data;
data_abs.freq = log(abs(data_abs.freq) + eps);

%% Check for singularities
data_abs.freq(~isfinite(data_abs.freq)) = 0;

%% Do the Hilbert Transformation - manually
hilb_data        = ita_ifft(data_abs);

flat = hilb_data;
flat.time = flat.timeVector * 0 + 1;

% nice window - relative values in win vector
if sArgs.window
    windata = ita_time_window(flat,round(hilb_data.nSamples*sArgs.window),'samples');
else
    windata = ita_time_window(flat,[1 round(hilb_data.nSamples/2)],@rectwin,'samples');
end

hilb_data = hilb_data .* windata;

hilb_data_part2  = ita_negate(ita_time_reverse(hilb_data));
hilb_data_part2  = ita_time_shift(hilb_data_part2,1,'samples'); %time zero sample should not be there two times
hilb_data_part2.dat(:,1) = 0.*hilb_data_part2.dat(:,1);

res = windata + ita_time_shift(ita_time_reverse(windata),1,'samples');
res = flat./res;
res.time(isnan(res.time)) = 0;

hilb_data = ita_fft((hilb_data + hilb_data_part2).* res);

%% Make the phase
result = data;
result.freq = abs(data.freq) .* exp(1i*imag(hilb_data.freq));

if sArgs.cutoff
    result = ita_extract_dat(result,result.nSamples / 2,'symmetric');
    result.freq = abs(data_orig.freq) .* exp(1i*angle(result.freq));
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};
%end function
end