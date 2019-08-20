classdef itaComsolServer < handle
    %itaComsolServer Interface to start/stop and connect/disconnect
    %Comsol Server via Matlab LiveLink
    %   Also allows to remove comsol models from the server.
    %   
    %   Information on the server and LiveLink path are stored in an ini-file.
    %   This file is created the first time a connection is established.
    %   
    %   See also itaComsolModel
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolServer">doc itaComsolServer</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        iniFile;
        comsolIni = IniConfig();
        comsolServerExePath;
        matlabLiveLinkPath;
        isConnected = false;
    end
    
    properties(Constant = true, Access = private)
        iniSectionGlobal = 'Global';
        iniTagComsolServer = 'ComsolServerExe';
        iniTagMatlabLiveLink = 'MatlabLiveLinkPath';
        comsolServerExe = 'comsolmphserver.exe';
    end
    
    %% Constructor
    methods(Access = private)
        function obj = itaComsolServer()
            obj.init();
        end
    end
    methods(Static = true)
        function obj = Instance()
            %Returns the unique instance of this class
            persistent uniqueInstance;
            if isempty(uniqueInstance)
                uniqueInstance = itaComsolServer();
            end
            obj = uniqueInstance;
        end
    end
    
    %% Ini-File
    methods(Access = private)
        function init(obj)
            itaComsolPath = fileparts( fileparts( mfilename('fullpath') ) );
            obj.iniFile = fullfile(itaComsolPath, 'itaComsol.ini');
            
            if exist(obj.iniFile, 'file')
                obj.comsolIni.ReadFile(obj.iniFile);
                obj.comsolServerExePath = obj.comsolIni.GetValues(obj.iniSectionGlobal, obj.iniTagComsolServer, obj.comsolServerExePath);
                obj.matlabLiveLinkPath = obj.comsolIni.GetValues(obj.iniSectionGlobal, obj.iniTagMatlabLiveLink, obj.matlabLiveLinkPath);
            end
            
            if (~exist(obj.comsolServerExePath,'file'))
                disp(['[' class(obj) ']: No Comsol Server binary was found! Please select path to comsolmphserver.exe!']);
                obj.SelectComsolServerPath();                
            end
            if ~exist(obj.matlabLiveLinkPath,'dir')
                obj.matlabLiveLinkPath = fullfile(fileparts( fileparts( fileparts(obj.comsolServerExePath) ) ), 'mli');
                obj.writeIniFile();
                if ~exist(obj.matlabLiveLinkPath,'dir')
                    disp(['[' class(obj) ']: No Comsol Matlab Livelink folder was found! Please select path to the corresponding folder (usually called "mli")']);
                    obj.SelectMatlabLivelinkPath();
                end
            end
        end
        function writeIniFile(obj)
            if ~exist(obj.iniFile, 'file')
                obj.comsolIni.AddSections({obj.iniSectionGlobal});
                obj.comsolIni.AddKeys(obj.iniSectionGlobal, {obj.iniTagComsolServer}, {obj.comsolServerExePath});
                obj.comsolIni.AddKeys(obj.iniSectionGlobal, {obj.iniTagMatlabLiveLink}, {obj.matlabLiveLinkPath});
            else
                obj.comsolIni.SetValues(obj.iniSectionGlobal, {obj.iniTagComsolServer}, {obj.comsolServerExePath});
                obj.comsolIni.SetValues(obj.iniSectionGlobal, {obj.iniTagMatlabLiveLink}, {obj.matlabLiveLinkPath});
            end
            obj.comsolIni.WriteFile(obj.iniFile);
        end
    end
    
    methods
        function SelectComsolServerPath(obj)            
            [ selectedComsolExe, selectedComsolPath] = uigetfile('*.exe','No Comsol Server binary was found! Please select path to comsolmphserver.exe', 'C:\Program Files\COMSOL\comsolmphserver.exe');
            obj.comsolServerExePath = [ selectedComsolPath selectedComsolExe];
            if ~strcmp(selectedComsolExe, 'comsolmphserver.exe')
                warning('Executable for Comsol Server is usually called "comsolmphserver.exe". Did you select the correct file?')
            end
            obj.writeIniFile();
        end
        function SelectMatlabLivelinkPath(obj)
            liveLinkDir = uigetdir('C:\Program Files\COMSOL\', 'No Comsol Matlab Livelink folder was found! Please select path to the corresponding folder (mli)');
            obj.matlabLiveLinkPath = liveLinkDir;
            if ~contains(liveLinkDir, [filesep 'mli'])
                warning('Matlab Livelink folder is usually called "mli". Did you select the correct folder?')
            end
            obj.writeIniFile();
        end
    end
    
    %% LiveLink Connection
    methods
        function Connect(obj)
            %Establishes a Matlab Livelink connection to a Comsol Server.
            if isempty(obj.comsolServerExePath) || isempty(obj.matlabLiveLinkPath)
                obj.init();
            end
            
            if ispc() && ~obj.comsolServerIsRunning()
                obj.startComsolServer();
            end
            
            currentFolder = pwd;            
            try
                cd(obj.matlabLiveLinkPath);
                mphstart(2036);
            catch err
                cd(currentFolder);
                if ~strcmp(err.message, 'Already connected to a server')
                    rethrow(err);
                end
            end
            cd(currentFolder);
            obj.isConnected = true;
        end
        function Disconnect(obj)
            %Disconnects Matlab from the Comsol Server and shuts down the
            %server.
            if ~obj.isConnected; return; end
            if ispc() && ~obj.comsolServerIsRunning()
                warning('No Comsol Server to disconnect from')
                return;
            end
            com.comsol.model.util.ModelUtil.disconnect();
            obj.isConnected = false;
        end
    end
    methods(Access = private)
        function bool = comsolServerIsRunning(obj)            
            if ~ispc()
                error('This function is only defined for Windows platforms')
            end            
            [~,tasks] = system(['tasklist/fi "imagename eq ' obj.comsolServerExe '"']);
            bool = contains(tasks, obj.comsolServerExe);
        end
        function startComsolServer(obj)
            if ~ispc()
                error('This function is only defined for Windows platforms')
            end
            if obj.comsolServerIsRunning()
                warning('Comsol Server is already running.')
                return
            end
            
            startInfo = System.Diagnostics.ProcessStartInfo('cmd.exe', ...
                sprintf('/c "%s"', obj.comsolServerExePath));
            startInfo.UseShellExecute = false;
            proc = System.Diagnostics.Process.Start(startInfo);
            if isempty(proc)
                error('Failed to launch Comsol Server');
            end
        end
    end
    
    %% Remove Models from Server
    methods
        function RemoveModel(obj, model)
            %Removes the given comsol model from the server
            assert(isa(model, 'com.comsol.clientapi.impl.ModelClient'), 'Input must be a comsol model node')
            if ~obj.isConnected; return; end
            if ispc() && ~obj.comsolServerIsRunning()
                warning('No Comsol Server is active')
                return;
            end
            com.comsol.model.util.ModelUtil.remove(char(model.tag));
        end
    end
end

