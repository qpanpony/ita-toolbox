classdef itaOptitrack < handle
    % class itaOptitrack
    %
    %   Constructs an itaOptitrack object to communicate with a NatNet server 
    %   application (e.g. Motive). Can be used to log tracking data for further 
    %   usage in Matlab.
    %
    %   For proper functionality:
    %   (1) Run Optitrack's Motive tracker software
    %   (2) Enable "Broadcast Frame Data" in the Data Streaming Panel
    %       (Select Network Interface, e.g. 'Local Loopback')
    %   (3) Define rigid bodies using >2 reflective markers
    %
    %   All options must be provided as pair, i.e. 
    %   'option', <option_value> ([string] or [double]/[logical]).
    %
    %   ATTENTION: Creating two itaOptitrack objects with same name potentially
    %   leads to a Matlab crash! Avoid it!
    %
    %   Constructor: [Optitrack_obj] = itaOptitrack(options)
    %                'autoconnect' Connects to 127.0.0.1 ('localhost') or
    %                        to given host IP/port immediately [logical].
    %                'ip'    Connect to a defined host IP address. If no 
    %                        host IP is given, a connection to 'localhost' 
    %                        is established [string].
    %                'port'  Port of the server to be connected to. The
    %                        default command port is '1510' (and can be changed
    %                        in Motive's Advanced Network options) [string].
    %
    %   Destructor:  Optitrack_obj.delete():
    %                Delete Optitrack_obj.
    %
    %   To establish a connection to a NatNet server application on 'localhost', 
    %   run Optitrack_obj.connect() without any further input arguments or pass
    %   a host IP address as string. Optionally, construct class with option
    %   'autoconnect'.
    %
    %   Methods:
    %
    %       Optitrack_obj.connect(options):
    %           Connect to NatNet server
    %           'ip'         Connect to a defined host IP address. If no host IP is given,
    %                        a connection to '127.0.0.1' ('localhost') is
    %                        established [string].
    %           'port'       Port of the server to be connected to. The
    %                        default command port is '1510' (and can be changed
    %                        in Motive's Advanced Network options) [string].
    %
    %       Optitrack_obj.disconnect():
    %           Disconnect from NatNet server.
    %
    %       Optitrack_obj.printInfo():
    %           Display info about markers and rigid bodies (requires
    %           server connection).
    %
    %       Optitrack_obj.startLogging(options)
    %           Start to log tracker data with preferred options (requires
    %           server connection). Data will be stored temporarily in 
    %           Optitrack_obj.data and/or saved to disc ('savePath', 'saveName')
    %           'recMethod'  recording method,
    %                        0: record data for recTime seconds (default) [double]
    %                        1: manually abort logging by Optitrack_obj.stopLogging  [double]
    %           'recTime'    preferred logging time in seconds [double]
    %                        (default: 1, only for recMethod 0)
    %           'singleShot' only log 1 frame of tracking data [logical]
    %                        (e.g. for geometric measurement purposes)
    %           'autoSave'   save tracked data (default: false) [logical]
    %                        if savePath and/or saveName are unset,
    %                        savePath -> pwd, saveName -> trackerData_time_stamp
    %           'savePath'   path to save file containing logged data [string]
    %           'saveName'   name of file containing logged data [string]
    %
    %       Optitrack_obj.info [struct] contains:
    %           .CaptureStartTime  start time of data logging [string]
    %           .NatNetVersion     version of used NatNet SDK [string]
    %           .TakeName          name of recording take (if specified 
    %                              during .startLogging) [string]
    %           .CaptureFrameRate  tracker rate in Hz [double]
    %           .TotalFrames       number of recorded frames [double]
    %           .CoordinateSpace   used coordinate space [string]
    %
    %       Optitrack_obj.data [1 x numRigidBodies struct] contains:
    %           .frameID           IDs of all tracked frames [numFrames x 1 double]
    %           .frameTime         time stamps of all tracked frames [numFrames x 1 double]
    %           .rigigBodyID       ID of rigid body [double]
    %           .rigidBodyName     name of rigid body [string]
    %           .position          position of rigid body [itaCoordinates with numFrames points]
    %           .orientation       position of rigid body [itaOrientation with numFrames points]
    %           .meanError         mean error of marker distances between the rigid body definition 
    %                              and the tracked rigid body [numFrames x 1 double]
    %           .isTracked         tracked/un-tracked [numFrames x 1 logical]
    %           .nMarkers          number of markers associated with rigid body [1 x 1 double]
    %           .droppedFrameID    IDs of dropped frames [numDroppedFrames x 1 double]
    %           .droppedFrameTime  time stamps of dropped frames [numDroppedFrames x 1 double]
    %           .calibratedData    data is adjusted by offset vector calculated during .calibrate (only for first rigid body) [logical]
    %
    %       Optitrack_obj.stopLogging(options)
    %           Stop logging tracker data
    %
    %       Optitrack_obj.plot(options)
    %           Plot routine to visualize position and orientation over time
    %           'stepSize'              only display every stepSize frame
    %                                   (default: 7) [double]
    %           
    %           Note: Use the function ita_plot_itaOptitrack_data for plotting 
    %                 stored logging data after using .startLogging and 'autoSave'.
    %
    %       Optitrack_obj.calibrate(options)
    %           Calculate offset of a head-mounted rigid body to the center
    %           of the interaural axis (procedure description: see below).
    %           'useCalibration'        apply calibration data in
    %                                   consecutive measurements (optional, default: [], user will be asked) [logical]
    %           'calibPenOffset'        calibration pen: vector norm in meters measured from the volume center point 
    %                                   of the marker set to the tip of the calibration pen [double]
    %           'countdownDuration'     duration of countdown in seconds during calibration procedure [double]
    %           'savePathCalibration'   path to save Optitrack_obj.dataCalibration / .infoCalibration 
    %                                   as .mat file (optional) [string]
    %           'saveNameCalibration'   name of .mat file containing calibration data to be saved (optional) [string]
    %
    %       Optitrack_obj.loadCalibration(options)
    %           Load calibration data saved during .calibrate. Calibration data will be automatically applied 
    %           on logged data of following measurements.
    %           'loadPathCalibration'   path to Optitrack_obj.calibrationData .mat file to be loaded [string]
    %           'loadNameCalibration'   file name of .mat file to be loaded [string]
    % 
    %       Optitrack_obj.dataCalibration (calibration data as measured during .calibrate)
    %           .head                   position (itaCoordinates) and orientation (itaOrientation) 
    %                                   of head-mounted marker set
    %           .leftPenTip             position (itaCoordinates) and orientation (itaOrientation) 
    %                                   of offset-corrected left pen marker set
    %           .rightPenTip            position (itaCoordinates in [m]) and orientation (itaOrientation) 
    %                                   of offset-corrected right pen marker set
    %           .headToLeftPenTip       vector norm measured from the volume center point 
    %                                   of the head-mounted marker set to the offset-corrected tip of the   
    %                                   left calibration pen (itaCoordinates) 
    %           .headToRightPenTip      vector norm measured from the volume center point 
    %                                   of the head-mounted marker set to the offset-corrected tip of the   
    %                                   right calibration pen (itaCoordinates) 
    %           .headToEarAxisCenter    vector norm measured from the volume center point 
    %                                   of the head-mounted marker set to the center of the 
    %                                   line connecting the tips of the calibration pens 
    %                                   (e.g., ear axis midpoint) (itaCoordinates)
    %               
    %       Optitrack_obj.infoCalibration contains information about the calibration data (see .dataCalibration)
    %
    %    The following useful commands are available to communicate with Optitrack's software Motive
    %    via Matlab/NatNet (see p.14 of NatNet's User Guide)
    %
    %       Syntax:
    %       Optitrack_obj.theClient.SendMessageAndWait('<Command>, <Parameter>')
    %           Sends an application-defined message to the NatNet server application and waits for a response.
    %
    %          .SendMessageAndWait('SetRecordTakeName, <Name of next recording take>');
    %                        Name of next recording take (Note: There is an error in NatNetUsersGuide, 'TakeName' is no appropriate command!)
    %          .SendMessageAndWait('StartRecording');
    %                        Start Recording
    %          .SendMessageAndWait('StopRecording');
    %                        Stop Recording
    %          .SendMessageAndWait('LiveMode');
    %                        Switch to Live mode
    %          .SendMessageAndWait('EditMode');
    %                        Switch to Edit mode
    %          .SendMessageAndWait('TimelinePlay');
    %                        Start take playback
    %          .SendMessageAndWait('TimelineStop');
    %                        Stop take playback
    %
    %	Example 1: create, connect with given host IP, log 0.5 seconds of
    %              tracking data (recMethod 0), disconnect, destroy
    %       Optitrack_obj = itaOptitrack();
    %       Optitrack_obj.connect('ip','127.0.0.1')
    %       Optitrack_obj.startLogging('recMethod',0,'recTime',0.5)
    %       Optitrack_obj.disconnect();
    %       Optitrack_obj.delete();
    %
    %	Example 2: create+autoconnect (without given host IP), log tracking
    %              data (recMethod 1), destroy
    %       Optitrack_obj = itaOptitrack('autoconnect',1);
    %       Optitrack_obj.startLogging('recMethod',1,'savePath',pwd,'saveName','testtake')
    %       java.util.concurrent.locks.LockSupport.parkNanos(0.5*10^9);
    %       Optitrack_obj.stopLogging
    %       Optitrack_obj.delete();
    %
    %	Example 3: create+autoconnect (with given host IP), set take name,
    %              start/stop logging ~0.5s of tracking data in Motive, destroy
    %       Optitrack_obj = itaOptitrack('autoconnect',1,'ip','127.0.0.1');
    %       Optitrack_obj.theClient.SendMessageAndWait('SetRecordTakeName, testtake');
    %       Optitrack_obj.theClient.SendMessageAndWait('StartRecording');
    %       java.util.concurrent.locks.LockSupport.parkNanos(0.5*10^9);
    %       Optitrack_obj.theClient.SendMessageAndWait('StopRecording');
    %       Optitrack_obj.delete();
    %
    % Optitrack_obj.calibrate: Description of the calibration procedure
    % This calibration method relies on 3 rigid bodies (define in Motive):
    %        Rigid Body 1: head-mounted marker set
    %        Rigid Body 2: left calibration pen marker set
    %        Rigid Body 3: right calibration pen marker set
    %
    %        When defining Rigid Body 2 and 3 in Motive ensure that each of
    %        them is perpendicular to the XZ-plane -> up = [0 1 0]
    %
    %        Procedure:
    %        1) Run the following commands:
    %        Optitrack_obj = itaOptitrack('autoconnect',1,'ip','<host ip>');
    %        Optitrack_obj.calibrate(options);
    %        
    %        2) A dialog window with countdown appears. You now have 
    %        Optitrack_obj.countdownDuration seconds to place the two tips 
    %        of the calibration pens at the user's ear entrances of each ear. 
    %        The vector norm in meters measured from the volume center point 
    %        of the calibration pen's marker set to the tip of the calibration 
    %        pen (default: 0.12 m) is already included in this procedure.
    %
    %        3) Another dialog window appears. You can either apply 
    %        Optitrack_obj.dataCalibration.headToEarAxisCenter
    %        in following measurements ('Yes') or directly apply it as offset 
    %        to the head-mounted rigid body in Motive ('No'). Note that the 
    %        latter makes only sense for static objects (e.g. dummy head) as the
    %        calculated (instantenous) offset won't be valid anymore as soon
    %        as the orientation of the head-mounted rigid body is changed.
    %
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    %
    % Feel free to improve this class by solving the TODOs in the code.
    %
    % See also: itaOrientation, itaCoordinates, quaternion, ita_quat2rpy, 
    %           ita_quat2vu, ita_rpy2quat, ita_rpy2vu, ita_vu2quat, ita_vu2rpy
    %           ita_plot_itaOptitrack_data
    
    properties (Constant, Hidden)
        stopped          = 0;
        logging          = 1;
    end
    
    properties(SetAccess = 'private', GetAccess = 'public')
        ip               = '127.0.0.1'; % host IP address [string]
        port             = '1510';      % port of the host server, the default command port is '1510' (can be changed in Motive's Advanced Network options) [string] 
        isConnected      = false;       % connection status to NatNet host application [logical]
        isInitialized    = false;       % initialization status [logical]
        isCalibrated     = false;       % calibration status [logical]
        
        loggingState     = itaOptitrack.stopped; % 0: stopped, 1: logging [logical]
        
        theClient;                % NatNetClientML object
        frameRate        = [];    % tracker frame rate in Hz [double]
        numRigidBodies   = [];    % number of rigid bodies [double]
        
        data             = struct();  % logged rigid body data, 1 x numRigidBodies [struct]
        info             = struct();  % info about logged rigid body data in .data [struct]
        
%         dataMLF          = struct();  % decoded rigid body data from MLF, 1 x numRigidBodies [struct]
%         infoMLF          = struct();  % info about decoded rigid body data in .dataMLF [struct]
        
        dataCalibration  = struct();  % calibration data measured during Optitrack_obj.calibrate [struct]
        infoCalibration  = struct();  % info about calibration data in .dataCalibration [struct]
    end
    
    properties(SetAccess = 'public', GetAccess = 'public')
        recMethod        = 0;     % recording method, 0: record data for recTime seconds (default), 1: record data without time limitation (stop via Optitrack_obj.stopTracking) [double]
        recTime          = 1;     % preferred logging time in sec (default: 1, only for recMethod 0) [double]
        autoSave         = false;  % save tracked data to pwd or to 'savePath' if set to true [logical]
        savePath         = [];    % path to save file containing logged data [string]
        saveName         = [];    % name of file containing logged data [string]

%         % for method .decodeMotiveLogFile
%         numRigidBodiesMLF    = 1; % number of rigid bodies
%         numMarkersPerRigidBodyMLF = 3; % number of markers per rigid body (default: 3), use a vector for different amount of markers per rigid body
%         pathMLF          = [];    % path to Motive Log File (MLF) w/o name of file       
%         nameMLF          = [];    % name of MLF including '.csv'
%         savePathMLF      = [];    % path to save decoded MLF data as .mat file (optional)
%         saveNameMLF      = [];    % name of saved MLF .mat file (optional)
        
        % for method .calibrate
        countdownDuration   = 5;  % duration of countdown in sec during calibration process [double]
        savePathCalibration = []; % path to save Optitrack_obj.calibrationData as .mat file [string]
        saveNameCalibration = []; % name of saved .mat file (optional) [string]
        loadPathCalibration = []; % path to Optitrack_obj.calibrationData .mat file to be loaded [string]
        loadNameCalibration = []; % file name of .mat file to be loaded [string]
        
    end
    
    properties(SetAccess = 'private', GetAccess = 'private')
        dllPath          = fullfile(ita_toolbox_path,'applications/Hardware/Tracking/Optitrack/NatNetSDK'); % path to itaOptitrack [string]
        timerData        = [];    % Matlab timer handle
        singleShot       = 0;     % only log 1 frame of tracking data (e.g. for geometric measurement purposes) [logical]
        correctRowIdx    = 1;     % idx to fill up Optitrack_obj.rigidBodyLogData.data ignoring duplicate frames [double]
        autoconnect      = 0;     % autoconnect after constructing class object [logical]
        useCalibration   = [];    % apply calibration on tracking data of following measurements [logical], []...question dialog, 0...do not use calibration, 1...use calibration
        tempRigidBodyLogData = []; % temporal rigidBodyLogData
        lastFrameTime    = [];    % most recent frame of data time
        lastFrameID      = [];    % most recent frame of data ID
        numFrames        = [];    % number of frames of tracking data to be saved according to recTime (only for recMethod 1) [double]
        rigidBodyLogData = [];    % logged tracking data
        calibPenOffset   = 0.12;  % vector norm in meters measured from the volume center point of the marker set to the tip of the calibration pen [double]
        measRodOffset    = 0.742; % vector norm in meters measured from the volume center point of the marker set to the tip of the measurement rod [double]
                                  % Note: Marker set / rigid body of measurement rod must be named 'MeasRod' and oriented towards positive
                                  % y-axis when creating the rigid body in Motive
        
%         rigidBodyLogDataMLF = []; % logged tracking data decoded from MLF
    end
    
    properties(SetAccess = 'public', GetAccess = 'public', Hidden = true)
        debugInfo        = 0;     % print additional info (e.g. duplicate frames)
        applyMeasRodOffset = true; % correct logged data of rigid body 'MeasRod' by multipling measRodOffset with negative up vector of measurement rod marker set (named 'MeasRod' in Motive)
    end
    
    properties(Dependent = true, Hidden = true)
        lastValidDataFrame        %for external access while tracking
    end
    
    %% Public methods
    methods
        %% CONSTRUCTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Optitrack_obj = itaOptitrack(varargin)
                       
            sArgs          = struct('autoconnect',0,'ip',Optitrack_obj.ip,'port',Optitrack_obj.port);
            sArgs          = ita_parse_arguments(sArgs,varargin,1);
            Optitrack_obj.autoconnect = sArgs.autoconnect;
            Optitrack_obj.ip          = char(sArgs.ip);
            Optitrack_obj.port        = char(sArgs.port);
            
            % Check if NatNet dll's are existing
            if isempty( which( 'NatNetML.dll' ) )
                
                % download NatNet version
                url = 'http://s3.amazonaws.com/naturalpoint/software/NatNetSDK/NatNet_SDK_2.10.zip';
                
                try
                    % check Internet connection and if url is existing
                    urljava = java.net.URL(url);
                    openStream(urljava);
                catch
                    % url is not existing or computer is not connected to Internet
                    error(['[itaOptitrack] No Internet connection or, ',url,' does not exist. Missing NatNet SDK cannot be downloaded. Please update download URL and NatNet version number.'])
                end
                    
                % create directory
                mkdir(Optitrack_obj.dllPath)
                
                fprintf( '[itaOptitrack] Cannot find NatNet SDK. Downloading...' );
                
                websave(fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10.zip'),url);
                
                % unzip
                fprintf('.')
                unzip(fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10.zip'),fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10'));
                
                % delete zip file
                fprintf('.\n')
                delete(fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10.zip'))
                
                % delete downloaded quaternion.m version
                delete(fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10\NatNetSDK\Samples\Matlab\quaternion.m'))
                delete(fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10\NatNetSDK\Samples\Matlab\quaternion-license.txt'))
                
                if strcmpi( computer('arch'), 'win64' )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/NatNetML.dll') )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/NatNetLib.lib') )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/NatNetLibStatic.lib') )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/NatNetLib.dll') )
                    rmdir( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/Samples'),'s' )
                    addpath( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/x64' ) )
                else
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/x64/NatNetML.dll') )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/x64/NatNetLib.lib') )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/x64/NatNetLibStatic.lib') )
                    delete( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib/x64/NatNetLib.dll') )
                    rmdir( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/Samples'),'s' )
                    addpath( fullfile(Optitrack_obj.dllPath,'NatNet_SDK_2.10/NatNetSDK/lib' ) )
                end
                
                fprintf( '[itaOptitrack] NatNet SDK 2.10 has been successfully downloaded.\n' );

            end
            
            NET.addAssembly( which( 'NatNetML.dll' ) );
            
            % Create instance of NatNet client
            Optitrack_obj.theClient     = NatNetML.NatNetClientML(0); % Input = iConnectionType: 0 = Multicast, 1 = Unicast
            version                     = Optitrack_obj.theClient.NatNetVersion();
            fprintf( '[itaOptitrack] Initialization succeeded.\n' );
            fprintf( '[itaOptitrack] NatNetML Client Version: %d.%d.%d.%d\n', version(1), version(2), version(3), version(4) );
            
            Optitrack_obj.isInitialized = true;
            
            % additionally connect to 'localhost'
            if Optitrack_obj.autoconnect
                connect(Optitrack_obj,'ip',Optitrack_obj.ip,'port',Optitrack_obj.port);
            end
            
        end
        
        %% DESTRUCTOR %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function destroy(Optitrack_obj)
            error('[itaOptitrack] Method deprecated. Please use .delete.');
        end
        function delete(Optitrack_obj)
            % delete Optitrack_obj (invalid handle remains -> clear('Optitrack_obj'))
            
            if Optitrack_obj.isConnected
                disconnect(Optitrack_obj);
                Optitrack_obj.isConnected = false;
            end
            delete(Optitrack_obj)
            fprintf('[itaOptitrack] Successfully deleted itaOptitrack object. Remaining object is no longer valid (invalid handle).\n')
        
        end
        
        %% DEPENDENT GET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function res = get.lastValidDataFrame(this)
            res = this.tempRigidBodyLogData;
        end
        
        %%
        function connect(Optitrack_obj, varargin)
        % connect to a NatNet server application (optionally pass host ip address [string])    
            if Optitrack_obj.isConnected == false
                
                % parse input arguments
                sArgs              = struct('ip',Optitrack_obj.ip,'port',Optitrack_obj.port);
                sArgs              = ita_parse_arguments(sArgs,varargin,1);
                if strcmp(sArgs.ip,'localhost')
                    Optitrack_obj.ip = java.net.InetAddress.getLoopbackAddress.getHostAddress;
                else
                    Optitrack_obj.ip   = char(sArgs.ip);
                end
                Optitrack_obj.port = char(sArgs.port);
                
                % Connect to an OptiTrack server (e.g. Motive)
                display('[itaOptitrack] Connecting to OptiTrack Server...')
                
                % set host ip address ('127.0.0.1' (localhost) per default)
                if strcmp(sArgs.ip,'127.0.0.1')
                    fprintf('[itaOptitrack] No specific host IP address given. Host IP address is set to %s (''localhost'', port %s)\n', char(Optitrack_obj.ip), Optitrack_obj.port)
                else
                    fprintf('[itaOptitrack] Host IP address: %s (port %s) \n', char(Optitrack_obj.ip), char(Optitrack_obj.port))
                end
                
                % connect to NatNet server application
                remote_host = Optitrack_obj.ip;
                remote_port = str2double(Optitrack_obj.port);
                own_loopback = java.net.InetAddress.getLoopbackAddress.getHostAddress;
                own_host = java.net.InetAddress.getLocalHost.getHostAddress;
                if remote_host == own_loopback
                    own_host = own_loopback; % use loopback interface instead of network device
                end
                returnCode = Optitrack_obj.theClient.Initialize( char( own_host ), char( remote_host ), remote_port ); % returnCode: 0 = Success
                    
                if returnCode==0
                    fprintf('[itaOptitrack] Connection to OptiTrack Server (IP %s, port %s) succeeded.\n',char( Optitrack_obj.ip ), char( Optitrack_obj.port ))
                    Optitrack_obj.isConnected = true;
                else
                    error('[itaOptitrack] Connection to OptiTrack Server (IP %s, port %s) failed.',char( Optitrack_obj.ip ), char( Optitrack_obj.port ))
                    Optitrack_obj.isConnected = false; %#ok<UNRCH>
                end
                
                % get tracker frame rate
                byteArray               = Optitrack_obj.theClient.SendMessageAndWait('FrameRate'); % request current system�s tracking frame rate
                byteArray               = uint8(byteArray); % decode frame rate
                Optitrack_obj.frameRate = typecast(byteArray,'single');
                fprintf('[itaOptitrack] Tracker frame rate: %d Hz\n', Optitrack_obj.frameRate)
                
                % print out a list of the active tracking Models in Motive
                printInfo(Optitrack_obj);
                Optitrack_obj.numRigidBodies = double(Optitrack_obj.theClient.GetLastFrameOfData.nRigidBodies);
                
            else
                fprintf('[itaOptitrack] Connection to OptiTrack Server (IP %s, port %s) is already established.\n',char( Optitrack_obj.ip ), char( Optitrack_obj.port ))
            end
            
        end
        
        %% 
        function disconnect(Optitrack_obj)
        % disconnect from a NatNet server application
            
            if Optitrack_obj.isConnected
                
                if Optitrack_obj.loggingState
                    stopLogging(Optitrack_obj);
                    Optitrack_obj.loggingState = Optitrack_obj.stopped;
                end
                
                Optitrack_obj.theClient.Uninitialize();
                fprintf('[itaOptitrack] Disconnected successfully from OptiTrack Server (IP %s, port %s).\n',char( Optitrack_obj.ip ),char( Optitrack_obj.port ))
                Optitrack_obj.isConnected   = false;
            else
                display('[itaOptitrack] There is no connection to an OptiTrack server to be disconnected.')
            end
            
        end
        
        %% print a description of actively tracked models in Motive
        function printInfo(Optitrack_obj)
            % Display info about markers and rigid bodies (requires server connection)
            if Optitrack_obj.isConnected
                
                dataDescriptions = Optitrack_obj.theClient.GetDataDescriptions();
                
                if dataDescriptions.Count==0
                   fprintf('[itaOptitrack] Cannot find any tracking models! -> check Motive settings (data streaming with correct local interface enabled?)\n')
                end
                
                % print information
%                 fprintf('[itaOptitrack] Tracking Models: %d\n', dataDescriptions.Count);
%                 for idx = 1 : dataDescriptions.Count
%                     descriptor = dataDescriptions.Item(idx-1);
%                     if(descriptor.type == 0)
%                         fprintf('\tMarkerSet: ');
%                     elseif(descriptor.type == 1)
%                         fprintf('Rigid Body: ');
%                     elseif(descriptor.type == 2)
%                         fprintf('\tSkeleton: ');
%                     else
%                         fprintf('\tUnknown data type: ');
%                     end
%                     fprintf('%s\n', char(descriptor.Name));
%                 end
                
                for idx = 1 : dataDescriptions.Count
                    descriptor = dataDescriptions.Item(idx-1);
                    if(descriptor.type == 0)
                        fprintf('\n\tMarkerset: %s\t(%d markers)\n', char(descriptor.Name), descriptor.nMarkers);
                        markerNames = descriptor.MarkerNames;
                        for markerIndex = 1 : descriptor.nMarkers
                            name = markerNames(markerIndex);
                            fprintf('\t\tMarker: %-20s\t(ID=%d)\n', char(name), markerIndex);
                        end
                    elseif(descriptor.type == 1)
                        fprintf('\n\tRigid Body: \t%s\t\t(ID=%d, ParentID=%d)\n', char(descriptor.Name),descriptor.ID,descriptor.parentID);
                    elseif(descriptor.type == 2)
                        fprintf('\n\tSkeleton: %s\t(%d bones)\n', char(descriptor.Name), descriptor.nRigidBodies);
                        %fprintf('\t\tID : %d\n', descriptor.ID);
                        rigidBodies = descriptor.RigidBodies;
                        for boneIndex = 1 : descriptor.nRigidBodies
                            rigidBody = rigidBodies(boneIndex);
                            fprintf('\t\tBone: %-20s\t(ID=%d, ParentID=%d)\n', char(rigidBody.Name), rigidBody.ID, rigidBody.parentID);
                        end
                    end
                end
                
            else
                fprintf('[itaOptitrack] No information about tracking models because there is no connection to an OptiTrack server.\n')
            end
            
        end
        
        function startLogging(Optitrack_obj,varargin)
        %% start data logging using the chosen recording method
        
            if Optitrack_obj.isConnected
            
            % parse input arguments
            sArgs          = struct('recMethod',0,'recTime',1,'savePath',[],'saveName',[],'singleShot',0,'debugInfo',0,'autoSave',0);
            sArgs          = ita_parse_arguments(sArgs,varargin,1);
            Optitrack_obj.recMethod      = sArgs.recMethod;  % recording method, 0: record data for recTime seconds
            %                                                                    1: manually abort logging by closing msgbox
            Optitrack_obj.recTime        = sArgs.recTime;    % preferred logging time [s]
            Optitrack_obj.savePath       = sArgs.savePath;   % path to save logged data (optional)
            Optitrack_obj.saveName       = sArgs.saveName;   % name of log file to be saved
            Optitrack_obj.debugInfo      = sArgs.debugInfo;  % name of log file to be saved
            Optitrack_obj.singleShot     = sArgs.singleShot; % only log 1 frame of tracking data
            Optitrack_obj.autoSave       = sArgs.autoSave;
            
            % clear old data
            Optitrack_obj.data = [];
            Optitrack_obj.info = [];
            Optitrack_obj.rigidBodyLogData = [];
            
            fprintf('[itaOptitrack] Started logging of tracker data. Running...\n')
            
            % log CaptureStartTime
            Optitrack_obj.info.CaptureStartTime = datestr(now);
             
            % get latest frame of data
            latestData                   = Optitrack_obj.theClient.GetLastFrameOfData();
            Optitrack_obj.lastFrameTime  = latestData.fLatency;
            Optitrack_obj.lastFrameID    = latestData.iFrame;
            
            % init.
            if Optitrack_obj.recMethod %==1
                if Optitrack_obj.singleShot
                    Optitrack_obj.numFrames = 1; % required number of frames
                    Optitrack_obj.rigidBodyLogData.data = NaN(Optitrack_obj.numFrames,13,Optitrack_obj.numRigidBodies);
                else
                    Optitrack_obj.rigidBodyLogData.data = double.empty(0,13,Optitrack_obj.numRigidBodies); % concatenate following frames
                end
            
            else % Optitrack_obj.recMethod==0
                
                if Optitrack_obj.singleShot
                    Optitrack_obj.numFrames = 1; % required number of frames
                    Optitrack_obj.rigidBodyLogData.data = NaN(Optitrack_obj.numFrames,13,Optitrack_obj.numRigidBodies);
                else
                    Optitrack_obj.numFrames = ceil(Optitrack_obj.recTime*(Optitrack_obj.frameRate)); % required number of frames
                    Optitrack_obj.rigidBodyLogData.data = NaN(Optitrack_obj.numFrames,13,Optitrack_obj.numRigidBodies);
                end
                
            end
            Optitrack_obj.rigidBodyLogData.droppedFrames = double.empty(0,2);
            
%             % create a msgbox to enable a user-defined abort of logging (only for Optitrack_obj.recMethod 1)
%             if Optitrack_obj.recMethod==1;
%                 hmsgbox          = msgbox('Click Stop to abort OptiTrack data logging.','[itaOptitrack]');
%                 hmsgbox_button   = findobj(hmsgbox, 'style', 'pushbutton');
%                 set(hmsgbox_button, 'String', 'Stop');
%             end
            
            if Optitrack_obj.recMethod==1
                if Optitrack_obj.singleShot
                   Optitrack_obj.timerData = timer('TimerFcn',{@Optitrack_obj.TimerCallback},'ExecutionMode','singleShot'); % execute timer callback once
                else
                   Optitrack_obj.timerData = timer('TimerFcn',{@Optitrack_obj.TimerCallback},'Period',round(1/16/Optitrack_obj.frameRate*1000)/1000,'ExecutionMode','fixedSpacing','BusyMode','drop');
                end
            else
                Optitrack_obj.correctRowIdx = 1; % reset row counter
                if Optitrack_obj.singleShot
                   Optitrack_obj.timerData = timer('TimerFcn',{@Optitrack_obj.TimerCallback},'ExecutionMode','singleShot'); % execute timer callback once
                else
                   Optitrack_obj.timerData = timer('TimerFcn',{@Optitrack_obj.TimerCallback},'Period',round(1/16/Optitrack_obj.frameRate*1000)/1000,...
                        'ExecutionMode','fixedSpacing','BusyMode','drop','TasksToExecute',32*Optitrack_obj.numFrames); % execute timer 16*Optitrack_obj.numFrames times but abort as soon as Optitrack_obj.rigidBodyLogData.data is filled
                end
            end
            
            try %#ok<TRYNC>
                % suppress timer accuracy warning
                w  = warning('query','last');
                id = w.identifier;
                warning('off',id)
            end
            
            if ~Optitrack_obj.loggingState
                % change logging state
                Optitrack_obj.loggingState = Optitrack_obj.logging;
                
                % start Matlab timer
                start(Optitrack_obj.timerData);
                
%                 if Optitrack_obj.recMethod==1
%                     % wait until msgbox is closed
%                     uiwait(hmsgbox);
%                     
%                     % stop tracker data logging
%                     stopLogging(Optitrack_obj)
%                 end
            else
                fprintf('[itaOptitrack] Logging of tracker data is already running...\n')
            end
            
            else
                fprintf('[\b[itaOptitrack] Logging cannot be started as there is no connection to an OptiTrack server.]\b\n')
            end
            
        end
        
        function stopLogging(Optitrack_obj)
            %% stop data logging
            
            if Optitrack_obj.isConnected

                if Optitrack_obj.loggingState

                    % stop Matlab timer
                    stop(Optitrack_obj.timerData);
                    Optitrack_obj.loggingState = Optitrack_obj.stopped;

                    % delete all existing timers
                    delete(Optitrack_obj.timerData)

                    if Optitrack_obj.singleShot
                        % delete rows in rigidBodyLogData containing NaN's in
                        % 'singleShot' measurment, TODO: find real reason for
                        % logging 2 frames instead of 1
                        Optitrack_obj.rigidBodyLogData.data(isnan(Optitrack_obj.rigidBodyLogData.data(:,1)),:,:) = [];
                        Optitrack_obj.rigidBodyLogData.droppedFrames = [];
                    end

                    % display info about tracked data (if some data was logged)
                    if ~isempty(Optitrack_obj.rigidBodyLogData.data)
                        if ~isempty(Optitrack_obj.rigidBodyLogData.droppedFrames)
                            fprintf('[itaOptitrack] Stopped logging of tracker data.\n')
                            fprintf('[itaOptitrack] Finished logging of %d frames incl. %d dropped frames @ %s Hz (%.3f seconds).\n',...
                                numel(Optitrack_obj.rigidBodyLogData.data(:,1)), numel(Optitrack_obj.rigidBodyLogData.droppedFrames(:,1)), ...
                                num2str(Optitrack_obj.frameRate), (numel(Optitrack_obj.rigidBodyLogData.data(:,1)))/Optitrack_obj.frameRate);
                            fprintf('[itaOptitrack] Inspect Optitrack_obj.data.droppedFramedID/.droppedFramedTime for additional info.\n')
                            fprintf('[itaOptitrack] Missing data points in Optitrack_obj.data are interpolated.\n')
                        else
                            if Optitrack_obj.singleShot
                                fprintf('[itaOptitrack] Stopped logging of tracker data.\n')
                                fprintf('[itaOptitrack] Finished logging of %d frame @ %s Hz (%.3f seconds).\n',...
                                    numel(Optitrack_obj.rigidBodyLogData.data(:,1)), num2str(Optitrack_obj.frameRate), ...
                                    numel(Optitrack_obj.rigidBodyLogData.data(:,1))/Optitrack_obj.frameRate);
                            else
                                fprintf('[itaOptitrack] Stopped logging of tracker data.\n')
                                fprintf('[itaOptitrack] Finished logging of %d frames @ %s Hz (%.3f seconds).\n',...
                                    numel(Optitrack_obj.rigidBodyLogData.data(:,1)), num2str(Optitrack_obj.frameRate), ...
                                    (numel(Optitrack_obj.rigidBodyLogData.data(:,1))+numel(Optitrack_obj.rigidBodyLogData.droppedFrames(:,1)))/Optitrack_obj.frameRate);
                            end
                        end

                        if Optitrack_obj.recMethod == 0 && ~isempty(Optitrack_obj.rigidBodyLogData.droppedFrames)
                           % delete NaN entries
                           Optitrack_obj.rigidBodyLogData.data(isnan(Optitrack_obj.rigidBodyLogData.data(:,1)),:,:) = [];
                        end

                        % create NaN entries
                        if ~Optitrack_obj.singleShot && ~isempty(Optitrack_obj.rigidBodyLogData.droppedFrames)
                           tempNaN = NaN(numel(Optitrack_obj.rigidBodyLogData.data(:,1,1))+numel((Optitrack_obj.rigidBodyLogData.droppedFrames(:,1))),13,Optitrack_obj.numRigidBodies);
                           tempNaN(1:numel(Optitrack_obj.rigidBodyLogData.data(:,1,1)),:,:) = Optitrack_obj.rigidBodyLogData.data;
                           tempNaN(numel(Optitrack_obj.rigidBodyLogData.data(:,1,1))+1:end,1:2,:) = repmat([Optitrack_obj.rigidBodyLogData.droppedFrames(:,1), Optitrack_obj.rigidBodyLogData.droppedFrames(:,2)],1,1,Optitrack_obj.numRigidBodies);
                           Optitrack_obj.rigidBodyLogData.data = NaN(size(tempNaN));
                           for idx=1:Optitrack_obj.numRigidBodies % TODO: implement without for loop
                               Optitrack_obj.rigidBodyLogData.data(:,:,idx) = sortrows(tempNaN(:,:,idx),1);
                           end
                        end

                        if all(diff(Optitrack_obj.rigidBodyLogData.data(:,1,1)))==0 % grid vectors are not monotonically increasing
                           % duplicate frames have been written (strange: needs further investigation)
                           % quick fix: erase duplicate frames and append NaN frames at the end
                           % TODO: find real reason

                           kickout = diff(Optitrack_obj.rigidBodyLogData.data(:,1,1))==0;

                           Optitrack_obj.rigidBodyLogData.data(kickout,:,:) = [];
                           Optitrack_obj.rigidBodyLogData.data = [Optitrack_obj.rigidBodyLogData.data; NaN(sum(kickout),13,Optitrack_obj.numRigidBodies)];
                           Optitrack_obj.rigidBodyLogData.data(end-sum(kickout)+1:end,1,:) = repmat(Optitrack_obj.rigidBodyLogData.data(end-sum(kickout),1,:),sum(kickout),1,1) + ...
                               reshape(repmat((1:sum(kickout))',1,Optitrack_obj.numRigidBodies),[sum(kickout)',1,Optitrack_obj.numRigidBodies]);
                           Optitrack_obj.rigidBodyLogData.data(end-sum(kickout)+1:end,2,:) = repmat(Optitrack_obj.rigidBodyLogData.data(end-sum(kickout),2,:),sum(kickout),1,1) + ...
                               reshape(repmat((1:sum(kickout))',1,Optitrack_obj.numRigidBodies),[sum(kickout)',1,Optitrack_obj.numRigidBodies]).*1/Optitrack_obj.frameRate;
                        end

                        % create final data struct
                        for idx = 1:Optitrack_obj.numRigidBodies %TODO: implement without for loop
                            if idx==1
                                tmpNatNetVersion                        = num2str(int32(Optitrack_obj.theClient.NatNetVersion));
                                Optitrack_obj.info.NatNetVersion        = strrep(tmpNatNetVersion, '   ', '.');
                                Optitrack_obj.info.TakeName             = Optitrack_obj.saveName;
                                Optitrack_obj.info.CaptureFrameRate     = Optitrack_obj.frameRate;
                                Optitrack_obj.info.TotalFrames          = numel(Optitrack_obj.rigidBodyLogData.data(:,1,1));
                                Optitrack_obj.info.LengthUnits          = 'Meters'; % TODO: query somehow if possible?
                                Optitrack_obj.info.CoordinateSpace      = 'Global'; % TODO: query somehow if possible?

                                dataDescriptions = Optitrack_obj.theClient.GetDataDescriptions();
                            end

                            descriptor = dataDescriptions.Item(idx-1);

                            Optitrack_obj.data(idx).frameID     = Optitrack_obj.rigidBodyLogData.data(:,1,idx);
                            Optitrack_obj.data(idx).frameTime   = Optitrack_obj.rigidBodyLogData.data(:,2,idx);
                            Optitrack_obj.data(idx).rigidBodyID = Optitrack_obj.rigidBodyLogData.data(1,3,idx);
                            Optitrack_obj.data(idx).rigidBodyName = char(descriptor.Name);

                            % interpolate missing data points using PCHIP interpolation
                            if ~isempty(Optitrack_obj.rigidBodyLogData.droppedFrames)
                                try
                                    Optitrack_obj.data(idx).position    = itaCoordinates( interp1(Optitrack_obj.data(idx).frameID(~isnan(Optitrack_obj.rigidBodyLogData.data(:,4,idx))), ...
                                                                                          Optitrack_obj.rigidBodyLogData.data(~isnan(Optitrack_obj.rigidBodyLogData.data(:,4,idx)),4:6,idx), ...
                                                                                          Optitrack_obj.data(idx).frameID, 'pchip') );
                                    %                                 
                                    Optitrack_obj.data(idx).orientation = itaOrientation( interp1(Optitrack_obj.data(idx).frameID(~isnan(Optitrack_obj.rigidBodyLogData.data(:,4,idx))),...
                                                                                         Optitrack_obj.rigidBodyLogData.data(~isnan(Optitrack_obj.rigidBodyLogData.data(:,4,idx)),7:10,idx), ...
                                                                                          Optitrack_obj.data(idx).frameID, 'pchip') );
                                catch e
                                    %disp( e )
                                end

                            else
                                Optitrack_obj.data(idx).position    = itaCoordinates( Optitrack_obj.rigidBodyLogData.data(:,4:6,idx) );
                                Optitrack_obj.data(idx).orientation = itaOrientation( Optitrack_obj.rigidBodyLogData.data(:,7:10,idx) );
                            end

                            % apply calibration data on first rigid body
                            if Optitrack_obj.data(idx).rigidBodyID == 1
                                if ~isempty(Optitrack_obj.useCalibration) && Optitrack_obj.useCalibration && Optitrack_obj.isCalibrated
                                    % get relative orientation change of head-mounted rigid body since calibration procedure by quaternion inversion
                                    oriChange =  Optitrack_obj.dataCalibration.head.orientation.quat.^-1 * Optitrack_obj.data(idx).orientation.quat;

                                    newOff = oriChange.RotateVector( Optitrack_obj.dataCalibration.headToEarAxisCenter.position.cart );

                                    % apply offset vector on position data of rigid body 1
                                    Optitrack_obj.data(idx).position.cart = Optitrack_obj.data(idx).position.cart + newOff';  
                                    Optitrack_obj.rigidBodyLogData.info.calibratedData = true;                                              
                                else
                                    Optitrack_obj.rigidBodyLogData.info.calibratedData = false;
                                end
                            end
                            
                            % apply calibration rod translation offset measRodOffset on rigid body called 'MeasRod'
                            if Optitrack_obj.applyMeasRodOffset
                                if strcmp(Optitrack_obj.data(idx).rigidBodyName, 'MeasRod')                            
                                    Optitrack_obj.data(idx).position.cart = Optitrack_obj.data(idx).position.cart + Optitrack_obj.measRodOffset*(-Optitrack_obj.data(idx).orientation.up);
                                end
                            end

                            % interpolate mean error
                            if ~isempty(Optitrack_obj.rigidBodyLogData.droppedFrames)
                                try
                                    % TODO: Use quaternion interpolation instead of PCHIP
                                    Optitrack_obj.data(idx).meanError   = interp1(1:sum(~isnan(Optitrack_obj.rigidBodyLogData.data(:,11,idx))),...
                                    Optitrack_obj.rigidBodyLogData.data(~isnan(Optitrack_obj.rigidBodyLogData.data(:,11,idx)),11,idx),1:Optitrack_obj.info.TotalFrames,'PCHIP');
                                catch e
                                end
                            else
                                Optitrack_obj.data(idx).meanError   = Optitrack_obj.rigidBodyLogData.data(:,11,idx);
                            end

                            Optitrack_obj.data(idx).isTracked   = Optitrack_obj.rigidBodyLogData.data(:,12,idx);
                            if Optitrack_obj.singleShot % check if frame was tracked during single shot measurement
                                if ~Optitrack_obj.data(idx).isTracked && Optitrack_obj.singleShot
                                    fprintf('[\b[itaOptitrack] Single shot frame of marker set ''%s'' was not tracked and potentially contains useless data.]\b\n',Optitrack_obj.data(idx).rigidBodyName);
                                end
                            end
                            Optitrack_obj.data(idx).nMarkers    = Optitrack_obj.rigidBodyLogData.data(:,13,idx);

                            if ~isempty(Optitrack_obj.rigidBodyLogData.droppedFrames)
                                Optitrack_obj.data(idx).isTracked(isnan(Optitrack_obj.data(idx).isTracked)) = false; % mark dropped frames as not tracked
                                Optitrack_obj.data(idx).nMarkers(isnan(Optitrack_obj.data(idx).nMarkers)) = 0;       % zero markers had been available because frame was dropped / "not tracked"
                                Optitrack_obj.data(idx).droppedFrameID   = Optitrack_obj.rigidBodyLogData.droppedFrames(:,1);
                                Optitrack_obj.data(idx).droppedFrameTime = Optitrack_obj.rigidBodyLogData.droppedFrames(:,2);
                            end

                            if Optitrack_obj.data(idx).rigidBodyID == 1 % set calibratedData flag
                                Optitrack_obj.data(idx).calibratedData = Optitrack_obj.rigidBodyLogData.info.calibratedData;
                            else
                                Optitrack_obj.data(idx).calibratedData = false;
                            end
                        end

                        % save data and info
                        if Optitrack_obj.autoSave % == true
                            if isempty(Optitrack_obj.savePath)
                                Optitrack_obj.savePath = pwd;
                            end
                            if isempty(Optitrack_obj.saveName)
                                timeStamp = Optitrack_obj.info.CaptureStartTime;
                                Optitrack_obj.saveName = sprintf('trackerData_%s%s%s_%s%s%s', ...
                                                        timeStamp(1:2),timeStamp(4:6),timeStamp(8:11), ...
                                                        timeStamp(13:14), timeStamp(16:17), timeStamp(19:20));
                            end
                            
                            LogData = Optitrack_obj.data; %#ok
                            LogInfo = Optitrack_obj.info; %#ok
                            save(fullfile(Optitrack_obj.savePath,[Optitrack_obj.saveName,'.mat']), 'LogData','LogInfo');
                            fprintf('[itaOptitrack] Saved logged tracking data successfully to %s\n\n',fullfile(Optitrack_obj.savePath,[Optitrack_obj.saveName,'.mat']))
                        
                        else
                            fprintf('[\b[itaOptitrack] Logged tracking data is only stored temporarily in Optitrack_obj.data]\b\n\n')
                        end
                        
                    else
                        fprintf('[itaOptitrack] Stopped logging of tracker data.\n')
                    end
                    
                else
                    fprintf('[itaOptitrack] Logging of tracker data has already been stopped.\n')
                end
                
            else
                fprintf('[\b[itaOptitrack] Logging cannot be stopped as there is no connection to an OptiTrack server.]\b\n')
            end
        end
     
%         function decodeMotiveLogFile(Optitrack_obj,varargin)successfully
%             %% decode a Motive Log File (MLF), i.e. exported tracking data from Optitrack's software Motive
%             
%             % parse input arguments
%             sArgs               = struct('pathMLF',[],'nameMLF',[],'savePathMLF',[],'saveNameMLF',[],...
%                 'numRigidBodiesMLF',1,'numMarkersPerRigidBodyMLF',3);
%             sArgs               = ita_parse_arguments(sArgs,varargin);
%             
%             Optitrack_obj.pathMLF                = sArgs.pathMLF;               % path to MLF w/o name of file
%             Optitrack_obj.nameMLF                = sArgs.nameMLF;               % name of MLF including '.csv'
%             Optitrack_obj.savePathMLF            = sArgs.savePathMLF;           % path to save MLF as .mat file
%             Optitrack_obj.saveNameMLF            = sArgs.saveNameMLF;           % name of saved .mat file (w/o .mat)
%             Optitrack_obj.numRigidBodiesMLF      = sArgs.numRigidBodiesMLF;     % number of tracked rigid bodies in MLF, default: 1
%             Optitrack_obj.numMarkersPerRigidBodyMLF   = sArgs.numMarkersPerRigidBodyMLF;  % number of markers used for each body in MLF, vector for different amount of markers per body allowed, default: 3
%             
%             % create structure for MotionOptiTrackLogFile_info
%             Optitrack_obj.rigidBodyLogDataMLF.info = struct('FormatVersion',[],'TakeName',[],...
%                 'CaptureFrameRate',[],'ExportFrameRate',[],'CaptureStartTime',[],...
%                 'TotalFrames',[],'RotationType',[],'LengthUnits',[],'CoordinateSpace',[]);
%             
%             % open and scan log file
%             fid = fopen(fullfile(Optitrack_obj.pathMLF ,Optitrack_obj.nameMLF),'r');
%             C = textscan(fid, repmat('%s',1,18), 'delimiter',',');%, 'CollectOutput',true);
%             
%             % fill up Optitrack_obj.rigidBodyLogDataMLF.info (includes addional information about the tracking data)
%             Optitrack_obj.infoMLF.FormatVersion        = C{2}{1};
%             Optitrack_obj.infoMLF.TakeName             = C{4}{1};
%             Optitrack_obj.infoMLF.CaptureFrameRate     = C{6}{1};
%             Optitrack_obj.infoMLF.ExportFrameRate      = C{8}{1};
%             Optitrack_obj.infoMLF.CaptureStartTime     = C{10}{1};
%             Optitrack_obj.infoMLF.TotalFrames          = C{12}{1};
%             Optitrack_obj.infoMLF.RotationType         = C{14}{1};
%             Optitrack_obj.infoMLF.LengthUnits          = C{16}{1};
%             Optitrack_obj.infoMLF.CoordinateSpace      = C{18}{1};
%             
%             fclose(fid);
%             
%             % fill up Optitrack_obj.rigidBodyLogDataMLF.data
%             rowoffset = 7; % reading starts at rowoffset+1
%             Optitrack_obj.rigidBodyLogDataMLF.data = csvread(fullfile(Optitrack_obj.pathMLF,Optitrack_obj.nameMLF),rowoffset);
%             
%             % read relevant data based on numRigidBodies and numMarkerPerBody
%             Optitrack_obj.rigidBodyLogDataMLF.data = Optitrack_obj.rigidBodyLogDataMLF.data(:,[1:2,3:(Optitrack_obj.numRigidBodiesMLF*10+sum(Optitrack_obj.numMarkersPerRigidBodyMLF)*4)]);
%                         
%             % some idx calculations
%             idx_source  = 3:6;
%             idx_source  = repmat(idx_source,1,Optitrack_obj.numRigidBodiesMLF);
%             gapsize_source = 7 + 4*Optitrack_obj.numMarkersPerRigidBodyMLF(1:end-1)*(Optitrack_obj.numRigidBodiesMLF-1)+1;
%             gapsize_source = sort([zeros(1,4), repmat(gapsize_source,Optitrack_obj.numRigidBodiesMLF-1,4)]);
%             idx_source  = idx_source+gapsize_source;
%             
%             idx_target  = 3:5;
%             idx_target  = repmat(idx_target,1,Optitrack_obj.numRigidBodiesMLF);
%             gapsize_target = 7 + 4*Optitrack_obj.numMarkersPerRigidBodyMLF(1:end-1)*(Optitrack_obj.numRigidBodiesMLF-1);
%             gapsize_target = sort([zeros(1,3), repmat(gapsize_target,Optitrack_obj.numRigidBodiesMLF-1,3)]);
%             idx_target  = idx_target+gapsize_target;
%             
%             if Optitrack_obj.numRigidBodiesMLF>1
%                 % some permutations and reshapes
%                 tempDecodedRigidBodyData = permute(Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_source),[2,1]);
%                 tempDecodedRigidBodyData = (reshape(tempDecodedRigidBodyData,[4,Optitrack_obj.numRigidBodiesMLF*size(Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_source),1)]))';
%                 tempDecodedRigidBodyData = [tempDecodedRigidBodyData(:,1), tempDecodedRigidBodyData(:,2), tempDecodedRigidBodyData(:,3), tempDecodedRigidBodyData(:,4)];
%                 
%                 % write converted data into Optitrack_obj.rigidBodyLogDataMLF.data
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(1:3:end)) = tempDecodedRigidBodyData(:,1:3:end);
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(2:3:end)) = tempDecodedRigidBodyData(:,2:3:end);
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(3:3:end)) = tempDecodedRigidBodyData(:,3:3:end);
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(4:3:end)) = tempDecodedRigidBodyData(:,4:3:end);
%                 
%             else
%                 qOrig = [ Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_source(1)), Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_source(2)),...
%                     Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_source(3)), Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_source(4)) ];
%                 
%                 % write converted data into Optitrack_obj.rigidBodyLogDataMLF.data
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(1:3:end)) = tempDecodedRigidBodyData(:,1:3:end);
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(2:3:end)) = tempDecodedRigidBodyData(:,2:3:end);
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(3:3:end)) = tempDecodedRigidBodyData(:,3:3:end);
%                 Optitrack_obj.rigidBodyLogDataMLF.data(:,idx_target(4:3:end)) = tempDecodedRigidBodyData(:,4:3:end);
%                 
%             end
%             
%             Optitrack_obj.data(idx).frameID     = Optitrack_obj.rigidBodyLogData.data(:,1,idx);
%             Optitrack_obj.data(idx).frameID(isnan(Optitrack_obj.data(idx).frameID)) = Optitrack_obj.rigidBodyLogData.droppedFrames(:,1);
%             Optitrack_obj.data(idx).frameTime   = Optitrack_obj.rigidBodyLogData.data(:,2,idx);
%             Optitrack_obj.data(idx).frameTime(isnan(Optitrack_obj.data(idx).frameTime)) = Optitrack_obj.rigidBodyLogData.droppedFrames(:,2);
%             Optitrack_obj.data(idx).rigidBodyID = Optitrack_obj.rigidBodyLogData.data(1,3,idx);
%             Optitrack_obj.data(idx).rigidBodyName = char(descriptor.Name);
%             Optitrack_obj.data(idx).position    = itaCoordinates( Optitrack_obj.rigidBodyLogData.data(:,4:6,idx) );
%             Optitrack_obj.data(idx).orientation = itaOrientation( Optitrack_obj.rigidBodyLogData.data(:,7:10,idx) );
%             
%             % apply calibration data on first rigid body
%             if idx==1
%                 if Optitrack_obj.useCalibration
%                     Optitrack_obj.data(idx).position.cart = Optitrack_obj.data(idx).position.cart + ...
%                         norm(Optitrack_obj.dataCalibration.headToEarAxisCenter.cart) * -Optitrack_obj.data(idx).orientation.up;
%                     Optitrack_obj.rigidBodyLogData.info.calibratedData = true;
%                 else
%                     Optitrack_obj.rigidBodyLogData.info.calibratedData = false;
%                 end
%             end
%             
%             Optitrack_obj.data(idx).meanError   = Optitrack_obj.rigidBodyLogData.data(:,11,idx);
%             Optitrack_obj.data(idx).isTracked   = Optitrack_obj.rigidBodyLogData.data(:,12,idx);
%             Optitrack_obj.data(idx).nMarkers    = Optitrack_obj.rigidBodyLogData.data(:,13,idx);
%             Optitrack_obj.data(idx).droppedFrameID   = Optitrack_obj.rigidBodyLogData.droppedFrames(:,1);
%             Optitrack_obj.data(idx).droppedFrameTime = Optitrack_obj.rigidBodyLogData.droppedFrames(:,2);
%             
%             fprintf('[itaOptitrack] Decoding of MLF -> mat was successful!\n')
%             
%             % store data in savePath if selected
%             if ~isempty(Optitrack_obj.savePathMLF) && ~isempty(Optitrack_obj.saveNameMLF)
%                 if ~exist(Optitrack_obj.savePathMLF,'dir')
%                     mkdir(Optitrack_obj.savePathMLF);
%                 end
%                 rigidBodyLogDataMLF = Optitrack_obj.rigidBodyLogDataMLF; %#ok<NASGU,PROP>
%                 save(fullfile(Optitrack_obj.savePathMLF,[Optitrack_obj.saveNameMLF,'.mat']), 'rigidBodyLogDataMLF');
%                 fprintf('[itaOptitrack] Saved decoded tracking data of MLF successfully to %s\n',fullfile(Optitrack_obj.savePathMLF,[Optitrack_obj.saveNameMLF]))
%             end
%         end
        
