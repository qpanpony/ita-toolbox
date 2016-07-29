function test_mgu_revChamber_protocol(empty, material, setup)
% create protocol for reverberation chamber measurements
% use latex template and create pdf 
% mgu 2013

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


mikTexExe = '"C:\Program Files (x86)\MiKTeX 2.9\miktex\bin\latex.exe"';


freqRange       = [100 8000];
bandsPerOctave  = 3;
freqVec = ita_ANSI_center_frequencies(freqRange, bandsPerOctave);

[c , m ] = ita_constants({'c','m'},'T',setup.temperatur,'phi',setup.humidity ,'f', freqVec );

% ISO calculation
A1 = 55.3 * setup.roomVolume / c.value ./  nanmean(empty.freqData,2) - 4 * setup.roomVolume *m.value;
A2 = 55.3 * setup.roomVolume / c.value ./  nanmean(material.freqData,2) - 4 * setup.roomVolume *m.value;
alphaData = (A2 -A1) / setup.objectSurface;
alphaS = itaResult(alphaData, empty.freqVector, 'freq');
alphaS.allowDBPlot = false;
alphaS.channelNames = {'Absorption nach ISO'};

alphaS.plotLineProperties = { 'linewidth', 2, 'marker', 'o',};
alphaS.plot_freq
ylabel('Schallabsorptionsgrad  \alpha_S')
xlabel('Frequenz (in Hz)')
title(setup.nameDerProbe)
legend('off')
ylim([0 1.2])

set(gcf,'units', 'centimeters', 'position', [1 1 30 15])
grafikName = sprintf('%s_plot.pdf', setup.texName);
ita_savethisplot(fullfile(setup.folder, grafikName))




myFreqVec = [100 125 160 200 250 315 400 500 630 800];
myFreqVec  = [ myFreqVec  myFreqVec*10];

keyValueCell = cell(0);
for iFreq = 1:numel(myFreqVec)
    keyValueCell = [keyValueCell; {sprintf('<alpha_s_%i>', myFreqVec(iFreq)), sprintf('%2.2f', alphaS.freq2value(myFreqVec(iFreq)))}];
end

keyValueCell = [ keyValueCell; ...
    {   '<Dateiname der Grafik>',   grafikName; ...
    '<Bildunterschrift>'        setup.textBildunterschrift; ...
    '<NameDerProbe>',           setup.nameDerProbe;...
    '<temperaturInGradC>'       num2str(setup.temperatur, '%2.1f'); ...
    '<luftfeuchtigkeit>'        num2str(setup.humidity*100, '%2.1f'); ...
    '<datumDerMessung>'         setup.datumDerMessung; ...
    '<nameDesPruefers>'         setup.nameDesPruefers; ...
    '<beschreibungDesMaterials>'  setup.beschreibungDerProbe  }];

templateFile = [ ita_toolbox_path '\applications\Kundt\Protocol\HallraumGermanTemplate.tex'];
outputTexFile = fullfile(  setup.folder, [setup.texName '.tex' ]);
ita_fillInTemplate(templateFile, keyValueCell, outputTexFile)



% kopieren schein einfacher als latex pfade mit leerzeichen erklären...
[stat res] = system(['copy "' fullfile( ita_toolbox_path, '\applications\Kundt\Protocol\KopfzeileGKB.png' ) '"  "' fullfile(setup.folder, 'KopfzeileGKB.png') '"' ]);


%  [stat res ]= system([mikTexExe ' -include-directory="D:\Dokumente und Einstellungen\guski\Eigene Dateien\MATLAB\ITA-Toolbox\applications\Kundt\Protocol" "' outputTexFile '"'])
% oldPath = pwd;
% cd(fileparts(outputTexFile))
% system([mikTexExe ' "' outputTexFile '"'])
%  system([mikTexExe ' "' [setup.texName '.tex' ] '"'])
% [stat res ]= system([mikTexExe ' G:\Test2.tex'])
%  open([probeFileName '.pdf']);
%     delete(protocolHeaderPNG);
%     delete([probeFileName '.log'] );
%     delete([probeFileName '.aux'] );