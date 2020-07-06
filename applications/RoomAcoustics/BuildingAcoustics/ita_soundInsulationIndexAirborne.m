function varargout = ita_soundInsulationIndexAirborne(varargin)
% ita_soundInsulationIndexAirborne - sound insulation acc. to ISO 717-1

% <ITA-Toolbox>
% This file is part of the application BuildingAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% re-implementation: Markus Mueller-Trapet (markus.mueller-trapet@nrc.ca)
% Date: June 2017

%% input parsing
sArgs = struct('pos1_data','anything','bandsperoctave',3,'freqVector',[],'createPlot',false,'type','ISO');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% reference curves
if strcmpi(sArgs.type,'iso') % Reference curve and frequencies according to ISO 717-1
    outputStr = 'R_w (C; C_{tr})';
    roundingFactor = 0.1;
    deficiencyLimit = Inf;
    if sArgs.bandsperoctave == 1
        freq = [125 250 500 1000 2000];
        refSurf = 10;
        refCurve = [36 45 52 55 56].'-52;
        Ccurve = [-21 -14 -8 -5 -4].';
        Ctrcurve = [-14 -10 -7 -4 -6].';
    elseif sArgs.bandsperoctave == 3
        freq = [100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150].';
        refSurf = 32;
        refCurve = [33 36 39 42 45 48 51 52 53 54 55 56 56 56 56 56].'-52;
        Ccurve = [-29 -26 -23 -21 -19 -17 -15 -13 -12 -11 -10 -9 -9 -9 -9 -9].';
        Ctrcurve = [-20 -20 -18 -16 -15 -14 -13 -12 -11 -9 -8 -9 -10 -11 -13 -15].';
    else
        error([upper(mfilename) ':wrong input for bandsperoctave']);
    end
elseif strcmpi(sArgs.type,'astm') % Reference curve and frequencies according to ASTM E413
    outputStr = 'STC';
    roundingFactor = 1;
    deficiencyLimit = 8;
    sArgs.bandsperoctave = 3;
    freq = [125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150,4000].';
    refCurve = [-16 -13 -10 -7 -4 -1 0 1 2 3 4 4 4 4 4 4].';
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
soundReduction = 20.*log10(interp1(freqVector,data.freqData(:,1),freq,'spline','extrap'));

if min(freqVector) > freq(1) || max(freqVector) < freq(end)
    warning([upper(mfilename) ': Sound insulation data will be extrapolated']);
end

%% sound insulation index
soundReduction = round(soundReduction,-log10(roundingFactor));
soundReductionIndex = min(floor(soundReduction-refCurve));
delta = max(0,refCurve + soundReductionIndex - soundReduction);
counter = 0; % stopping criterion
% shift reference curve until limits are reached

while sum(delta) <= refSurf && all(delta <= deficiencyLimit) && counter < 1e3
    soundReductionIndex = soundReductionIndex + dbStep;
    delta = max(0,refCurve + soundReductionIndex - soundReduction);
    counter = counter+1;
end
soundReductionIndex = soundReductionIndex - dbStep;
delta = max(0,refCurve + soundReductionIndex - soundReduction);
deficiencies = itaResult(delta,freq,'freq')*itaValue(1,'dB');
deficiencies.allowDBPlot = false;

%% adaptation terms for ISO
if strcmpi(sArgs.type,'iso')
    C = round(-10.*log10(sum(10.^((Ccurve - soundReduction)./10),1)) - soundReductionIndex);
    Ctr = round(-10.*log10(sum(10.^((Ctrcurve - soundReduction)./10),1)) - soundReductionIndex);
else
    C = 0;
    Ctr = 0;
end

%% output
if sArgs.createPlot
    fgh = ita_plot_freq(data);
    combinedFreq = unique(round([freq; freqVector]./10).*10);
    plotResult = itaResult([[nan(sum(combinedFreq<min(freq)),1); 10.^((refCurve+soundReductionIndex)./20); nan(sum(combinedFreq > max(freq)),1)],[ones(sum(combinedFreq<=500),1)*10.^(soundReductionIndex./20); nan(sum(combinedFreq > 500),1)]],combinedFreq,'freq');
    ita_plot_freq(plotResult,'figure_handle',fgh,'axes_handle',gca,'hold');
    bar(gca,deficiencies.freqVector,deficiencies.freq,'hist');
    [maxDef,maxIdx] = max(deficiencies.freq);
    if strcmpi(sArgs.type,'iso')
        singleNumberString = [outputStr ' = ' num2str(soundReductionIndex) ' (' num2str(C) '; ' num2str(Ctr) ') dB'];
    else
        singleNumberString = [outputStr ' = ' num2str(soundReductionIndex) 'dB'];
    end
    legend({'Sound transmission loss','Shifted reference curve',singleNumberString,['Deficiencies (sum: ' num2str(sum(deficiencies.freq)) 'dB, max: ' num2str(maxDef) 'dB at ' num2str(deficiencies.freqVector(maxIdx)) 'Hz)']});
    xlim([min(combinedFreq) max(combinedFreq)]);
    ylim([0 max(max(soundReduction),max(refCurve)+soundReductionIndex)+15]);
end

varargout{1} = soundReductionIndex;
% reference curve specified at the freqVector specified by the input itaResult:
if nargout >= 2
    varargout{2} = interp1(freq, 10.^((refCurve+soundReductionIndex)./20), freqVector, 'linear');
    if nargout >= 3
        varargout{3} = deficiencies;
        if nargout >= 4
            varargout{4} = [C,Ctr];
        end
    end
end
