function varargout = ita_roomacoustics_reverberation_time_lundeby(varargin)
%ITA_ROOMACOUSTICS_LUNDEBY - reverberation time with lundeby algorithm
%  This function uses the algorithm after Lundeby et al. [1] to calculate 
%  the (late) reverberation time, intersection time and noise level estimation.
%  This function should not be called directly. Use ita_roomacoustics() to
%  get Lundeby parameters:
%
% 
%  Use ita_roomacoustics() to get parameter:
%  
%   raFilter    = ita_roomacoustics(RIR, 'T_Lundeby', 'PSNR_Lundeby', 'Intersection_Time_Lundeby' )
%   raBroadBand = ita_roomacoustics(RIR, 'T_Lundeby', 'PSNR_Lundeby', 'Intersection_Time_Lundeby' , 'broadbandAnalysis')
% 
%  Example:
%    [RT_lundeby PSNR Intersection_Time_Lundeby NoiseLundeby PNR] = ita_roomacoustics_reverberation_time_lundeby(RIR)
%
%   'shortRevTimeMode' (false): shorter time average intervals to detect very short reverberation times (or intersections)
%  See also:
%   ita_roomacoustics
%
% References
%  [1] Lundeby, Virgran, Bietz and Vorlaender - Uncertainties of Measurements in Room Acoustics - ACUSTICA Vol. 81 (1995)
% 
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_lundeby">doc ita_roomacoustics_lundeby</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  06-Jul-2011


%% Initialization and Input Parsing
sArgs         = struct('pos1_data','itaAudio',  'bandsPerOctave', ita_preferences('bandsperoctave'), 'freqRange', ita_preferences('freqRange'), 'plot', false, 'shortRevTimeMode',false, 'broadbandAnalysis', false, 'inputIsSquared', false);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

%%

[input, timeShifted] = ita_time_shift(input, '20dB');

% cut samples from cyclic shift to avoid error in noise estimation
nSamples2cut   = -timeShifted*input.samplingRate + rem(-timeShifted*input.samplingRate,2); % always cut even number

% input        = ita_roomacoustics_shiftIR(input, 'threshold', 20);
% nSamples2cut = zeros(input.nChannels,1);

%%
if sArgs.broadbandAnalysis
    freqVec         = ones(input.nChannels,1);
    freqDepWinTime = ones(input.nChannels,1) * 0.03; % broadband: use 30 ms windows sizes

else
    freqVec         = ita_ANSI_center_frequencies(sArgs.freqRange , sArgs.bandsPerOctave, input.samplingRate);

    if numel(freqVec) ~= input.nChannels
        ita_verbose_info('Frequency vector does not fit to input channles. Frequency dependet smoothing will be wrong! ',0)
    end
    
    % % freqDepWinTime = min(max((20e3 - freqVec*6) /500+10, 10), 50) / 1000;
    % % freqDepWinTime = min(max( 1./freqVec*800+20, 10), 50) / 1000 * 1.5; % old: works well
    % freqDepWinTime = min( 5./freqVec, 50); % 2 periods per wavelength, maximum 50 ms
    freqDepWinTime =  (800 ./freqVec+10 ) / 1000;
end

if sArgs.shortRevTimeMode
    freqDepWinTime = freqDepWinTime / 5;
end

% semilogx(freqVec, freqDepWinTime*1000, 'o-'); grid on
%%
if sArgs.inputIsSquared
        rawTimeData         = max(input.timeData,0);
else
    rawTimeData         = input.timeData.^2;
end

[nSamples, nChannels]= size(rawTimeData);
nSamples            = nSamples - nSamples2cut;
[ revT, noiseLevel, intersectionTime, noisePeakLevel]   = deal(nan(nChannels,1));

%%

% semilogx(freqVec, 1000*[ (800 ./freqVec+10 ) / 1000;  min( 5./freqVec, 50);  min(max( 1./freqVec*800+20, 10), 50)/1000], 'o-'); 
% grid on
% legend({'sota' 'old' 'new'})

%%

nPartsPer10dB            =  5;   % time intervals per 10 dB decay. lundeby: 3 ... 10
dbAboveNoise             = 10;   % end of regression 5 ... 10 dB
useDynRangeForRegression = 20 ;  % 10 ... 20 dB

% % % dbAboveNoise             = 0;   % end of regression 5 ... 10 dB
% % % useDynRangeForRegression = 10 ;  % 10 ... 20 dB


% plot parameters
if sArgs.plot
    figure;
    subplotSize = [ceil(sqrt(nChannels)) round(sqrt(nChannels)) ];
end

for iChannel = 1:nChannels
    
    % 1) smooth
    nSamplesPerBlock = round(freqDepWinTime(iChannel)* input.samplingRate);
    timeWinData      = squeeze(sum(reshape(rawTimeData(1:floor(nSamples(iChannel)/nSamplesPerBlock)*nSamplesPerBlock,iChannel), nSamplesPerBlock,floor(nSamples(iChannel)/nSamplesPerBlock) ,1),1)).'/nSamplesPerBlock;
    timeVecWin       = (0:size(timeWinData,1)-1).'*nSamplesPerBlock/input.samplingRate;
    
    % 2) estimate noise
    noiseEst = mean(timeWinData(end-round(size(timeWinData,1)/10):end,:))+realmin;
    
    % 3) regression

    [del, startIdx] = max(timeWinData);
    stopIdx = find(10*log10(timeWinData(startIdx+1:end)) > 10*log10(noiseEst)+ dbAboveNoise, 1, 'last') + startIdx;
