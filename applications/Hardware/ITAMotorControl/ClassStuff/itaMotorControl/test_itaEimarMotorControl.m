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
    % BE AWARE: THE MOTOR CONTROL HAS BEEN SEPARATED FROM THE ORIGINAL
    % itaEimar
    %
    % Author:       Jan-Gerrit Richter (jri@akustik.rwth-aachen.de)
    %
    % itaEimar:     Benedikt Krechel - November-June 2012
    %               Johannes Klein - March/April/May 2012
    %
    % Contact:      Benedikt.krechel@rwth-aachen.de
    %               Johannes.klein@rwth-aachen.de
    %
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
    %   This lets the motor decide what part of the coordinates it is
    %   responsible for
    % -  iMS.moveTo( itaCoordinate Object )
    %
    % Separate move commands:
    % -  iMS.moveTo(MotorName, step in degrees)
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
    % CONTINUOUS MEASUREMENT:
    %
    %   This moves the arc into reference, then moves some angle against
    %   the turn direction and sends all commands but start for the full
    %   rotation
    % -  iMS.prepareForContinuousMeasurement;
    %   
    %   Starts the previously prepared rotation and measures
    %    iMS.runContinuousMeasurement;
    %   
    %   See ita_tutorial_hrtfMeasurement
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
    end
    % *********************************************************************
    properties (Access = protected, Hidden = true)
        actual_status       =   []; % Store status - don't send the same command again!
        old_position        =   itaCoordinates(2); % Avoid to move two times to the same position
        wait                =   true;        % Status - do we wait for motors to reach final position? -> Set by prepare-functions!
        
        mMotorControl = [];
    end
    % *********************************************************************
    properties(Constant, Hidden = true)

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
        end
        
        
        %% -----------------------------------------------------------------
        % Reference stuff:
        function reference(this)
            % Move to reference position
            ita_verbose_info('Everything is moving... (TAKE CARE OF YOUR HEAD!)',0);
            this.mMotorControl.reference;
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
            
            % let the motor control do the move
            this.mMotorControl.moveTo(varargin{:});
        end
  
        function prepareContinuousMeasurement(this,varargin)
            
            if isempty(this.measurementSetup)
                error('Measurement Setup is unset')
            end
            
            % calculate the pre angle
            % the pre angle is needed because the measurement setup will
            % not start recording imidiately
            numRepetitions = this.measurementSetup.repetitions;
            timePerRepetition = this.measurementSetup.twait*length(this.measurementSetup.outputChannels);
            speed   =   360/(numRepetitions*timePerRepetition);

            % preangletime
            preAngle = 45;
            preAngleTime = preAngle/speed; % it takes 2 seconds to start recording

            postAngle = 10;
            postAngleTime = postAngle/speed;
            
            additionalReps = ceil((postAngleTime+preAngleTime + 1)/timePerRepetition);
            numTotalRepetitions = numRepetitions+additionalReps;
            this.measurementSetup.repetitions = numTotalRepetitions;
            
            %prepare motors for continuous measurement
            this.mMotorControl.prepareForContinuousMeasurement('speed',speed,'preAngle',preAngle);
            
            % calculate the excitation as this takes quite a long time
            this.measurementSetup.excitation;
            
            % pre init playrec to save the second delay
            if playrec('isInitialised')
                playrec('reset');
            end
            playrec('init', this.measurementSetup.samplingRate, 0, 0);
            
            
        end
        
        
        function [result, result_raw] = runContinuousMeasurement(this)
            this.mMotorControl.setWait(false);
            this.mMotorControl.startContinuousMoveNow;
            pause(0.1);
            result_raw = this.measurementSetup.run_raw_imc;
            result = this.measurementSetup.deconvolve(result_raw);
%             this.stop;
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