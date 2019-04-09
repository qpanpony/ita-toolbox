function ita_kundt_protocol(varargin)
%ITA_KUNDT_PROTOCOL - calculates loudness level of a signal according to DIN

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% TODO:
% - ita_parse_arguments verwenden...
% - auswähle wo pdf gespeichert wird?
% - zwei variablen 'humidity' und 'luftfeuchtigkeit', eine löschen
% - einheitliche dateinstruktur, mit raw daten, temperatur, anuahl der mics, mic positionen, ...
% - ita header anders, nur ita logi in toolbox, text mit tex
% - option fuer keine smooth => text in protokoll anpassen
% - Missing LOGO


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
    [files, pathName, ~] = uigetfile('*_raw.ita', 'MultiSelect','on');
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
    
    texpath = ita_preferences('miktexpath');
    
else % mgu mode
    inStruct = varargin{1};
    protocolLanguage = inStruct.protocolLanguage;
    linFreq = inStruct.linFreq;
    pathName = inStruct.pathName ;
    files    = inStruct.files;
    nameDerProbe = inStruct.nameDerProbe;
    texpath = [ '"' fullfile(inStruct.texpath, 'pdflatex.exe') '"'];
    
    currpath = pwd;
    cd(pathName)
    pause(0.1)
    if isequal(files,0)
        return
    end
    
    
end

%% Settings for postprocessing and plots
TimeWindow1 = [0.18 0.222];

x_lim = [80 8000];
y_lim = [0 1];

lWidthMean = 1.5;
lWidthStd = 1.1;


raw_data = ita_read(fullfile(files));
nMeasurements = numel(raw_data);

% datum der messung
if iscell(files)
    x = dir(files{1});
elseif ischar(files)
    x = dir(files);
end
datumDerMessung = datestr(x(1).datenum, 'dd.mm.yyyy');

% TODO: in GUI auswählen
protocolPath = [ita_toolbox_path filesep 'applications' filesep 'Measurement' filesep 'ImpedanceTube' filesep 'Protocol' filesep];

if strcmpi(protocolLanguage, 'german')
    templateFileName = [protocolPath 'KundtGermanTemplate.tex'];
elseif strcmpi(protocolLanguage, 'english')
    templateFileName = [protocolPath 'KundtEnglishTemplate.tex'];
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
    
    
else  % mgu mode, aka no GUI Mode
    nameDesPruefers             = inStruct.nameDesPruefers;
    temperatur                  = inStruct.temperatur;
    luftfeuchtigkeit            = inStruct.luftfeuchtigkeit*100;
    beschreibungDerProbe        = inStruct.beschreibungDerProbe;
    samplesOderWiederholungen   = inStruct.sampleOderWiederholungen;
    delPictureFile              = inStruct.delPicture;
    delTexFile                  = inStruct.delTexFile;
    smooth                      = inStruct.smooth;
    smooth_reps                 = inStruct.smootheReps;
    temp                        = inStruct.temperatur;
    humidity                    = inStruct.luftfeuchtigkeit;
end

if (~exist('Auswertung','dir'))
    mkdir('Auswertung');
end

probeFileName   = [ 'Auswertung/' strrep(strrep(nameDerProbe, ' ','_'), '.', ''), '_mean(' num2str(nMeasurements) ')' ];
texFileName     = [probeFileName '.tex'];
grafikName      = [probeFileName '_grafik.png'];


%% Start postprocessing

rawData_shifted = raw_data;

for iMeasurement = 1:nMeasurements
    rawData_shifted(iMeasurement) = ita_time_shift(raw_data(iMeasurement));
end



rawData_win= ita_time_window(rawData_shifted,TimeWindow1,'time','symmetric');

[absorption, Impedance] = deal(itaAudio(nMeasurements,1));

nChannels = rawData_win(1).nChannels;
if isfield(inStruct, 'geometry')
    KindOfTube = inStruct.geometry;
else
    if nChannels == 3
        KindOfTube = questdlg('Which tube have you used?','Kind of tube', 'smallTubeITA Mics123', 'Big Kundt''s Tube at ITA', 'Rohr mit Ohr' ,'smallTubeITA Mics123');
    else
        KindOfTube = 'smallTubeITA Mics1234';
    end
end
wbh = waitbar(0,'Create protocol...');
gesWaitbar = nMeasurements + smooth_reps;

for iMeasurement = 1:nMeasurements
    [Impedance(iMeasurement), Refl] = ita_kundt_calc_impedance(rawData_win(iMeasurement) , KindOfTube , temp, humidity);
    absorption(iMeasurement) = 1 - abs(Refl)^2 ;
    
    absorption(iMeasurement).channelNames = {rawData_win(iMeasurement).comment};
    waitbar(iMeasurement/gesWaitbar, wbh, 'calculate absorption');
end
absorption = absorption.merge;
absorption.comment = 'Absorption';


Impedance = Impedance.merge;
Impedance.channelNames = absorption.channelNames;
ita_write(Impedance, [probeFileName '_Impedance.ita'], 'overwrite')


% export absorption without smoothing
absorption.allowDBPlot = false;
absorption.plotAxesProperties = { 'xlim',[20 10000],'ylim',[-0.1 1.1]};
ita_write(absorption, [probeFileName '_noSmooth.ita'], 'overwrite')


