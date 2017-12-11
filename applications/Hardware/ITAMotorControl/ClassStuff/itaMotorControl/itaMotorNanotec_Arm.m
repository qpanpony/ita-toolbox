classdef itaMotorNanotec_Arm < itaMotorNanotec
    %ITAMOTORCONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = protected, Hidden = true)
        mSerialObj; % the serial connection
        
        mMotorControl; % parent controlling this class
        sArgs_motor;
        
        
%         mIsReferenced = false;
    end
    
    properties 
        horizontalCorrectionFactor = 0;
    end
    
    properties(Constant, Hidden = true)
        % used to be sArgs_default_arm
        sArgs_default_motor       = struct( ...
            'wait',         true,       ...
            'speed',        1.1,          ...
            'VST',          'adaptiv',  ...
            'closed_loop',  false,      ...
            'acceleration_ramp', 100,   ...
            'gear_ratio',   90,        ...
            'current',      90,         ...
            'ramp_mode',    2           );
    end
    
    methods
        function this = itaMotorNanotec_Arm(varargin)
            options =   struct('motorControl', []);
            options    =   ita_parse_arguments(options, varargin);
            this.mMotorControl = options.motorControl;
            this.mSerialObj = itaSerialDeviceInterface.getInstance();
            
            this.motorID = 4;
            this.motorName = 'Arm';
            
            this.motorLimits = [-90 120];
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
        
        function disableReference(this,value)

        end
        
        function sendConfiguration(this)
            motorControl = this.mMotorControl;
            motorControl.add_to_commandlist(sprintf('#%d:port_in_a7\r'  , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_in_b7\r'  , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a1\r' , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a2\r' , this.motorID));
            % Define switch behavior
            %this.add_to_commandlist(sprintf('#%dl=+%d\r', this.motorID_arm, bin2dec('0100010000101000')));
            % Strange behaviour - do not use l!!!!

            % Define polarity of switchs:
            motorControl.add_to_commandlist(sprintf('#%dh%d\r'         , this.motorID, bin2dec('110000000000111000')));
            motorControl.add_to_commandlist(sprintf('#%dJ1\r'          , this.motorID));
            %this.add_to_commandlist(sprintf('#%dz=0\r', this.motorID_arm));

        end
        
        function this = moveToReferencePosition(this)
            
            % Prepare reference move (arm)
            if ~this.mIsInit
                ita_verbose_info('Not initialized - This should not happen',0);
            end
            
            motorControl = this.mMotorControl;
            % Call Current:
            motorControl.add_to_commandlist(sprintf('#%di90\r'          , this.motorID));
            % External Reference Run
            motorControl.add_to_commandlist(sprintf('#%dp4\r'          , this.motorID));
            % Set direction to right: (IMPORTANT!)
            motorControl.add_to_commandlist(sprintf('#%dd1\r'          , this.motorID));
            % Calculate and set upper speed:
            stepspersecond    	=   (this.sArgs_default_motor.speed/5/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%du%.2f\r'       , this.motorID, stepspersecond));
            % Calculate and set lower speed:
            stepspersecond      =   (this.sArgs_default_motor.speed/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do%.2f\r'       , this.motorID, stepspersecond));
            % Start reference move:
            motorControl.add_to_commandlist(sprintf('#%dA\r'            , this.motorID));

            
            this.old_position = itaCoordinates(1);
            this.mIsReferenced = true;
            ita_verbose_info('Arm referenced...',2);
        end
        
        function this = startMoveToPosition(this)
             this.mMotorControl.add_to_commandlist(sprintf('#%dA\r'        , this.motorID));
        end
        
        
        function started = prepareMove(this,position,varargin)
            
           if ~this.mIsInit
               ita_verbose_info('Arm: No initialized! This should not happen!',0)
               started = false;
               return;
           end
           
           if ~this.mIsReferenced
              ita_verbose_info('Arm: No reference move done! Not moving!',0)
              started = false;
              return;
           end
            
           sArgs.continuous = false;
           sArgs.speed = this.sArgs_default_motor.speed;
           if ~isempty(varargin)
               sArgs = ita_parse_arguments(sArgs,varargin);
           end
           if sArgs.continuous
                ret = this.prepare_move(position, 'speed', sArgs.speed,'continuous', true); 
                started = true;
           else
               % if only the theta angle is given
               if ~isa(position,'itaCoordinates')
                  tmpPosition = this.old_position;
                  if ~isnan(position)
                      tmpPosition.theta_deg = position;
                  end
                  position = tmpPosition;
               end

               if this.old_position.theta ~= position.theta

                    angle = position.theta_deg;
                    ret = this.prepare_move(angle, 'wait', true); 
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
%              if ~this.isInitialized
%                 ita_verbose_info('Not initialized - I will do that for you...!',0);
%                 this.initialize
%             end
%             if ~this.isReferenced
%                 ita_verbose_info('Arm: You are not allowed to move the arm until you made a reference move!', 0)
%                 ret         =   false;
%                 this.wait   =   false;
%                 return;
%             end

            if isnan(angle)
                ret = false;
                return;
            end

            if (angle < this.motorLimits(1)) || (angle > this.motorLimits(2))
                ita_verbose_info(['Arm: Only values between ' num2str(this.motorLimits(1)) ' and ' num2str(this.motorLimits(2)) ' are allowed!'], 0)
                ret         =   false;
%                 this.wait   =   false;
                return;
            end
            
            angle = angle - 120-1.7+this.horizontalCorrectionFactor; % Larger substractive value: Higher position. Checkt at 90�.
            
            motorControl = this.mMotorControl;
            
            sArgs_arm  =   this.sArgs_default_motor;
            % -------------------------------------------------------------
            % Meaning:
            %
            % Wait              =   Stop matlab until motor reaches final position!
            % Speed             =   Grad/sec of the arm
            % VST               =   Microstep divider. Values: 1, 2, 4, 5, 8, 10, 16, 32,
            %                       64. 254="Vorschubkonstantenmodus", 255=Adaptive Stepdivider
            % Closed_loop       =   Turn on the closed loop regulation
            % Acceleration_ramp =   Value in Hz/ms
            % Gear_ratio        =   Getriebe�bersetzung
            % Current           =   Maximum current in percent
            % Ramp_mode         =   0=trapez, 1=sinus-ramp, 2=jerkfree-ramp
            % -------------------------------------------------------------
            sArgs_arm  =   ita_parse_arguments(sArgs_arm,varargin);
%             this.wait       =   sArgs_arm.wait;
            if (sArgs_arm.speed == 0)
                % This means: STOP!
                motorControl.add_to_commandlist(sprintf('#%dS\r'        , this.motorID));
                return
            end
            
            if (sArgs_arm.speed > 3) || (sArgs_arm.speed < 0)
                ita_verbose_info('Arm: Speed must be between >0 and 3!', 0)
                ret = false;
                return
            end
            % Set microstep-divider:
            if strcmpi(sArgs_arm.VST, 'adaptiv')
                motorControl.add_to_commandlist(sprintf('#%dg=255\r'     , this.motorID));
            else
                motorControl.add_to_commandlist(sprintf(['#%dg=' sArgs_arm.VST '\r']    , this.motorID));
            end
            % Set maximum current to 100%:
            motorControl.add_to_commandlist(sprintf('#%di%.0f\r'       , this.motorID, sArgs_arm.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            motorControl.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r', this.motorID, sArgs_arm.ramp_mode)); % if hell breaks loose, check here!
            % Set maximum acceleration jerk:
            motorControl.add_to_commandlist(sprintf('#%d:b=100\r'       , this.motorID));
            % Use acceleration jerk as braking jerk:
            motorControl.add_to_commandlist(sprintf('#%d:B=0\r'         , this.motorID));  % if hell breaks loose, check here!
            % Closed_loop?
            if sArgs_arm.closed_loop == true
                ita_verbose_info('Closed-loop-parameter not adjusted for the arm (yet)! Using turntable parameter. May not work as you wish..!', 0)
                % Activate CL during movement:
                motorControl.add_to_commandlist(sprintf('#%d:CL_enable=2\r' , this.motorID));
                % Some nice values measured for the turntable:
                pos         =   [0.5 1 2 3 4 8 12 16 25 32 40 50];
                vecP        =   [0.5 1.5 2.5 3.5 4.5 4.5 5.5 2.5 2.0 1.3 1.3 1.3];
                vecI        =   [0.05 0.1 0.2 0.3 0.4 0.8 1.2 1.6 2.0 2.5 2.5 2.5];
                vecD        =   [9 6 4 3 2 1 1 3 6 10 10 10];
                pP          =   polyfit(pos,vecP,5);
                pI          =   polyfit(pos,vecI,5);
                pD          =   polyfit(pos,vecD,5);
                P           =   polyval(pP,sArgs_arm.speed);
                I           =   polyval(pI,sArgs_arm.speed);
                D           =   polyval(pD,sArgs_arm.speed);
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
                % Pos-Kreis:
                % F�r 10�/s
                %P = 100;% (400 = default)
                %I = 1.5;% (2 = default)
                %D = 300;% (700 = default)
                % F�r 3�/s
                P           =   200;% (400 = default)
                I           =   1.0;% (2 = default)
                D           =   300;% (700 = default)
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
            else
                % Use motor as classic step motor:
                motorControl.add_to_commandlist(sprintf('#%d:CL_enable=0\r'     , this.motorID));
            end
            
            % Correction of the sinus-commutierung: (Should be on!)
            motorControl.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r', this.motorID));
            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the arm and not for the motor:
            stepspersecond  = (sArgs_arm.speed/0.9*sArgs_arm.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do%.2f\r'               , this.motorID, stepspersecond));
            % Calculate the number of steps:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given angle value
            % is for the arm and not for the motor:
            steps           = (angle/0.9*sArgs_arm.gear_ratio);
            
            % ONLY absolut position mode allowed:
            motorControl.add_to_commandlist(sprintf('#%dp2\r'              , this.motorID));
            % Set position (positive/negaive relative to the reference:
            motorControl.add_to_commandlist(sprintf('#%ds%.2f\r'           , this.motorID, steps));
            % INFO: -100000000 <= steps <= +100000000!
            
            % Set acceleration ramp:
            % This formula is given by the programming handbook of Nanotec:
            value           =   round((3000/(sArgs_arm.acceleration_ramp + 11.7))^2);
            motorControl.add_to_commandlist(sprintf('#%db%.0f\r'           , this.motorID, value));
            % Brake ramp:
            motorControl.add_to_commandlist(sprintf('#%dB0\r'              , this.motorID));
            % Zero means equal to acceleration ramp!
            ret = true;
        end       
    end
    
end

