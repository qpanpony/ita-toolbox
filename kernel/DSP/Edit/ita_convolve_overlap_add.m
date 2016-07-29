function [ varargout ] = ita_convolve_overlap_add( varargin )
%ITA_CONVOLVE_OVERLAP_ADD - Convolve time signal with IR or FR
%  This function convolves two signals with correct scaling. 
%    A and B can be in time or frequency domain 
%  This function uses an overlap add method for memory efficient calculation
%
%   Faster for short filters on long signals
%
%  Syntax: result = ita_convolve(asA,asB) - convolve audiostruct A with B and
%                   returns the result in frequency domain
%
%   See also ita_zconv, ita_convolve
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_acc2vel">doc ita_acc2vel</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Autor: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de

%% Initialization
varargout = {ita_convolve(varargin{:})};
ita_verbose_info('ita_convolve_overlap_add is useless, use ita_convolve, to force overlap-add, use ''overlap_add'' option',0);
return;

sArgs   = struct('pos1_num','itaAudioTime','pos2_den','itaAudioTime');
[source_signal, filter_dat, sArgs] = ita_parse_arguments(sArgs,varargin);

%% Check for energy/power setting
if ~strcmpi(filter_dat.signalType,'energy')
    ita_verbose_info('ITA_CONVOLVE:Oh Lord. Filters should be energy signals. I will fix this for you!',1);
    filter_dat.signalType = 'energy';
end

%% Check SamplingRates
if source_signal.samplingRate ~= filter_dat.samplingRate
    error('ITA_CONVOLVE:Sampling Rates do not match');
end

%% Extend signals
%final sample number, but should be even for the fft
finalSamples = source_signal.nSamples + filter_dat.nSamples -1;
finalSamples = 2 * ceil(finalSamples./2);

%extend source signal
source_signal = ita_extend_dat(source_signal,finalSamples);

ita_verbose_info('ITA_CONVOLVE_OVERLAP_ADD:Input signals have been extented.',2);

%% Match channels
if source_signal.nChannels == 1 && filter_dat.nChannels > 1
    source_signal = ita_split(source_signal,ones(filter_dat.nChannels,1));
end
if source_signal.nChannels > 1 && filter_dat.nChannels == 1
    filter_dat = ita_split(filter_dat,ones(source_signal.nChannels,1));
end


%% Convolution by Mulitplying in frequency domain and IFFT
result = source_signal;
result.timeData = fftfilt(filter_dat.timeData ,source_signal.timeData);

for nChx = 1:result.nChannels
    result.channelNames{nChx} = [source_signal.channelNames{nChx} ' * ' filter_dat.channelNames{nChx}];
end

%% Add history line
%result = ita_metainfo_rm_historyline(result,'all');
result = ita_metainfo_add_historyline(result,'ita_convolve_overlap_add',varargin,'withSubs');

%% Find output parameters
error(nargoutchk(0,2,nargout));
if nargout == 0 
    ita_audioplay(result);
elseif nargout == 1
    varargout(1) = {result};
end