function varargout = ita_soundInsulationIndexAirborne(varargin)
% ita_soundInsulationIndexAirborne - sound insulation acc. to ISO 717-1

% <ITA-Toolbox>
% This file is part of the application BuildingAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% input parsing
sArgs = struct('pos1_data','anything','bandsperoctave',3,'freqVector',[],'createPlot',false,'type','ISO');
[data,sArgs] = ita_parse_arguments(sArgs,varargin);

%% reference curves
if strcmpi(sArgs.type,'iso') % Reference curve and frequencies according to ISO 717-1
    outputStr = 'R_W';
    roundingFactor = 0.1;
    deficiencyLimit = Inf;
    if sArgs.bandsperoctave == 1
        refCurve = [36 45 52 55 56]-52;
        freq = [125 250 500 1000 2000];
        refSurf = 10;
    elseif sArgs.bandsperoctave == 3
        freq = [100,125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150];
        refCurve = [33 36 39 42 45 48 51 52 53 54 55 56 56 56 56 56]-52;
        refSurf = 32;
    else
        error([upper(mfilename) ':wrong input for bandsperoctave']);
    end
elseif strcmpi(sArgs.type,'astm') % Reference curve and frequencies according to ASTM E413
    outputStr = 'STC';
    roundingFactor = 1;
    deficiencyLimit = 8;
    sArgs.bandsperoctave = 3;
    freq = [125,160,200,250,315,400,500,630,800,1000,1250,1600,2000,2500,3150,4000];
    refCurve = [-16 -13 -10 -7 -4 -1 0 1 2 3 4 4 4 4 4 4];
    refSurf = 32;
else
    error([upper(mfilename) ':wrong input for type']);
end
freq = freq(:);
refCurve = refCurve(:);
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
soundInsulation = 20.*log10(interp1(freqVector,data.freqData(:,1),freq,'spline','extrap'));

if min(freqVector) > freq(1) || max(freqVector) < freq(end)
    warning([upper(mfilename) ': Sound insulation data will be extrapolated']);
end

%% sound insulation index
soundInsulation = round(soundInsulation/roundingFactor)*roundingFactor;
soundInsulationIndex = min(floor(soundInsulation-refCurve));
delta = max(0,refCurve + soundInsulationIndex - soundInsulation);
counter = 0; % stopping criterion
% shift reference curve until limits are reached

while sum(delta) < refSurf && all(delta) < deficiencyLimit && counter < 1e3
    soundInsulationIndex = soundInsulationIndex + dbStep;
    delta = max(0,refCurve + soundInsulationIndex - soundInsulation);
    counter = counter+1;
end
soundInsulationIndex = soundInsulationIndex - dbStep;
delta = max(0,refCurve + soundInsulationIndex - soundInsulation);
deficiencies = itaResult(delta,freq,'freq')*itaValue(1,'dB');
deficiencies.allowDBPlot = false;

%% output
if sArgs.createPlot
    fgh = ita_plot_freq(data);
    plotResult = itaResult([10.^((refCurve+soundInsulationIndex)./20), [ones(sum(freq<=500),1)*10.^(soundInsulationIndex./20); nan(sum(freq>500),1)]],freq,'freq');
    ita_plot_freq(plotResult,'figure_handle',fgh,'axes_handle',gca,'hold');
    bar(gca,deficiencies.freqVector,deficiencies.freq,'hist');
    legend({'Sound transmission loss','Shifted reference curve',[outputStr ' = ' num2str(soundInsulationIndex) 'dB'],'Deficiencies'});
    ylim([0 max(max(soundInsulation),max(refCurve)+soundInsulationIndex)+15]);
end

varargout{1} = soundInsulationIndex;
% reference curve specified at the freqVector specified by the input itaResult:
if nargout >= 2
    varargout{2} = interp1(freq, 10.^((refCurve+soundInsulationIndex)./20), freqVector, 'linear');
    if nargout == 3
        varargout{3} = deficiencies;
    end
end
