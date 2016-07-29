function varargout = ita_soundInsulationIndexAirborne(varargin)
% ita_soundInsulationIndexAirborne - sound insulation acc. to ISO 717-1

% <ITA-Toolbox>
% This file is part of the application BuildingAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% input parsing
sArgs = struct('pos1_data','anything','bandsperoctave',3,'freqVector',[],'createPlot',false);
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% additional parameters
if sArgs.bandsperoctave == 3
    refSurf = 32;
elseif sArgs.bandsperoctave == 1
    refSurf = 10;
else
    error([upper(mfilename) ':wrong input for badnsperoctave']);
end
refFreq = 500;

%% reference curves
if sArgs.bandsperoctave == 1
    refCurve = [36 45 52 55 56]; % Reference curve according to ISO 717-1
    freq = [125 250 500 1000 2000]; % Frequencies according to ISO 717-1
    lFreq = length(refCurve);
else
    freq = [100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150]; % Frequencies according to ISO 717-1
    refCurve = [33 36 39 42 45 48 51 52 53 54 55 56 56 56 56 56]; % Reference curve according to ISO 717-1
    lFreq = length(refCurve);
end

%% prepare data
msgExtrap = 'Sound insulation data will be extrapolated';
if isa(data,'itaSuper')
    freqVector = data.freqVector;
    soundInsulation = 20.*log10(interp1(freqVector,data.freqData(:,1),freq,'spline','extrap'));
else
    freqVector = sArgs.freqVector;
    if ~isempty(freqVector)
        soundInsulation = interp1(freqVector,data,freq,'spline','extrap');  % not in dB?!?
    else
        error([upper(mfilename) ':not enough input data']);
    end
end

if isempty(find(freqVector <= freq(1),1,'first')) || isempty(find(freqVector >= freq(end),1,'first'))
    warning(upper(mfilename),msgExtrap);
end

%% sound insulation index
soundInsulation = round(soundInsulation*10)/10;
delta = refCurve-soundInsulation;
soundInsulationIndexTest = sum(delta(delta>0));
counter = 0; % stopping criterion
% shift reference curve until 32dB is reached

Diff = 0;
while abs(soundInsulationIndexTest -refSurf)>1 && counter < 1e6
    if counter == 0 % Anpassung der refTerzkurve
        Diff = round(mean(delta)*10)/10;
    elseif sum(soundInsulationIndexTest) < refSurf-1
        Diff = Diff+0.1;
    else
        Diff = Diff-0.1;
    end
    
    delta = (refCurve+Diff)- soundInsulation;
    soundInsulationIndexTest = sum(delta(delta>0));
    
    counter = counter+1;
end

soundInsulationIndex = round((refCurve(freq == refFreq)+Diff)*100)/100;

%% output
if sArgs.createPlot
    plotResult = itaResult;
    plotResult.freqVector = freq;
    plotResult.freqData(:,1) = 10.^((refCurve+Diff)./20);
    plotResult.freqData(:,3) = 10.^(soundInsulation./20);
    plotResult.freqData(:,2) = ones(lFreq,1)*10.^(soundInsulationIndex./20);
    
    plotResult.channelNames{3} = 'sound insulation';
    plotResult.channelNames{1} = 'shifted reference curve';
    plotResult.channelNames{2} = ['R_W = ' num2str(soundInsulationIndex) 'dB'];
    
    plotResult.plot_freq;
    xlim([min(freq) max(freq)]);
end

varargout{1} = soundInsulationIndex;
% reference curve specified at the freqVector specified by the input itaResult:
if nargout == 2
    varargout{2} = interp1(freq, 10.^((refCurve+Diff)./20), freqVector, 'linear'); 
end
