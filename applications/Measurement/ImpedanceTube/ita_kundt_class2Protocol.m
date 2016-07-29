function ita_kundt_class2Protocol(varargin)

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if nargin==0
    ita_verbose_info('Not enough input for class2Protocol!',0);
else
    protocolPath = [ita_toolbox_path filesep 'applications' filesep 'Kundt' filesep 'Protocol' filesep];
    texpath = '"C:\Programme\MiKTeX 2.9\miktex\bin\pdflatex.exe"';
    protocolLanguage = 'german';
    templateFileName = 'KundtGermanTemplate.tex';
    linFreq = false;
    sArgs = struct('pos1_data','itaKundtTubeMaterial','language','german','linFreq',false','freqRange','auto');
    [x , sArgs]=ita_parse_arguments(sArgs,varargin);
    if strcmpi(sArgs.freqRange,'auto')
        sArgs.freqRange = sArgs.data.measurementSetup.freqRange;
    else
        freqRangeSave = sArgs.data.measurementSetup.freqRange;
        sArgs.data.measurementSetup.freqRange = sArgs.freqRange;
    end
    %%working with input
%    inSize=size(varargin);
%    if nargin==1
%         materialClass = varargin{1};
%     else
%     for idx=1:inSize(2)
%         if strcmpi(varargin(idx),'material')
%             materialClass = varargin{idx+1};
%         end
%         if strcmpi(varargin(idx),'language')
%             protocolLanguage = varargin{idx+1};
%             if strcmpi(protocolLanguage,'english')
%                 templateFileName = 'KundtEnglishTemplate.tex';
%             end
%         end
%         if strcmpi(varargin(idx),'linfreq')
%             if strcmpi(varargin(idx+1),'true')
%                 linFreq=true;
%             else
%                 linFreq = false;
%             end
%         end
%     end
%     end
    
    %% Settings for postprocessing and plots
    TimeWindow1 = [0.04 0.06];
    y_lim = [0 1];
    protocolHeaderPNG = 'KopfzeileGKB.png';
    probeFileName = [strrep(sArgs.data.nameOfDUT, ' ','_'), '_mean(' num2str(sArgs.data.reflectionCoefficient.nChannels) ')' ];
    texFileName = [probeFileName '.tex'];
    lWidthMean = 1.5;
    lWidthStd = 1.1;
    temperatur                  = mean(sArgs.data.temperature);
    luftfeuchtigkeit            = mean(sArgs.data.airHumidity)*100;
    delPictureFile              = true;
    delTexFile                  = true;
    temp     = temperatur;
    humidity = luftfeuchtigkeit/100;
    
    
    %% Start postprocessing
    absorption = itaAudio(sArgs.data.reflectionCoefficient.nChannels,1);
    
    
    wbh = waitbar(0,'Create protocol...');
    gesWaitbar = sArgs.data.reflectionCoefficient.nChannels + sArgs.data.measurementSetup.averages;
    absorption = sArgs.data.alpha;
    absorption.signalType = 'energy'
    absorption.comment = 'Absorption';
    
    %%
    % SMOOTH
    absSmooth = absorption;
    
    if ~isempty(sArgs.data.kindOfSmooth)
        for idxSmooth = 1:sArgs.data.measurementSetup.averages
            waitbar((sArgs.data.reflectionCoefficient.nChannels+idxSmooth)/gesWaitbar, wbh, sprintf('smoothing %i / %i',idxSmooth, sArgs.data.measurementSetup.averages));
            absSmooth = ita_smooth(absSmooth, 'LogFreqOctave1', ita_str2num( sArgs.data.kindOfSmooth )/ sArgs.data.measurementSetup.averages, 'Real');
        end
    end
    waitbar((sArgs.data.reflectionCoefficient.nChannels+idxSmooth)/gesWaitbar, wbh, '');
    %% plot and save image
    absMean = ita_mean(absSmooth);
    absStd  = ita_std(absSmooth);
    
    
    fgh = figure;
    color = colormap; % Same color as plot before
    color = color(1,:);
    
    absMean.plotLineProperties = {'Color',color};
    ita_plot_freq(absMean,'nodb','xlim',sArgs.freqRange,'ylim',y_lim,'figure_handle', fgh, 'linewidth', lWidthMean, 'linfreq', linFreq);
    
    pltstd = merge(absMean + absStd,absMean - absStd );
    pltstd.plotLineProperties = {'LineStyle','--','Color',color};
    fgh = ita_plot_freq(pltstd,'nodb','xlim',sArgs.freqRange,'ylim',y_lim,'figure_handle',fgh,'hold','on', 'linewidth', lWidthStd, 'linfreq', linFreq);
    
    
    
    
    
    lgh = legend({sArgs.data.nameOfDUT},'Interpreter','none', 'location', 'best');
    
    
    set(gca, 'TickDir', 'out', 'box', 'off')
    probeFileName = [strrep(sArgs.data.nameOfDUT, ' ','_'), '_mean(' num2str(sArgs.data.reflectionCoefficient.nChannels) ')' ];
    grafikName = [probeFileName '_grafik.png'];
    set(fgh, 'position', [0 0 750 350])
    ita_savethisplot(fgh,  grafikName, 'resolution', 300)
    close(fgh)
    
    %%
    % calc third octave values
    absMean2 = absMean;
    absMean2.freqData([1:absMean2.freq2index(100) absMean2.freq2index(8000):end],:) = nan;
    thirdOctAlpha = ita_spk2frequencybands(absMean2,'bandsPerOctave',3,'method','averaged','freqRange',sArgs.freqRange);
    
    
    % fill in the template
    keyValueCell   = { '<\itaBriefkopfBild>' protocolHeaderPNG;
        '<\datumDerMessung>' sArgs.data.Date;
        '<\nameDesPruefers>' sArgs.data.examiner
        '<\temperaturInGradC>' temperatur
        '<\luftfeuchtigkeit>'  luftfeuchtigkeit
        '<\nameDerProbe>'  sArgs.data.nameOfDUT
        '<\anzahlDerMessungen>' num2str(sArgs.data.reflectionCoefficient.nChannels)
        '<\samplesOderWiederholungen>'  sArgs.data.sampleOrRepetition
        '<\dateinameGrafik>'  grafikName
        '<\smoothParameter>'  sArgs.data.kindOfSmooth
        '<\beschreibungDesMaterials>'  sArgs.data.descriptionOfDUT
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
    
    texFileName = [probeFileName '.tex'];
    ita_fillInTemplate(templateFileName, keyValueCell, texFileName);
    fclose('all');
    
    
    
    % kopieren schein einfacher als latex pfade mit leerzeichen erklären...
    [stat res] = system(['copy "' [protocolPath protocolHeaderPNG] '" ']);
    
    % create pdf
    if ita_preferences('verboseMode') == 2
        system([texpath ' ' texFileName]) % mit ausgabe
    else
        [status result] = system([texpath ' ' texFileName]); % ohne ausgabe zur console
    end
    
    close(wbh);
    %
    % löscht überflüssige Dateien
    try
        open([probeFileName '.pdf']);
        delete(protocolHeaderPNG);
        delete([probeFileName '.log'] );
        delete([probeFileName '.aux'] );
        if exist([probeFileName '.bbl'], 'file')~=0
            delete([probeFileName '.bbl']);
        end
        if exist([probeFileName '.blg'],'file')~=0
            delete([probeFileName '.blg'] );
        end
        
        % TODO: Order in itaToolbox wo Template und header dring liegt
    catch %#ok<CTCH>
        warning('Please, insert your path of miktex in linie 33. In addition there could be difficulties with your tex file. Please try to compile it separately.') %#ok<WNTAG>
    end
    
    if delTexFile
        delete(texFileName);
    end
    if delPictureFile
        if exist([probeFileName '.png'],'file')
            delete([probeFileName '.png']);
        end
    end
    if exist('freqRangeSave','var')
    sArgs.data.measurementSetup.freqRange = freqRangeSave;
    end
end
end



