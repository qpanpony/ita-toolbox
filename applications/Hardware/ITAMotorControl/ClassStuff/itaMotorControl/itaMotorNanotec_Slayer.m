classdef itaMotorNanotec_Slayer < itaMotorNanotec
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
        % used to be sArgs_default_slayer
        sArgs_default_motor    = struct( ...
            'wait',         true,       ...
            'speed',        2,          ...
            'VST',          'adaptiv',  ...
            'acceleration_ramp', 2000,  ...
            'absolut',      true,       ...
            'gear_ratio',   200,        ...
            'current',      80,         ...
            'ramp_mode',    2           ); 
    end
    
    methods
        function this = itaMotorNanotec_Arm(varargin)
            options =   struct('motorControl', []);
            options    =   ita_parse_arguments(options, varargin);
            this.mMotorControl = options.motorControl;
            this.mSerialObj = itaSerialDeviceInterface.getInstance();
            
            this.motorID = 5;
            this.motorName = 'Slayer';
            
            this.motorLimits = [-82 190];
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
            motorControl = this.mMotorControl;
            % Set Input 3 as external Referenceswitch *****Important!!!
            motorControl.add_to_commandlist(sprintf('#%d:port_in_b7\r'  , this.motorID)); % Added swtich 2
            motorControl.add_to_commandlist(sprintf('#%d:port_in_c7\r'  , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a1\r' , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%d:port_out_a2\r' , this.motorID));
            % Define switch behavior
            % DO NOT USE THE FOLLOWING TWO LINES! THEY DON'T WORK
            % AS THEY ARE SUPPOSED TO. CHECK SETTING VIA NANOPRO!
            % Free back for external switch disabled during normal
            %this.add_to_commandlist(sprintf('#%dl=%d\r'         , this.motorID, bin2dec('0100010000101000')));
            % Free back for external switch enabled during normal
            %this.add_to_commandlist(sprintf('#%dl=%d\r'         , this.motorID, bin2dec('001010000100010')));
            motorControl.add_to_commandlist(sprintf('#%dl%d\r'         , this.motorID, 5154));
            motorControl.add_to_commandlist(sprintf('#%dJ=1\r'          , this.motorID));
            motorControl.add_to_commandlist(sprintf('#%dz=0\r'          , this.motorID));

        end
        
        function disableReference(this,value)

        end
        
        function this = moveToReferencePosition(this)
            
            % Prepare reference move (arm)
            if ~this.mIsInit
                ita_verbose_info('Not initialized - This should not happen',0);
            end
            
            % Call Reference-Mode:
            motorControl.add_to_commandlist(sprintf('#%dp=4\r', this.motorID));
            %**********Important!!*********************
            % Set direction:
            motorControl.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID));
            %******************************************
            % Calculate and set upper speed:
            stepspersecond      =   (this.sArgs_default_motor.speed/8/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%du=%.2f\r'       , this.motorID, stepspersecond));
            % Calculate and set lower speed:
            stepspersecond      =   (this.sArgs_default_motor.speed/2/0.9*this.sArgs_default_motor.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do=%.2f\r'       , this.motorID, stepspersecond));
            % Start reference move:
            motorControl.add_to_commandlist(sprintf('#%dA\r'            , this.motorID));

            
            this.old_position = itaCoordinates(1);
            this.mIsReferenced = true;
            ita_verbose_info('Slayer referenced...',1);
        end
        
        function this = startMoveToPosition(this)
             this.mMotorControl.add_to_commandlist(sprintf('#%dA\r'        , this.motorID));
        end
        
        
        function started = prepareMove(this,position,varargin)
            
           if ~this.mIsInit
               ita_verbose_info('Slayer: No initialized! This should not happen!',0)
               started = false;
               return;
           end
           
           if ~this.mIsReferenced
              ita_verbose_info('Slayer: No reference move done! Not moving!',0)
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

            if (angle < this.SLAYER_limit(1)) || (angle > this.SLAYER_limit(2))
                ita_verbose_info(['Slayer: Only values between ' num2str(this.SLAYER_limit(1)) ' and ' num2str(this.SLAYER_limit(2)) ' are allowed!'], 0)
                ret         =   false;
%                 this.wait   =   false;
                return;
            end
            
            angle           =   angle + 84.34; % Reference at -84.34 degree!
            
            
            motorControl = this.mMotorControl;
            
            sArgs_slayer  =   this.sArgs_default_motor;
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
            sArgs_slayer  =   ita_parse_arguments(sArgs_slayer,varargin);
%             this.wait       =   sArgs_arm.wait;
            if (sArgs_slayer.speed == 0)
                % This means: STOP!
                motorControl.add_to_commandlist(sprintf('#%dS\r'        , this.motorID));
                return
            end
            
            if (this.sArgs_slayer.speed > 20) || (this.sArgs_slayer.speed < 0)
                ita_verbose_info('Slayer: Speed must be between >0 and 20!', 0)
                ret             =   false;
                return
            end
         % Set microstep-divider:
            if strcmpi(this.sArgs_slayer.VST, 'adaptiv')
                motorControl.add_to_commandlist(sprintf('#%dg=255\r'         , this.motorID));
            else
                motorControl.add_to_commandlist(sprintf(['#%dg=' this.sArgs_slayer.VST '\r'] , this.motorID));
            end
            % Set maximum current:
            motorControl.add_to_commandlist(sprintf('#%di=%.0f\r'           , this.motorID, this.sArgs_slayer.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            motorControl.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r'    , this.motorID, this.sArgs_slayer.ramp_mode));
            % Set maximum acceleration jerk:
            motorControl.add_to_commandlist(sprintf('#%d:b=100\r'           , this.motorID));
            % Use acceleration jerk as braking jerk:
            motorControl.add_to_commandlist(sprintf('#%d:B=0\r'             , this.motorID));
            % Use motor as classic step motor: (No closed loop supported!)
            motorControl.add_to_commandlist(sprintf('#%d:CL_enable=0\r'     , this.motorID));
            % Correction of the sinus-commutierung: (Should be on!)
            motorControl.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r'    , this.motorID));
            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the arm and not for the motor:
            stepspersecond      =   (this.sArgs_slayer.speed/0.9*this.sArgs_slayer.gear_ratio);
            motorControl.add_to_commandlist(sprintf('#%do=%.2f\r'           , this.motorID, stepspersecond));
            % Calculate the number of steps:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given angle value
            % is for the arm and not for the motor:
            steps               =   (angle/0.9*this.sArgs_slayer.gear_ratio);
            % Only absolut position mode!:
            motorControl.add_to_commandlist(sprintf('#%dp=2\r'              , this.motorID));
            % Set position (positive/negaive relative to the
            % reference:
            motorControl.add_to_commandlist(sprintf('#%ds=%.2f\r'           , this.motorID, steps));
            % Set acceleration ramp:
            % This formula is given by the programming handbook of Nanotec!
            value               =   round((3000/(this.sArgs_slayer.acceleration_ramp + 11.7))^2);
            motorControl.add_to_commandlist(sprintf('#%db=%.0f\r'           , this.motorID, value));
            % Brake ramp:
            motorControl.add_to_commandlist(sprintf('#%dB=0\r'              , this.motorID));
            % Zero menas equal to acceleration ramp!
            ret = true;
        end       
    end
    
end