%%
        function calibrate(Optitrack_obj,varargin)
        % calculate offset of a head-mounted rigid body to the center of the interaural axis (procedure description: see above).

            if Optitrack_obj.isConnected
                
                if Optitrack_obj.numRigidBodies>3
                    fprintf('[\b[itaOptitrack.calibrate] More than three rigid bodies detected. First three will be selected for calibration procedure.]\b\n')
                end
                
                if Optitrack_obj.numRigidBodies<3
                    fprintf('[\b[itaOptitrack.calibrate] Calibration procedure needs three rigid bodies. Aborted.]\b\n')
                else
                    
                    % parse input arguments
                    sArgs = struct('useCalibration',Optitrack_obj.useCalibration,...
                        'savePathCalibration',Optitrack_obj.savePathCalibration,...
                        'saveNameCalibration',Optitrack_obj.saveNameCalibration,...
                        'calibPenOffset',Optitrack_obj.calibPenOffset,...
                        'countdownDuration',Optitrack_obj.countdownDuration);
                    sArgs = ita_parse_arguments(sArgs,varargin);
                    
                    Optitrack_obj.calibPenOffset      = sArgs.calibPenOffset;
                    Optitrack_obj.useCalibration      = sArgs.useCalibration;
                    Optitrack_obj.savePathCalibration = sArgs.savePathCalibration;
                    Optitrack_obj.saveNameCalibration = sArgs.saveNameCalibration;
                    Optitrack_obj.countdownDuration   = sArgs.countdownDuration;
                    
                    if isempty(Optitrack_obj.saveNameCalibration)
                        Optitrack_obj.saveNameCalibration = ['OptiTrackCalibration',...
                            datestr(now,'dd-mmmm-yyyy')];
                    end
                    
                    if ~Optitrack_obj.isCalibrated
                        
                        % message box for calibration with countdown
                        calmsgbox1          = msgbox(sprintf('Click ''Calibrate'' or wait till countdown has \nfinished to log the position of all rigid bodies.\n'),'[itaOptitrack]');
                        calmsgbox_button1   = findobj(calmsgbox1, 'style', 'pushbutton');
                        
                        temppos = get(calmsgbox1,'position');
                        xlength = 290;
                        ylength = 100;
                        set(calmsgbox1, 'position', [(temppos(1)+xlength)/2 (temppos(2)+ylength)/2 xlength ylength]); %makes box bigger
                        ah = get( calmsgbox1, 'CurrentAxes' );
                        ch = get( ah, 'Children' );
                        set( ch, 'FontSize', 15); %makes text bigger
                        
                        set(calmsgbox_button1, 'String', sprintf('Calibrate [%d]',Optitrack_obj.countdownDuration),'FontSize',15,'Position',[90,5,100,30]);
                        
                        timerDataCal=timer('executionmode','fixedrate','period',1,'timerfcn',{@Optitrack_obj.TimerCallbackCal,calmsgbox_button1},...
                            'ExecutionMode','fixedRate','BusyMode','queue','TasksToExecute',Optitrack_obj.countdownDuration);
                        
                        start(timerDataCal);
                        
                        % wait for user input
                        uiwait(calmsgbox1,Optitrack_obj.countdownDuration);
                        
                        % stop timer and clean up
                        stop(timerDataCal);
                        delete(timerDataCal);
                        if ishandle(calmsgbox1)
                            close(calmsgbox1);
                        end
                        
                        % run a singleShot measurement
                        startLogging(Optitrack_obj,'singleShot',1);
                        
                        % get info about singleShot measurement
                        Optitrack_obj.infoCalibration = Optitrack_obj.info;
                        for index = 1:Optitrack_obj.numRigidBodies
                           trackedData(index) =  Optitrack_obj.data(index).isTracked;
                        end
                        Optitrack_obj.infoCalibration.isTracked = trackedData;
                        if ~isempty(Optitrack_obj.savePathCalibration)&&~isempty(Optitrack_obj.saveNameCalibration)
                            Optitrack_obj.infoCalibration.TakeName = fullfile(Optitrack_obj.savePathCalibration,Optitrack_obj.saveNameCalibration);
                        end
                        
                        % calculate offset
                        Optitrack_obj.dataCalibration.head.position    = itaCoordinates( Optitrack_obj.rigidBodyLogData.data(1,4:6,1) );
                        Optitrack_obj.dataCalibration.head.orientation = itaOrientation( Optitrack_obj.rigidBodyLogData.data(1,7:10,1) );
                        % integrate offset of calibration pen, i.e. vector norm in meters measured from the volume center point 
                        %        of the calibration pen's marker set to the tip of the calibration pen
                        leftPenTip.orientation = itaOrientation( Optitrack_obj.rigidBodyLogData.data(1,7:10,2) );
                        leftPenTip.position    = itaCoordinates( Optitrack_obj.rigidBodyLogData.data(1,4:6,2) );
                        leftPenTip.position.cart = leftPenTip.position.cart + Optitrack_obj.calibPenOffset*(-leftPenTip.orientation.up);
                        Optitrack_obj.dataCalibration.leftPenTip.position    = leftPenTip.position;
                        Optitrack_obj.dataCalibration.leftPenTip.orientation = leftPenTip.orientation;
                 
                        rightPenTip.orientation = itaOrientation( Optitrack_obj.rigidBodyLogData.data(1,7:10,3) );
                        rightPenTip.position      = itaCoordinates( Optitrack_obj.rigidBodyLogData.data(1,4:6,3) );
                        rightPenTip.position.cart = rightPenTip.position.cart + Optitrack_obj.calibPenOffset*(-rightPenTip.orientation.up);
                        Optitrack_obj.dataCalibration.rightPenTip.position    = rightPenTip.position;
                        Optitrack_obj.dataCalibration.rightPenTip.orientation = rightPenTip.orientation;
                        
                        Optitrack_obj.dataCalibration.headToLeftPenTip  = Optitrack_obj.dataCalibration.leftPenTip.position  - Optitrack_obj.dataCalibration.head.position;
                        Optitrack_obj.dataCalibration.headToRightPenTip = Optitrack_obj.dataCalibration.rightPenTip.position - Optitrack_obj.dataCalibration.head.position;
                        headToEarAxisCenter = 0.5 * (Optitrack_obj.dataCalibration.headToLeftPenTip.cart + Optitrack_obj.dataCalibration.headToRightPenTip.cart);
                        Optitrack_obj.dataCalibration.headToEarAxisCenter.position = itaCoordinates(headToEarAxisCenter);
                        
                        % ask user if calibration data should be applied (if Optitrack_obj.useCalibration is not already set to true)
                        if isempty(Optitrack_obj.useCalibration)
                            calmsgbox2 = questdlg('Would you like to apply calibration data in following measurements?','[itaOptitrack]','Yes','No','No');
                            
                            if strcmp(calmsgbox2,'Yes')
                                Optitrack_obj.useCalibration = true;
                                fprintf('[\b[itaOptitrack.calibrate] Calibration data will be applied on tracking data of following measurements.]\b\n')
                            else
                                Optitrack_obj.useCalibration = false;
                                fprintf('[\b[itaOptitrack.calibrate] Calibration data will be ignored in following measurements.]\b\n')
                            end
                            
                        elseif Optitrack_obj.useCalibration
                            % Optitrack_obj.useCalibration is already set to true
                            fprintf('[\b[itaOptitrack.calibrate] Calibration data will be applied on tracking data in following measurements.]\b\n')
                        end
                        
                        Optitrack_obj.isCalibrated = true;
                        
                        % optionally save calibration data + info
                        if ~isempty(Optitrack_obj.savePathCalibration)&&~isempty(Optitrack_obj.saveNameCalibration)
                            calibrationData = Optitrack_obj.dataCalibration; %#ok<NASGU>
                            calibrationInfo = Optitrack_obj.infoCalibration; %#ok<NASGU>
                            save(fullfile(Optitrack_obj.savePathCalibration,[Optitrack_obj.saveNameCalibration,'.mat']), 'calibrationData', 'calibrationInfo');
                            fprintf('[itaOptitrack.calibrate] Saved calibration data successfully to %s\n',fullfile(Optitrack_obj.savePathCalibration,[Optitrack_obj.saveNameCalibration,'.mat']))
                        else
                            fprintf('[\b[itaOptitrack.calibrate] Calibration data is only stored temporarily in Optitrack_obj.dataCalibration.]\b\n')
                        end
                        
                    else
                        % Optitrack_obj.calibrationData already contains calibration data
                        calmsgbox2 = questdlg('Optitrack_obj.calibrationData already contains calibration data? Would you still do a calibration?','[itaOptitrack]','Yes','No','No');
                        if strcmp(calmsgbox2,'Yes')
                            fprintf('[\b[itaOptitrack.calibrate] Old calibration data will be overwritten.]\b\n')
                            Optitrack_obj.isCalibrated = false;
                            calibrate(Optitrack_obj);
                        else
                            fprintf('[itaOptitrack.calibrate] Calibration process aborted by user.\n')
                        end
                        
                    end
                end
                
            else
                fprintf('[\b[itaOptitrack.calibrate] Calibration process cannot be started as there is no connection to an OptiTrack server.]\b\n')
            end
            
        end

        %%
        function loadCalibration(Optitrack_obj,varargin)
        % Load calibration data saved during .calibrate. Calibration data will be automatically applied 
        % on logged data of following measurements.            
        
        if Optitrack_obj.isCalibrated
            % Optitrack_obj.calibrationData already contains calibration data
            calmsgbox = questdlg('Optitrack_obj.calibrationData already contains calibration data? Would you still load a calibration?','[itaOptitrack]','Yes','No','No');
            
            if strcmp(calmsgbox,'Yes')
                fprintf('[\b[itaOptitrack.loadCalibration] Old calibration data will be overwritten.]\b\n')
            else
                fprintf('[itaOptitrack.loadCalibration] Process aborted by user.\n')
                return
            end          
        end
        
        % parse input arguments
        sArgs = struct('loadPathCalibration',Optitrack_obj.savePathCalibration,...
            'loadNameCalibration',Optitrack_obj.saveNameCalibration);
        sArgs = ita_parse_arguments(sArgs,varargin);
        
        if isempty(sArgs.loadPathCalibration) || isempty(sArgs.loadNameCalibration)
            error('[itaOptitrack.loadCalibration] No path or file name given. Aborted.')
        end
        
        Optitrack_obj.loadPathCalibration = sArgs.loadPathCalibration;
        Optitrack_obj.loadNameCalibration = sArgs.loadNameCalibration;
        
        try
            tmp = load(fullfile(Optitrack_obj.loadPathCalibration,...
            Optitrack_obj.loadNameCalibration));
            
            Optitrack_obj.dataCalibration = tmp.calibrationData;
            Optitrack_obj.infoCalibration = tmp.calibrationInfo;
            
            fprintf('[itaOptitrack.loadCalibration] Successfully loaded calibration data.\n')
            
            % use dataCalibration in following measurements
            Optitrack_obj.useCalibration  = true;
            fprintf('[\b[itaOptitrack.loadCalibration] Calibration data will be applied on tracking data in following measurements.]\b\n\n')
            Optitrack_obj.isCalibrated    = true;
            
        catch
            error('[itaOptitrack.loadCalibration] Unable to load calibration data using given path or file name. Aborted.')
        end

        end
        
    end
    
    %% Hidden methods
    methods(Hidden=true, Access=private)
        
        %% process data in a Matlab Timer callback
        % TimerCallback(Optitrack_obj, timerobj, event)
        function TimerCallback(varargin)
            
            Optitrack_obj = varargin{1};
        
            latestData           = Optitrack_obj.theClient.GetLastFrameOfData();
            frameTime            = latestData.fLatency;
            frameID              = latestData.iFrame;
            
            % first execution
            if Optitrack_obj.recMethod==1
                if isempty(Optitrack_obj.rigidBodyLogData.data)
                    %                 disp(timerobj.TasksExecuted)
                    Optitrack_obj.lastFrameID   = frameID-1;
                    Optitrack_obj.lastFrameTime = frameTime-1/Optitrack_obj.frameRate;
                end
            else
                if isnan(Optitrack_obj.rigidBodyLogData.data(1))
                    %                 disp(timerobj.TasksExecuted)
                    Optitrack_obj.lastFrameID   = frameID-1;
                    Optitrack_obj.lastFrameTime = frameTime-1/Optitrack_obj.frameRate;
                end
            end
            
            % display info about dropped or duplicate frames
            if(frameID ~= Optitrack_obj.lastFrameID) || Optitrack_obj.singleShot 
                if (frameID - Optitrack_obj.lastFrameID)==2
                    if Optitrack_obj.debugInfo
                        fprintf('[\b[itaOptitrack] Dropped frame! FrameID: %5d\tFrameTime: %0.3f]\b\n', frameID, frameTime);
