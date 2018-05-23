function [ varargout ] = ita_convolve( varargin )
%ITA_CONVOLVE - Convolve time signal with IR or FR
%  This function convolves two signals with correct scaling.
%    A and B can be in time or frequency domain
%
%  Syntax: result = ita_convolve(asA,asB, Options) - convolve audiostruct A with B and
%                   returns the result in frequency domain
%
%   Options (default):  'overlapp_add' ([]): force convolution with or without overlap_add (empty means automatic)
%						'circular' (false):  circular convolution (equal to multiplication in frequency domain, signals won't be extended)
% 
%   See also ita_zconv.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_acc2vel">doc ita_acc2vel</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  18-Jul-2008

%% Initialization
sArgs   = struct('pos1_num','itaAudioTime','pos2_den','itaAudioTime', 'overlap_add',[],'circular',false);
[source_signal, filter_dat, sArgs] = ita_parse_arguments(sArgs,varargin);

if isempty(sArgs.overlap_add)
   sArgs.overlap_add = abs(source_signal.fftDegree - filter_dat.fftDegree) < 2;
end

%% Check for energy/power setting
if ~strcmpi(filter_dat.signalType,'energy')
    ita_verbose_info('ITA_CONVOLVE:Oh Lord. Filters should be energy signals. I will fix this for you!',1);
    filter_dat.signalType = 'energy';
end

%% Check SamplingRates
if source_signal.samplingRate ~= filter_dat.samplingRate
    filter_dat = ita_resample(filter_dat,source_signal.samplingRate);
    ita_verbose_info('ITA_CONVOLVE: Sampling Rates do not match, resampling filter!',1);
end

%% Check number of channels channels
if source_signal.nChannels ~= filter_dat.nChannels
    % only a problem if both inputs have more than one channel, fftfilt can
    % handle the rest
    if source_signal.nChannels > 1 && filter_dat.nChannels > 1
        error('ITA_CONVOLVE: Number of channels do not match');
    end
end

%% Extend signals
%final sample number, but should be even for the fft
if sArgs.circular
    finalSamples = max(source_signal.nSamples, filter_dat.nSamples);
else
    finalSamples = source_signal.nSamples + filter_dat.nSamples -1;
    finalSamples = 2 * ceil(finalSamples./2);
end
%extend source signal
source_signal = ita_extend_dat(source_signal,finalSamples);

if ~sArgs.overlap_add %signals have similar length, overlap-add makes no sense
    ita_verbose_info('ITA_CONVOLVE:Linear convolution in frequency domain.',2);
    %extend filter
    filter_dat = ita_extend_dat(filter_dat,finalSamples);
    % Convolution by Mulitplying in frequency domain and IFFT
    source_signal = source_signal*filter_dat;
else % RSC - use overlap-add
    ita_verbose_info('ITA_CONVOLVE:Linear convolution using overlap-add.',2);
    source_signal.timeData = fftfilt(double(filter_dat.timeData),double(source_signal.timeData));
    % deal with units
    source_signal.channelUnits(:) = {ita_deal_units(filter_dat.channelUnits{1},source_signal.channelUnits{1},'*')};
end

%% Add history line
source_signal = ita_metainfo_rm_historyline(source_signal,'all');
source_signal = ita_metainfo_add_historyline(source_signal,'ita_convolve',varargin,'withSubs');

%% Check for output parmater
error(nargoutchk(0,1,nargout));

varargout(1) = {source_signal};
