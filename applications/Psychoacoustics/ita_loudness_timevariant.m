function varargout = ita_loudness_timevariant(varargin)
%ITA_LOUDNESS_TIMEVARIANT - Timevariant Loudness according to DIN 45631/A1
%   This function calculates the loudness level of a signal according to
%   DIN 45631/A1 norm, using the Zwicker algorithm. The input is an ITA audio+
%   object (unit Pa).
%
%  Syntax:
%   TotalLoudness                           = ita_loudness_timevariant(itaAudio, options)
%   [TotalLoudness SpecificLoudness]        = ita_loudness_timevariant(itaAudio, options)
%   [TotalLoudness SpecificLoudness N_5]    = ita_loudness_timevariant(itaAudio, options)
%   [...]                                   = ita_loudness_timevariant(fileName, options)
%
%    TotalLoudness      - Loudness as a function of time
%    SpecificLoudness   - Loudness as a function of time and bark scale
%    N_5                - The 5% percentile loudness (Corresponds to the average perceived loudness according to DIN)
%    fileName           - Path and Filename of a Wave File
%
%   Options (default):
%           'SoundFieldType' ('free')   : Type of sound field: 'free' or 'diffuse'
%           'blocksize'      (2)        : Blocksize in ms.                  [DIN: 2ms]
%           'overlap'        (0)        : Overlap of the blocks [0 ... 1)   [DIN: 0  ]
%           'sensitivity'    ( )        : Sensitivity in [1 / Pa] - Only when input is wav
%           'cutoutput'      (false)    : true => length(output) = length(input)
%

% <ITA-Toolbox>
% This file is part of the application Psychoacoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%
%  Example:
%   pink = ita_generate('pinknoise', 0.9, 44100, 19);
%   pink.channelUnits = {'Pa'};
%   N1 = ita_loudness_timevariant(pink)
%
%   ita_write(pink, 'pink19.wav')
%   N2 = ita_loudness_timevariant('pink19.wav', 'sensitivity' , 1/ itaValue(2, 'Pa'))   % fullscale in wave equates 2 Pa
%
%  See also:
%   ita_loudness, ita_sone2phon, ita_sharpness
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_loudness_timevariant">doc ita_loudness_timevariant</a>

% TODO:
%  * Faktoren für RMS und einseitige spektrum direkt in alle Filter
%  * ist mit zweiseitigen spektren rechnen schneller?
%  * 'shape' 'same' funktion
%  * empfindlcihkeit als itaValue?

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  18-Aug-2010



% Ablauf:
% Signal >> Filterbank (FB) >> Gleichrichtung >> Tiefpassfilterung (TP1)
% >> FilterBankKanal 1 und 2 zusammenfassen >> SPL berechnen
% >> Kernlautheiten berechnen >> NL Block
% >> Frequenzverdeckung berechnen und Integration >> Tiefpassfilterung (TP2)
%
% FB und TP1 werden mit Overlap-Add berechnet um hohe Zeitliche Auflösung auch für tiefe Freq zu erreichen.
% NL Block ist in C geschrieben und aus DIN Kopiert (ohne die Fehler versteht sich)
% Berechnung der Frequnzverdeckung auch in C da iterativ und deswegen langsam
% TP2 so ausgelegt, dass das raus kommt was rauskommen soll


%% Initialization and Input Parsing
if isa(varargin{1}, 'itaAudio')
    sArgs        = struct('pos1_data','itaAudio', 'SoundFieldType', 'free', 'blocksize', 2, 'overlap', 0, 'sensitivity', itaValue, 'cutoutput', false);
    [input,sArgs] = ita_parse_arguments(sArgs,varargin);
    
    % UNIT CHECK
    if ~all(strcmp(input.channelUnits(:), 'Pa'))
        error('The input has to be itaAudio with unit Pa.');
    end
    
    nChannels           = input.nChannels;
    nSamplesOriginal    = input.nSamples;
    samplingRate        = input.samplingRate;
    chName              = input.channelNames{1};
    input_DATA          = input.timeData;
    inputIsWave         = false;
    
    inputHistory = input.history;
    inputComment = input.comment;
    clear input