%     stopIdx = find(10*log10(timeWinData(startIdx+1:end)) < 10*log10(noiseEst)+ dbAboveNoise, 1, 'first') + startIdx;


    dynRange = diff(10*log10(timeWinData([startIdx stopIdx])));
    
    if isempty(stopIdx) || (stopIdx == startIdx) || dynRange > -5 
        ita_verbose_info('Regression did not work due to low SNR, continuing with next channel/band',1);
        continue;
    end
    
%     if (stopIdx-startIdx+1) <= 3 % less than 3 samples for regression (maybe problem of too large time intervals for short reverberation)
%         % if dynamic range is big engough => use shorter averiging intervals
%         if dynRange < -30   
%         end    
%     end
    
    
    X = [ones(stopIdx-startIdx+1,1) timeVecWin(startIdx:stopIdx)]; % X*c = edc
    c = X\(10*log10(timeWinData(startIdx:stopIdx)));
    %     T = -60/c(2);
    
    if c(2) == 0 || any(isnan(c))
        ita_verbose_info('Regression did not work due, T would be Inf, setting to 0, continuing with next channel/band',1);
        continue;
    end
    
    % 4) preliminary crossing point
    crossingPoint = (10*log10(noiseEst) - c(1)) / c(2);
    if crossingPoint > (input.trackLength + timeShifted(iChannel))  * 2 
        continue
    end
    
    % 5) new local time interval length
    nBlocksInDecay   = diff(10*log10(timeWinData([startIdx stopIdx]))) / -10 * nPartsPer10dB;
    nSamplesPerBlock = round(diff(timeVecWin([startIdx stopIdx])) / nBlocksInDecay * input.samplingRate);
    
    % 6) average
    timeWinData = squeeze(sum(reshape(rawTimeData(1:floor(nSamples(iChannel)/nSamplesPerBlock)*nSamplesPerBlock,iChannel), nSamplesPerBlock,floor(nSamples(iChannel)/nSamplesPerBlock) ,1),1)).'/nSamplesPerBlock;
    timeVecWin = (0:size(timeWinData,1)-1).'*nSamplesPerBlock/input.samplingRate;
    [del, idxMax] = max(timeWinData);
    
    
    oldCrossingPoint = 11+crossingPoint; % high start value to enter while-loop
    loopCounter = 0;
    
    while(abs(oldCrossingPoint-crossingPoint) > 0.01)
        % 7) estimate backgroud level
        correspondingDecay = 10;  % 5...10 dB
        idxLast10percent        = round(size(timeWinData,1)*0.9);
        idx10dBBelowCrosspoint  = max(1,round( (crossingPoint - correspondingDecay ./ c(2)) * input.samplingRate / nSamplesPerBlock));
        noiseEst                = mean(timeWinData(min(idxLast10percent,idx10dBBelowCrosspoint ):end,:)) +realmin;
        
        % 8) estimate late decay slope
        startIdx = find(10*log10(timeWinData(idxMax:end)) < 10*log10(noiseEst)+ dbAboveNoise + useDynRangeForRegression, 1, 'first') + idxMax - 1;
        if isempty(startIdx)
            startIdx = 1;
        end
        stopIdx  = find(10*log10(timeWinData(startIdx+1:end)) < 10*log10(noiseEst)+ dbAboveNoise, 1, 'first')           + startIdx;
        if isempty(stopIdx)
            ita_verbose_info('Regression did not work due to low SNR, continuing with next channel/band',1);
            break;
        end
        X = [ones(stopIdx-startIdx+1,1) timeVecWin(startIdx:stopIdx)]; % X*c = edc
        c = X\(10*log10(timeWinData(startIdx:stopIdx)));
        
        if c(2) >= 0
            ita_verbose_info('Regression did not work due, T would be Inf, setting to 0, continuing with next channel/band',1);
            c(2) = Inf;
            break;
        end
        
        % 9) find croosspoint
        oldCrossingPoint = crossingPoint;
        crossingPoint = (10*log10(noiseEst) - c(1)) / c(2);
        
        
        % iteration faild
        % in the case of no noise tail his might be possible, or not?
% % %         if crossingPoint > input.trackLength + timeShifted(iChannel)
% % %             [c(2), crossingPoint, noiseEst] = deal(nan);
% % %             break
% % %         end
        

        %
        loopCounter = loopCounter +1;
        if loopCounter > 30
            ita_verbose_info('30 iterations => cancel',1);
            break;
        end
        
    end
    
