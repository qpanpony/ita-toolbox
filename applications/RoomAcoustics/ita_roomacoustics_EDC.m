function varargout = ita_roomacoustics_EDC(varargin)
%ITA_ROOMACOUSTICS_EDC - calculate reverse-time integrated impulse response
%  This function calculates the schroeder curve (energy decay curve, EDC) of a given room impulse
%  response (RIR) by using a backward integration. Dependent on the chosen method the integration
%  limits are set and whether a correction is used or not.
%
%  Syntax:
%   EDCs = ita_roomacoustics_EDC(inputIR, options)
%
%   Options (default):
%           'method' ('cutWithCorrection') :
%                                      'cutWithCorrection'   : truncate impulse response according to given intersection time and apply correction (accorrding ISO 3382-1:2009)
%                                      'justCut'             : truncate impulse response according to given intersection time
%                                      'noCut'               : take whole imulse response for EDC calculation
%                                      'subtractNoise'       : subtract noise estimation  from impulse response
%                                      'unknownNoise'        : apply moving average window with width T/5 (according (old) ISO 3382:2000 )
%
%           'intersectionTime' ()         : itersection times for all input channels as itaResult (for methods 'cutWithCorrection' and 'justCut')
%           'normTo0dB' (true)            : EDC starts at 0 dB
%
%  Examples:
%   EDCs = ita_roomacoustics_EDC(RIR, 'method','noCut')
%   EDCs = ita_roomacoustics_EDC(myRIR, 'method', 'unknownNoise')

%   EDCs = ita_roomacoustics_EDC(RIR, 'intersectionTime', iTimes)
%
%  See also:
%   ita_roomacoustics
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_roomacoustics_EDC">doc ita_roomacoustics_EDC</a>

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  05-Aug-2011

% andere methoden
% - 'noCutWithCorrection': falls IR kuerzer als intersectiontime, noch nicht getestet


%% Input Parsing
sArgs         = struct('pos1_data','itaAudio', 'method', 'cutWithCorrection', 'intersectionTime', 'itaResult', 'lateRevEstimation', 'itaResult', 'noiseRMS',  'itaResult', 'normTo0dB', true, 'plot', false ,'calcCenterTime', false, 'inputIsSquared', false);
[input,sArgs] = ita_parse_arguments(sArgs,varargin);

% check if method is known
possibleMethods = {'noCut' 'justCut' 'cutWithCorrection' 'subtractNoise' 'subtractNoiseAndCutWithCorrection' 'unknownNoise' 'noCutWithCorrection' };
if ~any(strcmpi(possibleMethods, sArgs.method))
    helpStr = possibleMethods{1};
    for iMethod = 2:numel(possibleMethods), helpStr = [ helpStr ', ' possibleMethods{iMethod}]; end
    error('ita_roomacoustics_edc: unknown edc method %s (possible methods are: %s)',sArgs.method, upper(helpStr) )
end
nChannels = input.nChannels;



% center time
if sArgs.calcCenterTime
    centerTimeMat = zeros(nChannels,1);
else
    centerTimeMat = [];
end

%% set calculation parameters for edc methods
calcLateRevTime                         = false;
takeNoiseLevelForIntersectionPressure   = true;
subtractNoiseEnergyFromIR               = false;

switch lower(sArgs.method)
    case 'nocut'
        cutIR         = false;
        correctForCut = false;
        
    case 'justcut'
        cutIR           = true;
        correctForCut   = false;
        sArgs = checkLundebyResults(sArgs, input.nChannels);
        
    case 'cutwithcorrection'
        cutIR         = true;
        correctForCut = true;
        sArgs = checkLundebyResults(sArgs, input.nChannels);
        
    case 'subtractnoise'
        cutIR                     = false;
        correctForCut             = false;
        subtractNoiseEnergyFromIR = true;
        sArgs = checkLundebyResults(sArgs, input.nChannels);
        
    case 'subtractnoiseandcutwithcorrection'
        cutIR                     = true;
        correctForCut             = true;
        subtractNoiseEnergyFromIR = true;
        sArgs = checkLundebyResults(sArgs, input.nChannels);
        
    case 'unknownnoise'
        cutIR         = false;
        correctForCut = false;
        
    case 'nocutwithcorrection'
        cutIR                                 = false;
        correctForCut                         = true;
        calcLateRevTime                       = true;
        takeNoiseLevelForIntersectionPressure = false;
        sArgs = checkLundebyResults(sArgs, input.nChannels);
        
    otherwise
        error('unkown parameter for edc method: %s' , sArgs.method)
        
