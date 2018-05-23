function varargout = ita_soundInsulationIndexImpact(varargin)
% ita_soundInsulationIndexAirborne - sound insulation acc. to ISO 717-2 or ASTM E989

% <ITA-Toolbox>
% This file is part of the application BuildingAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% re-implementation: Markus Mueller-Trapet (markus.mueller-trapet@nrc.ca)
% Date: March 2018

%% input parsing
sArgs = struct('pos1_data','anything','bandsperoctave',3,'freqVector',[],'createPlot',false,'type','ISO');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% reference curves
if strcmpi(sArgs.type,'iso') % Reference curve and frequencies according to ISO 717-2
    outputStr = 'Ln_w (C_I)';
    roundingFactor = 0.1;
    deficiencyLimit = Inf;
    if sArgs.bandsperoctave == 1
        freq = [125 250 500 1000 2000];
        refSurf = 10;
        refCurve = [67 67 65 62 49].'-60;
    elseif sArgs.bandsperoctave == 3
        freq = [100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150].';
        refSurf = 32;
        refCurve = [62 62 62 62 62 62 61 60 59 58 57 54 51 48 45 42].'-60;
    else
        error([upper(mfilename) ':wrong input for bandsperoctave']);
    end
elseif strcmpi(sArgs.type,'astm') % Reference curve and frequencies according to ASTM E989
    outputStr = 'IIC';
    roundingFactor = 1;
    deficiencyLimit = 8;
    sArgs.bandsperoctave = 3;
    freq = [100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150].';
    refCurve = [2 2 2 2 2 2 1 0 -1 -2 -3 -6 -9 -12 -15 -18].';
    refSurf = 32;
else
    error([upper(mfilename) ':wrong input for type']);
end
dbStep = 1;

%% prepare data
if ~isa(data,'itaSuper')
    freqVector = sArgs.freqVector;
    if ~isempty(freqVector)
        data = itaResult(10.^(data(:)./20),freqVector(:),'freq');
    else
        error([upper(mfilename) ':not enough input data']);
    end
end
freqVector = data.freqVector;
NISPL = 20.*log10(interp1(freqVector,data.freqData(:,1),freq,'spline','extrap')) + 94;

if min(freqVector) > freq(1) || max(freqVector) < freq(end)
    warning([upper(mfilename) ': Sound insulation data will be extrapolated']);
end

%% sound insulation index
NISPL = round(NISPL/roundingFactor)*roundingFactor;
impactInsulationClass = max(ceil(NISPL-refCurve));
delta = max(0,NISPL - (refCurve + impactInsulationClass));
counter = 0; % stopping criterion
% shift reference curve until limits are reached

while sum(delta) <= refSurf && all(delta <= deficiencyLimit) && counter < 1e3
    impactInsulationClass = impactInsulationClass - dbStep;
    delta = max(0,NISPL - (refCurve + impactInsulationClass));
    counter = counter+1;
end
impactInsulationClass = impactInsulationClass + dbStep;
delta = max(0,NISPL - (refCurve + impactInsulationClass));
deficiencies = itaResult(delta,freq,'freq')*itaValue(1,'dB');
deficiencies.allowDBPlot = false;

if strcmpi(sArgs.type,'astm')
    impactInsulationClass = 110 - impactInsulationClass;
end

%% adaptation term for ISO
if strcmpi(sArgs.type,'iso')
    C = round(round((10.*log10(sum(10.^(NISPL./10))))/0.1)*0.1 - 15 - impactInsulationClass);
else
    C = 0;
end

%% output
if sArgs.createPlot
    if strcmpi(sArgs.type,'astm')
        refCurve = refCurve + 110 - impactInsulationClass;
        plotResult = itaResult([nan(sum(freqVector<min(freq)),1); 10.^((refCurve)./20); nan(sum(freqVector>max(freq)),1)],freqVector,'freq');
    else
        refCurve = refCurve + impactInsulationClass;
        plotResult = itaResult([[nan(sum(freqVector<min(freq)),1); 10.^((refCurve)./20); nan(sum(freqVector>max(freq)),1)], [ones(sum(freqVector<=500),1)*10.^(refCurve(freq == 500)./20); nan(sum(freqVector>500),1)]],freqVector,'freq');
    end
    fgh = ita_plot_freq(data);
    ita_plot_freq(plotResult,'figure_handle',fgh,'axes_handle',gca,'hold');
    bar(gca,deficiencies.freqVector,deficiencies.freq,'hist');
    [maxDef,maxIdx] = max(deficiencies.freq);
    if strcmpi(sArgs.type,'iso')
        singleNumberString = [outputStr ' = ' num2str(impactInsulationClass) ' (' num2str(C) ') dB'];
    else
        singleNumberString = [outputStr ' = ' num2str(impactInsulationClass) 'dB'];
    end
    legend({'Normalized Impact Sound Pressure Levels','Shifted reference curve',singleNumberString,['Deficiencies (sum: ' num2str(sum(deficiencies.freq)) 'dB, max: ' num2str(maxDef) 'dB at ' num2str(deficiencies.freqVector(maxIdx)) 'Hz)']});
    xlim([min(freq) max(freq)]);
    ylim([0 max(max(impactInsulationClass),max(refCurve))+15]);
end

varargout{1} = impactInsulationClass;
% reference curve specified at the freqVector specified by the input itaResult:
if nargout >= 2
    varargout{2} = interp1(freq, 10.^((refCurve)./20), freqVector, 'linear');
    if nargout >= 3
        varargout{3} = deficiencies;
        if nargout >= 4
            varargout{4} = C;
        end
    end
end
