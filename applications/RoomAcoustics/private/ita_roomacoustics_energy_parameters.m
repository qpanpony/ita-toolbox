function output = ita_roomacoustics_energy_parameters(varargin)
%ITA_ROOMACOUSTICS_ENERGY_PARAMETERS - Clarity, Definition, Center Time
%
%  This function calculates the energy parameters of a RIR after ISO 3382.
%  Energy parameters are CenterTime, Clarity (C80, C50) and Defintion (D50, D80)
%
%  Syntax:
%  Call: itaResult = ita_roomacoustics_energy_parameters(itaAudio, options)
%
%   Options (default):
%
%   See also ita_roomacoustics
% ita_roomacoustics_reverberation_time,
% ita_roomacoustics_reverberation_timeNew
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_energy_parameters">doc ita_roomacoustics_energy_parameters</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  30-Jun-2012



%% Initialization
sArgs          = struct('pos1_edc','itaAudioTime', 'freqRange', ita_preferences('freqRange'), 'bandsPerOctave', ita_preferences('bandsPerOctave'), 'centerTimeMat',[], 'C50', false, 'C80', false, 'D50', false, 'D80', false, 'Center_Time', false);
[edc,sArgs] = ita_parse_arguments(sArgs,varargin);


%% Calculate Energy Parameters from EDC
nChannels       = edc.nChannels;

if sArgs.C50 || sArgs.D50
    idx50ms             = edc.time2index(0.05);
end
if sArgs.C80 || sArgs.D80
    idx80ms             = edc.time2index(0.08);
end

freqVec = ita_ANSI_center_frequencies(sArgs.freqRange, sArgs.bandsPerOctave,edc.samplingRate);

resultTemplate                      = itaResult(zeros(numel(freqVec),1), freqVec,'freq');
resultTemplate.channelCoordinates   = edc.channelCoordinates.n(1);
resultTemplate.allowDBPlot          = false;

%%
if sArgs.C50
    output.C50                    = resultTemplate;
    output.C50.freq               = 10*log10(1./ edc.timeData(idx50ms,:).' -1);
    output.C50.comment            = [edc.comment ' -> C50 (dB)' ];
    output.C50.plotAxesProperties = {'ylabel' 'C_{50} (in dB)'};
end

if sArgs.C80
    output.C80                    = resultTemplate;
    output.C80.freq               = 10*log10(1./ edc.timeData(idx80ms,:).' -1);
    output.C80.comment            = [edc.comment ' -> C80 (dB)' ];
    output.C80.plotAxesProperties = {'ylabel' 'C_{80} (in dB)'};
end


%% definition

if sArgs.D50
    output.D50                    = resultTemplate;
    output.D50.freqData           = (1 - edc.timeData(idx50ms,:).')*100;
    output.D50.comment            = [edc.comment ' -> D50 (%)' ];
    output.D50.plotAxesProperties = {'ylabel' 'D_{50} (in %)'};
end

% D80
if sArgs.D80
    output.D80                      = resultTemplate;
    output.D80.freqData             = ( 1 - edc.timeData(idx80ms,:).' )*100;
    output.D80.comment              = [edc.comment ' -> D80 (%)' ];
    output.D80.plotAxesProperties   = {'ylabel' 'D_{80} (in %)'};
end

% Center Time
if sArgs.Center_Time
    if isempty(sArgs.centerTimeMat)
        error('centerTimeMat is empty');
    end
    output.Center_Time                    = resultTemplate;
    output.Center_Time.freqData           = sArgs.centerTimeMat(:);
    output.Center_Time.comment            = [edc.comment ' -> CT ' ];
    output.Center_Time.plotAxesProperties = {'ylabel' 'Center Time  (in s)', 'yLim', [0 ceil(max(output.Center_Time.freqData)*1.2) ]};
    output.Center_Time.channelUnits       = repmat({'s'}, 1, nChannels);
end



%end function
end
