classdef itaRavenProject < handle
    %RavenProject - The class for working with RAVEN.
    % This class allows you to create configurations of settings, to
    % run simulations and to retrieve the results.
    %
    % Using:
    %   rpf = itaRavenProject(raven_project_file)
    %
    % Public Properties:
    %   Enter this command to get the properties:
    %   >> properties itaRavenProject
    %
    % Public Methods:
    %   Enter this command to get the methods:
    %   >> methods itaRavenProject
    %
    %   Enter this command to get more info of method:
    %   >> help itaRavenProject/methodname
    %
    %
    %
    % Example:
    %   rpf = itaRavenProject();
    %   rpf.SetModel('cave.ac')
    %   rpf.run()
    %   rpf.getReverbTime()
    %
    %
    % Author:         Soenke Pelzer (spe@akustik.rwth-aachen.de)
	%				  Lukas Aspöck (las@akustik.rwth-aachen.de)
    % Version:        0.1
    % First release:  01.11.10
    % Last revision:  12.09.16
    % Copyright:      Institute of Technical Acoustics, RWTH Aachen University
    %

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties(Constant)
        
        % CONSTANTS
        freqLabel3rd = { '   20 Hz', '   25 Hz', '   31 Hz', '   40 Hz', '   50 Hz', '   63 Hz', '   80 Hz', '  100 Hz', '  125 Hz', '  160 Hz', '  200 Hz', ...
                                     '  250 Hz', '  315 Hz', '  400 Hz', '  500 Hz', '  630 Hz', '  800 Hz', '   1 kHz', '1.25 kHz', ' 1.6 kHz', '   2 kHz', ...
                                     ' 2.5 kHz', '3.15 kHz', '   4 kHz', '   5 kHz', ' 6.3 kHz', '   8 kHz', '  10 kHz', '12.5 kHz', '  16 kHz', '  20 kHz'};
        freqLabelOct = { '   31 Hz', '   63 Hz', '  125 Hz', '  250 Hz', '  500 Hz', '   1 kHz', '   2 kHz', '   4 kHz', '   8 kHz', '  16 kHz'};        
        freqVector3rd = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
        freqVectorOct = [31.5 63 125 250 500 1000 2000 4000 8000 16000];
        MODE_BSP   = 0;
        MODE_HASH  = 1;
        MODE_BRUTE = 2;
        COORD_TRAFO_SKETCHUP2RAVEN = [1 3 -2];
        COORD_TRAFO_RAVEN2SKETCHUP = [1 -3 2];
     end
    
    properties (GetAccess = 'public', SetAccess = 'private')
        % raven

        ravenExe
        ravenLogFile = 'RavenLog.txt'
        ravenProjectFile
        ravenIniFile
        projectName
        
        % general
        sampleRate = 44100
        
        % paths
        pathResults
        pathDirectivities
        pathMaterials
        fileHRTF
        fileSpeakers
        
        % model
        modelFileList = []
        model = []
        
        % [Global]
        simulationTypeIS
        simulationTypeRT
        generateRIR
        generateBRIR
        generateISHOA
        generateRTHOA
        generateISVBAP
        generateRTVBAP
        exportFilter
        exportHistogram
        exportWallHitLog
        exportPlaneWaveList
        accelerationType
        logPerformance
        
        % [PrimarySources] %
        sourceNames
        sourceDirectivity
        sourcePositions
        sourceViewVectors
        sourceUpVectors
        sourceSoundStates
        sourceSoundLevels
        
        % [Receiver] %
        receiverNames
        receiverPositions
        receiverViewVectors
        receiverUpVectors
        receiverStates
        
        % [ImageSources] %
        ISOrder_PS
        ISOrder_SS
        ISSkipDirectSound
        
        % [RayTracing] %
        numParticles_Sphere
        numParticles_Portal
        energyLoss_Sphere
        energyLoss_Portal
        filterLength
        timeSlotLength
        radiusSphere
        fixReflectionPattern
        
        % [Filter] %
        fixPoissonSequence
        poissonSequenceNumber
        filterResolution
        ambisonicsOrder
        numberSpreadedSources
        spreadingStdDeviation
        fftDegreeForWallFilterInterpolation

        % [PlaneWaveLists] %
        planeWaveList_IS = []
        planeWaveList_RT = []
		
        % [Performance]
        performance = struct('ISFilterMonaural',[],'ISFilterBinaural',[],'RTFilterMonaural',[],'RTFilterBinaural',[],'ISGenerateImageSources',[],'ISTransformationMatrix',[],'ISAudibilityTest',[],'RTTotal',[],'RTBands',[]);
        
    end
    
    properties (GetAccess = 'public', SetAccess = 'public')	
        % [WallHitLogs] %
        wallHitLog_IS = []
        wallHitLog_RT = []
        initialParticleEnergy = []
    end
	
    properties (GetAccess = 'private', SetAccess = 'private')
        
        ravenExe64 = '..\bin64\RavenConsole64.exe'
        ravenExe32 = '..\bin32\RavenConsole.exe'
        
        rpf_ini
        raven_ini
        projectID
        projectTag
        
        projectLoaded = false
        simulationDone = false
        
        keepOutputFiles
        plotModelHandle = [];
        
        % [PrimarySources] %
        sourceNameString
        sourceDirectivityString
        
        % [Receiver] %
        receiverNameString
        uniformReceiverGridX = []
        uniformReceiverGridY = []
        uniformReceiverGridZ = []
        
        % RESULTS %
        monauralIR = []
        monauralIR_IS = []
        monauralIR_RT = []
        binauralIR = []
        binauralIR_IS = []
        binauralIR_RT = []
        ambisonicsIR = []
        ambisonicsIR_IS = []
        ambisonicsIR_RT = []
        vbapIR = []
        vbapIR_IS = []
        vbapIR_RT = []
        histogram = []
        histogramRT = []
    end
    
    
    %---------------------- PUBLIC METHODS -------------------------------%
    methods
        %------------------------------------------------------------------
        function obj = itaRavenProject(raven_project_file)
            %RavenProject - constructor
            % To Create a new project with empty default configuration.
            %
            % Using:
            %   rpf = RavenProject(raven_project_file)
            %
            % Input:
            %   [optional] existing raven project file
            %
            % Output:
            %   obj - an instance of class RavenProject
            %
            
            if strcmp(computer('arch'), 'win32')
                obj.ravenExe = obj.ravenExe32;
            elseif strcmp(computer('arch'), 'win64')
                obj.ravenExe = obj.ravenExe64;
            else
                error('Only Windows OS are supported.');
            end
            
            itaRavenProjectPath = which('itaRavenProject.m');
            obj.ravenIniFile = [ itaRavenProjectPath(1:end-9) '.ini'];
            
            ravenIniExists = exist(obj.ravenIniFile,'file');
            
            if (ravenIniExists)
                    % load path from itaRaven.ini
                    obj.raven_ini = IniConfig();
                    obj.raven_ini.ReadFile(obj.ravenIniFile);
                    obj.ravenExe         = obj.raven_ini.GetValues('Global', 'PathRavenExe', obj.ravenExe);
                    obj.raven_ini.WriteFile(obj.ravenIniFile);
            end        
                    
            if (~exist(obj.ravenExe,'file'))

                    % neither the default raven console or the path in
                    % itaRaven.ini was not found, try to locate
                    % RavenConsole
                    locatedRavenExe = which(obj.ravenExe(10:end));
        
                    if isempty(locatedRavenExe) 
                        disp('[itaRaven]: No raven binary was found! Please select path to RavenConsole.exe!');
                        [ selectedRavenExe, selectedRavenPath] = uigetfile('*.exe',' No raven binary was found! Please select path to RavenConsole.exe');
                        obj.ravenExe = [ selectedRavenPath selectedRavenExe];
                    else
                        obj.ravenExe = locatedRavenExe;
                    end
                    
                    if (~ravenIniExists)
                        obj.raven_ini = IniConfig();
