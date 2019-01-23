classdef itaMotorNanotec_HRTFarc < itaMotorNanotec
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
            'wait',             true,       ...
            'speed',            1,          ...
            'VST',              'adaptiv',  ...
            'limit',            true,      ...
            'continuous',       false,      ...
            'absolut',          true,      ...
            'closed_loop',      false,       ...
            'acceleration_ramp',20,  ...
            'decceleration_ramp',20, ...
            'gear_ratio',       80,        ...
            'current',          100,        ...
            'ramp_mode',        2,           ...
            'P',                400, ...
            'I',                2.0, ...
            'D',                700, ...
            'P_nenner',         3, ...
            'I_nenner',         5,...
            'D_nenner',         3);
    end

    methods
        function this = itaMotorNanotec_HRTFarc(varargin)
            options =   struct('motorControl', []);
            options    =   ita_parse_arguments(options, varargin);
            this.mMotorControl = options.motorControl;
            this.mSerialObj = itaSerialDeviceInterface.getInstance();
            this.mIsReferenced = 0;

            this.motorID = 8;
            this.motorName = 'HRTFArc';
            this.motorLimits = [-45 330]; % the motor can do a whole rotation + ~15 deg to both sides
        end

        function this = init(this)
            this.setReferenced(false);
        end


        function disableReference(this,value)
            if value
                this.mMotorControl.sendControlSequenceAndPrintResults(':port_in_a=0');
            else
                this.mMotorControl.sendControlSequenceAndPrintResults(':port_in_a=7');
            end
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

%         function freeFromStopButton(this)
%            res = motorControl.sendControlSequenceAndPrintResults('Zd');
%            resp = res{end};
%            direction = str2double(resp(end));
%
%            if direction == 0
%               direction = -1;
%            else
%                direction = 1;
%            end
%            this.allowMoveOverRefButton(1);
%            this.prepareMove(direction*20,'absolut',false,'speed',10);
%            this.startMoveToPosition();
%            this.allowMoveOverRefButton(0);
%         end


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
            motorControl.add_to_commandlist(sprintf('#%d:port_in_b=7\r'  , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a=1\r' , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a=2\r' , this.motorID));
            % phasenstrom im stillstand
            motorControl.add_to_commandlist(sprintf('#%dr=0\r' , this.motorID));
            % fehlerkorrekturmodus
            motorControl.add_to_commandlist(sprintf('#%dU=0\r' , this.motorID));
            % ausschwingzeit
            motorControl.add_to_commandlist(sprintf('#%dO=1\r' , this.motorID));
            % umkehrspiel
            motorControl.add_to_commandlist(sprintf('#%dz=5\r'          , this.motorID));

            % automatisches senden des status deaktivieren
            motorControl.add_to_commandlist(sprintf('#%dJ=0\r'          , this.motorID));
            % endschalterverhalten: the ref manual is not very clear. bit 0
            % is the most important bit. all not listed bits are 0
            % defValue bin2dec('0100010000100010') = 17442
            this.allowMoveOverRefButton(0);

            % set lower speed to 1 Hz/sec (lowest value)
            motorControl.add_to_commandlist(sprintf('#%du3\r'          , this.motorID));

        end

        function this = moveToReferencePosition(this)
            % Prepare reference move (turntable)
            motorControl = this.mMotorControl;
            % Turn + some degrees in case we are already at the end of the
            % reference switch or already passed it:
