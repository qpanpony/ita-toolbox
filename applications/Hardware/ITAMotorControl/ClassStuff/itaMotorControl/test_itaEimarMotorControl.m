classdef test_itaEimarMotorControl < itaMeasurementTasksScan
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
    % *********************************************************************
    %
    % <ITA-Toolbox>
    % This file is part of the application Movtec for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties
        doSorting           =     true;   % sort the measurement coordinates for arm due to shorter measurement time 
%         ContinuousMeasurement = 0; % moved from task-scan
    end
    % *********************************************************************
    properties (Access = protected, Hidden = true)
%         isReferenced        =   false;      % Are all motors referenced?
%         inuse               =   struct( ... % Which motors are in use?
%             'turntable',    false, ...
%             'arm',          false, ...
%             'slayer',       false);
%         started             =   struct( ... % Which motors are on right now?
%             'turntable',    false, ...
%             'arm',          false, ...
%             'slayer',       false);
          actual_status       =   []; % Store status - don't send the same command again!
        old_position        =   itaCoordinates(2); % Avoid to move two times to the same position
        wait                =   true;        % Status - do we wait for motors to reach final position? -> Set by prepare-functions!
%         sArgs_turntable     =   [];
%         sArgs_arm           =   [];
%         sArgs_slayer        =   [];
        
        mMotorControl = [];
    end
    % *********************************************************************
    properties(Constant, Hidden = true)

%         
        ARM_limit               =         [-90 120]; % Movement-range of Arm %jck: THIS SHOULD BE COUPLED TO THE VALUE IN prepare_move_arm
        SLAYER_limit            =       [-91 260]; % Movement-range of Slayer
%         % *********************************************************************
        % *********************************************************************
    end
    methods
        %% -----------------------------------------------------------------
        % Basic stuff:
        function this = test_itaEimarMotorControl(varargin)
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
 %         
        function init(this, varargin)
            % Initialize class
            
            %do a reset and also reset the serialObj
            this.reset(); % Do a reset first.
            this.actual_status           =   [];



             
            % Init RS232 and return handle
            try
                if isempty(this.measurementSetup)
                elseif isempty(this.measurementSetup) && isempty(this.measurementSetup.inputMeasurementChain(1).coordinates.x)
                    for idx = 1:numel(this.measurementSetup.inputMeasurementChain)
                        this.measurementSetup.inputMeasurementChain(idx).coordinates = itaCoordinates([0 0 0]);
                    end
                end
                
%                 insts               =   instrfind;         %show existing terminals using serial interface
%                 if ~isempty(insts)
%                     aux = strfind(insts.Name,com_port);
%                     if numel(aux) == 1
%                         aux = {aux};
%                     end
%                     for idx = 1:numel(aux)
%                         if ~isempty(aux{idx})
%                             delete(insts(idx));             %delete used serial ports
%                         end
%                     end
%                 end
                
            % init the motorclass object;
            this.mMotorControl = itaMotorControlNanotec;
            this.mIsInitialized = true;

            catch errmsg
%                 this.mIsInitialized                     =   false;
                ita_verbose_info(errmsg.message,0);
                error('i: Unable to initialize correctly');
            end
            
            % subfolder for data - speed reasons for lots of files
            if ~isdir(this.finalDataPath)
                mkdir(this.finalDataPath);
            end
            % Set some default values:
%             this.sArgs_turntable    =   this.sArgs_default_turntable;
%             this.sArgs_arm          =   this.sArgs_default_arm;
%             this.sArgs_slayer       =   this.sArgs_default_slayer;
        end
        %% -----------------------------------------------------------------
        % Reference stuff:
        function reference(this)
            % Move to reference position
            ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
            this.mMotorControl.reference;
%             this.isReferenced       =   true;
            ita_verbose_info('Reference done!',1);
        end
        %% -----------------------------------------------------------------
        % Move commands:
        function stop(this)
            % DO NOT ASK - JUST STOP ALL MOTORS!
            for i = 1:5 % repeat several times to ensure that every motor stops!
                this.mMotorControl.stopAllMotors;
            end
        end
        
        function moveTo(this,varargin)
            % Move turntable, arm and slayer to absolute position. Takes
            % struct with motor name and angle in degree or
            % itaCoordinates (first point = turntable/arm, second point* =
            % slayer, *optional)
            % Error checks
            
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
            
            this.mMotorControl.moveTo(varargin{:});
%             this.old_position = varargin;
        end
  
        function prepareContinuousMeasurement(this,varargin)
            % calculate the pre angle
            numRepetitions = this.measurementSetup.repititions;
            timePerRepetition = this.measurementSetup.twait*length(this.measurementSetup.outputChannels);
            speed   =   360/(numRepetitions*timePerRepetition);

            % preangletime
            preAngleTime = 2/64*numRepetitions;
            preAngle = preAngleTime*speed;

            preAngle = min(preAngle,15);
            preAngle = max(preAngle,8);
            numTotalRepetitions = numRepetitions+ceil(preAngleTime/(timePerRepetition))+4;
            this.measurementSetup.repititions = numTotalRepetitions;
            
            %prepare motors for continuous measurement
            this.mMotorControl.prepareForContinuousMeasurement('speed',speed,'preAngle',preAngle);
            
            this.measurementSetup.excitation;
            if playrec('isInitialised')
                playrec('reset');
            end
            playrec('init', 44100, 0, 0);
            
            
        end
        
        
        function result = runContinuousMeasurement(this)
            this.mMotorControl.setWait(false);
            this.mMotorControl.startContinuousMoveNow;
            result = this.measurementSetup.run_raw_imc;
            this.stop;
            this.mMotorControl.setWait(true);
        end
        
        function motorControl = getMotorControl(this)
           motorControl = this.mMotorControl; 
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
 
%         % -----------------------------------------------------------------
        function res = finalDataPath(this)
            % Final data path string
            res                 =   [this.dataPath filesep 'data'];
        end
        %-----------------------------------------------------------------

        
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