else
    sArgs        = struct('pos1_fileName','string', 'SoundFieldType', 'free', 'blocksize', 2, 'overlap', 0, 'sensitivity', itaValue, 'cutoutput', false);
    [fileName,sArgs] = ita_parse_arguments(sArgs,varargin);
    
    [m, d] = wavfinfo(fileName);
    if strcmp(m, 'Sound (WAV) file')
        nSamplesOriginal = str2double(d(findstr(d, 'Sound (WAV) file containing: ') + 28: findstr(d, ' samples')));
        nChannels = str2double(d(findstr(d, 'samples in ') + 11: findstr(d, ' channel(s)')));
        [filePath, chName] = fileparts(fileName);
        [~, samplingRate] = wavread(fileName, [1 1]);
    else
        error('Could not open wave file!')
    end
    inputIsWave = true;
    if strcmpi(sArgs.sensitivity.unit,'1/Pa')
        sensitivity = sArgs.sensitivity.value;
    else
        error('If input is a wave file, the sensitivity must be specified in 1/Pa !')
    end
    
    clear del m d filePath
end

if nChannels ~=1% jo, mehr Kanäle wären toll TODO
    disp('At the moment only analysis of first channel  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
end



if  strcmp(sArgs.SoundFieldType, 'diffuse');
    diffFieldCorrection = [0 0 0.5 0.9 1.2 1.6 2.3 2.8 3.0 2.0 0.0 -1.4 -2.0 -1.9 -1.0 0.5 3.0 4.0 4.3 4.0].';
else
    diffFieldCorrection = 0;
end

% FILTERBANK(FB) PARAMETER
fbBlockSize     = 2^15+1;
fbFFTsize       = 2^16;
fbFilterSize    = fbFFTsize +1 -fbBlockSize;

% ZEROPADDING FOR FB
nParts              = ceil(nSamplesOriginal / fbBlockSize);
if ~inputIsWave
    input_DATA          =  [input_DATA; zeros(nParts*fbBlockSize - nSamplesOriginal ,nChannels)];
end

% ANALYSE PARAMETER
anaBlockSize    = round(sArgs.blocksize/1000 * samplingRate);
anaOverlap      = sArgs.overlap;
nOverlap        = round(anaOverlap * anaBlockSize);
if nOverlap >= anaBlockSize
    disp('Warning:  Overlap set to < 1 !!');
    nOverlap = anaBlockSize-1;
end
nAnalysisParts  = ceil(( nParts*fbBlockSize-nOverlap)/(anaBlockSize-nOverlap));
analysisDeltaT  = (anaBlockSize-nOverlap) / samplingRate ;


%% DESIGN FILTER
impulse = ita_generate('impulse', 1,samplingRate, fbFFTsize);
[filterBank, freqVec] = ita_fractional_octavebands(impulse, 'freqRange', [25 12500], 'bandsPerOctave', 3, 'order',6, 'zerophase', false);
thridOctFilter_SPK = filterBank.freqData;

%
filterBank_SPK      = [sum(thridOctFilter_SPK(:,1:3),2) sum(thridOctFilter_SPK(:,4:6),2) sum(thridOctFilter_SPK(:,7:9),2) sum(thridOctFilter_SPK(:,10:11),2) thridOctFilter_SPK(:,12:28)];
filterBank_SPK      = [filterBank_SPK;  filterBank_SPK(end-1:-1:2,:)];
filterBank_freq     = freqVec([3 6 9 11 12:end]); %TODO: Check ob so richtig
clear thirdOctFilter neededFreq thridOctFilter_SPK

% DESIGN LOWPASS FILTER TP1
finalTimeData   = [];
f3dB            = 3 * filterBank_freq(1:10) / (4*pi); % just for fc <=1000 Hz
impulse         = ita_generate('impulse',1,samplingRate,fbFilterSize);
for iTP = 1: length(f3dB)
    h               = fdesign.lowpass('n,f3db',1,f3dB(iTP),samplingRate);
    Hd              = design(h,'butter');
    finalTimeData   = [finalTimeData filter(Hd,impulse.timeData',2).']; %#ok<AGROW>
end
finalTimeData   = [finalTimeData repmat(finalTimeData(:,end), 1, 11); zeros(fbFFTsize-fbFilterSize,21) ];
filterBank_TP1               = itaAudio(finalTimeData, samplingRate, 'time');
filterBank_TP1.signalType    = 'energy';
filterBankTP1_SPK            = filterBank_TP1.freqData;
filterBankTP1_SPK            = [filterBankTP1_SPK ; filterBankTP1_SPK(end-1:-1:2,:)];
clear f3dB impulse iTP h Hd finalTimeData  filterBank_TP1

% PreAlloc
oaBufferTerzfilter      = zeros(fbFFTsize,21);
oaBufferTP1             = zeros(fbFFTsize,20);
BlockConversionBuffer   = [];
TotalLoudness           = ones(nAnalysisParts,1);
if nargin > 1
    SpecificLoudness        = zeros(nAnalysisParts,240);
end
iAnalysePart            = 1;

cblBuffer = zeros(nAnalysisParts,20);

cWaitLimit = 0.1*nAnalysisParts; % waitbar
% fprintf('Calc Loudness: [          ]')

for iPart = 1:nParts
    idxStartPart = (iPart-1)*fbBlockSize+1;  % TODO: check ob Vektor strat:end schneller ist
    
    if inputIsWave % input is wave
        if iPart ~= nParts
            input_DATA = wavread(fileName, [idxStartPart idxStartPart+fbBlockSize-1])/ sensitivity;
        else  % zeropaddin for last part
            input_DATA = [wavread(fileName, [idxStartPart nSamplesOriginal]) /sensitivity; zeros(nParts*fbBlockSize-nSamplesOriginal,nChannels)];
        end
        inputPart_SPK = fft(input_DATA(:,1), fbFFTsize );
    else  % input is itaAudio
        inputPart_SPK = fft(input_DATA(idxStartPart:idxStartPart+fbBlockSize-1,1), fbFFTsize );
    end
    
    % 1/3 OCTAVE BAND FILTERBANK
    fbSig_SPK = bsxfun(@times,inputPart_SPK, filterBank_SPK);
    fbSig_DATA = ifft(fbSig_SPK , 'symmetric');
    
    oaBufferTerzfilter = [oaBufferTerzfilter(fbBlockSize+1:end,:)+ fbSig_DATA(1:fbFilterSize-1,:) ; fbSig_DATA(fbFilterSize:end,:)];
    
    % ABSOLUTE VALUE
    SigNachAbs_DATA = abs(oaBufferTerzfilter(1:fbBlockSize,:)) ;
    
    % TP1
    SigNachAbs_SPK = fft(SigNachAbs_DATA, fbFFTsize);
    SigNachTP1_SPK = SigNachAbs_SPK .* filterBankTP1_SPK;
    SigNachTP1_DATA = ifft([SigNachTP1_SPK(:,1) + SigNachTP1_SPK(:,2) SigNachTP1_SPK(:,3:21)], 'symmetric');
    
    oaBufferTP1 = [oaBufferTP1(fbBlockSize+1:end,:)+ SigNachTP1_DATA(1:fbFilterSize-1,:) ; SigNachTP1_DATA(fbFilterSize:end,:)];
    
    % Blockkonvertierung
    BlockConversionBuffer = [BlockConversionBuffer; oaBufferTP1(1:fbBlockSize,:)]; %#ok<AGROW>
    
    if isequal(iPart, nParts) % add zeros to the last part
        nZeros = ceil(( size(BlockConversionBuffer,1) -nOverlap)/(anaBlockSize-nOverlap))* (anaBlockSize-nOverlap) + nOverlap - size(BlockConversionBuffer,1);
        BlockConversionBuffer = [BlockConversionBuffer; zeros(nZeros,20)]; %#ok<AGROW>
    end
    
    for iAnaBlockReady = 1:floor(( size(BlockConversionBuffer,1) -nOverlap)/(anaBlockSize-nOverlap))
        % waitbar
        if iAnalysePart > cWaitLimit
            zehner = round(10* cWaitLimit /nAnalysisParts);
            % fprintf([ repmat('\b',1,12-zehner) '>'  repmat(' ',1,10-zehner) ']'])
            cWaitLimit = (zehner+1)/10*nAnalysisParts;
        end
        idxTmp = (anaBlockSize - nOverlap)*(iAnaBlockReady-1)+1;
        power = sum(BlockConversionBuffer(idxTmp:idxTmp+anaBlockSize-1 ,:).^2) /(anaBlockSize);
        
        % SPL => Kernlautheit
        level = zeros(20,1);
        level(power>0) = 10*log10(power(power>0)) + 93.9794 ;
        
        
        % diffuse field correction
        level = level + diffFieldCorrection;
        
        cbl = ita_level2criticalBandLoudness(level);
        cblBuffer(iAnalysePart,:)  = cbl;
        
        % next step
        iAnalysePart = iAnalysePart+1;
        
    end
    
    BlockConversionBuffer = BlockConversionBuffer(idxTmp+anaBlockSize-nOverlap:end,:);
end

% BLOCK NL
cblBufferNL =  ita_loudness_BlockNL_MEX(cblBuffer,   analysisDeltaT );

% MAKE SLOPES
if nargout > 1 % this way there will be no memory errors for large wave files
    for iAnalysePart = 1:nAnalysisParts
        [TotalLoudness(iAnalysePart), SpecificLoudness(iAnalysePart,:)] =ita_loudness_makeSlopes_MEX([cblBufferNL(iAnalysePart,:).';0 ]);
    end
else
    for iAnalysePart = 1:nAnalysisParts
        [TotalLoudness(iAnalysePart), del] = ita_loudness_makeSlopes_MEX([cblBufferNL(iAnalysePart,:).';0 ]); %#ok<NASGU>
    end
end
%%

NvorTP2 = itaAudio([TotalLoudness; zeros(rem(nAnalysisParts,2),1)], 1/analysisDeltaT, 'time' );

% TP 2    -   Lowpass 2 is not described in detail in DIN.
NfftMin         = NvorTP2.samplingRate *1 +NvorTP2.nSamples -1; % filter with length 1 sec
NfftOrder       = nextpow2(NfftMin);
delaySamples    = round(3.5e-3/analysisDeltaT);  % delay of analog filter
impuls = ita_time_shift(ita_generate('impulse', 1, NvorTP2.samplingRate, NfftOrder), delaySamples, 'samples');
shelf1 = ita_filter(impuls, 'shelf',   'low',[6.26 2.5],'order', 1);
shelf2 = ita_filter(shelf1, 'shelf',   'low',[12.1 39],'order', 1);
shelf2 = ita_amplify(shelf2, .3-max(shelf2.freqData_dB), 'dB');
result = ita_multiply_spk(ita_extend_dat(NvorTP2, 2^NfftOrder, 'forcesamples'), shelf2);

if sArgs.cutoutput
    nOutputSamples = round(nSamplesOriginal/ samplingRate /analysisDeltaT);
else
    nOutputSamples = NvorTP2.nSamples;
end

% lowpass for specific loudness
if nargout > 1
    % fprintf('  - filter specific loudness')
    NSvorTP2 = itaAudio([SpecificLoudness; zeros(rem(nAnalysisParts,2),240)],  1/analysisDeltaT, 'time');
    clear SpecificLoudness
    
    %      nSamplesVorTP2 = NSvorTP2.nSamples;
    %     resultNS = ita_multiply_spk(ita_extend_dat(NSvorTP2, 2^NfftOrder, 'forcesamples'), shelf2);
    
    NSvorTP2 = ita_extend_dat(NSvorTP2, 2^NfftOrder, 'forcesamples');
    
    NSout = zeros(240,nOutputSamples);
    
    for iBarkStep = 1:240 % loop to avoid memory error
        if isequal(rem(iBarkStep,24),0)
            fprintf('.')
        end
        tmpRes = ita_multiply_spk(NSvorTP2.ch(iBarkStep), shelf2);
        NSout(iBarkStep,:) = tmpRes.timeData(1:nOutputSamples,1);
    end
    
    NSoutStruct.data          = round(NSout*100)/100;
    NSoutStruct.timeVector    = NSvorTP2.timeVector(1:nOutputSamples);
    
    NSoutStruct.freqVector    = 0.1:.1:24;
    NSoutStruct.chName        = chName;
end

% fprintf('done.\n')






%% Generate itaResult
N                       = itaResult();
% N.timeData              = result.timeData(1:result.time2index(nSamplesOriginal / samplingRate),:);
% N.timeVector            = result.timeVector(1:size(N.timeData,1));
N.timeData              = result.timeData(1:nOutputSamples);
N.timeVector            = result.timeVector(1:nOutputSamples);

N.channelNames{1}       = ['Timevariant Loudness of ' chName];
N.plotAxesProperties    = {'ylim' [0 ceil(max(max(N.timeData)))] 'xlim' [0 nSamplesOriginal / samplingRate]};
N.channelUnits(:)       = {'sone'};
if ~inputIsWave
    N.history               = inputHistory;
    N.comment               = inputComment;
end

N                       = ita_metainfo_add_historyline(N,mfilename,varargin);

%% Set Output


varargout(1) = {N};

if nargout > 1
    
    varargout(2) = {NSoutStruct };
    
    % %     pcolor(NSoutStruct.timeVector,  NSoutStruct.freqVector, NSoutStruct.data)
    %     contourf(NSoutStruct.timeVector,  NSoutStruct.freqVector, NSoutStruct.data)
    %     shading flat
    %     xlabel('Time [s]'); ylabel('Frequency [Bark]'); title(NSoutStruct.chName)
    %     cb = colorbar; set(get(cb,'ylabel'),'String','Specific Loudness [sone/ Bark]');
end

if nargout == 3
    
    N_5 = itaValue(prctile(N.timeData, 95));
    N_5.unit = 'sone';
    varargout(3) = {N_5};
end

%end function
end