function [ varargout ] = ita_resample( varargin )
%ITA_RESAMPLE - Resample Audio Data
%
%   Resample Audio Data to a given Sampling Rate. It takes into account the
%   facts about power and energy signals. The energy of energy signals and
%   the power of power signals should remain the same. Therefore,
%   normalization dependent on the signal type is processed. The frequency
%   plots always remain the same after resampling due to this
%   normalization.
%
%   Syntax: itaAudio = ita_resample(itaAudio, NewSamplingRate)
%
%   See also ita_mpb_filter, ita_multiply_spk, ita_audioplay.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_resample">doc ita_resample</a>
%
%   Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
%
% % TODO % check behavior: resampling 1000Hz sine(fftdeg 15,44100) with 48000
%   results in small spikes at higher frequencies!!!!

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% GUI required?
if nargin == 0
    pList = local_gui_call();
    if ~isempty(pList) && ~isempty(pList{1})
        result = ita_resample(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
end

%% Initialization and Input Parsing
sArgs           = struct('pos1_a','itaAudio');
[Data, sArgs] = ita_parse_arguments(sArgs,varargin(1)); %#ok<ASGLU>

if nargin == 1 
    NewSamplingRate = 44100;
    ita_verbose_info('ITA_RESAMPLE:Sampling rate set to 44100.',1);
else
    NewSamplingRate = varargin{2};
end

if numel(Data) > 1
    ita_verbose_info('Calling for all instances.',1)
    result = itaAudio(size(Data));
    for idx = 1:numel(Data)
        result(idx) = ita_resample(Data(idx),NewSamplingRate); 
    end
    varargout{1} = result;
    return
end

OldSamplingRate = Data.samplingRate;
if OldSamplingRate == NewSamplingRate
    ita_verbose_info('ITA_RESAMPLE:The Sampling Rate is already fine.',1);
    varargout(1) = varargin(1);
    return; %write back quickly and leave
end

%% Resample
[p, q] = rat(OldSamplingRate / NewSamplingRate, 0.0001);
result = Data;
newTimeData = zeros(ceil(Data.nSamples/p*q),Data.nChannels);
oldTimeData = Data.time;
%resample channels separately due to memory usage
for idx = 1:Data.nChannels
    newTimeData(:,idx) = resample(double(oldTimeData(:,idx)),q,p);    
end
result.timeData = newTimeData;
result.samplingRate = NewSamplingRate;
clear Data;

%% Check Scaling
if strcmpi(result.signalType, 'energy') %for energy signals rescale time domain
    ita_verbose_info('ITA_RESAMPLE:Energy signal. Rescaling time signal amplitudes.',1);
    result.timeData = result.timeData .* p/q;
end

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_resample',{'audioObj',result.samplingRate});

%% Find Output
varargout(1) = {result};

end %function

function pList = local_gui_call()
ele = 1;
pList{ele}.description = 'itaAudio';
pList{ele}.helptext    = 'This is the itaAudio you want to resample';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = length(pList) + 1;
pList{ele}.description = 'New Samplerate in Hertz';
pList{ele}.helptext    = 'Type in your new samplerate e.g. ''44100''';
pList{ele}.datatype    = 'int';
pList{ele}.default     = 44100;

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';

ele = length(pList) + 1;
pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = ['result_' mfilename];

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Resample an itaAudio Object']);
end