%                     else
%                         fprintf('[\b[itaOptitrack] Dropped frame!]\b\n')
                    end
                    Optitrack_obj.rigidBodyLogData.droppedFrames = [Optitrack_obj.rigidBodyLogData.droppedFrames; double(frameID-1), Optitrack_obj.lastFrameTime+1/Optitrack_obj.frameRate];
                elseif (frameID - Optitrack_obj.lastFrameID)>2
                    if Optitrack_obj.debugInfo
                        fprintf('[\b[itaOptitrack] Multiple dropped frames! FrameID: %5d to %5d\tFrameTime: %0.3f to %0.3f]\b\n', Optitrack_obj.lastFrameID+1, frameID-1, ...
                            Optitrack_obj.lastFrameTime+1/Optitrack_obj.frameRate, frameTime-1/Optitrack_obj.frameRate:frameTime-1/Optitrack_obj.frameRate);
%                     else
%                         fprintf('[\b[itaOptitrack] Multiple dropped frames!]\b\n')
                    end
                    Optitrack_obj.rigidBodyLogData.droppedFrames = [Optitrack_obj.rigidBodyLogData.droppedFrames; double(Optitrack_obj.lastFrameID+1:frameID-1)', ...
                        ( double(frameTime)-(double(frameID) - double(Optitrack_obj.lastFrameID) - 1)/Optitrack_obj.frameRate:1/Optitrack_obj.frameRate:frameTime-1/Optitrack_obj.frameRate )'];
                end
                
                % decode NatNet frame data to get 6DoF tracking data
                Optitrack_obj.getData(latestData,frameID,frameTime);
                
                % store data in Optitrack_obj.rigidBodyLogData.data
                if Optitrack_obj.recMethod
                    Optitrack_obj.rigidBodyLogData.data  = [Optitrack_obj.rigidBodyLogData.data; Optitrack_obj.tempRigidBodyLogData];
                    if Optitrack_obj.singleShot
                       stopLogging(Optitrack_obj) 
                    end
                else
                    Optitrack_obj.rigidBodyLogData.data(Optitrack_obj.correctRowIdx,:,:) = Optitrack_obj.tempRigidBodyLogData;
                    Optitrack_obj.correctRowIdx = Optitrack_obj.correctRowIdx + 1;

                    if Optitrack_obj.correctRowIdx > (Optitrack_obj.numFrames-numel(Optitrack_obj.rigidBodyLogData.droppedFrames(:,1)))
                        stopLogging(Optitrack_obj)
                    end
                    
                end
                
            else
                if Optitrack_obj.debugInfo; fprintf('[itaOptitrack] Duplicate frame (will be ignored). FrameID: %5d\tFrameTime: %0.3f\n', frameID, frameTime); end
            end
            
            Optitrack_obj.lastFrameID   = frameID;
            Optitrack_obj.lastFrameTime = frameTime;

        end
        
        %% decode NatNet frame data for further usage in Matlab
        function getData(Optitrack_obj, data, frameID, frameTime)
            
            Optitrack_obj.tempRigidBodyLogData = nan(1,13,Optitrack_obj.numRigidBodies);
            
            for idx=1:data.nRigidBodies % TODO: quick and dirty solution with for loop, implement without for loop
                rigidBodyData = data.RigidBodies(idx);
                                
                % Rigid body position [X,Y,Z]
                X = double(rigidBodyData.x);
                Y = double(rigidBodyData.y);
                Z = double(rigidBodyData.z);
                
                % FrameID, FrameTime, RigidBodyID, X, Y, Z, quatX, quatY, quatZ, quatW, MeanError, Tracked, nMarkers, MarkerInfo
                Optitrack_obj.tempRigidBodyLogData(:,:,idx) = [double(frameID), double(frameTime), double(rigidBodyData.ID),...
                    X, Y, Z, rigidBodyData.qw, rigidBodyData.qx, rigidBodyData.qy, rigidBodyData.qz, double(rigidBodyData.MeanError),...
                    double(rigidBodyData.Tracked), double(rigidBodyData.nMarkers)]; 
            end
        end
        
        function TimerCallbackCal(varargin)
            
            Optitrack_obj    = varargin{1};
            numTasksExecuted = varargin{2}.TasksExecuted-1;
            pushButtonHandle = varargin{4};
            
            % update countdown in calibration msgbox
            set(pushButtonHandle, 'String', sprintf('Calibrate (%d)',Optitrack_obj.countdownDuration-numTasksExecuted));
        end
        
    end
    
end

