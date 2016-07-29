classdef itaItalian < itaMeasurementTasksMovtec
    
    % <ITA-Toolbox>
    % This file is part of the application Movtec for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % Measurements with the ITA italian turntable (arm is optional)
    % together with the MOVTEC controller.
    %
    % See also: itaXY, itaVibrometer, itaMeasurementTasksMovtec
    
    % Author: Pascal Dietrich - Mai 2010
    
    % *********************************************************************
    % *********************************************************************
    properties
        defaultArmSpeed       = 1; %default speed for arm (0.25)
        defaultTurntableSpeed = 10; %default speed for turntable (1)
        wait_forArm           = 0.5;
        noArm                 = false; %disable arm routines to save time if not required
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = private)
        
    end
    % *********************************************************************
    % *********************************************************************
    methods
        function reference(this)
            %move to reference position
            this.referenceMove;
        end
        
        function init(this)
            init@itaMeasurementTasksMovtec(this);
            %             this.move_turntable(0);
            %             this.move_arm(0);
        end
        
        function move_arm(this,angle,varargin)
            %   This function moves the arm on a vertical direction, upwards for a
            %   positive angle and downwards for a negative angle.
            %
            %   The rules for the commands sent via RS232 are the following:
            %
            %   - for moving the arm , always set the last but third column of
            %   data_hex_V to '32' (for moving turntable - see ita_italian_move
            %   turntable - this value is set to '12')
            %
            %   1) positive angle -> update the last 3 columns of data_hex_V by:
            %
            %    a) make the last column = 'FF';
            %    b) subtract 100 x angle from 2^16 (decimal operation);
            %    c) value obtained transform to hexadecimal format;
            %    d) invert the last 2 and first 2 digits of the new number
            %       ex: 65436 = 'FF9C' -> '9C' 'FF'
            %    e) change the last but two and the last but one columns of data_hex_V
            %    by the previous result e.g '9C' 'FF'
            %
            %   2) negative angle -> update the last 3 columns of data_hex_V by:
            %
            %    a) make the last column = '00';
            %    b) subtract 100 x angle (angle is negative!) from 2^16 (decimal operation);
            %    c) value obtained transform to hexadecimal format;
            %    d) ignore the first one of the result (it's the sign);
            %       e.g '10064' -> '0064'
            %    e) invert the last 2 and first 2 digits of the new number
            %       ex: '0064' -> '64' '00'
            %    f) change the last but two and the last but one columns of data_hex_V
            %    by the previous result e.g '64' '00'
            %
            %   Examples:
            %   1)  angle  = -5
            %       2^16 - 100*(-5)= 65536 + 500 = 66036
            %       66036(base 10) = 101F4 (base 16)
            %       '101F4' -> '01F4' -> 'F4' '01'
            %       data_hex_V=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'86';'03';'03';'23';'03';'32';'F4';'01';'00'];
            %
            %     - minimum angle is 0.01 degree
            %
            %   2)  angle  = 10
            %       2^16 - 100*(10)= 65536 + 1000 = 64536
            %       64536(base 10) = FC18 (base 16)
            %       'FC18' -> '18' 'FC'
            %       data_hex_V=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'86';'03';'03';'23';'03';'32';'18';'FC';'FF'];
            %
            %   - for changing speed, change the 15th column of data_hex_V; by default,
            %   the speed for moving arm is 0.5 °/s, which corresponds to a value of
            %   '86' (base 16)/'134' (base 10) in column 15. The speed range for moving
            %   arm is between 1/12(83.3333 m°/s) °s and 1°/s
            %
            %   The rule for changing speed contains the following steps:
            %
            %   a) add 12*speed to 128 (base 10);
            %   b) transform the result into hexadecimal format;
            %   c) update the 15th column of data_hex_V
            %
            %   Example:
            %   speed = 1/6 °/s
            %   128 + 12*1/6 = 130 (base 10)
            %   '130' (base 10) -> '82' (base 16)
            %   - for an angle change of -5 (see example 1 above), data _hex_V becomes:
            %   data_hex_V=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'82';'03';'03';'23';'03';'32';'F4';'01';'00'];
            %
            
            if this.noArm
                return;
            end
            
            %% Init
            if ~this.isInitialized
                this.initialize
            end
            
            sArgs = struct('wait',true,'speed',this.defaultArmSpeed,'VST','01');
            sArgs = ita_parse_arguments(sArgs,varargin);
            speed = sArgs.speed;
            
            if (speed < 1/12) || (speed > 1)
                error('ITA_ITALIAN_MOVE_ARM: Speed must be between 1/12°/s and 1°/s!');
                return; %#ok<UNRCH>
            else
                if mod(speed,1/12)% is speed is not a multiple of 1/12, then update to next smallest value multiple of 1/12
                    disp('Speed must be a multiple of 1/12! I will correct this for you.')
                    speed = speed - mod(speed,1/12);
                end
                % speed value give in °
                hex_speed = dec2hex(128 + 12*speed);
                
                data_hex_V = ['55';'0D';'0D';...
                    %                 '24';'10';... %strom %kein einfluss festgestellt
                    '28';sArgs.VST;... %vollschritt teilung
                    %                   '22';'01';... %gesch. bereich %pdi:kein einfluss festgestellt
                    '33';hex_speed;...
                    '23';'03';... %rampe
                    ];
                
            end
            
            %             data_hex_V = ['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';hex_speed;'03';'03';'23';'03';'32'];
            %             data_hex_V = ['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';hex_speed;'03';'03';'23';'03']; % ohne '32' (Sendebefehl)
            
            if abs(angle)>90
                error('ITA_ITALIAN_MOVE_ARM: Angle range is -90 to 90!');
                return; %#ok<UNRCH>
            elseif round(angle*100) == 0
                %                 data_hex_V = [];
            elseif angle > 0
                move = dec2hex(2^16 - round(100*angle));
                col3 = move(3:4);
                col2 = move(1:2);
                data_hex_V = [data_hex_V ; '32'; col3 ; col2; 'FF'];
            elseif angle < 0
                move = dec2hex(2^16 - round(100*angle));
                col3 = move(4:5);
                col2 = move(2:3);
                data_hex_V = [data_hex_V ; '32'; col3 ; col2; '00'];
            end
 
            %% Set position
            newPosition = this.mCurrentPosition.theta - angle/180*pi;
            if (newPosition > pi/2+30/180*pi) || (newPosition < 0)
                error('itaItalian: Angle range is -30 to 90!');
                return; %#ok<UNRCH>
            else
                this.mCurrentPosition.theta = newPosition;
            end
            
            %% Open Serial Port
            fclose(this.mSerialObj); %better to close first
            fopen(this.mSerialObj);  %open port
            data_dec_V = hex2dec(data_hex_V); %convert to decimal, pdi: don't ask me why!
            fwrite(this.mSerialObj,21);% Kill old commandos
            fwrite(this.mSerialObj,85);
            pause(0.1)
            fwrite(this.mSerialObj,data_dec_V); %write to RS232
            ita_verbose_info('itaItalian: Arm is moving...',2);
            if sArgs.wait
                this.wait4arm;
            end
        end
        
        function move_turntable(this,angle,varargin)
            %   This function moves the turntable, counterclockwise for a negative
            %   angle and clockwise for a positive angle.
            %
            %   The rules for the commands sent via RS232 are the following:
            %
            %   - for moving the arm , always set the last but third column of
            %   data_hex_V to '12' (for moving turntable - see ita_italian_move
            %   arm - this value is set to '32')
            %
            %   1) positive angle -> update the last 3 columns of data_hex_V by:
            %
            %    a) make the last column = 'FF';
            %    b) subtract 100 x angle from 2^16 (decimal operation);
            %    c) value obtained transform to hexadecimal format;
            %    d) invert the last 2 and first 2 digits of the new number
            %       ex: 65436 = 'FF9C' -> '9C' 'FF'
            %    e) change the last but two and the last but one columns of data_hex_V
            %    by the previous result e.g '9C' 'FF'
            %
            %   2) negative angle -> update the last 3 columns of data_hex_V by:
            %
            %    a) make the last column = '00';
            %    b) subtract 100 x angle (angle is negative!) from 2^16 (decimal operation);
            %    c) value obtained transform to hexadecimal format;
            %    d) ignore the first one of the result (it's the sign);
            %       e.g '10064' -> '0064'
            %    e) invert the last 2 and first 2 digits of the new number
            %       ex: '0064' -> '64' '00'
            %    f) change the last but two and the last but one columns of data_hex_V
            %    by the previous result e.g '64' '00'
            %
            %   Examples:
            %   1)  angle  = -5
            %       2^16 - 100*(-5)= 65536 + 500 = 66036
            %       66036(base 10) = 101F4 (base 16)
            %       '101F4' -> '01F4' -> 'F4' '01'
            %       data_hex_V=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'86';'03';'03';'23';'03';'12';'F4';'01';'00'];
            %
            %   2)  angle  = 10
            %       2^16 - 100*(10)= 65536 + 1000 = 64536
            %       64536(base 10) = FC18 (base 16)
            %       'FC18' -> '18' 'FC'
            %       data_hex_V=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'86';'03';'03';'23';'03';'12';'18';'FC';'FF'];
            %
            %   - for changing speed, change the 13th column of data_hex_V; by default,
            %   the speed for moving arm is 5°/s, which corresponds to a value of 'BC'
            %   (base 16)/'188' (base 10) in column 15. The speed range for moving
            %   arm is between 1/12(83.3333 m°/s) °s and 10°/s
            %
            %   The rule for changing speed contains the following steps:
            %
            %   a) add 12*speed to 128 (base 10);
            %   b) transform the result into hexadecimal format;
            %   c) update the 15th column of data_hex_V
            %
            %   Example:
            %   speed = 10°/s
            %   128 + 12*10 = 248 (base 10)
            %   '248' (base 10) -> 'F8' (base 16)
            %   - for an angle change of -5 (see example 1 above), data _hex_V becomes:
            %   data_hex_V=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'F8';'33';'86';'03';'03';'23';'03';'12';'F4';'01';'00'];
            %
            %   Remark: the speed should change in fractions of 1/12!
            %
            % Added by Benedikt Krechel:
            % Values for speed_range (Parameter 02h):
            % 0 = 0 to 20.2 kHz
            % 1 = 0 to 10.1 kHz
            % 2 = 0 to 6.7 kHz
            % 3 = 0 to 5 kHz
            % 4 = 0 to 4 kHz
            % 5 = 0 to 3.3 kHz
            % 6 = 0 to 2.9 kHz
            % 7 = 0 to 2.5 kHz
            % 8 = 0 to 2.2 kHz (standard!)
            % 9 = 0 to 2.0 kHz
            % A = 0 to 1.9 kHz
            % B = 0 to 1.8 kHz
            % C = 0 to 1.7 kHz
            % D = 0 to 1.6 kHz
            % E = 0 to 1.5 kHz
            % F = 0 to 0.169 kHz
            
            
            %% Init
            if ~this.isInitialized
                this.initialize
            end
            sArgs = struct('wait',false,'speed',this.defaultTurntableSpeed,'VST','01','limit',false,'continuous',false, 'speed_range', '08');
            sArgs = ita_parse_arguments(sArgs,varargin);
            %sArgs.speed = 8+0/12; just for testing...
            speed = sArgs.speed;
            
            %% Get commando to send via RS232
            if (speed <1/12) || (speed > 1000)
                error('ITA_ITALIAN_MOVE_TURNTABLE: Speed must be between 1/12°/s and 10°/s!');
                return; %#ok<UNRCH>
            else
                if mod(speed,1/12)% is speed is not a multiple of 1/12, then update to next smallest value multiple of 1/12
                    disp('Speed must be a multiple of 1/12! I will correct this for you.')
                    speed = speed - mod(speed,1/12);
                end
                % speed value give in °/s
                hex_speed = dec2hex(128 + 12*speed);
                
                sequence = ['55';'0D';'0D';...
                    % add current here?!?
                    '03';'01';... % Rampe
                    '08';sArgs.VST;... % Vollschrittteilung
                    '02';sArgs.speed_range;... % Geschwindigkeitsbereich (>= 7 sonst kommt der Motor nicht nach!)
                    '13';hex_speed;... % Speed
                    ];
            end
            
            %             sequence = ['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';'13';'BC';'33';'86';'03';'03';'23';'03';'12'];% speed = 5m°/s ('BC')
            %                         sequence = ['55';'0D';'0D';
            %                             '02';'08';
            %                             '22';'08';
            %                             '08';'01';'28';'01';'13';hex_speed;'33';'86';'03';'03';'23';'03'];% speed = 5m°/s ('BC') % ohne '32' (Sendebefehl)
        if ~(sArgs.continuous)
            if abs(angle)>360 && sArgs.limit
                error('ITA_ITALIAN_MOVE_TURNTABLE: Angle range is -360 to 360!');
                return; %#ok<UNRCH>
            elseif angle == 0
                %                 sequence = []; %#ok<NASGU>
                %                 return;
            elseif angle > 0
                move = dec2hex(2^24 - round(100*angle*hex2dec(sArgs.VST)), 6);
                col3 = move(5:6);
                col2 = move(3:4); 
                col1 = move(1:2);
                sequence = [ sequence ; '12'; col3 ; col2; col1];
            elseif angle < 0
                move = dec2hex(round(100*abs(angle)*hex2dec(sArgs.VST)), 6);
                col3 = move(5:6);
                col2 = move(3:4); 
                col1 = move(1:2);
                sequence = [sequence ; '12'; col3 ; col2; col1];
            end
        else
            % ADD SOMETHING HERE FOR CONTINUOUS-OPERATION!
        end
         
            data_hex_V = sequence;
