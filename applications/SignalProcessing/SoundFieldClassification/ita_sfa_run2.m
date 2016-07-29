function varargout = ita_sfa_run2(varargin)
%ITA_SFA_RUN - Sound Field Classification for 2 channel input
%  This function calculates the sound field classification for the input of
%  2 nearby sensors. 
%  The input can be the input from a sound card, a wave filename or an
%  itaAudio.
%
%  Syntax:
%   [SFI, SFD, SFC, SFA] = ita_sfa_coherences(audioObjIn, options)   - itaAudio input
%   [SFI, SFD, SFC, SFA] = ita_sfa_coherences(wav-Filename, options) - wav input
%   [SFI, SFD, SFC, SFA] = ita_sfa_coherences('realtime', options)   - realtime audio
%
%   Options (default):
%           'blocksize' ()      : blocksize for coherence estimation
%           'overlap' ()        : overlap between slices
%           'window' ()         : time window
%           'sensorspacing' ()  : distance between sensors
%           'fraction' ()       : fraction in octaves for band calculation
%           'flimit' ()         : frequency limits for evaluation
%           'interval' ()       : interval in samples to be evaluated
%           'history' (inf)     : number of evaluations to keep in plots
%           'channels' ()       : Which channels of input are used
%           'audiobuffersize' (): Buffer size in pages for real time input (2-3 should be fine)
%           'direct_plot',    	: Plots results while processing instead of just returning the results
%           'interactive',      : Allow adjustments from the user while running
%           'bandidplot',     	: Which bands are used for the mean value calculation in 2d plots
%           'compensate',       : Compensate sensor mismatch using measured frequency responses
%           'autocompamp',      : Automatic try compensate amplitude mismatch
%           'ampmminit',      	: inital guess of amplitude mismatch
%           'autocompphase',  	: Automatic try to compensate group delay
%           'gdelayinit',       : initial guess of group delay
%           't_autocalib', (300): Time constant for automatic compensation, use 0 to prevent adaption
%           'redrawframes',(100): Do not plot every sample in real time mode. increase to increase performance 
%           'playback',         : Play back the input signal (e.g. for wav inputs)
%           'flimit',         	: Frequency Range for 
%           't_c',              : Time constant for PSD calculation (exponential average)
%           'psdbands',         : Calculate bands on PSD spectrums instead of coherences
%           'freqdependentsfc'  : Use frequency dependent definition of basic sound fields
%           'sfcmethod',        : There are different methods implemented, 5 is the one from the report
%           'sfdmode',          : There are different methods implemented, 2 is the one from the report
%           'puinput',          : The input is a pu instead of a pp signal
%           'ampmismatch',      : Introduce some artificial amplitude mismatch
%           'phasemismatch',    : Introduce some artificial phase mismatch
%           'gdelay',           : Introduce some artificial group delay
%           'compinit',         : Initial value for sensor compensation
% 
%
%       Most defaults are defined in ita_preferences_sfc()
%
%  Example:
%   [SFI, SFD, SFC, SFA]t = ita_sfa_run('test.wav','blocksize',128,'channels',[3 4])
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sfa_run">doc ita_sfa_run</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  04-Nov-2010



%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
if isa(varargin{1},'itaAudio')
    arg1 = 'itaAudio';
    mode = 'itaAudio';
elseif isa(varargin{1},'char')
    arg1 = 'char';
    if strcmpi(varargin{1},'realtime')
        mode = 'realtime';
    else
        mode = 'wav';
    end
else
    error('Wrong first argument');
end

sArgs        = struct('pos1_data',      arg1,...
    'blocksize',      ita_preferences('SFC_blocksize'),...
    'bbblocksize',    2^18,...
    'overlap',        ita_preferences('SFC_overlap'),...
    'window',         str2func(ita_preferences('SFC_window')),...
    'sensorspacing',  ita_preferences('SFC_sensorspacing'),...
    'fraction',       ita_preferences('SFC_bandsperoctave'),...
    'interval',       [],...
    'history',        inf,...
    'channels',       ita_preferences('SFC_channels'),...
    'audiobuffersize',ita_preferences('SFC_audiobuffersize'),...
    'direct_plot',    false,...
    'interactive',    false,...
    'bandidplot',     1,...
    'compensate',     false,...
    'autocompamp',    false,...
    'ampmminit',      1,...
    'autocompphase',  false,...
    'gdelayinit',     0,...
    't_autocalib',    300,...
    'redrawframes',   100,...
    'playback',       false,...
    'flimit',         ita_preferences('SFC_freqrange'),...
    't_c',            ita_preferences('SFC_tc'),...
    'psdbands',       false,...
    'plot_sfdspace',  true,...
    'freqdependentsfc',ita_preferences('SFC_freqdependentsfc'),...
    'sfcmethod',      6,...
    'sfdmode',        2,...
    'puinput',        false,...
    'ampmismatch',    0,...
    'phasemismatch',  0,...
    'compinit',       [],...
    'gdelay',         0,...
    'plot',           'SFI',...
    'frequencydependentplot', false,...
    'fuzzy',          true  );

[input,sArgs] = ita_parse_arguments(sArgs,varargin);


if isempty(sArgs.sensorspacing)
    if strcmpi(mode,'wav') || strcmpi(mode,'realtime');
        ita_verbose_info([thisFuncStr ' Sensor spacing necessary, guessing 1.4 cm '],0);
        sArgs.sensorspacing = 0.014;
    else
        sArgs.sensorspacing = input.channelCoordinates.n(2)- input.channelCoordinates.n(1);
        sArgs.sensorspacing = sArgs.sensorspacing.r;
        if sArgs.sensorspacing < 0.001 || isnan(sArgs.sensorspacing)
            ita_verbose_info([thisFuncStr ' Sensor spacing necessary, guessing 1.4 cm '],0);
            sArgs.sensorspacing = 0.014;
        end
    end
end

switch mode
    case 'wav'
        if strcmpi(input(end-2:end),'wav')
            [Y,FS,~,~]=wavread(input,'size');
            nSamples = Y(1);
            nChannels = Y(2);
            samplingRate = FS;
        else
            error('Unknown filetype')
        end
    case 'itaAudio'
        nSamples = input.nSamples;
        nChannels = input.nChannels;
        samplingRate = input.samplingRate;
    case 'realtime'
        nSamples = inf;
        nChannels = 2;
        samplingRate = ita_preferences('samplingRate');
        sArgs.overlap = 0;
end

if sArgs.playback
    sArgs.overlap = 0;
end

blocksize = sArgs.blocksize;
nOverlap = blocksize * sArgs.overlap;
alpha = 1-exp(-1./sArgs.t_c * (blocksize-nOverlap) / samplingRate);
alpha_bb = 1-exp(-1./sArgs.t_c * (blocksize) / samplingRate);
alpha_autocalib = 1-exp(-1./sArgs.t_autocalib * (blocksize-nOverlap) / samplingRate);

%% Some validity checks
if isempty(sArgs.interval)
    sArgs.interval = [1 nSamples];
end