end




% plot parameters
if sArgs.plot
    figure
    subplotSize = [ceil(sqrt(nChannels)) round(sqrt(nChannels)) ];
    envelope = ita_envelope(input);
    envelopeEnergyData =  envelope.timeData.^2;
end

smoothBlockLength = 0.075; % in sec  (used for noise estimation)  TODO: frequency dependent?

%%
nSamples     = input.nSamples;
if sArgs.inputIsSquared
    energyData   = input.timeData;
else
    energyData   = input.timeData.^2;
end
samplingRate = input.samplingRate;
timeVector   = input.timeVector;

if mean(abs(imag(energyData(:)))) > 1e-19
    ita_verbose_info('complex energy values? ',0)
else
    energyData = real(energyData);   % delete numerical noise
end

EDCmat = nan(nSamples, input.nChannels); % what is better nans, zeros or realmin (plot, calc, find ...)
C = 0;

if strcmpi(sArgs.method, 'unknownNoise')  % old ISO method for unknown noises
    for iChannel = 1:input.nChannels
        
        % first estimation of T0 is EDT
        EDC          = flipud(cumsum(energyData(end:-1:1,iChannel)));
        idxMinus10dB = find(EDC < EDC(1)/10, 1, 'first');
        coeff = [timeVector(1:idxMinus10dB)*0+1 timeVector(1:idxMinus10dB)] \ (10*log10(EDC(1:idxMinus10dB)));
        T0 = -60 / coeff(2);
        
        T0_last = 0;
        loopCounter = 0;
        
        % iteration
        while abs(T0_last-T0) / T0*100 > 25
            loopCounter = loopCounter +1;
            if loopCounter > 100
                ita_verbose_info('Cancel iteration after 100 loops', 0)
                break
            end
            
            nSamplesWin = round(T0/5 * samplingRate);
            T0_last = T0;
            
            EDC = conv(energyData(:,iChannel), rectwin(nSamplesWin));
            EDC = EDC(nSamplesWin:end);
            idxMinus10dB = find(EDC < EDC(1)/10, 1, 'first');
            coeff   = [timeVector(1:idxMinus10dB)*0+1 timeVector(1:idxMinus10dB)] \ (10*log10(EDC(1:idxMinus10dB)));
            T0      = -60 / coeff(2);
            
        end
        EDCmat(:, iChannel)   = EDC;
        
        if sArgs.calcCenterTime
            ita_verbose_info('No center time avaiable for EDCmethod ''unknownNoise'' !', 0)
            centerTimeMat(iChannel) = nan;
            %             centerTimeMat(iChannel) = sum(energyData(1:nSamplesWin,iChannel) .* timeVector(1:nSamplesWin)) / EDCmat(1,iChannel)
        end
        
    end