% %    % estimate late rev time according ISO 3382 (without 10 db offset above noise)
% %    % 8) estimate late decay slope
% %         startIdx = find(10*log10(timeWinData(idxMax:end)) < 10*log10(noiseEst)+ 0 + 10, 1, 'first') + idxMax - 1;
% %         if isempty(startIdx)
% %             startIdx = 1;
% %         end
% %         stopIdx  = find(10*log10(timeWinData(startIdx+1:end)) < 10*log10(noiseEst)+ 0, 1, 'first')           + startIdx;
% %         if isempty(stopIdx)
% %             ita_verbose_info('Regression did not work due to low SNR, continuing with next channel/band',1);
% %             break;
% %         end
% %         X = [ones(stopIdx-startIdx+1,1) timeVecWin(startIdx:stopIdx)]; % X*c = edc
% %         linRegRes = X\(10*log10(timeWinData(startIdx:stopIdx)));
% %         revT(iChannel)             = -60/linRegRes(2);

    revT(iChannel)             = -60/c(2);
    noiseLevel(iChannel)       = 10*log10(noiseEst);
    intersectionTime(iChannel) = crossingPoint;
    
    noisePeakLevel(iChannel)   =  10*log10(max(timeWinData(min(idxLast10percent,idx10dBBelowCrosspoint ):end,:)));
    
    
     %     ita_verbose_info(['end after ' num2str(loopCounter) ' iterations'],1)
    % plot
    if sArgs.plot
        subplot(subplotSize(1), subplotSize(2), iChannel)
        plot(input.timeVector(1:nSamples(iChannel)), 10*log10(abs(rawTimeData(1:nSamples(iChannel),iChannel))), 'color', [.7 .7 1])                          % rawdata
        title(sprintf(' %2.0fHz (SNR %2.1fdB, T: %1.2f s)', freqVec(iChannel), 10*log10(max(abs(rawTimeData(:,iChannel)))/noiseEst), revT(iChannel) ))
        hold all
        plot([0 (10*log10(noiseEst)-40-c(1)) / c(2) ], [c(1) 10*log10(noiseEst)-40],'linewidth', 3 );               % EDC line
        plot(timeVecWin, 10*log10(timeWinData ),'o-', 'linewidth', 2)                                                    % smoothed data
        scatter(timeVecWin([startIdx stopIdx]), 10*log10(timeWinData([startIdx stopIdx])) , 'filled')               % limits for regression
        %         axLimit = [0 input.trackLength 10*log10(noiseEst)-30 max(10*log10(abs(rawTimeData(:,iChannel))))+20 ];%
%         axLimit = [0 crossingPoint *1.2 10*log10(noiseEst)-30 max(10*log10(abs(rawTimeData(:,iChannel))))+20 ];%
        axLimit = [0 max(crossingPoint *1.2,input.timeVector(nSamples(iChannel))) 10*log10(noiseEst)-30 max(10*log10(abs(rawTimeData(:,iChannel))))+20 ];%
        plot(axLimit(1:2), [1 1]*10*log10(noiseEst), 'linewidth', 2)                                                % noise line
        plot([1 1]*crossingPoint, axLimit(3:4), 'linewidth', 2)                                                     % intersection time
        
        if all(isnan(axLimit))
            axis(axLimit)
        end
        hold off
%         ita_legend({'IR' 'reverberation slope' 'envelope','late rev eval interval', 'noise level estimation', 'intersection time'})
    end
end


resultDummy             = itaResult(freqVec(:), freqVec, 'freq');
resultDummy.comment     = input.comment;
resultDummy.channelNames = input.channelNames;
resultDummy.channelCoordinates = input.channelCoordinates;

result                  = resultDummy;
result.allowDBPlot      = false;
result.freqData         = revT ;
result.channelUnits(:)  = {'s'};
result.comment          = [input.comment ' -> T (Lundeby)'];


%% Set Output
varargout(1) = {result};

if nargout >= 2
    psnr = resultDummy;
    psnr.freqData  = sqrt(max(rawTimeData).') ./ 10.^(noiseLevel/20) ;
    psnr.comment          = [input.comment ' -> Peak SNR (Lundeby)'];
    psnr.channelUnits(:) = {''};
    varargout(2) = {psnr};
end
if nargout >= 3
    
    iTime = resultDummy;
    iTime.freqData  = intersectionTime -  timeShifted(:);
    iTime.channelUnits(:)  = {'s'};
    iTime.comment          = [input.comment ' -> Intersection Time (Lundeby)'];
    
    varargout(3) = {iTime};
end

if nargout >= 4
    noise = resultDummy;
    noise.freqData   = 10.^(noiseLevel/20) ;
    noise.comment          = [input.comment ' -> NoiseEstimation (Lundeby)'];
    noise.channelUnits(:)  = {'Pa'};
    varargout(4) = {noise};
end



if nargout >= 5
    pspnr = resultDummy;
    pspnr.freqData   = sqrt(max(rawTimeData).') ./ 10.^(noisePeakLevel /20) ;
    pspnr.comment          = [input.comment ' -> Peak Signal to Peak Noise Ratio(Lundeby)'];
    pspnr.channelUnits(:)  = {''};
    varargout(5) = {pspnr};
end


%end function
end