%                         obj.raven_ini.ReadFile(obj.ravenIniFile);
                        obj.raven_ini.AddSections({'Global'});
                        obj.raven_ini.AddKeys('Global', {'PathRavenExe'}, {obj.ravenExe});
                    else
                        obj.raven_ini.SetValues('Global', {'PathRavenExe'}, {obj.ravenExe});
                    end
                    obj.raven_ini.WriteFile(obj.ravenIniFile);
                       
            end
                      
            % check if raven project file exists
            if (nargin > 0) && exist(raven_project_file, 'file')
                obj.loadRavenConfig(raven_project_file);
            else
                error('No raven project file given or file not found.');
            end
        end
        
        function delete(obj)
            obj.deleteResultsInRavenFolder();
        end
        
        %------------------------------------------------------------------
        function setRavenExe(obj, newRavenExe)
            obj.ravenExe = newRavenExe;

            if (exist(obj.ravenIniFile,'file'))
                obj.raven_ini.SetValues('Global', {'PathRavenExe'}, {obj.ravenExe});
                obj.raven_ini.WriteFile(obj.ravenIniFile);
            else
                obj.raven_ini = IniConfig();
                obj.raven_ini.AddSections({'Global'});
                obj.raven_ini.AddKeys('Global', {'PathRavenExe'}, {obj.ravenExe});
            end
                                            
        end
        
        %------------------------------------------------------------------
        function loadRavenConfig(obj, filename)
            %loadRavenConfig - Reads an existing raven project file
            %
            
            % change relative to absolute path
            if (~strcmp(filename(2),':'))
                obj.ravenProjectFile = [pwd '\' filename];
            else
                obj.ravenProjectFile = filename;
            end
            
            obj.rpf_ini = IniConfig();
            obj.rpf_ini.ReadFile(filename);
            
            % [Global] %
            obj.projectName         = obj.rpf_ini.GetValues('Global', 'ProjectName', 'Matlab');
            obj.projectTag          = obj.projectName;
            obj.pathResults         = obj.rpf_ini.GetValues('Global', 'ProjectPath_Output', '..\RavenOutput');
            obj.pathDirectivities   = obj.rpf_ini.GetValues('Global', 'ProjectPath_DirectivityDB', '..\RavenDatabase\DirectivityDatabase');
            obj.pathMaterials       = obj.rpf_ini.GetValues('Global', 'ProjectPath_MaterialDB', '..\RavenDatabase\MaterialDatabase');
            obj.fileHRTF            = obj.rpf_ini.GetValues('Global', 'ProjectPath_HRTFDB', '..\RavenDatabase\HRTF\ITA-Kunstkopf_HRIR_AP11_Pressure_Equalized_3x3_256.daff');
            obj.fileSpeakers        = obj.rpf_ini.GetValues('Global', 'SpeakerConfigFile', 'Speakers.ini');
            obj.simulationTypeIS    = obj.rpf_ini.GetValues('Global', 'simulationTypeIS', 1);
            obj.simulationTypeRT    = obj.rpf_ini.GetValues('Global', 'simulationTypeRT', 1);
            obj.generateRIR         = obj.rpf_ini.GetValues('Global', 'generateRIR', 1);
            obj.generateBRIR        = obj.rpf_ini.GetValues('Global', 'generateBRIR', 1);
            obj.generateISHOA       = obj.rpf_ini.GetValues('Global', 'generateISHOA', 0);
            obj.generateRTHOA       = obj.rpf_ini.GetValues('Global', 'generateRTHOA', 0);
            obj.generateISVBAP      = obj.rpf_ini.GetValues('Global', 'generateISVBAP', 0);
            obj.generateRTVBAP      = obj.rpf_ini.GetValues('Global', 'generateRTVBAP', 0);
            obj.exportFilter        = obj.rpf_ini.GetValues('Global', 'exportFilter', 1);
            obj.exportHistogram     = obj.rpf_ini.GetValues('Global', 'exportHistogram', 1);
            obj.exportWallHitLog    = obj.rpf_ini.GetValues('Global', 'exportWallHitList', 0);
            obj.exportPlaneWaveList = obj.rpf_ini.GetValues('Global', 'exportPlaneWaveList', 0);
            obj.accelerationType    = obj.rpf_ini.GetValues('Global', 'accelerationType', 0);   % default 0 = MODE_BSP
            obj.logPerformance      = obj.rpf_ini.GetValues('Global', 'logPerformance', 0);
            obj.keepOutputFiles     = obj.rpf_ini.GetValues('Global', 'keepOutputFiles', 0);
            
            
            % change relative to absolute paths
            if obj.ravenExe(2) == ':' % absolute path
                ravenBasePath = fileparts(fileparts(obj.ravenExe)); % base path of raven
                
                if (strcmp(obj.pathResults(1:2),'..')), obj.pathResults = [ ravenBasePath obj.pathResults(3:end) ]; end
                if (strcmp(obj.pathDirectivities(1:2),'..')), obj.pathDirectivities = [ ravenBasePath obj.pathDirectivities(3:end) ]; end
                if (strcmp(obj.pathMaterials(1:2),'..')), obj.pathMaterials = [ ravenBasePath obj.pathMaterials(3:end) ]; end
                if (strcmp(obj.fileHRTF(1:2),'..')), obj.fileHRTF = [ ravenBasePath obj.fileHRTF(3:end) ]; end               
                

            end
            
            % [Rooms] %
            model_string            = obj.rpf_ini.GetValues('Rooms',  'Model');
            obj.modelFileList       = textscan(model_string, '%s', 'Delimiter' , ',');
            obj.modelFileList       = obj.modelFileList{1}; % textscan implementation issue
            if numel(obj.modelFileList) == 1
                obj.modelFileList = obj.modelFileList{1};   % de-cell if only 1 room given
                
                if obj.ravenExe(2) == ':' % convert to absolute path
                    if (strcmp(obj.modelFileList(1:2),'..')), obj.modelFileList = [ ravenBasePath obj.modelFileList(3:end) ]; end   
                end
            end
            


            
            % [PrimarySources] %
            obj.sourceNameString    = obj.rpf_ini.GetValues('PrimarySources', 'sourceNames', 'Sender');
            obj.sourceNames         = textscan(obj.sourceNameString, '%s', 'Delimiter', ',');
            obj.sourceNames         = obj.sourceNames{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            obj.sourceDirectivityString = obj.rpf_ini.GetValues('PrimarySources', 'sourceDirectivity', '');
            if ~isempty(obj.sourceDirectivityString)
                obj.sourceDirectivity   = textscan(obj.sourceDirectivityString, '%s', 'Delimiter', ',');
                obj.sourceDirectivity   = obj.sourceDirectivity{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            else
                obj.sourceDirectivity   = {};
            end
            obj.sourcePositions     = obj.rpf_ini.GetValues('PrimarySources', 'sourcePositions');
            obj.sourcePositions     = reshape(obj.sourcePositions, 3, numel(obj.sourcePositions)/3)';
            obj.sourceViewVectors   = obj.rpf_ini.GetValues('PrimarySources', 'sourceViewVectors', '0, 0, 1');
            obj.sourceViewVectors   = reshape(obj.sourceViewVectors, 3, numel(obj.sourceViewVectors)/3)';
            obj.sourceUpVectors     = obj.rpf_ini.GetValues('PrimarySources', 'sourceUpVectors', '0, 1, 0');
            obj.sourceUpVectors     = reshape(obj.sourceUpVectors, 3, numel(obj.sourceUpVectors)/3)';
            obj.sourceSoundStates   = obj.rpf_ini.GetValues('PrimarySources', 'sourceSoundStates', '1');
            obj.sourceSoundLevels   = obj.rpf_ini.GetValues('PrimarySources', 'sourceSoundLevels', '100');
            
            % [Receiver] %
            obj.receiverNameString  = obj.rpf_ini.GetValues('Receiver', 'receiverNames', 'Receiver');
            obj.receiverNames       = textscan(obj.receiverNameString, '%s', 'Delimiter', ',');
            obj.receiverNames       = obj.receiverNames{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            obj.receiverPositions   = obj.rpf_ini.GetValues('Receiver', 'receiverPositions');
            obj.receiverPositions   = reshape(obj.receiverPositions, 3, numel(obj.receiverPositions)/3)';
            obj.receiverViewVectors = obj.rpf_ini.GetValues('Receiver', 'receiverViewVectors', '1, 0 ,0');
            obj.receiverViewVectors = reshape(obj.receiverViewVectors, 3, numel(obj.receiverViewVectors)/3)';
            obj.receiverUpVectors   = obj.rpf_ini.GetValues('Receiver', 'receiverUpVectors', '0, 1, 0');
            obj.receiverUpVectors   = reshape(obj.receiverUpVectors, 3, numel(obj.receiverUpVectors)/3)';
            
            % [ImageSources] %
            obj.ISOrder_PS          = obj.rpf_ini.GetValues('ImageSources', 'ISOrder_PS', 2);
            obj.ISOrder_SS          = obj.rpf_ini.GetValues('ImageSources', 'ISOrder_SS', 2);
            obj.ISSkipDirectSound   = obj.rpf_ini.GetValues('ImageSources', 'ISSkipDirectSound', 0);
            
            % [RayTracing] %
            obj.numParticles_Sphere = obj.rpf_ini.GetValues('RayTracing', 'numberOfParticles_DetectionSphere', 10000);
            obj.numParticles_Portal = obj.rpf_ini.GetValues('RayTracing', 'numberOfParticles_Portal', 10000);
            obj.energyLoss_Sphere   = obj.rpf_ini.GetValues('RayTracing', 'energyLoss_DetectionSphere', 63);
            obj.energyLoss_Portal   = obj.rpf_ini.GetValues('RayTracing', 'energyLoss_Portal', 63);
            obj.filterLength        = obj.rpf_ini.GetValues('RayTracing', 'filterLength_DetectionSphere', 2000);
            obj.timeSlotLength      = obj.rpf_ini.GetValues('RayTracing', 'timeResolution_DetectionSphere', 6);
            obj.radiusSphere        = obj.rpf_ini.GetValues('RayTracing', 'radius_DetectionSphere', 0.5);
            obj.fixReflectionPattern= obj.rpf_ini.GetValues('RayTracing', 'fixReflectionPattern', 0);
            
            % [Filter] %
            obj.fixPoissonSequence  = obj.rpf_ini.GetValues('Filter', 'setFixPoissonSequence', 0);
            obj.poissonSequenceNumber = obj.rpf_ini.GetValues('Filter', 'poissonSequenceNumber', 9876);
            obj.filterResolution    = obj.rpf_ini.GetValues('Filter', 'filterResolution', 1);   % 1 = Octave, 0 = 3rd Octave
            obj.ambisonicsOrder     = obj.rpf_ini.GetValues('Filter', 'ambisonicsOrder', -1);
            obj.numberSpreadedSources             = obj.rpf_ini.GetValues('Filter', 'numberSpreadedSources', 0);
            obj.spreadingStdDeviation             = obj.rpf_ini.GetValues('Filter', 'spreadingStdDeviation', 0.2);
            obj.fftDegreeForWallFilterInterpolation = obj.rpf_ini.GetValues('Filter', 'fftDegreeForWallFilterInterpolation', 8);
            
            obj.projectLoaded = true;
        end
        
        %------------------------------------------------------------------
        function reloadRavenConfig(obj, filename)
            if nargin < 2
                filename = obj.ravenProjectFile;
            end
            
            obj.loadRavenConfig(filename);
        end
        
                %------------------------------------------------------------------
        function saveRavenConfig(obj, filename)
            %saveRavenConfig - Saves the current object in a (different)
            %raven project file. Can be used as a log if various
            %simulations are run with multiple configurations
            %
            obj.rpf_ini.WriteFile(filename);

        end
        
        %------------------------------------------------------------------
        function run(obj)
            
            obj.simulationDone = false;
            
            if obj.projectLoaded
                savedProjectName = obj.projectName;
                
                obj.projectID = datestr(now, 30);
                obj.projectTag = [obj.projectName obj.projectID];
                
                % give the project name a date and time string to help to identify the results
                obj.setProjectName(obj.projectTag);
                
                % set filter length to the length of the reverberation
                %                 obj.setFilterLengthToReverbTime();
                
                % run the simulation
                disp(['Running simulation... (' obj.ravenExe ')']);
                if exist(obj.ravenLogFile, 'file')
                    delete(obj.ravenLogFile);
                end
                %                 system([obj.ravenExe ' "' obj.ravenProjectFile '" >> ' obj.ravenLogFile]);
                prevPath = pwd;
                cd(fileparts(obj.ravenExe));
                dos(['"' obj.ravenExe '"' ' "' obj.ravenProjectFile '"'],'-echo');
                disp('Done.');
                cd(prevPath);
                
                % restore the initial project name
                obj.setProjectName(savedProjectName);
                
                % gather results
                disp('Getting results...');
                obj.gatherResults();
                disp('Done.');
                
                obj.simulationDone = true;
                
                % delete results in raven folder structure -> they are copied now into this class
                if (obj.keepOutputFiles == 0)
                    obj.deleteResultsInRavenFolder();
                end
            else
                disp('No projected defined yet.');
            end
            
        end
        
        %------------------------------------------------------------------
        function runNoGathering(obj)
            % basicly the same as the run method, but without the call of
            % obj.gatherResults();
            
            obj.simulationDone = false;
            
            if obj.projectLoaded
                savedProjectName = obj.projectName;
                
                obj.projectID = datestr(now, 30);
                obj.projectTag = [obj.projectName obj.projectID];
                
                % give the project name a date and time string to help to identify the results
                obj.setProjectName(obj.projectTag);
                
                % set filter length to the length of the reverberation
                %                 obj.setFilterLengthToReverbTime();
                
                % run the simulation
                disp(['Running simulation... (' obj.ravenExe ')']);
                if exist(obj.ravenLogFile, 'file')
                    delete(obj.ravenLogFile);
                end
                %                 system([obj.ravenExe ' "' obj.ravenProjectFile '" >> ' obj.ravenLogFile]);
                dos([obj.ravenExe ' "' obj.ravenProjectFile '"'], '-echo');
                disp('Done.');
                
                % restore the initial project name
                obj.setProjectName(savedProjectName);
                
                % gather results
                disp('This function does _not_ gather the results. Please provide arguments to getWallHitLogBand(band)');
%                 obj.gatherResults();
%                 disp('Done.');
                
                obj.simulationDone = true;
                
                % delete results in raven folder structure -> they are copied now into this class
%                 if (obj.keepOutputFiles == 0)
%                     obj.deleteResultsInRavenFolder();
%                 end
            else
                disp('No projected defined yet.');
            end
            
        end
        
                %------------------------------------------------------------------
        function openOutputFolder(obj)
            % opens the output folder in windows explorer
                
            if (exist(obj.pathResults,'dir'))
                dos(['C:\Windows\Explorer.exe ' obj.pathResults]);
            else
                disp('Output Folder does not exist!');
            end
            
        end
        
        
        %------------------------------------------------------------------
        function numReceivers = createReceiverArray(obj, xpositions, zpositions, yheight)
            numReceivers = numel(xpositions) * numel(zpositions);
            [obj.uniformReceiverGridX, obj.uniformReceiverGridZ] = meshgrid(xpositions, zpositions);
            obj.uniformReceiverGridY = ones(size(obj.uniformReceiverGridX,1), size(obj.uniformReceiverGridX,2)) * yheight;
            
            rec_names = obj.makeNumberedNames('Array', numReceivers);
            rec_states = str2num(obj.writeXtimes_num(1, numReceivers));
            rec_view = str2num(obj.writeXtimes('1,0,0', numReceivers));
            rec_up = str2num(obj.writeXtimes('0,1,0', numReceivers));
            
            positions = zeros(numReceivers * 3, 1);
            positions(1:3:end) = obj.uniformReceiverGridX(:);
            positions(2:3:end) = obj.uniformReceiverGridY(:);
            positions(3:3:end) = obj.uniformReceiverGridZ(:);
            
            obj.setReceiverNames(rec_names);
            obj.setReceiverPositions(positions);
            obj.setReceiverViewVectors(rec_view);
            obj.setReceiverUpVectors(rec_up);
            obj.setReceiverStates(rec_states);
            
            disp(['Receiver grid created successfully. ' num2str(numReceivers) ' receivers placed.']);
        end
        
        %------------------------------------------------------------------
        function createReceiverArrayAuto(obj, yheight, distance, roomID)
            
            if nargin < 4
                roomID = 0;   % default = first room (ID = 0)
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            if nargin < 3
                distance = 1;   % default = 1 meter
            end
            
            if nargin < 2
                yheight = min(roommodel.nodes(:,2)) + 1.2;  % default listener 1.2 meters above ground
                if yheight > max(roommodel.nodes(:,2))
                    yheight = mean(roommodel.nodes(:,2));   % if 1.2 meters is out of ceiling, try putting receivers in the middle between floor and ceiling
                end
            end
            
            xpositions = min(roommodel.nodes(:,1)) + distance/2 : distance : max(roommodel.nodes(:,1)) - distance/2;
            zpositions = min(roommodel.nodes(:,3)) + distance/2 : distance : max(roommodel.nodes(:,3)) - distance/2;
            
            obj.createReceiverArray(xpositions, zpositions, yheight);
        end
        
        %------------------------------------------------------------------
        function rebuildReceiverGrid(obj)
            numReceivers = numel(obj.receiverPositions) / 3;    %xyz
            if numReceivers < 1
                error('No receiver position data present.');
            end
            x = obj.receiverPositions(:,1);
            y = obj.receiverPositions(:,2);
            z = obj.receiverPositions(:,3);
            averageDistance = sqrt((max(x)-min(x))*(max(z)-min(z)) / numReceivers);
            obj.createReceiverArray(min(x) : averageDistance : max(x), min(z) : averageDistance : max(z), mean(y));
        end
        
        %------------------------------------------------------------------
        function setModel(obj, filename)
            
            if (nargin < 2)
                error('Not enough input arguments.')
            end
            
            if ~ischar(filename)
                error('Requires string input.')
            else
                if iscell(filename)
                    obj.modelFileList = obj.cat_cell_of_strings(filename);
                else
                    obj.modelFileList = filename;
                end
                obj.rpf_ini.SetValues('Rooms', 'Model', obj.modelFileList);
            end
            
            obj.model = [];
            
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function plotModel(obj, tgtAxes, comp2axesMapping, wireframe)
            if isempty(obj.modelFileList)
                return;
            end
            
            if nargin < 4
                wireframe = 0;
            else
                if ischar(wireframe)
                    wireframe = isequal(wireframe, 'wireframe');
                end
            end
            if nargin < 3
                comp2axesMapping = [3 1 2];
            end
            if nargin < 2
                if (ishandle(obj.plotModelHandle))
                    tgtAxes = obj.plotModelHandle;
                else
                    figure;
                    tgtAxes = gca;
                end
                
            end
            
            obj.plotModelHandle = tgtAxes;
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                        obj.model{iRoom}.plotModel(tgtAxes, comp2axesMapping, wireframe);
                        hold on;
                    end
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    obj.model.plotModel(tgtAxes, comp2axesMapping, wireframe);
                end
            else
                if iscell(obj.model)
                    for iRoom = 1 : numel(obj.model)
                        obj.model{iRoom}.plotModel(tgtAxes, comp2axesMapping, wireframe);
                        hold on;
                    end
                else
                    obj.model.plotModel(tgtAxes, comp2axesMapping, wireframe);
                end
            end
            % plot source and receivers
            spos = obj.getSourcePosition;
            snames = obj.getSourceNames;
            
            rpos = obj.getReceiverPosition;
            rnames = obj.getReceiverNames;
            
            plot3(spos(:,3),spos(:,1),spos(:,2),'marker','o','markersize',9,'linestyle','none','linewidth',1.5)
            plot3(rpos(:,3),rpos(:,1),rpos(:,2),'marker','x','markersize',9,'linestyle','none','linewidth',1.5)
            
            % plot view/up vectors (red/green) of receivers
            sview = obj.getSourceViewVectors;
            sup = obj.getSourceUpVectors;
            
            quiver3(spos(:,3),spos(:,1),spos(:,2),0.5*sview(:,3),0.5*sview(:,1),0.5*sview(:,2),'color','r','maxheadsize',1.5,'linewidth',1.5);
            quiver3(spos(:,3),spos(:,1),spos(:,2),0.5*sup(:,3),0.5*sup(:,1),0.5*sup(:,2),'color','g','maxheadsize',1.5,'linewidth',1.5);
            
            % plot view/up vectors (red/green) of receivers
            rview = obj.getReceiverViewVectors;
            rup = obj.getReceiverUpVectors;
            
            quiver3(rpos(:,3),rpos(:,1),rpos(:,2),0.5*rview(:,3),0.5*rview(:,1),0.5*rview(:,2),'color','r','maxheadsize',1.5,'linewidth',1.5);
            quiver3(rpos(:,3),rpos(:,1),rpos(:,2),0.5*rup(:,3),0.5*rup(:,1),0.5*rup(:,2),'color','g','maxheadsize',1.5,'linewidth',1.5);
            
            % plot names
            text(spos(:,3)+0.2,spos(:,1),spos(:,2),snames)
            text(rpos(:,3)+0.2,rpos(:,1),rpos(:,2),rnames)
        end
        
        %------------------------------------------------------------------
        function plotMaterialsAbsorption(obj, exportPlot)
            
            if nargin < 2
               exportPlot = false; 
            end
            
            freqVector = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
            freqLabel3rdVisual = { '', '', '31.5 Hz', '', '', '' '', '  ', '  125 Hz', ' ', ' ', ...
                '', ' ', ' ', '  500 Hz', ' ', '  ', '', '', ' ', '   2 kHz', ...
                ' ', '', '', '', '', '   8 kHz', '  ', '', '', '20 kHz'};

            yticks = { '0.0','', '0.20','','0.40','','0.60','','0.80','','1.0'};

            allMaterials = obj.getRoomMaterialNames;
            numberMaterials = length(allMaterials);

            currentMaterial = itaResult;
            currentMaterial.freqVector = freqVector;
            currentMaterial.freqData = [];

            for iMat=1:numberMaterials
                [absorp scatter ] = obj.getMaterial(allMaterials{iMat});
                currentMaterial.freqData = [ currentMaterial.freqData absorp' ];
                currentSurfaceArea = obj.getSurfaceAreaOfMaterial(allMaterials{iMat});
                allMaterials{iMat} = strrep(allMaterials{iMat},'_',' ');
                allMaterials{iMat} = [ allMaterials{iMat} ' (S = ' num2str(currentSurfaceArea,'%5.2f') ' m² ;'];
                allMaterials{iMat} = [ allMaterials{iMat} ' A (Eyring, f=1000 Hz) = ' num2str(-currentSurfaceArea*log(1-currentMaterial.freqData(18)),'%5.2f') ' m² )'];
            end

            currentMaterial.channelNames = allMaterials;
            currentMaterial.allowDBPlot = false;
            currentMaterial.pf;
            
            % change format of plot
            title('');
            ylabel('Absorption coefficient');
            xlabel('Frequency in Hz');
            set(gca,'XLim',[63 20000]);
            set(gca,'YLim',[0 1]);
            leg = findobj(gcf,'Tag','legend');
            set(leg,'Location','NorthWest');
            set(leg,'FontSize',9);
            
            % remove [1] in legend entry
            for iMat=1:numberMaterials
                leg.String{iMat} = leg.String{iMat}(1:end-4);
            end
            

            % export plot to raven output
            if (exportPlot)
              [pathstr,name,ext] = fileparts(obj.ravenProjectFile);
              dateTimeStr = datestr(now,30);
              dateTimeStr = strrep(dateTimeStr,'T','_');
              fileName = [ obj.pathResults '\Absorption_' name '_' dateTimeStr '.png'];
              saveas(gcf,fileName);
            end
        end
        
        %------------------------------------------------------------------
        function plotMaterialsScattering(obj, exportPlot)
                    
            if nargin < 2
               exportPlot = false; 
            end
            
            freqVector = [20 25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
            freqLabel3rdVisual = { '', '', '31.5 Hz', '', '', '' '', '  ', '  125 Hz', ' ', ' ', ...
                '', ' ', ' ', '  500 Hz', ' ', '  ', '', '', ' ', '   2 kHz', ...
                ' ', '', '', '', '', '   8 kHz', '  ', '', '', '20 kHz'};

            yticks = { '0.0','', '0.20','','0.40','','0.60','','0.80','','1.0'};

            allMaterials = obj.getRoomMaterialNames;
            numberMaterials = length(allMaterials);

            currentMaterial = itaResult;
            currentMaterial.freqVector = freqVector;
            currentMaterial.freqData = [];

            for i=1:numberMaterials
                [absorp scatter ] = obj.getMaterial(allMaterials{i});
                currentMaterial.freqData = [ currentMaterial.freqData scatter' ];
                                currentSurfaceArea = obj.getSurfaceAreaOfMaterial(allMaterials{i});
                allMaterials{i} = strrep(allMaterials{i},'_',' ');
                allMaterials{i} = [ allMaterials{i} ' (S = ' num2str(currentSurfaceArea,'%5.2f') ' m² )'];
            end

            currentMaterial.channelNames = allMaterials;
            currentMaterial.allowDBPlot = false;
            currentMaterial.pf;
            
            % change format of plot
            title('');
            ylabel('Scattering coefficient');
            xlabel('Frequency in Hz');
            set(gca,'XLim',[63 20000]);
            set(gca,'YLim',[0 1]);
            leg = findobj(gcf,'Tag','legend');
            set(leg,'Location','NorthWest');
            set(leg,'FontSize',9);
            
            % remove [1] in legend entry
            for iMat=1:numberMaterials
                leg.String{iMat} = leg.String{iMat}(1:end-4);
            end

            % export plot to raven output
            if (exportPlot)
              [pathstr,name,ext] = fileparts(obj.ravenProjectFile);
              dateTimeStr = datestr(now,30);
              dateTimeStr = strrep(dateTimeStr,'T','_');
              fileName = [ obj.pathResults '\Scattering_' name '_' dateTimeStr '.png'];
              saveas(gcf,fileName);
            end
        end
        
        
        
        % [Global] %
        %------------------------------------------------------------------
        function setProjectName(obj, projectName)
            obj.projectName = projectName;
            obj.rpf_ini.SetValues('Global', 'ProjectName', projectName);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSimulationTypeIS(obj, typeIS)
            obj.simulationTypeIS = typeIS;
            obj.rpf_ini.SetValues('Global', 'simulationTypeIS', typeIS);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSimulationTypeRT(obj, typeRT)
            obj.simulationTypeRT = typeRT;
            obj.rpf_ini.SetValues('Global', 'simulationTypeRT', typeRT);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setGenerateRIR(obj, genRIR)
            obj.generateRIR = genRIR;
            obj.rpf_ini.SetValues('Global', 'generateRIR', genRIR);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setGenerateBRIR(obj, genBRIR)
            obj.generateBRIR = genBRIR;
            obj.rpf_ini.SetValues('Global', 'generateBRIR', genBRIR);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setGenerateISHOA(obj, genISHOA)
            obj.generateISHOA = genISHOA;
            obj.rpf_ini.SetValues('Global', 'generateISHOA', genISHOA);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setGenerateRTHOA(obj, genRTHOA)
            obj.generateRTHOA = genRTHOA;
            obj.rpf_ini.SetValues('Global', 'generateRTHOA', genRTHOA);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setGenerateISVBAP(obj, genISVBAP)
            obj.generateISVBAP = genISVBAP;
            obj.rpf_ini.SetValues('Global', 'generateISVBAP', genISVBAP);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setGenerateRTVBAP(obj, genRTVBAP)
            obj.generateRTVBAP = genRTVBAP;
            obj.rpf_ini.SetValues('Global', 'generateRTVBAP', genRTVBAP);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setExportFilter(obj, exportFilter)
            obj.exportFilter = exportFilter;
            obj.rpf_ini.SetValues('Global', 'exportFilter', exportFilter);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setExportHistogram(obj, exportHisto)
            obj.exportHistogram = exportHisto;
            obj.rpf_ini.SetValues('Global', 'exportHistogram', exportHisto);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setExportWallHitLog(obj, exportWallHitLog)
            obj.exportWallHitLog = exportWallHitLog;
            obj.rpf_ini.SetValues('Global', 'exportWallHitList', exportWallHitLog);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setExportPlaneWaveList(obj, exportPlaneWaveList)
            obj.exportPlaneWaveList = exportPlaneWaveList;
            obj.rpf_ini.SetValues('Global', 'exportPlaneWaveList', exportPlaneWaveList);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setAccelerationType(obj, accelerationType)
            obj.accelerationType = accelerationType;
            obj.rpf_ini.SetValues('Global', 'accelerationType', accelerationType);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setLogPerformance(obj, logPerformance)
            obj.logPerformance = logPerformance;
            obj.rpf_ini.SetValues('Global', 'logPerformance', logPerformance);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setPortals(obj, portalTypes, portalStatus)
            if nargin < 3
                % if only 1 parameter is given (portalTypes), interprete
                % them as portal states! (more likely to be used like this)
                obj.rpf_ini.SetValues('Portals', 'portalStatus', obj.make_proper_string(portalTypes));     % 1 = open, 0 = closed
            else
                obj.rpf_ini.SetValues('Portals', 'portalType', portalTypes);
                obj.rpf_ini.SetValues('Portals', 'portalStatus', obj.make_proper_string(portalStatus));     % 1 = open, 0 = closed
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setTemperature(obj, temp)
            obj.rpf_ini.SetValues('Rooms', 'Temperature', num2str(temp));
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function temp = getTemperature(obj)
            temp = obj.rpf_ini.GetValues('Rooms', 'Temperature', -1);
        end
        
        %------------------------------------------------------------------
        function setHumidity(obj, humid)
            obj.rpf_ini.SetValues('Rooms', 'Humidity', num2str(humid));
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function humid = getHumidity(obj)
            humid = obj.rpf_ini.GetValues('Rooms', 'Humidity', -1);
        end
        
        %------------------------------------------------------------------
        function setPressure(obj, press)
            obj.rpf_ini.SetValues('Rooms', 'Pressure', num2str(press));
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function press = getPressure(obj)
            press = obj.rpf_ini.GetValues('Rooms', 'Pressure', -1);
        end
        
        %------------------------------------------------------------------
        function enableAirAbsorption(obj)
            obj.rpf_ini.SetValues('Rooms', 'noAirAbsorption', 0);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function disableAirAbsorption(obj)
            obj.rpf_ini.SetValues('Rooms', 'noAirAbsorption', 1);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function airAbsEnabled = getAirAbsorptionEnabled(obj)
            airAbsEnabled = ~obj.rpf_ini.GetValues('Rooms', 'noAirAbsorption', 0);
        end        
        
        % [PrimarySources] %
        %------------------------------------------------------------------
        function setSourceNames(obj, sourceNames)
            if iscell(sourceNames)
                obj.sourceNameString = obj.cat_cell_of_strings(sourceNames);
                obj.sourceNames      = sourceNames;
            else
                obj.sourceNameString = sourceNames;
                obj.sourceNames      = textscan(obj.sourceNameString, '%s', 'Delimiter', ',');
                obj.sourceNames      = obj.sourceNames{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            end
            obj.rpf_ini.SetValues('PrimarySources', 'sourceNames', obj.sourceNameString);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function directivityName = getSourceDirectivity(obj, srcID)
            
            readstring = obj.rpf_ini.GetValues('PrimarySources', 'sourceDirectivity', '');
            if ~isempty(readstring)
                
                readstring   = textscan(readstring, '%s', 'Delimiter', ',');
                readstring   = readstring{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
                if nargin<2
                    directivityName=readstring;
                else
                    directivityName=readstring(srcID);
                end
                
            else
                obj.sourceDirectivity   = {};
            end
            
            % %            Original
            %             if iscell(obj.sourceDirectivity)
            %                 directivityName = obj.sourceDirectivity{sourceID + 1};
            %             else
            %                 obj.sourceDirectivity   = textscan(obj.sourceDirectivityString, '%s', 'Delimiter', ',');
            %                 obj.sourceDirectivity   = obj.sourceDirectivity{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            %                 directivityName = obj.sourceDirectivity{sourceID + 1};
            %             end
        end
        
        %------------------------------------------------------------------
        function setSourceDirectivity(obj, directivity)
            if iscell(directivity)
                obj.sourceDirectivityString = obj.cat_cell_of_strings(directivity);
                obj.sourceDirectivity   = directivity;
            else
                obj.sourceDirectivityString = directivity;
                obj.sourceDirectivity   = textscan(obj.sourceDirectivityString, '%s', 'Delimiter', ',');
                obj.sourceDirectivity   = obj.sourceDirectivity{1}; % textscan liefert cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            end
            obj.rpf_ini.SetValues('PrimarySources', 'sourceDirectivity', obj.sourceDirectivityString);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function pos = getSourcePosition(obj, srcID)

            all_pos = obj.rpf_ini.GetValues('PrimarySources', 'sourcePositions');
            if (nargin < 2)
                pos = reshape(all_pos',3,length(all_pos)/3)';
            else
                pos = all_pos((srcID*3 + 1) : (srcID*3 + 3));
            end
        end
        %------------------------------------------------------------------
        function setSourcePositions(obj, pos, coord_trafo)
            %setSourcePositions(pos, [coord_trafo])
            %   coord_trafo: 3-element vector
            %                1. element: which of the given axis to use as x-coordinates
            %                2. element: which of the given axis to use as y-coordinates
            %                3. element: which of the given axis to use as z-coordinates
            
            % if input is string convert to matrix
            if ischar(pos)
                pos = reshape(sscanf(pos, '%f,'), 3, numel(pos)/3)';
            end
            
            % if input is itaCoordinates convert to matrix
            if isa(pos, 'itaCoordinates')
                pos = pos.cart;
            end
            
            % check dimensions
            if size(pos, 2) ~= 3
                error('Positions must be given in vector (1x3) or matrix (Nx3) format.');
            end
            
            % store matrix in RavenProject object
            obj.sourcePositions = pos;
            
            % store positions in .rpf file on disk
            if nargin > 2
                obj.rpf_ini.SetValues('PrimarySources', 'sourcePositions', obj.make_proper_string( ...
                    [sign(coord_trafo(1)) .* pos(:, abs(coord_trafo(1))), ...
                    sign(coord_trafo(2)) .* pos(:, abs(coord_trafo(2))), ...
                    sign(coord_trafo(3)) .* pos(:, abs(coord_trafo(3)))] ));
            else
                obj.rpf_ini.SetValues('PrimarySources', 'sourcePositions', obj.make_proper_string(pos));
            end
            
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSourceViewVectors(obj, view)
            obj.sourceViewVectors = view;
            if isnumeric(view) || iscell(view)
                obj.rpf_ini.SetValues('PrimarySources', 'sourceViewVectors', obj.make_proper_string(view));
            else
                obj.rpf_ini.SetValues('PrimarySources', 'sourceViewVectors', view);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSourceUpVectors(obj, up)
            obj.sourceUpVectors = up;
            if isnumeric(up) || iscell(up)
                obj.rpf_ini.SetValues('PrimarySources', 'sourceUpVectors', obj.make_proper_string(up));
            else
                obj.rpf_ini.SetValues('PrimarySources', 'sourceUpVectors', up);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSourceSoundStates(obj, state)
            obj.sourceSoundStates   = state;
            if isnumeric(state) || iscell(state)
                obj.rpf_ini.SetValues('PrimarySources', 'sourceSoundStates', obj.make_proper_string(state));
            else
                obj.rpf_ini.SetValues('PrimarySources', 'sourceSoundStates', state);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSourceLevels(obj, levels)
            obj.sourceSoundLevels   = levels;
            if isnumeric(levels) || iscell(levels)
                obj.rpf_ini.SetValues('PrimarySources', 'sourceSoundLevels', obj.make_proper_string(levels));
            else
                obj.rpf_ini.SetValues('PrimarySources', 'sourceSoundLevels', levels);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        % [Receiver] %
        %------------------------------------------------------------------
        function setReceiverNames(obj, rec_names)
            if iscell(rec_names)
                obj.receiverNameString = obj.cat_cell_of_strings(rec_names);
                obj.receiverNames      = rec_names;
            else
                obj.receiverNameString = rec_names;
                obj.receiverNames      = textscan(obj.receiverNameString, '%s', 'Delimiter', ',');
                obj.receiverNames      = obj.receiverNames{1}; % textscan liefer cell array in nochmal einer zelle, diese doppelkapselung wird hier rückgängig gemacht
            end
            obj.rpf_ini.SetValues('Receiver', 'receiverNames', obj.receiverNameString);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function pos = getReceiverPosition(obj, recID)
            all_pos = obj.rpf_ini.GetValues('Receiver', 'receiverPositions');
            if (nargin < 2)
                pos = reshape(all_pos',3,length(all_pos)/3)';
            else
                pos = all_pos((recID*3 + 1) : (recID*3 + 3));
            end
        end
        
        %------------------------------------------------------------------
        function rvv = getReceiverViewVectors(obj, recID)
          
            all_pos = obj.rpf_ini.GetValues('Receiver', 'receiverViewVectors');
            if (nargin < 2)
                rvv=reshape(all_pos',3,length(all_pos)/3)';
            else
                rvv = all_pos((recID*3 + 1) : (recID*3 + 3));
            end
        end
        
        %------------------------------------------------------------------
        function ruv = getReceiverUpVectors(obj, recID)
          
            all_pos = obj.rpf_ini.GetValues('Receiver', 'receiverUpVectors');
            if (nargin < 2)
                ruv = reshape(all_pos',3,length(all_pos)/3)';
            else
                ruv = all_pos((recID*3 + 1) : (recID*3 + 3));
            end
        end
        
        %------------------------------------------------------------------
         function rss = getReceiverStates(obj,recID)
            rss = obj.rpf_ini.GetValues('Receiver', 'receiverStates', -1);
            if nargin==2
                rss=rss(recID);
            end
         end
        
         %------------------------------------------------------------------
        function rn = getReceiverNames(obj,recID)
            rn = obj.rpf_ini.GetValues('Receiver', 'receiverNames', -1);
            rn = textscan(rn, '%s', 'Delimiter', ',');
            rn = rn{1};
            if nargin==2
                rn=rn{1}{recID};
            end
        end
        
        %------------------------------------------------------------------
        function setReceiverPositions(obj, pos, coord_trafo)
            %setReceiverPositions(pos, coord_trafo)
            %   coord_trafo: 3-element vector
            %                1. element: which of the given axis to use as x-coordinates
            %                2. element: which of the given axis to use as y-coordinates
            %                3. element: which of the given axis to use as z-coordinates
            
            % if input is string convert to matrix
            if ischar(pos)
                pos = reshape(sscanf(pos, '%f,'), 3, numel(pos)/3)';
            end
            
            % if input is itaCoordinates convert to matrix
            if isa(pos, 'itaCoordinates')
                pos = pos.cart;
            end
            
            % check dimensions
            if size(pos, 2) ~= 3
                error('Positions must be given in vector (1x3) or matrix (Nx3) format.');
            end
            
            % store matrix in RavenProject object
            obj.receiverPositions = pos;
            
            % store positions in .rpf file on disk
            if nargin > 2
                obj.rpf_ini.SetValues('Receiver', 'receiverPositions', obj.make_proper_string( ...
                    [sign(coord_trafo(1)) .* pos(:, abs(coord_trafo(1))), ...
                    sign(coord_trafo(2)) .* pos(:, abs(coord_trafo(2))), ...
                    sign(coord_trafo(3)) .* pos(:, abs(coord_trafo(3)))] ));
            else
                obj.rpf_ini.SetValues('Receiver', 'receiverPositions', obj.make_proper_string(pos));
            end
            
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setReceiverViewVectors(obj, view)
            obj.receiverViewVectors = view;
            if isnumeric(view) || iscell(view)
                obj.rpf_ini.SetValues('Receiver', 'receiverViewVectors', obj.make_proper_string(view));
            else
                obj.rpf_ini.SetValues('Receiver', 'receiverViewVectors', view);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setReceiverUpVectors(obj, up)
            obj.receiverUpVectors   = up;
            if isnumeric(up) || iscell(up)
                obj.rpf_ini.SetValues('Receiver', 'receiverUpVectors', obj.make_proper_string(up));
            else
                obj.rpf_ini.SetValues('Receiver', 'receiverUpVectors', up);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setReceiverStates(obj, states)
            obj.receiverStates = states;
            if isnumeric(states) || iscell(states)
                obj.rpf_ini.SetValues('Receiver', 'receiverStates', obj.make_proper_string(states));
            else
                obj.rpf_ini.SetValues('Receiver', 'receiverStates', states);
            end
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function directivityName = getReceiverHRTF(obj)
            directivityName = obj.rpf_ini.GetValues('Global', 'ProjectPath_HRTFDB');
        end
        
        %------------------------------------------------------------------
        function setReceiverHRTF(obj, HRTF)
            [pathHRTF,~,~] = fileparts(obj.fileHRTF);
            newFile = fullfile(pathHRTF, HRTF);
            
            % check if file path is absolute or relative path 
            % (if ':" is in path, path is absolute)
            if ~isempty(strfind(HRTF, ':'))
                newFile = HRTF;
            else
                newFile = fullfile(pathHRTF, HRTF);
            end
            
            if exist(newFile, 'file')
                obj.fileHRTF = newFile;
                obj.rpf_ini.SetValues('Global', 'ProjectPath_HRTFDB', obj.fileHRTF);
                obj.rpf_ini.WriteFile(obj.ravenProjectFile);
            else
                error(['File not found: ' newFile]);
            end
        end
        
        % [ImageSources] %
        %------------------------------------------------------------------
        function setISOrder_PS(obj, is_order)
            obj.ISOrder_PS          = is_order;
            obj.rpf_ini.SetValues('ImageSources', 'ISOrder_PS', is_order);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setISOrder_SS(obj, is_order)
            obj.ISOrder_SS          = is_order;
            obj.rpf_ini.SetValues('ImageSources', 'ISOrder_SS', is_order);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSkipDirectSound(obj, skipit)
            obj.ISSkipDirectSound   = skipit;
            obj.rpf_ini.SetValues('ImageSources', 'ISSkipDirectSound', skipit);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        % [RayTracing] %
        %------------------------------------------------------------------
        function setNumParticles(obj, num_particles)
            obj.numParticles_Sphere = num_particles;
            obj.rpf_ini.SetValues('RayTracing', 'numberOfParticles_DetectionSphere', num_particles);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setNumParticles_Portal(obj, num_particles)
            obj.numParticles_Portal = num_particles;
            obj.rpf_ini.SetValues('RayTracing', 'numberOfParticles_Portal', num_particles);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setEnergyLoss(obj, energyloss)
            obj.energyLoss_Sphere = energyloss;
            obj.rpf_ini.SetValues('RayTracing', 'energyLoss_DetectionSphere', energyloss);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setEnergyLoss_Portal(obj, energyloss)
            obj.energyLoss_Portal = energyloss;
            obj.rpf_ini.SetValues('RayTracing', 'energyLoss_Portal', energyloss);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end        
        
        %------------------------------------------------------------------
        function setTimeSlotLength(obj, slotlength)   % set timeslot lengt in ms !
            obj.timeSlotLength = slotlength;
            obj.rpf_ini.SetValues('RayTracing', 'timeResolution_DetectionSphere', slotlength);
            obj.rpf_ini.SetValues('RayTracing', 'timeResolution_Portal', slotlength);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setRadiusDetectionSphere(obj, radius)
            obj.radiusSphere        = radius;
            obj.rpf_ini.SetValues('RayTracing', 'radius_DetectionSphere', radius);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        % [Filter] %
        %------------------------------------------------------------------
        function setFilterLength(obj, filter_length)    % filter length parameter needed in [ms]
            if filter_length < 3
                filter_length = filter_length * 1000;
                filter_length = fix(filter_length);
                disp(['Filter length should be set in milliseconds. Filter Length now set to ' num2str(filter_length) ' ms.']);
            else
                filter_length = fix(filter_length);
            end
            
            obj.filterLength = filter_length;
            obj.rpf_ini.SetValues('RayTracing', 'filterLength_DetectionSphere', filter_length);
            obj.rpf_ini.SetValues('RayTracing', 'filterLength_Portal', filter_length);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setFilterLengthToReverbTime(obj, roomID)
            % get approximate reverberation time and set filter length accordingly
            if iscell(obj.modelFileList)
                if (nargin < 2)
                    disp('Please define which room should be used. Now using the first room (roomID = 0).');
                    roomID = 0;
                end
                if isempty(obj.model)
                    roommodel = load_ac3d(obj.modelFileList{roomID + 1});
                else
                    roommodel = obj.model{roomID + 1};
                end
            else
                if isempty(obj.model)
                    roommodel = load_ac3d(obj.modelFileList);
                else
                    roommodel = obj.model;
                end
            end
            
            RT = roommodel.getReverbTime(obj.pathMaterials);
            filter_length = max(RT) * 1.2 * 1000;     % filter length parameter needed in [ms] and 20% additional headroom
            obj.setFilterLength(filter_length);
        end
        
        %------------------------------------------------------------------
        function setFixPoissonSequence(obj, fixit)
            obj.fixPoissonSequence = fixit;
            obj.rpf_ini.SetValues('Filter', 'setFixPoissonSequence', fixit);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setPoissonSequenceNumber(obj, number)
            obj.poissonSequenceNumber = number;
            obj.rpf_ini.SetValues('Filter', 'poissonSequenceNumber', number);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setFilterResolution(obj, octOr3rd)
            %setFilterResolution(obj, octOr3rd)
            % 1 = Octave (or 'oct'), 0 = 3rd Octave (or '3rd')
            if ~isnumeric(octOr3rd)
                octOr3rd = double(strcmp(octOr3rd, 'oct'));
                if ~octOr3rd
                    octOr3rd = double(strcmp(octOr3rd, '3rd'));
                end
            end
            obj.filterResolution = octOr3rd;
            obj.rpf_ini.SetValues('Filter', 'filterResolution', octOr3rd);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setFixReflectionPattern(obj, fixit)
            obj.fixReflectionPattern = fixit;
            obj.rpf_ini.SetValues('RayTracing', 'fixReflectionPattern', fixit);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setAmbisonicsOrder(obj, order)
            obj.ambisonicsOrder = order;
            obj.rpf_ini.SetValues('Filter', 'ambisonicsOrder', order);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setNumberSpreadedSources(obj, numberSpreadedSrc)
            obj.numberSpreadedSources = numberSpreadedSrc;
            obj.rpf_ini.SetValues('Filter', 'numberSpreadedSources', numberSpreadedSrc);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setSpreadingStdDeviation(obj, spreadingStdDev)
            obj.spreadingStdDeviation = spreadingStdDev;
            obj.rpf_ini.SetValues('Filter', 'spreadingStdDeviation', spreadingStdDev);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setFftDegreeForWallFilterInterpolation(obj, fft_degree)
            obj.fftDegreeForWallFilterInterpolation = fft_degree;
            obj.rpf_ini.SetValues('Filter', 'fftDegreeForWallFilterInterpolation', fft_degree);
            obj.rpf_ini.WriteFile(obj.ravenProjectFile);
        end
        
        %------------------------------------------------------------------
        function setMaterial(obj, materialname, alpha, scatter, roomID)
            %
            %   setMaterial(materialname, alpha, scatter, roomID)
            %
            %       materialname can be the filename of the .mat file (without
            %           extension or a number to address the material ID if the
            %           current room (can be further specified by roomID).
            %
            %       alpha and scatter have to be size of
            %           - 31 elements (for one-third octave resolution)
            %           - 10 elements (for octave resolution)
            %           - or a single number (flat spectrum)
            
            if nargin < 4
                scatter = 0.3;
            end
            
            % check if a material ID was given instead of a material name
            if isnumeric(materialname)
                % addressing by material ID (which is dependent on the room that is currently loaded!)
                matID = materialname;
                if nargin < 5
                    roomID = 0;
                end
                materialsInCurrentRoom = obj.getRoomMaterialNames(roomID);
                matname = materialsInCurrentRoom{matID + 1};
            else
                matname = materialname;
            end
            
            mat_filename = fullfile(obj.pathMaterials, [matname '.mat']);
            
            % open file for writing
            fid = fopen(mat_filename, 'wt');
            % print header
            fprintf(fid, '[Material]\r\n');
            fprintf(fid, ['name=' matname '\r\n']);
            fprintf(fid, ['notes=Generated/Modified by MATLAB script (' datestr(now) ')\r\n']);
            
            % parse input data
            if length(alpha) == 1
                alpha = ones(1,31) * alpha;
            elseif length(alpha) ~= 31 && length(alpha) ~= 10
                disp('ERROR! alpha has to be a vector with the length 1,10, or 31.');
                return;
            end
            if length(scatter) == 1
                scatter = ones(1,31) * scatter;
            elseif length(scatter) ~= 31 && length(scatter) ~= 10
                disp('ERROR! scatter has to be a vector with the length 1,10, or 31.');
                return;
            end
            
            % print absorption values
            if length(alpha)==31
                fprintf(fid, ['absorp=' num2str(alpha(1), '%2.4f')]);
                for i = 1 : 30
                    fprintf(fid, [', ' num2str(alpha(i+1), '%2.4f')]);
                end
            else
                fprintf(fid, ['absorp=' num2str(alpha(1), '%2.4f')]);
                for i = 1 : 30
                    fprintf(fid, [', ' num2str(alpha(int32(i+1)/3), '%2.4f')]);
                end
            end
            fprintf(fid, '\r\n');
            
            % print scattering values
            if length(scatter)==31
                fprintf(fid, ['scatter=' num2str(scatter(1), '%2.4f')]);
                for i = 1 : 30
                    fprintf(fid, [', ' num2str(scatter(i+1), '%2.4f')]);
                end
            else
                fprintf(fid, ['scatter=' num2str(scatter(1), '%2.4f')]);
                for i = 1 : 30
                    fprintf(fid, [', ' num2str(scatter(int32(i+1)/3), '%2.4f')]);
                end
            end
            fprintf(fid, '\r\n');
            
            % print interpolation values
            if length(alpha)==31
                fprintf(fid, 'interpol=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0\r\n');
            else
                fprintf(fid, 'interpol=1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1\r\n');
            end
            
            % close file
            fclose(fid);
        end
        
        %------------------------------------------------------------------
        function order = getAmbisonicsOrder(obj)
            order = obj.rpf_ini.GetValues('Filter', 'ambisonicsOrder', -1);
        end
        
        %------------------------------------------------------------------
        function numberSpreadedSources = getNumberSpreadedSources(obj)
            numberSpreadedSources = obj.rpf_ini.GetValues('Filter', 'numberSpreadedSources', 0);
        end
        
        %------------------------------------------------------------------
        function spreadingStdDeviation = getSpreadingStdDeviation(obj)
            spreadingStdDeviation = obj.rpf_ini.GetValues('Filter', 'spreadingStdDeviation', 0.2);
        end
        
        %------------------------------------------------------------------
        function sourceviewvectors = getSourceViewVectors(obj,srcID)
            
            all_pos = obj.rpf_ini.GetValues('PrimarySources', 'sourceViewVectors');
            if (nargin < 2)
                sourceviewvectors=reshape(all_pos',3,length(all_pos)/3)';
            else
                sourceviewvectors = all_pos((srcID*3 + 1) : (srcID*3 + 3));
            end
        end
        
        %------------------------------------------------------------------
        function suv = getSourceUpVectors(obj,srcID)
            
            all_pos = obj.rpf_ini.GetValues('PrimarySources', 'sourceUpVectors');
            
            if (nargin < 2)
                suv = reshape(all_pos',3,length(all_pos)/3)';
            else
                suv = all_pos((srcID*3 + 1) : (srcID*3 + 3));
            end
            
        end
        
        %------------------------------------------------------------------
        function sss = getSourceSoundStates(obj,srcID)
            sss = obj.rpf_ini.GetValues('PrimarySources', 'sourceSoundStates', -1);
            if nargin==2
                sss=sss(srcID);
            end
        end
        
        %------------------------------------------------------------------
        function ssl = getSourceSoundLevels(obj,srcID)
            ssl = obj.rpf_ini.GetValues('PrimarySources', 'sourceSoundLevels', -1);
            if nargin==2
                ssl=ssl(srcID);
            end
        end
        
        %------------------------------------------------------------------
        function sn = getSourceNames(obj,srcID)
            sn = obj.rpf_ini.GetValues('PrimarySources', 'sourceNames', -1);
            sn = textscan(sn, '%s', 'Delimiter', ',');
            sn = sn{1};
            if nargin==2
                sn=sn{1}{srcID};
            end
        end
        
        %------------------------------------------------------------------
        function [absorp, scatter] = getMaterial(obj, materialName, roomID)
            % check if a material ID was given instead of a material name
            if isnumeric(materialName)
                % addressing by material ID (which is dependent on the room that is currently loaded!)
                matID = materialName;
                if nargin < 3
                    roomID = 0;
                end
                materialsInCurrentRoom = obj.getRoomMaterialNames(roomID);
                matname = materialsInCurrentRoom{matID + 1};
            else
                if (numel(materialName) > 4) && isequal(materialName(end-3:end), '.mat')
                    materialName = materialName(1:end-4);
                end
                matname = materialName;
            end
            
            ini = IniConfig();
            ini.ReadFile(fullfile(obj.pathMaterials, [matname '.mat']));
            
            absorp = ini.GetValues('Material', 'absorp');
            
            if nargout > 1
                scatter = ini.GetValues('Material', 'scatter');
            end
        end
        
        %------------------------------------------------------------------
        function monauralIR = getMonauralImpulseResponse(obj)
            if isempty(obj.monauralIR)
                error('No monaural impulse response present.');
            end
            
            if numel(obj.monauralIR) > 1
                monauralIR = obj.monauralIR;
            else
                monauralIR = obj.monauralIR{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function monauralIRitaAudio = getMonauralImpulseResponseItaAudio(obj)
            if isempty(obj.monauralIR)
                error('No monaural impulse response present.');
            end
            
            monauralIRitaAudio = itaAudio(size(obj.monauralIR));
            
            for iSrc = 1 : size(obj.monauralIR, 1)
                for iRec = 1 : size(obj.monauralIR, 2)
                    monauralIRitaAudio(iSrc,iRec).timeData = obj.monauralIR{iSrc,iRec};
                    monauralIRitaAudio(iSrc,iRec).samplingRate = obj.sampleRate;
                    monauralIRitaAudio(iSrc,iRec).signalType = 'energy';
                    monauralIRitaAudio(iSrc,iRec).channelNames{1} = obj.receiverNames{iRec};
                end
            end
        end
        
        %------------------------------------------------------------------
        function monauralIR_IS = getMonauralImpulseResponseImageSources(obj)
            if isempty(obj.monauralIR_IS)
                error('No monaural image source impulse response present.');
            end
            
            if numel(obj.monauralIR_IS) > 1
                monauralIR_IS = obj.monauralIR_IS;
            else
                monauralIR_IS = obj.monauralIR_IS{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function monauralIR_RT = getMonauralImpulseResponseRayTracing(obj)
            if isempty(obj.monauralIR_RT)
                error('No monaural ray tracing impulse response present.');
            end
            
            if numel(obj.monauralIR_RT) > 1
                monauralIR_RT = obj.monauralIR_RT;
            else
                monauralIR_RT = obj.monauralIR_RT{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function monauralIRitaAudio = getMonauralImpulseResponseImageSourcesItaAudio(obj)
            if isempty(obj.monauralIR_IS)
                error('No monaural image source impulse response present.');
            end
            
            monauralIRitaAudio = itaAudio(size(obj.monauralIR_IS));
            
            for iSrc = 1 : size(obj.monauralIR_IS, 1)
                for iRec = 1 : size(obj.monauralIR_IS, 2)
                    monauralIRitaAudio(iSrc,iRec).timeData = obj.monauralIR_IS{iSrc,iRec};
                    monauralIRitaAudio(iSrc,iRec).samplingRate = obj.sampleRate;
                    monauralIRitaAudio(iSrc,iRec).signalType = 'energy';
                    monauralIRitaAudio(iSrc,iRec).channelNames{1} = obj.receiverNames{iRec};
                end
            end
        end
        
        %------------------------------------------------------------------
        function monauralIRitaAudio = getMonauralImpulseResponseRayTracingItaAudio(obj)
            if isempty(obj.monauralIR_RT)
                error('No monaural ray tracing impulse response present.');
            end
            
            monauralIRitaAudio = itaAudio(size(obj.monauralIR_RT));
            
            for iSrc = 1 : size(obj.monauralIR_RT, 1)
                for iRec = 1 : size(obj.monauralIR_RT, 2)
                    monauralIRitaAudio(iSrc,iRec).timeData = obj.monauralIR_RT{iSrc,iRec};
                    monauralIRitaAudio(iSrc,iRec).samplingRate = obj.sampleRate;
                    monauralIRitaAudio(iSrc,iRec).signalType = 'energy';
                    monauralIRitaAudio(iSrc,iRec).channelNames{1} = obj.receiverNames{iRec};
                end
            end
        end
        
        %------------------------------------------------------------------
        function binauralIR = getBinauralImpulseResponse(obj)
            if isempty(obj.binauralIR)
                error('No binaural impulse response present.');
            end
            
            if numel(obj.binauralIR) > 1
                binauralIR = obj.binauralIR;
            else
                binauralIR = obj.binauralIR{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function binauralIRitaAudio = getBinauralImpulseResponseItaAudio(obj)
            if isempty(obj.binauralIR)
                error('No binaural impulse response present.');
            end
            
            binauralIRitaAudio = itaAudio(size(obj.binauralIR));
            
            for iSrc = 1 : size(obj.binauralIR, 1)
                for iRec = 1 : size(obj.binauralIR, 2)
                    binauralIRitaAudio(iSrc,iRec).timeData = obj.binauralIR{iSrc,iRec};
                    binauralIRitaAudio(iSrc,iRec).samplingRate = obj.sampleRate;
                    binauralIRitaAudio(iSrc,iRec).signalType = 'energy';
                    binauralIRitaAudio(iSrc,iRec).channelNames{1} = [obj.receiverNames{iRec} '_Left'];
                    binauralIRitaAudio(iSrc,iRec).channelNames{2} = [obj.receiverNames{iRec} '_Right'];
                end
            end
        end
        
        %------------------------------------------------------------------
        function binauralIR_IS = getBinauralImpulseResponseImageSources(obj)
            if isempty(obj.binauralIR_IS)
                error('No binaural image source impulse response present.');
            end
            
            if numel(obj.binauralIR_IS) > 1
                binauralIR_IS = obj.binauralIR_IS;
            else
                binauralIR_IS = obj.binauralIR_IS{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function binauralIRitaAudio = getBinauralImpulseResponseImageSourcesItaAudio(obj)
            if isempty(obj.binauralIR_IS)
                error('No binaural image source impulse response present.');
            end
            
            binauralIRitaAudio = itaAudio(size(obj.binauralIR_IS));
            
            for iSrc = 1 : size(obj.binauralIR_IS, 1)
                for iRec = 1 : size(obj.binauralIR_IS, 2)
                    binauralIRitaAudio(iSrc,iRec).timeData = obj.binauralIR_IS{iSrc,iRec};
                    binauralIRitaAudio(iSrc,iRec).samplingRate = obj.sampleRate;
                    binauralIRitaAudio(iSrc,iRec).signalType = 'energy';
                    binauralIRitaAudio(iSrc,iRec).channelNames{1} = [obj.receiverNames{iRec} '_Left'];
                    binauralIRitaAudio(iSrc,iRec).channelNames{2} = [obj.receiverNames{iRec} '_Right'];
                end
            end
        end
        
        %------------------------------------------------------------------
        function binauralIR_RT = getBinauralImpulseResponseRayTracing(obj)
            if isempty(obj.binauralIR_RT)
                error('No binaural ray tracing impulse response present.');
            end
            
            if numel(obj.binauralIR_RT) > 1
                binauralIR_RT = obj.binauralIR_RT;
            else
                binauralIR_RT = obj.binauralIR_RT{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function binauralIRitaAudio = getBinauralImpulseResponseRayTracingItaAudio(obj)
            if isempty(obj.binauralIR_RT)
                error('No binaural image source impulse response present.');
            end
            
            binauralIRitaAudio = itaAudio(size(obj.binauralIR_RT));
            
            for iSrc = 1 : size(obj.binauralIR_RT, 1)
                for iRec = 1 : size(obj.binauralIR_RT, 2)
                    binauralIRitaAudio(iSrc,iRec).timeData = obj.binauralIR_RT{iSrc,iRec};
                    binauralIRitaAudio(iSrc,iRec).samplingRate = obj.sampleRate;
                    binauralIRitaAudio(iSrc,iRec).signalType = 'energy';
                    binauralIRitaAudio(iSrc,iRec).channelNames{1} = [obj.receiverNames{iRec} '_Left'];
                    binauralIRitaAudio(iSrc,iRec).channelNames{2} = [obj.receiverNames{iRec} '_Right'];
                end
            end
        end
        
        %------------------------------------------------------------------
        function binauralPoissonSequenceitaAudio = getBinauralPoissonSequenceItaAudio(obj)
            
            data = load([ obj.pathResults '\binauralPoissonNoiseProcess.txt']);
            
            binauralPoissonSequenceitaAudio = itaAudio;
            binauralPoissonSequenceitaAudio.samplingRate = obj.sampleRate;
            binauralPoissonSequenceitaAudio.signalType = 'energy';
            binauralPoissonSequenceitaAudio.timeData = data;
            binauralPoissonSequenceitaAudio.channelNames{1} = [obj.receiverNames{end} '_Left'];
            binauralPoissonSequenceitaAudio.channelNames{2} = [obj.receiverNames{end} '_Right'];
        end
        
        %------------------------------------------------------------------
        function binauralImpulseResponse = generateBinauralImpulseResponseItaAudio(obj)
            % get noise process (containing poisson distributed HRIRs without temporal or spectral weighting)
            poisson = obj.getBinauralPoissonSequenceItaAudio();
            
            % add white noise to poisson sequence (for more realistic simulaitons
            %             noiseLevel = 10^(-20/10) * max(max(poisson.timeData));
            %             addNoise = ita_generate('whitenoise', noiseLevel, poisson.samplingRate, poisson.fftDegree);
            %             addNoise.timeData(:,2) = addNoise.timeData(:,1);    % add second channel
            %             poisson = poisson + addNoise;
            
            % get ray tracing results
            %             histo = obj.getHistogramRayTracing();
            histo = obj.histogramRT();
            if iscell(histo)
                if numel(histo) > 1
                    disp('WARNING! Generating binaural impulse response only for the last receiver!')
                end
                histo = histo{end};
            end
            
            % low pass late part of the histogram to avoid bubble sound
            histo.data = obj.applyLowPassToLatePartOfHistogram(histo.data);
            
            % convert added energy histogram to sound pressure envelope histogram and
            % time-interpolate time slot quantized histogram to full number of samples length
            histoInterpolatedToSamples = interp1(histo.timevector, sqrt(histo.data), poisson.timeVector, 'cubic');
            histoInterpolatedToSamples(histoInterpolatedToSamples < 0) = 0;
            
            %             energyScalingFactor = sum(histo.data) ./ sum(histoInterpolatedToSamples); % is vector of frequencies, sums up the time slots
            %             energyScalingFactor(isnan(energyScalingFactor)) = 0;
            %             histoInterpolatedToSamples = histoInterpolatedToSamples .* repmat(energyScalingFactor, poisson.nSamples, 1);
            
            % band-pass poisson sequence
            if size(histo.data, 2) == 10
                poissonFilteredLeft = ita_mpb_filter(poisson.ch(1), 'oct', 1, 'order', 6);
                poissonFilteredRight = ita_mpb_filter(poisson.ch(2), 'oct', 1, 'order', 6);
            else
                poissonFilteredLeft = ita_mpb_filter(poisson.ch(1), 'oct', 3, 'order', 6);
                poissonFilteredRight = ita_mpb_filter(poisson.ch(2), 'oct', 3, 'order', 6);
                % toolbox 30 thirdocts vs. ravens 31 thirdocts, delete 20 Hz data
                histoInterpolatedToSamples(:, 1) = [];
            end
            
            % temporal shaping of the poisson sequence using the sound presssure envelope from the histogram
            poissonFilteredLeft.timeData(:, :) = poissonFilteredLeft.timeData(:,:) .* histoInterpolatedToSamples;
            poissonFilteredRight.timeData(:, :) = poissonFilteredRight.timeData(:, :) .* histoInterpolatedToSamples;
            
            % create new itaAudio to store resulting filter
            binauralImpulseResponse = itaAudio;
            binauralImpulseResponse.samplingRate = obj.sampleRate;
            binauralImpulseResponse.signalType = 'energy';
            binauralImpulseResponse.timeData(:,:) = [sum(poissonFilteredLeft.timeData, 2) sum(poissonFilteredRight.timeData, 2)];
            
            % total energy scaling (total energy histogram == total energy impulse response of one channel)
            % convert averaged energy histogram to added energy histogram
            histo.data = obj.powerSpectrum2energySpectrum(histo.data);
            totalEnergyHistogram = sum(sum(histo.data,2));
            numTimeSlots = size(histo.data, 1);
            maxEnergyHistogram = (1 * numTimeSlots);    % 1 == EnergyAdded for one timeslot if all frequencyies are = 1
            maxEnergyPoisson = sum(poisson.timeData.^2);    % vector(2) for left and right channel
            totalEnergyImpulseResponse = sum(binauralImpulseResponse.timeData.^2);  % vector(2) for left and right channel
            binauralImpulseResponse.timeData = binauralImpulseResponse.timeData .* sqrt((maxEnergyPoisson / totalEnergyImpulseResponse) * (totalEnergyHistogram / maxEnergyHistogram));
            
            % add image sources
            BRIR_IS = obj.getBinauralImpulseResponseImageSourcesItaAudio();
            [BRIR_IS, binauralImpulseResponse] = ita_extend_dat(BRIR_IS, binauralImpulseResponse);
            binauralImpulseResponse = BRIR_IS + binauralImpulseResponse;
        end
        
        %------------------------------------------------------------------
        function ambisonicsIR = getAmbisonicsImpulseResponse(obj)
            if isempty(obj.ambisonicsIR)
                error('No ambisonics b-format impulse response present.');
            end
            
            if numel(obj.ambisonicsIR) > 1
                ambisonicsIR = obj.ambisonicsIR;
            else
                ambisonicsIR = obj.ambisonicsIR{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function ambisonicsIRita = getAmbisonicsImpulseResponseItaAudio(obj)
            if isempty(obj.ambisonicsIR)
                error('No ambisonics b-format impulse response present.');
            end
            
            ambisonicsIRita = itaAudio(size(obj.ambisonicsIR));
            
            for iSrc = 1 : size(obj.ambisonicsIR, 1)
                for iRec = 1 : size(obj.ambisonicsIR, 2)
                    ambisonicsIRita(iSrc,iRec).timeData = obj.ambisonicsIR{iSrc,iRec};
                    ambisonicsIRita(iSrc,iRec).samplingRate = obj.sampleRate;
                    ambisonicsIRita(iSrc,iRec).signalType = 'energy';
                    for linInd = 1 : ambisonicsIRita(iSrc,iRec).nChannels
                        [deg, ord] = ita_sph_linear2degreeorder(linInd);
                        ambisonicsIRita(iSrc,iRec).channelNames{linInd} = [obj.receiverNames{iRec} '_Degree(' num2str(deg) ')_Order(' num2str(ord) ')'];
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function ambisonicsIR_IS = getAmbisonicsImpulseResponseImageSources(obj)
            if isempty(obj.ambisonicsIR_IS)
                error('No image sources ambisonics b-format impulse response present.');
            end
            
            if numel(obj.ambisonicsIR_IS) > 1
                ambisonicsIR_IS = obj.ambisonicsIR_IS;
            else
                ambisonicsIR_IS = obj.ambisonicsIR_IS{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function ambisonicsIRita = getAmbisonicsImpulseResponseImageSourcesItaAudio(obj)
            if isempty(obj.ambisonicsIR_IS)
                error('No image sources ambisonics b-format impulse response present.');
            end
            
            ambisonicsIRita = itaAudio(size(obj.ambisonicsIR_IS));
            
            for iSrc = 1 : size(obj.ambisonicsIR_IS, 1)
                for iRec = 1 : size(obj.ambisonicsIR_IS, 2)
                    ambisonicsIRita(iSrc,iRec).timeData = obj.ambisonicsIR_IS{iSrc,iRec};
                    ambisonicsIRita(iSrc,iRec).samplingRate = obj.sampleRate;
                    ambisonicsIRita(iSrc,iRec).signalType = 'energy';
                    for linInd = 1 : ambisonicsIRita(iSrc,iRec).nChannels
                        [deg, ord] = ita_sph_linear2degreeorder(linInd);
                        ambisonicsIRita(iSrc,iRec).channelNames{linInd} = [obj.receiverNames{iRec} '_Degree(' num2str(deg) ')_Order(' num2str(ord) ')'];
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function ambisonicsIR_RT = getAmbisonicsImpulseResponseRayTracing(obj)
            if isempty(obj.ambisonicsIR_RT)
                error('No ray tracing ambisonics b-format impulse response present.');
            end
            
            if numel(obj.ambisonicsIR_RT) > 1
                ambisonicsIR_RT = obj.ambisonicsIR_RT;
            else
                ambisonicsIR_RT = obj.ambisonicsIR_RT{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function ambisonicsIRita = getAmbisonicsImpulseResponseRayTracingItaAudio(obj)
            if isempty(obj.ambisonicsIR_RT)
                error('No ray tracing ambisonics b-format impulse response present.');
            end
            
            ambisonicsIRita = itaAudio(size(obj.ambisonicsIR_RT));
            
            for iSrc = 1 : size(obj.ambisonicsIR_RT, 1)
                for iRec = 1 : size(obj.ambisonicsIR_RT, 2)
                    ambisonicsIRita(iSrc,iRec).timeData = obj.ambisonicsIR_RT{iSrc,iRec};
                    ambisonicsIRita(iSrc,iRec).samplingRate = obj.sampleRate;
                    ambisonicsIRita(iSrc,iRec).signalType = 'energy';
                    for linInd = 1 : ambisonicsIRita(iSrc,iRec).nChannels
                        [deg, ord] = ita_sph_linear2degreeorder(linInd);
                        ambisonicsIRita(iSrc,iRec).channelNames{linInd} = [obj.receiverNames{iRec} '_Degree(' num2str(deg) ')_Order(' num2str(ord) ')'];
                    end
                end
            end
            
        end
        
        %------------------------------------------------------------------
        function vbapIR = getVBAPImpulseResponse(obj)
            if isempty(obj.vbapIR)
                error('No vbap impulse response present.');
            end
            
            if numel(obj.vbapIR) > 1
                vbapIR = obj.vbapIR;
            else
                vbapIR = obj.vbapIR{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function vbapIRita = getVBAPImpulseResponseItaAudio(obj)
            if isempty(obj.vbapIR)
                error('No vbap impulse response present.');
            end
            
            vbapIRita = itaAudio(size(obj.vbapIR));
            
            for iSrc = 1 : size(obj.vbapIR, 1)
                for iRec = 1 : size(obj.vbapIR, 2)
                    vbapIRita(iSrc,iRec).timeData = obj.vbapIR{iSrc,iRec};
                    vbapIRita(iSrc,iRec).samplingRate = obj.sampleRate;
                    vbapIRita(iSrc,iRec).signalType = 'energy';
                    for linInd = 1 : vbapIRita(iSrc,iRec).nChannels
                        vbapIRita(iSrc,iRec).channelNames{linInd} = [obj.receiverNames{iRec} '_Speaker_' num2str(linInd)];
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function vbapIR_IS = getVBAPImpulseResponseImageSources(obj)
            if isempty(obj.vbapIR_IS)
                error('No image sources vbap impulse response present.');
            end
            
            if numel(obj.vbapIR_IS) > 1
                vbapIR_IS = obj.vbapIR_IS;
            else
                vbapIR_IS = obj.vbapIR_IS{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function vbapIRita = getVBAPImpulseResponseImageSourcesItaAudio(obj)
            if isempty(obj.vbapIR_IS)
                error('No image sources vbap impulse response present.');
            end
            
            vbapIRita = itaAudio(size(obj.vbapIR_IS));
            
            for iSrc = 1 : size(obj.vbapIR_IS, 1)
                for iRec = 1 : size(obj.vbapIR_IS, 2)
                    vbapIRita(iSrc,iRec).timeData = obj.vbapIR_IS{iSrc,iRec};
                    vbapIRita(iSrc,iRec).samplingRate = obj.sampleRate;
                    vbapIRita(iSrc,iRec).signalType = 'energy';
                    for linInd = 1 : vbapIRita(iSrc,iRec).nChannels
                        vbapIRita(iSrc,iRec).channelNames{linInd} = [obj.receiverNames{iRec} '_Speaker_' num2str(linInd)];
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function vbapIR_RT = getVBAPImpulseResponseRayTracing(obj)
            if isempty(obj.vbapIR_RT)
                error('No ray tracing vbap impulse response present.');
            end
            
            if numel(obj.vbapIR_RT) > 1
                vbapIR_RT = obj.vbapIR_RT;
            else
                vbapIR_RT = obj.vbapIR_RT{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function vbapIRita = getVBAPImpulseResponseRayTracingItaAudio(obj)
            if isempty(obj.vbapIR_RT)
                error('No ray tracing vbap impulse response present.');
            end
            
            vbapIRita = itaAudio(size(obj.vbapIR_RT));
            
            for iSrc = 1 : size(obj.vbapIR_RT, 1)
                for iRec = 1 : size(obj.vbapIR_RT, 2)
                    vbapIRita(iSrc,iRec).timeData = obj.vbapIR_RT{iSrc,iRec};
                    vbapIRita(iSrc,iRec).samplingRate = obj.sampleRate;
                    vbapIRita(iSrc,iRec).signalType = 'energy';
                    for linInd = 1 : vbapIRita(iSrc,iRec).nChannels
                        vbapIRita(iSrc,iRec).channelNames{linInd} = [obj.receiverNames{iRec} '_Speaker_' num2str(linInd)];
                    end
                end
            end
            
        end
        
        %------------------------------------------------------------------
        function histo = getHistogram(obj)
            if isempty(obj.histogram)
                error('No histogram present.');
            end
            
            if numel(obj.histogramRT) > 1
                histo = obj.histogram;
            else
                histo = obj.histogram{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function histo = getHistogram_itaResult(obj)
            histo_data = obj.getHistogram();
            
            if ~iscell(histo_data)
                histo_data = {histo_data};
            end
            
            % pre-alloc multi-instance for all sources and receivers
            histo(size(obj.histogram,1), size(obj.histogram,2)) = itaResult();
            for iHisto = 1 : numel(obj.histogram)
                if ~isempty(obj.histogram{iHisto})
                    histo(iHisto).timeData = histo_data{iHisto}.data;
                    histo(iHisto).timeVector = histo_data{iHisto}.timevector;
                    if obj.filterResolution == 1
                        histo(iHisto).channelNames = strcat('Histogram ', obj.freqLabelOct);
                    else
                        histo(iHisto).channelNames = strcat('Histogram ', obj.freqLabel3rd);
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function histo = getHistogramRayTracing(obj)
            if isempty(obj.histogramRT)
                raytracing_histo_files = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), '_RT', '.hst');
                % read the histogram files back from disk
                obj.histogramRT = obj.readHistogram(raytracing_histo_files);
            end
            
            if numel(obj.histogramRT) > 1
                histo = obj.histogramRT;
            else
                histo = obj.histogramRT{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function histo = getHistogramEnergyAdded(obj)
            if isempty(obj.histogram)
                error('No histogram present.');
            end
            
            numberFrequencyBands = size(obj.histogram{find(~cellfun(@isempty, obj.histogram), 1)}.data, 2);
            numberTimeSteps = size(obj.histogram{find(~cellfun(@isempty, obj.histogram), 1)}.data, 1);
            
            if numberFrequencyBands == 10
                centerFreqs = [31.25,   62.50,  125.00,  250.00,  500.00, 1000.00, 2000.00, 4000.00, 8000.00,16000.00];
                lowerBandLimits = centerFreqs / sqrt(2);
                upperBandLimits = centerFreqs * sqrt(2);
                bandWidths = upperBandLimits - lowerBandLimits;
                
                %bandWidths = [0.0010    0.0020    0.0041    0.0082    0.0163    0.0326    0.0652    0.1302    0.2591    0.4870];
                %bandWidths = [44.2    44.2    88.4   176.8   353.5   707.1  1414.2  2828.5  5656.9 11313.8];
            elseif numberFrequencyBands == 31
                centerFreqs = [19.686,   24.803,   31.250,   39.373,   49.606,   62.500,   78.745,   99.213,  125.000,  157.490,  198.425,  250.000,  314.980,  396.850,  500.000,  629.961,  793.701, 1000.000, 1259.921, 1587.401, 2000.000, 2519.842, 3174.802, 4000.000, 5039.684, 6349.604, 8000.000,10079.368,12699.208,16000.000,20158.737];
                lowerBandLimits = centerFreqs / sqrt(2);
                upperBandLimits = centerFreqs * sqrt(2);
                bandWidths = upperBandLimits - lowerBandLimits;
                
                %bandWidths = [0.0002095384,0.0002644467,0.0003336922,0.0004203726,0.0005296132,0.0006672770,0.0008407238,0.0010592415,0.0013345612,0.0016814420,0.0021184840,0.0026691217,0.0033628807,0.0042369610,0.0053382298,0.0067257351,0.0084738691,0.0106763538,0.0134512584,0.0169473147,0.0213518612,0.0269008258,0.0338912528,0.0426969859,0.0537882314,0.0677558315,0.0853411434,0.1074724174,0.1353085098,0.1702908522,0.1861151317];
                %bandWidths = [22.4    5.5    7.2    9.1   11.4   14.5   18.3   23.0   28.9   36.5   46.0   57.9   72.9   91.8  115.8  145.9  183.8  231.6  291.7  367.6  463.1  583.5  735.2  926.3 1167.0 1470.4 1852.5 2334.0 2941.2 3705.0 4667.6];
            else
                error('Unkown frequency resolution.');
            end
            
            bandWidthTotal = sum(bandWidths);
            
            histo = obj.histogram;
            for iHisto = 1 : numel(histo)
                histo{iHisto}.data = histo{iHisto}.data(:,:) .* repmat(bandWidths./bandWidthTotal, numberTimeSteps, 1);
                %                 disp('ACHTUNG! Histogramm ist nicht von energy averaged auf energy added konvertiert worden!');
            end
            
            if numel(histo) < 2
                histo = histo{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function histo = getHistogramRayTracingEnergyAdded(obj)
            if isempty(obj.histogramRT)
                error('No ray tracing histogram present.');
            end
            
            numberFrequencyBands = size(obj.histogramRT{find(~cellfun(@isempty, obj.histogramRT), 1)}.data, 2);
            numberTimeSteps = size(obj.histogramRT{find(~cellfun(@isempty, obj.histogramRT), 1)}.data, 1);
            
            if numberFrequencyBands == 10
                bandWidths = [44.2    44.2    88.4   176.8   353.5   707.1  1414.2  2828.5  5656.9 11313.8];
            elseif numberFrequencyBands == 31
                bandWidths = [22.4    5.5    7.2    9.1   11.4   14.5   18.3   23.0   28.9   36.5   46.0   57.9   72.9   91.8  115.8  145.9  183.8  231.6  291.7  367.6  463.1  583.5  735.2  926.3 1167.0 1470.4 1852.5 2334.0 2941.2 3705.0 4667.6];
            else
                error('Unkown frequency resolution.');
            end
            
            bandWidthTotal = sum(bandWidths);
            
            histo = obj.histogramRT;
            for iHisto = 1 : numel(histo)
                histo{iHisto}.data = histo{iHisto}.data .* repmat(bandWidths./bandWidthTotal, numberTimeSteps, 1);
                %                 disp('ACHTUNG! Histogramm ist nicht von energy averaged auf energy added konvertiert worden!');
            end
            
            if numel(histo) < 2
                histo = histo{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function wall_log = getWallHitLog_IS(obj, logFile)
            if (nargin < 2) && isempty(obj.wallHitLog_IS)
                error('No wall hit log present.');
            end
            
            if nargin > 1
                obj.wallHitLog_IS = obj.readWallHitLog_IS(logFile);
            end
            
            if numel(obj.wallHitLog_IS) > 1
                wall_log = obj.wallHitLog_IS;
            else
                wall_log = obj.wallHitLog_IS{1,1};
            end
        end

        %------------------------------------------------------------------
        function planewaves = getPlaneWaves_IS(obj, sourceID, receiverID)
            %
            % planewaves = getPlaneWaves_IS(sourceID, receiverID)
            %
            %   Returns the plane waves of the image source simulation.
            %   The returned freqData values are linear absolute sound pressure.
            %       sourceID   : optional ID of the sound source
            %       receiverID : optional ID of the receiver
            %                    (counting starts with zero)

            if isempty(obj.planeWaveList_IS)
                error('No plane wave list present. Activate using RavenProject.setExportPlaneWaveList(1).');
            end

            if numel(obj.planeWaveList_IS) > 1
                if nargin > 1
                    if nargin > 2
                        planewaves = obj.planeWaveList_IS{sourceID+1, receiverID+1};    % 2 arguments
                    else
                        planewaves = obj.planeWaveList_IS{sourceID+1, :};               % 1 argument
                    end
                else
                    planewaves = obj.planeWaveList_IS;                                  % 0 argument - return whole cell array
                end
            else
                planewaves = obj.planeWaveList_IS{1,1};                                 % 0 argument - return single entry
            end
        end
        
        %------------------------------------------------------------------
        function planewaves = getPlaneWaves_RT(obj, sourceID, receiverID)
            %
            % planewaves = getPlaneWaves_RT(sourceID, receiverID)
            %
            %   Returns the plane waves of the ray tracing simulation.
            %   The returned freqData values are linear absolute sound pressure.
            %       sourceID   : optional ID of the sound source
            %       receiverID : optional ID of the receiver
            %                    (counting starts with zero)
            
            if isempty(obj.planeWaveList_RT)
                error('No plane wave list present. Activate using RavenProject.setExportPlaneWaveList(1).');
            end

            if numel(obj.planeWaveList_RT) > 1
                if nargin > 1
                    if nargin > 2
                        planewaves = obj.planeWaveList_RT{sourceID+1, receiverID+1};    % 2 arguments
                    else
                        planewaves = obj.planeWaveList_RT{sourceID+1, :};               % 1 argument
                    end
                else
                    planewaves = obj.planeWaveList_RT;                                  % 0 argument - return whole cell array
                end
            else
                planewaves = obj.planeWaveList_RT{1,1};                                 % 0 argument - return single entry
            end
        end
        
        %------------------------------------------------------------------
        function histo = buildHybridHistogramFromWallHitLogs(obj)
            % evaluate ray tracer wall hit log files and build histogram
            histo = obj.buildRTHistogramFromWallHitLog();
            
            % evaluate image sources wall hit log files and add data to ray tracing histogram
            %             histo = obj.addISEnergyToRTHistogram(histo);
            disp('IS disabled so far...');
        end
        
        %------------------------------------------------------------------
        function histo = buildRTHistogramFromWallHitLog(obj)
            % check if data is present
            if numel(obj.wallHitLog_RT) < 1
                error('No wall hit log present.');
            end
            
            % number of time steps
            numTimeSteps = ceil((obj.filterLength + 100)/ obj.timeSlotLength + 0.5);
            
            % calculate sound speed
            soundspeed = calculateSoundSpeed(obj.getTemperature, obj.getHumidity, obj.getPressure);
            
            % get mean particle running distance for each timeslot
            distance = (1:numTimeSteps)' * (0.5*obj.timeSlotLength/1000) * soundspeed;
            
            % calculate air absorption
            airAbsorption = determineAirAbsorptionParameter(obj.getTemperature, obj.getPressure, obj.getHumidity);
            
            % get number of sources and receivers and frequecy bands
            numSources   = size(obj.wallHitLog_RT, 1);
            numReceivers = size(obj.wallHitLog_RT, 2);
            numFreqBands = size(obj.wallHitLog_RT, 3);
            
            % build material database
            roomMaterialNames = obj.getRoomMaterialNames();
            numMaterials = numel(roomMaterialNames);
            materialMatrixAbsorption = zeros(numMaterials, 31);
            materialMatrixScattering = zeros(numMaterials, 31);
            for iMat = 1 : numMaterials
                [abso, scat] = readRavenMaterial(roomMaterialNames{iMat});
                if ~isempty(abso)
                    materialMatrixAbsorption(iMat,:) = abso;
                    materialMatrixScattering(iMat,:) = scat;
                else
                    error('Material not found.');
                end
            end
            
            % prepare histograms
            histo = cell(numSources, numReceivers);
            for iSrc = 1 : numSources
                for iRec = 1 : numReceivers
                    histo{iSrc,iRec}.sourcename   = obj.sourceNames{iSrc};
                    histo{iSrc,iRec}.receivername = obj.receiverNames{iSrc};
                    histo{iSrc,iRec}.timevector   = (0:(numTimeSteps-1))' * obj.timeSlotLength;
                    histo{iSrc,iRec}.data         = zeros(numTimeSteps, numFreqBands);
                    
                    for iBand = 1 : numFreqBands
                        % translate octave/third-octave indices
                        if numFreqBands == 10
                            thirdOctIndex = (iBand-1)*3+3;   % transfer functions, air absorption etc. is always in third octave resolution. this translates octaves to third octaves if necessary
                        else
                            thirdOctIndex = iBand;
                        end
                        
                        
                        % distance: Vector (numTimeslots x 1) vorher definieren mit der jeweiligen
                        % mittleren distanz eines zeitslots
                        
                        % mean energy loss due to air absorption for each time slot
                        airAbs = exp(- (airAbsorption(thirdOctIndex)) * distance);
                        
                        % use logarithm so that number of wall hits can be multiplied
                        %M = exp(obj.wallHitLog_RT{iSrc,iRec,iBand} * log(1 - materialMatrixAbsorption(:,iBand)));
                        M = bsxfun(@power, (1 - materialMatrixAbsorption(:,iBand)'), obj.wallHitLog_RT{iSrc,iRec,iBand});
                        
                        M(sum(obj.wallHitLog_RT{iSrc,iRec,iBand},2) == 0) = 0;  % elimante walls that haven't been hit
                        
                        M = prod(M, 2);     % multiply all walls
                        
                        histo{iSrc,iRec}.data(:, iBand) = airAbs' .* sum(bsxfun(@times, reshape(M, obj.numParticles_Sphere, numTimeSteps), obj.initialParticleEnergy{iSrc,iBand}));
                        
                        % todo: mal ohne exp/log probieren... könnte schneller sein
                        
                        
                        %                         % loop all detections
                        %                         for iRefl = 1 : numel(obj.wallHitLog_RT{iSrc,iRec,iBand})
                        %                             % get particle running distance
                        %                             distance = obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).time * soundspeed;
                        %
                        %                             % build wall filter
                        %                             wallTransferFunction = 1;
                        %                             for iWall = 1 : numel(obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).materials)
                        %                                 % wallTransferFunction = (1 - alpha)
                        %                                 wallTransferFunction = wallTransferFunction * ...
                        %                                                         (1 - materialMatrixAbsorption(obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).materials(iWall)+1, thirdOctIndex));
                        %                             end
                        %
                        %                             % add energy
                        %                             histo{iSrc,iRec}.data(obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).timeslot + 1, iBand) = ...
                        %                                 histo{iSrc,iRec}.data(obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).timeslot + 1, iBand) + ...
                        %                                 obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).initialEnergy * ...
                        %                                 wallTransferFunction * obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).lambertIntegral * ...
                        %                                 exp(- (airAbsorption(thirdOctIndex)) * distance);
                        %
                        % %                             % debug
                        % %                             histo{iSrc,iRec}.data(obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).timeslot + 1, iBand) = ...
                        % %                                 histo{iSrc,iRec}.data(obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).timeslot + 1, iBand) + ...
                        % %                                 obj.wallHitLog_RT{iSrc,iRec,iBand}(iRefl).energy;
                        %                         end
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function histoRT = addISEnergyToRTHistogram(obj, histoRT)
            % this functions adds the energy of audible image sources to the spectral energy histogram
            % of the ray tracer. note: audible image sources and RT histogram must be determined before
            
            % calculate sound speed
            soundspeed = calculateSoundSpeed(obj.getTemperature, obj.getHumidity, obj.getPressure);
            
            % calculate air absorption
            airAbsorption = determineAirAbsorptionParameter(obj.getTemperature, obj.getPressure, obj.getHumidity);
            
            % get image sources wall hit log
            refl_IS = obj.getWallHitLog_IS();
            if ~iscell(refl_IS)
                refl_IS = {refl_IS};
            end
            
            % get number of sources and receivers and frequecy bands
            numSources   = size(refl_IS, 1);
            numReceivers = size(refl_IS, 2);
            numFreqBands = numel(refl_IS{1,1}(1).spectrum);
            
            % build material database
            roomMaterialNames = obj.getRoomMaterialNames();
            numMaterials = numel(roomMaterialNames);
            materialMatrixAbsorption = zeros(numMaterials, 31);
            materialMatrixScattering = zeros(numMaterials, 31);
            for iMat = 1 : numMaterials
                [materialMatrixAbsorption(iMat,:), materialMatrixScattering(iMat,:)] = readRavenMaterial(roomMaterialNames{iMat});
            end
            
            % prepare histograms
            for iSrc = 1 : numSources
                % open directivity
                if ~isempty(obj.sourceDirectivity) && (numel(obj.sourceDirectivity) >= iSrc)
                    sourceDirectivityFile = obj.sourceDirectivity{iSrc};
                    daffDirectivity = DAFF('open', sourceDirectivityFile);
                else
                    sourceDirectivityFile = [];
                    daffDirectivity = [];
                end
                
                for iRec = 1 : numReceivers
                    % process direct sound and image sources
                    for i = 1 : numel(refl_IS{iSrc,iRec})
                        % get time and distance of image source
                        time = refl_IS{iSrc,iRec}(i).time;
                        distance = time * soundspeed;
                        histogramIndex = refl_IS{iSrc,iRec}(i).timeslot + 1;
                        
                        for band = 1 : numFreqBands
                            if numFreqBands == 10
                                thirdOctIndex = (band-1)*3+3;   % transfer functions, air absorption etc. is always in third octave resolution. this translates octaves to third octaves if necessary
                            else
                                thirdOctIndex = band;
                            end
                            
                            % get source energy
                            if isempty(sourceDirectivityFile)
                                energy = 1.0;
                            else
                                % read DAFF directivity filter
                                data = DAFF('getNearestNeighbourRecord', daffDirectivity, 'obj', refl_IS{iSrc,iRec}(i).azimuth, refl_IS{iSrc,iRec}(i).elevation);
                                energy = data(thirdOctIndex) * data(thirdOctIndex);
                            end
                            
                            % geometrical spreading
                            energy = energy / (distance * distance);
                            
                            % build wall filter
                            wallTransferFunction = 1;
                            for iWall = 1 : numel(refl_IS{iSrc,iRec}(i).materials)
                                % wallTransferFunction = (1 - alpha) * (1 - S)
                                wallTransferFunction = wallTransferFunction * ...
                                    (1 - materialMatrixAbsorption(refl_IS{iSrc,iRec}(i).materials(iWall)+1, thirdOctIndex)) * ...
                                    (1 - materialMatrixScattering(refl_IS{iSrc,iRec}(i).materials(iWall)+1, thirdOctIndex));
                            end
                            
                            histoRT{iSrc,iRec}.data(histogramIndex, band) = histoRT{iSrc,iRec}.data(histogramIndex, band) + ...
                                wallTransferFunction * energy * ...
                                exp(- (airAbsorption(thirdOctIndex)) * distance);
                        end % for number of bands
                    end % for image sources
                    
                    %                     % build debug histogram
                    %                     histodatadebug = zeros(size(histodata));
                    %                     for i = 1 : numel(refl_IS{iSrc,iRec})
                    %                         histodatadebug(refl_IS{iSrc,iRec}(i).timeslot, :) = histodatadebug(refl_IS{iSrc,iRec}(i).timeslot, :) + refl_IS{iSrc,iRec}(i).spectrum;
                    %                     end
                    
                end % for receivers
            end % for sources
            
            % close directivity file
            if ~isempty(sourceDirectivityFile)
                DAFF('close', daffDirectivity)
            end
        end
        
        %------------------------------------------------------------------
        function V = getRoomVolume(obj, roomID)
            %V = getRoomVolume(roomID)
            %
            %   returns the volume of the current room.
            %
            if nargin < 2
                roomID = 0;
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get all materials in room
            V = roommodel.getVolume();
        end
        
        %------------------------------------------------------------------
        function S = getRoomSurfaceArea(obj, roomID)
            %S = getRoomSurfaceArea(roomID)
            %
            %   returns the total surface area of the current room.
            %
            if nargin < 2
                roomID = 0;
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get all materials in room
            S = roommodel.getSurface();
        end
        
        %------------------------------------------------------------------
        function S = getMaterialSurfaceArea(obj, materialName)
            %S = getRoomSurfaceArea(roomID)
            %
            %   returns the total surface area of the current room.
            %
            if nargin < 2
                error('Please provide a material name.');
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get all materials in room
            S = roommodel.getMaterialSurface(materialName);
        end       
        
        %------------------------------------------------------------------
        function A = getRoomEquivalentAbsorptionArea_Sabine(obj, roomID)
            %A = getRoomEquivalentAbsorptionArea_Sabine(roomID)
            %
            %   returns the total equivalent absorption area of the current
            %   room for all frequency bands.
            %
            if nargin < 2
                roomID = 0;
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get reverberation time after sabine
            A = roommodel.getEquivalentAbsorptionArea_sabine();
        end
        
        %------------------------------------------------------------------
        function A = getRoomEquivalentAbsorptionArea_Eyring(obj, roomID)
            %A = getRoomEquivalentAbsorptionArea_Sabine(roomID)
            %
            %   returns the total equivalent absorption area of the current
            %   room for all frequency bands.
            %
            if nargin < 2
                roomID = 0;
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get reverberation time after sabine
            A = roommodel.getEquivalentAbsorptionArea_eyring(obj.pathMaterials);
        end
        
        %------------------------------------------------------------------
        function RT = getReverbTime(obj, eyring, roomID)
            %RT = getReverbTime(eyring, roomID)
            %
            %   returns the estimated reverberation time of the current room.
            %
            if nargin < 3
                roomID = 0;
            end
            if nargin < 2
                eyring = 1; % default to eyring
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get reverberation time
            if (eyring == 1)
                airAbsorption = determineAirAbsorptionParameter(obj.getTemperature, obj.getPressure, obj.getHumidity);
                RT = roommodel.getReverbTime(obj.pathMaterials, 'eyring', airAbsorption);
            else
                airAbsorption = determineAirAbsorptionParameter(obj.getTemperature, obj.getPressure, obj.getHumidity);
                RT = roommodel.getReverbTime(obj.pathMaterials, 'sabine', airAbsorption);
            end
        end
        
        %------------------------------------------------------------------
        function RT = getReverbTime_Sabine(obj)
            RT = obj.getReverbTime(0);
        end

        %------------------------------------------------------------------
        function RT = getReverbTime_Eyring(obj)
            RT = obj.getReverbTime(1);
        end
        
        %------------------------------------------------------------------
        function S = getSurfaceAreaOfMaterial(obj,material)
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            S = roommodel.getSurfaceArea(material);            
                        
        end        

        %------------------------------------------------------------------
        function materialNames = getRoomMaterialNames(obj, roomID)
            %materialNames = getRoomMaterialNames(roomID)
            %
            %   returns the names of materials that are used in the
            %   current room.
            %
            if nargin < 2
                roomID = 0;
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get all materials in room
            materialNames = roommodel.getMaterialNames();
        end
        
        %------------------------------------------------------------------
        function materialNames = setRoomMaterialNames(obj, materialNames, roomID)
            %setRoomMaterialNames(materialNames, roomID)
            %
            %   returns the names of materials that are used in the
            %   current room.
            %
            if nargin < 3
                roomID = 0;
            end
            
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            
            % get all materials in room
            roommodel.setMaterialNames(materialNames);
        end
        
        %------------------------------------------------------------------
        function IACC = getIACC(obj, brir)
            if nargin < 2
                brir = obj.getBinauralImpulseResponseItaAudio();
            end
           
            % apply filter bank
            third_octs = ita_mpb_filter(brir, 'oct', 3);
            timeData = third_octs.timeData;
			numFreqs = size(timeData, 2)/2;
           
            % preallocation IACC vector
            IACC = zeros(numFreqs, 1);			
            samples_in_1ms = round(brir.samplingRate / 1000);
            wb=itaWaitbar(samples_in_1ms*2*31);
            for i3rd = 1 : numFreqs
                % calculate interaural correlation function
                IACF = sum(timeData(:, i3rd*2-1).^2) * sum(timeData(:, i3rd*2).^2);
               
                % search for maximum of cross correlation function in interval -1ms to +1ms
%                 samples_in_1ms = round(brir.samplingRate / 1000);
               
          
                % shift left channel
                for lambda = 1 : samples_in_1ms
                    this_iacc = abs(sum(timeData(lambda:end, i3rd*2-1) .* timeData(1:(end-lambda+1), i3rd*2)) / sqrt(IACF));
                    IACC(i3rd) = max([this_iacc, IACC(i3rd)]);
                wb.inc;
                end
                % shift right channel
                for lambda = 1 : samples_in_1ms
                    this_iacc = abs(sum(timeData(1:(end-lambda+1), i3rd*2-1) .* timeData(lambda:end, i3rd*2)) / sqrt(IACF));
                    IACC(i3rd) = max([this_iacc, IACC(i3rd)]);
                wb.inc;
                end
            end
        wb.close; 
        end
        
        %------------------------------------------------------------------
        function [Ts] = getCenterTime(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            % calculate schroeder curve
            edc = obj.getSchroederCurve('nodB', 'nonorm', 'notimecorrect');
            if ~iscell(edc)
                edc = {edc};
            end
            
            % calculate sound speed
            c = calculateSoundSpeed(obj.getTemperature(), obj.getHumidity(), obj.getPressure());
            
            for iRec = 1 : numel(edc)
                if ~isempty(edc{sourceID+1,iRec})
                    for iFreq = 1 : size(edc{sourceID+1,iRec}, 2)
                        % calculate source to receiver distance and arrival time of direct sound
                        srcPos = obj.getSourcePosition(sourceID);
                        recPos = obj.getReceiverPosition(iRec-1);
                        source_receiver_distance = norm(recPos - srcPos);
                        directSoundTime = source_receiver_distance / c;
                        
                        % create timevector with center times of each time step
                        timeVecDirect = obj.histogram{sourceID+1,iRec}.timevector + (obj.timeSlotLength/1000) / 2;
                        % set t=0 to arrival of the direct sound
                        timeVecDirect = timeVecDirect - directSoundTime;
                        % set negative entries (before direct sound arrival to zero)
                        timeVecDirect(timeVecDirect < 0) = 0;   
                        
                        % find timestep AFTER direct sound
                        timestepDirect = floor(directSoundTime / (obj.timeSlotLength/1000)) + 1; % second timestep after direct sound (counting starts at 1 in matlab!)
                        
                        % time in the middle between direct sound arrival and end of the timestep
                        timeFirstTimestep = (timestepDirect * (obj.timeSlotLength/1000) - directSoundTime) / 2;
                        
                        % calculcate numerator
                        tmpIntegral = timeFirstTimestep * obj.histogram{sourceID+1,iRec}.data(timestepDirect, iFreq);     % first time step
                        tmpIntegral = tmpIntegral + sum(timeVecDirect((timestepDirect+1):end) .* obj.histogram{sourceID+1,iRec}.data((timestepDirect+1):end, iFreq));     % all remaining time steps
                                                
                        % total energy in the impulse response
                        totalEnergy = edc{sourceID+1,iRec}(1, iFreq);
                                                
                        % calculate center time
                        if totalEnergy > 0
                            Ts{iRec}(iFreq) = tmpIntegral / totalEnergy;
                        else
                            Ts{iRec}(iFreq) = 0;
                        end
                    end
                else
                    Ts{iRec} = [];
                end
            end
            
            if averageOverReceivers
                Ts = obj.averageOverReceivers(Ts);
            end
            
            if averageOverFrequencies
                if nargin < 4
                    afterDIN = 0;
                end
                Ts = obj.averageAfterDIN(Ts, afterDIN);
            end
            
            if (numel(Ts) == 1) && iscell(Ts)
                Ts = Ts{1};
            end
        end
            
        %------------------------------------------------------------------
        function [C50, C80] = getClarity(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            % calculate schroeder curve
            edc = obj.getSchroederCurve('nodB', 'nonorm', 'notimecorrect');
            if ~iscell(edc)
                edc = {edc};
            end
            
            % calculate sound speed
            c = calculateSoundSpeed(obj.getTemperature(), obj.getHumidity(), obj.getPressure());
            
            for iRec = 1 : numel(edc)
                if ~isempty(edc{sourceID+1,iRec})
                    for iFreq = 1 : size(edc{sourceID+1,iRec}, 2)
                        % calculate source to receiver distance and arrival time of direct sound
                        srcPos = obj.getSourcePosition(sourceID);
                        recPos = obj.getReceiverPosition(iRec-1);
                        source_receiver_distance = norm(recPos - srcPos);
                        directSoundTime = source_receiver_distance / c;
                        
                        % find the exact integration limit in the histogram
                        integral_end_time_50 = (directSoundTime + 0.050);
                        integral_end_time_80 = (directSoundTime + 0.080);
                        last_time_slot_50 = find(obj.histogram{sourceID+1,iRec}.timevector >= integral_end_time_50, 1) - 1;
                        last_time_slot_80 = find(obj.histogram{sourceID+1,iRec}.timevector >= integral_end_time_80, 1) - 1;
                        relativePortionOfLastTimeSlot_50 = rem(integral_end_time_50, obj.timeSlotLength/1000) / (obj.timeSlotLength/1000);
                        relativePortionOfLastTimeSlot_80 = rem(integral_end_time_80, obj.timeSlotLength/1000) / (obj.timeSlotLength/1000);
                        
                        % detect energy in last time slot
                        energyInLastTimeSlot_50 = edc{sourceID+1,iRec}(last_time_slot_50, iFreq) - edc{sourceID+1,iRec}(last_time_slot_50 + 1, iFreq);
                        energyInLastTimeSlot_80 = edc{sourceID+1,iRec}(last_time_slot_80, iFreq) - edc{sourceID+1,iRec}(last_time_slot_80 + 1, iFreq);
                        
                        % total energy in the impulse response
                        totalEnergy = edc{sourceID+1,iRec}(1, iFreq);
                        
                        % energy in the first 50ms/80ms after the direct sound
                        energy50ms = totalEnergy - edc{sourceID+1,iRec}(last_time_slot_50, iFreq) + relativePortionOfLastTimeSlot_50 * energyInLastTimeSlot_50;
                        energy80ms = totalEnergy - edc{sourceID+1,iRec}(last_time_slot_80, iFreq) + relativePortionOfLastTimeSlot_80 * energyInLastTimeSlot_80;
                        
                        % calculate clarity
                        if totalEnergy > energy50ms
                            C50{iRec}(iFreq) = 10 * log10( energy50ms / (totalEnergy-energy50ms) );
                        else
                            C50{iRec}(iFreq) = inf;
                        end
                        
                        if nargout > 1
                            if totalEnergy > energy80ms
                                C80{iRec}(iFreq) = 10 * log10( energy80ms / (totalEnergy-energy80ms) );
                            else
                                C80{iRec}(iFreq) = inf;
                            end
                        end
                    end
                else
                    C50{iRec} = [];
                    if nargout > 1
                        C80{iRec} = [];
                    end
                end
            end
            
            if averageOverReceivers
                C50 = obj.averageOverReceivers(C50);
                if nargout > 1
                    C80 = obj.averageOverReceivers(C80);
                end
            end
            
            if averageOverFrequencies
                if nargin < 4
                    afterDIN = 0;
                end
                C50 = obj.averageAfterDIN(C50, afterDIN);
                if nargout > 1
                    C80 = obj.averageAfterDIN(C80, afterDIN);
                end
            end
            
            if (numel(C50) == 1) && iscell(C50)
                C50 = C50{1};
                if nargout > 1
                    C80 = C80{1};
                end
            end
        end
        
        %------------------------------------------------------------------
        function [D50, D80] = getDefinition(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            % get clarity
            [C50, C80] = obj.getClarity(averageOverReceivers, averageOverFrequencies, afterDIN, sourceID);
            
            % calculate definition from clarity
            if iscell(C50)
                for iCell = 1 : numel(C50)
                    D50{iCell} = 1 - 1 ./ (10.^(C50{iCell}./10) + 1);
                    if nargout > 1
                        D80{iCell} = 1 - 1 ./ (10.^(C80{iCell}./10) + 1);
                    end
                end
            else
                D50 = 1 - 1 ./ (10.^(C50./10) + 1);
                if nargout > 1
                    D80 = 1 - 1 ./ (10.^(C80./10) + 1);
                end
            end
            
            if (numel(D50) == 1) && iscell(D50)
                D50 = D50{1};
                if nargout > 1
                    D80 = D80{1};
                end
            end
        end
        
        %------------------------------------------------------------------
        function [LFC, LF, LE] = getLFC(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if ~isfield(obj.histogram{1,1}, 'energyLFC')
                error('LFC not implemented. Please update your RAVEN installation.');                
            end
            
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            % calculate schroeder curve
            edc = obj.getSchroederCurve('nodB', 'nonorm', 'notimecorrect');
            if ~iscell(edc)
                edc = {edc};
            end
                        
            for iRec = 1 : numel(edc)
                % check if this receiver looks at the source
                srcPos = obj.getSourcePosition(sourceID);
                recPos = obj.getReceiverPosition(iRec-1);
                recView = obj.getReceiverViewVectors(iRec-1);
                directionErrorDeg = acosd(dot(srcPos-recPos, recView) / (norm(srcPos - recPos) * norm(recView)));
                if (directionErrorDeg > 2)
                    warning(['Receiver ' num2str(iRec) ' does not look directly at the source! Re-orient the receiver to calculate LF(C).']);
                end
                
                if ~isempty(edc{sourceID+1,iRec})
                    for iFreq = 1 : size(edc{sourceID+1,iRec}, 2)
                        % get arrival time of direct sound
                        directSoundTime = obj.histogram{sourceID+1,iRec}.directsounddelay;
                        
                        % find the exact integration limit in the histogram
                        integral_end_time = (directSoundTime + 0.080);
                        last_time_slot = find(obj.histogram{sourceID+1,iRec}.timevector >= integral_end_time, 1) - 1;
                        relativePortionOfLastTimeSlot = rem(integral_end_time, obj.timeSlotLength/1000) / (obj.timeSlotLength/1000);
                        
                        % detect energy in last time slot
                        energyInLastTimeSlot = edc{sourceID+1,iRec}(last_time_slot, iFreq) - edc{sourceID+1,iRec}(last_time_slot + 1, iFreq);
                        
                        % total energy in the impulse response
                        totalEnergy = edc{sourceID+1,iRec}(1, iFreq);

                        % omnidirectional energy in the first 0ms..80ms after the direct sound                        
                        energy80ms = totalEnergy - edc{sourceID+1,iRec}(last_time_slot, iFreq) + relativePortionOfLastTimeSlot * energyInLastTimeSlot;
                                               
                        % calculate lateral fraction [cosine]
                        if energy80ms > realmin
                            LFC{iRec}(iFreq) = obj.histogram{sourceID+1,iRec}.energyLFC(iFreq) / energy80ms;
                            if nargout > 1
                                LF{iRec}(iFreq) = obj.histogram{sourceID+1,iRec}.energyLF(iFreq) / energy80ms;
                                if nargout > 2
                                    LE{iRec}(iFreq) = obj.histogram{sourceID+1,iRec}.energyLE(iFreq) / energy80ms;
                                end
                            end
                        else
                            LFC{iRec}(iFreq) = 0;
                            if nargout > 1
                                LF{iRec}(iFreq) = 0;
                                if nargout > 2
                                    LE{iRec}(iFreq) = 0;
                                end
                            end
                        end
                    end
                else
                    LFC{iRec} = [];
                    if nargout > 1
                        LF{iRec} = [];
                        if nargout > 2
                            LE{iRec} = [];
                        end
                    end
                end
            end
            
            if averageOverReceivers
                LFC = obj.averageOverReceivers(LFC);
                if nargout > 1
                    LF = obj.averageOverReceivers(LF);
                    if nargout > 2
                        LE = obj.averageOverReceivers(LE);
                    end
                end
            end
            
            if averageOverFrequencies
                if nargin < 4
                    afterDIN = 0;
                end
                LFC = obj.averageAfterDINLateral(LFC, afterDIN);
                if nargout > 1
                    LF = obj.averageAfterDINLateral(LF, afterDIN);
                    if nargout > 1
                        LE = obj.averageAfterDINLateral(LE, afterDIN);
                    end
                end
            end
            
            if (numel(LFC) == 1) && iscell(LFC)
                LFC = LFC{1};
                if nargout > 1
                    LF = LF{1};
                    if nargout > 2
                        LE = LE{1};
                    end
                end
            end
        end        
        
        %------------------------------------------------------------------
        function G = getStrength(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            edc = obj.getSchroederCurve('nodB', 'nonorm', 'notimecorr');
            if ~iscell(edc)
                edc = {edc};
            end
            
            for iRec = 1 : size(edc,2)
                % Strength G
                G{iRec} = 10 * log10( edc{sourceID+1,iRec}(1,:) / (1/100) );       % 1/100 = energy of direct sound per frequency band for 10m distance
            end
            
            if averageOverReceivers
                G = obj.averageOverReceivers(G);
            end
            
            if averageOverFrequencies
                if nargin < 4
                    afterDIN = 0;
                end
                G = obj.averageAfterDIN(G, afterDIN);
            end
            
            if (numel(G) == 1) && iscell(G)
                G = G{1};
            end
        end
        
        %------------------------------------------------------------------
        function EDT = getEDT(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            EDT = obj.getRT(averageOverReceivers, averageOverFrequencies, afterDIN, 0, -10, sourceID);
        end
        
        %------------------------------------------------------------------
        function T30 = getT30(obj, averageOverReceivers, averageOverFrequencies, afterDIN, sourceID)
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                sourceID = 0;
            end
            
            T30 = obj.getRT(averageOverReceivers, averageOverFrequencies, afterDIN, -5, -35, sourceID);
        end
        
        %------------------------------------------------------------------
        function T30 = getRT(obj, averageOverReceivers, averageOverFrequencies, afterDIN, from_dB, to_dB, sourceID)
            % getT30(averageOverReceivers, averageOverFrequencies, afterDIN, from_dB, to_dB, sourceID)
            
            if nargin < 2
                averageOverReceivers = 0;
            end
            if nargin < 3
                averageOverFrequencies = 0;
            end
            if nargin < 4
                afterDIN = 0;
            end
            if nargin < 5
                from_dB = -5;   % default to T30
            end
            if nargin < 6
                to_dB = -35;    % default to T30
            end
            if nargin < 7
                sourceID = 0;   % default to first source
            end
            
            % get schroeder curve
            edc = obj.getSchroederCurve('dB', 'norm', 'timecorrect');
            if ~iscell(edc)
                edc = {edc};
            end
            
            % get number of frequency bands
            numFrequencyBands = size(obj.histogram{find(~cellfun(@isempty, obj.histogram), 1)}.data, 2);
            T30 = cell(size(obj.histogram,2),1);   % T30{1..numReceivers}(1..numFrequencyBands)
            
            for iRec = 1 : size(obj.histogram, 2)
                if ~isempty(obj.histogram{sourceID+1,iRec})
                    % get slope of schroeder curves
                    slope = ones(numFrequencyBands, 1);
                    for iBand = 1 : numFrequencyBands
                        % linear regression analysis
                        start_index = find(edc{sourceID+1,iRec}(:, iBand) <= from_dB, 1);
                        end_index = find(edc{sourceID+1,iRec}(:, iBand) <= to_dB, 1);
                        if start_index ~= end_index
                            slope_temp = polyfit(obj.histogram{sourceID+1,iRec}.timevector(start_index : end_index), ...
                                edc{sourceID+1,iRec}(start_index : end_index, iBand), 1);
                            slope(iBand) = slope_temp(1);
                        else
                            slope(iBand) = -Inf;
                        end
                    end
                    
                    % reverberation times
                    T30{iRec} = -60 ./ slope;
                else
                    T30{iRec} = [];
                end
            end
            
            if averageOverReceivers
                T30 = obj.averageOverReceivers(T30);
            end
            
            if averageOverFrequencies
                if nargin < 4
                    afterDIN = 0;
                end
                T30 = obj.averageAfterDIN(T30, afterDIN);
            end
            
            if (numel(T30) == 1) && iscell(T30)
                T30 = T30{1};
            end
        end
                
        %------------------------------------------------------------------
        function newReverbTime = adjustAbsorptionToMatchReverbTime(obj, targetReverbTime, roomID, validationsimulation, materialPrefix, materialAppendix, materialIndexVector)
            %adjustAbsorptionToMatchReverbTime(targetReverbTime, roomID, validationsimulation, materialPrefix, materialAppendix, materialIndexVector)
            if isempty(obj.modelFileList)
                return
            end
            
            % check args
            if nargin < 3
                roomID = 0;
            end
            
            % check if simulation was already run
            if isempty(obj.histogram)
                if ~obj.exportHistogram
                    obj.setExportHistogram(1);     % make sure we get a histogram
                    obj.run();
                    obj.setExportHistogram(0);
                else
                    obj.run();
                end
            else
                disp('Using results from last simulation run.');
            end
            
            % check back the reverberation times
            thisReverbTime = obj.getT30(1);     % average over receivers
            
            % if desired, rename the materials of the model
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            materialNames = roommodel.getMaterialNames(); % read materials out of the ac3d model
            if nargin > 4
                newMaterialNames = strcat(materialPrefix, materialNames);
                if nargin > 5
                    newMaterialNames = strcat(newMaterialNames, materialAppendix);
                end
                roommodel.setMaterialNames(newMaterialNames);
            else
                newMaterialNames = materialNames;
            end
            
            % calculate new absorption values for the variable model to match the reverberation time of the target model (default values by eyring including air abs)
            [A, S] = roommodel.getEquivalentAbsorptionArea_eyring(obj.pathMaterials);
            if (obj.getAirAbsorptionEnabled)
                 airAbscoeffs = determineAirAbsorptionParameter(obj.getTemperature, obj.getPressure, obj.getHumidity);
            else
                airAbscoeffs = zeros(1,31); 
            end
            equivalentAirAbsorptionArea = 4* roommodel.getVolume() * airAbscoeffs;
            
            if numel(targetReverbTime) == 10 % go to octave resolution
                A = A(3:3:end);   
                equivalentAirAbsorptionArea = equivalentAirAbsorptionArea(3:3:end);
            end
            alphas_default = 1 - exp(((-0.163 * roommodel.getVolume() ./ targetReverbTime) - equivalentAirAbsorptionArea)/(S));
            alphas_alt = (A+equivalentAirAbsorptionArea)/S;
            alphas_neu = 1 - (1 - alphas_alt(:)).^(thisReverbTime(:) ./ targetReverbTime(:));
                      
            absorptionFactors = alphas_neu(:) ./ alphas_alt(:);
            absorptionFactors(isnan(absorptionFactors)) = 1;
            absorptionFactors(isinf(absorptionFactors)) = 999;
            
            % apply new absorption values
            matProcessed={};
            if nargin < 7
                materialIndexVector = 1 : numel(materialNames);
            else
                materialIndexVector = materialIndexVector + 1; % C++ starts counting at zero, but MATLAB starts at 1
            end
            for iMat = materialIndexVector
                
                if ~sum(strcmp(materialNames{iMat},matProcessed))
                    matProcessed{iMat}=materialNames{iMat};
                    [absorp, scatter] = readRavenMaterial(materialNames{iMat}, obj.pathMaterials);
                    if isempty(absorp)
                        absorp = alphas_default;
                        scatter = 0.2;
                        disp(['Material (' materialNames{iMat} ') not found. Using default absorption values by eyring.']);
                    elseif numel(absorptionFactors) == 10
                        absorp = absorp(3:3:end);   % go to octave resolution
                        scatter = scatter(3:3:end);   % go to octave resolution
                    end
                    absorp_neu = absorp(:) .* absorptionFactors(:);
                    absorp_neu(absorp_neu > 1) = 1;
                    absorp_neu(absorp_neu <= 0) = 0.0001;
                    obj.setMaterial(newMaterialNames{iMat}, absorp_neu, scatter);
                end
            end
            
            if (nargin < 4) || validationsimulation
                disp('repeat simulation for validation');
                obj.run();
                
                % check back the reverberation times
                newReverbTime = obj.getT30(1);
                
                figure;
                nRT = numel(targetReverbTime);
                plot(1:nRT, targetReverbTime, 1:nRT, thisReverbTime, 1:nRT, newReverbTime);
                legend('Target RT', 'RT before', 'RT after');
                
                ylabel('T30 [s]');
                xlabel('Frequency band [Hz]');
                ylim([0 1.1*max(targetReverbTime)]);             
                
                ax = gca; 
                ax.XTickLabel = {32 63 125 250 500 1000 2000 4000 8000 16000}; 
                grid on;

            else
                newReverbTime = [];
            end
            
        end        
        
         %------------------------------------------------------------------
        function [ newReverbTime absorp_neu_all ]= adjustAbsorptionToMatchParameter(obj, targetReverbTime, roomID, validationsimulation, materialPrefix, materialAppendix, materialIndexVector)
            
            if isempty(obj.modelFileList)
                return
            end
            
            % check args
            if nargin < 3
                roomID = 0;
            end
            
            % check if simulation was already run
            if isempty(obj.histogram)
                if ~obj.exportHistogram
                    obj.setExportHistogram(1);     % make sure we get a histogram
                    obj.run();
                    obj.setExportHistogram(0);
                else
                    obj.run();
                end
            else
                disp('Using results from last simulation run.');
            end
            
            % check back the reverberation times
            thisReverbTime = obj.getT30(1);     % average over receivers
            
            % if desired, rename the materials of the model
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            materialNames = roommodel.getMaterialNames(); % read materials out of the ac3d model
            if nargin > 4
                newMaterialNames = strcat(materialPrefix, materialNames);
                if nargin > 5
                    newMaterialNames = strcat(newMaterialNames, materialAppendix);
                end
                roommodel.setMaterialNames(newMaterialNames);
            else
                newMaterialNames = materialNames;
            end
            
            % calculate new absorption values for the variable model to match the reverberation time of the target model (default values by eyring including air abs)
            [A, S] = roommodel.getEquivalentAbsorptionArea_eyring(obj.pathMaterials);
            if (obj.getAirAbsorptionEnabled)
                 airAbscoeffs = determineAirAbsorptionParameter(obj.getTemperature, obj.getPressure, obj.getHumidity);
            else
                airAbscoeffs = zeros(1,31); 
            end
            equivalentAirAbsorptionArea = 4* roommodel.getVolume() * airAbscoeffs;
            
            if numel(targetReverbTime) == 10 % go to octave resolution
                A = A(3:3:end);   
                equivalentAirAbsorptionArea = equivalentAirAbsorptionArea(3:3:end);
            end
            alphas_default = 1 - exp(((-0.163 * roommodel.getVolume() ./ targetReverbTime) - equivalentAirAbsorptionArea)/(S));
            alphas_alt = (A+equivalentAirAbsorptionArea)/S;
            alphas_neu = 1 - (1 - alphas_alt(:)).^(thisReverbTime(:) ./ targetReverbTime(:));
                      
            absorptionFactors = alphas_neu(:) ./ alphas_alt(:);
            absorptionFactors(isnan(absorptionFactors)) = 1;
            absorptionFactors(isinf(absorptionFactors)) = 999;
            
            % apply new absorption values
            matProcessed={};
            if nargin < 7
                materialIndexVector = 1 : numel(materialNames);
            else
                materialIndexVector = materialIndexVector + 1; % C++ starts counting at zero, but MATLAB starts at 1
            end
            
            
            absorp_neu_all = zeros(length(alphas_neu),numel(materialIndexVector));
            
            for iMat = materialIndexVector
                
                if ~sum(strcmp(materialNames{iMat},matProcessed))
                    matProcessed{iMat}=materialNames{iMat};
                    [absorp, scatter] = readRavenMaterial(materialNames{iMat}, obj.pathMaterials);
                    if isempty(absorp)
                        absorp = alphas_default;
                        scatter = 0.2;
                        disp(['Material (' materialNames{iMat} ') not found. Using default absorption values by eyring.']);
                    elseif numel(absorptionFactors) == 10
                        absorp = absorp(3:3:end);   % go to octave resolution
                        scatter = scatter(3:3:end);   % go to octave resolution
                    end
                    absorp_neu = absorp(:) .* absorptionFactors(:);
                    absorp_neu(absorp_neu > 1) = 1;
                    absorp_neu(absorp_neu <= 0) = 0.0001;
                    obj.setMaterial(newMaterialNames{iMat}, absorp_neu, scatter);
                    absorp_neu_all(:,iMat) = absorp_neu;
                end
            end
            
            if (nargin < 4) || validationsimulation
                disp('repeat simulation for validation');
                obj.run();
                
                % check back the reverberation times
                newReverbTime = obj.getT30(1);
                
%                 figure;
%                 nRT = numel(targetReverbTime);
%                 plot(1:nRT, targetReverbTime, 1:nRT, thisReverbTime, 1:nRT, newReverbTime);
%                 legend('Target RT', 'RT before', 'RT after');
%                 
%                 ylabel('T30 [s]');
%                 xlabel('Frequency band [Hz]');
%                 ylim([0 1.1*max(targetReverbTime)]);             
%                 
%                 ax = gca; 
%                 ax.XTickLabel = {32 63 125 250 500 1000 2000 4000 8000 16000}; 
%                 grid on;

            else
                newReverbTime = [];
            end
            
        end        
        
        %------------------------------------------------------------------
        function brir = adjustAbsorptionToMatchReverbTimeOfBinauralImpulseResponse(obj, targetReverbTime, roomID, validationsimulation, materialPrefix, materialAppendix)
            %adjustAbsorptionToMatchReverbTimeOfBinauralImpulseResponse(targetReverbTime, roomID, validationsimulation)
            
            if isempty(obj.modelFileList)
                return
            end
            
            % check args
            if nargin < 3
                roomID = 0;
            end
            
            % check if simulation was already run
            if isempty(obj.binauralIR)
                obj.run();
            else
                disp('Using results from last simulation run.');
            end
            
            disp('get binaural impulse response');
            brir = obj.getBinauralImpulseResponseItaAudio();
            
            % merge IRs of multiple receivers into 1 multichannel itaAudio
            if iscell(brir)
                tmp = brir{1};
                for i = 2 : numel(brir)
                    tmp = merge(tmp, brir{i});
                end
                brir = tmp;
            elseif numel(brir) > 1
                % multi-instance
                brir = merge(brir);
            end            
            
            % calculate schroeder decay curves and get reverberation times
            thisReverbTime = ita_roomacoustics(brir, 'T20', 'edcMethod','noCut', 'freqRange', [20 20000], 'bandsPerOctave', 3);
            thisReverbTime = thisReverbTime.T20;
            thisReverbTime = mean(thisReverbTime.freqData, 2);
                        
            % check if target reverb times are values already or if they still have to be calculated from an itaAudio
            if isa(targetReverbTime, 'itaAudio')
                targetReverbTime = ita_roomacoustics(targetReverbTime, 'T20', 'edcMethod','noCut', 'freqRange', [20 20000], 'bandsPerOctave', 3);
                targetReverbTime = targetReverbTime.T20;
                targetReverbTime = mean(targetReverbTime.freqData, 2);
            end
            
            disp('load room model');
            % if desired, rename the materials of the model
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            materialNames = roommodel.getMaterialNames(); % read materials out of the ac3d model
            if nargin > 4
                newMaterialNames = strcat(materialPrefix, materialNames);
                if nargin > 5
                    newMaterialNames = strcat(newMaterialNames, materialAppendix);
                end
                roommodel.setMaterialNames(newMaterialNames);
            else
                newMaterialNames = materialNames;
            end
            
            disp('calculate new absorption values for the variable model to match the reverberation time of the target model');
            [A, S] = roommodel.getEquivalentAbsorptionArea();
            if numel(targetReverbTime) == 10
                A = A(3:3:end);   % go to octave resolution
            end
            alphas_default = 1 - exp(-0.163 * roommodel.getVolume() ./ (S .* targetReverbTime));
            alphas_alt = A/S;
            alphas_neu = 1 - (1 - alphas_alt(:)).^(thisReverbTime(:) ./ targetReverbTime(:));
            
            absorptionFactors = alphas_neu(:) ./ alphas_alt(:);
            absorptionFactors(isnan(absorptionFactors)) = 1;
            absorptionFactors(isinf(absorptionFactors)) = 999;
            
            disp('apply new absorption values');
            matProcessed={};
            for iMat = 1 : numel(materialNames)
                
                if ~sum(strcmp(materialNames{iMat},matProcessed))
                    matProcessed{iMat}=materialNames{iMat};
                    [absorp, scatter] = readRavenMaterial(materialNames{iMat}, obj.pathMaterials);
                    if isempty(absorp)
                        absorp = alphas_default;
                        scatter = 0.2;
                        disp(['Material (' materialNames{iMat} ') not found. Using default absorption values by eyring.']);
                    end
                    if numel(absorptionFactors) == 10
                        absorp = absorp(3:3:end);   % go to octave resolution
                        scatter = scatter(3:3:end);   % go to octave resolution
                    end
                    absorp_neu = absorp(:) .* absorptionFactors(:);
                    absorp_neu(absorp_neu > 1) = 1;
                    absorp_neu(absorp_neu <= 0) = 0.0001;
                    obj.setMaterial(newMaterialNames{iMat}, absorp_neu, scatter);
                end
            end
            
            if (nargin < 4) || validationsimulation
                disp('repeat simulation for validation');
                obj.run();
                
                disp('generate binaural impulse response');
                brir = obj.getBinauralImpulseResponseItaAudio();
                
                % merge IRs of multiple receivers into 1 multichannel itaAudio
                if numel(brir) > 1
                    brir = merge(brir);
                end
                
                % calculate schroeder decay curves and get reverberation times
                newReverbTime = ita_roomacoustics(brir, 'T20', 'edcMethod','noCut', 'freqRange', [20 20000], 'bandsPerOctave', 3);
                newReverbTime = newReverbTime.T20;
                newReverbTime = mean(newReverbTime.freqData, 2);
                
                figure;
                nRT = numel(targetReverbTime);
                plot(1:nRT, targetReverbTime, 1:nRT, thisReverbTime, 1:nRT, newReverbTime);
                legend('Target RT', 'RT before', 'RT after');
            end
        end
        
        %------------------------------------------------------------------
        function rir = adjustAbsorptionToMatchReverbTimeOfMonauralImpulseResponses(obj, targetReverbTime, roomID, validationsimulation, materialPrefix, materialAppendix, materialIndexVector)
            %adjustAbsorptionToMatchReverbTimeOfMonauralImpulseResponses(targetReverbTime, roomID, validationsimulation, materialPrefix, materialAppendix)
            
            if isempty(obj.modelFileList)
                return
            end
            
            % check args
            if nargin < 3
                roomID = 0;
            end
            
            % check if simulation was already run
            if isempty(obj.monauralIR)
                obj.run();
            else
                disp('Using results from last simulation run.');
            end
            
            disp('get monaural impulse response');
            rir = obj.getMonauralImpulseResponseItaAudio();
            
            % merge IRs of multiple receivers into 1 multichannel itaAudio
            if iscell(rir)
                tmp = rir{1};
                for i = 2 : numel(rir)
                    tmp = merge(tmp, rir{i});
                end
                rir = tmp;
            elseif numel(rir) > 1
                % multi-instance
                rir = merge(rir);
            end
            
            % calculate schroeder decay curves and get reverberation times
            if numel(targetReverbTime) == 10
                thisReverbTime = ita_roomacoustics(rir, 'T20', 'edcMethod','noCut', 'freqRange', [30 16000], 'bandsPerOctave', 1);
            else
                thisReverbTime = ita_roomacoustics(rir, 'T20', 'edcMethod','noCut', 'freqRange', [20 20000], 'bandsPerOctave', 3);
            end
            thisReverbTime = mean(thisReverbTime.T20.freqData, 2);
            
            % check if target reverb times are values already or if they still have to be calculated from an itaAudio
            if isa(targetReverbTime, 'itaAudio')
                targetReverbTime = ita_roomacoustics(targetReverbTime, 'T20', 'edcMethod','noCut', 'freqRange', [20 20000], 'bandsPerOctave', 3);
                targetReverbTime = mean(targetReverbTime.freqData, 2);
            end
            
            disp('load room model');
            % if desired, rename the materials of the model
            if isempty(obj.model)
                if iscell(obj.modelFileList)
                    for iRoom = 1 : numel(obj.modelFileList)
                        obj.model{iRoom} = load_ac3d(obj.modelFileList{iRoom});
                    end
                    roommodel = obj.model{roomID + 1};
                else
                    obj.model = load_ac3d(obj.modelFileList);
                    roommodel = obj.model;
                end
            else
                if iscell(obj.model)
                    roommodel = obj.model{roomID + 1};
                else
                    roommodel = obj.model;
                end
            end
            materialNames = roommodel.getMaterialNames(); % read materials out of the ac3d model
            if nargin > 4
                newMaterialNames = strcat(materialPrefix, materialNames);
                if nargin > 5
                    newMaterialNames = strcat(newMaterialNames, materialAppendix);
                end
                roommodel.setMaterialNames(newMaterialNames);
            else
                newMaterialNames = materialNames;
            end
            
            disp('calculate new absorption values for the variable model to match the reverberation time of the target model');
            [A, S] = roommodel.getEquivalentAbsorptionArea();
            if numel(targetReverbTime) == 10
                A = A(3:3:end);   % go to octave resolution
            end
            alphas_default = 1 - exp(-0.163 * roommodel.getVolume() ./ (S .* targetReverbTime));
            alphas_alt = A/S;
            alphas_neu = 1 - (1 - alphas_alt(:)).^(thisReverbTime(:) ./ targetReverbTime(:));
            
            absorptionFactors = alphas_neu(:) ./ alphas_alt(:);
            absorptionFactors(isnan(absorptionFactors)) = 1;
            absorptionFactors(isinf(absorptionFactors)) = 999;
            
            disp('apply new absorption values');
            matProcessed={};
            if nargin < 7
                materialIndexVector = 1 : numel(materialNames);
            else
                materialIndexVector = materialIndexVector + 1; % C++ starts counting at zero, but MATLAB starts at 1
            end
            for iMat = materialIndexVector
                
                if ~sum(strcmp(materialNames{iMat},matProcessed))
                    matProcessed{iMat}=materialNames{iMat};
                    [absorp, scatter] = readRavenMaterial(materialNames{iMat}, obj.pathMaterials);
                    if isempty(absorp)
                        absorp = alphas_default;
                        scatter = 0.2;
                        disp(['Material (' materialNames{iMat} ') not found. Using default absorption values by Eyring.']);
                    end
                    if numel(absorptionFactors) == 10
                        absorp = absorp(3:3:end);   % go to octave resolution
                        scatter = scatter(3:3:end);   % go to octave resolution
                    end
                    absorp_neu = absorp(:) .* absorptionFactors(:);
                    absorp_neu(absorp_neu > 1) = 1;
                    absorp_neu(absorp_neu <= 0) = 0.0001;
                    obj.setMaterial(newMaterialNames{iMat}, absorp_neu, scatter);
                end
            end
            
            if (nargin < 4) || validationsimulation
                disp('repeat simulation for validation');
                obj.run();
                
                disp('get monaural impulse response');
                rir = obj.getMonauralImpulseResponseItaAudio();
                
                % merge IRs of multiple receivers into 1 multichannel itaAudio
                if numel(rir) > 1
                    rir = merge(rir);
                end
                
                % calculate schroeder decay curves and get reverberation times
                if numel(targetReverbTime) == 10
                    newReverbTime = ita_roomacoustics(rir, 'T20', 'edcMethod','noCut', 'freqRange', [30 16000], 'bandsPerOctave', 1);
                else
                    newReverbTime = ita_roomacoustics(rir, 'T20', 'edcMethod','noCut', 'freqRange', [20 20000], 'bandsPerOctave', 3);
                end
                newReverbTime = mean(newReverbTime.T20.freqData, 2);
                
                figure;
                nRT = numel(targetReverbTime);
                plot(1:nRT, targetReverbTime, 1:nRT, thisReverbTime, 1:nRT, newReverbTime);
                legend('Target RT', 'RT before', 'RT after');
            end
        end
        
        %------------------------------------------------------------------
        function T30 = getT30_fromImpulseResponse(obj)
            
            IRs = obj.getMonauralImpulseResponseItaAudio();
            
            for i = 1 : numel(IRs)
                if ~isempty(IRs{i})
                    T30{i} = ita_roomacoustics_reverberation_time(IRs{i});
                else
                    T30{i} = [];
                end
            end
            
            if numel(T30) == 1
                T30 = T30{1};
            end
        end
        
        %------------------------------------------------------------------
        function schroeder_edc = getSchroederCurve(obj, nodB, norm, timecorrect)
            if nargin < 3
                timecorrect = 'timecorrect';
            end
            if nargin < 3
                norm = 'norm';
            end
            if nargin < 2
                nodB = 'dummy';
            end
            % load histogram
            if isempty(obj.histogram)
                error('No histogram present.');
            end
            
            % preallocation
            schroeder_edc = cell(size(obj.histogram, 1), size(obj.histogram, 2));
            
            for iSrc = 1 : size(obj.histogram, 1)
                for iRec = 1 : size(obj.histogram, 2)
                    if ~isempty(obj.histogram{iSrc,iRec})
                        % calculate schroeder function
                        schroeder_edc{iSrc,iRec} = cumsum(obj.histogram{iSrc,iRec}.data(end:-1:1, :), 1);
                        schroeder_edc{iSrc,iRec} = schroeder_edc{iSrc,iRec}(end:-1:1, :);
                        
                        % time correction? (direct sound should be at t = 0)
                        if strcmp(timecorrect, 'timecorrect')
                            directSoundEnergy = max(schroeder_edc{iSrc,iRec});
                            [timeInd, freqInd] = find(abs(bsxfun(@minus, schroeder_edc{iSrc,iRec}, directSoundEnergy)) < eps, 1, 'last');
                            schroeder_edc{iSrc,iRec}(1:timeInd, :) = [];
                        end
                        
                        % normalize?
                        if strcmp(norm, 'norm')
                            schroeder_edc{iSrc,iRec} = bsxfun(@rdivide,schroeder_edc{iSrc,iRec},schroeder_edc{iSrc,iRec}(1, :));
                        end
                        
                        % dB scale?
                        if ~strcmp(nodB, 'nodB')
                            schroeder_edc{iSrc,iRec} = 10 * log10(schroeder_edc{iSrc,iRec} + eps);
                        end
                    else
                        schroeder_edc{iSrc,iRec} = [];
                    end
                end
            end
            
            if numel(schroeder_edc) == 1
                schroeder_edc = schroeder_edc{1,1};
            end
        end
        
        %------------------------------------------------------------------
        function schroeder_edc = getSchroederCurve_itaResult(obj, nodB, norm, timecorrect)
            if nargin < 3
                timecorrect = 'timecorrect';
            end
            if nargin < 3
                norm = 'norm';
            end
            if nargin < 2
                nodB = 'nodB';
            end
            
            schroeder_data = obj.getSchroederCurve(nodB, norm, timecorrect);
            if ~iscell(schroeder_data)
                schroeder_data = {schroeder_data};
            end
            
            schroeder_edc(size(obj.histogram,1), size(obj.histogram,2)) = itaResult();
            for iHisto = 1 : numel(obj.histogram)
                if ~isempty(obj.histogram{iHisto})
                    schroeder_edc(iHisto).timeData = schroeder_data{iHisto};
                    schroeder_edc(iHisto).timeVector = obj.histogram{1}.timevector(1:size(schroeder_edc(iHisto).timeData, 1));
                    if obj.filterResolution == 1
                        schroeder_edc(iHisto).channelNames = strcat('EDC ', obj.freqLabelOct);
                    else
                        schroeder_edc(iHisto).channelNames = strcat('EDC ', obj.freqLabel3rd);
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        function wavedata = loadWaveFile(obj, filename)
            if isempty(filename)
                wavedata = [];
                return;
            end
            
            if ~iscell(filename)
                filename = {filename};
            end
            
            % get number of sources and receivers
            numSources   = numel(obj.sourcePositions) / 3;
            numReceivers = numel(obj.receiverPositions) / 3;
            
            % number of impulse responses
            numFiles = numel(filename);
            if (numFiles ~= numSources * numReceivers)
                warning(['There are ' num2str(numSources * numReceivers) ' Source->Receiver combinations, but ' num2str(numFiles) ' impulse response files.']);
            end
            
            info_file = IniConfig();
            
            wavedata = cell(numSources, numReceivers);            
            
            for i = 1 : numFiles
                % get source and receiver IDs
                info_file_name = [filename{i}(1:end-4) '_info.rir'];
                info_file.ReadFile(info_file_name);
                sourceID   = info_file.GetValues('PrimarySource', 'sourceID', -1);
                receiverID = info_file.GetValues('Receiver', 'receiverID', -1);
                if (sourceID < 0) || (receiverID < 0)
                    continue;
                end
                
                % LAS: wavread is not supported by Matlab versions newer than 2015a
        %        [wavedata{sourceID+1, receiverID+1}, obj.sampleRate,~] = wavread(filename{i});
                [wavedata{sourceID+1, receiverID+1}, obj.sampleRate] = audioread(filename{i});
                
                
                sourcename   = info_file.GetValuesWithoutDefaults('PrimarySource', 'sourceName');
                receivername = info_file.GetValuesWithoutDefaults('Receiver', 'receiverName');
                
                % read performance data
                if (obj.logPerformance)       
                    obj.loadPerformanceData(info_file, i)
                end
                                                    
                % check matlab <-> raven consistency (via name tags)
                if ~strcmp(sourcename, obj.sourceNames{sourceID+1})
                    disp(['Warning! Probably wrong source<->IR mapping (source "' obj.sourceNames{sourceID+1} '" vs. IR "' sourcename '").']);
                end
                if ~strcmp(receivername, obj.receiverNames{receiverID+1})
                    disp(['Warning! Probably wrong receiver<->IR mapping (receiver "' obj.receiverNames{receiverID+1} '" vs. IR "' receivername '").']);
                end
                
            end
        end

        %------------------------------------------------------------------
        function initPerformanceData(obj)
            
                    % get number of sources and receivers
                    numFiles   = (numel(obj.sourcePositions) / 3)*(numel(obj.receiverPositions) / 3);                   
                   
                   % init variables 
                   obj.performance.ISFilterMonaural = zeros(1,numFiles);
                   obj.performance.ISFilterBinaural = zeros(1,numFiles);
                   obj.performance.RTFilterMonaural = zeros(1,numFiles);
                   obj.performance.RTFilterBinaural = zeros(1,numFiles);                     
                   obj.performance.ISGenerateImageSources = zeros(1,numFiles);
                   obj.performance.ISTransformationMatrix = zeros(1,numFiles);
                   obj.performance.ISAudibilityTest = zeros(1,numFiles);
                   obj.performance.RTTotal = zeros(1,numFiles);
                   
                    if obj.filterResolution==1
                            nBands = 10;
                    else
                            nBands = 31;
                    end
                   obj.performance.RTBands = zeros(nBands,numFiles);
        end
            
        %------------------------------------------------------------------
        function loadPerformanceData(obj, info_file, fileIndex)
            % reads ravens performance data which is stored in the info files
            i = fileIndex;
            
            % infofiles for one simulation may contain redundant information. Only read info
            % file if no data is present yet (0)
            
            if (obj.performance.ISFilterMonaural(i) == 0)
                obj.performance.ISFilterMonaural(i) = info_file.GetValues('Performance', 'RF_Controller::computeMonauralImpulseResponseImageSources_PS2R',0);
            end
            
            if (obj.performance.ISFilterBinaural(i) == 0)
                obj.performance.ISFilterBinaural(i) = info_file.GetValues('Performance', 'RF_Controller::computeBinauralImpulseResponseImageSources_PS2R',0);
            end
            
            if (obj.performance.RTFilterMonaural(i) == 0)
                obj.performance.RTFilterMonaural(i) = info_file.GetValues('Performance', 'RF_Controller::computeMonauralImpulseResponseRayTracer_PS2R',0);
            end
            
            if (obj.performance.RTFilterBinaural(i) == 0)
                obj.performance.RTFilterBinaural(i) = info_file.GetValues('Performance', 'RF_Controller::computeBinauralImpulseResponseRayTracer_PS2R',0);  
            end

            if (obj.performance.ISGenerateImageSources(i) == 0)
                obj.performance.ISGenerateImageSources(i) = info_file.GetValues('Performance', 'RIS_Ops::generate_image_sources_PS',0);
            end
            
            if (obj.performance.ISTransformationMatrix(i) == 0)
                obj.performance.ISTransformationMatrix(i) = info_file.GetValues('Performance', 'RIS_Ops::calculate_image_sources_transformation_matrix',0);
            end
            
            if (obj.performance.ISAudibilityTest(i) == 0)
                obj.performance.ISAudibilityTest(i) = info_file.GetValues('Performance', 'RIS_Ops::find_audible_sources_PS2R_BSP',0);
            end
            
            if (obj.performance.RTTotal(i) == 0)
                obj.performance.RTTotal(i) = info_file.GetValues('Performance', 'RRT_Controller::ExecuteRayTracing_PS2R_BSP',0);
            end
            
            if (sum(obj.performance.RTBands(:,i)) == 0)
                for l=1:size(obj.performance.RTBands,1)
                    obj.performance.RTBands(l,i) = info_file.GetValues('Performance', ['RRT_Controller::ExecuteRayTracing_PS2R_BSP_band' int2str(l-1)],0);
                end
            end
                        
        end
        
        %------------------------------------------------------------------
        function histo = readHistogram(obj, histoFiles)
            %
            %   [histogram, timevector] = readHistogram()
            %
            %   Returns the data of the given histogram file(s)
            %
            
            if isempty(histoFiles)
                histo = [];
                return;
            end
            
            if ~iscell(histoFiles)
                histoFiles = {histoFiles};
            end
            
            numHistograms = numel(histoFiles);
            numSources    = numel(obj.sourcePositions) / 3;
            numReceivers  = numel(obj.receiverPositions) / 3;
            histo = cell(numSources, numReceivers);
            
            hst = IniConfig();
            
            for i_histo = 1 : numHistograms
                % Read INI file
                hst.ReadFile(histoFiles{i_histo});
                
                % get source ID
                sourceID = hst.GetValues('Histogram', 'PrimarySourceID', -1);
                if sourceID < 0
                    continue;
                end
                
                % get receiver ID
                receiverID = hst.GetValues('Histogram', 'ReceiverID', -1);
                if receiverID < 0
                    continue;
                end
                
                histo{sourceID+1,receiverID+1}.sourcename   = hst.GetValuesWithoutDefaults('Histogram', 'SourceName');
                histo{sourceID+1,receiverID+1}.receivername = hst.GetValuesWithoutDefaults('Histogram', 'ReceiverName');
                
                if ~strcmp(histo{sourceID+1,receiverID+1}.receivername, obj.receiverNames{receiverID+1})
                    disp(['Warning! Probably wrong receiver-histogram mapping (receiver "' obj.receiverNames{receiverID+1} '" vs. histogram "' histo{sourceID+1,receiverID+1}.receivername '").']);
                end
                
                % read direct sound time delay
                histo{sourceID+1,receiverID+1}.directsounddelay = hst.GetValuesWithoutDefaults('Histogram', 'directSoundTimeDelay');
                
                % read lateral energy sums
                histo{sourceID+1,receiverID+1}.energyLE  = hst.GetValuesWithoutDefaults('Histogram', 'energyLE');
                histo{sourceID+1,receiverID+1}.energyLF  = hst.GetValuesWithoutDefaults('Histogram', 'energyLF');
                histo{sourceID+1,receiverID+1}.energyLFC = hst.GetValuesWithoutDefaults('Histogram', 'energyLFC');
                
                % read time steps
                numTimeSteps = hst.GetValuesWithoutDefaults('Histogram', 'Timesteps');
                %                 numFreqBands = hst.GetValues('Histogram', 'Bands');
                
                %                 histo{receiverID+1}.data       = zeros(numTimeSteps, numFreqBands);
                %                 histo{receiverID+1}.timevector = zeros(1, numTimeSteps);
                %                 for i = 1 : numTimeSteps
                %                     read_line = hst.GetValues('Histogram', num2str(i-1));
                %                     histo{receiverID+1}.timevector(i) = read_line(1);
                %                     histo{receiverID+1}.data(i,:) = read_line(3:end);
                %                 end
                
                all_time_steps = cellstr(int2str((0:numTimeSteps-1)'));
                read_line = cell2mat(hst.GetFloatVector('Histogram', all_time_steps));
                histo{sourceID+1,receiverID+1}.timevector = read_line(:, 1);
                histo{sourceID+1,receiverID+1}.data = read_line(:, 3:end);
            end
        end
        
        %------------------------------------------------------------------
        function wall_log = readWallHitLog_IS(obj, wallFiles)
            %
            %   wall_log = readWallHitLog_IS(obj, wallFiles)
            %
            %   Returns the list of image source reflections with wall hit list
            %
            
            if isempty(wallFiles)
                wall_log = [];
                return;
            end
            
            if ~iscell(wallFiles)
                wallFiles = {wallFiles};
            end
            
            numWallLogs = numel(wallFiles);
            
            % get number of sources and receivers
            if ~isempty(obj.sourcePositions) && numWallLogs > 1
                numSources = numel(obj.sourcePositions) / 3;
            else
                numSources = 1;
            end
            if ~isempty(obj.receiverPositions) && numWallLogs > 1
                numReceivers = numel(obj.receiverPositions) / 3;
            else
                numReceivers = 1;
            end
            
            % prealloc
            wall_log = cell(numSources,numReceivers);
            
            log = IniConfig();
            
            for i_log = 1 : numWallLogs
                % Read INI file
                log.ReadFile(wallFiles{i_log});
                
                % get source and receiver ID
                sourceID   = log.GetValues('WallHitLog', 'sourceID', -1);
                receiverID = log.GetValues('WallHitLog', 'receiverID', -1);
                if (sourceID < 0) || (receiverID < 0)
                    continue;
                end
                
                numReflections = log.GetValues('WallHitLog', 'numReflections', -1);
                %                 numFreqBands = log.GetValues('WallHitLog', 'numFreqBands', -1);
                
                % prealloc
                wall_log{sourceID+1,receiverID+1}(numReflections) = struct;
                
                for i = 1 : numReflections
                    wall_log{sourceID+1,receiverID+1}(i).time      = log.GetValuesWithoutDefaults(num2str(i-1), 'time');
                    wall_log{sourceID+1,receiverID+1}(i).timeslot  = log.GetValuesWithoutDefaults(num2str(i-1), 'timeslot');
                    wall_log{sourceID+1,receiverID+1}(i).azimuth_PS   = log.GetValuesWithoutDefaults(num2str(i-1), 'azimuth_PS');
                    wall_log{sourceID+1,receiverID+1}(i).elevation_PS = log.GetValuesWithoutDefaults(num2str(i-1), 'elevation_PS');
                    wall_log{sourceID+1,receiverID+1}(i).azimuth_Rec   = log.GetValuesWithoutDefaults(num2str(i-1), 'azimuth_Rec');
                    wall_log{sourceID+1,receiverID+1}(i).elevation_Rec = log.GetValuesWithoutDefaults(num2str(i-1), 'elevation_Rec');
                    wall_log{sourceID+1,receiverID+1}(i).spectrum  = log.GetValuesWithoutDefaults(num2str(i-1), 'spectrum');
                    wall_log{sourceID+1,receiverID+1}(i).materials = log.GetValuesWithoutDefaults(num2str(i-1), 'walls');
                end
            end
        end
        
        %------------------------------------------------------------------
        function [wall_log, initial_particle_energy] = readWallHitLog_RT(obj, wallFiles)
            %
            %   wall_log = readWallHitLog_IS(obj, wallFiles)
            %
            %   Returns the list of ray tracing reflections with wall hit list
            %
            
            if isempty(wallFiles)
                wall_log = [];
                return;
            end
            
            if ~iscell(wallFiles)
                wallFiles = {wallFiles};
            end
            
            numWallLogs = numel(wallFiles);
            
            % get number of sources and receivers
            if ~isempty(obj.sourcePositions) && numWallLogs > 1
                numSources = numel(obj.sourcePositions) / 3;
            else
                numSources = 1;
            end
            if ~isempty(obj.receiverPositions) && numWallLogs > 1
                numReceivers = numel(obj.receiverPositions) / 3;
            else
                numReceivers = 1;
            end
            
            % get number of bands
            if obj.filterResolution == 1
                numBands = 10;
            else
                numBands = 31;
            end
            
            % prealloc
            wall_log = cell(numSources,numReceivers,numBands);
            if nargout > 1
                initial_particle_energy = cell(numSources,numBands);
            end
            
            for i_log = 1 : numWallLogs
                % Read source/receiver IDs and frequency band
                [logspath, fname, ~] = fileparts(wallFiles{i_log});
                IDs = sscanf(fname, 'WallHitLog_PrimarySource[%i]_Receiver[%i]_Band[%i]_RT.log');
                
                % get source and receiver ID
                sourceID   = IDs(1);
                receiverID = IDs(2);
                bandID     = IDs(3);
                
                % read data
                try
                    wall_log{sourceID+1,receiverID+1,bandID+1} = dlmread(wallFiles{i_log});
                catch
                    disp(['Wall Log File empty for source ' num2str(sourceID) ' receiver ' num2str(receiverID) ' in band ' num2str(bandID)]);
                end
                wall_log{sourceID+1,receiverID+1,bandID+1} = sortrows(wall_log{sourceID+1,receiverID+1,bandID+1});
                
%                 %check for inital particle energy file
%                 if nargout > 1
%                     initPartFileName = ['InitialParticleEnergy_PrimarySource[' num2str(sourceID) ']_Band[' num2str(bandID) ']_RT.log'];
%                     if exist(fullfile(logspath, initPartFileName), 'file')
%                         try
%                             initial_particle_energy{sourceID+1,bandID+1} = dlmread(fullfile(logspath, initPartFileName));
%                         catch
%                             disp(['Initial particle energy file empty or not found for source ' num2str(sourceID) ' receiver ' num2str(receiverID) ' in band ' num2str(bandID)]);
%                         end
%                     else
%                         initial_particle_energy{sourceID+1,bandID+1} = [];
%                     end
%                 end
                
                %                 fid = fopen(wallFiles{i_log});
                %                 reflectionIndex = 1;
                %                 while ~feof(fid)
                %                     readline = fgetl(fid);
                %                     data = sscanf(readline, '%f,');
                %
                %                     % prealloc
                %                     %wall_log{sourceID+1,receiverID+1,bandID+1}(numReflections) = struct;
                %
                %                     wall_log{sourceID+1,receiverID+1,bandID+1}(reflectionIndex).initialEnergy = data(1);
                %                     wall_log{sourceID+1,receiverID+1,bandID+1}(reflectionIndex).time          = data(2);
                %                     wall_log{sourceID+1,receiverID+1,bandID+1}(reflectionIndex).timeslot      = floor(data(2) / (obj.timeSlotLength/1000));
                %                     wall_log{sourceID+1,receiverID+1,bandID+1}(reflectionIndex).lambertIntegral = data(3);
                %                     wall_log{sourceID+1,receiverID+1,bandID+1}(reflectionIndex).energy        = data(4);
                %                     wall_log{sourceID+1,receiverID+1,bandID+1}(reflectionIndex).materials     = data(5:end);
                %
                %                     reflectionIndex = reflectionIndex + 1;
                %                 end
                %                 fclose(fid);
            end
        end
        
        %------------------------------------------------------------------
        function planeWaveList = readPlaneWaveList(obj, planeWaveFiles)
            %
            %   planeWaveList = readPlaneWaveList_RT(planeWaveFiles)
            %
            %   Returns the list of reflections
            %
            
            if isempty(planeWaveFiles)
                planeWaveList = [];
                return;
            end
            
            if ~iscell(planeWaveFiles)
                planeWaveFiles = {planeWaveFiles};
            end
            
            numPWLists = numel(planeWaveFiles);
            
            % get number of sources and receivers
            if ~isempty(obj.sourcePositions) && numPWLists > 1
                numSources = numel(obj.sourcePositions) / 3;
            else
                numSources = 1;
            end
            if ~isempty(obj.receiverPositions) && numPWLists > 1
                numReceivers = numel(obj.receiverPositions) / 3;
            else
                numReceivers = 1;
            end
            
            % get number of bands
            if obj.filterResolution == 1
                numBands = 10;
            else
                numBands = 31;
            end
            
            % prealloc
            planeWaveList = cell(numSources, numReceivers);
            
            for i_log = 1 : numPWLists
                % Read source/receiver IDs and frequency band
                [logspath, fname, ~] = fileparts(planeWaveFiles{i_log});
                IDs = sscanf(fname, 'PlaneWaves_PrimarySource[%i]_Receiver[%i]_%c%c.txt');
                
                % get source and receiver ID
                sourceID   = IDs(1);
                receiverID = IDs(2);
                
                % read data
                try
                    tempData = dlmread(planeWaveFiles{i_log});
                catch
                    disp(['Plane Wave List empty for source ' num2str(sourceID) ' receiver ' num2str(receiverID)]);
                end
                % sort by time stemp
                tempData = sortrows(tempData);
                
                % get names
                planeWaveList{sourceID+1,receiverID+1}.sourcename   = obj.sourceNames{sourceID+1};
                planeWaveList{sourceID+1,receiverID+1}.receivername = obj.receiverNames{receiverID+1};
                
                % arrival time
                planeWaveList{sourceID+1,receiverID+1}.time = tempData(:, 1);
                
                % angles
                planeWaveList{sourceID+1,receiverID+1}.azimuth = tempData(:, 2);
                planeWaveList{sourceID+1,receiverID+1}.elevation = tempData(:, 3);
                
                % frequency data
                planeWaveList{sourceID+1,receiverID+1}.freqData = tempData(:, 4:end);
            end            
        end
        
        %------------------------------------------------------------------
        function plotSphereEnergy(obj, sourceID)
            if nargin < 2
                sourceID = 0;
            end
            
            if isempty(obj.histogram)
                if ~isempty(obj.monauralIR)
                    disp('Calculating energy from impulse response.');
                    sphereEnergy = zeros(size(obj.monauralIR,2), 1);
                    for i = 1 : size(obj.monauralIR,2)
                        sphereEnergy(i) = 10*log10( sum(obj.monauralIR{sourceID+1,i}.^2) );
                    end
                else
                    error('No histogram present.');
                end
            else
                sphereEnergy = zeros(size(obj.histogram,2), 1);
                for i = 1 : size(obj.histogram,2)
                    if isempty(obj.histogram{sourceID+1,i})
                        sphereEnergy(i) = -63;  % -63 dB is the lower energy limit for particles in raven
                    else
                        sphereEnergy(i) = 10*log10(sum(sum(obj.histogram{sourceID+1,i}.data)) );
                    end
                end
            end
            
            %             x = obj.receiverPositions(1:3:end);
            %             y = obj.receiverPositions(2:3:end);
            %             z = obj.receiverPositions(3:3:end);
            %             scatter3(x, y, z, obj.radiusSphere * 1000, sphereEnergy, 'filled');
            
            figure;
            for i = 1 : numel(sphereEnergy)
                [x,y,z] = sphere(16);
                x = x * obj.radiusSphere + obj.receiverPositions(i, 1);
                y = y * obj.radiusSphere + obj.receiverPositions(i, 2);
                z = z * obj.radiusSphere + obj.receiverPositions(i, 3);
                c = ones(size(z,1), size(z,2)) * sphereEnergy(i);
                surf(z, x, y, c);
                hold on;
            end
            shading flat;
            set(gca, 'CameraViewAngleMode', 'manual');
            axis equal;
            colorbar;
            
            
            hold on;
            obj.plotModel(gca);
            
            set(gca, 'CameraViewAngle', 10);
        end
        
        %------------------------------------------------------------------
        function soundspeed = getSoundSpeed(obj)
            %  Give temperature in degree celsius, relative humidity in percent and
            %  pressure in Pa. Defaults are 20 degree celcius, 50% humidity and 101325 Pa
            %  The exact solution is valid from 0 to 30 degrees celcius.
            %  Taken from:
            %  http:%resource.npl.co.uk/acoustics/techguides/speedair/:
            %  "The calculator presented here computes the zero-frequency speed of sound
            %  in humid air according to Cramer (J. Acoust. Soc. Am., 93, p2510, 1993),
            %  with saturation vapour pressure taken from Davis, Metrologia, 29, p67, 1992,
            %  and a mole fraction of carbon dioxide of 0.0004.
            %  [...]
            
            temperature = obj.getTemperature();
            humidity    = obj.getHumidity();
            pressure    = obj.getPressure();
            
            Kelvin = 273.15;
            
            % Measured ambient temp
            T_kel = Kelvin + temperature;
            
            % Molecular concentration of water vapour calculated from Rh using Giacomos method by Davis (1991) as implemented in DTU report 11b-1997
            ENH = 3.14 * .00000001 * pressure + 1.00062 + temperature*temperature * 5.6 * .0000001;
            
            % These commented lines correspond to values used in Cramer (Appendix)
            % PSV1 = sqr(T_kel)*1.2811805*Math.pow(10,-5)-1.9509874*Math.pow(10,-2)*T_kel ;
            % PSV2 = 34.04926034-6.3536311*Math.pow(10,3)/T_kel;
            PSV1 = ( T_kel*T_kel * 1.2378847 * 0.00001 ) - ( 1.9121316 * 0.01 * T_kel );
            PSV2 = 33.93711047 - 6.3431645 * 1000 / T_kel;
            PSV  = exp(PSV1) * exp(PSV2);
            H    = humidity * ENH * PSV / pressure;
            Xw   = H / 100.0;
            % Xc   = 314.0 * 10^-6;
            Xc   = 400.0 * .000001;
            
            % Speed calculated using the method of Cramer from JASA vol 93 pg 2510
            C1 = 0.603055  * temperature +  331.5024 - temperature*temperature * 5.28 / 10000 ...
                + (0.1495874 * temperature + 51.471935 - temperature*temperature * 7.82 / 10000)   * Xw;
            C2 =(-1.82 / 10000000 + 3.73 / 100000000 * temperature - temperature*temperature * 2.93 / 10000000000) * pressure ...
                + (-85.20931 - 0.228525 * temperature + temperature*temperature * 5.91 /  100000 ) * Xc;
            C3 = Xw*Xw * 2.835149 + pressure*pressure * 2.15 / 10000000000000 ...
                - Xc*Xc * 29.179762 - 4.86 / 10000 * Xw * pressure * Xc;
            
            soundspeed = C1 + C2 - C3;
            
        end
        
        %------------------------------------------------------------------
        function N = getNumberOfParticlesRecommendation(obj, stdDev_dB, roomID)
            % N = getNumberOfParticlesRecommendation(stdDev_dB, roomID)
            
            if nargin < 3
                roomID = 0;
            end
            if nargin < 2
                stdDev_dB = 1; % default 1dB as assumed JND
            end
            
            N = obj.getRoomVolume(roomID) ./ ((stdDev_dB/4.34)^2 * pi*obj.radiusSphere^2 * obj.getSoundSpeed() * obj.timeSlotLength/1000);
            
        end
        
        %------------------------------------------------------------------
        function plotSurfaceEnergy(obj, sourceID)
            if nargin < 2
                sourceID = 0;
            end
            
            if isempty(obj.uniformReceiverGridX)
                disp('For surface plots a uniform receiver grid has to be created first. (Or rebuilt using "rebuildReceiverGrid")');
                disp('Trying to restore the grid from the given receiver positions...');
                obj.restoreReceiverGrid();
            end
            
            if isempty(obj.histogram)
                if ~isempty(obj.monauralIR)
                    disp('Calculating energy from impulse response.');
                    surfaceEnergy = zeros(size(obj.monauralIR,2), 1);
                    for i = 1 : size(obj.monauralIR,2)
                        surfaceEnergy(i) = 10*log10( sum(obj.monauralIR{sourceID+1,i}.^2) );
                    end
                else
                    error('No histogram present.');
                end
            else
                sphereEnergy = zeros(size(obj.histogram,2), 1);
                for i = 1 : size(obj.histogram,2)
                    if isempty(obj.histogram{sourceID+1,i})
                        sphereEnergy(i) = -63;  % -63 dB is the lower energy limit for particles in raven
                    else
                        sphereEnergy(i) = 10*log10( sum(sum(obj.histogram{sourceID+1,i}.data)) );
                    end
                end
            end
            
            c = reshape(sphereEnergy, size(obj.uniformReceiverGridX,1), size(obj.uniformReceiverGridX,2));
            
            surf(obj.uniformReceiverGridZ, obj.uniformReceiverGridX, obj.uniformReceiverGridY, c);
            shading flat;
            axis equal;
            colorbar;
        end
        
        %------------------------------------------------------------------
        function plotSurfaceEnergyUniform(obj, resolution, sourceID)
            if nargin < 3
                sourceID = 0;
            end
            
            if isempty(obj.histogram)
                if ~isempty(obj.monauralIR)
                    disp('Calculating energy from impulse response.');
                    surfaceEnergy = zeros(size(obj.monauralIR,2), 1);
                    for i = 1 : size(obj.monauralIR,2)
                        surfaceEnergy(i) = sum(obj.monauralIR{sourceID+1,i}.^2);
                    end
                else
                    error('No histogram present.');
                end
            else
                sphereEnergy = zeros(size(obj.histogram,2), 1);
                for i = 1 : size(obj.histogram,2)
                    if isempty(obj.histogram{sourceID+1,i})
                        sphereEnergy(i) = -63;  % -63 dB is the lower energy limit for particles in raven
                    else
                        sphereEnergy(i) = sum(sum(obj.histogram{sourceID+1,i}.data));
                    end
                end
            end
            
            if nargin < 2
                resolution = 1;
            end
            
            x = obj.receiverPositions(:, 1);
            y = obj.receiverPositions(:, 2);
            z = obj.receiverPositions(:, 3);
            minx = min(x);
            maxx = max(x);
            %             miny = min(y);
            %             maxy = max(y);
            minz = min(z);
            maxz = max(z);
            
            c = reshape(sphereEnergy, size(x,1), size(x,2));
            
            [uniformz, uniformx] = meshgrid(minz : resolution : maxz, minx : resolution : maxx);
            uniformy = uniformx;
            uniformy(:,:) = mean(mean(y));
            uniformc = griddata(z, x, c, uniformz, uniformx);
            
            surf(uniformz, uniformx, uniformy, uniformc);
            shading flat;
            axis equal;
            colorbar;
        end
        
        %------------------------------------------------------------------
        function plotSphereEnergyAnimation(obj, sourceID)
            if nargin < 2
                sourceID = 0;
            end
            
            numTimeSteps = 0;
            if isempty(obj.histogram)
                if ~isempty(obj.monauralIR)
                    disp('Calculating energy from impulse response.');
                    numTimeSteps = size(obj.monauralIR{find(~cellfun(@isempty, obj.monauralIR), 1)}, 1);
                    sphereEnergy = zeros(size(obj.monauralIR,2), numTimeSteps);
                    for i_sphere = 1 : size(obj.monauralIR,2)
                        for i_sample = 1 : numTimeSteps
                            sphereEnergy(i_sphere, i_sample) = 10*log10(obj.monauralIR{sourceID+1,i}(i_sample)^2  + eps);
                        end
                    end
                else
                    error('No histogram present.');
                end
            else
                numTimeSteps = numel(obj.histogram{find(~cellfun(@isempty, obj.histogram), 1)}.timevector);
                sphereEnergy = zeros(size(obj.histogram,2), numTimeSteps);
                for i_sphere = 1 : size(obj.histogram,2)
                    if isempty(obj.histogram{sourceID+1,i_sphere})
                        sphereEnergy(i_sphere, :) = -63;
                    else
                        for i_timestep = 1 : numTimeSteps
                            sphereEnergy(i_sphere, i_timestep) = 10*log10(sum(obj.histogram{sourceID+1,i_sphere}.data(i_timestep, :)) + eps);
                        end
                    end
                end
            end
            
            if numTimeSteps > 0
                fig = figure;
                for i_sphere = 1 : size(sphereEnergy, 1)
                    [x,y,z] = sphere(16);
                    x = x * obj.radiusSphere + obj.receiverPositions(i_sphere, 1);
                    y = y * obj.radiusSphere + obj.receiverPositions(i_sphere, 2);
                    z = z * obj.radiusSphere + obj.receiverPositions(i_sphere, 3);
                    c = zeros(size(z,1), size(z,2));
                    sphere_handle(i_sphere) = surf(z, x, y, c);
                    hold on;
                end
                shading flat;
                set(gca, 'CameraViewAngleMode', 'manual');
                axis equal;
                caxis([-60 max(max(sphereEnergy))]);
                colorbar;
                hold on;
                obj.plotModel(gca);
                
                set(gca, 'CameraViewAngle', 10);
                
                for i_rep = 1 : 1
                    for i_time = 1 : numTimeSteps
                        for i_sphere = 1 : size(sphereEnergy, 1)
                            sphere_color = ones(size(x,1), size(x,2)) * sphereEnergy(i_sphere, i_time);
                            set(sphere_handle(i_sphere), 'CData', sphere_color);
                        end
                        
                        % show the current time in the impulse response
                        if exist('h', 'var')
                            delete(h);
                        end
                        h = text(0,0, [num2str(i_time/numTimeSteps * obj.timeSlotLength) 's']);
                        
                        pause(1 / i_time);
                        
                        %                         lighting phong;
                        %                         set(gcf,'Renderer','zbuffer');
                        %                         frame(i_time) = getframe;
                    end
                end
                
                close(fig);
                
                %                 figure;
                %                 movie(frame, 1, 10);
            end
        end
        
        
        %------------------------------------------------------------------
        function getWallHitLogBand(obj,iBand)
            
            if obj.logPerformance
                obj.initPerformanceData;
            end
            
            disp('gatherResultsBand is called.');

            if ~isnumeric(iBand)
                error('Your argument has to be numeric and positive scalar.');
            end
            
            if obj.exportWallHitLog
                wall_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'WallHitLog_', ['_IS.log']}, '.log');
                wall_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'WallHitLog_', ['[' num2str(iBand-1) ']_RT.log']}, '.log');
                
                % read the wall hit logs back from disk
                obj.wallHitLog_IS = obj.readWallHitLog_IS(wall_files_IS);
                [obj.wallHitLog_RT, obj.initialParticleEnergy] = obj.readWallHitLog_RT(wall_files_RT);
            else
                obj.wallHitLog_IS = [];
                obj.wallHitLog_RT = [];
                obj.initialParticleEnergy = [];
            end
            
            if obj.exportPlaneWaveList
                planewave_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'PlaneWaves_', ['_IS.txt']}, '.txt');
                planewave_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'PlaneWaves_', ['[' num2str(iBand-1) ']_RT.txt']}, '.txt');
                
                % read the plane wave lists back from disk
                obj.planeWaveList_IS = obj.readPlaneWaveList(planewave_files_IS);
                obj.planeWaveList_RT = obj.readPlaneWaveList(planewave_files_RT);
            else
                obj.planeWaveList_IS = [];
                obj.planeWaveList_RT = [];
            end
            
            disp(['Successfully gathered results from band ' num2str(iBand)]);
        end
    end % public methods
    
    %---------------------- PRIVATE METHODS ------------------------------%
    methods (Access = 'private')
        %------------------------------------------------------------------
        function gatherResults(obj)
            
            if obj.logPerformance
                obj.initPerformanceData;
            end
            
            if obj.generateRIR
                ir_files = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\RIR_Combined', 'PrimarySource', 'Receiver'}, '.wav');
                ir_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\RIR_IS', 'PrimarySource', 'Receiver'}, '.wav');
                ir_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\RIR_RT', 'PrimarySource', 'Receiver'}, '.wav');
                
                % read the wave files back from disk
                obj.monauralIR = obj.loadWaveFile(ir_files);
                obj.monauralIR_IS = obj.loadWaveFile(ir_files_IS);
                obj.monauralIR_RT = obj.loadWaveFile(ir_files_RT);
            else
                obj.monauralIR = [];
                obj.monauralIR_IS = [];
                obj.monauralIR_RT = [];
            end
            if obj.generateBRIR
                ir_files = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\BRIR_Combined', 'PrimarySource', 'Receiver'}, '.wav');
                ir_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\BRIR_IS', 'PrimarySource', 'Receiver'}, '.wav');
                ir_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\BRIR_RT', 'PrimarySource', 'Receiver'}, '.wav');
                
                % read the wave files back from disk
                obj.binauralIR = obj.loadWaveFile(ir_files);
                obj.binauralIR_IS = obj.loadWaveFile(ir_files_IS);
                obj.binauralIR_RT = obj.loadWaveFile(ir_files_RT);
            else
                obj.binauralIR = [];
                obj.binauralIR_IS = [];
                obj.binauralIR_RT = [];
            end
            if obj.generateISHOA
                ir_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\HOA_IS', 'PrimarySource', 'Receiver'}, '.wav');
                
                % read the wave files back from disk
                obj.ambisonicsIR_IS = obj.loadWaveFile(ir_files_IS);
                
                % check for combined results with ray tracing
                if obj.generateRTHOA
                    ir_files_combined = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\HOA_Combined', 'PrimarySource', 'Receiver'}, '.wav');
                    
                    % read the wave files back from disk
                    obj.ambisonicsIR = obj.loadWaveFile(ir_files_combined);
                else
                    obj.ambisonicsIR = [];
                end
            else
                obj.ambisonicsIR_IS = [];
            end
            if obj.generateRTHOA
                ir_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\HOA_RT', 'PrimarySource', 'Receiver'}, '.wav');
                
                % read the wave files back from disk
                obj.ambisonicsIR_RT = obj.loadWaveFile(ir_files_RT);
            else
                obj.ambisonicsIR_RT = [];
            end
            
            if obj.generateISVBAP
                ir_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\VBAP_IS', 'PrimarySource', 'Receiver'}, '.wav');
                
                % read the wave files back from disk
                obj.vbapIR_IS = obj.loadWaveFile(ir_files_IS);
                
                % check for combined results with ray tracing
                if obj.generateRTVBAP
                    ir_files_combined = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\VBAP_Combined', 'PrimarySource', 'Receiver'}, '.wav');
                    
                    % read the wave files back from disk
                    obj.vbapIR = obj.loadWaveFile(ir_files_combined);
                else
                    obj.vbapIR = [];
                end
            else
                obj.vbapIR_IS = [];
            end
            if obj.generateRTVBAP
                ir_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'\VBAP_RT', 'PrimarySource', 'Receiver'}, '.wav');
                
                % read the wave files back from disk
                obj.vbapIR_RT = obj.loadWaveFile(ir_files_RT);
            else
                obj.vbapIR_RT = [];
            end
            
            if obj.exportHistogram
                histo_files = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), '_Hybrid', '.hst');
                raytracing_histo_files = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), '_RT', '.hst');
                
                % read the histogram files back from disk
                obj.histogram = obj.readHistogram(histo_files);
                obj.histogramRT = obj.readHistogram(raytracing_histo_files);
            else
                obj.histogram = [];
                obj.histogramRT = [];
            end
            
            if obj.exportWallHitLog
                wall_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'WallHitLog_', '_IS.log'}, '.log');
                wall_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'WallHitLog_', '_RT.log'}, '.log');
                
                % read the wall hit logs back from disk
                obj.wallHitLog_IS = obj.readWallHitLog_IS(wall_files_IS);
                [obj.wallHitLog_RT, obj.initialParticleEnergy] = obj.readWallHitLog_RT(wall_files_RT);
            else
                obj.wallHitLog_IS = [];
                obj.wallHitLog_RT = [];
                obj.initialParticleEnergy = [];
            end
            
            if obj.exportPlaneWaveList
                planewave_files_IS = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'PlaneWaves_', '_IS.txt'}, '.txt');
                planewave_files_RT = obj.scan_output_folder(fullfile(obj.pathResults, obj.projectTag), {'PlaneWaves_', '_RT.txt'}, '.txt');
                
                % read the plane wave lists back from disk
                obj.planeWaveList_IS = obj.readPlaneWaveList(planewave_files_IS);
                obj.planeWaveList_RT = obj.readPlaneWaveList(planewave_files_RT);
            else
                obj.planeWaveList_IS = [];
                obj.planeWaveList_RT = [];
            end
        end
        
        %------------------------------------------------------------------
        function deleteResultsInRavenFolder(obj)
            if exist(fullfile(obj.pathResults, obj.projectTag), 'dir')
                rmdir(fullfile(obj.pathResults, obj.projectTag), 's');
            end
        end
        
        %------------------------------------------------------------------
        function restoreReceiverGrid(obj)
            numReceivers = numel(obj.receiverPositions) / 3;    %xyz
            if numReceivers < 1
                error('No receiver position data present.');
            end
            x = obj.receiverPositions(:, 1);
            y = obj.receiverPositions(:, 2);
            z = obj.receiverPositions(:, 3);
            
            [x, new_index_order] = sort(x);
            y = y(new_index_order);
            z = z(new_index_order);
            
            uniform_x = [];
            uniform_y = [];
            uniform_z = [];
            
            row_size = 0;
            
            i = 1;
            while i <= numel(x)
                uniform_row_indices = (x==x(i));
                
                row_x = x(uniform_row_indices);
                row_y = y(uniform_row_indices);
                row_z = z(uniform_row_indices);
                
                [row_z, new_row_order] = sort(row_z);
                row_x = row_x(new_row_order);
                row_y = row_y(new_row_order);
                
                uniform_x = [uniform_x row_x];
                uniform_y = [uniform_y row_y];
                uniform_z = [uniform_z row_z];
                
                row_size = numel(row_x);
                
                i = i + numel(row_x);
            end
            
            if row_size > 0
                if rem(numel(x), row_size) == 0
                    col_size = numel(x) / row_size;
                    obj.uniformReceiverGridX = reshape(uniform_x, row_size, col_size);
                    obj.uniformReceiverGridY = reshape(uniform_y, row_size, col_size);
                    obj.uniformReceiverGridZ = reshape(uniform_z, row_size, col_size);
                end
            end
        end
        
    end % private methods
    
    %---------------------- STATIC METHODS -------------------------------%
    methods(Static)
        
        %------------------------------------------------------------------
        function rvn_pos = pSU2RVN(su_pos)
            if size(su_pos, 2) ~= 3
                error('Input positions must be given in Nx3 matrix.');
            end
            rvn_pos = su_pos;
            rvn_pos(:, 1) = sign(RavenProject.COORD_TRAFO_SKETCHUP2RAVEN(1)) .* su_pos(:, abs(RavenProject.COORD_TRAFO_SKETCHUP2RAVEN(1)));
            rvn_pos(:, 2) = sign(RavenProject.COORD_TRAFO_SKETCHUP2RAVEN(2)) .* su_pos(:, abs(RavenProject.COORD_TRAFO_SKETCHUP2RAVEN(2)));
            rvn_pos(:, 3) = sign(RavenProject.COORD_TRAFO_SKETCHUP2RAVEN(3)) .* su_pos(:, abs(RavenProject.COORD_TRAFO_SKETCHUP2RAVEN(3)));
        end
        
        %------------------------------------------------------------------
        function su_pos = pRVN2SU(rvn_pos)
            if size(rvn_pos, 2) ~= 3
                error('Input positions must be given in Nx3 matrix.');
            end
            su_pos = rvn_pos;
            su_pos(:, 1) = sign(RavenProject.COORD_TRAFO_RAVEN2SKETCHUP(1)) .* rvn_pos(:, abs(RavenProject.COORD_TRAFO_RAVEN2SKETCHUP(1)));
            su_pos(:, 2) = sign(RavenProject.COORD_TRAFO_RAVEN2SKETCHUP(2)) .* rvn_pos(:, abs(RavenProject.COORD_TRAFO_RAVEN2SKETCHUP(2)));
            su_pos(:, 3) = sign(RavenProject.COORD_TRAFO_RAVEN2SKETCHUP(3)) .* rvn_pos(:, abs(RavenProject.COORD_TRAFO_RAVEN2SKETCHUP(3)));
        end
        
        %------------------------------------------------------------------
        function outputFilename = convolve(soundFilename, IRitaAudioOrFile, outputFilename, overwrite, amplification_dB)
            %outputFilename = convolve(soundFilename, IRitaAudio, outputFilename, overwrite, amplification_dB)
            
            if ~exist(soundFilename, 'file')
                error('Sound file not found.');
            end
            
            % check if convolution program is available in current directory
            if ~exist('FIRFilter.exe', 'file')
                error('Convolution engine (''FIRFilter.exe'') not found in current directory.');
            end
            
            if exist(outputFilename, 'file')
                % ask user if file should be overwritten
                if nargin < 4
                    answ = questdlg('Do you want to overwrite the target file?', ...
                        'File already exists. Overwrite?', ...
                        'Overwrite', 'Cancel', 'Overwrite');
                    switch answ,
                        case 'Overwrite',
                            overwrite = 1;
                        case 'Cancel',
                            outputFilename = '';
                            return;
                    end % switch
                end
                
                if ~overwrite
                    warning('File already exists and was not allowed to be overwritten.');
                    return;
                end
            end
            
            if isa(IRitaAudioOrFile, 'itaAudio')
                tmpFileName = 'RavenProjectTempImpulseResponse1234567890.wav';
                ita_write(IRitaAudioOrFile, tmpFileName, 'overwrite', 'nbits', 32);
            elseif ischar(IRitaAudioOrFile)
                tmpFileName = IRitaAudioOrFile;
            else
                error('Couldn''t read impulse response.');
            end
            
            executeCommand = ['FIRFilter.exe '];
            if exist('amplification_dB', 'var') && isnumeric(amplification_dB) && (amplification_dB ~= 0)
                executeCommand = [executeCommand '-g ' num2str(amplification_dB) ' '];
            end
            executeCommand = [executeCommand '"' soundFilename '" "' tmpFileName '" "' outputFilename '"'];
            disp(executeCommand);
            system(executeCommand);
            
            if isa(IRitaAudioOrFile, 'itaAudio')
                delete(tmpFileName);
            end
        end
        
        %------------------------------------------------------------------
        function outfile = mix(outfile, varargin)
            % outfile = mix(outfile, infile1, [infile2], [infile3], ...)
            % outfile = mix(outfile, {infile1, [infile2], [infile3], ...})
            
            if nargin < 2
                error('At least two parameters expected.');
            end
            
            % check if mixing program is available in current directory
            if ~exist('CLmix.exe', 'file')
                error('Mixing engine (''CLmix.exe'') not found in current directory.');
            end
            
            % make command
            executeCommand = ['CLmix.exe "' outfile];
            
            % append input file names
            if iscell(varargin{1})
                for iFile = 1 : numel(varargin{1})
                    executeCommand = [executeCommand '" "' varargin{1}{iFile}];
                end
            else
                for iFile = 1 : nargin-1
                    executeCommand = [executeCommand '" "' varargin{iFile}];
                end
            end
            
            executeCommand = [executeCommand '"'];
            
            % execute command
            disp(executeCommand);
            system(executeCommand);
        end

        %------------------------------------------------------------------
        function lspSignals = ambisonicsDecoding(BformatItaAudio, decodingMatrix, nfcFilter)
            % get parameters
            nSmpls = BformatItaAudio.nSamples;
            nLS = size(decodingMatrix, 2);

            % pre-allocate memory
            lspSignals = itaAudio;
            lspSignals.timeData = zeros(nSmpls, nLS);

            % partition data to avoid memory problems
            blockSize = 1000;
            numCycles = ceil(nSmpls / blockSize);
            startSample = 1;
            endSample = startSample + blockSize;

            % signal too short? (nSmpls < blockSize)
            if numCycles < 2
                endSample = nSmpls;
            end

            % NFC
            if nargin > 2
                % 1:1 channel by channel convolution
                BformatItaAudio = ita_convolve(BformatItaAudio, nfcFilter);
                % TODO: undo time shift

                disp('NFC filters did apply a time shift which should be reversed. TODO.');
            end

            % DECODING
            h = waitbar(0, 'Decoding...');
            for i = 1 : numCycles
                lspSignals.timeData(startSample : endSample, :) = real(BformatItaAudio.timeData(startSample : endSample, 1:size(decodingMatrix, 1)) * decodingMatrix);
                startSample = startSample + blockSize; 
                endSample = endSample + blockSize;
                if endSample > size(BformatItaAudio.timeData,1)
                    endSample = size(BformatItaAudio.timeData,1);
                end
                if ishandle(h)
                    waitbar(i / numCycles, h);
                end
            end
            delete(h);
        end
        
        %------------------------------------------------------------------
        function energySpectrum = powerSpectrum2energySpectrum(powerSpectrum)
            RF_DEF_thirdOctaveBoundary = [ ...
                22.4, ...
                27.9,      35.1,      44.2, ...
                55.6,      70.1,      88.4, ...
                111.4,     140.3,     176.8, ...
                222.8,     280.7,     353.6, ...
                445.4,     561.2,     707.1, ...
                890.9,    1122.5,    1414.2, ...
                1781.8,    2244.9,    2828.4, ...
                3563.6,    4489.9,    5656.9, ...
                7127.3,    8979.8,   11313.8, ...
                14255.0,   17960.0,   22627.6 ];
            RF_DEF_octaveBoundary = [ ...
                44.2,      88.4,     176.8, ...
                353.6,     707.1,    1414.2, ...
                2828.4,    5656.9,   11313.8, ...
                22627.6 ];
            
            numFrequencyBands = size(powerSpectrum, 2);
            numTimeSlots = size(powerSpectrum, 1);
            energySpectrum = zeros(numTimeSlots, numFrequencyBands);
            
            % OCTAVE RESOLUTION
            if (numFrequencyBands == 10)
                % get total bandwidth in Hz of all octave bands
                bandwidthTotal = RF_DEF_octaveBoundary(10);	% RF_DEF_octaveBoundary array defines the upper band limits (see RD_Defines.h)
                
                for frequencystep = 1 : numFrequencyBands
                    % define the upper and lower band borders of the current band
                    upperBandLimit = RF_DEF_octaveBoundary(frequencystep);
                    if (frequencystep == 1)
                        lowerBandLimit = 0;
                    else
                        lowerBandLimit = RF_DEF_octaveBoundary(frequencystep - 1);
                    end
                    
                    % get bandwidth in Hz of the current band
                    bandwidthCurrentBand = upperBandLimit - lowerBandLimit;
                    
                    % multiply the power level at the center frequency with the band's width to get the energy per band
                    energySpectrum(:, frequencystep) = (bandwidthCurrentBand / bandwidthTotal) * powerSpectrum(:, frequencystep);
                end
                % THIRD-OCTAVE RESOLUTION
            elseif (numFrequencyBands == 31)
                % get total bandwidth in Hz of all third-octave bands
                bandwidthTotal = RF_DEF_thirdOctaveBoundary(31);	% RF_DEF_octaveBoundary array defines the upper band limits (see RD_Defines.h)
                
                for frequencystep = 1 : numFrequencyBands
                    % define the upper and lower band borders of the current band
                    upperBandLimit = RF_DEF_thirdOctaveBoundary(frequencystep);
                    if (frequencystep == 1)
                        lowerBandLimit = 0;
                    else
                        lowerBandLimit = RF_DEF_thirdOctaveBoundary(frequencystep - 1);
                    end
                    
                    % get bandwidth in Hz of the current band
                    bandwidthCurrentBand = upperBandLimit - lowerBandLimit;
                    
                    % multiply the power level at the center frequency with the band's width to get the energy per band
                    energySpectrum(:, frequencystep) = (bandwidthCurrentBand / bandwidthTotal) * powerSpectrum(:, frequencystep);
                end
                % UNKNOWN RESOLUTION - ERROR
            else
                disp('Error in RavenProject.powerSpectrum2energySpectrum: Unknown frequency resolution.');
                energySpectrum = [];
            end
        end
        
        %------------------------------------------------------------------
        function thisReverbTime = getT30_fromBinauralImpulseResponse(brir)            
            if ~iscell(brir)
                brir = {brir};
            end
            
            thisReverbTime = cell(numel(brir), 1);
                      
            for i = 1 : numel(brir)
                if ~isempty(brir{i})
                    disp('third-octave filtering');
                    brir{i} = ita_mpb_filter(brir{i}, '3-oct');

                    disp('schroeder decay curve and reverberation time');
                    thisReverbTime{i} = ita_roomacoustics_reverberation_time(brir{i}, 'edc_type','normal');

                    disp('average left and right ear''s reverberation time');
                    if numel(thisReverbTime{i}) > 1
                        thisReverbTime{i} = mean(thisReverbTime{i});
                    end
                    thisReverbTime{i} = mean([thisReverbTime{i}.freqData(1:2:60) thisReverbTime{i}.freqData(2:2:60)], 2);                    
                else
                    thisReverbTime{i} = [];
                end
            end
            
            if numel(thisReverbTime) == 1
                thisReverbTime = thisReverbTime{1};
            end               
        end
        
        %------------------------------------------------------------------
        function value_out = averageAfterDIN(values_in, afterDIN)
            if nargin < 2
                afterDIN = 1;   % default -> average after DIN, otherwise just return mean
            end
            if ~iscell(values_in)
                values_in = {values_in};
            end
            
            for iCell = 1 : numel(values_in)
                % averaging a la DIN (average of 500Hz and 1kHz for
                % octaves or 400, 500, 630, 800, 1000, 1250 Hz for
                % third-octave resolution
                if (numel(values_in{iCell}) == 10) && afterDIN
                    value_out{iCell} = (values_in{iCell}(5) + values_in{iCell}(6)) / 2;  % 500 and 1000 Hz
                elseif (numel(values_in{iCell}) == 31) && afterDIN
                    value_out{iCell} = ...
                        (values_in{iCell}(14) + ...    %  400 Hz
                        values_in{iCell}(15) + ...     %  500 Hz
                        values_in{iCell}(16) + ...     %  630 Hz
                        values_in{iCell}(17) + ...     %  800 Hz
                        values_in{iCell}(18) + ...     % 1000 Hz
                        values_in{iCell}(19)) / 6;     % 1250 Hz
                else
                    % neither octaves nor thirds, average over all bands
                    value_out{iCell} = mean(values_in{iCell});
                end
            end
            
            if numel(value_out) == 1
                value_out = value_out{1};
            end
        end
        
        %------------------------------------------------------------------
        function value_out = averageAfterDINLateral(values_in, afterDIN)
            if nargin < 2
                afterDIN = 1;   % default -> average after DIN, otherwise just return mean
            end
            if ~iscell(values_in)
                values_in = {values_in};
            end
            
            for iCell = 1 : numel(values_in)
                % averaging a la DIN (average of 125Hz ro 1kHz for
                % octaves or 100 to 1250 Hz for third-octave resolution
                if (numel(values_in{iCell}) == 10) && afterDIN
                    value_out{iCell} = ...
                        (values_in{iCell}(3) + ...     %  125 Hz
                        values_in{iCell}(4) + ...      %  250 Hz
                        values_in{iCell}(5) + ...      %  500 Hz
                        values_in{iCell}(6)) / 4;      % 1000 Hz
                elseif (numel(values_in{iCell}) == 31) && afterDIN
                    value_out{iCell} = ...
                        (values_in{iCell}(8) + ...     %  100 Hz
                        values_in{iCell}(9) + ...      %  125 Hz
                        values_in{iCell}(10) + ...     %  160 Hz
                        values_in{iCell}(11) + ...     %  200 Hz
                        values_in{iCell}(12) + ...     %  250 Hz
                        values_in{iCell}(13) + ...     %  315 Hz
                        values_in{iCell}(14) + ...     %  400 Hz
                        values_in{iCell}(15) + ...     %  500 Hz
                        values_in{iCell}(16) + ...     %  630 Hz
                        values_in{iCell}(17) + ...     %  800 Hz
                        values_in{iCell}(18) + ...     % 1000 Hz
                        values_in{iCell}(19)) / 12;    % 1250 Hz
                else
                    % neither octaves nor thirds, average over all bands
                    value_out{iCell} = mean(values_in{iCell});
                end
            end
            
            if numel(value_out) == 1
                value_out = value_out{1};
            end
        end
        
        %------------------------------------------------------------------
        function value_out = averageOverReceivers(rec_data)
            
            if ~iscell(rec_data)
                rec_data = {rec_data};
            end
            
            summe = [];
            validReceiverCount = 0;
            for iRec = 1 : numel(rec_data)
                if ~isempty(rec_data{iRec})
                    if isempty(summe)
                        summe = rec_data{iRec};
                    else
                        summe = summe + rec_data{iRec};
                    end
                    validReceiverCount = validReceiverCount + 1;
                end
            end
            
            if validReceiverCount > 0
                % average over all receivers
                value_out = summe / validReceiverCount;
            else
                value_out = [];
            end
        end
        
        %------------------------------------------------------------------
        function histo = applyTemporalLowPassToLatePartOfHistogram(histo, min_block_size, max_block_size)
            numTimeSteps = size(histo, 1);
            if nargin < 2
                min_block_size = 0.9;	% just slightly below 1 to avoid 2-slot-windows at the beginning (1/2 = 0.5 -> rounded to 1)
            end
            if nargin < 2
                max_block_size = numTimeSteps * 0.1;    % at the end moving average windows will have have the size of 10% of the impulse response
            end
            startTimeStep = ceil(min_block_size / 2) + 1;
            endTimeStep = numTimeSteps - ceil(max_block_size / 2);
            currentWindowLength = min_block_size;
            stepFactor = (max_block_size/min_block_size)^(1/numTimeSteps);
            for timestep = startTimeStep : endTimeStep
                windowBegin = round(timestep - currentWindowLength/2);
                windowEnd = round(timestep + currentWindowLength/2);
                windowLength = windowEnd - windowBegin + 1;
                histo(timestep, :) = sum(histo(windowBegin:windowEnd, :), 1) / windowLength;
                
                currentWindowLength = currentWindowLength * stepFactor;
            end
            for timestep = endTimeStep : numTimeSteps
                windowBegin = round(timestep - currentWindowLength/2);
                windowEnd = numTimeSteps;
                windowLength = windowEnd - windowBegin + 1;
                histo(timestep, :) = sum(histo(windowBegin:windowEnd, :), 1) / windowLength;
            end
        end
        
        %------------------------------------------------------------------
        function wav_files = scan_output_folder(outputDir, searchTag, extension)
            %
            % scan_output_folder(outputDir, searchTag, extension)
            %
            %   Reads all impulse responses in the given output directory that contain
            %   the seachTag(s) in their filename. SearchTag might be e.g. "BRIR_IS_",
            %   "BRIR_RT_" or "BRIR_Combined_". SearchTag can also be an array of
            %   cells: {'BRIR_IS_', 'portal'}. If no Extension is given, the function
            %   will return all .wav files by default.
            %
            
            if nargin < 3
                extension = '.wav';
            end
            
            if (nargin > 1) && ~isempty(searchTag)
                if ~iscell(searchTag)
                    searchTag = {searchTag};
                end
                searchTag = lower(searchTag);
                
                wav_files = [];
                all_ir_files = dirrec(outputDir, extension);
                
                for i_ir = 1 : numel(all_ir_files)
                    % look for searchTag(s) in current file name
                    
                    tags_found = true;
                    for i_tag = 1 : numel(searchTag)
                        if isempty(strfind(lower(all_ir_files{i_ir}), searchTag{i_tag}))
                            tags_found = false;
                        end
                    end
                    
                    if tags_found
                        wav_files{end+1} = all_ir_files{i_ir};
                    end
                end
            else
                % no search tags given, output all files
                wav_files = dirrec(outputDir, extension);
            end
        end
        
        %------------------------------------------------------------------
        function out_string = cat_cell_of_strings(cell_of_strings)
            if iscell(cell_of_strings)
                out_string = '';
                for i = 1 : numel(cell_of_strings)
                    out_string = [out_string cell_of_strings{i} ','];
                end
                out_string(end) = [];  % delete last ","
            else
                out_string = cell_of_strings;
            end
        end
        
        %------------------------------------------------------------------
        function out_string = make_proper_string(in_matrix)
            if iscell(in_matrix)
                out_string = '';
                for i = 1 : numel(in_matrix)
                    out_string = [out_string num2str(in_matrix{i}, '%.3f,')];
                end
                out_string(end) = [];  % delete last ","
            else
                if numel(in_matrix) > 3
                    temp = num2str(in_matrix(:,:), '%.3f,');
                    out_string(1:numel(temp)) = deal(temp');
                    out_string(end) = [];  % delete last ", "
                elseif numel(in_matrix) > 0
                    % 1 frame
                    out_string = num2str(in_matrix(:)', '%.3f,');
                    out_string(end) = [];  % delete last ", "
                else
                    out_string = [];
                end
            end
        end
        
        %------------------------------------------------------------------
        function out_string = makeNumberedNames(name, xtimes)
            out_string = sprintf([name '%05d,'], 0 : xtimes-1);
            out_string(end) = [];  % delete last ","
        end
        
        %------------------------------------------------------------------
        function out_string = writeXtimes(str, xtimes)
            [cell_of_strings{1:xtimes, 1}] = deal(str);
            out_string = RavenProject.cat_cell_of_strings(cell_of_strings);
        end
        
        %------------------------------------------------------------------
        function out_string = writeXtimes_num(num, xtimes)
            str = num2str(num);
            out_string = RavenProject.writeXtimes(str, xtimes);
        end
        
    end % static methods
    
end % classdef
%--------------------------------------------------------------------------

