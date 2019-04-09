classdef itaZOOMSession < handle
    %ITAZOOMSESSION Lightweight class around a ZOOM session (a 'ZOOM0001' folder with
    %recorded tracks) that supports easier calibration and extraction of
    %time data

    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties(Hidden = true, Access = private)
        session_valid = false;
        session_ready = false;
        session_calibrated = false;
        tracks = cell( 0 );
    end
    
    properties( Hidden = false, Access = public )
        path = '';
        subfolder = '';
        project_name = 'Unnamed ZOOM session';
        identifier = '';
        index = 0;
        startdate;
        channels = 0;
        trackLength = 0;
        samplingRate = 0;
        domain = 'time';
    end
    
    
    methods
        
        function obj = itaZOOMSession( session_path )
            %%itaZOOMSession Create an empty ZOOM session object. If a path
            % is given as first argument, this session will be loaded, too.
            if nargin == 1
               obj.load( session_path );
            end
        end
        
    end % methods
    
end % class

