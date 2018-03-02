function varargout = ita_loudspeakertools_maxSPL(varargin)
% ita_loudspeakertools_maxSPL - Calculate the MaxSPL, THD, THDN, THD_F and HD's with noise of a
% distorted signal for a loudspeaker
% This function processes a measurement of MaxSPL and various distortion values (calling ita_loudspeakertools_distortions) of a loudspeaker.
% Therefore it uses the stepped-sine method in which for each excitation frequency a sine is generated.
% This sine is played back by the loudspeaker and recorded afterwards. After
% each measurement step for one frequency the algorithm looks if either the
% THD-value has reached the specified maximum or the specified maximal
% amp-power was reached.
%
% As you can see the THD, THDN and THD_F just distinguish between their
% reference:
%
% harmonicComponents = sqrt(sum(abs(harm(2:end)).^2))
% THD   =     harmonicComponents   /sqrt(sum(abs(harm(1:end)).^2));
% THD_F =     harmonicComponents   /sqrt(abs(harm(1))^2);
% THDN  =     harmonicComponents   /distortedSine.rms;
%
% Syntax: vector = ita_loudspeakertools_maxSPL(inputMC,outputMC,options);
%
% Options (default):
%   'bandsPerOctave' (3)                                :        3=1/3 octave bands, 12=1/12 octave bands
%   'powerRange' ([0.02 5])                             :        start and stop power (stop criterion!) for the amp in Watts
%   'powerIncrement' (2)                                :        increase amp power by this value in dB - the increment additionaly get scaled according to the current distortion and the distortion limit to be reached
%   'nHarmonics' (4)                                    :        number of harmonics to calculate, including the fundamental wave at first
%   'signalReference' ('THDN')                          :        'THD', 'THDN','THD_F';
%                                                                stop if this value has reached the distortionLimit
%   'distortionLimit' ([3 5 10])                        :        stop at this percentage (stop criterion!)
%   'tolerance' (0.05)                                  :        tolerance range for the reference value
%   'nominalLoudspeakerImpedance' (8)                   :        Nominal Loudspeaker Impedance in Ohm
%   'windowSamples' ([])                                :        number of samples at the begin and the end of the excitation sine for
%                                                                window fade-in/fade-out
%   'pauseConst'   (5)                                  :        here you can specify the pause length between
%                                                                power increments. It will be ampVoltage/pauseConst
%
% stop criteria are: maxTHD and powerRange(2).
%
% Stepped Sine method: returns a vector with maximal SPL, n first HD's with
% noise and THD corresponding to the maximal SPL (over the frequency:'third' or 'octave').
%
% Examples:
%   [maxSPL THD THDN THD_F HD excitationFrequencies exceptionMatrix gain] = ita_loudspeakertools_maxSPL(MS,'win_nSamples',10,'powerRange',[0.02 20],'powerIncrement',3,'nHarmonics',8);
%
% NOTE: for the calculation of the THD for a specific amplitude, just give the same begin and end amplitude
%
%   See also
%       ita_loudspeakertools_distortions
%
% Author: Christian Haar -- christian.haar@akustik.rwth-aachen.de
% Created: May-2011

% Update to new measurement setup structure in 2014
% MMT -- mmt@akustik.rwth-aachen.de

% updated to adaptive measurement with multiple distortions limits at once
% Dec - 2014 -- Marco Berzborn -- marco.berzborn@akustik.rwth-aaachen.de

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Initialization and Input Parsing
sArgs = struct('pos1_MS','itaMSPlaybackRecord','bandsPerOctave',3,'powerRange',[0.02 5],'powerIncrement',2,'nHarmonics',4,'signalReference','THDN', ...
               'distortionLimit',[3 5 10],'tolerance',0.05,'nominalLoudspeakerImpedance',8,'windowSamples',[],'pauseConst',5);
[MS,sArgs] = ita_parse_arguments(sArgs,varargin);

% Find the excitation frequencies
excitationFreq = ita_ANSI_center_frequencies(MS.freqRange, sArgs.bandsPerOctave);

max_spl         = zeros(numel(excitationFreq),numel(sArgs.distortionLimit));     % Max SPL values for the specified maximal THD
max_voltage     = zeros(numel(excitationFreq),numel(sArgs.distortionLimit));     % Max voltage for MAX SPL
THD             = zeros(numel(excitationFreq),numel(sArgs.distortionLimit));     % THD values
THDN            = zeros(numel(excitationFreq),numel(sArgs.distortionLimit));     % THDN values
THD_F           = zeros(numel(excitationFreq),numel(sArgs.distortionLimit));     % THD_F values
HD              = cell(numel(excitationFreq),numel(sArgs.distortionLimit));     % HD values

