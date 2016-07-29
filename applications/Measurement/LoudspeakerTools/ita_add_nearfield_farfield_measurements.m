function varargout = ita_add_nearfield_farfield_measurements(varargin)
%ITA_ADD_NEARFIELD_FARFIELD_MEASUREMENTS - for loudspeaker near-field measurements
%  This function takes the near-field and far-field response of a
%  loudspeaker and crossfades them at a given frequency, adjusting the
%  level and the time delay of the near-field measurement to correspond to
%  the far-field measurement.
%
%  Optionally, a port measurement also carried out in the near-field can be
%  specified for bass-reflex enclosures, which will then be added first to
%  the near-field response.
%
%  Syntax:
%   audioObjOut = ita_add_nearfield_farfield_measurements(audioObjIn1,audioObjIn1, options)
%
%   Options (default):
%           'portMeasurement' (itaAudio())  : used for bass-reflex loudspeakers
%           'crossoverFrequency' (100)      : where to crossfade near- and far-field
%           'filterOrder' (24)              : order used for crossfading
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_add_nearfield_farfield_measurements">doc ita_add_nearfield_farfield_measurements</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  13-Jun-2011 



%% Initialization and Input Parsing
sArgs        = struct('pos1_farfield','itaAudio', 'pos2_nearfield','itaAudio','portMeasurement',itaAudio(),'crossoverFrequency',115, 'filterOrder', 24, 'plot', false);
[farfield,nearfield,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% some preprocessing, crossover filters
flat                = ita_generate('flat',1,farfield.samplingRate,farfield.fftDegree);
filt_merge_TT_low   = abs(ita_filter_LiRi(flat,[0 sArgs.crossoverFrequency],'order',sArgs.filterOrder)');
filt_merge_TT_low   = filt_merge_TT_low/max(abs(filt_merge_TT_low.freq)); % workaround
filt_merge_TT_high  = abs(ita_filter_LiRi(flat,[sArgs.crossoverFrequency 0],'order',sArgs.filterOrder)');

%% if port measurement is also given, add near-field and port first

[junk,t1]       = ita_time_shift(nearfield);
if ~isempty(sArgs.portMeasurement)
    % find the maximum of the port measurement and add the measurements at
    % a third of that frequency where the slopes should be equal
    [junk,maxIdx]   = max(abs(sArgs.portMeasurement.freq2value(1,sArgs.crossoverFrequency))); %#ok<*ASGLU>
    crossFreq       = sArgs.portMeasurement.freqVector(maxIdx)/4;
    ampPT           = abs(sArgs.portMeasurement.freq2value(crossFreq));
    ampNF           = abs(nearfield.freq2value(crossFreq));
    [junk,t0]       = ita_time_shift(sArgs.portMeasurement);
    if sArgs.plot
        new_nearfield = merge(ampNF/ampPT*ita_time_shift(sArgs.portMeasurement,t0 - t1,'time'),nearfield);
        ita_plot_freq(merge(new_nearfield,sum(new_nearfield)));
    end
    nearfield       = ampNF/ampPT*ita_time_shift(sArgs.portMeasurement,t0 - t1,'time')+nearfield;
end

% adjust the levels of near-field and far-field and also time-shift the
% near-field measurement to correspond to the far-field measurement
[junk,t2]   = ita_time_shift(farfield);
ampNF       = abs(nearfield.freq2value(sArgs.crossoverFrequency));
ampFF       = abs(farfield.freq2value(sArgs.crossoverFrequency));
 
%% add near-field and far-field
% compensate levels and tme shift and then crossfade
nearfield = ita_time_shift(ampFF/ampNF*nearfield,t1-t2,'time');

if sArgs.plot
    new_farfield = merge(nearfield,farfield);
    ita_plot_freq(merge(new_farfield,sum(new_farfield*merge(filt_merge_TT_low,filt_merge_TT_high))));
end

farfield = nearfield*filt_merge_TT_low + farfield*filt_merge_TT_high;

%% Set Output
varargout(1) = {farfield}; 

%end function
end