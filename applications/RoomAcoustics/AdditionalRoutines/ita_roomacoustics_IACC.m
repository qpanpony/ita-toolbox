function outStruct = ita_roomacoustics_IACC(varargin)
%ITA_ROOMACOUSTICS_IACC - Interaural cross correlation (IACC)
%
%  This function calculates the interaural cross correlation (IACC)
%  after ISO 3382 for early reflections, for reverberant sound and full time.
%  The input should be an itaAudio file which contains a binaural
%  measurement. The function identifies the binaural impulse responses
%  by searching the words "Left", "Right" in the channels. If the channel
%  names don't have this words, the function will set left and right
%  ear by selecting the first and second channel.
%
%   The Parameters are calculated in octave or in third octave bands.
%
%  Syntax:
%   iaccStruct                              = ita_roomacoustics_IACC(audioObjIn, options)
%
%   Options (default):
%           'freqRange'           (ita_preferences('freqRange'))      : frequncy range for analysis
%           'bandsPerOctave'      (ita_preferences('bandsPerOctave')) : bands per octave for filtering
%           'broadBand'           (false)                             : broadband analysis (no filtering)
%  Example:
%       iaccStruct = ita_roomacoustics_IACC(audioObjIn)
%       iaccStruct.IACC_ealy
%
%  See also:
%   ita_roomacoustics, ita_roomacoustics_lateral
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_IACC">doc ita_roomacoustics_IACC</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  17-May-2010


%% GUI ?
if ~nargin
    ita_roomacoustics_IACC_gui();
    return
end

