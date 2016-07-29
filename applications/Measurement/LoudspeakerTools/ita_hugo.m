function varargout = ita_hugo(varargin)
%ITA_HUGO - LS equalization filter generation
%  This function calculates compensation filters including xovers
%
%  Syntax:
%   audioObjOut = ita_hugo(audioObjIn,xover_freq, options)
%   xover_freq: crossover frequencies in hz
%
%   Options (default):
%           'freqRange' ([40 16000]) : target freqrange
%           'samplingRate' ( ita_preferences('samplingRate') ) : SamplingRate of target filter
%           'fftDegree' (14) : Length of target filter
%           'smoothNotches',1/3
%           'squeezeFactor',0.3
%           'plot',false
%           'finalbandpass',false
%           'shortenFIRfilter',  (0) : 0 -> disabled, else fftDegree of final Filter
%
%  Example:
%   audioObjOut = ita_hugo(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_hugo">doc ita_hugo</a>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  13-Apr-2011

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Initialization and Input Parsing
sArgs         = struct('pos1_data','itaAudio','pos2_xover','vector','samplingRate', ita_preferences('samplingRate'),'freqRange',[40 16000],'fftDegree',14,...
    'delay',0.01,'smoothNotches',1/3,'squeezeFactor',0.3,'plot',false,'finalbandpass',false, 'normalize', false,'minFreq',30);
[input,xovers,sArgs] = ita_parse_arguments(sArgs,varargin);

% get rid of units
input.channelUnits(:) = {''};

%% init
sr         = sArgs.samplingRate; % sampling rate
fft_degree = sArgs.fftDegree;    % length of filter 2^fft_degree samples
nWays      = input(1).nChannels; % number of ways per loudspeaker
nLS        = numel(input);       % number of loudspeakers

% order for xovers
order      = [8 16 16 16];
order      = order(1:nWays-1);

% get nice frequency limits
x          = (repmat(xovers(:),1,2)).';
reg_freqs  = [sArgs.freqRange(1); x(:);   sArgs.freqRange(2)];
filter_vec = reshape(reg_freqs,2,[]).';

%% 1 get LS spectra (time shift and maybe shorten)
for idx = 1:nLS
    LS_raw(idx) = ita_resample(ita_time_shift(input(idx)),sr); %#ok<AGROW>
    % get rid of delay
    if sArgs.fftDegree < input.fftDegree
        shiftSamples = ita_start_IR(LS_raw(idx))-1;
        [low_win,lsDelay(idx)] = ita_loudspeakertools_shorten_IR(LS_raw(idx).ch(1),'fftDegree',sArgs.fftDegree,'freqRange',[1 3].*min(filter_vec(:))); %#ok<AGROW>
        LS_win(idx) = merge(low_win,ita_extract_dat(ita_time_shift(LS_raw(idx).ch(2:nWays),lsDelay(idx)-shiftSamples(1),'samples'),sArgs.fftDegree)); %#ok<AGROW>
    else
        LS_win(idx) = ita_extend_dat(LS_raw(idx),sArgs.fftDegree); %#ok<AGROW>
    end
    LS_win(idx) = ita_time_shift(LS_win(idx)); %#ok<AGROW>
end

if sArgs.plot
    ita_plot_freq_phase(merge(LS_win));
    title('loudspeaker reponses');
    pause(2);
end


%% 2 bandpass
flat = ita_generate('flat',1,sr,fft_degree);
bp(1)  = ita_mpb_filter(flat,[0 filter_vec(1,2)],'zerophase','order',order(1));
bp(2)  = abs((flat - bp(1))');
for idx = 3:nWays
    bp(idx) = ita_mpb_filter(flat,[filter_vec(idx,1),0],'zerophase', 'order',order(idx-1));
    bp(idx-1) = abs((bp(idx-1) - bp(idx))');
end

bp = merge(bp);
bp.freq(20.*log10(abs(bp.freq)) <= -60) = 0;

if sArgs.plot
    ita_plot_freq_phase(merge(bp, sum(bp)));
    title('prototype bandpass');
    pause(2);
end


%% 3 Regularization and smooth notches
for LS_idx = 1:nLS
    for idx = 1:nWays
        x = ita_smooth_notches(LS_win(LS_idx).ch(idx),'bandwidth',sArgs.smoothNotches,'squeezeFactor',sArgs.squeezeFactor);
        comp(idx)  = ita_invert_spk_regularization(x,filter_vec(idx,:)); %#ok<AGROW>
    end
    comp_filter(LS_idx) = merge(comp); %#ok<AGROW>
end

if sArgs.plot
    ita_plot_freq(merge(comp_filter));
    title('compensation filter (without bandpass)');
    pause(2);
end


%% 4 bandpassed compensation filters (convolution of 1 and 3)
for LS_idx = 1:nLS
    filter_complete(LS_idx) = ita_time_shift(comp_filter(LS_idx) * bp); %#ok<AGROW>
    filter_complete(LS_idx).comment = 'filter complete'; %#ok<AGROW>
%     deltaSample = round(0.9*filter_complete(LS_idx).nSamples);
%     lowStart = deltaSample + round(ita_start_IR(ita_time_shift(filter_complete(LS_idx).ch(1),-deltaSample,'samples'),'correlation',1));
    lowStart = filter_complete(LS_idx).nSamples - ita_start_IR(LS_win(LS_idx).ch(1));
    flatShift = ita_time_shift(flat,lowStart,'samples');
    filter_complete(LS_idx) = merge(ita_xfade_spk(flatShift*filter_complete(LS_idx).ch(1).freq(find(floor(filter_complete(LS_idx).freqVector./sArgs.freqRange(1)) == 1,1,'first')),filter_complete(LS_idx).ch(1),sArgs.freqRange(1)),merge(filter_complete(LS_idx).ch(2:nWays))); %#ok<AGROW>
end

if sArgs.plot
    ita_plot_freq(merge(filter_complete));
    title('compensation filter (with bandpass)');
    pause(2);
end

%% 5 optimize filters
freqIds = bp.freq2index(sArgs.freqRange(1),sArgs.freqRange(2));
for LS_idx = 1:nLS
    tmp = filter_complete(LS_idx)*LS_win(LS_idx)/bp;
    tmpFreq = [ones(freqIds(1)-1,tmp.nChannels); tmp.freq(freqIds,:); ones(tmp.nBins-freqIds(end),tmp.nChannels)];
    tmpFreq(20.*log10(abs(tmpFreq)) <= -30) = 1;
    tmp.freq = tmpFreq;
    filter_opt(LS_idx) = filter_complete/tmp; %#ok<AGROW>
end

if sArgs.plot
    ita_plot_freq(merge(filter_opt));
    title('compensation filter (with bandpass, optimized)');
    pause(2);
end

%% 6 final bandpass
if sArgs.finalbandpass
    for LS_idx = 1:nLS
        filter_final(LS_idx) = ita_mpb_filter(filter_opt(LS_idx),[sArgs.freqRange(1)/sqrt(2) 0],'zerophase','order',10); %#ok<AGROW>
        filter_final(LS_idx) = ita_mpb_filter(filter_opt(LS_idx),[0 min(sArgs.freqRange(2)*sqrt(2),sr/2*0.99)],'zerophase','order',2); %#ok<AGROW>
    end
else
    for LS_idx = 1:nLS
        filter_final(LS_idx) = ita_mpb_filter(filter_opt(LS_idx),[sArgs.minFreq 0],'zerophase','order',6); %#ok<AGROW>
    end
end

%% 7 normalization
% mgu: why RMS?
if sArgs.normalize
    % normfactor = max(max(abs(filter_complete_win.merge.freq)));
    normfactor = max(double(filter_final.merge.rms));
    for LS_idx = 1:nLS
        filter_norm(LS_idx) = filter_final(LS_idx)/normfactor; %#ok<AGROW>
    end
else
    filter_norm = filter_final;
end

if sArgs.plot
    filter_norm.merge.plot_freq
    title('final filters');
    filter_norm.merge.plot_time_dB
    title('final filters');
    pause(2);
end

%% 8 check H_LS * H_comp
if sArgs.plot
    for LS_idx = 1:nLS
        test(LS_idx) = sum(LS_raw(LS_idx) * ita_extend_dat(filter_norm(LS_idx),LS_raw(LS_idx).fftDegree,'symmetric')); %#ok<AGROW>
    end
    
    test.merge.plot_freq_groupdelay
    title('Compensation * LS response - Response of equalized system')
    pause(2);
end

%% Set Output
varargout(1) = {filter_norm};

%end function
end