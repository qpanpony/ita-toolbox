classdef itaListeningTestGUI < itaHandle

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    properties(Access = private, Hidden = true)
        mGUI;
        mEventTest;
        mDynamicAlphaMode = 0;
        
        %training properties
        mTrainingCounter = 0;
        mTrainingRounds = 10;
        
        
        %Blockmode properties
        mCounter = 1;
        mRounds = 10;
        
        mReplayCounter = 0;
        
        mResults = [];
        
        mAudio = [];
        
        % tracker timer and data
        mTimer = [];
        mTrackerData = cell(0);
        mCounterTracker = 0;
        mBlocksAzimuth = [];
        mBlocksElevation = [];
        mBlocksWidth = [];
        mBlocksAddWidth = [];
        
        mAbortExecution = false;
        
        % this is set during setup and then passed to java to get the
        % texture paths right
        mFilePath = '';
        
        % this (invisible figure) is used to wait for java execution
        mHelperFigure = [];
        
    end


    properties       

        mTrackerPeriod = 0.05;
        mMaxReplay = 3;
        mGLMode = 0;
        mTrainingResolution = 3;
        mUserTracker = 0; %TODO UseTracker = 1;
        mFullscreen = 0;
        mFeedbackOnly = 1;
    end
    
    methods
        function this = itaListeningTestGUI()
            this = this.initGUI();
            if this.mFeedbackOnly == 0
                % init portaudio with empty itaAudio
                dat = ita_generate('emptydat',44100,5);
                ita_portaudio(dat, 'block', false);
            end
            
            
            eventTest = this.mGUI.getEventObject;
            eventTest = handle(eventTest, 'CallbackProperties');
            set(eventTest,'ReplayEventCallback',@this.replayCallback);
            set(eventTest,'WindowCloseEventCallback',@this.windowCloseCallback);
            
            
            % timer to get the tracker data
            this.mTimer = timer('TimerFcn',@(h,e)this.getTrackerData, 'ExecutionMode','fixedRate','Period',this.mTrackerPeriod);
            this.mHelperFigure = figure('Visible','off');                     
        end
        
        function setControllerLimits(this,lowerLimit, upperLimit)
            this.mGUI.setControllerLimits(lowerLimit,upperLimit);
        end
       
        function delete(this)
%             obj.mGUI.close();
%             disp('itaListeningTest.delete');
            this.mGUI.close();
            itaListeningTestGUI.shutdownController();
            clear this.mGUI;
        end
        
        function set.mUserTracker(this,value)
           this.mUserTracker = value;
           if value == 1
            fprintf('Initializing the Polhemus tracker - please wait a few seconds...\n');
            ITAPolhemus('init');
           end
        end
        
        function value = get.mUserTracker(this)
            value = this.mUserTracker;
        end
        
        function set.mFullscreen(obj,value)
           this.mFullscreen = value;
           obj.mGUI.setFullscreen(value);
        end
        
        function setViewAzimuthAngle(obj,value)
           obj.mGUI.setViewAzimuthAngle(value)
        end
        
        function value = get.mFullscreen(obj)
            value = this.mUserTracker;
        end
        
        function setBlocks(this,azimuthPositions, elevationPositions, blockWidth, additionalWidth)
            this.mBlocksAzimuth = azimuthPositions;
            this.mBlocksElevation = elevationPositions;
            this.mBlocksWidth = blockWidth;
            this.mBlocksAddWidth = additionalWidth; 
        end
        
        function setDynamicAlphaMode(this,value)
           this.mDynamicAlphaMode = value;
        end
  
        function [abort] = showAndStopTillUserReady(this)
            
            this.mGUI.show(this.mGLMode,this.mFilePath); %1 - Blockmode , 0 - Normalmode
                        
            %Set Blocks in JOGL
            this.mGUI.setBlocks(length(this.mBlocksAzimuth),...
                this.mBlocksAzimuth, this.mBlocksElevation, this.mBlocksWidth, this.mBlocksAddWidth)
            
            % set alpha mode
            this.mGUI.setDynamicAlphaMode(this.mDynamicAlphaMode); 
            
            eventTest = this.mGUI.getEventObject;
            eventTest = handle(eventTest, 'CallbackProperties');
            set(eventTest,'StartEventCallback',@this.startEventCallback);
            
            set(this.mHelperFigure,'Tag','true');
            waitfor(this.mHelperFigure,'Tag','false');
            