else        % all other methods
    
    if ~cutIR % use full signal, no cut
        t1IdxRaw = nSamples;
        t1 = input.trackLength;
    end
    
    for iChannel = 1:input.nChannels
        
        % cut impulse response at intersection time
        if cutIR
            t1              = sArgs.intersectionTime.freqData(iChannel);
            [del t1IdxRaw]  = min(abs(timeVector- t1));
        end
        
        % calculate smoothed ir data
        if ~takeNoiseLevelForIntersectionPressure || calcLateRevTime
            % smooth data TODO: try moving max window
            nSamplesPerBlock = round( smoothBlockLength * input.samplingRate);
            timeWinData      = sum(reshape(energyData(1:floor(nSamples/nSamplesPerBlock)*nSamplesPerBlock,iChannel), nSamplesPerBlock, floor(nSamples/nSamplesPerBlock) ,1),1).' / nSamplesPerBlock;
            timeVecWin       = (0.5+(0:size(timeWinData,1)-1)).'*nSamplesPerBlock/input.samplingRate; %TODO: outside loop!
            
            %          figure; plot(timeVector, (energyData)); hold all; plot(timeVecWin, (timeWinData), 'o-'); hold off; grid; xlim([0.2 0.5])
            [del t1idx]         = min( abs(timeVecWin - t1));
            %             pSquareAtIntersection = interp1(timeVecWin(max(t1idx-1,1):min(t1idx+1,end)), timeWinData(max(t1idx-1,1):min(t1idx+1,end)), t1) / engergyCorr;        % TODO: faster without using interp1 ?!?
        end
        
        if correctForCut || subtractNoiseEnergyFromIR   % calc pressure at intersection time
            if takeNoiseLevelForIntersectionPressure
                pSquareAtIntersection = sArgs.noiseRMS.freqData(iChannel).^2;
            else % RIR already cut, take last values to estimate  noise level
                
                pSquareAtIntersection =  timeWinData(t1idx);
                
% %                 % calculate ir level at intersectioin time
% %                 % interpolate on dB data (divide by 2 because noise and RIR have same pressure engery at intersection time)
% %                 pSquareAtIntersection = 10^(interp1(timeVecWin(max(t1idx-1,1):min(t1idx+1,end)), 10*log10(timeWinData(max(t1idx-1,1):min(t1idx+1,end))), t1,'linear', 'extrap') / 10) / 2;        % TODO: faster without using interp1 ?!?
            end
        else
            pSquareAtIntersection  = 0;
        end
        if correctForCut
            if calcLateRevTime
                t0idx               = find(abs(timeWinData(1:t1idx)) > 10 * pSquareAtIntersection,1, 'last');     % 10 dB above pSquareAtIntersection
                if isempty(t0idx)
                    t0idx = 1;
                end
                
                % regression ueber letzten 10 dB vor noise
                % regression on raw data
