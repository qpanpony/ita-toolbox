classdef itaKundtTube < itaHandle
    %ITAKUNDTTUBE This class includes all parameters and the Gui required for
    %initialization of measurements with the Kundt's Tube at ITA
    %
    %With this Class you define your parameters for a measurement:
    %       -> Date
    %       -> Examiner
    %       -> Kind of Tube
    %       -> Sample or Repetition
    %       -> Kind of Smooth
    %       -> ITA Measurement Setup
    %
    % Autor: Philipp Schwellenbach

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    %%
    %protected properties
    properties(SetAccess = protected, GetAccess = protected, Hidden = true)
        %%protected property for kind Of Tube
        %default
        mKindOfTube = 'Small Kundt''s Tube at ITA Mics1234';
        
        %protected property for examiner
        mExaminer = ita_preferences('AuthorStr');%default
        
        %protected property for Sample or Repetition
        mSampleOrRepetition = 'Sample';%default
        
        %protected property for  kind of Smooth
        mKindOfSmooth = '1/12';%default
        
        %protected property for Measuremet Setup (is kind of class itaMSTF)
        mMeasurementSetup
        
        %protected property for geometry of Tube
        mGeometry = [100e-3 17e-3 110e-3 400e-3];%default
        
        %protected property for Date(date is saved as a number)
        mDate = datenum(date); %default
        
        %protected property saving gui data
        mGuiHandleStruct
        %protected property for number of materials with this setup
        newMatNum = 0;
        %
        mGuiStatus = true;
        %default savePath(not used and not finished)
        %savePath = ita_preferences('DataPath');
        micNum = 4;
        guiStatus = true;
    end
    
    %%
    %private properties
    properties(Access = private,Hidden = true)
        
        %private property for kind of Tube Popup Menu Value
        kindOfTubeValue = 1;%default
        %protected property for sample of repetition Popup Menu Value
        sampOrRepValue = 1;%default
        %protected property for kind of smooth Popup Menu Value
        kindOfSmValue = 4;%default
        %private property for upper frequency range of small kundt's tube
        smallTubeFreqRange = 12000; %default
        %private property for upper frequency range of tube with ear
        tubeWEarFreqRange = 12000;%default
        %private property for upper frequency range of big tube
        bigTubeFreqRange = 3000;%default
        %gui opens
        guiOpensVar = 0;
        geometrySmall4 = [100e-3  17e-3  110e-3  400e-3];
        geometrySmall3 = [ 100e-3 17e-3 110e-3 ];
        geometryBig = [ 205e-3 80e-3 130e-3 ];
        geometryTubeWithEar = [ 25e-3 07e-3 40e-3 ];
    end
    %%
    properties(Dependent = true, Hidden = false)%dependet properties(with their set/get functions we set/get our protected properties)
        %dependent property for kind of tube
        %
        %default: Small Kundt's Tube at ITA Mics1234
        %What to insert:
        %
        %Insert possibilities for Integers:
        %
        %			4	->	Small Kundt's Tube (4 Microphones)
        %			3	->	Small Kundt's Tube (3 Microphones)
        %			2	->	Big Kundt's Tube
        %			1	->	Tube with Ear
        %
        %           Example: classobj.kindOfTube = 4;
        %
        %Insert possibilities for Strings:
        %			Small Kundt's Tube (4 Microphones)
        %               small4
        %               small mics4
        %               small mics1234
        %               small kundt's tube at ita mics1234
        %               default
        %
        %			Small Kundt's Tube (3 Microphones)
        %				small3
        %				small mics3
        %				small sics123
        %				small sundt's sube at ita mics123
        %
        %			Big Kundt's Tube
        %				big kundt's tube at ita
        %				big
        %
        %			Tube with Ear
        %				rohr mit ohr
        %				ohr
        %				ear
        %				tube with ear
        %
        %               Example: classobj.kindOfTube = 'small3';
        kindOfTube
        
        %dependent property tor examiner
        %
        %You should insert your name. It has to be a string:
        %Example: classobj.examiner = 'Matthias Examiner';
        examiner
        
        %dependent property for sample or repetition
        %
        %You can insert sample Or Repetition as strings
        %
        %   Example: classobj.sampleOrRepetition = 'sample';
        %
        %Or as Integer
        %   1   ->  sample
        %   2   ->  repetition
        %
        %   Example: classobj.sampleOrRepetition = 2;
        sampleOrRepetition
        %dependent property for kind of smooth
        %
        %You can insert kind Of Smooth as a double and as a string:
        %   Double      String
        %     1           '1'
        %    1/3         '1/3'
        %    1/6         '1/6'
        %    1/12        '1/12'
        %    1/24        '1/24'
        %
        %   Example: classobj.kindOfSmooth = 1/3; or classobj.kindOfSmooth = '1/24';
        kindOfSmooth
        %dependent property for measurement setup
        %You have to insert a kind of itaMSTF class
        %   Example: classobj.measurementSetup = itaMSTF(...); (for ... look at itaMSTF class
        measurementSetup
        %dependent property for date
        %
        %You have to insert a correct date string
        % Example: classobj.Date = datestr('29.05.2012','dd.mm.yyyy') (for more information look at date functions)
        Date
        %not used savepath propertie
        %savePath = ita_preferences('DataPath');
    end
    %%
    methods%set/get functions for dependent properties        
        %set function for kindOfTube with check
        function this = set.kindOfTube(this,inVar)
            this.setKOT(inVar);
        end
        
        %get functions for kind of tube
        function value = get.kindOfTube(this)
            value = this.mKindOfTube;
        end
        
        %set function for examiner with check
        function this = set.examiner(this,inStr)
            if ischar(inStr)
                this.mExaminer = this.correctStr(inStr);
            else
                ita_verbose_info('Invalid input for Examiner. Pls insert a string!',0)
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg('Invalid input for Examiner. Pls insert a string!');
                end                
            end
            if ishandle(this.mGuiHandleStruct.f)
                delete(this.mGuiHandleStruct.f);
                this.gui
            end
        end
        
        %get function for examiner
        function value = get.examiner(this)
            value = this.mExaminer;
        end
        
        %set function for sample or repetition with check
        function this = set.sampleOrRepetition(this,inStr)
            inStr(strfind(inStr , ' ')) = [];
            inStr = lower(inStr);
            kindOfInput = {'s','samp','sample';'r','rep','repetition'}; %possibilities for sample or repetition input
            outStr = 'Invalid input for Sample or Repetition! Pls insert itaKundtTube class help (doc) for more information!';
            switch inStr
                case kindOfInput(1,:)     %case sample
                    this.mSampleOrRepetition = 'Sample';
                    this.sampOrRepValue = 1;
                case kindOfInput(2,:)     %case repetition
                    this.mSampleOrRepetition = 'Repetition';
                    this.sampOrRepValue = 2;
                otherwise                 %all other cases
                    ita_verbose_info(outStr,0)
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg(outStr);
                end                     
            end
            if ishandle(this.mGuiHandleStruct.f)
                delete(this.mGuiHandleStruct.f);
                this.gui
            end
        end
        
        %get function for sample or repetition
        function value = get.sampleOrRepetition(this)
            value = this.mSampleOrRepetition;
        end
        
        %set function for kind of smooth with check
        function this = set.kindOfSmooth(this,val)
            outStr = sprintf('Invalid input for Kind of Smooth, pls insert itaKundtTube class help (doc) for more information');
            if ischar(val)    %checks if input is a char
                switch val
                    case '1/1'      %with checking for strings
                        this.mKindOfSmooth = '1/1';
                        this.kindOfSmValue = 1;
                    case '1/3'
                        this.mKindOfSmooth = '1/3';
                        this.kindOfSmValue = 2;
                    case '1/6'
                        this.mKindOfSmooth = '1/6';
                        this.kindOfSmValue = 3;
                    case {'1/12','default'}
                        this.mKindOfSmooth = '1/12';
                        this.kindOfSmValue = 4;
                    case '1/24'
                        this.mKindOfSmooth = '1/24';
                        this.kindOfSmValue = 5;
                    otherwise             %all other chars
                        ita_verbose_info(outStr,0)
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg(outStr);
                end                         
                end
            else
                switch round(val*10)                %checks doubles by multiply with 100 and rounding
                    case 100
                        this.mKindOfSmooth = '1/1';
                    case 33
                        this.mKindOfSmooth = '1/3';
                    case 17
                        this.mKindOfSmooth = '1/6';
                    case 8
                        if idx == 1
                            this.mKindOfSmooth = '1/12';
                        end
                    case 4
                        this.mKindOfSmooth = '1/24';
                    otherwise
                        if round(val*10) == 3
                            this.mKindOfSmooth = '1/3';
                        else
                            ita_verbose_info(outStr,0);
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg(outStr);
                end                             
                        end
                end
            end
            if ishandle(this.mGuiHandleStruct.f)
                delete(this.mGuiHandleStruct.f);
                this.gui
            end            
        end
        %get function for kind of smooth
        function value = get.kindOfSmooth(this)
            value = this.mKindOfSmooth;
        end
        %set function for measurement Setup
        function this = set.measurementSetup(this,MSObj)
            this.setMS(MSObj);
        end
        %get function for measurement Setup
        function value = get.measurementSetup(this)
            value = this.mMeasurementSetup;
        end
        %set function for date
        function this = set.Date(this,dateStr)
            checkeddate = ita_checkDate(dateStr); % changed by rbo
            if checkeddate.valid  ==  1
                str = [checkeddate.day '.' checkeddate.month '.' checkeddate.year];
                this.mDate = datenum(str,'dd.mm.yyyy');
            else
                this.mDate = datenum(date);
                ita_verbose_info('Invalid input for Date. Pls insert a date string! \n \n \t Date was set to NOW',0)
                if ishandle(this.mGuiHandleStruct.f)
                    errordlg('Invalid input for Date. Pls insert a date string! \n \n \t Date was set to NOW');
                end 
            end
            if ishandle(this.mGuiHandleStruct.f)
                delete(this.mGuiHandleStruct.f);
                this.gui
            end
        end
        %get function for date
        function value = get.Date(obj)
            value = datestr(obj.mDate,'dd.mm.yyyy');
        end
        
        function this = set.guiStatus(this,inBool)
            if inBool
                set(this.mGuiHandleStruct.f,'Visible','on');
                this.mGuiStatus = true;
            else
                this.mGuiStatus = false;
                set(this.mGuiHandleStruct.f,'Visible','off');
            end
        end
    end
    
    %%
    methods%other public methods
        function setMS(this,MSObj)
            if isa(MSObj,'itaMSTF')
                this.mMeasurementSetup = MSObj;
            else
                ita_verbose_info('Invalid input, pls insert an object of Type ita Measurement Setup class (itaMSTF)!',0)
                
            end
        end
        
        function setKOT(this,inVar)
                    %small tube possibilities
            kindsOfTubeSmall = {'small4','smallmics4','smallmics1234','smallkundt''stubeatitamics1234';...
                'small3','smallmics3','smallmics123','smallkundt''stubeatitamics123'};
            %big tube possibilities
            kindsOfTubeBig = {'bigkundt''stubeatita','big'};
            %tube with ear possibilities
            kindsOfTubeEar = {'rohrmitohr','ohr','ear','tubewithear'};
            %output string for invalid input
            outStr = sprintf('Invalid input for Kind of Tube! Pls look at itaKundtTube class help (doc) for more information!');
            
            %sprintf('%s, ' , kindsOfTubeSmall{:})
            
            
            upperFreqRange = this.mMeasurementSetup.freqRange(2); %temp propertie for freqRange
            
            
            if ischar(inVar)%char possibility
                inVar(strfind(inVar , ' ')) = [];
                inVar = lower(inVar);
                switch inVar
                    case kindsOfTubeSmall(1,:)    %case small tube 4 mics
                        this.mKindOfTube = 'Small Kundt''s Tube at ITA Mics1234';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 1;
                        this.mGeometry = this.geometrySmall4;
                        this.micNum = 4;
                    case 'default'                %default case = small tube 4 mics
                        this.mKindOfTube = 'Small Kundt''s Tube at ITA Mics1234';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 1;
                        this.mGeometry = this.geometrySmall4;
                        this.micNum = 4;
                    case kindsOfTubeSmall(2,:)    %case small tube 3 mics
                        this.mKindOfTube = 'Small Kundt''s Tube at ITA Mics123';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 2;
                        this.mGeometry = this.geometrySmall3;
                        this.micNum = 3;
                    case kindsOfTubeBig           %case big tube
                        this.mKindOfTube = 'Big Kundt''s Tube at ITA';
                        this.mMeasurementSetup.freqRange(2) = this.bigTubeFreqRange;
                        this.kindOfTubeValue = 3;
                        this.mGeometry = this.geometryBig;
                        this.micNum = 3;
                    case kindsOfTubeEar           %case tube with ear
                        this.mKindOfTube = 'Rohr mit Ohr';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 4;
                        this.mGeometry = this.geometryTubeWithEar;
                        this.micNum = 3;
                    otherwise                 %all other string cases
                        ita_verbose_info(outStr,0)
                        if ishandle(this.mGuiHandleStruct.f)
                            errordlg(outStr);
                        end                         
                end
            else %all other possibilities
                switch inVar %integer possibility
                    case 4
                        this.mKindOfTube = 'Small Kundt''s Tube at ITA Mics1234';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 1;
                        this.mGeometry = this.geometrySmall4;
                        this.micNum = 4;
                    case 3
                        this.mKindOfTube = 'Small Kundt''s Tube at ITA Mics123';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 2;
                        this.mGeometry = this.geometrySmall3;
                        this.micNum = 3;
                    case 2
                        this.mKindOfTube = 'Big Kundt''s Tube at ITA';
                        this.mMeasurementSetup.freqRange(2) = this.bigTubeFreqRange;
                        this.kindOfTubeValue = 3;
                        this.mGeometry = this.geometryBig;
                        this.micNum = 3;
                    case 1
                        this.mKindOfTube = 'Rohr mit Ohr';
                        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
                        this.kindOfTubeValue = 4;
                        this.mGeometry = this.geometryTubeWithEar;
                        this.micNum = 3;
                    otherwise
                        ita_verbose_info(outStr,0)    %all other non-string cases
                        if ishandle(this.mGuiHandleStruct.f)
                            errordlg(outStr);
                        end                         
                end
            end
            %changed frequency range??
            str = '';
            if  upperFreqRange~= this.mMeasurementSetup.freqRange(2)  %checks if frequency range has changed
                if ishandle(this.mGuiHandleStruct.f)                    %checks if gui is open
                    %set information in gui
                    timestr = datestr(now,'HH:MM:SS');
                    infostr = get(this.mGuiHandleStruct.infoListBox,'String');
                    sizeOfInfo = size(infostr);
                    for idx = 1:sizeOfInfo
                        str =  [str '|' infostr(idx,:)];
                    end
                    outStr = sprintf(' You changed the upper value of frequency range to %i.(In Measurement Setup)',this.mMeasurementSetup.freqRange(2));
                    str = [timestr outStr str];
                    
                end
                %set information in command window
                ita_verbose_info(sprintf('You changed the upper frequency range to %i! (In your Measurement Setup)',this.mMeasurementSetup.freqRange(2)),0)
                        if ishandle(this.mGuiHandleStruct.f)
                            errordlg(outStr);
                        end 
            end
            
            %names = fieldnames(this.mGuiHandleStruct);
            
            if ishandle(this.mGuiHandleStruct.f)
                delete(this.mGuiHandleStruct.f);
                this.gui
                if ~isa(this,'itaKundtTubeMaterial')
                set(this.mGuiHandleStruct.infoListBox,'String',str);
                end
            end
        end        
        
        function display(this)
            %Display function
            %displays all important information about the properties of the
            %itaKundtTube class object
            br =  sprintf('\n');
            tab =  sprintf('\t');
            disp([br tab 'This Property is kind of the itaKundtTube class']);
            disp([br tab tab tab 'Date of examination: ' tab datestr(this.mDate,'dd.mm.yyyy')]);
            disp([tab tab tab 'Name of examiner: ' tab tab this.mExaminer]);
            disp([tab tab tab 'Kind of Tube: ' tab tab tab this.mKindOfTube]);
            disp([tab tab tab 'Samples or Repetition: ' tab this.mSampleOrRepetition]);
            disp([tab tab tab 'Kind of smooth: ' tab tab this.mKindOfSmooth]);
            str = [num2str(this.mGeometry(1)) ' (Distanze from DUT to Mic1)'];
            if ita_preferences('verboseMode')~= 0
            disp([tab tab tab 'Geometry of Tube: ' tab tab str]);
            Size = size(this.mGeometry,2);
            for idx = 2:Size
                str = [ num2str(this.mGeometry(idx)) sprintf('(Distance from Mic%i to Mic%i)',idx-1,idx)];
                disp([tab tab tab tab tab tab tab tab tab str])
            end
            disp([tab tab tab 'Number of created Materials: ' tab tab num2str(this.newMatNum)]);
            end
            
        end
        
        function gui(this)
            %Generate GUI
            %In the Gui of itaKundtTube Class you see all possibilities for
            %your measurement with one of the Tubes at ITA
            % If you chance one of the initializations in the GUI you have
            % to overwrite the defaultparameters with the 'SAVE
            % CANGES'-OK-BUTTON.
            %
            %With click on 'NEW MATERIAL'-BUTTON you will create a new object
            %of itaKundtTubeMaterial class which comprised the material
            %dependent parameters for your measurement.
            %
            %If the GUI changes same parameters you have set before, you will
            %see this in the Information Listbox
            scrennSize = get(0,'ScreenSize');
            centerOfGUI = scrennSize(3:4)/2;        %central point of screen
            layout.figSize          = [800 550];    %size of figure
            layout.defaultSpace     = 20;
            layout.compTxtHeight    = 12;           %standart text height
            layout.compBTxtHeight   = 10;           %standart button text height
            layout.bSize           = [120 20];      %standart button size
            %layout.bPosition       = [layout.figSize(1)/2-170 layout.figSize(2) - 2*layout.defaultSpace-layout.compTxtHeight-layout.bSize(2) layout.bSize; layout.figSize(1)/2+170-120 layout.figSize(2)-2*layout.defaultSpace-layout.compTxtHeight-layout.bSize(2) layout.bSize];
            layout.bgColor = [0.8 0.8 0.8];       %standart background color
            layout.fontColor = 'blue';            %standart text color
            br =  sprintf('\n'); %new line
            tab =  sprintf('\t');%tab
            %creating a figure for gui
            h.f = figure('Visible','off',...
                'NumberTitle', 'off',...
                'Position',[centerOfGUI(1)-layout.figSize(1)/2,centerOfGUI(2)-layout.figSize(2)/2, layout.figSize],...
                'Name','itaKundtTube',...
                'MenuBar', 'none',...
                'Color', layout.bgColor);
            %creating information window (is not in the right order, has to be infront of the kind of tube menu)
            h.infoListBox = uicontrol('Style','Listbox',...
                'String','',...
                'ForegroundColor','red',...
                'FontSize',layout.compBTxtHeight-2,...
                'Position',[layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-22*layout.defaultSpace,layout.figSize(1)/2,4*layout.defaultSpace],...
                'horizontalAlignment','left');
            %creating headline
            h.txtHeadline = uicontrol('Style','text',...
                'String','Parameters for KundtTube class',...
                'FontWeight','bold',...
                'ForegroundColor','black',...
                'FontSize',15,...
                'Position',[0,layout.figSize(2)-layout.defaultSpace-1.5*layout.compTxtHeight,layout.figSize(1),2*layout.compTxtHeight],...
                'horizontalAlignment','center',...
                'BackgroundColor',layout.bgColor);
            %creating line
            h.line1 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-layout.defaultSpace-2*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                'BackgroundColor',layout.bgColor,...
                'HorizontalAlignment','left',...
                'Style', 'frame');
            toolTipStr = ['With clicking the Button,' br ...
                'you will open the measurement.edit GUI' br ...
                'where you can change all parameters of itaMSTF class!'];
            %creating text for measurement setup edit button
            h.txtMSedit = uicontrol('Style','text',...
                'String','Measurement Setup',...
                'FontWeight','bold',...
                'ForegroundColor',layout.fontColor,...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.defaultSpace,layout.figSize(2)-5*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString',toolTipStr);
            %creating measurement setup edit button
            h.buttonMSedit = uicontrol('Style','pushbutton',...
                'String','Edit Setup',...
                'FontSize',layout.compBTxtHeight,...
                'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-3.5*layout.defaultSpace,layout.bSize],...
                'Callback',{@MSedit,this.mMeasurementSetup},...
                'BackgroundColor',layout.bgColor,...
                'TooltipString',toolTipStr);
            %creating line
            h.line2 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-layout.defaultSpace-4*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                'BackgroundColor',layout.bgColor,...
                'HorizontalAlignment','left',...
                'Style', 'frame');
            toolTipStr = [ 'You have to insert a date string' br tab ...
                '''dd.mm.yyy''' br tab ...
                'or ''dd-3 letters of month-yyyy''' br tab ...
                'or ''dd mm yyyy''!'];
            %creating text for Date
            h.txtdate = uicontrol('Style','text',...
                'String','Date',...
                'FontWeight','bold',...
                'ForegroundColor',layout.fontColor,...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.defaultSpace,layout.figSize(2)-7*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString',toolTipStr);
            %creating edit field for Date
            h.dateEditField = uicontrol('Style','edit',...
                'String',datestr(this.mDate,'dd.mm.yyyy'),...
                'FontSize',layout.compBTxtHeight,...
                'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-5.5*layout.defaultSpace,layout.bSize],...
                'TooltipString',toolTipStr);
            %creating text for examiner edit field
            h.txtExaminer = uicontrol('Style','text',...
                'String','Examiner',...
                'FontWeight','bold',...
                'ForegroundColor',layout.fontColor,...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.defaultSpace,layout.figSize(2)-8.5*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString','You have to insert the name of the examiner!');
            %creating edit field for examiner
            h.examinerEditField = uicontrol('Style','edit',...
                'String',this.mExaminer,...
                'FontSize',layout.compBTxtHeight,...
                'Position',[layout.figSize(1)-layout.bSize(1)*2-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-6.9*layout.defaultSpace,layout.bSize(1)*2,layout.bSize(2)],...
                'TooltipString','You have to insert the name of the examiner!');
            toolTipStr = ['You have to choose the kind of tube you want to use.' br ...
                'Changing kind of tube may change some parameters in your measurement setup!'];
            %creating text for kindOfTube popup menu
            h.txtKindOfTube = uicontrol('Style','text',...
                'String','Kind of Tube',...
                'FontWeight','bold',...
                'ForegroundColor',layout.fontColor,...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.defaultSpace,layout.figSize(2)-10.1*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString',toolTipStr);
            %creating popup menu for kindOfTube
            h.kindOfTubeMenu = uicontrol('Style','popupmenu',...
                'String',{'Small Kundt''s Tube at ITA Mics1234' 'Small Kundt''s Tube at ITA Mics123' 'Big Kundt''s Tube at ITA' 'Rohr mit Ohr'},...
                'Value',this.kindOfTubeValue,...
                'FontSize',layout.compBTxtHeight,...
                'Position',[layout.figSize(1)-layout.bSize(1)*2-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-8.3*layout.defaultSpace,layout.bSize(1)*2,layout.bSize(2)],...
                'Callback',{@kOTCallBack,this},...
                'TooltipString',toolTipStr);
            toolTipStr = ['You have to choose between sample (some samples of your material)' br ...
                'or repetition (some repetitions with the same sample)'];
            %creating text for sample or repetition popup menu
            h.txtSampOrRep = uicontrol('Style','text',...
                'String','Sample or Repetition',...
                'FontWeight','bold',...
                'ForegroundColor',layout.fontColor,...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.defaultSpace,layout.figSize(2)-11.7*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString',toolTipStr);
            %creating popup menu for sample or repetition
            h.sampOrRepMenu = uicontrol('Style','popupmenu',...
                'String',{'Sample' 'Repetition'},...
                'Value',this.sampOrRepValue,...
                'FontSize',layout.compBTxtHeight,...
                'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-9.9*layout.defaultSpace,layout.bSize],...
                'TooltipString',toolTipStr);
            %creating text for kind of smooth popup menu
            h.txtkindOfSm = uicontrol('Style','text',...
                'String','Kind of Smooth',...
                'FontWeight','bold',...
                'ForegroundColor',layout.fontColor,...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.defaultSpace,layout.figSize(2)-13.2*layout.defaultSpace,layout.figSize(1)/2,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString','You have to choose your kind of smooth');
            %creating popup menu for kindOfSmooth
            h.kindOfSmMenu = uicontrol('Style','popupmenu',...
                'String',{'1/1' '1/3' '1/6' '1/12' '1/24'},...
                'Value',this.kindOfSmValue,...
                'FontSize',layout.compBTxtHeight,...
                'Position',[layout.figSize(1)-layout.bSize(1)/2-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-11.5*layout.defaultSpace,layout.bSize(1)/2,layout.bSize(2)],...
                'TooltipString','You have to choose your kind of smooth');
            
            %creating border line
            h.line3 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-13.4*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                'BackgroundColor',layout.bgColor,...
                'HorizontalAlignment','left',...
                'Style', 'frame');
            toolTipStr = ['You have to klick this toggle Button,' br ...
                'to enable the New Material Button'];
            %creating text for save button
            h.txtOkBtn = uicontrol('Style','text',...
                'String','save changes',...
                'FontWeight','bold',...
                'ForegroundColor','black',...
                'BackgroundColor',layout.bgColor,...
                'FontSize',layout.compTxtHeight,...
                'Position',[layout.figSize(1)*2/3,layout.figSize(2)-15.7*layout.defaultSpace,layout.figSize(1)/4,2.5*layout.compTxtHeight],...
                'horizontalAlignment','left',...
                'TooltipString',toolTipStr);
            %creating save button
            h.okBtn = uicontrol('Style','togglebutton',...
                'String','OK',...
                'FontSize',layout.compBTxtHeight,...
                'BackgroundColor',layout.bgColor,...
                'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-14.8*layout.defaultSpace,layout.bSize(1),layout.bSize(2)*2],...
                'Callback',{@okCallBack,this},...
                'TooltipString',toolTipStr);
            toolTipStr = ['With clicking this button,' br ...
                'you will create a new object of itaKundtMaterial' br ...
                'which comprised all material specific parameters'];
            %creating button for new material
            h.newMatBtn = uicontrol('Style','pushbutton',...
                'String','New Material',...
                'FontSize',layout.compBTxtHeight,...
                'BackgroundColor',layout.bgColor,...
                'Position',[layout.figSize(1)-layout.bSize(1)-layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-18*layout.defaultSpace,layout.bSize(1),layout.bSize(2)*2],...
                'Callback',{@newMatCallBack,this},...
                'TooltipString',toolTipStr,...
                'enable','off');
            %creating border line
            h.line4 = uicontrol('Position',[layout.defaultSpace/2 layout.figSize(2)-16.4*layout.defaultSpace layout.figSize(1)-layout.defaultSpace 1],...
                'BackgroundColor',layout.bgColor,...
                'HorizontalAlignment','left',...
                'Style', 'frame');
            %create information window headline
            h.txtInfoHead = uicontrol('Style','text',...
                'String','Information',...
                'FontWeight','bold',...
                'ForegroundColor','black',...
                'FontSize',layout.compBTxtHeight,...
                'BackgroundColor',layout.bgColor,...
                'Position',[layout.defaultSpace,layout.figSize(2)-layout.bSize(2)-18*layout.defaultSpace,layout.figSize(1)/2,0.7*layout.defaultSpace],...
                'horizontalAlignment','left');
            
            
            % ITA toolbox logo with grey background
            a_im = importdata(which('ita_toolbox_logo.png'));
            image(a_im);axis off
            set(gca,'Units','pixel', 'Position', [10 10 210 40]);
            
            %gui anzeigen
            set(h.f,'Visible','on');
            this.guiOpensVar = this.guiOpensVar+1;
            this.mGuiHandleStruct = h;
            
        end
        
        
        
        
       
        
        %save function
        function sObj = saveobj(this)
            % Called when an object is saved
            %
            %saves the defined properties in a new struct
            propertylist = itaKundtTube.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    methods(Static)
        %contructor, initialisation of properties
        function obj = itaKundtTube(varargin)
            obj.mGuiHandleStruct.f = []; %because [] is no handle!
            switch nargin
                case 1
                    if isstruct(varargin{1})||isa(varargin{1},'itaKundtTube')
                        obj.mMeasurementSetup = varargin{1}.measurementSetup;
                        obj.mKindOfTube = varargin{1}.kindOfTube;
                        obj.mExaminer = varargin{1}.examiner;
                        obj.mSampleOrRepetition = varargin{1}.sampleOrRepetition;
                        obj.mKindOfSmooth = varargin{1}.kindOfSmooth;
                        obj.newMatNum = varargin{1}.newMatNum;
                        obj.mDate = datenum(varargin{1}.Date,'dd.mm.yyyy');
                        obj.mGeometry = varargin{1}.mGeometry;
                        obj.micNum = varargin{1}.micNum;
                    elseif varargin{1}
                        %%Default measurementSetup
                    fftDegree   = 18;
                    freqRange   = [100,obj.smallTubeFreqRange];
                    %excitation  = 'exp';
                    stopMargin  = 0.1;
                    inputCh      = 1;
                    outputCh     = 3;
                    %outputamplification = -35;
                    commentStr = ['Kundt''s tube measurement (' datestr(now)  ')'];
                    pauseTime           = 0.1;
                    averages            = 1;
                    
                    % create MSTF object(ita Measurement Setup object)
                    obj.mMeasurementSetup = itaMSTF('freqRange', freqRange, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'useMeasurementChain', false,'inputChannels', inputCh, 'outputChannels', outputCh, 'averages', averages, 'pause' , pauseTime, 'comment', commentStr );
                    
                    % shelf filter to amplify high frequencies
                    obj.mMeasurementSetup.excitation = ita_filter(obj.mMeasurementSetup.excitation, 'shelf',   'high',[50 8000],'order', 6);
                    else
                        ita_verbose_info('Wrong input for itaKundtTube class constructor, look at help for more information (doc)!',0)
                    end
                case 0
                    %%Default measurementSetup
                    fftDegree   = 18;
                    freqRange   = [100,obj.smallTubeFreqRange];
                    %excitation  = 'exp';
                    stopMargin  = 0.1;
                    inputCh      = 1;
                    outputCh     = 3;
                    %outputamplification = -35;
                    commentStr = ['Kundt''s tube measurement (' datestr(now)  ')'];
                    pauseTime           = 0.1;
                    averages            = 1;
                    
                    % create MSTF object(ita Measurement Setup object)
                    obj.mMeasurementSetup = itaMSTF('freqRange', freqRange, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'useMeasurementChain', false,'inputChannels', inputCh, 'outputChannels', outputCh, 'averages', averages, 'pause' , pauseTime, 'comment', commentStr );
                    
                    % shelf filter to amplify high frequencies
                    obj.mMeasurementSetup.excitation = ita_filter(obj.mMeasurementSetup.excitation, 'shelf',   'high',[50 8000],'order', 6);
                    obj.mMeasurementSetup.averages = 1;
                    %start gui
                    obj.gui;
                otherwise
                    ita_verbose_info('To much input parameters for itaKundtTube constructor, look at help for more information (doc)!',0)
            end
        end
        function this = loadobj(sObj)
            % Called when an object is loaded
            %
            %Calls Constructor of itaKundtTube with input property. (the
            %constructor will take care
            this = itaKundtTube(sObj);
        end
    end
    methods(Static,Access = protected)
        function outStr =  correctStr(inStr)
            inStr = strrep(inStr,'ä','ae');
            inStr = strrep(inStr,'ö','oe');
            inStr = strrep(inStr,'ß','ss');
            inStr = strrep(inStr,'ü','ue');
            inStr = strrep(inStr,'Ä','Ae');
            inStr = strrep(inStr,'Ö','Oe');
            inStr = strrep(inStr,'Ü','Ue');            
            outStr = inStr;
        
        end
        
        function result = propertiesSaved
            %defining the properties which will be saved
            result = {'kindOfTube','examiner','sampleOrRepetition','kindOfSmooth','measurementSetup','newMatNum','Date','mGeometry','micNum'};
        end
    end
    
    methods(Access = private)
        function str = getListBoxStr(this)
            infostr = get(this.mGuiHandleStruct.infoListBox,'String');
            sizeOfInfo = size(infostr);
            str = '';
            for idx = 1:sizeOfInfo
                str =  [str '|' infostr(idx,:)];
            end
        end
    end
end

%%
%Callbackfunction for Ok Button
function okCallBack(hObject,eventdata,this)
if get(hObject,'Value')
    set(this.mGuiHandleStruct.dateEditField,'enable','off');
    set(this.mGuiHandleStruct.examinerEditField,'enable','off');
    set(this.mGuiHandleStruct.sampOrRepMenu,'enable','off');
    set(this.mGuiHandleStruct.kindOfTubeMenu,'enable','off');
    set(this.mGuiHandleStruct.kindOfSmMenu,'enable','off');
    set(this.mGuiHandleStruct.newMatBtn,'enable','on');
%save date with check
dateStr = get(this.mGuiHandleStruct.dateEditField, 'string');
checkeddate = ita_checkDate(dateStr); % changed by rbo
if checkeddate.valid
    str = [checkeddate.day '.' checkeddate.month '.' checkeddate.year];
    this.mDate = datenum(str,'dd.mm.yyyy');
else
    this.mDate = datenum(date);
    set(this.mGuiHandleStruct.dateEditField,'string',datestr(date,'dd.mm.yyyy'));
    errordlg('wrong input for date');
end

%save examiner
examinerStr = get(this.mGuiHandleStruct.examinerEditField, 'string');
this.mExaminer = examinerStr;
set(this.mGuiHandleStruct.examinerEditField,'string',this.mExaminer);

%save kindOfTube
kindOfTubeStr = get(this.mGuiHandleStruct.kindOfTubeMenu,'string');
this.kindOfTubeValue = get(this.mGuiHandleStruct.kindOfTubeMenu,'Value');
this.mKindOfTube = kindOfTubeStr{this.kindOfTubeValue};
switch this.kindOfTubeValue
    case 1
        this.mGeometry =  this.geometrySmall4;
        this.micNum = 4;
    case 2
        this.mGeometry =  this.geometrySmall3;
        this.micNum = 3;
    case 3
        this.mGeometry =  this.geometryBig;
        this.micNum = 3;
    case 4
        this.mGeometry =  this.geometryTubeWithEar;
        this.micNum = 3;
end

%save sample or Repetition
sampOrRepStr = get(this.mGuiHandleStruct.sampOrRepMenu,'string');
this.sampOrRepValue = get(this.mGuiHandleStruct.sampOrRepMenu,'Value');
this.mSampleOrRepetition = sampOrRepStr{this.sampOrRepValue};

%save kind of smooth
kindOfSmStr = get(this.mGuiHandleStruct.kindOfSmMenu,'string');
this.kindOfSmValue = get(this.mGuiHandleStruct.kindOfSmMenu,'Value');
this.mKindOfSmooth = kindOfSmStr{this.kindOfSmValue};
else
    set(this.mGuiHandleStruct.dateEditField,'enable','on');
    set(this.mGuiHandleStruct.examinerEditField,'enable','on');
    set(this.mGuiHandleStruct.sampOrRepMenu,'enable','on');
    set(this.mGuiHandleStruct.kindOfTubeMenu,'enable','on');
    set(this.mGuiHandleStruct.kindOfSmMenu,'enable','on');
    set(this.mGuiHandleStruct.newMatBtn,'enable','off');    
end
end


%Callbackfunction for MSedit Button
function MSedit(hObject,eventdata,measurementSetup)
measurementSetup.edit;
end

%Callback für kindOfTube popup menu
function kOTCallBack(hObject,eventdata,this)

timestr = datestr(now, 'HH:MM:SS');

valueOfPopUpMenu = get(hObject,'Value');

str = this.getListBoxStr;
switch valueOfPopUpMenu
    case 3
        if this.mMeasurementSetup.freqRange(2)~= this.bigTubeFreqRange
            outStr = sprintf(' You changed the upper value of frequency range to %i.(In Measurement Setup)',this.bigTubeFreqRange);
            str = [timestr outStr str];
            set(this.mGuiHandleStruct.infoListBox,'String',str);
        end
        this.mMeasurementSetup.freqRange(2) = this.bigTubeFreqRange;
    case {1,2,4}
        if this.mMeasurementSetup.freqRange(2)~= this.smallTubeFreqRange
            outStr = sprintf(' You changed the upper value of frequency range to %i.(In Measurement Setup)',this.smallTubeFreqRange);
            str = [timestr outStr str];
            set(this.mGuiHandleStruct.infoListBox,'String',str);
        end
        this.mMeasurementSetup.freqRange(2) = this.smallTubeFreqRange;
end
this.mMeasurementSetup.excitation = ita_filter(this.mMeasurementSetup.excitation, 'shelf',   'high',[50 8000],'order', 6);
end

%Callbackfunction for new material Button
function newMatCallBack(hObject,eventdata,this)
this.newMatNum = this.newMatNum+1;
newMat = itaKundtTubeMaterial(this);
ita_setinbase('currentMaterial', newMat)
newMat.nameOfDUT = 'currentMaterial';
end
