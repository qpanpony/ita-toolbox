classdef itaKundtTubeMaterial < itaKundtTube
    %ITAKUNDTTUBEMATERIAL This class includes all parameters and the Gui required to
    %measure a Material with the Kundt's Tube at ITA
    %
    %With this Class you define your parameters for a Material:
    %       -> Name of DUT
    %       -> Temperature
    %       -> Air Humidity
    %       -> Description of DUT
    %       
    %And you can Run your Measurement here.
    %
    %Autor: Philipp Schwellenbach

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    %%
    properties(SetAccess = protected, GetAccess = protected, Hidden = true)
        %protected properties
        %default temperature
        mTemperature = [22];
        %default air humidity
        mAirHumidity = [0.5];
        %default name of DUT
        mNameOfDUT = 'insert name of DUT';
        %default description of DUT
        mDescriptionOfDUT = 'Materialbeschreibung: ____. Dicke ca. XY mm Passgenaue Platzierung der Samples im Probenhalter mit dichtem Abschluss zur Wandung. Einbau der Proben ohne Abstand vor dem schallharten Rohrabschluss.';
        %refection coefficient
        mReflectionCoefficient = [itaAudio(1)];
        %micData itaAudio
        mMicData = [itaAudio(1)];
        % history
        mHistory = '';
    end
    
    properties(Access = private,Hidden = true)
        %private properties
        isInitialized = false;
        micMeasured = [0];
        sampOrRepNum = 1;
    end
    
    properties(Dependent = true, Hidden = false)
        %dependent properties
        %default temperature
        temperature
        %default air humidity
        airHumidity
        %default name of DUT
        nameOfDUT
        %default description of DUT
        descriptionOfDUT
        %default reflection coefficient
        reflectionCoefficient
        %default micData, micData is kind of itaAudio class
        micData
        %default history
        history
    end
    
    methods%set/get functions for dependent properties
        
        function this = set.temperature(this,inStr)
            if ischar(inStr)
                inStr(strfind(inStr , '°')) = [];
                inStr(strfind(inStr , ',')) = '.';
                inVar = str2double(inStr);
                if isnan(inVar)
                    ita_verbose_info('Wrong input for temperature, look at class help (doc) for more information!',0);
                    if ishandle(this.mGuiHandleStruct.f)
                        errordlg('Wrong input for temperature, look at class help (doc) for more information!');
                    end
                else
                    this.mTemperature = inVar;
                end
            elseif isnumeric(inStr)
                this.mTemperature = inStr;
            else
                ita_verbose_info('Wrong input for temperature, look at class help (doc) for more information!',0);
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg('Wrong input for temperature, look at class help (doc) for more information!');
                end
            end
            if ishandle(this.mGuiHandleStruct.f)
                set(this.mGuiHandleStruct.temperatureEditField,'String',num2str(this.mTemperature));
            end
        end
        
        function value = get.temperature(this)
            value = this.mTemperature;
        end
        
        function this = set.airHumidity(this,inStr)
            if ischar(inStr)
                if strfind(inStr,'%') == []
                    inStr(strfind(inStr , ',')) = '.';
                    inVar = str2double(inStr);
                else
                    inStr(strfind(inStr , '%')) = [];
                    inStr(strfind(inStr , ',')) = '.';
                    inVar = str2double(inStr);
                    inVar = inVar/100;
                end
                if isnan(inVar) || inVar <= 0 || inVar >= 1
                    ita_verbose_info('Wrong input for air humidity, look at class help (doc) for more information!',0);
                    if ishandle(this.mGuiHandleStruct.f)
                        errordlg('Wrong input for air humidity, look at class help (doc) for more information!');
                    end
                else
                    this.mAirHumidity = inVar;
                end
            elseif isnumeric(inStr)
                this.mAirHumidity = inStr;
            else
                ita_verbose_info('Wrong input for air humidity, look at class help (doc) for more information!',0);
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg('Wrong input for air humidity, look at class help (doc) for more information!');
                end
            end
            if ishandle(this.mGuiHandleStruct.f)
                set(this.mGuiHandleStruct.airHumidityEditField,'String',num2str(this.mAirHumidity));
            end
        end
        
        function value = get.airHumidity(this)
            value = this.mAirHumidity;
        end
        
        function this = set.nameOfDUT(this,inStr)
            if ischar(inStr)
                this.mNameOfDUT = this.correctStr(inStr);
                if ishandle(this.mGuiHandleStruct.f)
                    set(this.mGuiHandleStruct.nameOfDUTEditField,'String',this.mNameOfDUT);
                end
            else
                ita_verbose_info('Wrong input for nameOfDUT, input should be a string!',0);
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg('Wrong input for nameOfDUT, input should be a string!');
                end
            end
        end
        
        function value = get.nameOfDUT(this)
            value = this.mNameOfDUT;
        end
        
        function this = set.descriptionOfDUT(this,inStr)
            if ischar(inStr)
                question = questdlg('you will delete the foreign description, are you sure?');
                if strcmpi(question,'yes')
                    this.mDescriptionOfDUT = this.correctStr(inStr);
                    if ishandle(this.mGuiHandleStruct.f)
                        set(this.mGuiHandleStruct.descrOfDUTEditField,'String',this.mDescriptionsOfDUT);
                    end
                end
            else
                ita_verbose_info('Wrong input for descriptionOfDUT, input should be a string!',0);
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg('Wrong input for descriptionOfDUT, input should be a string!');
                end
            end
        end
        
        function value = get.descriptionOfDUT(this)
            value = this.mDescriptionOfDUT;
        end
        
        function value = get.reflectionCoefficient(this)
            if ~isempty(this.mReflectionCoefficient(1))
                value = merge(this.mReflectionCoefficient);
                value.comment = [this.nameOfDUT ' - Number of ' this.sampleOrRepetition 's: ' sprintf('%i',this.sampOrRepNum) ' - reflection coefficient'];
            end
        end
        
        function value = get.micData(this)
            value = this.mMicData;
        end
        
        function value = get.history(this)
            value = this.mHistory;
        end
    end
    
    methods%other public methods
        function setKOT(this,inVar)
            ita_verbose_info('You can not change the Tube of your Material, close the Material Gui and create a new Material with your favorite kind of tube!',0);
        end
        function setMS(this,MSObj)
            ita_verbose_info('You can not change the Measurement Setup of your Material, close the Material Gui and create a new Material with your favorite Measurement Setup!',0);
        end
        %display
        function display(this)
            %Display function
            %displays all important information about the properties of the
            %itaKundtTube class object
            display@itaKundtTube(this);
            tab =  sprintf('\t');
            br = sprintf('\n');
            disp([tab tab tab 'Temperature: ' tab tab tab num2str(this.mTemperature) '°C']);
            disp([tab tab tab 'Air Humidity: ' tab tab tab num2str(this.mAirHumidity*100) '%']);
            disp([tab tab tab 'Name of DUT: ' tab tab tab this.mNameOfDUT]);
            disp([tab tab tab 'Description of DUT: ' tab this.mDescriptionOfDUT]);
            disp([tab tab tab 'History: ' tab tab tab this.mHistory br]);
            
            %links will be here
            
            disp([tab tab 'functions:' br]);
            disp([tab tab tab 'Alpha: ' tab '-.' sprintf('<a href = "matlab: this.apha;">alpha</a>') '.' sprintf('<a href = "matlab: this.apha.plotFrequency;">plotFrequency</a>')]);
        end
        
        %gui
        function gui(this)
            if ishandle(this.mGuiHandleStruct.f)
                delete(this.mGuiHandleStruct.f);
            end
            if this.isInitialized
                scrennSize = get(0,'ScreenSize');
                centerOfGUI = scrennSize(3:4)/2;        %central point of screen
                layout.defaultSpace     = 20;
                layout.compTxtHeight    = 12;           %standart text height
                layout.compBTxtHeight   = 10;           %standart button text height
                layout.bSize           = [120 20];      %standart button size
                layout.figSize          = [800 600];    %size of figure
                %layout.bPosition       = [layout.figSize(1)/2-170 layout.figSize(2) - 2*layout.defaultSpace-layout.compTxtHeight-layout.bSize(2) layout.bSize; layout.figSize(1)/2+170-120 layout.figSize(2)-2*layout.defaultSpace-layout.compTxtHeight-layout.bSize(2) layout.bSize];
                layout.bgColor = [0.8 0.8 0.8];       %standart background color
                layout.fontColor = 'blue';            %standart text color
                br =  sprintf('\n'); %new line
                tab =  sprintf('\t');%tab
                %creating a figure for gui
                h.f = figure('Visible','off',...
                    'NumberTitle', 'off',...
                    'Position',[centerOfGUI(1)-layout.figSize(1)/2+layout.defaultSpace, centerOfGUI(2)-layout.figSize(2)/2-2*layout.defaultSpace, layout.figSize],...
                    'Name','itaKundtTubeMaterial',...
                    'MenuBar', 'none',...
                    'Color', layout.bgColor,...
                    'CloseRequestFcn',{@figureCloseFcn,this});
                %creating headline
                h.txtHeadline = uicontrol('Style','text',...
                    'String','Parameters for KundtTubeMaterial class',...
                    'FontWeight','bold',...
                    'ForegroundColor','black',...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',15,...
                    'Position',[0,layout.figSize(2)-layout.defaultSpace-1.5*layout.compTxtHeight,layout.figSize(1),2*layout.compTxtHeight],...
                    'horizontalAlignment','center');
                %creating line
                h.line1 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-layout.defaultSpace-2*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                    'BackgroundColor',layout.bgColor,...
                    'HorizontalAlignment','left',...
                    'Style', 'frame');
                toolTipStr = ['Number of ' this.mSampleOrRepetition 'you are preparing'];
                %creating text for measurement setup edit button
                h.txtSampOrRepNum = uicontrol('Style','text',...
                    'String',[this.mSampleOrRepetition ' Number'],...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.defaultSpace,layout.figSize(2)-5*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString',toolTipStr);
                %creating measurement setup edit button
                h.txtSampOrRepNumShow = uicontrol('Style','text',...
                    'String',sprintf('%i',this.sampOrRepNum),...
                    'FontSize',layout.compBTxtHeight,...
                    'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-3.5*layout.defaultSpace,layout.bSize],...
                    'BackgroundColor',layout.bgColor,...
                    'TooltipString',toolTipStr);
                toolTipStr = [ 'You have to insert a string' br...
                    ' as a name of your DUT'];
                %creating text for Date
                h.txtNameOfDUT = uicontrol('Style','text',...
                    'String','Name of DUT',...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.defaultSpace,layout.figSize(2)-6.6*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString',toolTipStr);
                %creating edit field for Date
                h.nameOfDUTEditField = uicontrol('Style','edit',...
                    'String',this.mNameOfDUT,...
                    'FontSize',layout.compBTxtHeight,...
                    'Position',[layout.figSize(1)-2*layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-5.1*layout.defaultSpace,layout.bSize(1)*2,layout.bSize(2)],...
                    'TooltipString',toolTipStr);
                toolTipStr = 'You have to insert the current temperature';
                %creating text for examiner edit field
                h.txtTemperature = uicontrol('Style','text',...
                    'String','Temperature',...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.defaultSpace,layout.figSize(2)-8.1*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString','You have to insert the current temperature');
                %creating edit field for examiner
                h.temperatureEditField = uicontrol('Style','edit',...
                    'String',this.mTemperature(this.sampOrRepNum),...
                    'FontSize',layout.compBTxtHeight,...
                    'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-6.5*layout.defaultSpace,layout.bSize(1),layout.bSize(2)],...
                    'TooltipString',toolTipStr);
                toolTipStr = 'You have to insert the current air humidity!';
                %creating text for kindOfTube popup menu
                h.txtAirHumidity = uicontrol('Style','text',...
                    'String','Air Humidity',...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.defaultSpace,layout.figSize(2)-9.7*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString',toolTipStr);
                %creating popup menu for kindOfTube
                h.airHumidityEditField = uicontrol('Style','edit',...
                    'String',this.mAirHumidity(this.sampOrRepNum),...
                    'FontSize',layout.compBTxtHeight,...
                    'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-7.9*layout.defaultSpace,layout.bSize(1),layout.bSize(2)],...
                    'TooltipString',toolTipStr);
                toolTipStr = 'Enter a specific description for your DUT';
                %creating text for sample or repetition popup menu
                h.txtDescrOfDUT = uicontrol('Style','text',...
                    'String','Description of DUT',...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.defaultSpace,layout.figSize(2)-11.3*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString',toolTipStr);
                %creating popup menu for sample or repetition
                h.descrOfDUTEditField = uicontrol('Style','edit',...
                    'String',this.mDescriptionOfDUT,...
                    'FontSize',layout.compBTxtHeight,...
                    'Position',[layout.figSize(1)-3*layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-3*layout.bSize(2)-9.5*layout.defaultSpace,layout.bSize*3],...
                    'TooltipString',toolTipStr,...
                    'Max',10,...
                    'Min',0);
                %creating border line
                h.line3 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-13*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                    'BackgroundColor',layout.bgColor,...
                    'HorizontalAlignment','left',...
                    'Style', 'frame');
                toolTipStr = ['If you want to go on with your measurement you' br...
                    'have to click this button to enable the microphone buttons'];
                %creating text for save button
                h.txtOkBtn = uicontrol('Style','text',...
                    'String',['save ' this.mSampleOrRepetition sprintf(' %i',this.sampOrRepNum)],...
                    'FontWeight','bold',...
                    'ForegroundColor','black',...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.figSize(1)*2/3-layout.defaultSpace,layout.figSize(2)-15.5*layout.defaultSpace,layout.figSize(1)/4,2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString',toolTipStr);
                %creating save button
                h.okBtn = uicontrol('Style','togglebutton',...
                    'String','OK',...
                    'FontSize',layout.compBTxtHeight,...
                    'BackgroundColor',layout.bgColor,...
                    'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-14.7*layout.defaultSpace,layout.bSize(1),layout.bSize(2)*2],...
                    'Callback',{@toggleCallBack,this},...
                    'TooltipString',toolTipStr);
                toolTipStr = ['With clicking one of the microphone buttons you' br ...
                    'will start the measurement for the specific microphone position' br ...
                    'you have to measure all microphones to enable the calculation button!'];
                %creating border line
                h.line4 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-16.4*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                    'BackgroundColor',layout.bgColor,...
                    'HorizontalAlignment','left',...
                    'Style', 'frame');
                h.txtMeasurementRun = uicontrol('Style','text',...
                    'String','Measurement Run',...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.figSize(1)/4, layout.figSize(2)-17.4*layout.defaultSpace-2.5*layout.compTxtHeight, layout.figSize(1)/2, 2.5*layout.compTxtHeight],...
                    'horizontalAlignment','center',...
                    'TooltipString',toolTipStr);
                for idMic = 1:this.micNum
                    buttonTxt =  ['Mic' int2str(idMic)];
                    buttonToolTipTxt    = ['Run measurement at microphone position ' int2str(idMic) br...
                        'Red: Microphone disabled' br...
                        'Yellow: Microphone ready to measure' br...
                        'Green: Microphone position already measured']; %this text should be shown when the mouse moves over the textfield for the description
                    h.micBtn(idMic) = uicontrol('Style','pushbutton',...
                        'String',buttonTxt,...
                        'FontSize',layout.compBTxtHeight,...
                        'BackgroundColor',layout.bgColor,...
                        'Position',[layout.figSize(1)*idMic/(this.micNum+1)-layout.bSize(1)/2,layout.figSize(2)-17.9*layout.defaultSpace-2.5*layout.compTxtHeight-layout.bSize(2),layout.bSize],...
                        'Callback',{@micBtnCallBack,this},...
                        'TooltipString',buttonToolTipTxt,...
                        'Enable','off');
                    if this.micMeasured(idMic,this.sampOrRepNum)
                        color = 'g';
                    else
                        color = 'r';
                    end
                    ax(idMic+1) = subplot(100,100,25*idMic-10);
                    h.circle(idMic) = rectangle('Position',[100,100,50,50],'Linewidth',1,'Curvature',1,'facecolor',color);axis off
                    set(gca,'Units','pixel', 'Position', [layout.figSize(1)*idMic/(this.micNum+1)-10 layout.figSize(2)-19.4*layout.defaultSpace-2.5*layout.compTxtHeight-layout.bSize(2) 20 20]);
                end
                h.line5 = uicontrol('Position',[layout.defaultSpace/2, layout.figSize(2)-20.4*layout.defaultSpace-2.5*layout.compTxtHeight-layout.bSize(2), layout.figSize(1)-layout.defaultSpace, 1],...
                    'BackgroundColor',layout.bgColor,...
                    'HorizontalAlignment','left',...
                    'Style', 'frame');
                toolTipStr = ['This Button only enables if you have measured all microphones' br ...
                    'If you click this Button the reflection Coefficient is calculated' br...
                    'and you get a plot of alpha, the absorbtion coefficient.'];
                h.txtCal = uicontrol('Style','text',...
                    'String','Calculation',...
                    'FontWeight','bold',...
                    'ForegroundColor',layout.fontColor,...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.figSize(1)/4, layout.figSize(2)-21*layout.defaultSpace-5*layout.compTxtHeight-layout.bSize(2), layout.figSize(1)/2, 2.5*layout.compTxtHeight],...
                    'horizontalAlignment','center',...
                    'TooltipString',toolTipStr);
                h.calcBtn = uicontrol('Style','pushbutton',...
                    'String','Calculate',...
                    'FontSize',layout.compBTxtHeight,...
                    'FontWeight','bold',...
                    'BackgroundColor',layout.bgColor,...
                    'Position',[layout.figSize(1)*4/5-layout.bSize(1)/2,layout.figSize(2)-20.5*layout.defaultSpace-5*layout.compTxtHeight-layout.bSize(2),layout.bSize],...
                    'Callback',{@calcBtnCallback, this},...
                    'TooltipString',toolTipStr,...
                    'Enable','off');
                h.line6 = uicontrol('Position',[layout.defaultSpace/2, layout.figSize(2)-22.7*layout.defaultSpace-2.5*layout.compTxtHeight-layout.bSize(2), layout.figSize(1)-layout.defaultSpace, 1],...
                    'BackgroundColor',layout.bgColor,...
                    'HorizontalAlignment','left',...
                    'Style', 'frame');
                h.txtNewSampOrRep = uicontrol('Style','text',...
                    'String',['New ' this.mSampleOrRepetition],...
                    'FontWeight','bold',...
                    'ForegroundColor','black',...
                    'BackgroundColor',layout.bgColor,...
                    'FontSize',layout.compTxtHeight,...
                    'Position',[layout.figSize(1)*2/3, layout.figSize(2)-23.8*layout.defaultSpace-5*layout.compTxtHeight-layout.bSize(2), layout.figSize(1)/2, 2.5*layout.compTxtHeight],...
                    'horizontalAlignment','left',...
                    'TooltipString',toolTipStr);
                h.newSampOrRepBtn = uicontrol('Style','pushbutton',...
                    'String',['Go to ' this.mSampleOrRepetition sprintf(' %i',this.sampOrRepNum+1)],...
                    'FontSize',layout.compBTxtHeight,...
                    'FontWeight','bold',...
                    'BackgroundColor',layout.bgColor,...
                    'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-22.7*layout.defaultSpace-5*layout.compTxtHeight-2*layout.bSize(2),layout.bSize(1),2*layout.bSize(2)],...
                    'Callback',{@newSampOrRepCallback, this},...
                    'TooltipString',toolTipStr,...
                    'Enable','off');
                % ITA toolbox logo with grey background
                ax(1) = subplot(100,100,1);
                a_im = importdata(which('ita_toolbox_logo.png'));
                image(a_im);axis off
                set(gca,'Units','pixel', 'Position', [10 10 210 40]);
                %gui anzeigen
                set(h.f,'Visible','on');
                
                this.mGuiHandleStruct = h;
            end
        end
        
        function outAlpha = alpha(this)
            if ~isempty(this.mReflectionCoefficient)
                for iSampOrRep = 1:this.sampOrRepNum
                    outAlpha(iSampOrRep) = 1-abs(this.mReflectionCoefficient(iSampOrRep))^2; %alpha calculation formula from technical acustic 1 script
                    outAlpha(iSampOrRep).plotAxesProperties = {'xlim', this.measurementSetup.freqRange, 'ylim', [-0.1 1.1]};
                    outAlpha(iSampOrRep).allowDBPlot = false;
                    outAlpha(iSampOrRep).channelNames = {[this.nameOfDUT ' - ' this.sampleOrRepetition sprintf('%i',iSampOrRep) ' - absorbtion coefficient' ]};
                    outAlpha(iSampOrRep).comment = [this.nameOfDUT ' - Number of ' this.sampleOrRepetition 's: ' sprintf('%i',this.sampOrRepNum) ' - absorbtion coefficient = 1-abs(reflection coefficient)^2'];
                end
                outAlpha = merge(outAlpha);
            else
                ita_verbose_info('No results from measurment!',0)
            end
        end
        
        function imp = impedance(this)
            for iSampOrRep = 1:this.sampOrRepNum
                rho0    = ita_constants('rho_0', 'T', this.mTemperature(iSampOrRep), 'phi', this.mAirHumidity(iSampOrRep));
                c      = ita_constants('c',     'T', this.mTemperature(iSampOrRep), 'phi', this.mAirHumidity(iSampOrRep));
                imp(iSampOrRep) = rho0*c*this.specificImpedance.ch(iSampOrRep); %impedance calculation formula from technical acustic 1 script
                imp(iSampOrRep).plotAxesProperties = {'xlim', this.measurementSetup.freqRange};
                imp(iSampOrRep).allowDBPlot = false;
                imp(iSampOrRep).channelNames = {[this.nameOfDUT ' - ' this.sampleOrRepetition sprintf('%i',iSampOrRep) ' - impedance' ]};
                imp(iSampOrRep).comment = [this.nameOfDUT ' - Number of ' this.sampleOrRepetition 's: ' sprintf('%i',this.sampOrRepNum) ' - impedance = rho0 * c * specific impedance'];
            end
            imp = merge(imp);
        end
        
        function admit = admittance(this)
            admit = 1/(this.impedance);
            for iSampOrRep = 1:this.sampOrRepNum
                admit(iSampOrRep).plotAxesProperties = {'xlim', this.measurementSetup.freqRange};
                admit(iSampOrRep).allowDBPlot = false;
                admit(iSampOrRep).channelNames = {[this.nameOfDUT ' - ' this.sampleOrRepetition sprintf('%i',iSampOrRep) ' - admittance' ]};
                admit(iSampOrRep).comment = [this.nameOfDUT ' - Number of ' this.sampleOrRepetition 's: ' sprintf('%i',this.sampOrRepNum) ' - admittance = 1 / impedance'];
            end
            admit = merge(admit);
        end
        
        function specImp = specificImpedance(this)
            for iSampOrRep = 1:this.sampOrRepNum
                specImp(iSampOrRep) = (1+ this.mReflectionCoefficient(iSampOrRep))/(1-this.mReflectionCoefficient(iSampOrRep));%specific impedance calculation formula from technical acustic 1 script
                specImp(iSampOrRep).plotAxesProperties = {'xlim', this.measurementSetup.freqRange};
                specImp(iSampOrRep).allowDBPlot = false;
                specImp(iSampOrRep).channelNames = {[this.nameOfDUT ' - ' this.sampleOrRepetition sprintf('%i',iSampOrRep) ' - specific impedance' ]};
                specImp(iSampOrRep).comment = [this.nameOfDUT ' - Number of ' this.sampleOrRepetition 's: ' sprintf('%i',this.sampOrRepNum) ' - specific impedance = (1+ reflection coefficient) / (1- reflection coefficient)'];
            end
            specImp = merge(specImp);
        end
        
        function specAdmit = specificAdmittance(this)
            specAdmit = 1/this.specificImpedance;
            for iSampOrRep = 1:this.sampOrRepNum
                specAdmit(iSampOrRep).plotAxesProperties = {'xlim', this.measurementSetup.freqRange};
                specAdmit(iSampOrRep).allowDBPlot = false;
                specAdmit(iSampOrRep).channelNames = {[this.nameOfDUT ' - ' this.sampleOrRepetition num2Str(iSampOrRep) ' - specific admittance' ]};
                specAdmit(iSampOrRep).comment = [this.nameOfDUT ' - Number of ' this.sampleOrRepetition 's: ' sprintf('%i',this.sampOrRepNum) ' - specific admittance = 1 / specific impedance'];
            end
        end
        
        function createProtocol(this)
            this = 'todo';
            disp(this);
            itaKundtTubeMaterialCreateProtocol(this);
        end
        
        function sObj = saveobj(this)
            % Called when an object is saved
            %
            %saves the defined properties in a new struct
            propertylist = itaKundtTubeMaterial.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        %constructors
        function obj = itaKundtTubeMaterial(varargin)
            oldInformation = ita_getfrombase('informationOfLatestMaterial');
            if nargin
                invar = varargin{1} ;
            else
                invar = itaKundtTube(true);
                invar.guiStatus = false;
                
            end
            obj = obj@itaKundtTube(invar);
            switch obj.kindOfTube
                case 'Small Kundt''s Tube at ITA Mics1234'
                    obj.micNum = 4;
                otherwise
                    obj.micNum = 3;
            end
            obj.micMeasured = [zeros(obj.micNum,1)];
            switch nargin
                case {1}
                    if isa(varargin{1},'itaKundtTube')
                        obj.isInitialized = true;
                        if ~isempty(oldInformation)
                            oldInformation = ita_getfrombase('informationOfLatestMaterial');
                            obj.nameOfDUT = oldInformation.nameOfDUT;
                            obj.temperature = oldInformation.temperature;
                            obj.airHumidity = oldInformation.airHumidity;
                            obj.descriptionOfDUT = oldInformation.descriptionOfDUT;
                        end
                    elseif isstruct(varargin{1})||isa(varargin{1},'itaKundtTubeMaterial')
                        obj.mTemperature = varargin{1}.temperature;
                        obj.mAirHumidity = varargin{1}.airHumidity;
                        obj.mNameOfDUT = varargin{1}.nameOfDUT;
                        obj.mDescriptionOfDUT = varargin{1}.mDescriptionOfDUT;
                        obj.mReflectionCoefficient = varargin{1}.mReflectionCoefficient;
                        obj.mMicData = varargin{1}.mMicData;
                        obj.mHistory = varargin{1}.mHistory;
                        obj.sampOrRepNum = varargin{1}.sampOrRepNum;
                        obj.micMeasured = varargin{1}.micMeasured;
                        obj.isInitialized = true;
                    else
                        ita_verbose_info('Wrong input for itaKundtTubeMaterial Class constroctor, look at help for more information (doc)!',0)
                    end
                case 0
                    %initialisation
                    obj.isInitialized = true;
                    if ~isempty(oldInformation)
                        obj.nameOfDUT = oldInformation.nameOfDUT;
                        obj.temperature = oldInformation.temperature;
                        obj.airHumidity = oldInformation.airHumidity;
                        obj.mDescriptionOfDUT = oldInformation.descriptionOfDUT;
                    end
                otherwise
                    ita_verbose_info('To much input parameters for itaKundtTubeMaterial class constructor, look at help for more information (doc)!',0)
            end
            obj.gui;
        end
        function this = loadobj(sObj)
            % Called when an object is loaded
            %
            %Calls Constructor of itaKundtTube with input property. (the
            %constructor will take care
            %loadobj@itaKundtTube(sObj);
            this = itaKundtTubeMaterial(sObj);
        end
    end
    methods(Static,Access = protected)
        function result = propertiesSaved
            %defining the properties which will be saved
            result = propertiesSaved@itaKundtTube;
            result = [result, 'temperature','airHumidity','nameOfDUT','mDescriptionOfDUT','mReflectionCoefficient','mMicData','mHistory','sampOrRepNum','micMeasured'];
        end
    end
end


function figureCloseFcn(hObject,eventdata,this)
if ishandle(this.mGuiHandleStruct.f)
    question = questdlg('You want to save your material data?? it will be used for creating the next Material!');
    if strcmpi(question,'yes')
        oldInformation.nameOfDUT        = get(this.mGuiHandleStruct.nameOfDUTEditField,'String');
        oldInformation.temperature      = get(this.mGuiHandleStruct.temperatureEditField,'String');
        oldInformation.airHumidity      = get(this.mGuiHandleStruct.airHumidityEditField,'String');
        oldInformation.descriptionOfDUT = get(this.mGuiHandleStruct.descrOfDUTEditField,'String');
        ita_setinbase('informationOfLatestMaterial',oldInformation);
    end
end
delete(hObject);
end

function toggleCallBack(hObject,eventdata,this)
buttonOn = get(hObject,'Value');
if buttonOn
    this.mNameOfDUT = this.correctStr(get(this.mGuiHandleStruct.nameOfDUTEditField,'String'));
    set(this.mGuiHandleStruct.nameOfDUTEditField,'String',this.mNameOfDUT);
    temperatureHumidity= {'temperatureEditField';'airHumidityEditField';'termperature';'air humidity';'mTemperature';'mAirHumidity';'°';'%'};
    for idx=1:2
        inStr = get(this.mGuiHandleStruct.(temperatureHumidity{idx}),'String');
        inStr(strfind(inStr , temperatureHumidity{idx+6})) = [];
        inStr(strfind(inStr , ',')) = '.';
        inVar = str2double(inStr);
        if isnan(inVar) || (idx == 2 && inVar <= 0)
            set(hObject,'Value',0);
            errordlg(['wrong input for ' temperatureHumidity{idx+2}]);
            return
        else
            this.(temperatureHumidity{idx+4})(this.sampOrRepNum) = inVar;
        end
    end
    this.mDescriptionOfDUT = this.correctStr(get(this.mGuiHandleStruct.descrOfDUTEditField,'String'));
    set(this.mGuiHandleStruct.descrOfDUTEditField,'String',this.mDescriptionOfDUT);
    ita_setinbase(this.mNameOfDUT, this)
end
if buttonOn
    for idx = 1:this.micNum
        set(this.mGuiHandleStruct.micBtn(idx),'Enable','on');
        if ~this.micMeasured(idx,this.sampOrRepNum)
            set(this.mGuiHandleStruct.circle(idx),'facecolor','y');
        end
    end
    if all(this.micMeasured(:,this.sampOrRepNum))
        set(this.mGuiHandleStruct.calcBtn,'Enable','on');
    end
    set(this.mGuiHandleStruct.nameOfDUTEditField,'Enable','off');
    set(this.mGuiHandleStruct.temperatureEditField,'Enable','off');
    set(this.mGuiHandleStruct.airHumidityEditField,'Enable','off');
    set(this.mGuiHandleStruct.descrOfDUTEditField,'Enable','off');
else
    set(this.mGuiHandleStruct.calcBtn,'Enable','off');
    set(this.mGuiHandleStruct.newSampOrRepBtn,'Enable','off');
    for idx = 1:this.micNum
        set(this.mGuiHandleStruct.micBtn(idx),'Enable','off');
        if ~this.micMeasured(idx,this.sampOrRepNum)
            set(this.mGuiHandleStruct.circle(idx),'facecolor','r');
        end
    end
    if this.sampOrRepNum == 1
        set(this.mGuiHandleStruct.nameOfDUTEditField,'Enable','on');
        set(this.mGuiHandleStruct.descrOfDUTEditField,'Enable','on');
    end
    set(this.mGuiHandleStruct.temperatureEditField,'Enable','on');
    set(this.mGuiHandleStruct.airHumidityEditField,'Enable','on');
    
end
end


function micBtnCallBack(hObject,eventData,this)
% Initialization and Input Parsing
buttonName = get(hObject,'String');
iMic       = ita_str2num(buttonName(4:end));

% Get probe name
probename = this.mNameOfDUT;

% Run measurement
MS = this.mMeasurementSetup;
fprintf('Probename: ''%s''   Mikrofon: %i \n', probename, iMic);


% try
result = MS.run;
% catch
%     disp([name ' didn'' run correct']);
%     micnum = str2num(name(4));
%     this.micMeasured(micNum) = false;
%  return
% end

result.channelNames{1} = buttonName;
result.comment         = [probename ' - ' this.mSampleOrRepetition sprintf(' %i',this.sampOrRepNum)];


this.mMicData(iMic,this.sampOrRepNum) = result;

this.micMeasured(iMic,this.sampOrRepNum) = true;
set(this.mGuiHandleStruct.circle(iMic),'facecolor','g');

if all(this.micMeasured(:,this.sampOrRepNum))
    calcBtnCallback(this.mGuiHandleStruct.calcBtn,eventData,this);
    set(this.mGuiHandleStruct.calcBtn,'Enable','on');
end

end

function calcBtnCallback(hObject,eventData,this)
rawdata = merge(this.mMicData(:,this.sampOrRepNum));

%% Default Kundt_Setup

windowTime   = [0.2 0.3];


%% Calc

rawdata       = ita_time_shift(rawdata);
winData = ita_time_window(rawdata, windowTime ,'time','symmetric');

[Z , result]         = ita_kundt_calc_impedance(winData, this.mGeometry, this.temperature(this.sampOrRepNum), this.airHumidity(this.sampOrRepNum), this.measurementSetup.freqRange );
result.comment = [this.mNameOfDUT ' - ' this.mSampleOrRepetition sprintf(' %i',this.sampOrRepNum)];
result.channelNames = {result.comment};
this.mReflectionCoefficient(this.sampOrRepNum) = result;
this.mReflectionCoefficient(this.sampOrRepNum).plotAxesProperties = {'xlim', this.measurementSetup.freqRange, 'ylim', [-0.1 1.1]};
this.mReflectionCoefficient(this.sampOrRepNum).allowDBPlot = false;
this.mReflectionCoefficient(this.sampOrRepNum).channelNames = {[result.comment ' - reflection coefficient']};
this.mReflectionCoefficient(this.sampOrRepNum).comment = [result.comment ' - reflection coefficient - measured: ' datestr(this.mDate,'dd.mm.yyyy')];

ita_plot_freq(this.alpha)
ita_verbose_info('Calculation done', 2)


set(this.mGuiHandleStruct.newSampOrRepBtn,'Enable','on');

end

function newSampOrRepCallback(hObject,eventdata,this)
set(this.mGuiHandleStruct.temperatureEditField,'Enable','on');
set(this.mGuiHandleStruct.airHumidityEditField,'Enable','on');
set(this.mGuiHandleStruct.nameOfDUTEditField,'Enable','off');
set(this.mGuiHandleStruct.descrOfDUTEditField,'Enable','off');
set(this.mGuiHandleStruct.calcBtn,'Enable','off');
set(this.mGuiHandleStruct.micBtn,'Enable','off');
set(this.mGuiHandleStruct.circle,'facecolor','r');
this.sampOrRepNum = this.sampOrRepNum+1;
set(this.mGuiHandleStruct.txtSampOrRepNumShow,'String',this.sampOrRepNum);
set(this.mGuiHandleStruct.newSampOrRepBtn,'String',['Go to ' this.mSampleOrRepetition sprintf(' %i',this.sampOrRepNum+1)]);
this.micMeasured(:,this.sampOrRepNum) = zeros(this.micNum,1);
set(this.mGuiHandleStruct.okBtn,'Value',0);
set(this.mGuiHandleStruct.newSampOrRepBtn,'Enable','off');
this.mTemperature(this.sampOrRepNum) = this.mTemperature(this.sampOrRepNum-1);
this.mAirHumidity(this.sampOrRepNum) = this.mAirHumidity(this.sampOrRepNum-1);

end