%% Initialization and Input Parsing
sArgs         = struct('pos1_data','itaAudioTime','bandsPerOctave', ita_preferences('bandsPerOctave'), 'freqRange', ita_preferences('freqRange'), 'broadBand', false, 'calcITDandILD', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

if nargout > 3
    error('to many output arguments')
end

%%

if input.fftDegree > 16
    input = ita_extract_dat(input,16);
end
%% Check for left and right channels.

idxLeft     = find(~cellfun(@isempty, strfind(lower(input.channelNames), 'left' )));
idxRight    = find(~cellfun(@isempty, strfind(lower(input.channelNames), 'right')));

if all([numel(idxLeft) numel(idxRight)] == 0)   % found nothing
    ita_verbose_info('automatic channel recognition failed: left (right) channelname must contain string ''left'' (''right'').',0)
    ita_verbose_info(['  Assumption for left : Channel 1 (' input.channelNames{1} ')' ] ,1)
    ita_verbose_info(['  Assumption for right: Channel 2 (' input.channelNames{2} ')' ] ,1)
    idxLeft  = 1;
    idxRight = 2;
elseif all([numel(idxLeft) numel(idxRight)] ~= 1)
    error('more than one channel recognized as left or right')
else
    ita_verbose_info(sprintf('  Found left  channel: Channel %i (%s)', idxLeft, input.channelNames{idxLeft}) ,1)
    ita_verbose_info(sprintf('  Found right channel: Channel %i (%s)', idxRight, input.channelNames{idxRight}) ,1)
end

nShiftSamplesLeft  = ita_start_IR(input.ch(idxLeft));
nShiftSamplesRight = ita_start_IR(input.ch(idxRight));

[left,  shiftTimeL] = ita_time_shift(input.ch(idxLeft), -min(nShiftSamplesLeft, nShiftSamplesRight), 'samples');
[right, shiftTimeR] = ita_time_shift(input.ch(idxRight), -min(nShiftSamplesLeft, nShiftSamplesRight), 'samples');

% fprintf(' %i samples = %2.2f ms\n',abs(nShiftSamplesRight - nShiftSamplesLeft), abs(nShiftSamplesRight - nShiftSamplesLeft) / input.samplingRate * 1000 )

%% Searching for integration limits

t0 = 0;
t1 = 0.080; % seconds
t2 = left.trackLength - max(abs([shiftTimeL shiftTimeR]));%bigger than T

timeIntervals = [t0 t1; t1 t2; t0, t2];
intervalNameCell = {'early' 'late' 'fullTime'};

fs = input.samplingRate;
%% filtering
if ~sArgs.broadBand
    [left,  freqVec]  = ita_fractional_octavebands(left, 'bandsPerOctave', sArgs.bandsPerOctave, 'freqrange', sArgs.freqRange, 'zerophase');
    right            = ita_fractional_octavebands(right,'bandsPerOctave', sArgs.bandsPerOctave, 'freqrange', sArgs.freqRange, 'zerophase');
else
    freqVec = 0;
end

nFreqBands = numel(freqVec);
%% calculate correlations

[IACC_data, ITD_data, ILD_data]  = deal(nan(nFreqBands, 3));

for iTimeInterval = 1: size(timeIntervals,1)
    
    idxLow = left.time2index(timeIntervals(iTimeInterval,1));
    idxHigh = left.time2index(timeIntervals(iTimeInterval,2));
    
    cutLeft     = left.timeData(idxLow:idxHigh,:);
    cutRight    = right.timeData(idxLow:idxHigh,:);
    nCutSamples = idxHigh - idxLow  +1;
    
    for iBand = 1:nFreqBands
        CCF  = xcorr(cutLeft(:,iBand) ,cutRight(:,iBand));
        [maxCorr, ITD_data(iBand, iTimeInterval)] = max(abs(CCF(round(nCutSamples-fs*0.001):round(nCutSamples+fs*0.001))));
        energyLeft = sqrt(sum(cutLeft(:,iBand).^2));
        energyRight = sqrt(sum(cutRight(:,iBand).^2));
        IACC_data(iBand, iTimeInterval)  = maxCorr/(energyLeft*energyRight);
        
        ILD_data(iBand, iTimeInterval) = energyLeft ./ energyRight;
    end
    
end

%% Set Output

result  = itaResult(3,1);
[result.freqVector]         = deal(freqVec);
[result.allowDBPlot]        = deal(false);

resultTemplate = result(1);


[result.comment ]   = deal( [input.comment sprintf(' -> IACC early (%i ms, %i ms) ', 1000*t0, 1000*t1)], ...
                            [input.comment sprintf(' -> IACC late (%i ms, %1.2f s) ', 1000*t1, t2)]    , ...
                            [input.comment sprintf(' -> IACC full time (%i ms, %1.2f s) ', 1000*t0, t2)]) ;
[result.plotAxesProperties] = deal({'ylim', [0 1.05]});




for iInterval = 1: size(IACC_data,2)
    result(iInterval).freqData  = IACC_data(:,iInterval);
    outStruct.(['IACC_' intervalNameCell{iInterval}]) = result(iInterval);
    
end


if sArgs.calcITDandILD
    
    
    % convert samples in time
    ITD_data = ITD_data / fs - 0.001;
    
    % convert rms ratio in (dB) level difference
    ILD_data = 20*log10(ILD_data);
    
    for iInterval = 1: size(IACC_data,2)
        tmpResult = resultTemplate;
        tmpResult.freqData = ITD_data(:,iInterval);
        [tmpResult.comment, tmpResult.channelNames{1}] = deal(sprintf('ITD %s', intervalNameCell{iInterval}));
        tmpResult.channelUnits ={'s'};
        outStruct.(['ITD_' intervalNameCell{iInterval}]) = tmpResult;
        
        
        tmpResult = resultTemplate;
        tmpResult.freqData = ILD_data(:,iInterval);
        [tmpResult.comment, tmpResult.channelNames{1}] = deal(sprintf('ILD %s', intervalNameCell{iInterval}));
        tmpResult.channelUnits ={'dB'};
        outStruct.(['ILD_' intervalNameCell{iInterval}]) = tmpResult;

    end
    
    
end

%end function
end