%             eventTest.setStartBlocked(true);
%             waitfor(eventTest,'StartBlocked','off')
            
            abort = this.mAbortExecution;
        end
        
        
        function showFeedbackAndWait(this,trainAzimuth,trainElevation,userAzimuth,userElevation,timeout)
            this.mGUI.show(this.mGLMode,this.mFilePath);
            this.mGUI.setOnlyFeedback(1);
            this.mGUI.setFeedback(trainAzimuth,trainElevation,2,userAzimuth,userElevation);
            pause(timeout);
            this.mGUI.close();
        end
      
        function closeGUI(this)
           if (this.mUserTracker == 1)
            %ITAPolhemus('finalize');
           end
           
           this.mGUI.close(); 
        end
        
        function [results] = startSingleTraining(this,azimuth,elevation,audio)
            this.mAudio = audio;
            this.mReplayCounter = 0;
            this.mAbortExecution = false;
            [results] = singleShot(this,azimuth,elevation,audio,1);
        end
        
        function [results] = startSingleListeningTest(this,azimuth,elevation,audio)
            this.mAudio = audio;
            this.mReplayCounter = 0;
            this.mAbortExecution = false;
            [results] = singleShot(this,azimuth,elevation,audio,0);
        end
        
        function fullReset(this)
            this.mAbortExecution = false;
            this.mGUI.fullReset();
        end
        
    end

    methods(Static = true)
        function shutdownController()
            ita.listeningTestGUI.ListeningTestMain.shutdownController; 
        end   
        
    end
    
    methods(Hidden = true)
        
        function this = initGUI(this)
            %clear java
            % this does not work!
            % java.lang.System.load([pwd '/jinput/jinput-dx8_64.dll']); %Windows
            % java.lang.System.load([pwd '/jinput/jinput-raw_64.dll']); %Windows

            % clear import
            import ita.listeningTestGUI.*
            % import jinput.*
            import net.java.games.*
            import org.nicegamepads.*
            % create object
            this.mGUI = ita.listeningTestGUI.ListeningTestMain.getInstance();
            %Create Arrays for JavaBlocks
%             [this.mBlocksAzimuth, this.mBlocksElevation, this.mBlocksWidth, this.mBlocksAddWidth] = ...
%                 createJavaBlockArrays (6, 3, 60, 120);
            path = mfilename('fullpath');

            folder = strrep(path,'\','/');     
            C = strsplit(folder,'/');
            C{end} = 'java';
            this.mFilePath = strjoin(C(1:end),'/');
            
            this.mGUI.setOnlyFeedback(this.mFeedbackOnly);
            
        end
        
        function [results] = singleShot(this,azimuth,elevation,audio,training)

            this.mRounds = 1;
            this.mCounter = 1;
            this.mTrackerData = cell(1,1000);
            eventTest = this.mGUI.getEventObject;
            setappdata(eventTest,'UserData',[]); 
            eventTest = handle(eventTest, 'CallbackProperties');
           
            set(eventTest,'ConfirmationEventCallback',@this.confirmationCallback);

            this.mGUI.reset();
            % start the timer to get tracker values
            this.mCounterTracker = 0;
            start(this.mTimer);
            if (training)
                this.mGUI.trainDirection(azimuth,elevation,this.mTrainingResolution);    
            end

            tic
            % play
            if (~isempty(audio))
                outputChannels = [1 2];
                ita_portaudio(audio, 'block', false,'OutputChannels',outputChannels);
            end
            set(this.mHelperFigure,'Tag','true');
            waitfor(this.mHelperFigure,'Tag','false');


            data = getappdata(eventTest,'UserData');
            if (this.mAbortExecution == 1)
                results.abort = this.mAbortExecution;
            else
                results = data.results;
                results.azimuth = azimuth;
                results.elevation = elevation;
                results.abort = this.mAbortExecution;
            end

        end
        
        % this callback is used in show and wait mode to wait for
        % startEvent
        function startEventCallback(this,event,source)
           %set(event,'StartBlocked','off');
           set(this.mHelperFigure,'Tag','false');
           this.mGUI.reset();
        end
        
        function this = confirmationCallback(this,event,source)
            userTime = toc;
            stop(this.mTimer);
            data = get(event,'ConfirmationEventCallbackData');
           
            userData = getappdata(event,'UserData');

            
            userData.results.userTime = userTime;
            userData.results.userAzimuth = data.azimuth;
            userData.results.userElevation = data.elevation;
            userData.results.inHead = data.inHeadLocalization;
            userData.results.replayCounter = this.mReplayCounter;
            userData.results.trackerData = this.mTrackerData;
           

            setappdata(event,'UserData',userData); 
            

            set(this.mHelperFigure,'Tag','false');
        end
        
        function this = replayCallback(this,event,source)
            if (~isempty(this.mAudio) && this.mReplayCounter < this.mMaxReplay)
                outputChannels = [25 26];
                ita_portaudio(this.mAudio, 'block', false,'OutputChannels',outputChannels);;
                this.mReplayCounter = this.mReplayCounter + 1;
            end
            if (this.mReplayCounter >= this.mMaxReplay)
                this.mGUI.hideReplayButton(); 
            end
        end
        
        function this = windowCloseCallback(this,event,source)
            disp('closeEvent');
            this.mAbortExecution = true;
            
            set(this.mHelperFigure,'Tag','false');
        end
        
        function this = getTrackerData(this,event,source)

            % TODO: get tracker marker
            if (this.mUserTracker == 1)
               this.mCounterTracker = this.mCounterTracker +1; 
               S = ITAPolhemus('getsensorstates');
               this.mTrackerData(this.mCounterTracker) = S(1,1);
            end

        end
        
        function clearGUI(this)
         % import the ita matlab java functions
            import ita.matlab.*
            mGUI = ita.listeningTestGUI.ListeningTestMain.getInstance();

            
            eventTest = this.mGUI.getEventObject;
            eventTest = handle(eventTest, 'CallbackProperties');
            set(eventTest,'StartEventCallback','');

            clear eventTest;
            mGUI.close();
            clear mGUI;
        end
        
    end  

end