nSegments = ceil(((sArgs.interval(2) - sArgs.interval(1)) -blocksize+nOverlap) / (sArgs.blocksize -nOverlap));
nNewLength = (nSegments + 1) * (sArgs.blocksize - nOverlap) + sArgs.blocksize;
while nNewLength > nSamples
    nSegments = nSegments-1; % just skip last segment
    nNewLength = (nSegments + 1) * (sArgs.blocksize - nOverlap) + sArgs.blocksize;
    
end

if isinf(sArgs.history) && strcmpi(mode,'realtime')
    sArgs.history = 100;
    nSegments = inf;
    ita_verbose_info(['Setting history to ' int2str(sArgs.history)],0);
else
    sArgs.history = min(nSegments+1, sArgs.history);
end

%% generate window
win_vec = window(sArgs.window,blocksize+1);
win_vec(end) = [];

bbwin_vec = window(sArgs.window,sArgs.bbblocksize+1);
bbwin_vec(end) = [];

%% Frequency limits for bands big blocks

freqVector = linspace(0,samplingRate/2,sArgs.bbblocksize/2+1);
if ~isempty(sArgs.fraction)
    if (sArgs.fraction ~= 0)
        b    = 10;
        step = 10*(3/sArgs.fraction)*0.1;
        x    = -20:step:round(log10(freqVector(end)/1000)*b);
        G    = 10;
        fm   = ((G.^(x/b))*1000).'; %centre frequency of bands
        bw_desgn = 2*sArgs.fraction;
        bandUpperLimit = fm*(2^(1/bw_desgn));
        bandLowerLimit = fm/(2^(1/bw_desgn));
        bandLowerLimit = [bandLowerLimit(1); bandUpperLimit(1:end-1)]; %mli: otherwise overlapping regions exist. e.g. 'fraction',0.5 on 1kHz sine produces very wrong results
        
        %new fm to show for the outside world
        if sArgs.fraction == 1 || sArgs.fraction == 3
            fm = ita_ANSI_center_frequencies([10 freqVector(end)],sArgs.fraction);
        else
            fm = fm.';
        end
        
        bandUpperLimit(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
        bandLowerLimit(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
        fm(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
    else  %% All mean
        bandLowerLimit = min(sArgs.flimit);
        bandUpperLimit = max(sArgs.flimit);
        fm = mean(sArgs.flimit);
    end
    freqIdx = bsxfun(@le, freqVector, bandUpperLimit) & bsxfun(@ge, freqVector, bandLowerLimit);
    
    emptybands = find(sum(freqIdx,2) == 0); % Some bands are empty, find and replace them
    while ~isempty(emptybands)
        freqIdx(emptybands,:) = freqIdx(emptybands+1,:);
        emptybands = find(sum(freqIdx,2) == 0);
    end
    
    freqIdx = bsxfun(@rdivide,freqIdx, mean(freqIdx,2)); % Divide every band by its number ob freqBins, so it can directly be used for multiplication
    
else
    fm = freqVector;
    if ~isempty( sArgs.flimit)
        fm(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
        freqIdx = bsxfun(@le, freqVector,  max(sArgs.flimit)) & bsxfun(@ge, freqVector,  min(sArgs.flimit));
    else
        freqIdx = true(size(fm));
    end
end
if size(fm,1)>1
    error('Why are we here?')
end

bbfreqVector = freqVector;
freqIdx_bb = freqIdx;

%% Frequency limits for bands 

freqVector = linspace(0,samplingRate/2,blocksize/2+1);
if ~isempty(sArgs.fraction)
    if (sArgs.fraction ~= 0)
        b    = 10;
        step = 10*(3/sArgs.fraction)*0.1;
        x    = -20:step:round(log10(freqVector(end)/1000)*b);
        G    = 10;
        fm   = ((G.^(x/b))*1000).'; %centre frequency of bands
        bw_desgn = 2*sArgs.fraction;
        bandUpperLimit = fm*(2^(1/bw_desgn));
        bandLowerLimit = fm/(2^(1/bw_desgn));
        bandLowerLimit = [bandLowerLimit(1); bandUpperLimit(1:end-1)]; %mli: otherwise overlapping regions exist. e.g. 'fraction',0.5 on 1kHz sine produces very wrong results
        
        %new fm to show for the outside world
        if sArgs.fraction == 1 || sArgs.fraction == 3
            fm = ita_ANSI_center_frequencies([10 freqVector(end)],sArgs.fraction);
        else
            fm = fm.';
        end
        
        bandUpperLimit(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
        bandLowerLimit(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
        fm(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
    else  %% All mean
        bandLowerLimit = min(sArgs.flimit);
        bandUpperLimit = max(sArgs.flimit);
        fm = mean(sArgs.flimit);
    end
    freqIdx = bsxfun(@le, freqVector, bandUpperLimit) & bsxfun(@ge, freqVector, bandLowerLimit);
    
    emptybands = find(sum(freqIdx,2) == 0); % Some bands are empty, find and replace them
    while ~isempty(emptybands)
        freqIdx(emptybands,:) = freqIdx(emptybands+1,:);
        emptybands = find(sum(freqIdx,2) == 0);
    end
    
    freqIdx = bsxfun(@rdivide,freqIdx, mean(freqIdx,2)); % Divide every band by its number ob freqBins, so it can directly be used for multiplication
    
else
    fm = freqVector;
    if ~isempty( sArgs.flimit)
        fm(fm < min(sArgs.flimit) | fm > max(sArgs.flimit)) = [];
        freqIdx = bsxfun(@le, freqVector,  max(sArgs.flimit)) & bsxfun(@ge, freqVector,  min(sArgs.flimit));
    else
        freqIdx = true(size(fm));
    end
end
if size(fm,1)>1
    error('Why are we here?')
end
%disp(['Analysing Frequencies: ' int2str(bandLowerLimit(sArgs.bandidplot)) ' Hz - ' int2str(bandUpperLimit(sArgs.bandidplot)) ' Hz'])
if ~isempty(sArgs.flimit)
    freqIdxSingle = (freqVector > min(sArgs.flimit) & freqVector < max(sArgs.flimit));
else
    freqIdxSingle = true(size(freqVector));
end



%% Allocate memory
pBuffer = zeros(blocksize, 2);
bbBuffer = zeros(sArgs.bbblocksize, 2);

C_pp = nan(sArgs.history, numel(fm));
C_pu = nan(sArgs.history, numel(fm));
C_pu_bb = nan(sArgs.history, numel(fm));
I = nan(sArgs.history, numel(fm));
%time = zeros(sArgs.history,1);
sfa = nan(sArgs.history, numel(fm),3);
sfd = nan(sArgs.history, numel(fm),3);
sf2 = nan(sArgs.history, numel(fm),2);
%sfc = nan(sArgs.history, numel(fm),4);
sfc = nan(sArgs.history, numel(fm),5);


time = linspace(0,nSegments*(blocksize-nOverlap)/samplingRate,sArgs.history);

uDenum = (double(ita_constants('rho_0')) * sArgs.sensorspacing) .* 1j .* 2 .* pi .* freqVector.' ./ double(ita_constants('z_0'));
uDenum(1) = Inf;

bbuDenum = (double(ita_constants('rho_0')) * sArgs.sensorspacing) .* 1j .* 2 .* pi .* bbfreqVector.' ./ double(ita_constants('z_0'));
bbuDenum(1) = Inf;

IDenum = nanmean(bsxfun(@times,uDenum.',freqIdx),2);

lostSamples = false;
clipping = false;

%% Prepare input
if strcmpi(mode,'itaAudio')
    input = input.ch([sArgs.channels]);
    timeData = input.timeData;
end
if strcmpi(mode,'realtime') || sArgs.playback % Init Hardware
    if playrec('isInitialised')
        playrec('reset');
    end
    if(~playrec('isInitialised'))
        playrec('init', samplingRate, ita_preferences('playDeviceID'), ita_preferences('recDeviceID'));
        pause(1);
    end
end
pageno = [];


%% Prepare compensation
if ~isempty(sArgs.compinit)
    comp = sArgs.compinit;
else
    % else
    %     if sArgs.compensate
    %         %comp = ita_read('hoertnix_compensation_onhead.ita');
    %         comp = abs(ita_read('mobile_demo_comp.ita'));
    %         comp = comp.ch(sArgs.channels);
    %         comp = ita_interpolate_spk(comp, log2(blocksize));
    %         comp = fft(comp);
    %         comp = comp.freqData;
    %     else
    comp = ones(blocksize/2+1,2);
    %     end
end

sgdelay = sArgs.gdelayinit;
sphasemm = 0; %mean((angle(comp(:,1))));
sampmm = sArgs.ampmminit;

%% Definition of basic sound fields in SFD space
switch sArgs.sfdmode
    case 1
        sf_ff = permute([1 1 1], [3 1 2]);
        sf_re = permute([1 0 1], [3 1 2]);
        sf_no = permute([0 0 0], [3 1 2]);
        
        if sArgs.freqdependentsfc % Frequency dependent definition of sf_di
            kd = sArgs.sensorspacing .* 2 .* pi .* fm ./ double(ita_constants('c')); % Or freqVector???
            sf_di = bsxfun(@times,permute([1 0 0], [3 1 2]), abs(sin(kd)./kd).^2);
        else
            sf_di = permute([1 0 0], [3 1 2]);
        end
    case 2
        sf_ff = permute([1 1 0], [3 1 2]);
        sf_re = permute([1 0 1], [3 1 2]);
        sf_no = permute([0 0 0], [3 1 2]);
        
        if sArgs.freqdependentsfc % Frequency dependent definition of sf_di
            kd = sArgs.sensorspacing .* 2 .* pi .* fm ./ double(ita_constants('c')); % Or freqVector???
            sf_di = bsxfun(@times,permute([1 0 0], [3 1 2]), abs(sin(kd)./kd).^2);
        else
            sf_di = permute([1 0 0], [3 1 2]);
        end
        
end

if size(sf_di,1) > 1 % Define other basic sound fields frequency dependent by repmat (constant over freq)
    sf_ff = repmat(sf_ff,size(sf_di)./size(sf_ff));
    sf_re = repmat(sf_re,size(sf_di)./size(sf_re));
    sf_no = repmat(sf_no,size(sf_di)./size(sf_no));
end

%% Inverse Coherence Energy Matrix
if sArgs.freqdependentsfc % Frequency dependent definition of sf_di
    kd = sArgs.sensorspacing .* 2 .* pi .* fm ./ double(ita_constants('c')); % Or freqVector???
    for idf = 1:numel(kd)
        ITFM(:,:,idf) = ([[0, 1, 0, 0, 0]; [(kd(idf))/sin(kd(idf)), 0, 0, -(kd(idf))/sin(kd(idf)), 0]; [0, 0, 1, 0, 0]; [-(kd(idf))/sin(kd(idf)), 0, 0, -(sin(kd(idf)) - kd(idf))/sin(kd(idf)), 1]; [0, -1, -1, 1, 0]]);
        %ITFM(:,:,idf) = ([[0, 1, 0, 0]; [(kd(idf))./sin(kd(idf)), -(kd(idf))./sin(kd(idf)), -(kd(idf))./sin(kd(idf)), 0]; [0, 0, 1, 0]; [-(kd(idf))./sin(kd(idf)), -(sin(kd(idf)) - kd(idf))./sin(kd(idf)), -(sin(kd(idf)) - kd(idf))./sin(kd(idf)), 1]]);
    end
else
    ITFM = repmat(([[0, 1, 0, 0]; [1, -1, -1, 0]; [0, 0, 1, 0]; [-1, 0, 0, 1]]),[1 1 numel(fm)] );
end

%% Create figure
% ToDo: Function for this!

if sArgs.direct_plot
    fgh(1) = figure();
    fgh(2) = figure('Name',['Sound Field Analysis ' int2str(bandLowerLimit(min(sArgs.bandidplot))) ' - ' int2str(bandUpperLimit(max(sArgs.bandidplot))) ' Hz']);
    set(fgh(2),'DefaultAxesColorOrder',[0 1 0;1 0 0;0 0 1; 0 0 0])
    ita_plottools_aspectratio(fgh(2),0); % Full screen
    [gui_axes, gui_handles, plot_axes ] = prepPlot(fgh, sArgs, [], []);
else
    fgh = 0;
end
stopnow = false;

%% Create Slices
idx = 0;
idredraw = 0;
while (idx < nSegments) && (all(ishandle(fgh)) || ~(sArgs.direct_plot)) && ~(stopnow) % Loop until the end of the audio or the figure is closed
    idx = idx+1;
    
    if sArgs.interactive % (Reevaluate Settings)
        try
            sArgs.sfcmethod = get(gui_handles.SFCMethod,'value');
            sArgs.ampmismatch = get(gui_handles.AmplificationMismatchInDB,'value');
            sArgs.gdelay = get(gui_handles.DelayInUs,'value')/1e6;
            sArgs.autocompamp = get(gui_handles.Auto_CompensateAmp,'value');
            sArgs.autocompphase = get(gui_handles.Auto_CompensatePhase,'value');
            sArgs.t_c = get(gui_handles.T_C,'value');
            sArgs.t_autocalib = get(gui_handles.T_Autocalib,'value');
            sArgs.bandidplot = str2num(get(gui_handles.BandIDsToPlot,'String'));
            sArgs.fuzzy = get(gui_handles.Fuzzy,'value');
            freqDepPlot = get(gui_handles.FrequencyDependentPlot ,'value');
            newplot = get(gui_handles.Plot,'String');
            newplot = deblank(newplot(get(gui_handles.Plot,'value'),:));
            if ~strcmpi(newplot,sArgs.plot) || freqDepPlot ~= sArgs.frequencydependentplot % User changed plot
                sArgs.plot = newplot;
                sArgs.frequencydependentplot = freqDepPlot;
                delete(plot_axes);
                [gui_axes, gui_handles, plot_axes ] = prepPlot(fgh, sArgs, gui_axes, plot_axes);
                plotsf(plot_axes,time,C_pu,C_pp,sfd,sfc,sfa,sArgs,true,idx,fm)
            end
            alpha = 1-exp(-1./sArgs.t_c * (blocksize-nOverlap) / samplingRate);
            alpha_autocalib = 1-exp(-1./sArgs.t_autocalib * (blocksize-nOverlap) / samplingRate);
            sArgs.bandidplot = min(sArgs.bandidplot, numel(fm));
            sArgs.bandidplot = max(sArgs.bandidplot, 1);
        catch errmsg
            rethrow(errmsg);
        end
    end
    
    iLow = (idx-1)*(blocksize-nOverlap) + sArgs.interval(1);
    iHigh = iLow+blocksize-1;
    %time(idx) = (iLow+iHigh)/2/samplingRate;
    %disp(100*idx/nSegments);
    switch mode
        case {'wav'; 'itaAudio'}
            switch mode
                case 'wav'
                    Y = wavread(input,[iLow iHigh]);
                    p1 = Y(:,1);
                    p2 = Y(:,2);
                case 'itaAudio'
                    p1 = timeData(iLow:iHigh,1);
                    p2 = timeData(iLow:iHigh,2);
            end
            if sArgs.playback
                pageno(end+1) = playrec('play',pBuffer,1:2); %#ok<AGROW>
                if numel(pageno) > sArgs.audiobuffersize
                    while ~playrec('isFinished',pageno(1))
                        pause(blocksize/samplingRate/8); % For responsiveness of GUI
                        %playrec('block',pageno(1));
                        
                    end
                    
                    playrec('delPage',pageno(1));
                    lostSamples = playrec('getSkippedSampleCount');
                    if lostSamples > blocksize
                        playrec('resetSkippedSampleCount');
                        disp('Lost some samples');
                    end
                    pageno(1) = [];
                    
                else
                end
            end
            
        case 'realtime'
            time(idx) = (iLow+iHigh)/2/samplingRate;
            if sArgs.playback
                pageno(end+1) = playrec('playrec',pBuffer,1:2,blocksize,sArgs.channels); %#ok<AGROW>
            else
                pageno(end+1) = playrec('rec',blocksize,sArgs.channels); %#ok<AGROW>
            end
            if numel(pageno) > sArgs.audiobuffersize
                pause(blocksize/samplingRate/20); % For responsiveness of GUI
                while ~playrec('isFinished',pageno(1))
                    %drawnow;%('expose');
                    %tic;
                    pause(blocksize/samplingRate/20); % For responsiveness of GUI
                    %bla = toc;
                    %disp(toc/(blocksize/samplingRate/20));
                    %playrec('block',pageno(1));
                end
                
                p = playrec('getRec',pageno(1));
                playrec('delPage',pageno(1));
                lostSamples = playrec('getSkippedSampleCount');
                if lostSamples > 0 %blocksize
                    playrec('resetSkippedSampleCount');
                    lostSamples = true; %disp('Lost some samples');
                else
                    lostSamples = false;
                end
                
                clipping = any(any(p > 0.99));
                
                pageno(1) = [];
                p1 = p(:,1);
                p2 = p(:,2);
            else
                p1 = zeros(blocksize,1);
                p2 = zeros(blocksize,1);
                playrec('resetSkippedSampleCount');
            end
    end
    
    pBuffer = [p1 p2] ;
    bbBuffer = [bbBuffer(blocksize+1:end,:); [p1 p2]] ;% Buffer for BigBlock evaluation
    
    %% FFT
    p1 = fft(p1.* win_vec); % Window + FFT
    p1 = p1(1:(blocksize+2)/2,:).';
    
    p2 = fft(p2.* win_vec); % Window + FFT
    p2 = p2(1:(blocksize+2)/2,:).';
    
    
    %Big Blocks
    p1bb = fft(bbBuffer(:,1) .* bbwin_vec);
    p1bb = p1bb(1:(sArgs.bbblocksize+2)/2,:).';
    p2bb = fft(bbBuffer(:,2) .* bbwin_vec);
    p2bb = p2bb(1:(sArgs.bbblocksize+2)/2,:).';
    
    
    %% Add artifical sensor mismatch
    p1 = p1 .* 10^(sArgs.ampmismatch/20) .* exp(1i .* sArgs.phasemismatch/180*pi) .* exp(1i .* 2.*pi.* freqVector .* sArgs.gdelay);
    
    %% Calculate auto compensation for Sensor Mismatch
    if sArgs.autocompamp || sArgs.autocompphase
        if ~sArgs.puinput % PP input
            if idx > 10 && mean(sfc(idx-1,:,2),2)>0.6 && alpha_autocalib < 1 %% Only in diffuse sound field
                if sArgs.autocompphase
                    gdelay = nanmean(angle(S_p1p2(freqIdxSingle)) ./ (2.*pi.*freqVector(freqIdxSingle))).' + sgdelay;
                    %phasemm = mean(angle(S_p1p2(freqIdxSingle))).' + sphasemm;
                    sgdelay = (1-alpha_autocalib) .* sgdelay + alpha_autocalib .* gdelay;
                    %sphasemm = (1-alpha_autocalib) .* sphasemm + alpha_autocalib .* phasemm;
                    %sphasemm = 0;
                end
                if sArgs.autocompamp
                    ampmm = nanmean(S_p2p2 ./ S_p1p1).' + sampmm - 1;
                    sampmm =  (1-alpha_autocalib) .* sampmm + alpha_autocalib .* ampmm;
                    
                end
            end
        else %% PU input
            if idx > 10 && mean(sfc(idx-1,:,2),2)>0.6 && alpha_autocalib < 1 %% Only in diffuse sound field
                if sArgs.autocompphase
                    gdelay = nanmean(angle(S_pu(freqIdxSingle)) ./ (2.*pi.*freqVector(freqIdxSingle))).' + sgdelay;
                    %phasemm = mean(angle(S_pu(freqIdxSingle))).' + sphasemm;
                    sgdelay = (1-alpha_autocalib) .* sgdelay + alpha_autocalib .* gdelay;
                    %sphasemm = (1-alpha_autocalib) .* sphasemm + alpha_autocalib .* phasemm;
                    %sphasemm = 0;
                end
                if sArgs.autocompamp
                    ampmm = nanmean(S_uu ./ S_pp).' + sampmm - 1;
                    ampmm = 1; % Dont comp amp for pu input
                    sampmm =  (1-alpha_autocalib) .* sampmm + alpha_autocalib .* ampmm;
                    
                end
            end
        end
        
        if sArgs.autocompamp && sArgs.autocompphase
            newcomp = sampmm .* exp(+1i .* (2.*pi.*freqVector.' .* sgdelay + sphasemm));
            compStr = ['Compensating ' num2str(-20*log10(mean(sampmm)),2) ' dB; ' num2str(-mean(sgdelay)*1e6,'%3.1f') ' us'];
        elseif sArgs.autocompamp
            newcomp = sampmm;
            compStr = ['Compensating ' num2str(-20*log10(mean(sampmm)),2) ' dB; ' num2str(0,'%3.1f') ' us'];
        elseif sArgs.autocompphase
            newcomp = 1 .* exp(+1i .* (2.*pi.*freqVector.' .* sgdelay + sphasemm));
            compStr = ['Compensating ' num2str(0,2) ' dB; ' num2str(-mean(sgdelay)*1e6,'%3.1f') ' us'];
        else
            newcomp = ones(size(comp));
        end
        
        comp = newcomp;
    else
        comp = ones(size(comp));
        compStr = ['Compensating ' num2str(0,2) ' dB; ' num2str(0,'%3.1f') ' us'];
        
    end
    
    %% Compensate Sensor Mismatch
    if sArgs.compensate || sArgs.autocompamp || sArgs.autocompphase
        p1 = p1 .* comp(:,1).';
        if size(comp,2) > 1
            p2 = p2 .* comp(:,2).';
        end
    end
    
    %% PP to PU or PU to PP
    if sArgs.puinput %% PU Input
        % p1 is P; p2 is U
        p = p1;
        u = p2;
        % Estimate p1 and p2 from p and u
        p1 = p + uDenum.' .* u./2;
        p2 = p - uDenum.' .* u./2;
        
    else % Default pp input
        % Estimate P and U from mic inputs
        p = (p1+p2)./2;
        u = (p2-p1) ./uDenum.';
        
        pbb = (p1bb+p2bb)./2;
        ubb = (p2bb-p1bb) ./bbuDenum.';
    end
    
    %% Cross- and Autospectral estimations
    if idx < 2 %Start of signal
        S_pu = p .* conj(u);
        S_pp =p .* conj(p);
        S_uu = u .* conj(u);
        S_p1p2 = (p1 .* conj(p2));
        S_p1p1 = (p1 .* conj(p1));
        S_p2p2 = (p2 .* conj(p2));
        
        S_pu_bb = pbb .* conj(ubb);
        S_pp_bb =pbb .* conj(pbb);
        S_uu_bb = ubb .* conj(ubb);
        
        
    elseif idx >= 2
        % Auto- and cross spectral densities for this slice + average with
        % last slice
        % This is an exponential average over the last slices, time
        % constant is defined by alpha
        S_pu =   (conj(p)  .* (u)  .* alpha + S_pu   .*(1-alpha));
        S_pp =   (conj(p)  .* (p)  .* alpha + S_pp   .*(1-alpha));
        S_uu =   (conj(u)  .* (u)  .* alpha + S_uu   .*(1-alpha));
        S_p1p2 = (conj(p1) .* (p2) .* alpha + S_p1p2 .*(1-alpha));
        S_p1p1 = (conj(p1) .* (p1) .* alpha + S_p1p1 .*(1-alpha));
        S_p2p2 = (conj(p2) .* (p2) .* alpha + S_p2p2 .*(1-alpha));
        
        S_pu_bb =   (conj(pbb)  .* (ubb)  .* alpha_bb + S_pu_bb   .*(1-alpha_bb));
        S_pp_bb =   (conj(pbb)  .* (pbb)  .* alpha_bb + S_pp_bb   .*(1-alpha_bb));
        S_uu_bb =   (conj(ubb)  .* (ubb)  .* alpha_bb + S_uu_bb   .*(1-alpha_bb));
        
        
        %% SFIs - Coherence and Intensity estimation
        if sArgs.psdbands
            C_pp_t = nanmean(bsxfun(@times,S_p1p2,freqIdx),2) ./ sqrt(nanmean(bsxfun(@times,S_p1p1,freqIdx),2) .* nanmean(bsxfun(@times,S_p2p2,freqIdx),2));
            C_pu_t = nanmean(bsxfun(@times,S_pu,freqIdx),2) ./ sqrt(nanmean(bsxfun(@times,S_pp,freqIdx),2) .* nanmean(bsxfun(@times,S_uu,freqIdx),2));
            I_t = nanmean(bsxfun(@times,S_pu,freqIdx),2) ./ nanmean(bsxfun(@times,S_pp,freqIdx),2);
            C_pp(idx,:) = C_pp_t;
            C_pu(idx,:) = C_pu_t;
        else
            C_pp_t = S_p1p2 ./ sqrt(S_p1p1 .* S_p2p2);
            C_pu_t = S_pu ./ sqrt(S_pp .* S_uu);
            I_t = S_pu ./ S_pp;
            
            C_pu_t(1) = C_pu_t(2); %S_uu(1) is 0 therefore C_pu_t is NaN, this is useless: Copy next bin
            C_pp_t(1) = C_pp_t(2); %S_uu(1) is 0 therefore C_pu_t is NaN, this is useless: Copy next bin
            
            C_pu_t_bb = S_pu_bb ./ sqrt(S_pp_bb .* S_uu_bb);
            C_pu_t_bb(1) = C_pu_t_bb(2); %S_uu(1) is 0 therefore C_pu_t is NaN, this is useless: Copy next bin
            
            %% Calculate Bands
            if isempty(sArgs.fraction) || sArgs.psdbands
                C_pp(idx,:) = C_pp_t(freqIdx);
                C_pu(idx,:) = C_pu_t(freqIdx);
            else
                C_pp(idx,:) = nanmean(bsxfun(@times,C_pp_t,freqIdx),2);
                C_pu(idx,:) = nanmean(bsxfun(@times,C_pu_t,freqIdx),2);
                I(idx,:) = nanmean(bsxfun(@times,I_t,freqIdx),2);
                
                C_pu_bb(idx,:) = mean(bsxfun(@times,C_pu_t_bb,freqIdx_bb),2);
            end
        end
        
        % Limit abs to [0 1] due to numerical reasons
        C_pp(idx,abs(C_pp(idx,:))>1) = C_pp(idx,abs(C_pp(idx,:))>1) ./ abs(C_pp(idx,abs(C_pp(idx,:))>1));
        C_pu(idx,abs(C_pu(idx,:))>1) = C_pu(idx,abs(C_pu(idx,:))>1) ./ abs(C_pu(idx,abs(C_pu(idx,:))>1));
        I(idx,abs(I(idx,:))>1) = I(idx,abs(I(idx,:))>1) ./ abs(I(idx,abs(I(idx,:))>1));
        
        C_pu_bb(idx,abs(C_pu_bb(idx,:))>1) = C_pu_bb(idx,abs(C_pu_bb(idx,:))>1) ./ abs(C_pu_bb(idx,abs(C_pu_bb(idx,:))>1));
        
        %% SFD
        switch sArgs.sfdmode
            case 1
                sfd(idx,:,1) = abs(C_pp(idx,:)); % Noise-Signal
                %sfd(idx,:,2) = abs(pi/2 - mod(angle(C_pu(idx,:)),pi)) /pi*2; % Reactive-Active
                sfd(idx,:,2) = 1./(1+1./abs(cot(angle(C_pu(idx,:)))));% .* (abs(C_pu(idx,:))); % Reactive-Active
                sfd(idx,:,3) = abs(C_pu(idx,:)); % Incoherent - Coherent
            case 2
                sfd(idx,:,1) = abs(C_pp(idx,:)); % Signal
                sfd(idx,:,2) = abs(real(C_pu(idx,:))); % Active
                sfd(idx,:,3) = abs(imag(C_pu(idx,:))); % Reactive
                sfd(idx,:,4) = abs(C_pu_bb(idx,:)); % Reactive
        end
        
        %% SFC
        % from SFD
        
        if sArgs.sfcmethod < 6
        d_ff = sqrt(sum(bsxfun(@minus,sfd(idx,:,:), sf_ff).^2,3));
        d_re = sqrt(sum(bsxfun(@minus,sfd(idx,:,:), sf_re).^2,3));
        
        switch sArgs.sfdmode
            case 1
                d_no = sqrt(sum(bsxfun(@minus,sfd(idx,:,[1 3]), sf_no(:,:,[1 3])).^2,3));
                d_di = sqrt(sum(bsxfun(@minus,sfd(idx,:,[1 3]), sf_di(:,:,[1 3])).^2,3));
            case 2
                d_no = sqrt(sum(bsxfun(@minus,sfd(idx,:,:), sf_no).^2,3));
                d_di = sqrt(sum(bsxfun(@minus,sfd(idx,:,:), sf_di).^2,3));
        end
        end
        
        switch round(sArgs.sfcmethod)
            case 1
                tsfc = 1 - cat(3,d_ff./sqrt(3),  d_di./sqrt(2), d_re./sqrt(3), d_no./sqrt(2));
                tsfc(tsfc<0) = 0;
                tsfc = bsxfun(@rdivide,tsfc , sum(tsfc,3));
            case 2
                tsfc = 1 - cat(3,d_ff./sqrt(1),  d_di./sqrt(1), d_re./sqrt(1), d_no./sqrt(1));
                tsfc(tsfc<0) = 0;
                tsfc = bsxfun(@rdivide,tsfc , sum(tsfc,3));
            case 3
                tsfc = 1 - cat(3,d_ff./sqrt(1),  d_di./sqrt(1), d_re./sqrt(1), d_no./sqrt(1));
                tsfc(tsfc<0) = 0;
            case 4
                tsfc = 1 ./ cat(3,d_ff./sqrt(1),  d_di./sqrt(1), d_re./sqrt(1), d_no./sqrt(1));
                tsfc(tsfc<0) = 0;
                tsfc = bsxfun(@rdivide,tsfc , sum(tsfc,3));
            case 5
                tsfc = 1 - cat(3,d_ff./sqrt(1),  d_di./sqrt(1), d_re./sqrt(1), d_no./sqrt(1));
                tsfc(tsfc<0) = 0;
                tsfc = 1./(1./tsfc - 1);
                tsfc = bsxfun(@rdivide,tsfc , sum(tsfc,3));
            case 6
                for idf = 1:size(sfd,2)
                    tsfc(1,idf,:) = ITFM(:,:,idf) * [squeeze(sfd(idx,idf,:)) ;1];
                end
            otherwise
                error('Invalid Setting')
        end
        
        if ~sArgs.fuzzy % Hard classification
            [a,b] = max(tsfc,[],3);
            %tsfc = zeros(size(tsfc));
            tsfc = repmat(b,[1,1,4]) == repmat(permute(1:4,[3 1 2]), [1, size(tsfc,2) ,1 ]);
        end
        
        
        %
        sfc(idx,:,:) = tsfc;
        
        %% SFA
        snr = 1./(1./abs(C_pp(idx,:)) - 1);
        %drr = 1./((1./abs(C_pu)) - (1./snr) - 1);
        drr = 1./((1./abs(C_pu(idx,:))) - 1); % Simplified Version
        %drr = 1./(1./(abs(C_pu).*(1./snr +1)) -1);
        drr(drr<0) = inf;
        arr = 1./abs(tan(angle(C_pu(idx,:))));
        tsfa = 10*log10(cat(3,snr,drr,arr));
        tsfa(~isnan(tsfa)) = max(min(tsfa(~isnan(tsfa)),30),-30); %Limit to axes
        sfa(idx,:,:) = tsfa;
        %source_direction = acos(real(I));
        %source_certainty = sfd(:,:,3) .* sfd(:,:,1) ;
        
        
    end
    
    if sArgs.direct_plot && all(ishandle(fgh))
        %% Plot
        set(fgh(2) ,'Name',['Sound Field Analysis ' int2str(bandLowerLimit(min(sArgs.bandidplot))) ' - ' int2str(bandUpperLimit(max(sArgs.bandidplot))) ' Hz']);
        plotsf(plot_axes,time,C_pu,C_pp,sfd,sfc,sfa,sArgs,false,idx,fm);

        %% Display some stuff
        clc
        disp(compStr);
        
        if lostSamples
            disp('Lost some samples')
        end
        if clipping
            disp('Clipping')
        end
    end
    
    
    %% Shift results
    if idx >= sArgs.history
        idx = idx-1;
        C_pp = circshift(C_pp,[-1 0]);
        C_pu = circshift(C_pu,[-1 0]);
        sfd = circshift(sfd,[-1 0 0]);
        sfc = circshift(sfc,[-1 0 0]);
        sfa = circshift(sfa,[-1 0 0]);
    end
    
end

if strcmpi(mode,'realtime') || sArgs.playback
    playrec('reset'); % Close audio stream
end

drawnow;
if exist('FS','var')
    FS.Clear() ;  % Clear up the box
    clear FS ;    % this structure has no use anymore
end

%% Clean Results
C_pp(time == 0,:) = [];
C_pu(time == 0,:) = [];
sfd(time == 0,:,:) = [];
sfc(time == 0,:,:) = [];
sfa(time == 0,:,:) = [];
time(time == 0) = [];

%% Prepare output
dummy = itaResultTimeFreq;
dummy.timeVector = time;
dummy.freqVector = fm;

isfi = dummy;
isfi.time = cat(3,C_pp, C_pu);
isfi.comment = 'SFI';
isfi.channelNames = {'C_{pp}','C_{pu}'};

isfd = dummy;
isfd.time = sfd;
isfd.comment = 'SFD';
isfd.channelNames = {'SFD_{NS}','SFD_{RA}','SFD_{IC}'};

isfc = dummy;
isfc.time = sfc;
isfc.comment = 'SFC';
isfc.channelNames = {'Free','Diffuse','Reactive','Noise','Reverberation'};
isfc.plotLineProperties = {'Color', [0 1 0], 'LineStyle', '-'; ...
                           'Color', [1 0 0], 'LineStyle', '--'; ...
                           'Color', [0 0 1], 'LineStyle', ':'; ...
                           'Color', [0 0 0], 'LineStyle', '-.'; ...
                           'Color', [1 1 0], 'LineStyle', '-.' ...
                           };


isfa = dummy;
isfa.time = sfa;
isfa.comment = 'SFA';
isfa.channelNames = {'SNR','DRR','ARR'};
isfa.channelUnits = {'dB','dB','dB'};



%% Set Output
if nargout > 1
    varargout = {isfi, isfd, isfc, isfa, comp, sampmm, sgdelay};
else
    varargout{1} = struct('sfi',isfi, 'sfd',isfd, 'sfc',isfc, 'sfa',isfa,'settings',sArgs,'comp',comp,'ampmm',sampmm,'gdelay',sgdelay);
    
end
end

function [gui_axes, gui_handles, plot_axes ] = prepPlot(fgh, sArgs, gui_axes, plot_axes)
persistent guihandle;

%    if sArgs.interactive
if isempty(gui_axes) || ~ishandle(gui_axes)
%     pos = get(fgh(1),'Position');
%     guipos = pos;
%     guipos(4) = pos(4)*1/2;
%     guipos(2) = pos(2)+pos(4)*2/3;
%     guipos(1) = pos(1)+ pos(3)*1/6;
%     guipos(3) = pos(3)*1/3;
%     gui_axes = axes('Parent',fgh(1),'Position',guipos);
    %gui_axes = subplot(2,3,1,'Parent',fgh);
    
    
    set(gui_axes,'Units','Pixels');
    set(gui_axes,'Visible','off');
    idx = 1;
    pList{idx}.description = 'Plot'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.list        = 'SFI|SFD|SFD-Space|SFC|SFA';
    pList{idx}.default     = sArgs.plot; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    idx = idx+1;
    pList{idx}.description = 'Frequency Dependent Plot'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.frequencydependentplot; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    idx = idx+1;
    pList{idx}.description = 'BandIDs to Plot'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.bandidplot; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    
    idx = idx+1;
    pList{idx}.description = 'SFC Method';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'slider'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.sfcmethod; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{idx}.range     = [1 6];
   
    idx = idx+1;
    pList{idx}.description = 'Fuzzy'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.fuzzy; %default value, could also be empty, otherwise it has to be of the datatype specified above
   
    
    idx = idx+1;
    pList{idx}.description = 'T_C'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'slider'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.t_c; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{idx}.range     = [0 10];
    
    
    idx = idx+1;
    pList{idx}.description = 'Amplification mismatch in dB';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'slider'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.ampmismatch; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{idx}.range     = [-5 5];
    
    idx = idx+1;
    pList{idx}.description = 'Delay in us';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'slider'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.gdelay; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{idx}.range     = [-100 100];
    
    idx = idx+1;
    pList{idx}.description = 'Auto-Compensate Amp'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.autocompamp; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    idx = idx+1;
    pList{idx}.description = 'Auto-Compensate Phase'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.autocompphase; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    
    idx = idx+1;
    pList{idx}.description = 'T_Autocalib'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'slider'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = sArgs.t_autocalib; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{idx}.range     = [0 300];
    
    
    % Sensor distance, Input_channels, amp+phase mismatch,
    % auto-compensate, t_c, t_autocalib
%    [~, gui_handles] = ita_parametric_GUI(pList,'test','wait',false,'return_handles','true','fgh',fgh,'position',    get(gui_axes,'OuterPosition'),'buttonnames',{'stop'});
        [~, gui_handles] = ita_parametric_GUI(pList,'test','wait',false,'return_handles','true','fgh',fgh(1));

    %    end
else
    gui_handles = guihandle;
end

guihandle = gui_handles;

if ishandle(plot_axes)
    delete(plot_axes);
end

% pos = get(fgh,'Position');
% plotpos = pos;
% plotpos(4) = pos(4)*5/6;
% plotpos(2) = pos(2)+ pos(4)*1/6;
% plotpos(1) = pos(1)+ pos(3)*2/7;
% plotpos(3) = pos(3)*5/8;
% plot_axes = axes('Parent',fgh,'Position',plotpos);
 plot_axes = axes('Parent',fgh(2));
%plot_axes = subplot(1,2,2,'Parent',fgh);


switch(lower(sArgs.plot))
    case 'sfd-space'
        ita_sfi_sfdspace_figure('axh',plot_axes,'legend',true,'slices',false,'linewidth',4,'sfdmode',sArgs.sfdmode);
    otherwise
        % DO nothing
end
% Logo
% ita_plottools_addlogo('parent',subplot(2,3,4),'uselogo',true)
%set(fgh,'Renderer','openGL')
drawnow;

%FS = stoploop('Stop',true);
end


function plotsf(plot_axes,time,C_pu,C_pp,sfd,sfc,sfa,sArgs,resetplot,idx,fm) %#ok<INUSL>
persistent idredraw;
persistent plot_handle;
persistent cbar;

if isempty(idredraw)
    idredraw = inf;
end

if isempty(plot_handle)
    plot_handle = -1;
end

if resetplot
    delete plot_handle;
    plot_handle = -1;
end

%% Plots
if sArgs.direct_plot && idredraw > sArgs.redrawframes && ishandle(plot_axes)
    idredraw = 0;
    %stopnow = FS.Stop();
    %             % Coherences
    %             if ~ishandle(c_plot_handle)
    %                 c_plot_handle = plot(time,[abs(C_pp(:,sArgs.bandidplot)) abs(C_pu(:,sArgs.bandidplot))],'Parent',c_axes);
    %                 ylim(c_axes,[0 1]);
    %                 %xlim([0 max(time)]);
    %                 legend(c_axes,{'C_{pp}','C_{pu}'});
    %                 legendcolorbarlayout(c_axes, 'remove')
    %             else
    %                 set(c_plot_handle(1),'YData',abs(C_pp(:,sArgs.bandidplot)),'XData',time);
    %                 set(c_plot_handle(2),'YData',abs(C_pu(:,sArgs.bandidplot)),'XData',time);
    %             end
    if sArgs.frequencydependentplot
        time(isinf(time)) = min(time);
        switch lower(sArgs.plot)
            case {'sfi'}
                plotthis = fliplr(cat(2,fliplr(abs(C_pp)), zeros(numel(time),1) ,fliplr(abs((C_pu)))).');
                clim = [0 1];
                fm = fliplr(fm);
                f = cat(2,fm,zeros(1, 1), fm);
            case {'sfd','sfc','sfa'}
                plottmp = eval(lower(sArgs.plot));
                plottmp = flipdim(plottmp,2);
                plotthis = plottmp(:,:,1);
                fm = fliplr(fm);
                f = fm;
                for idx = 2:size(plottmp,3);
                   plotthis = cat(2, plotthis, zeros(numel(time),1), plottmp(:,:,idx)); 
                   f = cat(2,f,zeros(1, 1), fm);
                end
                plotthis = fliplr(plotthis.');
                if strcmpi(sArgs.plot, 'sfa')
                    clim = [-30 30];
                else
                    clim = [0 1];
                end
                
            otherwise
                return
        end
        
        y = 1:size(plotthis,1);
        if ~all(ishandle(plot_handle))
            plot_handle(1) = image(time,y,plotthis,'Parent',plot_axes);
            set(plot_axes,'clim',clim);
            set(plot_handle(1),'CDataMapping','Scaled');
            drawnow;
            cbar = colorbar('peer',plot_axes);
            title(plot_axes,'');
            
            
            
            %set(axh,'YDir','normal');
            %set(axh,'YTickLabel',int2str(fm(f(get(axh,'YTick'))).'));
            set(plot_axes,'YTick',sort([find(f==(min(f(f>0)))| f == (max(f))) find(f == fm(round(numel(fm)/2)))] ));
            YLabels = cellstr(int2str((f(get(plot_axes,'YTick'))).'));
            YKLabels = cellstr([int2str((f(get(plot_axes,'YTick'))).'./1000) repmat('k',size((f(get(plot_axes,'YTick'))).'))]);
            YLabels((f(get(plot_axes,'YTick')))>1000) = YKLabels((f(get(plot_axes,'YTick')))>1000);
            
            set(plot_axes,'YTickLabel',YLabels);
            
            lbs = cellstr(get(plot_axes,'YTickLabel'));
            switch lower(sArgs.plot)
                case 'sfi'
                    lbs(2:3:end) = {'|C_pp|','|(C_pu)|'};
                case 'sfd'
                    lbs(2:3:end) = {'Signal','Active','Reactive'};
                case 'sfc'
                    lbs(2:3:end) = {'Free','Diffuse','Reactive','Noise'};
                case 'sfa'
                    lbs(2:3:end) = {'SNR','DRR','ARR'};
            end
            
            set(plot_axes,'YTickLabel',lbs);
            legendcolorbarlayout(plot_axes, 'remove');
            %set(plot_handle,'AlphaData',repmat(~(f==0), size(plotthis.')./ size(f)).' );
        else
            set(plot_handle(1),'CData',plotthis);
            %set(plot_axes,'clim',clim);
        end
    else
        plotids = min(sArgs.bandidplot):max(sArgs.bandidplot);
        if ishandle(cbar)
            colorbar(cbar,'off');
        end
        switch lower(sArgs.plot)
            case 'sfi'
                if ~all(ishandle(plot_handle))
                    plot_handle(1) = polar(plot_axes, mean(angle(C_pp(:,plotids)),2),ones(size(C_pp(:,1))));
                    hold(plot_axes,'all')
                    plot_handle(2) = polar(plot_axes, mean(angle(C_pu(:,plotids)),2),ones(size(C_pu(:,1))));
                    %c_plot_handle(3) = scatter(c_axes, cos(source_direction(idx,plotids)) .*source_certainty(idx,plotids) , sin(source_direction(idx,plotids)) .*source_certainty(idx,plotids));
                    plot_handle(3) = scatter(plot_axes, mean(real(C_pp(idx,plotids)),2),mean(imag(C_pp(idx,plotids)),2),50,[0 0 0],'filled');
                    plot_handle(4) = scatter(plot_axes, mean(real(C_pu(idx,plotids)),2),mean(imag(C_pu(idx,plotids)),2),50,[0 0 0],'filled');
                    
                    hold(plot_axes,'off')
                    view(plot_axes,[90 -90])
                    
                    %ylim(c_axes,[0 1]);
                    %xlim([0 max(time)]);
                    %legend(c_axes,{'C_{pp}','C_{pu}','Incidence Direction '});
                    legend(plot_axes,{'C_{pp}','C_{pu}'});
                    %legend(c_axes,{'SFI_{1}','SFI_{2}'});
                    legendcolorbarlayout(plot_axes, 'remove');
                    title(plot_axes,'Sound Field Indicators');
                    set(plot_handle(1),'LineWidth',2);
                    set(plot_handle(2),'LineWidth',2);
                    %                set(c_plot_handle(3),'LineWidth',2);
                    
                else
                    set(plot_handle(1),'YData',mean(imag(C_pp(:,plotids)),2),'XData',mean(real(C_pp(:,plotids)),2));
                    set(plot_handle(2),'YData',mean(imag(C_pu(:,plotids)),2),'XData',mean(real(C_pu(:,plotids)),2));
                    %set(c_plot_handle(3),'YData',sin(source_direction(idx,plotids)) .*source_certainty(idx,plotids),'XData',cos(source_direction(idx,plotids)).*source_certainty(idx,plotids));
                    set(plot_handle(3),'YData',mean(imag(C_pp(idx,plotids)),2),'XData',mean(real(C_pp(idx,plotids)),2));
                    set(plot_handle(4),'YData',mean(imag(C_pu(idx,plotids)),2),'XData',mean(real(C_pu(idx,plotids)),2));
                end
                
                
            case {'sfd', 'sfc', 'sfa'}
                plotthis = flipdim(eval(lower(sArgs.plot)),1);
                if ~all(ishandle(plot_handle))
                    plot_handle = plot(time,squeeze(mean(plotthis(:,plotids,:),2)),'Parent',plot_axes);
                    switch lower(sArgs.plot)
                        case 'sfd'
                            ylim(plot_axes,[0 1]);
                            switch sArgs.sfdmode
                                case 1
                                    legend(plot_axes,{'Noise<->Signal','Reactive<->Active','Incoherent<->Coherent'},'Location','NorthEast');
                                case 2
                                    legend(plot_axes,{'Signal','Active','Reactive'},'Location','NorthEast');
                            end
                            title(plot_axes,'Sound Field Description');
                        case 'sfc'
                            ylim(plot_axes,[-1 2]);
                            legend(plot_axes,{'Free','Diffuse','Reactive','Noise'},'Location','NorthEast');
                            title(plot_axes,'Sound Field Classification');
                        case 'sfa'
                            ylim(plot_axes,[-30 30]);
                            legend(plot_axes,{'SNR', 'DRR', 'ARR'},'Location','NorthEast');
                            title(plot_axes,'Sound Field Analysis');
                    end
                    legendcolorbarlayout(plot_axes, 'remove')
                else
                    for idx = 1:size(plotthis,3)
                        set(plot_handle(idx),'YData',mean(plotthis(:,plotids,idx),2),'XData',time);
                    end
                end
                

            case 'sfd-space'
                % SFDSPACE
                if sArgs.plot_sfdspace
                    if ~all(ishandle(plot_handle))
                        plot_handle(1) = plot3(mean(sfd(:,plotids,1),2),mean(sfd(:,plotids,2),2),mean(sfd(:,plotids,3),2),'Parent',plot_axes);
                        %sfs_plot_handle = plot3(sfd(:,:,1),sfd(:,:,2),sfd(:,:,3),'Parent',sfs_axes);
                        hold(plot_axes,'on');
                        plot_handle(2) = scatter3(mean(sfd(idx,plotids,1),2),mean(sfd(idx,plotids,2),2),mean(sfd(idx,plotids,3),2),'filled','Parent',plot_axes,'LineWidth',10);
                        hold(plot_axes,'off');
                        %xlim([0 max(time)]);
                        %legend(sfa_axes,{'SNR', 'DRR', 'ARR'});
                        legendcolorbarlayout(plot_axes, 'remove')
                        title(plot_axes,'SFD Space');
                    else
                        %scattercolor = [(1-sfd(idx,plotids,3))*sfd(idx,plotids,1) sfd(idx,plotids,2) * sfd(idx,plotids,1) (1-sfd(idx,plotids,2)) * sfd(idx,plotids,1) * sfd(idx,plotids,3) ];
                        %scattercolor = min(max(scattercolor,0),1); % Limit to [0 1], necessary due to numerical reasons
                        %if any(isnan(scattercolor))
                            scattercolor = [0 0 0];
                        %end
                        
                        set(plot_handle(1),'YData',mean(sfd(:,plotids,2),2),'XData',mean(sfd(:,plotids,1),2),'ZData',mean(sfd(:,plotids,3),2));
                        set(plot_handle(2),'YData',mean(sfd(idx,plotids,2),2),'XData',mean(sfd(idx,plotids,1),2),'ZData',mean(sfd(idx,plotids,3),2),'CData',scattercolor);
                    end
                end
            otherwise
        end
    end
    
    %    if ~strcmpi(mode,'realtime') && ~sArgs.playback
    %        drawnow('expose');
    %    end
end
idredraw = idredraw +1;

end