%             clear data_hex_V
%             data_hex_V=['55';'0D';'0D';...
%                 % Motor 1
%                 %'24';'40';...          % Einstellung des Motorstroms macht erstmal keinen Unterschied
%                 '03';'02';...           % Rampe-, Beschleunigungs-, Bremszeit
%                 
%                 '08';'80';...            % Vollschrittteilung f. vorg. Soll-Position
%                 '02';'0F';...         % Geschwindigkeitsbereich
%                 '13';hex_speed;...       % Positioniergeschwindigkeit
%                 %'0b';'04';...          % Einzelschrittvorgabe
%                 
%                 '12';col3;col2;col1;...
%                 ];
            %% Set position
            newPosition = mod(this.mCurrentPosition.phi + angle/180*pi,2*pi);
            if (newPosition > 2*pi) || (newPosition < -2*pi)
                error('itaItalian: Angle range is -360 to 360!');
                return; %#ok<UNRCH>
            else
                this.mCurrentPosition.phi = newPosition;
            end
            
            %% Open Serial Port
            fclose(this.mSerialObj); %better to close first
            fopen(this.mSerialObj);  %open port
            %pause(0.3);
            data_dec_V = hex2dec(data_hex_V); %convert to decimal, pdi: don't ask me why!
            fwrite(this.mSerialObj,21);% Kill old commandos
            %pause(0.3);
            fwrite(this.mSerialObj,85);
            pause(0.05);
            fwrite(this.mSerialObj,data_dec_V); %write to RS232
            ita_verbose_info('itaItalian: Arm is moving...',2);
            %disp(data_hex_V');
            if sArgs.wait
                this.wait4turntable;
            end
        end
        
        function moveTo(this,position)
            % Move turntable and arm to absolute position
            
            % Error checks
            if ~isa(position,'itaCoordinates')
                error('itaItalian: Should be itaCoordinates')
            end
            if ~this.isInitialized
                this.initialize
            end
            if ~this.isReferenced
                this.referenceMove
            end
            
            % Move arm
            azi_difference_deg = -180/pi * (mod(position.theta,pi) - this.currentPosition.theta);
            if abs(azi_difference_deg) > 1/12
                this.move_arm(azi_difference_deg,'wait',true);
            end
            
            % Move turntable
            ele_difference_deg = +180/pi * (mod(position.phi,2*pi) - this.currentPosition.phi);
            if abs(ele_difference_deg) > 1/12
                this.move_turntable(ele_difference_deg,'wait',true);
            end
            
        end
        
        function gui(this)
            %call ita italian GUI
            ita_italian_gui(this)
        end
        
        function wait(this)
            %wait until wait4arm and wait4turntable are finished
            %             this.wait4arm;
            this.wait4turntable;
        end
        
    end %methods
    
    % *********************************************************************
    % *********************************************************************
    
    methods(Hidden = true)
        function wait4arm(this)
            %wait until the arm has reached its position
            
            %status
            fclose(this.mSerialObj);
            fopen(this.mSerialObj);
            
            idx = 1;
            ita_verbose_info(['Waiting for Arm to reach position...'],2);
            V_status = '0000000';
            while ~strcmp(V_status, '10001111') && ~strcmp(V_status, '00111111') && ~strcmp(V_status, '10001011') && ~strcmp(V_status, '10001001') % && idx < 1000 : pdi:out is dependent on angle and speed, could be calculated by calling routine as a limit, but this is obsolete here
                %pdi: 00111111 added, used when no arm connected?
                pause(this.waitForSerialPort)
                idx = idx +1;
                fwrite(this.mSerialObj,hex2dec('31'));
                pause(this.waitForSerialPort);
                V_status=ita_angle2str(dec2bin(fread(this.mSerialObj,1)),8);
                %ita_verbose_info([ 'Arm answered with:   ' V_status],2);
            end
            fclose(this.mSerialObj);
            fopen(this.mSerialObj);
            ita_verbose_info('Arm position is reached',1);
            
            %added by martin kunkemoeller: wait until the arm does not
            %vibrate any more
            pause(this.wait_forArm);
        end
        
        function wait4turntable(this)
            %  This function checks if the turntable has reached the end position and
            %  only returns when the end position is reached.
            
            %% Init RS232 - pdi:out
            % % %             fclose(this.mSerialObj);
            % % %             fopen(this.mSerialObj);
            
            %% Ask Movetec and compare with Reference string and ready
            %% string
            ita_verbose_info(['Waiting for Turntable to reach position...'],2);
            H_status = '00000000'; %just an init string
            idx    = 1;
            idxMAX = 10000;
            while ~strcmp(H_status, '10001111') && idx < idxMAX
                pause(this.waitForSerialPort)
                fwrite(this.mSerialObj,hex2dec('11')); %ask Movetec
                pause(this.waitForSerialPort); %avoid asking to much, RS232 will die otherwise
                H_status = ita_angle2str(dec2bin(fread(this.mSerialObj,1)),8);
                %                 if strcmp(H_status(end-1:end),'01')
                %                     ita_verbose_info(['Turntable answered with:   ' H_status],2);
                %                 end
                
                % if the turntable is already at reference position '00111101'
                if strcmp(H_status, '00111101') || strcmp(H_status, '10001101')
                    H_status='10001111';
                end
                idx = idx + 1;
            end
            if idx == idxMAX
                ita_verbose_info('wait4turntable abort...',0)
            end
            ita_verbose_info(['Turntable position reached'],1);
            
            % %             %% Clear Buffer % pdi:out
            %             fclose(this.mSerialObj);
            %             fopen(this.mSerialObj);
        end
        function this = referenceMove(this)
            % do the reference move
            if ~this.isInitialized
                this.initialize;
            end
            
            %             if this.isReferenced
            %                 this.moveTo(itaCoordinates([1 pi/2 0],'sph'));
            %             end
            
            %% Init RS232 - Empty buffer
            fclose(this.mSerialObj);
            fopen(this.mSerialObj);
            fwrite(this.mSerialObj,85);%  '15' in hex; Kill old commandos
            %             pause(0.1) % hat nix gebracht
            pause(0.1)
            fwrite(this.mSerialObj,hex2dec('35'));% freigabe pdi  hat auch nix gebracht
            fwrite(this.mSerialObj,hex2dec('15'));% freigabe pdi  hat auch nix gebracht
            
            pause(0.1)
            %                         fwrite(this.mSerialObj,85);% Release - 'Freigabe' pdi: could
            %             be problematic!
            %             pause(0.5)
            %% Reference Move Commando                                            %'bc' before, pdi
            sequence=['55';'0D';'0D';'02';'08';'22';'08';'08';'01';'28';'01';...
                '13';'BC';'33';'8C';...
                '03';'03';...
                '23';'03';'06';'00';'16';'32';'06';'01';'26';'00'; '36'; '82'; '26'; '01'];
            % only arm--taken from movtec-xy-table
            %             sequence = ['55';'0D';'0D';...
            %                 % Motor 2 (x-direction)
            %                 '28';'01';...
            %                 '23';'03';...
            %                 '26';'00';...               % Rampe intern od. extern zweiter Motor
            %                 '36';'70';...               % entspricht Geschw. von dec=15
            %                 '26';'01';...
            %                 '22';'01';...
            %                 ];
            % turnttable--
            %             sequence=['55';'0D';'0D';...
            %                 % Motor 1 (y-direction)
            %                 '08';'01';...
            %                 '03';'09';... %(merkliche veränderung bei auskommentierung... Wagen fährt aus...)
            %                 '06';'00';... %beteiligt an dem Ausfahrverhalten
            %                 '16';'7C';...   % entspricht Geschwindigkeit von dec=30 (24%)
            %                 '06';'01';...
            %                 '02';'01';...  (nicht benötigt für Referenz-Fahrt)
            %                 ];
            
            
            %                            sequence = ['55';'0D';'0D';...
            %                             % Motor 2 (x-direction)
            %                             '28';'01';...
            %                             '23';'03';...
            %                             '26';'00';...               % Rampe intern od. extern zweiter Motor
            %                             '36';'70';...               % entspricht Geschw. von dec=15
            %                             '26';'01';...
            %                             '22';'01';...
            %                             '08';'01';...
            %                             '03';'09';... %(merkliche veränderung bei auskommentierung... Wagen fährt aus...)
            %                             '06';'00';... %beteiligt an dem Ausfahrverhalten
            %                             '16';'7C';...   % entspricht Geschwindigkeit von dec=30 (24%)
            %                             '06';'01';...
            %                             '02';'01';...  (nicht benötigt für Referenz-Fahrt)
            %                             ];
            %
            
            sequence_dec = hex2dec(sequence);
            fwrite(this.mSerialObj,sequence_dec);
            
            
            %%
            
            % % move_refx=['55';'0D';'0D';...
            % %     % Motor 2 (x-direction)
            % %     '28';'01';...
            % %     '23';'03';...
            % %     '26';'00';...               % Rampe intern od. extern zweiter Motor
            % %     '36';'70';...               % entspricht Geschw. von dec=15
            % %     '26';'01';...
            % %     '22';'01';...
            % % ];
            % %
            % % move_decx=hex2dec(move_refx);
            % % fclose(serial_movtec);
            % % fopen(serial_movtec);
            % % fwrite(serial_movtec,hex2dec('35'));        % Kill old motor-commandos
            % % %fwrite(s,hex2dec('55'));
            % % pause(0.3);
            % % fwrite(serial_movtec,move_decx);
            
            %%
            
            %% Wait for arm and turntable to reach reference position
            pause(0.5);
            this.mCurrentPosition.sph = [1 pi/2 0]; % Init-Position
            this.wait;
            
            %% empty buffer
            fclose(this.mSerialObj);
            fopen(this.mSerialObj);
            
        end
        
    end
    
end