classdef itaEimar < itaMeasurementTasksScan
    % Measurements with the ITA Italian Turntable (Nanotec motors), ITA Arm and the ITA Slayer
    %
    %
    
    % *********************************************************************
    %
    % E = Everything
    % I = Is
    % M = Moving
    % A = And
    % R = Rotating
    %
    % *********************************************************************
    %
    % BE AWARE: NEW MOTOR AND NEW MOTORCONTROLLER! NOT COMPATIBLE TO
    % MOVTEC!
    %
    % Motor and Controller are combined!
    % Type: Nanotec PD4-N59  18M4204 (Turntable)
    %       Nanotec PD4-N60  18L4204 (Arm)
    %       Nanotec PD2-O411 18L1804 (Slayer)
    %
    % Author:       Benedikt Krechel - November-June 2012
    %               Johannes Klein - March/April/May 2012
    %
    % Contact:      Benedikt.krechel@rwth-aachen.de
    %               Johannes.klein@rwth-aachen.de
    %
    % Otherwise:    Pascal Dietrich!
    %               pdi@akustik.rwth-aachen.de
    %
    % Special thanks to: Oliver Strauch for changing the e in Eimer to an a!
    %
    % *********************************************************************
    % *********************************************************************
    %
    % HOW TO USE:
    %
    % iMS = itaEimar;
    % -> Will call init and give note about which motor is connected.
    %
    % IMPORTANT COMMAND:
    % -  iMS.stop
    %
    % Make the reference move:
    % ( - without this you are not allowed to move the arm or the slayer (but the turntable)! - )
    % -  iMS.reference
    %
    % Move commands:
    % -  iMS.moveTo( itaCoordinate Object )
    %
    % Separate move commands:
    % -  iMS.move_turntable( in degrees, counter-clockwise relative to actual position )
    % -  iMS.move_arm( absolut degree )
    % -  iMS.move_slayer( absolut degree )
    %
    % ************************************
    % STATIC MEASUREMENT:
    %
    % How to prepare the measurement:
    % -  iMS.measurementPositions = ita_sph_sampling_gaussian(30); (i.e.)
    % -  iMS.measurementSetup = [ YOUR MEASUREMENT SETUP i.e. itaMSTF ]
    % -  iMS.dataPath = [ PATH / FOLDER FOR RESULTS ]
    %
    % Run measurement
    % -  iMS.run
    %
    %
    % ************************************
    % DYNAMIC MEASUREMENT:
    %
    % -  iMS.ContinuousMeasurement = true;
    % -  iMS.measurementPositions = [ n times two itaCoordinate Objects,
    %                                 first one  :   Start position
    %                                 second one :   Speed and direction  ]
    %
    % -  iMS.measurementSetup = [ YOUR MEASUREMENT SETUP i.e. itaMSTF ]
    % -  iMS.dataPath = [ PATH / FOLDER FOR RESULTS ]
    %
    % Run measurement
    % -  iMS.run
    %
    %
    % *********************************************************************
    % POSTPROCESSING FUNCTIONS:
    % 
    % It is possible to set postprocessing functions that are called after
    % each measurement
    %
    %   functionHandles = {@someFunction,@someOtherFunction}
    %   iMS.postProcessingFunctions = functionHandle;
    %
    % The functions are given the Eimar-Object, the measurement result and
    % some metadata (measurement number etc).
    % They have to return the processed audioObject
    %
    %   ao = someFunction( varargin )
    %
    % To pass additional arguments, anonymous function handles can be used:
    %
    %   someAdditionalStuff = 4;
    %   function1 = @(varargin)someFunction(varargin,someAdditionalStuff);
    %   functionHandles = {function0,@someOtherFunction}
    %
    % *********************************************************************
    %
    % <ITA-Toolbox>
    % This file is part of the application Movtec for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties
        waitForSerialPort   =     0.020;    % Time to wait between two commands
        timeout_response    =     0.1;      % Time in seconds within each motor has to response to a command!
        timeout_move        =   300;        % Time in seconds within each device has to reach their new position!
        failed_command_repititions  =   5;  % How often do we repeat commands until we throw an error?
        doSorting           =     true;     % sort the measurement coordinates for arm due to shorter measurement time 
        armCorrectionAngle  =   0;          % Correct the position of the arm. Check at 90° if horizontal. Value <0 -> higher position
    end
    % *********************************************************************
    properties (Access = protected, Hidden = true)
        isReferenced        =   false;      % Are all motors referenced?
        inuse               =   struct( ... % Which motors are in use?
            'turntable',    false, ...
            'arm',          false, ...
            'slayer',       false);
        started             =   struct( ... % Which motors are on right now?
            'turntable',    false, ...
            'arm',          false, ...
            'slayer',       false);
        commandlist         =   []; % Store commands in here...
        receivedlist        =   []; % All responses from all motors
        actual_status       =   []; % Store status - don't send the same command again!
        old_position        =   itaCoordinates(2); % Avoid to move two times to the same position
        wait                =   true;        % Status - do we wait for motors to reach final position? -> Set by prepare-functions!
        sArgs_turntable     =   [];
        sArgs_arm           =   [];
        sArgs_slayer        =   [];
    end
    % *********************************************************************
    properties(Constant, Hidden = true)
        sArgs_default_slayer    = struct( ...
            'wait',         true,       ...
            'speed',        2,          ...
            'VST',          'adaptiv',  ...
            'acceleration_ramp', 2000,  ...
            'absolut',      true,       ...
            'gear_ratio',   200,        ...
            'current',      80,         ...
            'ramp_mode',    2           );
        
        sArgs_default_turntable = struct( ...
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
        
        %         sArgs_default_arm       = struct( ...
        %                                 'wait',         true,       ...
        %                                 'speed',        0.5,          ...
        %                                 'VST',          'adaptiv',  ...
        %                                 'closed_loop',  false,      ...
        %                                 'acceleration_ramp', 100,   ...
        %                                 'gear_ratio',   60,        ...
        %                                 'current',      90,         ...
        %                                 'ramp_mode',    2           );
        sArgs_default_arm       = struct( ...
            'wait',         true,       ...
            'speed',        1.1,          ...
            'VST',          'adaptiv',  ...
            'closed_loop',  false,      ...
            'acceleration_ramp', 100,   ...
            'gear_ratio',   90,        ...
            'current',      90,         ...
            'ramp_mode',    2           );
        
        
        % *********************************************************************
        % *********************************************************************
        % * NEVER change the motor-IDs if you are not 99.9999999% sure what   *
        % * you do!!! May destroy arm and slayer!                             *
        motorID_turntable       =               3; % Motor-ID turntable     *
        motorID_arm             =               4; % Motor-ID arm           *
        motorID_slayer          =               5; % Motor-ID slayer        *
        
        ARM_limit               =         [-90 120]; % Movement-range of Arm %jck: THIS SHOULD BE COUPLED TO THE VALUE IN prepare_move_arm
        SLAYER_limit            =       [-82 190]; % Movement-range of Slayer
        % *********************************************************************
        % *********************************************************************
    end
    % *********************************************************************
    % *********************************************************************
    % *********************************************************************
    methods
        %% -----------------------------------------------------------------
        % Basic stuff:
        function this = itaEimar(varargin)
            % Constructor
            this.init;
        end
        function reset(this)
            %reset the Object. Ready to start from scatch again...
            this.clear_actual_status;
            this.mIsInitialized     =   false;
            this.mCurrentPosition   =   cart2sph(itaCoordinates(1));
            this.mLastMeasurement   =   0;
        end
        
        function clear_actual_status(this)
            % Clear confirmed commands which do not need to be send again.
            % Usefull if motor is turned off and on while class-object in
            % Matlab remains without a change.
            this.actual_status   =   [];
        end
        % If serial port does not work properly or class reloaded from disc:
        function close_port(this)
            % Close serial port
            fclose(this.mSerialObj);
        end
        function reopen_port(this)
            % Try to reopen serial port
            insts                   =   instrfind;         %show existing terminals using serial interface
            com_port                =   ita_preferences('movtecComPort');
            if ~isempty(insts)
                aux                 =   strfind(insts.Name,com_port);
                if numel(aux) == 1
                    aux             =   {aux};
                end
                for idx = 1:numel(aux)
                    if ~isempty(aux{idx})
                        delete(insts(idx));             %delete used serial ports
                    end
                end
            end
            try
                %this.mSerialObj     =   serial(com_port,'Baudrate',115200,'Databits',8,'Stopbits',1,'OutputBufferSize',3072);
                this.mSerialObj     =   serial(com_port,'Baudrate',19200,'Databits',8,'Stopbits',1,'OutputBufferSize',3072);
                this.mSerialObj.Terminator              =   13;
                this.mSerialObj.BytesAvailableFcnMode   =   'terminator';
                fopen(this.mSerialObj);
            catch errmsg
                ita_verbose_info(errmsg.message,0);
                ita_verbose_info('Could not open port... something might be wrong!', 0);
            end
        end
        
        function init(this, varargin)
            % Initialize class
            
            this.inuse              =   ita_parse_arguments(this.inuse, varargin);
            %do a reset and also reset the serialObj
            this.reset(); % Do a reset first.
            this.commandlist        =   [];
            this.receivedlist       =   [];
            this.actual_status           =   [];
            com_port                =   ita_preferences('movtecComPort');
%             if ~isempty(this.diaryFile) % jck: why again? and: turned off see comment in itaMeasurementTasksScan
%                 diary off;
%                 diary(this.diaryFile);
%             end
            if strcmpi(com_port,'noDevice')
                ita_verbose_info('Please select a COM-Port in ita_preferences (I''m using the Movtec-Port!)',0);
                ita_preferences;
                return;
            end
            % Init RS232 and return handle
            try
                if isempty(this.measurementSetup)
                elseif isempty(this.measurementSetup) && isempty(this.measurementSetup.inputMeasurementChain(1).coordinates.x)
                    for idx = 1:numel(this.measurementSetup.inputMeasurementChain)
                        this.measurementSetup.inputMeasurementChain(idx).coordinates = itaCoordinates([0 0 0]);
                    end
                end
                
                insts               =   instrfind;         %show existing terminals using serial interface
                if ~isempty(insts)
                    aux = strfind(insts.Name,com_port);
                    if numel(aux) == 1
                        aux = {aux};
                    end
                    for idx = 1:numel(aux)
                        if ~isempty(aux{idx})
                            delete(insts(idx));             %delete used serial ports
                        end
                    end
                end
                this.mSerialObj     =   serial(com_port,'Baudrate',19200,'Databits',8,'Stopbits',1,'OutputBufferSize',3072);
                this.mSerialObj.Terminator              =   13;
                this.mSerialObj.BytesAvailableFcnMode   =   'terminator';
                fopen(this.mSerialObj);    % open port
                pause(0.1); % Wait for 100 ms to ensure an open port!
                if isempty(varargin)
                    this.inuse.turntable        =   false;
                    this.inuse.arm              =   false;
                    this.inuse.slayer           =   false;
                    % Send a status request to each motor:
                    fwrite(this.mSerialObj, sprintf('#%d$\r'    , this.motorID_turntable));
                    pause(0.1) % Do a small pause to avoid conflicts!
                    fwrite(this.mSerialObj, sprintf('#%d$\r'    , this.motorID_arm));
                    pause(0.1)
                    fwrite(this.mSerialObj, sprintf('#%d$\r'    , this.motorID_slayer));
                    pause(0.1)
                    % Check which motor responded to the request:
                    idx = 0;
                    while idx < 50
                        if this.mSerialObj.BytesAvailable ~= 0
                            resp = fgetl(this.mSerialObj);
                            if strcmpi(resp(3), num2str(this.motorID_turntable))
                                this.inuse.turntable    =   true;
                            elseif strcmpi(resp(3), num2str(this.motorID_arm))
                                this.inuse.arm          =   true;
                            elseif strcmpi(resp(3), num2str(this.motorID_slayer))
                                this.inuse.slayer       =   true;
                            end
                        end
                        pause(0.01) % Half second to respond... more than enough!
                        idx = idx + 1;
                    end
                end
                % Tell the user which motors are in use:
                display(this.inuse)
                % Send configuration to each motor if accessable:
                if this.inuse.turntable
                    % Set Input 1 as external Referenceswitch
                    this.add_to_commandlist(sprintf('#%d:port_in_a=7\r'  , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%d:port_out_a=1\r' , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%d:port_out_a=2\r' , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%dr=0\r' , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%dU=0\r' , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%dO=1\r' , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%dz=0\r'          , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%dJ=1\r'          , this.motorID_turntable));
                    if ~this.send_commandlist(this.failed_command_repititions)
                        this.mIsInitialized             =   false;
                        error('Motor_turntable is not responding!')
                    end
                end
                if this.inuse.arm
                    % Set Input 1 and 2 as external Referenceswitch
                    
                    this.add_to_commandlist(sprintf('#%d:port_in_a7\r'  , this.motorID_arm));
                    this.add_to_commandlist(sprintf('#%d:port_in_b7\r'  , this.motorID_arm));
                    this.add_to_commandlist(sprintf('#%d:port_out_a1\r' , this.motorID_arm));
                    this.add_to_commandlist(sprintf('#%d:port_out_a2\r' , this.motorID_arm));
                    % Define switch behavior
                    %this.add_to_commandlist(sprintf('#%dl=+%d\r', this.motorID_arm, bin2dec('0100010000101000')));
                    % Strange behaviour - do not use l!!!!
                    
                    % Define polarity of switchs:
                    this.add_to_commandlist(sprintf('#%dh%d\r'         , this.motorID_arm, bin2dec('110000000000111000')));
                    this.add_to_commandlist(sprintf('#%dJ1\r'          , this.motorID_arm));
                    %this.add_to_commandlist(sprintf('#%dz=0\r', this.motorID_arm));
                    if ~this.send_commandlist(this.failed_command_repititions)
                        this.mIsInitialized             =   false;
                        error('Motor_arm is not responding!')
                    end
                end
                if this.inuse.slayer
                    % Set Input 3 as external Referenceswitch *****Important!!!
                    this.add_to_commandlist(sprintf('#%d:port_in_b7\r'  , this.motorID_slayer)); % Added swtich 2
                    this.add_to_commandlist(sprintf('#%d:port_in_c7\r'  , this.motorID_slayer));
                    this.add_to_commandlist(sprintf('#%d:port_out_a1\r' , this.motorID_slayer));
                    this.add_to_commandlist(sprintf('#%d:port_out_a2\r' , this.motorID_slayer));
                    % Define switch behavior
                    % DO NOT USE THE FOLLOWING TWO LINES! THEY DON'T WORK
                    % AS THEY ARE SUPPOSED TO. CHECK SETTING VIA NANOPRO!
                    % Free back for external switch disabled during normal
                    %this.add_to_commandlist(sprintf('#%dl=%d\r'         , this.motorID_slayer, bin2dec('0100010000101000')));
                    % Free back for external switch enabled during normal
                    %this.add_to_commandlist(sprintf('#%dl=%d\r'         , this.motorID_slayer, bin2dec('001010000100010')));
                    this.add_to_commandlist(sprintf('#%dl%d\r'         , this.motorID_slayer, 5154));
                    this.add_to_commandlist(sprintf('#%dJ=1\r'          , this.motorID_slayer));
                    this.add_to_commandlist(sprintf('#%dz=0\r'          , this.motorID_slayer));
                    if ~this.send_commandlist(this.failed_command_repititions)
                        this.mIsInitialized             =   false;
                        error('Motor_Slayer is not responding!')
                    end
                end
                this.mIsInitialized                     =   true;
            catch errmsg
                this.mIsInitialized                     =   false;
                ita_verbose_info(errmsg.message,0);
                error('i: Unable to initialize correctly');
            end
            
            % subfolder for data - speed reasons for lots of files
            if ~isdir(this.finalDataPath)
                mkdir(this.finalDataPath);
            end
            % Set some default values:
            this.sArgs_turntable    =   this.sArgs_default_turntable;
            this.sArgs_arm          =   this.sArgs_default_arm;
            this.sArgs_slayer       =   this.sArgs_default_slayer;
        end
        %% -----------------------------------------------------------------
        % Reference stuff:
        function reference(this)
            % Move to reference position
            if this.inuse.turntable
                this.referenceMove_turntable;
            end
            if this.inuse.arm
                this.referenceMove_arm;
            end
            if this.inuse.slayer
                this.referenceMove_slayer;
            end
            ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
            % Wait for the motor to stop:
            this.wait4everything;
            this.isReferenced       =   true;
            if this.inuse.slayer % Move Slayer to zero position!
                this.move_slayer(0);
            end
            % JCK: Leave arm at lowest position. Always same slope for measurments
            %             if this.inuse.arm % Move Arm to zero position!
            %                 this.move_arm(90);
            %             end
            ita_verbose_info('Reference done!',1);
        end
        
        function reference_turntable(this)
            if this.inuse.turntable
                % Move turntable to reference position
                this.referenceMove_turntable;
                ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
                % Wait for the motor to stop:
                this.wait4everything;
                this.isReferenced       =   true;
                ita_verbose_info('Turntable referenced...',2);
            end
        end
        
        function reference_arm(this)
            if this.inuse.arm
                % Move arm to reference position
                this.referenceMove_arm;
                ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
                % Wait for the motor to stop:
                this.wait4everything;
                this.isReferenced       =   true;
                % jck: Not good, always start measurement from here down here. this.move_arm(90);
                % todo: check this. the .move_arm seems to be ignored when
                % starting from the reference position (switch in hole)
                ita_verbose_info('Arm referenced...',2);
            end
        end
        
        function reference_slayer(this)
            if this.inuse.slayer
                % Move slayer to reference position
                this.referenceMove_slayer;
                ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
                % Wait for the motor to stop:
                this.wait4everything;
                this.isReferenced       =   true;
                this.move_slayer(0);
                ita_verbose_info('Slayer referenced...',2);
            end
        end
        %% -----------------------------------------------------------------
        % Move commands:
        function stop(this)
            % DO NOT ASK - JUST STOP ALL MOTORS!
            for i = 1:5 % repeat several times to ensure that every motor stops!
                fwrite(this.mSerialObj, sprintf('#%dS\r'        , this.motorID_turntable));
                pause(this.waitForSerialPort);
                fwrite(this.mSerialObj, sprintf('#%dS\r'        , this.motorID_arm));
                pause(this.waitForSerialPort);
                fwrite(this.mSerialObj, sprintf('#%dS\r'        , this.motorID_slayer));
                pause(this.waitForSerialPort);
            end
            while this.mSerialObj.BytesAvailable
                fgetl(this.mSerialObj);
            end
        end
        function start_move(this, varargin)
            % Send Start-command to motors
            this.started    =   struct('turntable', true, 'arm', true, 'slayer', true);
            this.started    =   ita_parse_arguments(this.started, varargin);
            % Start Motor:
            if this.started.turntable
                this.add_to_commandlist(sprintf('#%dA\r'        , this.motorID_turntable));
            end
            if this.started.arm
                this.add_to_commandlist(sprintf('#%dA\r'        , this.motorID_arm));
            end
            if this.started.slayer
                this.add_to_commandlist(sprintf('#%dA\r'        , this.motorID_slayer));
            end
            if ~this.send_commandlist(this.failed_command_repititions)
                ita_verbose_info('Something went wrong - not all commands were confirmed!', 0);
            else
                ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
            end
            % Check if we should wait until the new position is reached:
            if (this.wait)% && (~this.sArgs_turntable.continuous)
                this.wait4everything;
            end
        end
        function start_move_now(this)
            % Don't waist any time! JUST START NOW!!!
            fwrite(this.mSerialObj, sprintf('#%dA\r'            , this.motorID_turntable));
            pause(this.waitForSerialPort);
            fwrite(this.mSerialObj, sprintf('#%dA\r'            , this.motorID_arm));
            pause(this.waitForSerialPort);
            fwrite(this.mSerialObj, sprintf('#%dA\r'            , this.motorID_slayer));
            pause(this.waitForSerialPort);
            if (this.wait) && (~this.sArgs_turntable.continuous)
                this.wait4everything;
            end
        end
        
        function moveTo(this,position)
            % Move turntable, arm and slayer to absolute position. Takes
            % vector [turntable arm* slayer*]-angle in degree (*optional) or
            % itaCoordinates (first point = turntable/arm, second point* =
            % slayer, *optional)
            this.clear_receivedlist;
            % Error checks
            if ~isa(position,'itaCoordinates')
                if ~isvector(position)
                    error('Position should be itaCoordinates or vector ([turntable arm* slayer*]-angle, *optional)')
                else
                    if max(size(position)) == 3
                        pos             =   position;
                        position        =   itaCoordinates(2);
                        position.phi    =   [pos(1)/180*pi  0];
                        position.theta  =   [pos(2)/180*pi pos(3)/180*pi];
                    elseif max(size(position)) == 2
                        pos             =   position;
                        position        =   itaCoordinates(1);
                        position.phi    =   pos(1)/180*pi;
                        position.theta  =   pos(2)/180*pi;
                    elseif max(size(position)) == 1
                        pos             =   position;
                        position        =   itaCoordinates(1);
                        position.phi    =   pos(1)/180*pi;
                        position.theta  =   0;
                    else
                        error('Position should be itaCoordinates or vector ([tt arm slayer]-angle)')
                    end
                end
            end
            % Check if it is initialized:
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            % Check if it is referenced:
            if ~this.isReferenced
                % Otherwise warn the user that the reference is at power-up
                % position:
                ita_verbose_info('Be aware! No reference move done! Reference = Power-Up-Position!',2)
            end
            
            % Move turntable
            if this.inuse.turntable && (this.old_position.phi(1) ~= position.phi(1)) % if hell breaks loose, check here!
                if ~this.prepare_move_turntable(mod(position.phi(1)/2/pi*360+360, 720)-360, 'absolut', true, 'wait', true, 'speed', this.sArgs_turntable.speed)
                    ita_verbose_info('Something is wrong with the turntable!', 0)
                    return
                end
                this.started.turntable  =   true;
            else
                this.started.turntable  =   false;
            end
            % Move Arm:
            if this.inuse.arm && ...
                    ((this.old_position.theta(1) ~= position.theta(1)) || this.mLastMeasurement == 0) % or condition needed if measurement stopped and resumed, ask: jck, mpo 
                if ~this.prepare_move_arm(position.theta(1)/pi*180, 'wait', true)
                    ita_verbose_info('Something is wrong with the arm!', 0)
                    return
                end
                this.started.arm        =   true;
            else
                this.started.arm        =   false;
            end
            % Move Slayer:
            if this.inuse.slayer
                if position.nPoints == 2
                    if ~this.prepare_move_slayer(position.theta(2)/pi*180, 'wait', true)
                        ita_verbose_info('Something is wrong with the turntable!', 0)
                        return
                    end
                    this.started.slayer =   true;
                else
                    this.started.slayer =   false;
                end
            end
            this.wait                   =   true;
            this.start_move('turntable', this.started.turntable, 'arm', this.started.arm, 'slayer', this.started.slayer);
            this.old_position = position;
        end
        
        function move_turntable(this,angle,varargin)
            % angle:        turn counter-clockwise by angle degree (relative-mode)
            %                   or to specific position (absolut-mode)!
            % varargin:     is redirected to prepare_move_arm!
            
            % Move turntable
            this.clear_receivedlist;
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            if this.inuse.turntable
                % First prepare the move
                if this.prepare_move_turntable(angle, varargin{:})
                    % Now start the move
                    this.start_move('arm', false, 'slayer', false);
                end
            else
                ita_verbose_info('Turntable not connected!',0)
            end
        end
        function move_arm(this, angle, varargin)
            % angle:        move to this absolut angle!
            % varargin:     is redirected to prepare_move_arm!
            
            % Move arm
            this.clear_receivedlist;
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            if this.inuse.arm
                % First prepare the move
                if this.prepare_move_arm(angle, varargin{:});
                    % Now start the move
                    this.start_move('turntable', false, 'slayer', false);
                end
            else
                ita_verbose_info('Arm not connected!',0)
            end
        end
        function move_slayer(this, angle, varargin)
            % angle:        move to this absolut angle!
            % varargin:     is redirected to prepare_move_arm!
            
            % Move slayer
            this.clear_receivedlist;
            
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            if this.inuse.slayer
                % First prepare the move
                if this.prepare_move_slayer(angle, varargin{:});
                    % Now start the move
                    this.start_move('turntable', false, 'arm', false);
                end
            else
                ita_verbose_info('Slayer not connected!',0)
            end
        end
        
        %% -----------------------------------------------------------------
        % GUI:
        function gui(this) %#ok<*MANU>
            %call GUI
            errordlg('There is no GUI - sorry! But you can build one if you like!')
        end
        
    end %% methods
    % *********************************************************************
    % *********************************************************************
    methods(Hidden = true)
        % Sort measurement positions and delete points outside of the allowed range:
        function this = sort_measurement_positions(this,varargin)
            ita_verbose_info('I will sort your measurement positions for better performance.', 1);
            % Delete every point below ARM_limit:
            this.measurementPositions = this.measurementPositions.n(this.measurementPositions.theta <= this.ARM_limit(2)/180*pi);
            this.measurementPositions = this.measurementPositions.n(this.measurementPositions.theta >= this.ARM_limit(1)/180*pi);
            % Sort:
            this.measurementPositions = this.do_coordinate_sorting(this.measurementPositions); 
        end
        % -----------------------------------------------------------------
        % Prepare commands:
        function ret = prepare_move_turntable(this, angle, varargin)
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
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            % Use always default values and change them if user is asking for it:
            this.sArgs_turntable = this.sArgs_default_turntable;
            
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
            
            this.sArgs_turntable = ita_parse_arguments(this.sArgs_turntable,varargin);
            % Assign wait to global wait:
            this.wait = this.sArgs_turntable.wait;
            
            if (this.sArgs_turntable.speed == 0) && ((angle == 0) && (~this.sArgs_turntable.continuous) && (~this.sArgs_turntable.absolut))
                % This means: STOP!
                fwrite(this.mSerialObj, sprintf('#%dS\r'        , this.motorID_turntable));
                ret             =   false;
                pause(0.1);
                fgetl(this.mSerialObj);
                return
            end
            if (this.sArgs_turntable.limit == true)
                % Check if the position is too far away...
                if this.sArgs_turntable.continuous == true
                    % It will lead to problems if limit is on AND continuous
                    % is true...
                    error('Please turn off limit if you want to turn continuous! Please make also sure that no cable or other stuff can coil!');
                elseif this.sArgs_turntable.absolut == true
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
                    fwrite(this.mSerialObj, sprintf('#%dC\r'      , this.motorID_turntable));
                    act_pos       =   fgetl(this.mSerialObj);
                    act_pos       =   str2double(act_pos(3:end));
                    % Now multiply with 0.9 and divide by gear_ratio to get
                    % the position angle of the turntable:
                    act_pos       =   act_pos*0.9/this.sArgs_turntable.gear_ratio;
                    % Check if new position would be in the allowed range:
                    if (act_pos+angle) > 361 || (act_pos+angle) < -181
                        % No, it's not....
                        error('Limit is on! Only positions between -180 and 360 degree are allowed!')
                    end
                end
            end
            % Set microstep-divider:
            if strcmpi(this.sArgs_turntable.VST, 'adaptiv')
                this.add_to_commandlist(sprintf('#%dg=255\r'     , this.motorID_turntable));
            else
                this.add_to_commandlist(sprintf(['#%dg=' this.sArgs_turntable.VST '\r']  , this.motorID_turntable));
            end
            % Set maximum current to 100%:
            this.add_to_commandlist(sprintf('#%di=%.0f\r'       , this.motorID_turntable, this.sArgs_turntable.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            this.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r', this.motorID_turntable, this.sArgs_turntable.ramp_mode));
            % Set maximum acceleration jerk:
            this.add_to_commandlist(sprintf('#%d:b=100\r'       , this.motorID_turntable));
            % Use acceleration jerk as braking jerk:
            this.add_to_commandlist(sprintf('#%d:B=0\r'         , this.motorID_turntable));
            % Closed_loop?
            %this.sArgs_turntable.closed_loop = true; % DEBUG!
            if this.sArgs_turntable.closed_loop == true
                % JEAR! Without this the new motor would be nonsense!
                % Activate CL during movement:
                this.add_to_commandlist(sprintf('#%d:CL_enable=2\r' , this.motorID_turntable));
                % Nice values for the speed closed loop control:
                pos     =   [0.5 1 2 3 4 8 12 16 25 32 40 50];
                vecP    =   [0.5 1.5 2.5 3.5 4.5 4.5 5.5 2.5 2.0 1.3 1.3 1.3];
                vecI    =   [0.05 0.1 0.2 0.3 0.4 0.8 1.2 1.6 2.0 2.5 2.5 2.5];
                vecD    =   [9 6 4 3 2 1 1 3 6 10 10 10];
                pP      =   polyfit(pos,vecP,5);
                pI      =   polyfit(pos,vecI,5);
                pD      =   polyfit(pos,vecD,5);
                P       =   polyval(pP,this.sArgs_turntable.speed);
                I       =   polyval(pI,this.sArgs_turntable.speed);
                D       =   polyval(pD,this.sArgs_turntable.speed);
                P_nenner    =   5;
                I_nenner    =   5;
                D_nenner    =   5;
                P_zaehler   =   round(P*2^P_nenner);
                I_zaehler   =   round(I*2^I_nenner);
                D_zaehler   =   round(D*2^D_nenner);
                this.add_to_commandlist(sprintf('#%d:CL_KP_v_Z=%d\r'    , this.motorID_turntable, P_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KP_v_N=%d\r'    , this.motorID_turntable, P_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KI_v_Z=%d\r'    , this.motorID_turntable, I_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KI_v_N=%d\r'    , this.motorID_turntable, I_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KD_v_Z=%d\r'    , this.motorID_turntable, D_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KD_v_N=%d\r'    , this.motorID_turntable, D_nenner));
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
                this.add_to_commandlist(sprintf('#%d:CL_KP_s_Z=%d\r'    , this.motorID_turntable, P_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KP_s_N=%d\r'    , this.motorID_turntable, P_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KI_s_Z=%d\r'    , this.motorID_turntable, I_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KI_s_N=%d\r'    , this.motorID_turntable, I_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KD_s_Z=%d\r'    , this.motorID_turntable, D_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KD_s_N=%d\r'    , this.motorID_turntable, D_nenner));
                % Kask V-Regler: P = 1.2, I = 0.85, D = 0.7
                % Kask- P-Regler: P = 400 (default), I = 2 (default), D = 700 (default)
                % TODO: Send values to the motor... or we just skip the
                % kaskaded closed loop
            else
                % Use motor as classic step motor without closed loop:
                this.add_to_commandlist(sprintf('#%d:CL_enable=0\r'     , this.motorID_turntable));
            end
            % Correction of the sinus-commutierung: (Should be on!)
            this.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r', this.motorID_turntable));
            
            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the turntable and not for the motor:
            stepspersecond  =   (this.sArgs_turntable.speed/0.9*this.sArgs_turntable.gear_ratio);
            this.add_to_commandlist(sprintf('#%do=%.2f\r'               , this.motorID_turntable, stepspersecond));
            % Set mode:
            if this.sArgs_turntable.continuous == true
                % Continuous mode:
                this.add_to_commandlist(sprintf('#%dp=5\r'              , this.motorID_turntable));
                if (angle > 0)
                    % Turn right: (negative)
                    this.add_to_commandlist(sprintf('#%dd=1\r'          , this.motorID_turntable));
                else
                    % Turn left: (positive)
                    this.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID_turntable));
                end % Send a command with zero speed to stop the motor!
            else
                % Calculate the number of steps:
                % Divide by 0.9 because each (half)-step is equal to 0.9 degree
                % and multiply by the gear_ratio because the given angle value
                % is for the turntable and not for the motor:
                steps       =   (angle/0.9*this.sArgs_turntable.gear_ratio);
                % Check if absolut or relative position mode:
                if this.sArgs_turntable.absolut == true
                    % Absolut position mode:
                    this.add_to_commandlist(sprintf('#%dp=2\r'          , this.motorID_turntable));
                    % Set position (positive/negaive relative to the
                    % reference:
                    this.add_to_commandlist(sprintf('#%ds=%.2f\r'       , this.motorID_turntable, steps));
                    % INFO: -100000000 <= steps <= +100000000!
                else
                    % Relative position mode:
                    this.add_to_commandlist(sprintf('#%dp=1\r'          , this.motorID_turntable));
                    this.add_to_commandlist(sprintf('#%ds=%.2f\r'       , this.motorID_turntable, abs(steps)));
                    % INFO:     0 < steps <= +100000000! Direction is set seperatly!
                    % Check the direction:
                    if (angle > 0) % Turn right: (negative)
                        this.add_to_commandlist(sprintf('#%dd=1\r'      , this.motorID_turntable));
                    else % Turn left: (positive)
                        this.add_to_commandlist(sprintf('#%dd=0\r'      , this.motorID_turntable));
                    end
                end
            end
            % Set acceleration ramp: (This formula is given by the
            % programming handbook of Nanotec! Don't ask why it is so
            % complicated!!!!)
            value       =   round((3000/(this.sArgs_turntable.acceleration_ramp + 11.7))^2);
            this.add_to_commandlist(sprintf('#%db=%.0f\r'           , this.motorID_turntable, value));
            % Brake ramp:
            this.add_to_commandlist(sprintf('#%dB=0\r'              , this.motorID_turntable));
            % Zero menas equal to acceleration ramp!
            
            % ------------------------------------------------------------
            % All commands added to commandlist - now send it:
            if this.send_commandlist(this.failed_command_repititions)
                ita_verbose_info('Turntable is prepared...',2);
                ret     =   true;
            else
                ita_verbose_info('Something is wrong! Turntable is NOT prepared...',0);
                ret     =   false;
            end
        end
        
        function ret = prepare_move_arm(this, angle, varargin)
            %   This function prepares the moves of the arm
            
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            if ~this.isReferenced
                ita_verbose_info('Arm: You are not allowed to move the arm until you made a reference move!', 0)
                ret         =   false;
                this.wait   =   false;
                return;
            end
            if (angle < this.ARM_limit(1)) || (angle > this.ARM_limit(2))
                ita_verbose_info(['Arm: Only values between ' num2str(this.ARM_limit(1)) ' and ' num2str(this.ARM_limit(2)) ' are allowed!'], 0)
                ret         =   false;
                this.wait   =   false;
                return;
            end
            
            angle = angle - 119.01 + this.armCorrectionAngle; % Larger substractive value: Higher position. Checkt at 90�.
            
            
            
            this.sArgs_arm  =   this.sArgs_default_arm;
            % -------------------------------------------------------------
            % Meaning:
            %
            % Wait              =   Stop matlab until motor reaches final position!
            % Speed             =   Grad/sec of the arm
            % VST               =   Microstep divider. Values: 1, 2, 4, 5, 8, 10, 16, 32,
            %                       64. 254="Vorschubkonstantenmodus", 255=Adaptive Stepdivider
            % Closed_loop       =   Turn on the closed loop regulation
            % Acceleration_ramp =   Value in Hz/ms
            % Gear_ratio        =   Gear Ratio
            % Current           =   Maximum current in percent
            % Ramp_mode         =   0=trapez, 1=sinus-ramp, 2=jerkfree-ramp
            % -------------------------------------------------------------
            this.sArgs_arm  =   ita_parse_arguments(this.sArgs_arm,varargin);
            this.wait       =   this.sArgs_arm.wait;
            if (this.sArgs_arm.speed == 0)
                % This means: STOP!
                fwrite(this.mSerialObj, sprintf('#%dS\r'        , this.motorID_arm));
                ret         =   false;
                pause(0.1);
                fgetl(this.mSerialObj);
                return
            end
            if (this.sArgs_arm.speed > 3) || (this.sArgs_arm.speed < 0)
                ita_verbose_info('Arm: Speed must be between >0 and 3!', 0)
                ret = false;
                return
            end
            % Set microstep-divider:
            if strcmpi(this.sArgs_arm.VST, 'adaptiv')
                this.add_to_commandlist(sprintf('#%dg=255\r'     , this.motorID_arm));
            else
                this.add_to_commandlist(sprintf(['#%dg=' this.sArgs_arm.VST '\r']    , this.motorID_arm));
            end
            % Set maximum current to 100%:
            this.add_to_commandlist(sprintf('#%di%.0f\r'       , this.motorID_arm, this.sArgs_arm.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            this.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r', this.motorID_arm, this.sArgs_arm.ramp_mode)); % if hell breaks loose, check here!
            % Set maximum acceleration jerk:
            this.add_to_commandlist(sprintf('#%d:b=100\r'       , this.motorID_arm));
            % Use acceleration jerk as braking jerk:
            this.add_to_commandlist(sprintf('#%d:B=0\r'         , this.motorID_arm));  % if hell breaks loose, check here!
            % Closed_loop?
            if this.sArgs_arm.closed_loop == true
                ita_verbose_info('Closed-loop-parameter not adjusted for the arm (yet)! Using turntable parameter. May not work as you wish..!', 0)
                % Activate CL during movement:
                this.add_to_commandlist(sprintf('#%d:CL_enable=2\r' , this.motorID_arm));
                % Some nice values measured for the turntable:
                pos         =   [0.5 1 2 3 4 8 12 16 25 32 40 50];
                vecP        =   [0.5 1.5 2.5 3.5 4.5 4.5 5.5 2.5 2.0 1.3 1.3 1.3];
                vecI        =   [0.05 0.1 0.2 0.3 0.4 0.8 1.2 1.6 2.0 2.5 2.5 2.5];
                vecD        =   [9 6 4 3 2 1 1 3 6 10 10 10];
                pP          =   polyfit(pos,vecP,5);
                pI          =   polyfit(pos,vecI,5);
                pD          =   polyfit(pos,vecD,5);
                P           =   polyval(pP,this.sArgs_arm.speed);
                I           =   polyval(pI,this.sArgs_arm.speed);
                D           =   polyval(pD,this.sArgs_arm.speed);
                P_nenner    =   5;
                I_nenner    =   5;
                D_nenner    =   5;
                P_zaehler   =   round(P*2^P_nenner);
                I_zaehler   =   round(I*2^I_nenner);
                D_zaehler   =   round(D*2^D_nenner);
                this.add_to_commandlist(sprintf('#%d:CL_KP_v_Z=%d\r'    , this.motorID_arm, P_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KP_v_N=%d\r'    , this.motorID_arm, P_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KI_v_Z=%d\r'    , this.motorID_arm, I_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KI_v_N=%d\r'    , this.motorID_arm, I_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KD_v_Z=%d\r'    , this.motorID_arm, D_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KD_v_N=%d\r'    , this.motorID_arm, D_nenner));
                % Pos-Kreis:
                % For 10 deg/s
                %P = 100;% (400 = default)
                %I = 1.5;% (2 = default)
                %D = 300;% (700 = default)
                % For 3 deg/s
                P           =   200;% (400 = default)
                I           =   1.0;% (2 = default)
                D           =   300;% (700 = default)
                P_nenner    =   3;
                I_nenner    =   5;
                D_nenner    =   3;
                P_zaehler   =   round(P*2^P_nenner);
                I_zaehler   =   round(I*2^I_nenner);
                D_zaehler   =   round(D*2^D_nenner);
                this.add_to_commandlist(sprintf('#%d:CL_KP_s_Z=%d\r'    , this.motorID_arm, P_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KP_s_N=%d\r'    , this.motorID_arm, P_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KI_s_Z=%d\r'    , this.motorID_arm, I_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KI_s_N=%d\r'    , this.motorID_arm, I_nenner));
                this.add_to_commandlist(sprintf('#%d:CL_KD_s_Z=%d\r'    , this.motorID_arm, D_zaehler));
                this.add_to_commandlist(sprintf('#%d:CL_KD_s_N=%d\r'    , this.motorID_arm, D_nenner));
            else
                % Use motor as classic step motor:
                this.add_to_commandlist(sprintf('#%d:CL_enable=0\r'     , this.motorID_arm));
            end
            
            % Correction of the sinus-commutierung: (Should be on!)
            this.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r', this.motorID_arm));
            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the arm and not for the motor:
            stepspersecond  = (this.sArgs_arm.speed/0.9*this.sArgs_arm.gear_ratio);
            this.add_to_commandlist(sprintf('#%do%.2f\r'               , this.motorID_arm, stepspersecond));
            % Calculate the number of steps:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given angle value
            % is for the arm and not for the motor:
            steps           = (angle/0.9*this.sArgs_arm.gear_ratio);
            
            % ONLY absolut position mode allowed:
            this.add_to_commandlist(sprintf('#%dp2\r'              , this.motorID_arm));
            % Set position (positive/negaive relative to the reference:
            this.add_to_commandlist(sprintf('#%ds%.2f\r'           , this.motorID_arm, steps));
            % INFO: -100000000 <= steps <= +100000000!
            
            % Set acceleration ramp:
            % This formula is given by the programming handbook of Nanotec:
            value           =   round((3000/(this.sArgs_arm.acceleration_ramp + 11.7))^2);
            this.add_to_commandlist(sprintf('#%db%.0f\r'           , this.motorID_arm, value));
            % Brake ramp:
            this.add_to_commandlist(sprintf('#%dB0\r'              , this.motorID_arm));
            % Zero means equal to acceleration ramp!
            
            if this.send_commandlist(this.failed_command_repititions)
                ita_verbose_info('Arm is prepared...',2);
                ret = true;
            else
                ita_verbose_info('Something is wrong! Arm is NOT prepared...',0);
                ret = false;
            end
        end
        
        function ret = prepare_move_slayer(this, angle, varargin)
            %   This function prepares the moves of the slayer
            
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize
            end
            if ~this.isReferenced
                ita_verbose_info('Slayer: You are not allowed to move the slayer until you made a reference move!', 0)
                ret         =   false;
                this.wait   =   false;
                return;
            end
            if (angle < this.SLAYER_limit(1)) || (angle >  this.SLAYER_limit(2))
                ita_verbose_info(['Slayer: Only values between ' num2str(this.SLAYER_limit(1)) ' and ' num2str(this.SLAYER_limit(2)) ' are allowed!'], 0)
                ret         =   false;
                this.wait   =   false;
                return;
            end
            angle           =   angle + 84.34; % Reference at -84.34 degree!
            % Use default values:
            this.sArgs_slayer   =   this.sArgs_default_slayer;
            
            % -------------------------------------------------------------
            % Meaning:
            %
            % Wait              =   Stop matlab until motor reaches final position!
            % Speed             =   Grad/sec der Motorachse!
            % VST               =   Microstep divider. Values: 1, 2, 4, 5, 8, 10, 16, 32,
            %                       64. 254="Vorschubkonstantenmodus", 255=Adaptiv Stepdivider
            % Acceleration_ramp =   Value in Hz/ms
            % Gear_ratio        =   Gear ratio between motor and slayer-axis
            % Current           =   Maximum current in percent
            % Ramp_mode         =   0=trapez, 1=sinus-ramp, 2=jerkfree-ramp
            % -------------------------------------------------------------
            this.sArgs_slayer   =   ita_parse_arguments(this.sArgs_slayer,varargin);
            this.wait           =   this.sArgs_slayer.wait;
            if (this.sArgs_slayer.speed == 0)
                % This means: STOP!
                fwrite(this.mSerialObj, sprintf('#%dS\r', this.sArgs.motorID_slayer));
                ret             =   false;
                pause(0.1);
                fgetl(this.mSerialObj);
                return
            end
            if (this.sArgs_slayer.speed > 20) || (this.sArgs_slayer.speed < 0)
                ita_verbose_info('Slayer: Speed must be between >0 and 20!', 0)
                ret             =   false;
                return
            end
            % Set microstep-divider:
            if strcmpi(this.sArgs_slayer.VST, 'adaptiv')
                this.add_to_commandlist(sprintf('#%dg=255\r'         , this.motorID_slayer));
            else
                this.add_to_commandlist(sprintf(['#%dg=' this.sArgs_slayer.VST '\r'] , this.motorID_slayer));
            end
            % Set maximum current:
            this.add_to_commandlist(sprintf('#%di=%.0f\r'           , this.motorID_slayer, this.sArgs_slayer.current));
            % Choose ramp mode: (0=trapez, 1=sinus-ramp, 2=jerkfree-ramp):
            this.add_to_commandlist(sprintf('#%d:ramp_mode=%d\r'    , this.motorID_slayer, this.sArgs_slayer.ramp_mode));
            % Set maximum acceleration jerk:
            this.add_to_commandlist(sprintf('#%d:b=100\r'           , this.motorID_slayer));
            % Use acceleration jerk as braking jerk:
            this.add_to_commandlist(sprintf('#%d:B=0\r'             , this.motorID_slayer));
            % Use motor as classic step motor: (No closed loop supported!)
            this.add_to_commandlist(sprintf('#%d:CL_enable=0\r'     , this.motorID_slayer));
            % Correction of the sinus-commutierung: (Should be on!)
            this.add_to_commandlist(sprintf('#%d:cal_elangle_enable=1\r'    , this.motorID_slayer));
            % Set the speed:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given speed value
            % is for the arm and not for the motor:
            stepspersecond      =   (this.sArgs_slayer.speed/0.9*this.sArgs_slayer.gear_ratio);
            this.add_to_commandlist(sprintf('#%do=%.2f\r'           , this.motorID_slayer, stepspersecond));
            % Calculate the number of steps:
            % Divide by 0.9 because each (half)-step is equal to 0.9 degree
            % and multiply by the gear_ratio because the given angle value
            % is for the arm and not for the motor:
            steps               =   (angle/0.9*this.sArgs_slayer.gear_ratio);
            % Only absolut position mode!:
            this.add_to_commandlist(sprintf('#%dp=2\r'              , this.motorID_slayer));
            % Set position (positive/negaive relative to the
            % reference:
            this.add_to_commandlist(sprintf('#%ds=%.2f\r'           , this.motorID_slayer, steps));
            % Set acceleration ramp:
            % This formula is given by the programming handbook of Nanotec!
            value               =   round((3000/(this.sArgs_slayer.acceleration_ramp + 11.7))^2);
            this.add_to_commandlist(sprintf('#%db=%.0f\r'           , this.motorID_slayer, value));
            % Brake ramp:
            this.add_to_commandlist(sprintf('#%dB=0\r'              , this.motorID_slayer));
            % Zero menas equal to acceleration ramp!
            
            if this.send_commandlist(this.failed_command_repititions)
                ita_verbose_info('Slayer is prepared...',2);
                ret             =   true;
            else
                ita_verbose_info('Something is wrong! Slayer is NOT prepared...',0);
                ret             =   false;
            end
        end
        % -----------------------------------------------------------------
        function success = send_commandlist(this, repititions)
            % Send all commands in the commandlist. Check response. Repeat
            % command if no response. Argument is the number of
            % max repititions.
            this.clear_receivedlist;
            %
            ita_verbose_info(['Sending ' num2str(numel(this.commandlist)) ' commands...'], 2);
            % Send all commands:
            for i = 1:numel(this.commandlist)
                fwrite(this.mSerialObj, this.commandlist{i});
                pause(this.waitForSerialPort);
            end
            
            cnt                 =   round(this.timeout_response / this.waitForSerialPort);
            while (cnt > 0) && ~isempty(this.commandlist)
                if this.mSerialObj.BytesAvailable
                    resp        =   fgetl(this.mSerialObj);
                    
                    
                    
                    found       =   strfind(this.commandlist, resp(1:end)); % search command...
                    founditem   =   false;
                    for i = 1:numel(found)
                        if ~isempty(found{i})
                            this.commandlist(i)     =   [];
                            founditem               =   true;
                            
                            if ~isempty(strfind(resp, '='))
                                % Set some parameter - now store it local and avoid sending it again!
                                parametername = genvarname(regexprep(['Motor_' resp(1) '_Parameter_' resp(2:strfind(resp, '=')-1)], ':', ''));
                                value = resp(strfind(resp, '=')+1:end);
                                this.actual_status.(parametername) = value;
                            end
                            
                            break;
                        end
                    end
                    if founditem == false
                        this.receivedlist{end+1}    =   resp;
                    end
                else
                    pause(this.waitForSerialPort);
                    cnt         =   cnt - 1;
                end
            end
            % Check if all commands are confirmed:
            if isempty(this.commandlist)
                success         =   true;
            else
                % Not all commands are confirmed within given time - check
                % if we are allowed to send them again!
                if repititions > 0
                    ita_verbose_info([num2str(numel(this.commandlist)) ' commands left without a response! I will send them again!'], 0);
                    success     =   this.send_commandlist(repititions - 1);
                else
                    ita_verbose_info('Some commands left without a response!', 0);
                    for i = 1:numel(this.commandlist)
                        ita_verbose_info(['itaEimar: ' this.commandlist{i}(1:end-1)], 0);
                    end
                    success     =   false;
                end
            end
            % *********************************************************************
            if ~isempty(this.receivedlist)
                % Show user what is received without expected to be received:
                ita_verbose_info([sprintf('I could not assign these motor responses to a request:\r') this.receivedlist{:}], 0);
            end
        end
        
        function success = add_to_commandlist(this, string_to_send)
            % Add command to commandlist
            %this.commandlist{end+1}             =   string_to_send;
            %success             =   1;
            if ~isempty(strfind(string_to_send, '='))
                parametername = genvarname(regexprep(['Motor_' string_to_send(2) '_Parameter_' string_to_send(3:strfind(string_to_send, '=')-1)], ':', ''));
                value = string_to_send(strfind(string_to_send, '=')+1:end-1);
            else
                % Could not detect parametername:
                this.commandlist{end+1}             =   string_to_send;
                success             =   1;
                return;
            end
            
            if isfield(this.actual_status, parametername) && (strcmpi(this.actual_status.(parametername), value))
                % Parameter already set!
                success = -1;
            else
                % Need to send parameter!
                this.commandlist{end+1}             =   string_to_send;
                success             =   1;
            end
        end
        function clear_commandlist(this)
            % Delete commandlist
            this.commandlist    =   [];
        end
        function clear_receivedlist(this)
            % Clear list of motor-responses which could not be assigned to
            % a request
            this.receivedlist   =   [];
        end
        % -----------------------------------------------------------------
        function res = finalDataPath(this)
            % Final data path string
            res                 =   [this.dataPath filesep 'data'];
        end
        %-----------------------------------------------------------------
        % Reference moves:
        function this = referenceMove_turntable(this)
            % Prepare reference move (turntable)
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize;
            end
            
            % Turn + some degrees in case we are already at the end of the
            % reference switch or already passed it:
            this.move_turntable(+10);
            
            % Call Reference-Mode:
            this.add_to_commandlist(sprintf('#%dp=4\r'          , this.motorID_turntable));
            % Set direction:
            this.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID_turntable));
            % Calculate and set lower speed:
            stepspersecond      =   (this.sArgs_default_turntable.speed/0.9*this.sArgs_turntable.gear_ratio);
            this.add_to_commandlist(sprintf('#%du=%.2f\r'       , this.motorID_turntable, stepspersecond));
            % Calculate and set upper speed:
            stepspersecond      =   (this.sArgs_default_turntable.speed/0.9*this.sArgs_turntable.gear_ratio);
            this.add_to_commandlist(sprintf('#%do=%.2f\r'       , this.motorID_turntable, stepspersecond));
            % Start reference move:
            this.add_to_commandlist(sprintf('#%dA\r'            , this.motorID_turntable));
            if this.send_commandlist(this.failed_command_repititions)
                this.started.turntable  =   true;
                ita_verbose_info('Turntable started reference move...',2);
            else
                this.started.turntable  =   false;
                ita_verbose_info('Something is wrong with the turntable - unable to start the reference move!...',0);
            end
        end
        
        function this = referenceMove_arm(this)
            % Prepare reference move (arm)
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize;
            end
            % Call Current:
            this.add_to_commandlist(sprintf('#%di90\r'          , this.motorID_arm));
            % External Reference Run
            this.add_to_commandlist(sprintf('#%dp4\r'          , this.motorID_arm));
            % Set direction to right: (IMPORTANT!)
            this.add_to_commandlist(sprintf('#%dd1\r'          , this.motorID_arm));
            % Calculate and set upper speed:
            stepspersecond    	=   (this.sArgs_default_arm.speed/5/0.9*this.sArgs_arm.gear_ratio);
            this.add_to_commandlist(sprintf('#%du%.2f\r'       , this.motorID_arm, stepspersecond));
            % Calculate and set lower speed:
            stepspersecond      =   (this.sArgs_default_arm.speed/0.9*this.sArgs_arm.gear_ratio);
            this.add_to_commandlist(sprintf('#%do%.2f\r'       , this.motorID_arm, stepspersecond));
            % Start reference move:
            this.add_to_commandlist(sprintf('#%dA\r'            , this.motorID_arm));
            if this.send_commandlist(this.failed_command_repititions)
                this.started.arm = true;
                ita_verbose_info('Arm started reference move...',2);
            else
                this.started.arm = false;
                ita_verbose_info('Something is wrong with the arm - unable to start the reference move!...',0);
            end
        end
        
        function this = referenceMove_slayer(this)
            % Prepare reference move (slayer)
            if ~this.isInitialized
                ita_verbose_info('Not initialized - I will do that for you...!',0);
                this.initialize;
            end
            
            % Call Reference-Mode:
            this.add_to_commandlist(sprintf('#%dp=4\r', this.motorID_slayer));
            %**********Important!!*********************
            % Set direction:
            this.add_to_commandlist(sprintf('#%dd=0\r'          , this.motorID_slayer));
            %******************************************
            % Calculate and set upper speed:
            stepspersecond      =   (this.sArgs_default_slayer.speed/8/0.9*this.sArgs_slayer.gear_ratio);
            this.add_to_commandlist(sprintf('#%du=%.2f\r'       , this.motorID_slayer, stepspersecond));
            % Calculate and set lower speed:
            stepspersecond      =   (this.sArgs_default_slayer.speed/2/0.9*this.sArgs_slayer.gear_ratio);
            this.add_to_commandlist(sprintf('#%do=%.2f\r'       , this.motorID_slayer, stepspersecond));
            % Start reference move:
            this.add_to_commandlist(sprintf('#%dA\r'            , this.motorID_slayer));
            if this.send_commandlist(this.failed_command_repititions)
                this.started.slayer     =   true;
                ita_verbose_info('Slayer started reference move...',2);
            else
                this.started.slayer     =   false;
                ita_verbose_info('Something is wrong with the slayer - unable to start the reference move!...',0);
            end
        end
        %-----------------------------------------------------------------
        % Waiting routine:
        function wait4everything(this, varargin)
            %  This function checks if the turntable has reached the end
            %  position and only returns when the end position is reached.
            this.started        =   ita_parse_arguments(this.started, varargin);
            pause(0.5);
            if this.started.turntable
                ita_verbose_info('Waiting for Turntable to reach position...',2);
                turntable_stopped       =   false;
            else
                turntable_stopped       =   true;
            end
            if this.started.arm
                ita_verbose_info('Waiting for Arm to reach position...',2);
                arm_stopped             =   false;
            else
                arm_stopped             =   true;
            end
            if this.started.slayer
                ita_verbose_info('Waiting for Slayer to reach position...',2);
                slayer_stopped          =   false;
            else
                slayer_stopped          =   true;
            end
            
            % Initialize some counter:
            idx     =   0;
            idxMAX  =   round(this.timeout_move / this.waitForSerialPort); %Stop after 300 sec!
            time    =   (clock+[0 0 0 0 0 this.timeout_move]);
            temp    =   floor(time./ [inf inf inf 24*60*60 60*60 60]);
            time    =   time + [temp(2:6) 0] - temp(1:6).*[0 0 0 24 60 60];
            temp    =   floor(time./ [inf inf inf 24*60*60 60*60 60]);
            time    =   time + [temp(2:6) 0] - temp(1:6).*[0 0 0 24 60 60];
            ita_verbose_info(sprintf('Timeout (%d seconds) will occur at %d:%d:%d if >=1 motor has not reached it''s target position until then!', ...
                this.timeout_move, time(4), time(5), round(time(6))), 1)
            errors  =   false;
            % Wait till all motors stopped:
            while ~turntable_stopped || ~arm_stopped || ~slayer_stopped
                % If motor responses are available:
                if this.mSerialObj.BytesAvailable || ~isempty(this.receivedlist)
                    if isempty(this.receivedlist)
                        resp    =   fgetl(this.mSerialObj);
                    else
                        % If there are pending answers - check them:
                        resp    =   this.receivedlist{1};
                        this.receivedlist(1)    =   [];
                    end
                    if size(resp, 2) > 5
                        if strcmpi(resp(4), 'j') || strcmpi(resp(4), '$')
                            byte = str2double(resp(5:end));
                            if isnumeric(byte) && ~isinf(byte) && ~isnan(byte)
                                byte = dec2bin(byte, 8);
                                if strcmpi(resp(3), num2str(this.motorID_turntable)) && strcmp(byte(end), '1') && ~strcmp(byte(end-2), '1') && (turntable_stopped == false)
                                    turntable_stopped   =   true;
                                    ita_verbose_info('Turntable reached position...',2);
                                elseif strcmpi(resp(3), num2str(this.motorID_turntable)) && strcmp(byte(end-2), '1')
                                    turntable_stopped   =   true;
                                    ita_verbose_info('Turntable position error...',0);
                                    errors              =   true;
                                    this.add_to_commandlist(sprintf('#%dD\r'    , this.motorID_turntable));
                                elseif strcmpi(resp(3), num2str(this.motorID_arm)) && strcmp(byte(end), '1') && ~strcmp(byte(end-2), '1') && (arm_stopped == false)
                                    arm_stopped = true;
                                    ita_verbose_info('Arm reached position...',2);
                                elseif strcmpi(resp(3), num2str(this.motorID_arm)) && strcmp(byte(end-2), '1')
                                    arm_stopped         =   true;
                                    ita_verbose_info('Arm position error...',0);
                                    errors              =   true;
                                    this.add_to_commandlist(sprintf('#%dD\r'    , this.motorID_arm));
                                elseif strcmpi(resp(3), num2str(this.motorID_slayer)) && strcmp(byte(end), '1') && ~strcmp(byte(end-2), '1') && (slayer_stopped == false)
                                    slayer_stopped      =   true;
                                    ita_verbose_info('Slayer reached position...',2);
                                elseif strcmpi(resp(3), num2str(this.motorID_slayer)) && strcmp(byte(end-2), '1')
                                    slayer_stopped      =   true;
                                    ita_verbose_info('Slayer position error...',0);
                                    errors              =   true;
                                    this.add_to_commandlist(sprintf('#%dD\r'    , this.motorID_slayer));
                                end
                            end
                        end
                    end
                end
                idx             =   idx + 1;
                if idx > idxMAX
                    error('No response within %d seconds.... something is wrong!', this.timeout_move)
                end
                % Send a status request every few seconds... (To check for position errors!)
                if mod(idx, idxMAX/50) == 3; %idxMAX/50-8
                    ita_verbose_info('Continuouly checking for position errors every few seconds...', 2);
                    if this.started.turntable
                        fwrite(this.mSerialObj, sprintf('#%d$\r'        , this.motorID_turntable));
                        pause(0.05) % Do a small pause to avoid conflicts!
                    end
                    if this.started.arm
                        fwrite(this.mSerialObj, sprintf('#%d$\r'        , this.motorID_arm));
                        pause(0.05)
                    end
                    if this.started.slayer
                        fwrite(this.mSerialObj, sprintf('#%d$\r'        , this.motorID_slayer));
                        pause(0.05)
                    end
                end
                pause(this.waitForSerialPort);
            end
            % Check if any errors occured:
            if errors == false
                ita_verbose_info('Position reached',1);
            else
                ita_verbose_info('Position NOT reached! - Check for errors!', 0);
                this.send_commandlist(this.failed_command_repititions); % mpo: bugfix: send_commandlist needs argument
                this.isReferenced = false;
            end
            this.clear_receivedlist;
            this.started        =   struct('turntable', false, 'arm', false, 'slayer', false);
        end
        
        function run(this)
            if this.doSorting
                this.sort_measurement_positions();
            end
            run@itaMeasurementTasksScan(this);
        end
        
    end
    methods(Static)
        function s = do_coordinate_sorting(s)
            % phi should be between -pi..pi
            %             s.phi = mod(s.phi + pi, 2*pi) - pi;
            s.phi(s.phi > pi) = s.phi(s.phi > pi) - 2*pi;
            
            % sort the phi angles in both directions
            [~, index_phi_ascend] = sort(round_tol(s.phi), 'ascend');
            [~, index_phi_descend] = sort(round_tol(s.phi), 'descend');
            % sort the theta angles
            [~, index_theta_phi_ascend] = sort(s.theta(index_phi_ascend), 'descend');
            [~, index_theta_phi_descend] = sort(s.theta(index_phi_descend), 'descend');
            
            % get a list of unique elevation angles
            unique_theta = unique(round_tol(s.theta));
            
            % this is the complete coordinates sorted with ascending and
            % descending phi angle
            sph_ascend = s.sph(index_phi_ascend(index_theta_phi_ascend),:);
            sph_descend = s.sph(index_phi_descend(index_theta_phi_descend),:);
            
            % check when we want to use ascending, when descending
            isAscending = ismember(round_tol(sph_ascend(:,2)), unique_theta(1:2:end));
            % the last row with the lowest theta (at the beginning of the
            % unique-list) should be ascending in order to avoid problems
            % with the reference move later on
            
            % overwrite the data to the coordinates object
            s.sph(isAscending,:) = sph_ascend(isAscending,:);
            s.sph(~isAscending,:) = sph_descend(~isAscending,:);
            
%             % phi should be again between 0..2*pi
%             s.phi = mod(s.phi, 2*pi);
            
            function theta = round_tol(theta)
                constant = 1e10;
                theta = round(theta * constant) / constant;
            end
        end
    end
end