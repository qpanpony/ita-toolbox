function varargout = ita_din18041_reverberation_times(varargin)
%ITA_DIN18041_REVERBERATION_TIMES - calculates recommended reverbertion times for different room types, according to DIN18041
%
%  Call: itaAudio = ita_din18041_reverberation_times('V',room_volume,'purpose', room_purpose, 'add_to', itaAudio)
%
%       Options (default):
%           V ([]) - room volume
%           'purpose' ('speech') - what is the room used for? Known: 'speech' 'music' 'education'
%           'add_to' [] - if you supply an itaAudio, the reverberation times will be added as channels
%
%   See also ita_roomacoustics, ita_roomacoustics_reverberation_time
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_din18041_reverberation_times">doc ita_din18041_reverberation_times</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  16-Feb-2009 


%% Initialization and Input Parsing
sArgs        = struct('v',[],'purpose','speech','add_to', 'itaAudioFrequency');
narginchk(1,6);
sArgs = ita_parse_arguments(sArgs,varargin);
type = lower(sArgs.purpose);

if isempty(sArgs.v)
   error( ' I really need the volume of the room!'); 
elseif sArgs.v > 5000
    ita_verbose_info('ITA_DIN18041: Careful, norm only valid for small to medium size rooms!',1);
elseif sArgs.v > 30000
    ita_verbose_info('ITA_DIN18041: Carefull, norm only valid for small to medium size rooms! Room volume far out of range',0);
end


if isempty(sArgs.add_to) || strcmpi(sArgs.add_to, 'itaAudioFrequency')
    fs = 44100;
    f = linspace(0,fs/2,2^10+1);
else
    fs = sArgs.add_to.samplingRate;
    f = sArgs.add_to.freqVector;
end

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
switch type
    case {'musik','music'}
        a = 0.45;
        b = 0.07;
    case {'sprache','speech'}
        a = 0.37;
        b = -0.14;
    case {'unterricht','education'}
        a = 0.32;
        b = -0.17;
    otherwise
        error('room type unknown');
end

t_soll = a*log10(sArgs.v)+b; %General reverberation time

t_60 = zeros(2,length(f));

% frequency dependent reverberation time
if strcmp(type,'musik') || strcmp(type,'music')
    t_60(1,f<=250) = (-log10(f(f<=250))+log10(250))*0.7+0.8;
    t_60(1,f>250) = 0.8;
    t_60(1,f>=2000) = (-log10(f(f>=2000))+log10(2000))*0.5+0.8;
    t_60(2,:) = t_60(1,:) *1.2/0.8;
    t_60(2,f>=2000) = 1.2;    
else %Sprache, Unterricht
    t_60(1,f<=250) = (log10(f(f<=250))-log10(250))*0.5+0.8;
    t_60(1,f>250) = 0.8;
    t_60(1,f>=2000) = (-log10(f(f>=2000))+log10(2000))*0.5+0.8;
    t_60(2,:) = 1.2;
end

t_60 = t_60 .* t_soll;

t_60(t_60<0.000001)=0.000001;

result = itaAudio();
result.spk = t_60;
result.samplingRate = fs;
result.channelNames = {'Minimum recommended reverberation time' 'Maximum recommended reverberation time'};
result.channelUnits = {'s' 's'};
result.comment = 'Recommended reverberation times according to DIN18041';
result.signalType = 'energy';

%% Add history line
result = ita_metainfo_add_historyline(result,'ita_din18041_reverberation_times',varargin);

%% Check header
%result = ita_metainfo_check(result);

%% Find output parameters
if ~(isempty(sArgs.add_to)  || strcmpi(sArgs.add_to, 'itaAudioFrequency'))
    result = ita_merge(sArgs.add_to,result);
end
varargout(1) = {result};
%end function
end