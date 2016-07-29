classdef itaMeasurementTasks < itaHandle
    % Measurement Tasks are unified Setups for common Measurements
    % This is an Abstract super class
    
    % Author: Pascal Dietrich - Mai 2010
    
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % *********************************************************************
    % *********************************************************************
    properties
        diaryFile = 'diary.txt'; %write console output to this file (string)
        dataPath  = pwd; %Store data in this directory
        measurementSetup = []; %use this signal measurement setup (itaMeasurementSetup...) for each measurement
    end
    % *********************************************************************
    % *********************************************************************
    properties (Access = protected, Hidden = true)
        mIsInitialized = false; %store initialization status
    end
    % *********************************************************************
    % *********************************************************************
    methods
        function res = isInitialized(this)
            % returns 1 if Obj has been initialized
            res = this.mIsInitialized;
        end
        function this = initialize(this) % -- re-route
            %initialize the Obj
            this.init;
        end
    end
    % *********************************************************************
    % *********************************************************************
    methods (Abstract)
        this = init(this) %init serial or stuff like that
        this = run(this) %go for it!
        %         this = setup(this) % maybe a GUI
        this = reference(this) %go to reference or do some special calib
        %         this = check(this) %do the settings really look promising?
    end
    % *********************************************************************
    % *********************************************************************
end