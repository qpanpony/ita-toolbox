%% define main path


% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

mainPath = 'M:\2015-09-28 - VR Lab Absorber';


rawPath = fullfile(mainPath, '01 raw Measurements');
preResultsPath = fullfile(mainPath, '03 plots');
% create folder
if ~exist(mainPath, 'dir')
    mkdir(mainPath)
end

if ~exist(rawPath, 'dir')
    mkdir(rawPath)
end

if ~exist(preResultsPath, 'dir')
    mkdir(preResultsPath)
end
%% Create default Measurement Setup

fftDegree   = 20;
freqRangeSweep   = [40 178; 178 16000];
excitation  = 'exp';
stopMargin  = 1;

inputCh      = 1:4;
outputCh     = 1:2;

outputamplification = -20;

commentStr = ['Reverberation Chamber Measurement  (' datestr(now) '  ' ita_preferences('authorStr') ' )'];
pauseTime           = 0.1;
averages            = 1;


% create MFTF object
MeasurementSetup = itaMSTFbandpass('freqRange', freqRangeSweep, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'useMeasurementChain', false,'inputChannels', inputCh, 'outputChannels', outputCh, 'averages', averages, 'pause' , pauseTime, 'comment', commentStr );
% MeasurementSetup.edit    % allow user to edit...

% reset measurement data
measurementsEmpty    = itaAudio(0);

%% init arduino
tmpSensor  = itaArduino('COM4', 'reverberationroom');

[t, rh]  = tmpSensor.get_temperature_humidity

%% measure empty ( measure, save raw, combine repeatetd measurements)
iLSpos = 3;  % adjust number of loudspeaker position here

for iWhd = 1:2
    
    posName = sprintf('LSpos%02i', iLSpos);
    rec = MeasurementSetup.run;
    rec.channelNames = ita_sprintf('LS position %i - Mic %i', iLSpos, 1:4);
    [t, rh]  = tmpSensor.get_temperature_humidity
    rec.userData = struct('temperature', t, 'humidity', rh);
    % save raw
    ita_write(rec, fullfile(rawPath, sprintf('RevChamber_IR_empty_LSpos%02i_%s.ita' ,iLSpos,  datestr(now, 'YYYY.mm.dd_HHMMSS'))))
    
    % combine all repetitions
    measurementsEmpty(end+1) = rec;
    fprintf('  Empty Measurement No %i complete \n', numel(measurementsEmpty))
end
%% show T20 of empty measurements
tmp = measurementsEmpty.merge;
tmp.trackLength = 10;

raResEmpty = ita_roomacoustics(tmp, 'freqRange', [63 8000], 'bandsPerOctave', 3, 'T20');
raResEmpty.T20.pf
ita_plot_variation(raResEmpty.T20, 'areaMethod', 'minmax')


%% init new material

nameOfMaterial = 'Probe_HelmholtzAbsorber63_Ecke';
objectSurface =2 * 1*0.53;

measurementsAbsorber = itaAudio(0);
if ~exist(fullfile(rawPath, nameOfMaterial), 'dir')
    mkdir(fullfile(rawPath, nameOfMaterial))
end
%% measure absorber

    iLSpos         = 3;  % adjust number of loudspeaker position here

for iWdh = 1:2

    posName = sprintf('LSpos%02i', iLSpos);
    rec = MeasurementSetup.run;
    rec.channelNames = ita_sprintf('LS position %i - Mic %i', iLSpos, 1:4);
    [t, rh]  = tmpSensor.get_temperature_humidity;
    rec.userData = struct('temperature', t, 'humidity', rh);
    
    ita_write(rec, fullfile(rawPath, nameOfMaterial,  sprintf('RevChamber_IR_absorber_LSpos%02i_%s.ita', iLSpos, datestr(now, 'YYYY.mm.dd_HHMMSS'))))
    
    
    measurementsAbsorber(end+1) = rec;
    fprintf('  Messung absorber Nr %i\n', numel(measurementsAbsorber)-1)
end

%% show T20, calc absorption
tmp = measurementsAbsorber.merge;
tmp.trackLength = 10;
raRes = ita_roomacoustics(tmp, 'freqRange', [63 8000], 'bandsPerOctave', 3, 'T20');
raRes.T20.pf
ita_plot_variation(raRes.T20, 'areaMethod', 'minmax')

% calculate and show absorption

roomVolume    = 124;
roomSurface   = 178;

% konstanten
freqRange       = [63 8000];
bandsPerOctave  = 3;
raPar           = 'T20';


temperatur  = rec.userData.temperature;
humidity    = rec.userData.humidity;


freqVec = ita_ANSI_center_frequencies(freqRange, bandsPerOctave);

[c , m ] = ita_constants({'c','m'},'T',temperatur,'phi',humidity/100 ,'f', freqVec );

% ISO calculation
A1 = 55.3 * roomVolume / c.value ./  nanmean(raResEmpty.T20.freqData,2) - 4 * roomVolume *m.value;
A2 = 55.3 * roomVolume / c.value ./  nanmean(raRes.T20.freqData,2) - 4 * roomVolume *m.value;
alphaData = (A2 -A1) / objectSurface;
alphaBoden = itaResult(alphaData, raRes.T20.freqVector, 'freq');
alphaBoden.allowDBPlot = false;
alphaBoden.channelNames = {'absorption nach ISO'};

alphaBoden.plotLineProperties = { 'linewidth', 2, 'marker', 'o',};
alphaBoden.plot_freq
ylabel('Schallabsorptionsgrad  \alpha_S')
xlabel('Frequenz (in Hz)')
title(nameOfMaterial)
legend('off')
ylim([0 1.2])

set(gcf,'units', 'centimeters', 'position', [1 1 30 15])
grafikName = sprintf('alpha_%s.pdf', genvarname(nameOfMaterial));
ita_savethisplot(fullfile(preResultsPath, grafikName))
ita_savethisplot(fullfile(preResultsPath, [grafikName(1:end-3) 'png']))

A = alphaBoden * objectSurface;
A.pf