exceptionMatrix = cell(numel(excitationFreq),numel(sArgs.distortionLimit));

outputVoltageRange  = sqrt(sArgs.powerRange.*sArgs.nominalLoudspeakerImpedance);
voltageFirstDistortionLimit = outputVoltageRange(1);

lastMeasurement = false;
breakFlag = false;
gainMatrix = ones(numel(excitationFreq),numel(sArgs.distortionLimit));

% distortion limits not in percent!
sArgs.distortionLimit = sArgs.distortionLimit / 100;

% calculate absolute tolerance values for the maximum distortion
upperTolVal = sArgs.distortionLimit * (1+sArgs.tolerance);
lowerTolVal = sArgs.distortionLimit * (1-sArgs.tolerance);

%% go through the excitation frequencies, process measurement
ita_verbose_info('Measurement process',1);
wb = itaWaitbar([numel(excitationFreq),numel(sArgs.distortionLimit)],'maxSPL',{'Frequencies','Limits'});
% frequency band loop with freqIdx
for freqIdx = 1:numel(excitationFreq)
    
    if freqIdx > 1 
        % if it's not the first excitation frequency, do not begin with too low power
        outputVoltage = max(voltageFirstDistortionLimit*0.95, outputVoltageRange(1));
    else
        outputVoltage = outputVoltageRange(1);
    end

    % distortion limit loop
    for distIdx = 1:numel(sArgs.distortionLimit)
        currentPowerIncrement = sArgs.powerIncrement;
        distIter = 0;
        wb.inc
        % Amplification and measurement
        while outputVoltage >= (outputVoltageRange(1)/10) && outputVoltage <= outputVoltageRange(2)
            distIter = distIter + 1;
            if distIter == 10 % too many iterations going back and forth
                currentPowerIncrement = sArgs.powerIncrement/2;
            end
            lastSignalReferenceValue = eval([sArgs.signalReference '(freqIdx,distIdx)']);

            try
                [uSPL, thd, thdn, thd_f, hd] = ita_loudspeakertools_distortions(MS,outputVoltage,'excitationFreq',excitationFreq(freqIdx),'nHarmonics',sArgs.nHarmonics,'windowSamples',sArgs.windowSamples);
            catch theException
                ita_verbose_info(theException.message);
                exceptionMatrix{freqIdx,distIdx} = theException;
                break
            end
            THD(freqIdx,distIdx) = thd;
            THDN(freqIdx,distIdx) = thdn;
            THD_F(freqIdx,distIdx) = thd_f;
            HD{freqIdx,distIdx} = hd(:);

            max_spl(freqIdx,distIdx) = abs(uSPL); % Max SPL values (will be overwritten until limit is reached)
            max_voltage(freqIdx,distIdx) = outputVoltage;

            % Value of the current signal reference at the current sine
            % frequency
            signalReferenceValue = eval([sArgs.signalReference '(freqIdx,distIdx)']);

            % logical values for if conditions
            inTol = (signalReferenceValue >= lowerTolVal(distIdx)) & (signalReferenceValue <= upperTolVal(distIdx));
            aboveTol = signalReferenceValue > upperTolVal(distIdx);
            belowTol = signalReferenceValue < lowerTolVal(distIdx);

            if lastSignalReferenceValue == 0
                % this may be the first measurement
                gain = 10^(currentPowerIncrement/20);
            else
                % use logarithm to attenuate high gain values
                % gain = (log((abs(signalReferenceValue)/lastSignalReferenceValue + exp(1)))) * 10^(currentPowerIncrement/20);
                gain = log((abs(signalReferenceValue-sArgs.distortionLimit(distIdx))/signalReferenceValue + exp(1))) * 10^(currentPowerIncrement/20);
            end
            
            gainMatrix(freqIdx,distIdx) = gain;

            % Have we reached the distortion limit which is to be found?
            if inTol
                % distortion limit reached -> measure next distortion limit
                if distIdx == 1
                    % store voltage at fist limit for the starting voltage
                    % the next frequency
                    voltageFirstDistortionLimit = outputVoltage;
                end
                ita_verbose_info([num2str(sArgs.distortionLimit(distIdx)*100) '% ' sArgs.signalReference ' reached, exact value: ' num2str(signalReferenceValue*100,'%0.2f') '%'],0);
                outputVoltage = outputVoltage * gain;
                break;
                
            elseif aboveTol
                % went above limit -> decrement and show info
                ita_verbose_info([num2str(sArgs.distortionLimit(distIdx)*100) '% ' sArgs.signalReference ' too high, exact value: ' num2str(signalReferenceValue*100,'%0.2f') '%'],0);
                % factor to avoid getting stuck
                outputVoltage = outputVoltage / (ceil((10^(-currentPowerIncrement/20))/0.1)*0.1*gain);
            elseif belowTol
                % keep increasing
                outputVoltage = outputVoltage * gain;
                ita_verbose_info([num2str(sArgs.distortionLimit(distIdx)*100) '% ' sArgs.signalReference ' not reached, exact value: ' num2str(signalReferenceValue*100,'%0.2f') '%'],0);
            end
            
            if outputVoltage > outputVoltageRange(2)
                if ~lastMeasurement
                    outputVoltage = outputVoltageRange(2);
                    lastMeasurement = true;
                else
                    ita_verbose_info(['maximum output voltage reached: ' num2str(min(outputVoltage,outputVoltageRange(2)),'%0.2f')],0); % show some info
                    
                    % write remaining distortion limit values in case we
                    % reached the maximum voltage at a lower distortion
                    % limit
                    THD(freqIdx,distIdx:numel(sArgs.distortionLimit)) = thd;
                    THDN(freqIdx,distIdx:numel(sArgs.distortionLimit)) = thdn;
                    THD_F(freqIdx,distIdx:numel(sArgs.distortionLimit)) = thd_f;
                    for idxSort = distIdx:numel(sArgs.distortionLimit)
                        HD{freqIdx,idxSort} = hd(:);
                    end

                    max_spl(freqIdx,distIdx:numel(sArgs.distortionLimit)) = abs(uSPL);
                    % divide by gain as the voltage has been increased 
                    % since the measuremen has been carried out
                    max_voltage(freqIdx,distIdx:numel(sArgs.distortionLimit)) = outputVoltageRange(2);
                    
                    lastMeasurement = false;
                    
                    % breakFlag to break out of of distIdx for loop
                    breakFlag = true;
                    break;
                end
            else
                %Waiting
                time = outputVoltage/sArgs.pauseConst;      % Time in seconds
                pause(time);                                % Waiting for a cooling of the LS
            end
        end
        if breakFlag
            breakFlag = false;
            for iter = distIdx+1:numel(sArgs.distortionLimit)
                wb.inc();
            end
            break;
        end  
    end