%                 [del t0IdxRaw]      = min(abs(timeVector-timeVecWin(t0idx)));
%                 X                   = [timeVector(t0IdxRaw:t1IdxRaw).^0 timeVector(t0IdxRaw:t1IdxRaw)];
%                 coeff               = X\(10*log10(abs(energyData(t0IdxRaw:t1IdxRaw, iChannel))));               %calculate regression TODO: check if abs(9 ist best for hirata data
%                 TofLast10dB         = -60./coeff(2) ;
                
                % regression on smoothed data
                X                   = [timeVecWin(t0idx:t1idx).^0 timeVecWin(t0idx:t1idx)];
                coeff               = X\(10*log10(abs(timeWinData(t0idx:t1idx))));               %calculate regression TODO: check if abs(9 ist best for hirata data
                TofLast10dB         = -60./coeff(2) ;
                
                
                
                
%                figure; plot(timeVector(t0IdxRaw:t1IdxRaw), 10*log10(abs(energyData(t0IdxRaw:t1IdxRaw, iChannel))))
               
                if sArgs.plot
                    
                    [del t0IdxRaw]      = min(abs(timeVector-timeVecWin(t0idx)));
                    subplot(subplotSize(1), subplotSize(2), iChannel)
                    plot(timeVector, 10*log10(energyData(:,iChannel)));
                    hold all;
                    plot(timeVector(t0IdxRaw:t1IdxRaw), 10*log10(energyData(t0IdxRaw:t1IdxRaw,iChannel)));
                    plot(timeVecWin,                    10*log10(timeWinData), 'o-');
                    plot(timeVector, 10*log10(envelopeEnergyData(:,iChannel)));
                    
                    %                 axLimits = axis;
                    axLimits = [[t0IdxRaw t1IdxRaw]/input.samplingRate+[-0.5 +0.5]  10*log10(min(energyData(t0IdxRaw:t1IdxRaw,iChannel)))-10 10*log10(max(energyData(t0IdxRaw:t1IdxRaw,iChannel)))+30];
                    axis([max(0,axLimits(1)), axLimits(2:4)])
                    %                 ylim([-350 -100])
                    hold off; grid on;
                    
                end
                
                if TofLast10dB < 0 || TofLast10dB > 20 || isnan(TofLast10dB) || isnan(pSquareAtIntersection)
                    TofLast10dB = 0;
                    pSquareAtIntersection = 0;
                    ita_verbose_info(['Estimation of late reverberation time failed (maybe noisedetect wasn''t correct). No correction of schroeder curve! (Ch ' num2str(iChannel) ')'], 1);
                end
                
            else % take result from lundeby alorithm
                TofLast10dB = sArgs.lateRevEstimation.freqData(iChannel);
            end
            
            
            % calculate correction C according to DIN EN ISO 3382
            C = pSquareAtIntersection * TofLast10dB/ (6*log(10)) * input.samplingRate; % sum() * samplingRate = integral
        end
        
        
        if subtractNoiseEnergyFromIR
            energyData(:,iChannel) = energyData(:,iChannel) - pSquareAtIntersection;
        end
        
        % backwards integration
        EDC                            = cumsum(energyData(t1IdxRaw:-1:1,iChannel));
        EDCmat(1:t1IdxRaw, iChannel)   = EDC(end:-1:1,:) + C ;
        
        
        % set all EDC values below zero (due to noise subtraction) to NaN
        if subtractNoiseEnergyFromIR
            
            edcNegativeIdx = find(EDCmat(1:t1IdxRaw, iChannel) - C <= 0, 1, 'first');
            
            if ~isempty(edcNegativeIdx)
                EDCmat(edcNegativeIdx:t1IdxRaw, iChannel) = NaN;
            end
        end
        
        
        if sArgs.calcCenterTime
            numerator  = sum(energyData(1:t1IdxRaw, iChannel) .* timeVector(1:t1IdxRaw)) + C^2 + C * pSquareAtIntersection * t1;
            centerTimeMat(iChannel) = numerator / EDCmat(1, iChannel);
        end
    end
end


data = input;
if sArgs.normTo0dB
    data.timeData = bsxfun(@rdivide, EDCmat, EDCmat(1,:));
else
    data.timeData = EDCmat / data.samplingRate; %pdi:bugfix: scaling
end

% ste meta data
data.channelUnits(:) = {'Pa^2'}; % not correct, just to ensure 10 log plotting

%% Set Output
varargout(1) = {data};

if nargout >= 2
    varargout{2} = centerTimeMat;
end

%end function
end


% check if input lundeby result are okay
function sArgs = checkLundebyResults(sArgs, nInputChannels)

lundebyPar = {'intersectionTime' 'lateRevEstimation' 'noiseRMS'};

% if no lundeby parameters specified => calc
if all([ischar(sArgs.(lundebyPar{1})), ischar(sArgs.(lundebyPar{2})),  ischar(sArgs.(lundebyPar{3}))])
    ita_verbose_info('no lundeby parameter for noise compensation specified. calling ita_roomachoustics_lundeby',0)
    [sArgs.lateRevEstimation, ~, sArgs.intersectionTime, sArgs.noiseRMS, ~] = ita_roomacoustics_reverberation_time_lundeby(sArgs.data ,'broadbandanalysis');
    
    
else % check if input is correct
    
    
    for iPar = 1:numel(lundebyPar)
        
        if isa(sArgs.(lundebyPar{iPar}), 'itaResult')
            if sArgs.(lundebyPar{iPar}).nBins ~= nInputChannels
                error('%i input channels but %i intersection times!',nInputChannels, sArgs.(lundebyPar{iPar}).nBins )
            end
        elseif strcmpi(lundebyPar{iPar}, 'intersectionTime')
            error('Method %s needs %s or late reverberation time (itaResult) as input parameter', upper(sArgs.method), lundebyPar{iPar})
        end
    end
    
end
end
