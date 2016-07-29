function varargout = ita_sfi_calculate(varargin)
%ITA_SFI_CALCULATE - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_sfi_calculate(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_sfi_calculate(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sfi_calculate">doc ita_sfi_calculate</a>

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
    wavmode = false;
elseif isa(varargin{1},'char')
    arg1 = 'char';
    if strcmpi(varargin{1},'portaudio')
        
    else
        wavmode = true;
    end
else
    error('Wrong Input');
end

sArgs        = struct('pos1_data',arg1,'blocksize',1024,'overlap',0.5,'window',@hann,'blocks',8,'sensorspacing',[],'fraction',0,'interval',[]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

if isempty(sArgs.sensorspacing)
    if wavmode
        ita_verbose_info([thisFuncStr ' Sensor spacing necessary, guessing 1.4 com '],0);
        sArgs.sensorspacing = 0.014;
    else
        sArgs.sensorspacing = input.channelCoordinates.n(2)- input.channelCoordinates.n(1);
        sArgs.sensorspacing = sArgs.sensorspacing.r;
    end
end

if wavmode
    if strcmpi(input(end-2:end),'wav')
        [Y,FS,~,OPTS]=wavread(input,'size');
        nSamples = Y(1);
        nChannels = Y(2);
        samplingRate = FS;
    else
        error('Unknown filetype')
    end
else
    nSamples = input.nSamples;
    nChannels = input.nChannels;
    samplingRate = input.samplingRate;
end
blocksize = sArgs.blocksize;
nBlocks = sArgs.blocks;
nOverlap = blocksize * sArgs.overlap;

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back
if isempty(sArgs.interval)
    sArgs.interval = [1 nSamples];
end
nSegments = ceil(((sArgs.interval(2) - sArgs.interval(1)) -blocksize+nOverlap) / (sArgs.blocksize -nOverlap));
nNewLength = (nSegments + 1) * (sArgs.blocksize - nOverlap);
if nNewLength > nSamples
    nSegments = nSegments-1; % just skip last segment
end

%% generate window
win_vec = window(sArgs.window,blocksize+1);
win_vec(end) = [];

%% Frequency limits for bands
freqVector = linspace(0,samplingRate/2,blocksize/2+1);

if ~isempty(sArgs.fraction) && (sArgs.fraction ~= 0)
    f    = freqVector;
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
    %fm = ita_ANSI_center_frequencies([10 freqVector(end)],sArgs.fraction);
elseif ~isempty(sArgs.fraction) && (sArgs.fraction == 0) %% All mean
    bandLowerLimit = freqVector(2);
    bandUpperLimit = samplingRate/2;
    fm = samplingRate/4;
    
else
    fm = freqVector;
end




%% Allocate memory
resultDummy = itaAudio;
resultDummy.data = zeros(1,nChannels);
buffer = repmat(resultDummy,sArgs.blocks,1);
% p1b = repmat(resultDummy,sArgs.blocks,1);
% p2b = repmat(resultDummy,sArgs.blocks,1);
% pb = repmat(resultDummy,sArgs.blocks,1);
% ub = repmat(resultDummy,sArgs.blocks,1);

p1b = zeros(sArgs.blocks, blocksize/2+1);
p2b = zeros(sArgs.blocks, blocksize/2+1);
pb = zeros(sArgs.blocks, blocksize/2+1);
ub = zeros(sArgs.blocks, blocksize/2+1);

C_pp = nan(nSegments, numel(freqVector));
C_pu = nan(nSegments, numel(freqVector));
time = zeros(nSegments,1);

uDenum = (double(ita_constants('rho_0')) * sArgs.sensorspacing) .* 1j .* 2 .* pi .* freqVector.';
uDenum(1) = Inf;
timeData = input.timeData;

%% Create Slices
for idx = 1:nSegments
    iLow = (idx-1)*(blocksize-nOverlap) + sArgs.interval(1);
    iHigh = iLow+blocksize-1;
    time(idx) = (iLow+iHigh)/2/samplingRate;
    %disp(100*idx/nSegments);
    if wavmode
        Y = wavread(input,[iLow iHigh]);
        p1 = Y(:,1) .* win_vec;
        p2 = Y(:,2) .* win_vec;
    else
        % slice  = ita_extract_samples(input,iLow:iHigh, sArgs.window);
        p1 = timeData(iLow:iHigh,1) .* win_vec;
        p2 = timeData(iLow:iHigh,2) .* win_vec;
    end
    
    p1 = fft(p1);
    p1 = p1(1:(blocksize+2)/2,:);
    
    p2 = fft(p2);
    p2 = p2(1:(blocksize+2)/2,:);
    %% pp to pu
    
    p = (p1+p2)./2;
    u = (p1-p2) ./uDenum;
    %u = u ;
    
    %u = p./uDenum;
    
    %u = ita_integrate(p1-p2,'domain','freq') ./ uDenum;
    
    %newslice = merge([p1, p2, p, u]);
    
    if idx <= nBlocks %Start of signal
        %buffer(idx) = newslice;
        p1b(idx,:) = p1;
        p2b(idx,:) = p2;
        pb(idx,:) = p;
        ub(idx,:) = u;
    else
        %buffer = [buffer(2:nBlocks); newslice];
        p1b = [p1b(2:nBlocks,:); p1.'];
        p2b = [p2b(2:nBlocks,:); p2.'];
        pb = [pb(2:nBlocks,:); p.'];
        ub = [ub(2:nBlocks,:); u.'];
        
        
    end
    
    if idx >= nBlocks
        % Input Values
        S_pu = mean(pb .* conj(ub));
        S_pp = mean(pb .* conj(pb));
        S_uu = mean(ub .* conj(ub));
        S_p1p2 = mean(p1b .* conj(p2b));
        S_p1p1 = mean(p1b .* conj(p1b));
        S_p2p2 = mean(p2b .* conj(p2b));
        
        %% SFIs
        C_pp_t = S_p1p2 ./ sqrt(S_p1p1 .* S_p2p2);
        C_pu_t = S_pu ./ sqrt(S_pp .* S_uu);
        
        
        C_pp(idx,:) = C_pp_t;
        C_pu(idx,:) = C_pu_t;
        
    end
    
end


if isempty(sArgs.fraction)
else
    C_pp_t = C_pp;
    C_pu_t = C_pu;
    
    C_pu = C_pu(:,1:numel(fm));
    C_pp = C_pp(:,1:numel(fm));
    
    for idx_fm = 1:numel(fm)
        upper_limit_idx = find(freqVector < bandUpperLimit(idx_fm),1,'last');
        lower_limit_idx = find(freqVector >= bandLowerLimit(idx_fm),1);
        sel_idx = lower_limit_idx:upper_limit_idx; %selected indices
        
        if numel(sel_idx) > 0
            C_pp(:,idx_fm) = mean((C_pp_t(:,sel_idx)),2);
            C_pu(:,idx_fm) = mean(C_pu_t(:,sel_idx),2);
        else
            C_pp(:,idx_fm)  = NaN;
            C_pu(:,idx_fm)  = NaN;
        end
        
    end
end

%C_pu(isnan(C_pu)) = 0;
%C_pp(isnan(C_pp)) = 0;


% iC_pp = itaResult;
% iC_pu = itaResult;
% iC_pp.freqVector = fm;
% iC_pu.freqVector = fm;
% iC_pp.freqData = C_pp.';
% iC_pu.freqData = C_pu.';
% iC_pu.channelNames = cellstr(num2str(time,15));
% iC_pp.channelUnits = cellstr(num2str(time,15));

iC_pp = itaResult;
iC_pu = itaResult;
iC_pp.timeVector = time(:);
iC_pu.timeVector = time(:);
iC_pp.timeData = C_pp;
iC_pu.timeData = C_pu;
iC_pu.channelNames = cellstr(num2str(fm(:),15));
iC_pp.channelNames = cellstr(num2str(fm(:),15));



%% Set Output
varargout(1) = {iC_pu};
varargout(2) = {iC_pp};
%end function
end