%             this.prepareMove(20,'absolut',false,'speed',10);
%             this.startMoveToPosition();
%             if this.mMotorControl.send_commandlist(5);
%                 ita_verbose_info('HRTFarc started move...',2);
%             end
%             tmpWait = motorControl.wait;
%             motorControl.wait = true;
%             motorControl.wait4everything;
%             motorControl.wait = tmpWait;
            this.disableReference(0);
            % Call Reference-Mode:
            motorControl.add_to_commandlist(sprintf('#%dp=4\r'          , this.motorID));
            % Set direction:
            motorControl.add_to_commandlist(sprintf('#%dd=1\r'          , this.motorID));
            % Calculate and set lower speed:
            stepspersecond      =   round(this.sArgs_default_motor.speed/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%du=%d\r'       , this.motorID, stepspersecond));
            % Calculate and set upper speed:
            stepspersecond      =   round(this.sArgs_default_motor.speed/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do=%d\r'       , this.motorID, stepspersecond));
            % set decel to a high value so the switch is not overrun
            motorControl.add_to_commandlist(sprintf('#%d:decel1%.0f\r'              , this.motorID,100));

            % Start reference move:
            motorControl.add_to_commandlist(sprintf('#%dA\r'            , this.motorID));


            this.old_position = itaCoordinates(1);

        end

        function this = startMoveToPosition(this)
             this.mMotorControl.add_to_commandlist(sprintf('#%dA\r'        , this.motorID));
        end


        function started = prepareMove(this,position,varargin)
           sArgs = this.sArgs_default_motor;
           sArgs.continuous = false;
           if ~isempty(varargin)
               [sArgs,~] = ita_parse_arguments(sArgs,varargin);
           end
           if sArgs.continuous
                ret = this.prepare_move(position, sArgs);
                started = true;
           else
                   % if only the phi angle is given
                   if ~isa(position,'itaCoordinates')
                      tmpPosition = this.old_position;
                      if ~isnan(position)
                          tmpPosition.phi_deg = position;
                      end
                      position = tmpPosition;
                   end
               if sArgs.absolut == 1
                   if this.old_position.phi ~= position.phi

                        angle = mod(position.phi(1)/2/pi*360+360, 721)-360;
                        ret = this.prepare_move(angle, sArgs);
                        this.old_position = position;
                        started = true;
                   else
                        started = false;
                   end
               else
                    % in relative positioning mode, the angle is calculated
                    % and added to the old position
                    angle = position.phi_deg(1);
                    ret = this.prepare_move(angle, sArgs);
                    this.old_position = this.old_position + position;
                    started = true;
               end
           end
        end

    end

    methods(Hidden = true)

        function this = allowMoveOverRefButton(this,value)
           motorControl = this.mMotorControl;
           if value
              motorControl.sendControlSequenceAndPrintResults('l17442');
           else
              motorControl.sendControlSequenceAndPrintResults('l5154');
           end
%            Frei r�ckw�rts
%            5154
%            Stop
%            9250
        end



        function ret = prepare_move(this, angle, varargin)
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

            this.sArgs_motor = ita_parse_arguments(varargin{:});
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
                    if (angle > this.motorLimits(2)) || (angle < this.motorLimits(1))
                        % It's not in the allowed range... :-(
                        error('Limit is on! Only positions between %d and %d degree are allowed!',this.motorLimits)
                    end
                else
                    % Limit is on and relative positioning is on... this case
                    % is a bit more complex!
                    % Get position: motorposition does not work. using
                    % saved old position instead
                    % in the init case, old_position is not set.
                    if isnan(this.old_position.phi_deg)
                        this.mSerialObj.sendAsynch(sprintf('#%dC\r'      , this.motorID));
                        act_pos       =   this.mSerialObj.recvAsynch();
                        act_pos       =   str2double(act_pos(3:end));
                        % Now multiply with 0.9 and divide by gear_ratio to get
                        % the position angle of the turntable:
                        act_pos     =   -act_pos*0.9/this.sArgs_motor.gear_ratio;
                    else
                        act_pos       =   this.old_position.phi_deg;
                    end
                    % Check if old position would be in the allowed range:
                    if ((act_pos) > this.motorLimits(2)) || ((act_pos) < this.motorLimits(1))
                        % No, it's not....
                        ita_verbose_info('Warning: Could not determine a sensible position. Doing reference anyway.',0)
                    else
                        % Check if new position would be in the allowed range:
                        if ((act_pos+angle) > this.motorLimits(2)) || ((act_pos+angle) < this.motorLimits(1))
                            % No, it's not....
                            error('Limit is on! Only positions between %d and %d degree are allowed!',this.motorLimits)
                        end
                    end
                end
            end
            % Set microstep-divider:
%             if strcmpi(this.sArgs_motor.VST, 'adaptiv')
%                 motorControl.add_to_commandlist(sprintf('#%dg255\r'     , this.motorID));
%             else
%                 motorControl.add_to_commandlist(sprintf(['#%dg' this.sArgs_motor.VST '\r']  , this.motorID));
%             end
            % Set maximum current to 100%:
            motorControl.add_to_commandlist(sprintf('#%di%.0f\r'       , this.motorID, this.sArgs_motor.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            motorControl.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r', this.motorID, this.sArgs_motor.ramp_mode));
%             % Set maximum acceleration jerk:
             motorControl.add_to_commandlist(sprintf('#%d:b=4\r'       , this.motorID));
%             % Use acceleration jerk as braking jerk:
            motorControl.add_to_commandlist(sprintf('#%d:B=0\r'         , this.motorID));
            % Closed_loop?
            %this.sArgs_motor.closed_loop = true; % DEBUG!
            if this.sArgs_motor.closed_loop == true
                % JEAR! Without this the new motor would be nonsense!
                % Activate CL during movement:
                motorControl.add_to_commandlist(sprintf('#%d:CL_enable=2\r' , this.motorID));
                % Nice values for the speed closed loop control:
%                 pos     =   [0.5 1 2 3 4 8 12 16 25 32 40 50];
%                 vecP    =   [0.5 1.5 2.5 3.5 4.5 4.5 5.5 2.5 2.0 1.3 1.3 1.3];
%                 vecI    =   [0.05 0.1 0.2 0.3 0.4 0.8 1.2 1.6 2.0 2.5 2.5 2.5];
%                 vecD    =   [9 6 4 3 2 1 1 3 6 10 10 10];
%                 pP      =   polyfit(pos,vecP,5);
%                 pI      =   polyfit(pos,vecI,5);
%                 pD      =   polyfit(pos,vecD,5);
%                 P       =   polyval(pP,this.sArgs_motor.speed);
%                 I       =   polyval(pI,this.sArgs_motor.speed);
%                 D       =   polyval(pD,this.sArgs_motor.speed);
%                 P_nenner    =   5;
%                 I_nenner    =   5;
%                 D_nenner    =   5;
                P           =   this.sArgs_motor.P;% (400 = default)
                I           =   this.sArgs_motor.I;% (2 = default)
                D           =   this.sArgs_motor.D;% (700 = default)
                P_nenner    =   this.sArgs_motor.P_nenner;
                I_nenner    =   this.sArgs_motor.I_nenner;
                D_nenner    =   this.sArgs_motor.D_nenner;
                P_zaehler   =   round(P*2^P_nenner);
                I_zaehler   =   round(I*2^I_nenner);
                D_zaehler   =   round(D*2^D_nenner);
                motorControl.add_to_commandlist(sprintf('#%d:CL_KP_v_Z=%d\r'    , this.motorID, P_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KP_v_N=%d\r'    , this.motorID, P_nenner));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KI_v_Z=%d\r'    , this.motorID, I_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KI_v_N=%d\r'    , this.motorID, I_nenner));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KD_v_Z=%d\r'    , this.motorID, D_zaehler));
                motorControl.add_to_commandlist(sprintf('#%d:CL_KD_v_N=%d\r'    , this.motorID, D_nenner));
%                 % Nice values for the positioning closed loop control:

                P           =   this.sArgs_motor.P;% (400 = default)
                I           =   this.sArgs_motor.I;% (2 = default)
                D           =   this.sArgs_motor.D;% (700 = default)
                P_nenner    =   this.sArgs_motor.P_nenner;
                I_nenner    =   this.sArgs_motor.I_nenner;
                D_nenner    =   this.sArgs_motor.D_nenner;
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

            % JRI: unknown command?
            % Correction of the sinus-commutierung: (Should be on!)
            % motorControl.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r', this.motorID));

            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the turntable and not for the motor:
            stepspersecond  =   round((this.sArgs_motor.speed/0.9*this.sArgs_motor.gear_ratio));
            motorControl.add_to_commandlist(sprintf('#%do%d\r'               , this.motorID, stepspersecond));
            % Set mode:
            if this.sArgs_motor.continuous == true
                motorControl.add_to_commandlist(sprintf('#%dp=5\r'              , this.motorID));
                if (angle > 0)
                    % Turn right: (negative)
                    motorControl.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID));
                else
                    % Turn left: (positive)
                    motorControl.add_to_commandlist(sprintf('#%dd=1\r'          , this.motorID));
                end
                steps       =   (angle/0.9*this.sArgs_motor.gear_ratio);
                motorControl.add_to_commandlist(sprintf('#%ds=%d\r'       , this.motorID, round(abs(steps))));
            else
                % Calculate the number of steps:
                % Divide by 0.9 because each (half)-step is equal to 0.9 degree
                % and multiply by the gear_ratio because the given angle value
                % is for the turntable and not for the motor:
                steps       =   (angle/0.9*this.sArgs_motor.gear_ratio);
                % Check if absolut or relative position mode:
                if this.sArgs_motor.absolut == true
                    % Absolut position mode:
                    motorControl.add_to_commandlist(sprintf('#%dp2\r'          , this.motorID));
                    % Set position (positive/negaive relative to the
                    % reference:
                    motorControl.add_to_commandlist(sprintf('#%ds%d\r'       , this.motorID, -round(steps)));
                    % INFO: -100000000 <= steps <= +100000000!
                else
                    % Relative position mode:
                    motorControl.add_to_commandlist(sprintf('#%dp1\r'          , this.motorID));
                    motorControl.add_to_commandlist(sprintf('#%ds%d\r'       , this.motorID, round(abs(steps))));
                    % INFO:     0 < steps <= +100000000! Direction is set seperatly!
                    % Check the direction:
                    if (angle > 0) % Turn right: (negative)
                        motorControl.add_to_commandlist(sprintf('#%dd0\r'      , this.motorID));
                    else % Turn left: (positive)
                        motorControl.add_to_commandlist(sprintf('#%dd1\r'      , this.motorID));
                    end
                end
            end
            % Set acceleration ramp directly
             motorControl.add_to_commandlist(sprintf('#%d:accel%.0f\r'           , this.motorID, this.sArgs_motor.acceleration_ramp));
            % Brake ramp:
            motorControl.add_to_commandlist(sprintf('#%d:decel1%.0f\r'              , this.motorID,this.sArgs_motor.decceleration_ramp));
            % Zero menas equal to acceleration ramp!

            ret = true;
        end


    end

end
