
% clear all;

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

close all;
clc;
[mfilePath, mfileName, ext] = fileparts(mfilename('fullpath')); %#ok<ASGLU>
mfilePath = 'E:\Versuch2'; cd(mfilePath)
ita_preferences('fontsize',12); ita_preferences('verboseMode',0);commandwindow

%% measurement setup
% excitation settings
fftDegree               = 16;
measurementRange        = [250 22000];
position_averages       = 1;
fraction                = 3;
OutputAmplification =   '-10dB';

% setup details
SetupDetails.PlateMaterial              = 'R11';  %Keine Bindestriche!
SetupDetails.PlateThickness             = '13e-3';
SetupDetails.PlateDensity               = '618';
SetupDetails.PlateYoungsModulus         = '3.2e9';
SetupDetails.HeightRecRoom              = '750e-3';
SetupDetails.WidthRecRoom               = '1000e-3';
SetupDetails.DepthRecRoom               = '1130e-3';
Comment                                 = 'MDF';

%% Hilfe für Versuch 2:
% MDF-Holz  3.2e9 618
% Messing   100e9 8750
% Aluminium 70e9  2700
%
% Es können nun verschiedene Messungen hintereinander durchgeführt werden indem die Taste F5 gedrückt wird.
% Vor der Messung sollen die Anzahl der Mittelungen (position_averages) und die Eigenschaften
% (SetupDetails) genau überprüft werden, weil diese Angaben für die Berechnung und Verarbeitung verwendet werden. Es wird immer mit vier Mikrophonen
% gleichzeitig gemessen. Wenn bei Mittelungen eine 3 eingetragen wird, wird über 3x8 Positionen gemittelt.
% Nach allen Messungen ist eine bestimmte Auswahl an Grafiken für das Protokoll
% zu erstellen (Siehe auch Kapitel 'Protokoll').
% Tippen Sie den Befehl 'whos' im Matlab Eingabefenster um festzustellen welche
% Variablen vorhanden sind. Auf diese Weise wird man die verschiedenen Messungen zurückfinden. Benutzen Sie den Befehl 'plotv2' um eine
% Auswahl an Variablen gleichzeitig darzustellen. Exportieren Sie eine
% Grafik indem Sie 's' drücken, wenn die Grafik unter Matlab dargestellt
% wird.(EMF ist ein gutes Format unter Windows, EPS oder PDF ist ein besser
% für Latex. Bei PNG oder JPG ändert sich die Größe der Legende.)
%
% Beispiele: ita_plot_spk(ita_merge(pSendMean_MDF_12mm,p_MDF_12mm))
%            set(gca,'ylim',[0 60],'xlim',[315 20000])
%
%            ita_plot_spk(ita_merge(R_messing-1mm,R_3mmalu,R_mdf-4mm))
%            ita_plot_spk(ita_merge(p_messing-1mm,p_3mmalu,p_mdf-4mm))
%            set(gca,'ylim',[0 60],'xlim',[315 20000])
%

%% switches
plotOn = 1; saveWorkspace = 1; saveFigures = 1; saveData = 1;

%% get a Measurement Setup 
if ~exist('MS','var')
    
    % MS = ita_measurement_setup_signals_with_playback;
    % save('D:\Dokumente und Einstellungen\praktikum\Eigene Dateien\ITA-Toolbox\applications\Laboratory\V2\MSV2.mat','MS')
    load(which('V2_calibrated.mat'));
    
    % excitation signals
    noise = ita_generate('pinknoise',1,ita_preferences('samplingRate'),fftDegree);
    noise = noise * ita_zerophase(ita_make_filter(measurementRange,ita_preferences('samplingRate'),fftDegree));
    noise = ita_normalize_dat(noise);
    noise = ita_amplify(noise,OutputAmplification);
    MS.excitation = noise;
%     MS.inputChannels = 1:8;
    % Hier die Inputmeasurementchain reinpacken
    % MS speicher in MSV2.mat (save)
end

%% Measurement
DATA = itaAudio([position_averages 1]);
for iAverage = 1:position_averages
    fileName    = mfilename;
    
    DATA(iAverage) = MS.run;
    
    % update meta info
    DATA(iAverage).comment = Comment;
    DATA(iAverage).userData{1}.SetupDetails = SetupDetails;
    
    % Save measurement
    if saveData == 1
        ita_write(DATA(iAverage),fullfile(mfilePath,['measurementdata_',mat]));
    end
    
    if iAverage ~= position_averages
        commandwindow
        cprintf('green','.... ITA Versuch 2:  Move all microphones and press enter for next measurement \n');
        pause
    end
    
end
% plot
if plotOn == 1
    ita_plot_spk(ita_merge(DATA),'ylim',[-30 150],'xlim',[20 24000])
    ita_plottools_cursors('off',[],gca);
    title(mattitle);
end

%% load rt times
if ~exist('RT','var')
    RT = ita_read('RT.ita');
end

%% calculate R
[R,fc,p,pSendMean,pRecMean] = ita_v2_sound_reduction_index(DATA,'fraction',fraction,'sendChannels',1:4,'recChannels',5:8,'RT',RT,'density',str2double(SetupDetails.PlateDensity),...
    'thickness',str2double(SetupDetails.PlateThickness),'YoungsModulus',str2double(SetupDetails.PlateYoungsModulus),'Material',SetupDetails.PlateMaterial,...
    'Swall',str2double(SetupDetails.WidthRecRoom)*str2double(SetupDetails.HeightRecRoom),'VrecRoom',str2double(SetupDetails.WidthRecRoom)*str2double(SetupDetails.HeightRecRoom)*str2double(SetupDetails.DepthRecRoom));
clear DATA

% create variable according to material specified in SetupDetails
eval (['R',mat, '=R;']);
eval (['p',mat, '=p;']);
eval (['pSendMean',mat, '=pSendMean;']);
eval (['pRecMean',mat, '=pRecMean;']);

% plot R
ita_plot_spk(R,'ylim',[-30 60],'xlim',[315 20000])
title('');
ylabel('Schalldämmmaß [dB]');
xlabel('Frequenz [Hz]');
% lines=findobj(gca,'type','line');set(lines,'marker','s','markersize',5)
% ita_vertical_lines(fc)

% save calculations
if saveData == 1
    ita_write(eval(['R',mat]),fullfile(mfilePath,['R',mat]));
    ita_write(eval(['p',mat]),fullfile(mfilePath,['p',mat]));
    ita_write(eval(['pSendMean',mat]),fullfile(mfilePath,['pSendMean',mat]));
    ita_write(eval(['pRecMean',mat]),fullfile(mfilePath,['pRecMean',mat]));
end

%% save figures and workspace
figureVector=findobj(0,'type','figure');
if saveFigures==1
    ita_savethisplot(gcf,[fullfile(mfilePath,['R',mat]),'.png'])
    %     ita_savethisplot(gcf-1,[fullfile(mfilePath,['p',mat]),'.emf'])
end

if saveWorkspace == 1
    save(fullfile(mfilePath,mfileName))
end