function varargout = ita_kundt_protocol(varargin)
%ITA_KUNDT_PROTOCOL - calculates loudness level of a signal according to DIN

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% TODO:
% - path2TeX in ita_preferences`?
% - auswähle wo pdf gespeichert wird?
% - zwei variablen 'humidity' und 'luftfeuchtigkeit', eine löschen
% - einheitliche dateinstruktur, mit raw daten, temperatur, anuahl der mics, mic positionen, ...
% - ita header anders, nur ita logi in toolbox, text mit tex
% - option fuer keine smooth => text in protokoll anpassen
% - 


% normal call, no input => call gui
protocolHeaderPNG = 'KopfzeileGKB.png';
if isempty(varargin)
    protocolLanguage = questdlg('Please choose a protocol language:', ...
        'Language selection', ...
        'German','English','German');
    
    if isempty(protocolLanguage)
        return
    end
    
    linFreq = false;
    
    % raw dateien auswählen
    [files pathName del] = uigetfile('*_raw.ita', 'MultiSelect','on');
    cd(pathName)
    pause(0.1)
    if isequal(files,0)
        return
    end
    
    
    % try to guess probe name
    try
        tmp = cell2mat(files.');
        i= 0;
        while (isequal(repmat(tmp(1,1:i+1),size(tmp,1)-1,1), tmp(2:end,1:i+1)) )
            i = i+1;
        end
        
        if i<3
            nameDerProbe = 'Probe A';
        else
            nameDerProbe = strrep (tmp(1,1:i), '_' , ' ');
        end
    catch
        nameDerProbe = 'Probe A';
    end
%% tex path

% enter your MIKTEX path here |  |  |  |  |  |
%                            \ /\ /\ /\ /\ /\ /
%                             .  .  .  .  .  .
% texpath = '"C:\Program Files\MiKTeX 2.8\miktex\bin\pdf.latex.exe"';
% texpath = '"D:\Program Files\MiKTeX 2.9\miktex\bin\pdflatex.exe"';
%texpath = '"D:\Programme\MiKTeX 2.9\miktex\bin\pdflatex.exe"';
texpath = '"C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe"';
%                             .  .  .  .  .  .
%                            / \/ \/ \/ \/ \/ \
%                             |  |  |  |  |  |   
else % mgu mode
    inStruct = varargin{1};
    protocolLanguage = inStruct.protocolLanguage;
    linFreq = inStruct.linFreq;
    pathName = inStruct.pathName ;
    files    = inStruct.files;
    nameDerProbe = inStruct.nameDerProbe;
    texpath = [ '"' fullfile(inStruct.texpath, 'pdflatex.exe') '"'];

    cd(pathName)
    pause(0.1)
    if isequal(files,0)
        return
    end

end

%% Settings for postprocessing and plots
TimeWindow1 = [0.04 0.06];
surface_factor = 1;

x_lim = [100 8000];
y_lim = [0 1];

lWidthMean = 1.5;
lWidthStd = 1.1;

raw_data = ita_read(files);
nMeasurements = numel(raw_data);

% datum der messung
if iscell(files)
    x = dir(files{1});
elseif ischar(files)
    x = dir(files);
end
datumDerMessung = datestr(x.datenum,'dd.mm.yyyy');

% TODO: in GUI auswählen
protocolPath = [ita_toolbox_path filesep 'applications' filesep 'Kundt' filesep 'Protocol' filesep];

if strcmpi(protocolLanguage, 'english')
    error('gibt noch keine englische version')
end
if nargin == 0
    %% GUI erstellen
    
    % TODO: GUI in english!°
    pList = [];
    idx = 1;
    pList{idx}.description = 'Data Select';
    pList{idx}.datatype    = 'text';
    idx = idx+1;
    
    
    pList{idx}.datatype    = 'line'; %just draw a simple line
    idx = idx +1;
    
    pList{idx}.description = 'Datum der Messung';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'char';
    pList{idx}.default     = datumDerMessung;
    idx = idx+1;
    
    pList{idx}.description = 'Pruefer';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'char';
    pList{idx}.default     = ita_preferences('AuthorStr');
    idx = idx+1;
    
    pList{idx}.description = 'Temperatur [°C]';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'char';
    pList{idx}.default     = '19.5';
    idx = idx+1;
    
    pList{idx}.description = 'Luftfeuchtigkeit [%]';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'char';
    pList{idx}.default     = '61.4';
    idx = idx+1;
    
    pList{idx}.datatype    = 'line'; %just draw a simple line
    idx = idx +1;
    
    
    pList{idx}.description = 'Bezeichnung der Probe';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'char';
    pList{idx}.default     = nameDerProbe;
    idx = idx+1;
    
    pList{idx}.description = 'Beschreibung der Probe';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'textfield';
    pList{idx}.default     = 'Anthrazitfarbiger, teils geschlossen-poriger Zellschaum. Dicke ca. 52 mm Passgenaue Platzierung der Samples im Probenhalter mit dichtem Abschluss zur Wandung. Einbau der Proben ohne Abstand vor dem schallharten Rohrabschluss.';
    pList{idx}.height      = 5;
    idx = idx+1;
    
    pList{idx}.description = 'Mittelung ueber';
    pList{idx}.helptext    = '';
    pList{idx}.datatype    = 'char_popup';
    pList{idx}.list        = 'Samples|Wiederholungen';
    if strcmp(protocolLanguage, 'German')
        pList{idx}.list        = 'Samples|Wiederholungen';
    elseif strcmp(protocolLanguage, 'English')
        pList{idx}.list        = 'samples|repetitions';
    end
    pList{idx}.default     = 'Samples'; %default value, could also be empty, otherwise it has to be of the datatype specified above
    idx = idx+1;
    
    pList{idx}.datatype    = 'line'; %just draw a simple line
    idx = idx +1;
    
    pList{idx}.description = 'Bandbreite der Glaettung [Oktaven]'; %this text will be shown in the GUI
    pList{idx}.helptext    = ''; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'char_popup';
    pList{idx}.list        = '1/1|1/3|1/6|1/12|1/24';
    pList{idx}.default     = '1/12'; %default value, could also be empty, otherwise it has to be of the datatype specified above
    idx = idx+1;
    
    pList{idx}.description = 'Wiederholungen'; %this text will be shown in the GUI
    pList{idx}.helptext    = 'Bandbreite der Glaettung wird korriegiert'; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'int';
    pList{idx}.default     = '1'; %default value, could also be empty, otherwise it has to be of the datatype specified above
    idx = idx+1;
    
    pList{idx}.datatype    = 'line'; %just draw a simple line
    idx = idx +1;
    
    pList{idx}.description = 'Bild  loeschen'; %this text will be shown in the GUI
    pList{idx}.helptext    = 'Die Grafik zur Erstellung des Protokolls wird am Ende geloescht.'; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above
    idx = idx+1;
    
    pList{idx}.description = 'TeX-Date loeschen'; %this text will be shown in the GUI
    pList{idx}.helptext    = 'Die TeX-Datei zur Erstellung des Protokolls wird am Ende geloescht.'; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{idx}.default     = true; %default value, could also be empty, otherwise it has to be of the datatype specified above
    idx = idx+1;
    
    
    
    pList = ita_parametric_GUI(pList,'Protokoll erstellen','wait','on','return_handles',true); % RSC - No user entry on test ita_all! If you use this function for debuging etc make a local copy!
    
    if isempty(pList)
        return
    end
    
    
    %% read data from gui
    
    datumDerMessung             = pList{1};
    nameDesPruefers             = pList{2};
    temperatur                  = pList{3};
    luftfeuchtigkeit            = pList{4};
    beschreibungDerProbe        = pList{6};
    nameDerProbe                = pList{5};
    samplesOderWiederholungen   = pList{7};
    delPictureFile              = pList{10};
    delTexFile                  = pList{11};
    smooth                      = pList{8};
    smooth_reps                 = pList{9};
    
    temp        = ita_str2num(temperatur);
    humidity    =  ita_str2num(luftfeuchtigkeit)/100;
    
else  % mgu mode

    nameDesPruefers             = ita_preferences('AuthorStr');
    temperatur                  = inStruct.temperatur;
    luftfeuchtigkeit            = inStruct.luftfeuchtigkeit*100;
    beschreibungDerProbe        = inStruct.beschreibungDerProbe;
    samplesOderWiederholungen   = inStruct.sampleOderWiederholungen;
    delPictureFile              = inStruct.delPicture;
    delTexFile                  = inStruct.delTexFile;
    smooth                      = inStruct.smooth;
    smooth_reps                 = inStruct.smootheReps;
    
    
    temp     = inStruct.temperatur;
    humidity = inStruct.luftfeuchtigkeit/100;
end


%% Start postprocessing
if 1
    raw_data = ita_time_window(raw_data,TimeWindow1,'time','symmetric');
end

absorption = itaAudio(nMeasurements,1);
T = itaAudio(nMeasurements,1);

imp = itaAudio;

nChannels = raw_data(1).nChannels;

wbh = waitbar(0,'Create protocol...');
gesWaitbar = nMeasurements + smooth_reps;


for iMeasurement = 1:nMeasurements
    [~, T(iMeasurement),  Refl] = ita_kundt_calc_impedance_transmission(raw_data(iMeasurement).ch(1:3) , raw_data(iMeasurement).ch(4), 'smallTubeITA Mics123' , temp, humidity);
    absorption(iMeasurement) = 1 - abs(Refl)^2  * surface_factor;
    absorption(iMeasurement).signalType = 'energy';
    T(iMeasurement).signalType = 'energy';
    waitbar(iMeasurement/gesWaitbar, wbh, 'calculate absorption');
end
absorption = absorption.merge;
absorption.comment = 'Absorption';
T = abs(T.merge);
T.comment = 'Transmissionsfaktor (Betrag)';


% ita_plot_freq(absorption, 'nodb')

%% optional impedance polt  - from Martin Guski (2012-06-01) 
boolPlotImpedance = 0;
if boolPlotImpedance == 1 
    impSmooth = absorption;
    if ~isempty(smooth)
        for idsmooth = 1:smooth_reps
            impSmooth = ita_smooth(imp, 'LogFreqOctave1', ita_str2num( smooth )/ smooth_reps, 'Complex');
        end
    end
    impSmooth.channelUnits(:) = {'kg/s*m^2'};
    
    reUndImGetrennt = itaAudio(2);
    reUndImGetrennt(1) = ita_real(impSmooth);
    reUndImGetrennt(2) = ita_imag(impSmooth);
    
    nameCell = {'real' 'imag'};
    
    for i=1:2
        
        % plot
        impMean = ita_mean(reUndImGetrennt(i));
        impStd  = ita_std(reUndImGetrennt(i));
        
        
        fgh = figure;
        color = colormap; % Same color as plot before
        color = color(1,:);
        
        impMean.plotLineProperties = {'Color',color};
        ita_plot_freq(impMean,'nodb','xlim',x_lim,'figure_handle', fgh, 'linewidth', lWidthMean);
        
        pltstd = merge(impMean + impStd,impMean - impStd );
        pltstd.plotLineProperties = {'LineStyle','--','Color',color};
        %     fgh = ita_plot_freq(pltstd,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd);
        
        
        % imp
        fgh = ita_plot_freq(pltstd,'nodb','xlim',x_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd);
        
        lgh = legend({nameDerProbe},'Interpreter','none', 'location', 'northwest');
        set(gca, 'TickDir', 'out', 'box', 'off')
        probeFileName = [strrep(nameDerProbe, ' ','_'),  '_' nameCell{i} '_mean(' num2str(nMeasurements) ')' ];
        
        if i ==2
            ylim([-1 1]* 5000)
        end
        %     title('')
        ylabel(sprintf('%s(impedance) [%s]',nameCell{i}, impMean.channelUnits{1} ))
        ita_saveplot('aspectRatio',0.5 , 'filename', probeFileName, 'figures', fgh, 'exportPNG', true)
        close(fgh)
    end
    
end
%%
% SMOOTH
absSmooth = absorption;
transSmooth = T;
% absSmooth.freqData(1:absSmooth.freq2index(100), :) = 0;
% ita_verbose_info('Freq < 60 Hz werden zu Null gesetzt!',0)

if ~isempty(smooth)
    for idxSmooth = 1:smooth_reps
        waitbar((nMeasurements+idxSmooth)/gesWaitbar, wbh, sprintf('smoothing %i / %i',idxSmooth, smooth_reps));
        absSmooth = ita_smooth(absSmooth, 'LogFreqOctave1', ita_str2num(smooth)/ smooth_reps, 'Real');
%         hier weiter....
        transSmooth = ita_smooth(transSmooth, 'LogFreqOctave1', ita_str2num(smooth)/ smooth_reps, 'Real');
    end
    waitbar((nMeasurements+idxSmooth)/gesWaitbar, wbh, '');
end

%% save abs as itaResult
probeFileName                       = [strrep(strrep(nameDerProbe, ' ','_'), '.', ''), '_mean(' num2str(nMeasurements) ')' ];
absSmoothResult                     = itaResult(absSmooth);
absSmoothResult.channelNames        = ita_sprintf('%s: Messung %i', inStruct.nameDerProbe, 1:nMeasurements);
absSmoothResult.allowDBPlot         = false;
absSmoothResult.plotAxesProperties  = { 'xlim',[50 10000],'ylim',[-0.1 1.1]};

ita_write(absSmoothResult, [probeFileName '.ita'], 'overwrite')


%% plot and save image
absMean = ita_mean(absSmooth);
absStd  = ita_std(absSmooth);


% % % % terzen der std exportieren
% % % thirdOctAlpha = ita_spk2frequencybands(absMean,'bandsPerOctave',3,'method','averaged','freqRange',x_lim);
% % % thirdOctAlphaStd = ita_spk2frequencybands(absStd,'bandsPerOctave',3,'method','averaged','freqRange',x_lim);
% % % exportData = [{'Name:', inStruct.nameDerProbe ''; '' '' ''; 'Freq', 'Mean' 'std'}; num2cell([thirdOctAlpha.freqVector thirdOctAlpha.freqData thirdOctAlphaStd.freqData])];
% % % tmpPath = 'D:\tmp';
% % % xlswrite(fullfile(tmpPath, probeFileName), exportData)
% % % movefile(fullfile(tmpPath, [probeFileName ,'.xls']), fullfile(pathName, [probeFileName ,'.xls']))
% % % return

fgh = figure;
color = colormap; % Same color as plot before
color = color(1,:);

absMean.plotLineProperties = {'Color',color};
ita_plot_freq(absMean,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle', fgh, 'linewidth', lWidthMean, 'linfreq', linFreq);
%ita_plot_freq(absMean,'nodb','figure_handle', fgh, 'linfreq', linFreq);

pltstd = merge(absMean + absStd,absMean - absStd );
pltstd.plotLineProperties = {'LineStyle','--','Color',color};
fgh = ita_plot_freq(pltstd,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd, 'linfreq', linFreq);
%fgh = ita_plot_freq(pltstd,'nodb','figure_handle',fgh,'hold','on', 'linfreq', linFreq);

% imp
% ita_plot_cmplx(absMean,'nodb','ylim',y_lim,'figure_handle', fgh, 'linewidth', lWidthMean);
% fgh = ita_plot_cmplx(pltstd,'nodb','xlim',x_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd);

lgh = legend({nameDerProbe},'Interpreter','none', 'location', 'best');

set(gca, 'TickDir', 'out', 'box', 'off')

texFileName = [probeFileName '.tex'];
grafikName = [probeFileName '_grafik.png'];
set(fgh, 'position', [0 0 750 350])
ita_savethisplot(fgh,  grafikName, 'resolution', 300)
close(fgh)


%% TRANSMISSION: plot and save image
transMean = ita_mean(transSmooth);
transStd  = ita_std(transSmooth);

fgh = figure;
color = colormap; % Same color as plot before
color = color(1,:);

transMean.plotLineProperties = {'Color',color};
ita_plot_freq(transMean,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle', fgh, 'linewidth', lWidthMean, 'linfreq', linFreq);
%ita_plot_freq(absMean,'nodb','figure_handle', fgh, 'linfreq', linFreq);

pltstd = merge(transMean + transStd,transMean - transStd );
pltstd.plotLineProperties = {'LineStyle','--','Color',color};
fgh = ita_plot_freq(pltstd,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd, 'linfreq', linFreq);
%fgh = ita_plot_freq(pltstd,'nodb','figure_handle',fgh,'hold','on', 'linfreq', linFreq);

% imp
% ita_plot_cmplx(absMean,'nodb','ylim',y_lim,'figure_handle', fgh, 'linewidth', lWidthMean);
% fgh = ita_plot_cmplx(pltstd,'nodb','xlim',x_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd);
 legend({nameDerProbe},'Interpreter','none', 'location', 'best');

set(gca, 'TickDir', 'out', 'box', 'off')

texFileName = [probeFileName '.tex'];
grafikNameTrans = [probeFileName '_transmission_grafik.png'];
set(fgh, 'position', [0 0 750 350])
ita_savethisplot(fgh,  grafikNameTrans, 'resolution', 300)
close(fgh)
%% create ABS protocol
texFileName = [probeFileName '_abs.tex'];

% calc third octave values
absMean2 = absMean;
absMean2.freqData([1:absMean2.freq2index(100) absMean2.freq2index(8000):end],:) = nan;
thirdOctAlpha = ita_spk2frequencybands(absMean2,'bandsPerOctave',3,'method','averaged','freqRange',x_lim);

% fill in the template
keyValueCell   = { '<\itaBriefkopfBild>' protocolHeaderPNG;
    '<\datumDerMessung>' datumDerMessung;
    '<\nameDesPruefers>' nameDesPruefers
    '<\temperaturInGradC>' temperatur
    '<\luftfeuchtigkeit>'  luftfeuchtigkeit
    '<\nameDerProbe>'  nameDerProbe
    '<\anzahlDerMessungen>' num2str(nMeasurements)
    '<\samplesOderWiederholungen>'  samplesOderWiederholungen
    '<\dateinameGrafik>'  grafikName
    '<\smoothParameter>'  smooth
    '<\beschreibungDesMaterials>'  beschreibungDerProbe
    '<\terzWertA>' sprintf('%1.2f', thirdOctAlpha.freqData(1))
    '<\terzWertB>' sprintf('%1.2f', thirdOctAlpha.freqData(2))
    '<\terzWertC>' sprintf('%1.2f', thirdOctAlpha.freqData(3))
    '<\terzWertD>' sprintf('%1.2f', thirdOctAlpha.freqData(4))
    '<\terzWertE>' sprintf('%1.2f', thirdOctAlpha.freqData(5))
    '<\terzWertF>' sprintf('%1.2f', thirdOctAlpha.freqData(6))
    '<\terzWertG>' sprintf('%1.2f', thirdOctAlpha.freqData(7))
    '<\terzWertH>' sprintf('%1.2f', thirdOctAlpha.freqData(8))
    '<\terzWertI>' sprintf('%1.2f', thirdOctAlpha.freqData(9))
    '<\terzWertJ>' sprintf('%1.2f', thirdOctAlpha.freqData(10))
    '<\terzWertK>' sprintf('%1.2f', thirdOctAlpha.freqData(11))
    '<\terzWertL>' sprintf('%1.2f', thirdOctAlpha.freqData(12))
    '<\terzWertM>' sprintf('%1.2f', thirdOctAlpha.freqData(13))
    '<\terzWertN>' sprintf('%1.2f', thirdOctAlpha.freqData(14))
    '<\terzWertO>' sprintf('%1.2f', thirdOctAlpha.freqData(15))
    '<\terzWertP>' sprintf('%1.2f', thirdOctAlpha.freqData(16))
    '<\terzWertQ>' sprintf('%1.2f', thirdOctAlpha.freqData(17))
    '<\terzWertR>' sprintf('%1.2f', thirdOctAlpha.freqData(18))
    '<\terzWertS>' sprintf('%1.2f', thirdOctAlpha.freqData(19))
    '<\terzWertT>' sprintf('%1.2f', thirdOctAlpha.freqData(20))};


ita_fillInTemplate( [protocolPath 'KundtGermanTemplate.tex'], keyValueCell, texFileName);
fclose('all');

% kopieren schein einfacher als latex pfade mit leerzeichen erklären...
[stat res] = system(['copy "' [protocolPath protocolHeaderPNG] '" ']);

% create pdf
if ita_preferences('verboseMode') == 2
     system([texpath ' ' texFileName]) % mit ausgabe
 else
     [status result] = system([texpath ' ' texFileName]); % ohne ausgabe zur console
     if status
         error(result)
     end
end



% löscht überflüssige Dateien

%      open([probeFileName '.pdf']);
     delete(protocolHeaderPNG);
     delete([probeFileName '.log'] );
     delete([probeFileName '.aux'] );
     if exist([probeFileName '.bbl'], 'file')~=0
         delete([probeFileName '.bbl']);
     end
     if exist([probeFileName '.blg'],'file')~=0
         delete([probeFileName '.blg'] );
     end
     

 if delTexFile
     delete(texFileName);
 end
 if delPictureFile
     delete([probeFileName '.png']);
 end


%% create TRANS protocol
texFileName = [probeFileName '_trans.tex'];


% calc third octave values
absMean2 = transMean;
absMean2.freqData([1:absMean2.freq2index(100) absMean2.freq2index(8000):end],:) = nan;
thirdOctAlpha = ita_spk2frequencybands(absMean2,'bandsPerOctave',3,'method','averaged','freqRange',x_lim);

% fill in the template
keyValueCell   = { '<\itaBriefkopfBild>' protocolHeaderPNG;
    '<\datumDerMessung>' datumDerMessung;
    '<\nameDesPruefers>' nameDesPruefers
    '<\temperaturInGradC>' temperatur
    '<\luftfeuchtigkeit>'  luftfeuchtigkeit
    '<\nameDerProbe>'  nameDerProbe
    '<\anzahlDerMessungen>' num2str(nMeasurements)
    '<\samplesOderWiederholungen>'  samplesOderWiederholungen
    '<\dateinameGrafik>'  grafikNameTrans
    '<\smoothParameter>'  smooth
    '<\beschreibungDesMaterials>'  beschreibungDerProbe
    '<\terzWertA>' sprintf('%1.2f', thirdOctAlpha.freqData(1))
    '<\terzWertB>' sprintf('%1.2f', thirdOctAlpha.freqData(2))
    '<\terzWertC>' sprintf('%1.2f', thirdOctAlpha.freqData(3))
    '<\terzWertD>' sprintf('%1.2f', thirdOctAlpha.freqData(4))
    '<\terzWertE>' sprintf('%1.2f', thirdOctAlpha.freqData(5))
    '<\terzWertF>' sprintf('%1.2f', thirdOctAlpha.freqData(6))
    '<\terzWertG>' sprintf('%1.2f', thirdOctAlpha.freqData(7))
    '<\terzWertH>' sprintf('%1.2f', thirdOctAlpha.freqData(8))
    '<\terzWertI>' sprintf('%1.2f', thirdOctAlpha.freqData(9))
    '<\terzWertJ>' sprintf('%1.2f', thirdOctAlpha.freqData(10))
    '<\terzWertK>' sprintf('%1.2f', thirdOctAlpha.freqData(11))
    '<\terzWertL>' sprintf('%1.2f', thirdOctAlpha.freqData(12))
    '<\terzWertM>' sprintf('%1.2f', thirdOctAlpha.freqData(13))
    '<\terzWertN>' sprintf('%1.2f', thirdOctAlpha.freqData(14))
    '<\terzWertO>' sprintf('%1.2f', thirdOctAlpha.freqData(15))
    '<\terzWertP>' sprintf('%1.2f', thirdOctAlpha.freqData(16))
    '<\terzWertQ>' sprintf('%1.2f', thirdOctAlpha.freqData(17))
    '<\terzWertR>' sprintf('%1.2f', thirdOctAlpha.freqData(18))
    '<\terzWertS>' sprintf('%1.2f', thirdOctAlpha.freqData(19))
    '<\terzWertT>' sprintf('%1.2f', thirdOctAlpha.freqData(20))};


ita_fillInTemplate(  [protocolPath 'KundtGermanTemplate - Transmission.tex'], keyValueCell, texFileName);
fclose('all');

% kopieren schein einfacher als latex pfade mit leerzeichen erklären...
[stat res] = system(['copy "' [protocolPath protocolHeaderPNG] '" ']);

% create pdf
if ita_preferences('verboseMode') == 2
     system([texpath ' ' texFileName]) % mit ausgabe
 else
     [status result] = system([texpath ' ' texFileName]); % ohne ausgabe zur console
     if status
         error(result)
     end
end

% close(wbh);

% löscht überflüssige Dateien

%      open([probeFileName '.pdf']);
     delete(protocolHeaderPNG);
     delete([probeFileName '.log'] );
     delete([probeFileName '.aux'] );
     if exist([probeFileName '.bbl'], 'file')~=0
         delete([probeFileName '.bbl']);
     end
     if exist([probeFileName '.blg'],'file')~=0
         delete([probeFileName '.blg'] );
     end
     

 if delTexFile
     delete(texFileName);
 end
 if delPictureFile
     delete([probeFileName '.png']);
 end
 end

