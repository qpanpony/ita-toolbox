classdef itaOptitrackData
    %ITAOPTITRACKDATA Class to plot saved optitrack data
    %   This is just a wrapper to enable optitrack plotting of saved data
    %
    %   Usage: 
    %       tmp = load('savedData.mat')
    %       data = itaOptitrackData(tmp.LogData,tmp.LogInfo);
    %       data.plot
    %
    %
    % Author:  Jan-Gerrit Richter, jri@akustik.rwth-aachen.de
    % Version: 2017-11-23
    %
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    %
    
    properties
        data = struct();
        info = struct();
        
        numRigidBodies = 0;
    end
    
    methods
        function this = itaOptitrackData(globData,globInfo)
            this.data = globData;
            this.info = globInfo;
            
            this.numRigidBodies = length(this.data);
        end
        
        
        function varargout = plot(this, varargin)
           varargout{:} = itaOptitrack.plot(this,varargin{:}); 
        end
    end
    
end

