function varargout = ita_psd(varargin)
%ITA_PSD - Calculate power spectral density or cross power spectral density
%
% This Function will calculate the power spectral density of every channel of the input signal with a given FFT-Size.
% The signal will be segmentised into parts of size blocksize, with an overlap of 0.5 between the segments.
% A hanning-window will be applied to each segment before the fft. Afterwards the psd is calculated according to
% S_xx = E{X*(f) * X(f)}
%
% If called with two audio-Signals, it will compute the cross power spectral density between both signals as:
% S_xy = E{X*(f) * Y(f)}
%
%  Syntax: itaAudio = ita_psd(itaAudio, Options) for power spectral density
%        itaAudio = ita_psd(itaAudio1, itaAudio2, Options) for cross power spectral density
%
%           Options (default):
%               blocksize (signal_length):   FFT-Size for psd or cpsd
%               fftsize ([]):                expand signal to this fftsize by adding zeros, no reduction will be done, if fftsize < blocksize nothing will happen!
%
%   See also ita_roomacoustics, ita_sqrt, ita_roomacoustics_reverberation_time, ita_roomacoustics_reverberation_time_hirata, ita_roomacoustics_energy_parameters, test, ita_sum, ita_audio2struct, test, ita_channelnames_to_numbers, ita_test_all, ita_test_rsc, ita_arguments_to_cell, ita_test_isincellstr, ita_empty_header, ita_metainfo_check ita_metainfo_to_filename, ita_filename_to_header, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_metainfo_coordinates, ita_roomacoustics_EDC, test_ita_class, ita_metainfo_find_frequencystring, clear_struct, ita_italian, ita_italian_init, ita_metainfo_check.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_psd">doc ita_psd</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  12-Feb-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];    %  Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudioTime','blocksize',[],'fftsize',[]);
calc_cpsd = false;
if nargin > 1
    if isa(varargin{2},'itaSuper') % RSC - Bugfix
        sArgs.pos2_data2 = 'itaAudioTime';
        calc_cpsd = true;
    end
end

sArgs = ita_parse_arguments(sArgs,varargin);

data = sArgs.data;
if isempty(sArgs.blocksize)
    sArgs.blocksize = size(data.dat,2);
end

sArgs.blocksize = round(sArgs.blocksize);
sArgs.blocksize = sArgs.blocksize + mod(sArgs.blocksize,2); % Make even

if isempty(sArgs.fftsize)
    sArgs.fftsize = sArgs.blocksize;
end

if ~strcmpi(data.signalType,'power')
    ita_verbose_info( 'This is no power signal. I hope you know what you are doing',1);
end
if calc_cpsd
    data2 = sArgs.data2;
    if size(data.dat) ~= size(data2.dat)
        error([thisFuncStr 'The signals dont have the same length or number of channels']);
    end
end

if sArgs.blocksize > size(data.dat,2)
    ita_verbose_info([thisFuncStr 'blocksize is bigger than your input signal. I hope you know what you are doing'],0);
    data = ita_extend_dat(data,sArgs.blocksize);
    if calc_cpsd
        data2 = ita_extend_dat(data2,sArgs.blocksize);
    end
end

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back
seg_window = hanning(sArgs.blocksize);
result = data;
resultspk = zeros(data.nChannels,sArgs.fftsize/2+1);
for idx = 1:data.nChannels
    % X(f)
    thischannel = ita_split(data,idx); %Get only one channel
    thischannel = ita_ifft(thischannel); %Transfer into time domain
    
    % Y(f)
    if calc_cpsd
        thischannel2 = ita_split(data2,idx); %Get only one channel
        thischannel2 = ita_ifft(thischannel2); %Transfer into time domain
    else
        thischannel2 = thischannel;
    end
    
    resultspk(idx,1:sArgs.fftsize/2+1) = cpsd(thischannel.dat(1,:),thischannel2.dat(1,:),seg_window,round(sArgs.blocksize/2),sArgs.fftsize,data.samplingRate);
    
    % Set channel names
    if calc_cpsd
        result.channelNames{idx} = ['CPSD: ' data.channelNames{idx} ', ' data2.channelNames{idx}];
        result.channelUnits{idx} = ita_deal_units(data.channelUnits{idx},data2.channelUnits{idx},'*');
    else
        result.channelNames{idx} = ['PSD: ' data.channelNames{idx}];
        result.channelUnits{idx} = ita_deal_units(data.channelUnits{idx},data.channelUnits{idx},'*');
    end
end

result.freqData = resultspk.';

%% Add history line
result.history = data.history; %Restore old history as we screewed it up with quite a lot calculations
result = ita_metainfo_add_historyline(result,'ita_psd',varargin);

%% Find output parameters
    varargout(1) = {result};
%end function
end