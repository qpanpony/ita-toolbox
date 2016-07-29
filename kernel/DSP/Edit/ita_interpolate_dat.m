function [ varargout ] = ita_interpolate_dat( varargin )
%ITA_INTERPOLATE_DAT - Resample Audio Data
%   This Function resamples Audio Data to a given Sampling Rate. It takes 
%   into account the facts about power and energy signals. The energy of energy signals and
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

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%
% % TODO % check behavior: resampling 1000Hz sine(fftdeg 15,44100) with 48000
%   results in small spikes at higher frequencies!!!!

%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');

%% Initialization and Input Parsing
narginchk(1,2);
sArgs           = struct('pos1_a','itaSuper');
[Data, sArgs]   = ita_parse_arguments(sArgs,{varargin{1}}); 

if nargin == 1
    NewSamplingRate = 44100;
    if verboseMode, disp('ITA_RESAMPLE:Sampling rate set to 44100.'); end;
else
    NewSamplingRate = varargin{2};
end

if isa(Data,'itaAudio')
OldSamplingRate = Data.samplingRate;
if OldSamplingRate == NewSamplingRate
    if verboseMode, disp('ITA_RESAMPLE:The Sampling Rate is already fine.'), end;
    varargout(1) = {varargin{1}};
    return; %write back quickly and leave
end
end

%% Resample
old_timesteps = Data.timeVector;
new_timesteps = min(old_timesteps):1/NewSamplingRate:max(old_timesteps);
if mod(numel(new_timesteps),2) == 1
    new_timesteps(end+1) = new_timesteps(end); %Hold last sample to get even no of samples
end

Data.timeData = interp1(old_timesteps.',Data.timeData,new_timesteps.');


%% Update Header
if isa(Data,'itaAudio')
    Data.samplingRate = NewSamplingRate;
end


%Data = ita_metainfo_check(Data);

%% Add history line
Data = ita_metainfo_add_historyline(Data,'ita_interpolate_dat',{'audioObj',NewSamplingRate});

%% Find Output
varargout(1) = {Data};

end %function