%% from Martin Guski (2012-06-01) optional impedance polt
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
        
        % imp
        fgh = ita_plot_freq(pltstd,'nodb','xlim',x_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd);
        
        legend({nameDerProbe},'Interpreter','none', 'location', 'northwest');
        set(gca, 'TickDir', 'out', 'box', 'off')
        probeFileName = [ 'Auswertung/' strrep(nameDerProbe, ' ','_'),  '_' nameCell{i} '_mean(' num2str(nMeasurements) ')' ];
        
        if i ==2
            ylim([-1 1]* 5000)
        end
        %     title('')
        ylabel(sprintf('%s(impedance) [%s]',nameCell{i}, impMean.channelUnits{1} ))
        ita_saveplot('aspectRatio',0.5 , 'filename', probeFileName, 'figures', fgh, 'exportPNG', true)
        %         close(fgh)
    end
    
end
%% SMOOTH


absSmooth = absorption;
if ~isempty(smooth)
    
    for idxSmooth = 1:smooth_reps
        waitbar((nMeasurements+idxSmooth)/gesWaitbar, wbh, sprintf('smoothing %i / %i',idxSmooth, smooth_reps));
        absSmooth = ita_smooth(absSmooth, 'LogFreqOctave1', ita_str2num( smooth )/ smooth_reps, 'Real');
    end
    waitbar((nMeasurements+idxSmooth)/gesWaitbar, wbh, '');
    
    % save abs as itaResult
    absSmoothResult = itaResult(absSmooth);
    absSmoothResult.allowDBPlot = false;
    absSmoothResult.plotAxesProperties = { 'xlim',[20 10000],'ylim',[-0.1 1.1]};
    ita_write(absSmoothResult, [probeFileName '_smooth.ita'], 'overwrite')
    
end

%% mean & std: plot and save image
absMean = ita_mean(absSmooth);
absStd  = ita_std(absSmooth);


%% terzen der std exportieren
fgh = figure;
color = colormap; % Same color as plot before
color = color(1,:);

absMean.plotLineProperties = {'Color',color};
ita_plot_freq(absMean,'nodb','xlim',x_lim,'ylim',y_lim,'figure_handle', fgh, 'linewidth', lWidthMean, 'linfreq', linFreq);

pltstd = merge(absMean + absStd,absMean - absStd );
pltstd.plotLineProperties = {'LineStyle','--','Color',color};
fgh = ita_plot_freq(pltstd,'nodb','figure_handle',fgh,'hold','on', 'linewidth', lWidthStd, 'linfreq', linFreq);

legend({nameDerProbe},'Interpreter','none', 'location', 'best');

set(gca, 'TickDir', 'out', 'box', 'off')
set(fgh, 'position', [0 0 750 350])
axis([x_lim y_lim ])
ita_savethisplot(fgh,  grafikName, 'resolution', 300)
close(fgh)

%% calc third octave values

absMean2 = absMean;
absMean2.freqData([1:absMean2.freq2index(20) absMean2.freq2index(8000):end],:) = nan;
thirdOctAlpha = ita_spk2frequencybands(absMean2,'bandsPerOctave',3,'method','averaged','freqRange',[100 8000]);

%% fill in the latex template

keyValueCell   = { '<\itaBriefkopfBild>' protocolHeaderPNG;
    '<\datumDerMessung>' datumDerMessung;
    '<\nameDesPruefers>' nameDesPruefers
    '<\temperaturInGradC>' temperatur
    '<\luftfeuchtigkeit>'  luftfeuchtigkeit
    '<\nameDerProbe>'  nameDerProbe
    '<\anzahlDerMessungen>' num2str(nMeasurements)
    '<\samplesOderWiederholungen>'  samplesOderWiederholungen
    '<\dateinameGrafik>'  grafikName(12:end)
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


ita_fillInTemplate(templateFileName, keyValueCell, texFileName);
fclose('all');

% kopieren scheint einfacher als latex pfade mit leerzeichen erklären...
% This may be obsolte. Missing Logo
[~, ~] = system(['copy "' [protocolPath protocolHeaderPNG] '" ']);

% create pdf
cd 'Auswertung'
if ita_preferences('verboseMode') == 2
    system([texpath ' ' texFileName(12:end)]) % mit ausgabe
else
    [status, result] = system([texpath ' ' texFileName(12:end)]); % ohne ausgabe zur console
    if status
        cd(currpath)
        ita_verbose_info(['Running pdflatex failed with the error message: ', ...
            result ,'Please try running pdflatex manually'], 0);
        
    end
end

close(wbh);

delete(protocolHeaderPNG);
delete([probeFileName(12:end) '.log'] );
delete([probeFileName(12:end) '.aux'] );
if exist([probeFileName(12:end) '.bbl'], 'file')~=0
    delete([probeFileName(12:end) '.bbl']);
end
if exist([probeFileName(12:end) '.blg'],'file')~=0
    delete([probeFileName(12:end) '.blg'] );
end

if delTexFile
    delete(texFileName(12:end));
end
if delPictureFile
    delete([probeFileName(12:end) '.png']);
end


cd(currpath)

end