end
wb.close;
%% Post-processing and Results

% Max SPL will be returned as an itaResult
res_maxSPL = itaResult([max_spl,max_voltage],excitationFreq.','freq');
res_maxSPL.channelUnits(1:numel(sArgs.distortionLimit)) = {'Pa'};
res_maxSPL.channelUnits(numel(sArgs.distortionLimit)+1:numel(sArgs.distortionLimit)) = {'V'};

THD = itaResult(THD,excitationFreq.','freq');
THDN = itaResult(THDN,excitationFreq.','freq');
THD_F = itaResult(THD_F,excitationFreq.','freq');

gain = itaResult(gainMatrix,excitationFreq.','freq');

for distIdx=1:numel(sArgs.distortionLimit)
    res_maxSPL.channelNames{distIdx} = ['Max SPL for ' sArgs.signalReference ' of ' num2str(100*sArgs.distortionLimit(distIdx)) ' percent'];
    res_maxSPL.channelNames{distIdx+numel(sArgs.distortionLimit)} = ['Voltage for ' sArgs.signalReference ' of ' num2str(100*sArgs.distortionLimit(distIdx)) ' percent'];
    THD.channelNames{distIdx} = ['THD at limit ',num2str(distIdx) ,' (',num2str(100*sArgs.distortionLimit(distIdx)),' percent)'];
    THDN.channelNames{distIdx} = ['THDN at limit ',num2str(distIdx) ,' (',num2str(100*sArgs.distortionLimit(distIdx)),' percent)'];
    THD_F.channelNames{distIdx} = ['THD_F at limit ',num2str(distIdx) ,' (',num2str(100*sArgs.distortionLimit(distIdx)),' precent)'];
    gain.channelNames{distIdx} = ['gain at limit ',num2str(distIdx) ,' (',num2str(100*sArgs.distortionLimit(distIdx)),' precent)'];
end
varargout{1} = res_maxSPL;

varargout{2} = THD;             % THD
varargout{3} = THDN;            % THDN
varargout{4} = THD_F;           % THD_F
varargout{5} = HD;              % HD for each harmonic
varargout{6} = excitationFreq;  % excitation frequencies
varargout{7} = exceptionMatrix; % exceptions in case of error during measurement runtime
varargout{8} = gain;            % gains at each distortion Limit


end % function