% script to calibrate hanging diffusers in reverberation chamber coording
% to ISO 354
%
% mgu - 2014-08-07

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



%% define main path

mainPath = 'M:\Einmessung Diffusoren';


rawPath = fullfile(mainPath, '01 raw Measurements');
% create folder
if ~exist(mainPath, 'dir')
    mkdir(mainPath)
end

%% Create default Measurement Setup

fftDegree   = 19;
freqRangeSweep   = [250 10000];
excitation  = 'exp';
stopMargin  = 2;

inputCh      = 1:4;
outputCh     = 1:2;

outputamplification = -15;

commentStr = ['Reverberation Chamber Measurement  (' datestr(now) '  ' ita_preferences('authorStr') ' )'];
pauseTime           = 0.1;
averages            = 1;


% create MFTF object
MeasurementSetup = itaMSTF('freqRange', freqRangeSweep, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'useMeasurementChain', false,'inputChannels', inputCh, 'outputChannels', outputCh, 'averages', averages, 'pause' , pauseTime, 'comment', commentStr );


%% parameter for room

% room acoustic eval 
freqRange = [500 5000];
bandsPerOctave = 3;
raParameter = 'T20';

% room
roomVolume    = 124;
roomSurface   = 178;


% absorber
objectSurface = 8;

gcf


%% init arduino
tmpSensor  = itaArduino('COM4', 'reverberationroom');

[temperatur, humidity]  = tmpSensor.get_temperature_humidity

freqVec = ita_ANSI_center_frequencies(freqRange, bandsPerOctave);

[c , m ] = ita_constants({'c','m'},'T',temperatur,'phi',humidity/100 ,'f', freqVec );

%% init save struct
 
if ~exist('dataStruct', 'var')
    dataStruct = struct('RIR_empty', [], 'RIR_absorber', [], 'T20_empty', [], 'T20_absorber', [], 'alpha', [], 'alphaMean', [], 'nDiffusers', []);
else
    errordlg('dataStruct already exist! ')
end
iMeasurment = 0;

%% next measurement
iMeasurment = iMeasurment + 1
dataStruct(iMeasurment).nDiffusers =11;

cla([subplot(231) subplot(232) subplot(233)])
%% measure 
figure(gcf)

%$ measure empty
MeasurementSetup.outputChannels = 1;
rec1 = MeasurementSetup.run;
rec1.channelNames = ita_sprintf('LS position %i - Mic %i', 1, 1:4);
MeasurementSetup.outputChannels = 2;
rec2 = MeasurementSetup.run;
rec2.channelNames = ita_sprintf('LS position %i - Mic %i', 2, 1:4);
rec = merge(rec1, rec2);
dataStruct(iMeasurment).RIR_empty = rec;
% rec.trackLength = 5;
tmpRA = ita_roomacoustics(rec, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, raParameter);
dataStruct(iMeasurment).T20_empty = tmpRA.(raParameter);

ita_plot_freq(dataStruct(iMeasurment).T20_empty, 'figure_handle', gcf, 'axes_handle', subplot(231));
legend off; title('T20 EMPTY')

 uiwait(msgbox('ABsorber in Raum platzieren ','Waiting...','modal'))


% measurment of absorber
MeasurementSetup.outputChannels = 1;
rec1 = MeasurementSetup.run;
rec1.channelNames = ita_sprintf('LS position %i - Mic %i', 1, 1:4);
MeasurementSetup.outputChannels = 2;
rec2 = MeasurementSetup.run;
rec2.channelNames = ita_sprintf('LS position %i - Mic %i', 2, 1:4);
rec = merge(rec1, rec2);
dataStruct(iMeasurment).RIR_absorber = rec;
% rec.trackLength = 5;
tmpRA = ita_roomacoustics(rec, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, raParameter);
dataStruct(iMeasurment).T20_absorber = tmpRA.(raParameter);


ita_plot_freq(dataStruct(iMeasurment).T20_absorber, 'figure_handle', gcf, 'axes_handle', subplot(232));
legend off; title('T20 ABSORBER')


% ita_write(rec, fullfile(rawPath, sprintf('RevChamber_IR_empty_%s_LSpos%02i_%s.ita', posName,iLSpos,  datestr(now, 'YYYY.mm.dd_HHMMSS'))))
    



%% calculate and show absorption


% ISO calculation
A1 = 55.3 * roomVolume / c.value ./  nanmean(dataStruct(iMeasurment).T20_empty.freqData,2) - 4 * roomVolume *m.value;
A2 = 55.3 * roomVolume / c.value ./  nanmean(dataStruct(iMeasurment).T20_absorber.freqData,2) - 4 * roomVolume *m.value;
alphaData = (A2 -A1) / objectSurface;
alphaBoden = itaResult(alphaData, freqVec, 'freq');
alphaBoden.allowDBPlot = false;
alphaBoden.channelNames = {'absorption nach ISO'};

alphaBoden.plotLineProperties = { 'linewidth', 2, 'marker', 'o',};
ita_plot_freq(alphaBoden,  'figure_handle', gcf, 'axes_handle', subplot(233));
title('Schallabsorptionsgrad  \alpha_S')
xlabel('Frequenz (in Hz)')
title('\alpha')
legend('off')
ylim([0 1.5])

dataStruct(iMeasurment).alpha = alphaData;
dataStruct(iMeasurment).alphaMean = mean(alphaData);

% plot
subplot(212)
plot([dataStruct.nDiffusers], [dataStruct.alphaMean ], 'o-', 'linewidth', 3)
grid on; xlabel('# diffuser'); ylabel('mean \alpha')
xlim([0 11])



