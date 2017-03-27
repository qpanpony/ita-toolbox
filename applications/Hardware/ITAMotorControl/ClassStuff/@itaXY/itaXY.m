classdef itaXY < itaMeasurementTasksMovtec

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % Measurements with the XY table
    % together with the MOVTEC controller.
    
    % Author: Pascal Dietrich - Mai 2010
    
    % *********************************************************************
    % *********************************************************************
    properties(Hidden = true)
        mReference_x = 0;
        mReference_y = 0;
        mCalibrated   = false;
        mCalibrated_x = 0;
        mCalibrated_y = 0;
        backwards = false;
        
    end
    properties(Hidden = false)
        %@Gregor TODO. bitte GUI dafür machen.
        %               'speed' = 34 (in percent from 0.1 to 100)
        speed = 34;
        %               'speedR' = '00' (speedrange, '00'=0-20.2kHz,
        %               '01'=0-10.1kHz,
        %                   '02'=0-6.7kHz ... (see documentation)
        speedR = '00';
        %               'VST' = '01' (pitch, '01'=1, '02'=2, '04'=4, '08'=8, '10'=16,
        %                   ... (see documentation)
        VST = '01';
        %               'ramp' = '00' (the acceleration time, '00'=50ms, '01'=180ms,
        %               '02'=300ms, '03'=435ms, '04'=570ms, '05'=690ms, '06'=820ms,
        %               '07'=950ms, '08'=1080ms ... (see documentation)
        ramp = '00';
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = private)
        
    end
    
    %% Hidden Methods
    methods(Hidden = true)
        function varargout = steps2mm(this,varargin)
            %STEPS2MM - this function calculates the displacement in
            % mm to a number of steps have to be done by the specified motor or other
            % way.
            %
            %   Call:   steps2mm('motor', num)
            %           steps = steps2mm('x', 100, 'backwards',true);
            %   Arguments:
            %           'motor' could be 'x','X','2' or 'motor2' or 'y','Y','1' or
            %               'motor1'
            %           num is the number of steps or the displacement in mm
            %   optional arguments:
            %           'backwards' could be true or false (defaultvalue = false)
            %               true means calculation from steps to mm
            %           'VST' = '01' (pitch, '01'=1, '02'=2, '04'=4, '08'=8, '10'=16,
            %               ... (see documentation) (defaultvalue = '01')
            
            thisFuncStr  = [upper(mfilename) ':'];
            
            sArgs=struct('pos1_motor', 'string', 'pos2_num', 'numeric', 'backwards', this.backwards, 'VST', this.VST);
            sArgs=ita_parse_arguments(sArgs, varargin);
            
            motor1=0;
            motor2=0;
            
            % important to know which motor is going to move!
            if strcmp(sArgs.motor,'motor1') || strcmp(sArgs.motor,'1') || ...
                    strcmp(sArgs.motor,'y') || strcmp(sArgs.motor,'Y')
                motor1= 1;
            elseif strcmp(sArgs.motor,'motor2') || strcmp(sArgs.motor,'2') || ...
                    strcmp(sArgs.motor,'x') || strcmp(sArgs.motor,'X')
                motor2 = 1;
            end
            
            if motor1           % 963 steps = 10mm; VST step-pitch
                if sArgs.backwards    % mm to steps
                    varargout = {ceil(sArgs.num/10*963 * hex2dec(sArgs.VST))};
                else             % steps to mm
                    varargout = {round(100*sArgs.num*10/963 / hex2dec(sArgs.VST))/100};
                end
            elseif motor2       % 800 steps = 10mm; VST step-pitch
                if sArgs.backwards    % mm to steps
                    varargout = {ceil(sArgs.num/10*800 * hex2dec(sArgs.VST))};
                else             % steps to mm
                    varargout = {round(100*sArgs.num*10/800 / hex2dec(sArgs.VST))/100};
                end
            else
                error([thisFuncStr 'Which motor you wanna  get moved?']);
            end
            
            %EOF
        end
        
        function this = measurement_setup(this,varargin)
            %this function prepares the XY-table for measurement!
            %   it triggers a reference-move first! afterwards its calibrating the
            %   measurement middle (the point, where the mic is exactly positioned over
            %   the source
            
            % Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
            % Created:  29-Jan-2010
            thisFuncStr  = [upper(mfilename) ':'];
            
            % check if xy-table is initalized
            if ~this.isInitialized
                disp([thisFuncStr 'Doing a reference move first!']);
                this.reference();
            end
            
            % TODO
            % go to the middle of the table and start fine-calibration gui
            % make fine-calibration-gui x=112 y=321
            % TODO Tisch genau ausmessen...
            disp([thisFuncStr 'Please wait for calibration!']);
            
            this.gui;
            
            %EOF
        end
        
        function this = wait(this,varargin)
            %WAIT - this function should be used to wait for
            %   completion of a move-command (see ita_movtec_xy-table_move).
            %   You can wait for a specific motor or even both.
            %
            %   Call:   ita_movtec_xy-table_wait()
            %           ita_movtec_xy-table_wait('motor1')
            %           ita_movtec_xy-table_wait('motor2')
            %   instead of 'motor1' or 'motor2' you can also use '2','x' or 'X'
            %   (equals Motor2) and '1', 'y' or 'Y' (equals Motor1)
            
            % Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
            % Created:  28-Jan-2010
            thisFuncStr  = [upper(mfilename) ':'];
            
            % check input arguments
            checkX = 0;
            checkY = 0;
            if nargin == 2
                if strcmp(varargin{1},'motor1') || strcmp(varargin{1},'1') || ...
                        strcmp(varargin{1},'y') || strcmp(varargin{1},'Y')
                    checkY = 1;
                end
                if strcmp(varargin{1},'motor2') || strcmp(varargin{1},'2') || ...
                        strcmp(varargin{1},'x') || strcmp(varargin{1},'X')
                    checkX = 1;
                end
            else
                checkX = 1;
                checkY = 1;
            end
            
            %             fclose(this.mSerialObj);
            %             fopen(this.mSerialObj);
            
            idx = 1;
            ita_verbose_info([thisFuncStr 'Waiting for XY-table to reach position...'],1);
            
            if checkX
                % checks moving of Motor2 (x-direction)
                X_status = '0000000';
                while ~strcmp(X_status, '10001111') && ~strcmp(X_status, '10001011') && ~strcmp(X_status, '00111101') ...
                        && ~strcmp(X_status, '00001101') %&& ~strcmp(X_status,'10001101')%%  %pdi last added
                    pause(this.waitForSerialPort)
                    idx = idx +1;
                    fwrite(this.mSerialObj,hex2dec('31'));
                    pause(0.1);
                    X_status=ita_angle2str(dec2bin(fread(this.mSerialObj,1)),8);
                    ita_verbose_info([thisFuncStr 'x-motor answered with:   ' X_status],2);
                end
            end
            if checkY
                % checks moving of Motor1 (y-direction)
                Y_status = '0000000';
                while ~strcmp(Y_status, '10001111') && ~strcmp(Y_status, '10001011')...
                        && ~strcmp(Y_status, '00111101') && ~strcmp(Y_status, '00001101')  && ~strcmp(Y_status, '01001111') % 01001111 pdi last added 00001101
                    pause(this.waitForSerialPort)
                    idx = idx +1;
                    fwrite(this.mSerialObj,hex2dec('11'));
                    pause(0.1);
                    Y_status=ita_angle2str(dec2bin(fread(this.mSerialObj,1)),8);
                    ita_verbose_info([thisFuncStr 'y-motor answered with:   ' Y_status],2);
                end
            end
            
            ita_verbose_info([thisFuncStr 'Table position is reached'],1);
            
            %EOF
        end
        function show(this)
            %get current position
            this.mCurrentPosition
        end
        
        function varargout = getPosition(this,varargin)
            %XYTABLE_GETPOSITION - returns the x and y Position (in steps)
            %
            %   Call:   [x, y]= xytable_getPosition
            %           xytable_getPosition
            %           x = xytable_getPosition('x')
            %           xytable_getPosition('x')
            %           y = xytable_getPosition('y')
            %           xytable_getPosition('y')
            %   you can also use 'motor2', '2' or 'X' (equals 'x') and 'motor1','1'
            %   or 'Y' (equals 'y')
            
            % Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
            % Created:  02-Feb-2010
            thisFuncStr  = [upper(mfilename) ':'];
            
            % check serial-connection
            this.mSerialObj = this.mSerialObj;
            
            % check input arguments
            narginchk(0,2);
            getXPos = 0;
            getYPos = 0;
            if nargin == 2
                if nargout>1
                    error('Check your in- and output arguments!');
                end
                if strcmp(varargin{1},'motor1') || strcmp(varargin{1},'1') || ...
                        strcmp(varargin{1},'y') || strcmp(varargin{1},'Y')
                    getYPos = 1;
                end
                if strcmp(varargin{1},'motor2') || strcmp(varargin{1},'2') || ...
                        strcmp(varargin{1},'x') || strcmp(varargin{1},'X')
                    getXPos = 1;
                end
            else
                if nargout==1
                    error('Check your in- and output arguments!');
                end
                getXPos = 1;
                getYPos = 1;
            end
            
            % get the positions
            if getYPos && getXPos
                [posY posX] = this.getPosition('getPos1',true,'getPos2',...
                    true,'this.mSerialObj',this.mSerialObj);
            elseif getYPos
                posY= this.getPosition('getPos1',true,'getPos2',false,...
                    'this.mSerialObj', this.mSerialObj);
            elseif getXPos
                posX= this.getPosition('getPos1',false,'getPos2',true,...
                    'this.mSerialObj', this.mSerialObj);
            end
            
            % check and manage ouput arguments
            if nargout == 0
                if getXPos
                    disp([thisFuncStr 'The x-position is: ' num2str(posX)]);
                end
                if getYPos
                    disp([thisFuncStr 'The y-position is: ' num2str(posY)]);
                end
            elseif nargout == 1
                if getXPos
                    varargout(1)={posX};
                elseif getYPos
                    varargout(1)={posY};
                end
            else
                varargout= [{posX} {posY}];
            end
            %EOF
        end
        
    end %hidden methods **********************
    
    
    % *********************************************************************
    % *********************************************************************
    methods
        function this = moveTo(this,Position)
            % move to this Position
            
            %old gregor MEASUREMENT_RUN
            %             thisFuncStr  = [upper(mfilename) ':'];
            % check if calibrated
            %             if ~this.mCalibrated
            %                 error([thisFuncStr 'Do a measurement calibration first!']);
            %             end
            % displacement (steps) to reference point:
            % TODO: Spiegelung der Punkte testen...
            %             xdispl2R= this.steps2mm('x', -Position.x,'backwards',...
            %                 true);
            %             ydispl2R = this.steps2mm('y', -Position.y,'backwards',...
            %                 true);
            
            currentPos = this.mCurrentPosition;
            xdispl = Position.x - currentPos.x;
            ydispl = Position.y - currentPos.y;
            
            % goto next node!
            this.move('x',xdispl);
            this.move('y',ydispl);
            this.wait;
            this.mCurrentPosition = Position;
            fwrite(this.mSerialObj,hex2dec('35'));
            fwrite(this.mSerialObj,hex2dec('15'));
            fwrite(this.mSerialObj,hex2dec('55'));
            %EOF
        end
        
        
        
        function this = reference(this)
            %ITA_MOVTEC_XY-TABLE_REFERENCE_MOVE - this function moves the table into
            %   the reference-position
            %
            %   CALL: ita_movetec_xytable_reference_move()
            
            % Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
            % Created:  28-Jan-2010
            
            if ~this.isInitialized
                this.init;
            end
            %              sequence=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'8C';'03';'03';'23';'03';'06';'00';'16';'32';'06';'01';'26';'00'; '36'; '82'; '26'; '01'];
            %             sequence_dec = hex2dec(sequence);
            %             fwrite(this.mSerialObj,sequence_dec);
            move_refx=['55';'0D';'0D';...
                % Motor 2 (x-direction)
                '28';'01';...
                '23';'03';...
                '26';'00';...               % Rampe intern od. extern zweiter Motor
                '36';'70';...               % entspricht Geschw. von dec=15
                '26';'01';...
                '22';'01';...
                ];
            
            move_decx = hex2dec(move_refx);
            %             fclose(this.mSerialObj);
            %             fopen(this.mSerialObj);
            fwrite(this.mSerialObj,hex2dec('85'));        % Kill old motor-commandos
            %fwrite(s,hex2dec('55')); %pdi: shouldn't it really be 85 in
            %dec???
            pause(this.waitForSerialPort)
            fwrite(this.mSerialObj,move_decx);
            pause(this.waitForSerialPort)
            this.wait('x');
            
            move_refy=['55';'0D';'0D';...
                % Motor 1 (y-direction)
                '08';'01';...
                '03';'09';... %(merkliche veränderung bei auskommentierung... Wagen fährt aus...)
                '06';'00';... %beteiligt an dem Ausfahrverhalten
                '16';'7C';...   % entspricht Geschwindigkeit von dec=30 (24%)
                '06';'01';...
                '02';'01';...  (nicht benötigt für Referenz-Fahrt)
                ];
            
            move_decy = hex2dec(move_refy);
            %             fclose(this.mSerialObj);
            %             fopen(this.mSerialObj);
            
            fwrite(this.mSerialObj,hex2dec('35'));    % Kill old commandos
            fwrite(this.mSerialObj,hex2dec('15'));    % Kill old commandos
            %fwrite(s,hex2dec('55'));
            
            pause(this.waitForSerialPort)
            fwrite(this.mSerialObj,move_decy);
            pause(this.waitForSerialPort)
            this.wait('y');
            
            % to tell all the others, that finally... we are ready!
            this.mIsInitialized = true;
            this.mReference_x=0;
            this.mReference_y=0;
            
            this.mCurrentPosition = itaCoordinates([0 0 0]);
            
            %EOF
        end
        
        
        
        
        
        function this = move(this,varargin)
            %MOVE - this function move the table either in x- or in
            %   y-direction for a specified displacement.
            %   You also can specify the speed, the VST, the speedRange and if you want
            %   to wait for reaching the position.
            %
            %   Call:   move(motor, displacment, 'wait', bool, ...
            %                       'speed', numeric, 'speedR', numeric, ...
            %                       'VST', numeric, 'ramp', numeric)
            %
            %   arguments:  motor = 'motor2', 'x', 'X' or 'motor1', 'y', 'Y'
            %               displacment = 1000 (in mm)
            %
            %   optional arguments (defaults shown first) Input always in pairs of ...
            %   ('argumentString', value):
            %               'wait' = false or true
            %               'speed' = 34 (in percent from 0.1 to 100)
            %               'speedR' = '00' (speedrange, '00'=0-20.2kHz, '01'=0-10.1kHz,
            %                   '02'=0-6.7kHz ... (see documentation)
            %               'VST' = '01' (pitch, '01'=1, '02'=2, '04'=4, '08'=8, '10'=16,
            %                   ... (see documentation)
            %               'ramp' = '00' (the acceleration time, '00'=50ms, '01'=180ms,
            %               '02'=300ms, '03'=435ms, '04'=570ms, '05'=690ms, '06'=820ms,
            %               '07'=950ms, '08'=1080ms ... (see documentation)
            
            thisFuncStr  = [upper(mfilename) ':'];
            
            %% check if initalized
            if ~this.isInitialized
                error([thisFuncStr 'Please make a reference-move first!']);
            end
            
            %% check input arguments
            sArgs=struct('pos1_motor', 'string', 'pos2_displacement','numeric',...
                'wait',false, 'speed', this.speed, 'VST',this.VST,'speedR',...
                this.speedR, 'ramp',this.ramp,'check_posibility','true', 'steps',false);
            [motor displacement sArgs] = ita_parse_arguments(sArgs,varargin);
            
            %% determine if there should be a x- or y-movement
            moveX=0;
            moveY=0;
            if strcmp(motor,'motor1') || strcmp(motor,'1') || ...
                    strcmp(motor,'y') || strcmp(motor,'Y')
                moveY = 1;
            elseif strcmp(motor,'motor2') || strcmp(motor,'2') || ...
                    strcmp(motor,'x') || strcmp(motor,'X')
                moveX = 1;
            else
                error([thisFuncStr 'Which motor do you wanna move?']);
            end
            
            %% calculate the displacment (mm to motor-steps)
            if ~sArgs.steps
                if moveX
                    steps = this.steps2mm('x', displacement, ...
                        'backwards',true, 'VST', sArgs.VST);
                    sArgs.speed='5';
                end
                if moveY
                    steps = this.steps2mm('y', displacement, ...
                        'backwards',true, 'VST', sArgs.VST);
                    sArgs.speed='5';
                end
            else
                steps=displacement;
            end
            
            %% calculate the ramp ~ speed
            if moveY
                if str2num(sArgs.speed) < 5
                    sArgs.ramp = '00';
                elseif str2num(sArgs.speed) < 10
                    sArgs.ramp = '01';
                elseif str2num(sArgs.speed) < 15
                    sArgs.ramp = '02';
                elseif str2num(sArgs.speed) < 25
                    sArgs.ramp = '03';
                elseif str2num(sArgs.speed) < 40
                    sArgs.ramp = '04';
                elseif str2num(sArgs.speed) < 60
                    sArgs.ramp = '05';
                elseif str2num(sArgs.speed) < 80
                    sArgs.ramp = '06';
                else
                    sArgs.ramp = '07';
                end
            end
            if moveX
                if str2num(sArgs.speed) > 50
                    sArgs.ramp = '02';
                end
            end
            
            %% set the displacment hex (motor-steps to hex)
            if steps>0
                d = '00'; % positive Richtung
                stepsHex=dec2hex(steps,4);
            elseif steps<0
                d = 'ff';   % negative Richtung
                stepsHex = dec2hex(2^16 + round(steps),4);
            else
                ita_verbose_info([thisFuncStr 'Not moving, since no displacement or displacement is zero.'],1);
                return;
                stepsHex=dec2hex(0,4);
                d = '00';
            end
            
            %% set the speed hex (speed [0-100%] to speedHex[0-128dec])
            speedHex = dec2hex(ceil((sArgs.speed/100 * 127)+127));
            
            %% setup connection to movtec
            fclose(this.mSerialObj); %better to close first
            fopen(this.mSerialObj);  %open port
            
            %% set hex-command for x-movement
            if moveX
                data_hex_V=['55';'0D';'0D';...
                    % Motor 2
                    %'24';'40';...          % Einstellung des Motorstroms macht erstmal keinen Unterschied
                    '22';sArgs.speedR;...         % Geschwindigkeitsbereich
                    '23';sArgs.ramp;...           % Rampe-, Beschleunigungs-, Bremszeit
                    '28';sArgs.VST;...            % Vollschrittteilung f. vorg. Soll-Position
                    '33';speedHex;...       % Positioniergeschwindigkeit
                    %'2b';'04';...          % Einzelschrittvorgabe
                    '32';stepsHex(3:4);stepsHex(1:2);d;...% n-Umdrehungen
                    ];
                fwrite(this.mSerialObj,hex2dec('35'));    % kill old motorcommands
            end
            
            %% set hex-command for y-movement
            if moveY
                data_hex_V=['55';'0D';'0D';...
                    % Motor 1
                    %'24';'40';...          % Einstellung des Motorstroms macht erstmal keinen Unterschied
                    '02';sArgs.speedR;...         % Geschwindigkeitsbereich
                    '03';sArgs.ramp;...           % Rampe-, Beschleunigungs-, Bremszeit
                    '08';sArgs.VST;...            % Vollschrittteilung f. vorg. Soll-Position
                    '13';speedHex;...       % Positioniergeschwindigkeit
                    %'0b';'04';...          % Einzelschrittvorgabe
                    '12';stepsHex(3:4);stepsHex(1:2);d;...
                    ];
                fwrite(this.mSerialObj,hex2dec('15'));    % kill old motorcommands
            end
            data_dec_V = hex2dec(data_hex_V);
            
            %% checks if movement could be done...
            if sArgs.check_posibility
                %[x,y] = _getPosition();
                x=this.mReference_x;
                y=this.mReference_y;
                if 0;%x~=this.mReference_x || y~=this.mReference_y
                    error([thisFuncStr 'Global saved and actual Position different!']);
                else
                    if moveX
                        if x+steps<0
                            disp([thisFuncStr 'Do you really want to move out of the frame! NO!']);
                        else
                            this.mReference_x = this.mReference_x + steps;
                        end
                    elseif moveY
                        if y+steps<0
                            disp([thisFuncStr 'Do you really want to move out of the frame! NO!']);
                        else
                            this.mReference_y = this.mReference_y + steps;
                        end
                    end
                end
            end
            %% sending the command to the movtec
            fwrite(this.mSerialObj,hex2dec('55'));
            pause(this.waitForSerialPort)
            fwrite(this.mSerialObj,data_dec_V); %write to RS232
            
            %% waiting to reach the position
            if sArgs.wait
                if moveX
                    this.wait('x');
                else
                    this.wait('y');
                end
            end
            %EOF
        end
        
        function  this = gui(this,varargin)
            % this gui is used to fine-calibrate the measurement middle point.
            %   with a hit of one of the buttons the xy-table moves about 1mm in this
            %   direction.
            
            % Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
            % Created:  02-Feb-2010
            
            if ~this.isInitialized
                this.init;
            end
            
            %% building the figure
            vs = 30;        % Versatz zu Rändern und anderen Bereichen
            vsKl= 10;       % Abstand zwischen Nachbarelementen
            pbH=50;         % PushButton Höhe
            pbW=100;        % PushButton Breite
            midH=100;       % heigth of middle
            midW=100;       % weidth of middle
            
            % figure Höhe ist AnzahlButton vertikal+ (AnzahlButton-1)*versatzkl+
            % 3*versatz + midH + versatzkl;
            fH= 5 * pbH + 4 * vsKl + 3*vs + midH + vsKl;
            % figure Breite ist Anzahl PB horiz +
            % (AnzahlButton-1)*versatzkl+midW+versatzkl +2*versatz;
            fW= 4 * pbW + 3*vsKl + midW+vsKl + 2*vs;
            
            
            
            mpos = get(0,'Monitor');
            %             w_position = (mpos(1,length(mpos)-1)/2)-(width/2);
            %             h_position = (mpos(1,length(mpos))/2)-(height/2);
            
            mW = mpos(3);      % Monitor width
            mH = mpos(4);      % Monitor heigth
            f = figure('Visible','off','Position',[(mW-fW)/2,(mH-fH)/2,fW,fH],'menubar','none');
            
            %% PushButtons
            move10nx = uicontrol('Style','pushbutton', 'String','x -10mm',...
                'Position',[vs,(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
                'Callback',{@move10nxbutton_Callback} );
            move1nx = uicontrol('Style','pushbutton', 'String','x -1mm',...
                'Position',[(vs+vsKl+pbW),(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
                'Callback',{@move1nxbutton_Callback} );
            move1px = uicontrol('Style','pushbutton', 'String','x +1mm',...
                'Position',[(vs+3*vsKl+2*pbW+midW),(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
                'Callback',{@move1pxbutton_Callback} );
            move10px = uicontrol('Style','pushbutton', 'String','x +10mm',...
                'Position',[(vs+4*vsKl+3*pbW+midW),(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
                'Callback',{@move10pxbutton_Callback} );
            
            move10ny = uicontrol('Style','pushbutton', 'String','y -10mm',...
                'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+pbH),pbW,pbH],...
                'Callback',{@move10nybutton_Callback} );
            move1ny = uicontrol('Style','pushbutton', 'String','y -1mm',...
                'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+2*pbH+vsKl),pbW,pbH],...
                'Callback',{@move1nybutton_Callback} );
            move1py = uicontrol('Style','pushbutton', 'String','y +1mm',...
                'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+3*pbH+3*vsKl+midH),pbW,pbH],...
                'Callback',{@move1pybutton_Callback} );
            move10py = uicontrol('Style','pushbutton', 'String','y +10mm',...
                'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+4*pbH+4*vsKl+midH),pbW,pbH],...
                'Callback',{@move10pybutton_Callback} );
            
            calibrate = uicontrol('Style','pushbutton', 'String','Set Calib. Point',...
                'Position',[(vs+2*pbW+2*vsKl),(2*vs+3*pbH+3*vsKl+midH/2-vsKl/2),midW,midH/2-vsKl/2],...
                'Callback',{@calibratebutton_Callback});
            goMid = uicontrol('Style','pushbutton', 'String','Go to middle',...
                'Position',[(vs+2*pbW+2*vsKl),(2*vs+3*pbH+2*vsKl),midW,midH/2-vsKl/2],...
                'Callback',{@gotomidbutton_Callback});
            
            %% left corner
            cW = 2*pbW+vsKl;
            cH = 2*pbH+vsKl;
            rtext = uicontrol('Style','text','String','mm away from reference:',...
                'Position',[(vs+pbW+vsKl/2-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+2*cH/3),cW,cH/3]);
            xrtext = uicontrol('Style','text','String','X: ',...
                'Position',[(vs+pbW+vsKl/2-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+cH/3),cW,cH/3]);
            yrtext = uicontrol('Style','text','String','Y: ',...
                'Position',[(vs+pbW+vsKl/2-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2),cW,cH/3]);
            
            %% right corner
            cW = 2*pbW+vsKl;
            cH = 2*pbH+vsKl;
            ctext = uicontrol('Style','text','String','mm away from calibration point:',...
                'Position',[(vs+3*pbW+3.5*vsKl+midW-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+2*cH/3),cW,cH/3]);
            xctext = uicontrol('Style','text','String','X: ',...
                'Position',[(vs+3*pbW+3.5*vsKl+midW-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+cH/3),cW,cH/3]);
            yctext = uicontrol('Style','text','String','Y: ',...
                'Position',[(vs+3*pbW+3.5*vsKl+midW-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2),cW,cH/3]);
            
            %% bottom
            xvs = uicontrol('Style','edit','String','x-versatz...',...
                'Position',[vs,vs,pbW,pbH]);
            yvs = uicontrol('Style','edit','String','y-versatz...',...
                'Position',[(vs+vsKl+pbW),vs,pbW,pbH]);
            xvs = uicontrol('Style','edit','String','x-versatz...',...
                'Position',[vs,vs,pbW,pbH]);
            startVs = uicontrol('Style','pushButton','String','Go for it!',...
                'Position',[(vs+2*vsKl+2*pbW),vs,pbW,pbH],...
                'Callback',{@gobutton_Callback});
            
            %% ita toolbox logo with grey bg
            a_im = importdata(which('ita_toolbox_logo.png'));
            image(a_im);axis off
            set(gca,'Units','pixel', 'Position', [fW-vs-180+10 vs-10 180 35]);
            
            %% initialize gui
            set(f,'Name','fine calibrating the xy-table!')
            
            set(xrtext,'String', ['X: ' num2str(this.steps2mm('x',...
                this.mReference_x))]);
            set(yrtext,'String', ['Y: ' num2str(this.steps2mm('y',...
                this.mReference_y))]);
            set(xctext,'String', ['X: ' num2str(this.steps2mm('x',...
                this.mReference_x-this.mCalibrated_x))]);
            set(yctext,'String', ['X: ' num2str(this.steps2mm('x',...
                this.mReference_y-this.mCalibrated_y))]);
            
            %% edit Callbacks
            function gobutton_Callback(source,eventdata)
                xvsMm=str2num(get(xvs, 'String'));
                yvsMm=str2num(get(yvs, 'String')); %#ok<*ST2NM>
                if ~isempty(xvsMm)
                    this.move('x', xvsMm);
                    wait4motor();
                end
                if ~isempty(yvsMm)
                    this.move('y', yvsMm);
                    wait4motor();
                end
                
            end
            
            %%  pushButton Callbacks
            function move10nxbutton_Callback(source,eventdata)
                this.move('x',-10);
                wait4motor();
            end
            function move1nxbutton_Callback(source,eventdata)
                this.move('x',-1);
                wait4motor();
            end
            function move1pxbutton_Callback(source,eventdata)
                this.move('x',1);
                wait4motor();
            end
            function move10pxbutton_Callback(source,eventdata)
                this.move('x',10);
                wait4motor();
            end
            function move10nybutton_Callback(source,eventdata)
                this.move('y',-10);
                wait4motor();
            end
            function move1nybutton_Callback(source,eventdata)
                this.move('y',-1);
                wait4motor();
            end
            function move1pybutton_Callback(source,eventdata)
                this.move('y',1);
                wait4motor();
            end
            function move10pybutton_Callback(source,eventdata)
                this.move('y',10);
                wait4motor();
            end
            function calibratebutton_Callback(source,eventdata)
                this.mCalibrated_x=this.mReference_x;
                this.mCalibrated_y=this.mReference_y;
                this.mCalibrated=true;
                wait4motor();
            end
            
            function gotomidbutton_Callback(source,eventdata)
                this.move('x',ceil(112-this.steps2mm('x',this.mReference_x)));
                wait4motor();
                this.move('y',ceil(321-this.steps2mm('y',this.mReference_y)));
                wait4motor();
            end
            
            function wait4motor(source,eventdata)
                this.wait();
                % update position
                set(xrtext,'String', ['X: ' num2str(this.steps2mm('x',...
                    this.mReference_x))]);
                set(yrtext,'String', ['Y: ' num2str(this.steps2mm('y',...
                    this.mReference_y))]);
                set(xctext,'String', ['X: ' num2str(this.steps2mm('x',...
                    this.mReference_x-this.mCalibrated_x))]);
                set(yctext,'String', ['Y: ' num2str(this.steps2mm('y',...
                    this.mReference_y-this.mCalibrated_y))]);
            end
            
            set(f,'Visible','on')
            %EOF
        end
        
        function moveX(this,d)
            %move X Coordinate to this arbitrary position
            this.move('x',d);
        end
        function moveY(this,d)
            %move X Coordinate to this arbitrary position
            this.move('y',d);
        end
    end %methods
    % *********************************************************************
    % *********************************************************************
end
