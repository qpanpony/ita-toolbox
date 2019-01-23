classdef itaMotorNanotec_Turntable < itaMotorNanotec
    %ITAMOTORCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected, Hidden = true)
        mSerialObj; % the serial connection
        
        mMotorControl; % parent controlling this class
        sArgs_motor;
    end
    
    properties 

    end
    
    properties(Constant, Hidden = true)
        sArgs_default_motor = struct( ...
            'wait',         true,       ...
            'speed',        2,          ...
            'VST',          'adaptiv',  ...
            'limit',        false,      ...
            'continuous',   false,      ...
            'absolut',      false,      ...
            'closed_loop',  false,       ...
            'acceleration_ramp', 500,  ...
            'gear_ratio',   180,        ...
            'current',      100,        ...
            'ramp_mode',    2           );    
    end
    
    methods
        function this = itaMotorNanotec_Turntable(varargin)
            options =   struct('motorControl', []);
            options    =   ita_parse_arguments(options, varargin);
            this.mMotorControl = options.motorControl;
            this.mSerialObj = itaSerialDeviceInterface.getInstance();
            
            this.motorID = 3;
            this.motorName = 'Turntable';
        end
        
        function this = init(this)
            
        end
        
        function stop(this)
            % DO NOT ASK - JUST STOP ALL MOTORS!
            for i = 1:5 % repeat several times to ensure that every motor stops!
                this.mSerialObj.sendAsynch(sprintf('#%dS\r'        , this.motorID));
%                 pause(this.waitForSerialPort);
            end
            while this.mSerialObj.BytesAvailable
                ret = this.mSerialObj.recvAsynch;
            end    
        end
        
        
        function getStatus(this)
            motorControl.add_to_commandlist(sprintf('#%d$\r'    , this.motorID));
        end
        
        function status = isActive(this)
            if this.mIsInit == false
                this.mSerialObj.sendAsynch(sprintf('#%d$\r'    , this.motorID));
            end
            status = this.mIsInit;
        end
        
        function setActive(this,value)
           this.mIsInit = value;
        end
        
        function id = getMotorID(this)
            id = this.motorID;
        end
        function name = getMotorName(this)
           name = this.motorName; 
        end
        function sendConfiguration(this)
            % Set Input 1 as external Referenceswitch
            motorControl = this.mMotorControl;
            motorControl.add_to_commandlist(sprintf('#%d:port_in_a=7\r'  , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a=1\r' , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a=2\r' , this.motorID));
            % phasenstrom im stillstand
            motorControl.add_to_commandlist(sprintf('#%dr=0\r' , this.motorID));
            % fehlerkorrekturmodus
            motorControl.add_to_commandlist(sprintf('#%dU=0\r' , this.motorID));
            % ausschwingzeit
            motorControl.add_to_commandlist(sprintf('#%dO=1\r' , this.motorID));
            % umkehrspiel
            motorControl.add_to_commandlist(sprintf('#%dz=0\r'          , this.motorID));
            % automatisches senden des status
            motorControl.add_to_commandlist(sprintf('#%dJ=1\r'          , this.motorID));
