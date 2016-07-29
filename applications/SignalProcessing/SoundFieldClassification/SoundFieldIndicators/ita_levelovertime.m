function varargout = ita_levelovertime(varargin)
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
    wavmode = true;
else
    error('Wrong Input');
end

sArgs        = struct('pos1_data',arg1,'blocksize',1024,'overlap',0.5,'window',@hann,'fraction',0,'interval',[],'smooth',[]);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

input = input.ch(1);

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


if ~isempty(sArgs.fraction) && sArgs.fraction > 0
   input = ita_mpb_filter(input,'oct',sArgs.fraction);    
end


%% Allocate memory
resultDummy = itaAudio;
resultDummy.data = zeros(1,nChannels);
timeData = input.timeData;

%% Create Slices
for idx = 1:nSegments
    iLow = (idx-1)*(blocksize-nOverlap) + sArgs.interval(1);
    iHigh = iLow+blocksize-1;
    time(idx) = (iLow+iHigh)/2/samplingRate;
    %disp(100*idx/nSegments);
    if wavmode
        Y = wavread(input,[iLow iHigh]);
        p1 = Y(:,1);% .* win_vec;
    else
        % slice  = ita_extract_samples(input,iLow:iHigh, sArgs.window);
        p1 = timeData(iLow:iHigh,:);% .* win_vec;
    end

    resultData(idx,:) = sqrt(mean(p1.^2));
    
end

result = itaResult;
result.timeData = 20*log10(resultData);
result.timeVector = time;
result.channelNames = {'Level'};
result.channelUnits = {'dB'};


if ~isempty(sArgs.smooth)
    span = round(sArgs.smooth * 1./mean(diff(result.timeVector)));
end

if ~isempty(sArgs.smooth) && sArgs.smooth > 0
        result.timeData(:,1) = smooth(result.timeData(:,1),span,'moving');    
end

varargout{1} = result;

%end function
end