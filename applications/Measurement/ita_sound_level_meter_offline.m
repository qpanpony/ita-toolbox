function varargout = ita_sound_level_meter_offline(varargin)
%ITA_SOUND_LEVEL_METER_OFFLINE - offline sound level meter
%  This function provides the functionality of a sound level meter for
%  calibrated recorded data (instead of live and real-time).
%
%  Syntax:
%   audioObjOut = ita_sound_level_meter_offline(audioObjIn, options)
%
%   Options (default):
%           'blockSize'      (4096)       : input block size in samples
%           'overlap'        (0.5)        : fraction of block overlap
%           'tc'             (0.125)      : time weighting constant, e.g. 0.125: fast, 1.0: slow, 0: no weighting
%           'freqRange'      ([20 20000]) : frequency range
%           'bandsPerOctave' (3)          : bands per octave
%           'weightingType'  ('')         : weighting filter, '', 'A' or 'C'
%
%  Example:
%   Lp = ita_sound_level_meter_offline(input)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sound_level_meter_offline">doc ita_sound_level_meter_offline</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc-cnrc.gc.ca
% Created:  01-Apr-2020 


%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_input','itaAudio', 'blockSize', 4096, 'overlap', 0.5, ...
                      'tc', 0.125, 'freqRange', [20 20000], 'bandsPerOctave', 3, 'weightingType', '');
[input,sArgs] = ita_parse_arguments(sArgs,varargin);


%% some preparation
samplingRate = input.samplingRate;
blockSize    = round(sArgs.blockSize/2)*2;
nOverlap     = round(blockSize*sArgs.overlap);
windowFunc   = @hann;
winRMS       = windowFunc(blockSize+1);
winRMS       = rms(winRMS(1:end-1));
exp_alpha    = exponential_smoothing_alpha(sArgs.tc,blockSize,nOverlap,samplingRate);


%% octave-band and weighting filter
filterOrder = 10;
oct_filt = ita_mpb_filter(samplingRate,'oct',sArgs.bandsPerOctave,'octavefreqrange',sArgs.freqRange,'zerophase',false,'order',filterOrder);
oct_filt = oct_filt.impulseResponse;
% compensation for low-frequency power for short filters (via statistical filter band width)
fc = ita_ANSI_center_frequencies(sArgs.freqRange,sArgs.bandsPerOctave,samplingRate).';
[~,Beff] = statistical_filter_bandwidth(fc,1/sArgs.bandsPerOctave,filterOrder/2);
weighting = itaResult(Beff./(samplingRate./oct_filt.nSamples.*sum(abs(oct_filt.freq).^2).'),fc,'freq')^2;
% add weighting filter
if ~isempty(sArgs.weightingType)
    weighting = ita_filter_weighting(sqrt(weighting),'type',sArgs.weightingType)^2;
end


%% calculate levels per channel of input data
% split into blocks
nBlocks = ceil(input.nSamples/(blockSize-nOverlap)) + 1;
res = zeros(nBlocks,oct_filt.nChannels,input.nChannels);

wb = itaWaitbar([input.nChannels nBlocks],'Calculating level in blocks ...');
for iCh = 1:input.nChannels
    tmp = ita_extract_dat(ita_convolve(input.ch(iCh),oct_filt,'overlap_add',1),input.fftDegree);
    tmp = ita_multiple_time_windows(tmp,'blockSize',blockSize,'overlap',nOverlap,'window',windowFunc);
    % account for zeros inserted at beginning and end
    tmp(1) = tmp(1)*sqrt(2);
    tmp(end) = tmp(end)*sqrt(2);
    res(1,:,iCh) = weighting.freq.'.*rms(tmp(1)).^2;
    % go through all blocks and get rms in each band
    for iBlock = 2:nBlocks
        res(iBlock,:,iCh) = exponential_smoothing(weighting.freq.'.*rms(tmp(iBlock)).^2,res(iBlock-1,:,iCh),exp_alpha);
        wb.inc();
    end
end
wb.close();

% compensate for window
res = sqrt(res)/winRMS;
% time vector
t = (0:nBlocks-1).'*(blockSize-nOverlap)./samplingRate;
res = itaResult(res,t,'time')*itaValue(1,input.channelUnits{1});
res.channelNames = repmat(cellstr([num2str(fc) repmat(' Hz',numel(fc),1)]),[1 input(1).nChannels]);
% save band center frequencies in userData
res.userData{1} = fc;

%% Add history line
res = ita_metainfo_add_historyline(res,mfilename,varargin);

%% Set Output
varargout(1) = {res}; 

end %end function

%% subfunctions
function alpha = exponential_smoothing_alpha(tc,blockSize,nOverlap,samplingRate)
% calculate alpha depending on time constant and block size
%   tc is the low-pass filter time constant in seconds
%   block size in samples
%   n_overlap is the number of overlapping samples between blocks
%   sampling rate in samples/second

alpha = 1 - exp(-1./tc.*(blockSize-nOverlap)./samplingRate);
end

function currentInput = exponential_smoothing(currentInput,lastInput,alpha)
% apply exponential averaging

if alpha < 1 && ~isempty(lastInput)
    currentInput = (1-alpha).*lastInput + alpha.*currentInput;
end
end

function [B,Beff] = statistical_filter_bandwidth(fc,BW,filterOrder)

% Ref: Davy, The statistical bandwidth of Butterworth filters, JSV, 1987
B = pi/((2*filterOrder-1)*sin(pi/(2*filterOrder))).*(2^(BW/2)-2^(-BW/2)).*fc;
Beff = B.*(2*filterOrder-1)/(2*filterOrder);
end