%             if ~this.send_commandlist(this.failed_command_repititions)
%                 this.mIsInitialized             =   false;
%                 error('Motor_turntable is not responding!')
%             end
        end
        
        function this = moveToReferencePosition(this)
            % Prepare reference move (turntable)
            if ~this.mIsInit
                ita_verbose_info('Not initialized - This should not happen',0);
            end
            
            motorControl = this.mMotorControl;
            % Turn + some degrees in case we are already at the end of the
            % reference switch or already passed it:
            this.move_turntable(+2);
            if this.mMotorControl.send_commandlist(5)
                ita_verbose_info('Turntable started move...',2);
            end
            motorControl.wait4everything;
            % Call Reference-Mode:
            motorControl.add_to_commandlist(sprintf('#%dp=4\r'          , this.motorID));
            % Set direction:
            motorControl.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID));
            % Calculate and set lower speed:
            stepspersecond      =   (this.sArgs_default_motor.speed/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%du=%.2f\r'       , this.motorID, stepspersecond));
            % Calculate and set upper speed:
            stepspersecond      =   (this.sArgs_default_motor.speed/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do=%.2f\r'       , this.motorID, stepspersecond));
            % Start reference move:
            motorControl.add_to_commandlist(sprintf('#%dA\r'            , this.motorID));


            this.old_position = itaCoordinates(1);
            
            this.mIsReferenced = true;
            ita_verbose_info('Turntable referenced...',2);
        end
        
        function this = startMoveToPosition(this)
             this.mMotorControl.add_to_commandlist(sprintf('#%dA\r'        , this.motorID));
        end
        
        function disableReference(this,value)

        end
        
        function started = prepareMove(this,position,varargin)
           
           if ~this.mIsInit
               ita_verbose_info('Turntable: No initialized! This should not happen!',0)
               started = false;
               return;
           end
           
           if ~this.mIsReferenced
              ita_verbose_info('Turntable: No reference move done! Not moving!',0)
              started = false;
              return;
           end
            
           sArgs.continuous = false;
           sArgs.direct = true;
           sArgs.speed = this.sArgs_default_motor.speed;
           if ~isempty(varargin)
               [sArgs,~] = ita_parse_arguments(sArgs,varargin);
           end
           if sArgs.continuous
                ret = this.prepare_move(position, 'speed', sArgs.speed,'continuous', true); 
                started = ret;
           else
               % if only the phi angle is given
               if ~isa(position,'itaCoordinates')
                  tmpPosition = this.old_position;
                  if ~isnan(position)
                      tmpPosition.phi_deg = position;
                  end
                  position = tmpPosition;
               end

               if this.old_position.phi ~= position.phi
                    if ~sArgs.direct
                        angle = mod(position.phi(1)/2/pi*360+360, 720)-360;
                    else
                       angle = position.phi_deg(1); 
                    end
                    ret = this.prepare_move(angle, 'absolut', true, 'wait', true, 'speed', sArgs.speed); 
                    this.old_position = position;
                    started = ret;
               else
                    started = false;
               end
           end
        end

    end
    
    methods(Hidden = true)
        function move_turntable(this,angle,varargin)
            % angle:        turn counter-clockwise by angle degree (relative-mode)
            %                   or to specific position (absolut-mode)!
            % varargin:     is redirected to prepare_move_arm!
            
            % Move turntable
%             motorControl.clear_receivedlist;
%             if ~this.isInitialized
%                 ita_verbose_info('Not initialized - I will do that for you...!',0);
%                 this.initialize
%             end
            if this.mIsInit
                % First prepare the move
                if this.prepare_move(angle, varargin{:})
                    % Now start the move
                    this.startMoveToPosition;
                end


            else
                ita_verbose_info('Turntable not connected!',0)
            end
        end
        
        function ret = prepare_move(this, angle, varargin)
           if isnan(angle)
                ret = false;
                return;
           end
            
            
            %   This function prepares the moves of the turntable, counterclockwise for a negative
            %   angle and clockwise for a positive angle.
            %
            %   The rules for the commands sent via RS232 are the following:
            %
            %   Each command starts with it's startsign '#' followed by the
            %   motor number and ends with an '\r'. All other elements are ascii signs.
            %   A '*' sends the command to all motors.
            %
            %   The motor controller will respons with an echo of the
            %   command, but without the '#'. Invalid commands are marked
            %   with an '?' at the end of the echo.
            %
            %   Long commands start with an '#' followed by the motor ID
            %   and then an ':'. The command is read by just sending the
            %   command and set by '=<value>'.
            %
            % -----------------------------------------------------------------------------------------------
            % Init
%             if ~this.isInitialized
%                 ita_verbose_info('Not initialized - I will do that for you...!',0);
%                 this.initialize
%             end
            % Use always default values and change them if user is asking for it:
            this.sArgs_motor = this.sArgs_default_motor;
            
            % -------------------------------------------------------------
            % Meaning:
            %
            % Wait              =   Stop matlab until motor reaches final position!
            % Speed             =   Grad/s of the turntable
            % VST               =   Microstep divider. Values: 1, 2, 4, 5, 8, 10, 16, 32,
            %                       64. 254="Vorschubkonstantenmodus", 255=Adaptiv steps
            % Limit             =   Position only allowed between -180 and 360 degree if true!
            % Continuous        =   Turn continuously with a given speed
            % Absolut           =   Go to absolut positions
            % Closed_loop       =   Turn on the closed loop regulation
            % Acceleration_ramp =   Value in Hz/ms
            % Gear_ratio        =   Gear ratio between motor and turntable (be careful!)
            % Current           =   Maximum current in percent
            % Ramp_mode         =   0=trapez, 1=sinus-ramp, 2=jerkfree-ramp
            % -------------------------------------------------------------
            
            motorControl = this.mMotorControl;
            
            this.sArgs_motor = ita_parse_arguments(this.sArgs_motor,varargin);
            % Assign wait to global wait:
%
            
            if (this.sArgs_motor.speed == 0) && ((angle == 0) && (~this.sArgs_motor.continuous) && (~this.sArgs_motor.absolut))
                % This means: STOP!
                motorControl.add_to_commandlist(sprintf('#%dS\r'        , this.motorID));
%                 ret             =   false;
%                 pause(0.1);
%                 fgetl(this.mSerialObj);
                return
            end
            if (this.sArgs_motor.limit == true)
                % Check if the position is too far away...
                if this.sArgs_motor.continuous == true
                    % It will lead to problems if limit is on AND continuous
                    % is true...
                    error('Please turn off limit if you want to turn continuous! Please make also sure that no cable or other stuff can coil!');
                elseif this.sArgs_motor.absolut == true
                    % This case is easy because the given absolut angle
                    % shoud be between -180 and 360
                    if (angle > 361) || (angle < -181)
                        % It's not in the allowed range... :-(
                        error('Limit is on! Only positions between -180 and 360 degree are allowed!')
                    end
                else
                    % Limit is on and relative positioning is on... this case
                    % is a bit more complex!
                    % Get position:
                    this.mSerialObj.sendAsynch(sprintf('#%dC\r'      , this.motorID));
                    act_pos       =   this.mSerialObj.recvAsynch();
                    act_pos       =   str2double(act_pos(3:end));
                    % Now multiply with 0.9 and divide by gear_ratio to get
                    % the position angle of the turntable:
                    act_pos       =   act_pos*0.9/this.sArgs_motor.gear_ratio;
                    % Check if new position would be in the allowed range:
                    if (act_pos+angle) > 361 || (act_pos+angle) < -181
                        % No, it's not....
                        error('Limit is on! Only positions between -180 and 360 degree are allowed!')
                    end
                end
            end
            % Set microstep-divider:
            if strcmpi(this.sArgs_motor.VST, 'adaptiv')
                motorControl.add_to_commandlist(sprintf('#%dg=255\r'     , this.motorID));
            else
                motorControl.add_to_commandlist(sprintf(['#%dg=' this.sArgs_motor.VST '\r']  , this.motorID));
            end
            % Set maximum current to 100%:
            motorControl.add_to_commandlist(sprintf('#%di=%.0f\r'       , this.motorID, this.sArgs_motor.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            motorControl.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r', this.motorID, this.sArgs_motor.ramp_mode));
            % Set maximum acceleration jerk:
            motorControl.add_to_commandlist(sprintf('#%d:b=100\r'       , this.motorID));
            % Use acceleration jerk as braking jerk:
            motorControl.add_to_commandlist(sprintf('#%d:B=0\r'         , this.motorID));
            % Closed_loop?
            %this.sArgs_motor.closed_loop = true; % DEBUG!
            if this.sArgs_motor.closed_loop == true
                % JEAR! Without this the new motor would be nonsense!
                % Activate CL during movement:
                motorControl.add_to_commandlist(sprintf('#%d:CL_enable=2\r' , this.motorID));
                % Nice values for the speed closed loop control:
                pos     =   [0.5 1 2 3 4 8 12 16 25 32 40 50];
                vecP    =   [0.5 1.5 2.5 3.5 4.5 4.5 5.5 2.5 2.0 1.3 1.3 1.3];
                vecI    =   [0.05 0.1 0.2 0.3 0.4 0.8 1.2 1.6 2.0 2.5 2.5 2.5];
                vecD    =   [9 6 4 3 2 1 1 3 6 10 10 10];
                pP      =   polyfit(pos,vecP,5);
                pI      =   polyfit(pos,vecI,5);
                pD      =   polyfit(pos,vecD,5);
                P       =   polyval(pP,this.sArgs_motor.speed);
                I       =   polyval(pI,this.sArgs_motor.speed);
                D       =   polyval(pD,this.sArgs_motor.speed);
                P_nenner    =   5;
                I_nenner    =   5;
                D_nenner    =   5;
                P_zaehler   =   round(P*2^P_nenner);
                I_zaehler   =   round(I*2^I_nenner);
                D_zaehler   =   round(D*2^D_nenner);
                motorControl.add_to_commandlist(sprintf('#%d:CL_KP_v_Z=%d\r'    , this.motorID, P_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KP_v_N=%d\r'    , this.motorID, P_nenner));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KI_v_Z=%d\r'    , this.motorID, I_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KI_v_N=%d\r'    , this.motorID, I_nenner));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KD_v_Z=%d\r'    , this.motorID, D_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KD_v_N=%d\r'    , this.motorID, D_nenner));
                % Nice values for the positioning closed loop control:
                P       =   200;% (400 = default)
                I       =   1.0;% (2 = default)
                D       =   300;% (700 = default)
                P_nenner    =   3;
                I_nenner    =   5;
                D_nenner    =   3;
                P_zaehler   =   round(P*2^P_nenner);
                I_zaehler   =   round(I*2^I_nenner);
                D_zaehler   =   round(D*2^D_nenner);
                motorControl.add_to_commandlist(sprintf('#%d:CL_KP_s_Z=%d\r'    , this.motorID, P_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KP_s_N=%d\r'    , this.motorID, P_nenner));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KI_s_Z=%d\r'    , this.motorID, I_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KI_s_N=%d\r'    , this.motorID, I_nenner));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KD_s_Z=%d\r'    , this.motorID, D_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KD_s_N=%d\r'    , this.motorID, D_nenner));
                % Kask V-Regler: P = 1.2, I = 0.85, D = 0.7
                % Kask- P-Regler: P = 400 (default), I = 2 (default), D = 700 (default)
                % TODO: Send values to the motor... or we just skip the
                % kaskaded closed loop
            else
                % Use motor as classic step motor without closed loop:
                motorControl.add_to_commandlist(sprintf('#%d:CL_enable=0\r'     , this.motorID));
            end
            % Correction of the sinus-commutierung: (Should be on!)
            motorControl.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r', this.motorID));
            
            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the turntable and not for the motor:
            stepspersecond  =   (this.sArgs_motor.speed/0.9*this.sArgs_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do=%.2f\r'               , this.motorID, stepspersecond));
            % Set mode:
            if this.sArgs_motor.continuous == true
                % Continuous mode:
                motorControl.add_to_commandlist(sprintf('#%dp=5\r'              , this.motorID));
                if (angle > 0)
                    % Turn right: (negative)
                    motorControl.add_to_commandlist(sprintf('#%dd=1\r'          , this.motorID));
                else
                    % Turn left: (positive)
                    motorControl.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID));
                end % Send a command with zero speed to stop the motor!
            else
                % Calculate the number of steps:
                % Divide by 0.9 because each (half)-step is equal to 0.9 degree
                % and multiply by the gear_ratio because the given angle value
                % is for the turntable and not for the motor:
                steps       =   (angle/0.9*this.sArgs_motor.gear_ratio);
                % Check if absolut or relative position mode:
                if this.sArgs_motor.absolut == true
                    % Absolut position mode:
                    motorControl.add_to_commandlist(sprintf('#%dp=2\r'          , this.motorID));
                    % Set position (positive/negaive relative to the
                    % reference:
                    motorControl.add_to_commandlist(sprintf('#%ds=%.2f\r'       , this.motorID, steps));
                    % INFO: -100000000 <= steps <= +100000000!
                else
                    % Relative position mode:
                    motorControl.add_to_commandlist(sprintf('#%dp=1\r'          , this.motorID));
                    motorControl.add_to_commandlist(sprintf('#%ds=%.2f\r'       , this.motorID, abs(steps)));
                    % INFO:     0 < steps <= +100000000! Direction is set seperatly!
                    % Check the direction:
                    if (angle > 0) % Turn right: (negative)
                        motorControl.add_to_commandlist(sprintf('#%dd=1\r'      , this.motorID));
                    else % Turn left: (positive)
                        motorControl.add_to_commandlist(sprintf('#%dd=0\r'      , this.motorID));
                    end
                end
            end
            % Set acceleration ramp: (This formula is given by the
            % programming handbook of Nanotec! Don't ask why it is so
            % complicated!!!!)
            value       =   round((3000/(this.sArgs_motor.acceleration_ramp + 11.7))^2);
            motorControl.add_to_commandlist(sprintf('#%db=%.0f\r'           , this.motorID, value));
            % Brake ramp:
            motorControl.add_to_commandlist(sprintf('#%dB=0\r'              , this.motorID));
            % Zero menas equal to acceleration ramp!
            
            % ------------------------------------------------------------
            % All commands added to commandlist - now send it:
%             if this.send_commandlist(this.failed_command_repititions)
%                 ita_verbose_info('Turntable is prepared...',2);
%                 ret     =   true;
%             else
%                 ita_verbose_info('Something is wrong! Turntable is NOT prepared...',0);
%                 ret     =   false;
%             end

            ret = true;
        end
 
        
    end
    
end

