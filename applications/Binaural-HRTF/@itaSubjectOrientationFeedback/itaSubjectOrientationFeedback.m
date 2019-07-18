classdef itaSubjectOrientationFeedback < handle
    % class itaSubjectOrientationFeedback
    %
    % Provides visual real-time feedback about how to correct a current
    % orientation for a person in motion, e.g. during HRTF measurements
    % where no movement is desired.
    % Needs position and orientation data provided by a tracking system.
    % Usage:
    % ot = itaOptitrack('autoconnect', 1); % creates tracking object and
    % connects to localhost (127.0.0.1)
    % sof = itaSubjectOrientationFeedback(ot);
    % sof.startFeedback;
    % sof.stopFeedback;
    %
    % Author:  Saskia Wepner, swe@akustik.rwth-aachen.de
    %          Hark Baren - adaptations of Saskias code
    % Version: 2019-04-03
    %
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(GetAccess = 'public')
        optiTrackObject  = []; % store Optitrack object here
        
        plotFigure   = figure('visible', 'off', ... % create (empty) figure for real-time movement plot [MATLAB figure]
            'GraphicsSmoothing', 'off');
        figName          = 'plotFigure';        % as a precaution: avoid crash if figure is renamed from "movFig" to another name [string]
        
        %copy pasted variables: double check if needed
        train            = '';
        txtPart          = {};
        txtField         = {};
        first            = 0;
        second           = 0;
        third            = 0;
        plotType         = 2; %saskias plotTypes
        
        smileyPath       = fullfile(fileparts(mfilename('fullpath')),'pic');
        tmpImgs          = struct();  % for plot method: store smiley images for later use (avoid loading them several times) [struct]
        timerObject      = [];
        currFrameData    = []; %rigidBodyData from last valid frame
    end
    
    properties(SetAccess = 'public', GetAccess = 'public')
        doTraining       = false; % set true for training before real-time movement plot [logical]
    end
    
    properties(SetAccess = 'private', GetAccess = 'private')
        calibWindowPosition = [90,5,100,30]  % position of calibrate countdown window
    end
    
    properties(Dependent)
        isRunning
    end
    
    
    methods
        % Constructor
        function this = itaSubjectOrientationFeedback(optitrackObj)
            if nargin < 1, optitrackObj =[]; end
            this.optiTrackObject = optitrackObj;
            this.connectOptiTrack;
        end
        
        % Destructor left default for now
        
        
        %% GET ACCESS DEPENDENT PROTPERTIES
        function res = get.isRunning(this)
            res = false;
            if ~isempty(this.timerObject)&& strcmpi(this.timerObject.Running,'On')
                res = true;
            end
        end
    end
    
    
    methods
        %% functions
        function startFeedback(this,varargin)
            % OPTIONS (default)
            %   logData  (false), true: logData in optitrack object
            %            if true: provide optitrack with the necessary path
            %            arguments to store data where you want it
            
            if this.isRunning
                disp('Feedback is alredy running, please stopFeedback first.')
                return
            end
            
            sArgs = struct('logData',false);
            [sArgs,varargs] = ita_parse_arguments(sArgs,varargin);
            
            %start Optitrack tracking
            %         -> see if calibrated
            if ~this.optiTrackObject.isCalibrated
                response = questdlg('No Calibration found, what do you want to do?','Calibration Missing','Calibrate','Load Calibration from file','Calibrate');
                
                switch response
                    case 'Calibrate'
                        this.optiTrackObject.calibrate;
                    case 'Load Calibration from file'
                        [file,path] = uigetfile('Load Calibration from file')
                        this.optiTrackObject.loadCalibration;
                end
            end
            
            %set the recMethod to continous if nothing else is specified
            if ~ismember('recMethod',varargs)
                varargs = horzcat(varargs,{'recMethod',1});
            end
            
            if sArgs.logData
                if ismember('autoSave',varargs)
                    this.optiTrackObject.startLogging(varargs{:})
                else
                    this.optiTrackObject.startLogging('autoSave',true,varargs{:})
                end
            else
                this.optiTrackObject.startLogging(varargs{:});
            end
            
            %setup GUI window
            this.setupGUI;
            
            %initiate Timer Object for continuous feedback
            if isempty(this.timerObject)
                this.timerObject = timer('TimerFcn',{@this.TimerCallback},...
                    'Period',1/30,'ExecutionMode','fixedSpacing','BusyMode','drop');
            end
            
            %start feedback timer
            if strcmpi(this.timerObject.running,'off')
                %if timer stopped
                start(this.timerObject);
            end
        end
        
        function stopFeedback(this)
            if ~this.isRunning
                return
            end
            % close figure -- produces closereq error. need to be fixed.
%             fig = this.(this.figName);
%             if ishandle(fig)
%                 close(fig)
%             end

            % stop Matlab timer
            stop(this.timerObject);
            this.optiTrackObject.stopLogging;
        end
        
        function showGUI(this)
            set(this.plotFigure,'visible','on')
        end
        
        function hideGUI(this)
            set(this.plotFigure,'visible','off')
        end
        
        function setupGUI(this)
            % if figure has been closed, create a new one
            if ~ishandle(this.plotFigure)
                this.plotFigure = figure('visible', 'off', 'name', 'Movement');
            end
            
            %define title
            if this.doTraining
                figTitle = 'Training';
            else
                figTitle = 'Movement';
            end
            set(this.plotFigure, 'name', figTitle, 'visible', 'on', 'MenuBar', 'none');
            
            %adapt size to screensize
            SizeOfScreen = get(0, 'Screensize');
            set(this.plotFigure, ...
                'Position', [SizeOfScreen(1), SizeOfScreen(2)+45, SizeOfScreen(3), SizeOfScreen(4)-70]);
            %                 set(this.(this.figName), 'Resize', 'off'); % 2DO: möchte das wieder rein?
            
            % execute .stopLogging when figure is closed:
            set(this.plotFigure, 'DeleteFcn', @this.stopFeedback);
            axis off
            
            %initialize with calibration position
            this.plotInitialPosition();
            
        end
        
        function connectOptiTrack(this)
            %connect optitrack object to Motive NetNat Server
            if isempty(this.optiTrackObject)
                ita_verbose_info('ITASUBJECTORIENTATIONFEEDBACK: no Optitrack object found, initialising with autoconnect ...')
                this.optiTrackObject = itaOptitrack('autoconnect',1);
            end
            if ~this.optiTrackObject.isConnected
                this.optiTrackObject.connect;
            end
        end
        
        function calibrate(this,varargin)
            this.connectOptiTrack;
            this.optiTrackObject.calibrate(varargin);
        end
        
        function plotInitialPosition(this)
            if isempty(this.plotFigure) || ~isvalid(this.plotFigure)
                this.setupGUI;
            end
            initialData = this.optiTrackObject.dataCalibration.head;
            initialDataFrame.x  = initialData.position.x;
            initialDataFrame.y  = initialData.position.y;
            initialDataFrame.z  = initialData.position.z;
            initialDataFrame.qw = initialData.orientation.qw;
            initialDataFrame.qx = initialData.orientation.qx;
            initialDataFrame.qy = initialData.orientation.qy;
            initialDataFrame.qz = initialData.orientation.qz;
            % update of GUI according to current orientation in crosshair()
            crosshair(this,initialDataFrame,'initial')
        end
        
        function TimerCallback(this,varargin)
            % get data
            frameDataIn = this.optiTrackObject.lastValidDataFrame;
            %             [double(frameID), double(frameTime), double(rigidBodyData.ID),...
            %                 X, Y, Z, rigidBodyData.qw, rigidBodyData.qx, rigidBodyData.qy, rigidBodyData.qz, double(rigidBodyData.MeanError),...
            %                 double(rigidBodyData.Tracked), double(rigidBodyData.nMarkers)];
            
            %turn into rigidBodyData data
            rigidBodyData.ID = frameDataIn(:,3);
            rigidBodyData.x  = frameDataIn(:,4);
            rigidBodyData.y  = frameDataIn(:,5);
            rigidBodyData.z  = frameDataIn(:,6);
            rigidBodyData.qw = frameDataIn(:,7);
            rigidBodyData.qx = frameDataIn(:,8);
            rigidBodyData.qy = frameDataIn(:,9);
            rigidBodyData.qz = frameDataIn(:,10);
            
            %store in local variable
            this.currFrameData = rigidBodyData;
            
            %update plot
            this.updatePlot()
        end
        
        function updatePlot(this)
            % Adapt data pert is missing here
            
            crosshair(this, this.currFrameData, 'current');
        end
        
        
        
    end
    
end