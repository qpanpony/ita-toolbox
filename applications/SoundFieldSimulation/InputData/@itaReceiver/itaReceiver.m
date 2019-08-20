classdef itaReceiver < itaSpatialSimulationInputItem
    %itaReceiver represents a receiver and its acoustic properties which are
    %used for GA-based and wave-based simulations
    %   Properties:
    %   Receiver-type, position, orientation, left and right ear position
    %   
    %   See also itaSpatialSimulationInputItem, ReceiverType
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaReceiver">doc itaReceiver</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        %mFemGroup;
        mType = ReceiverType.Monaural;
        
        mGeometryFilename = '';
        mRelativeLeftEarMicPosition;
        mRelativeRightEarMicPosition;
    end
    properties(Dependent = true)
        type;                       %Receiver type used for FE simulations [ReceiverType]
        
        relativeLeftEarMicPosition; %Relative position of left ear microphone to origin of model [itaCoordinates]
        relativeRightEarMicPosition;%Relative position of right ear microphone to origin of model [itaCoordinates]
        geometryFilename;           %Name of file with geometry used for a binaural receiver
    end
    properties(Dependent = true, SetAccess = private)
        leftEarMicPosition;         %Global position of left ear microphone [itaCoordinates]
        rightEarMicPosition;        %Global position of right ear microphone [itaCoordinates]
    end
    
    %% Set
    methods
        function this = set.type(this, type)
            assert(isa(type, 'ReceiverType') && isscalar(type), 'Can only assign a single object of type ReceiverType');
            if type == ReceiverType.ITADummyHead
                this = this.readItaDummyHeadGeometryFile();
            end
            this.mType = type;
        end
        
        function this = set.relativeLeftEarMicPosition(this, pos)
            assert(this.mType == ReceiverType.UserDefined, 'relativeLeftEarMicPosition can only be set for UserDefined receiver type')
            assert(isa(pos, 'itaCoordinates') && pos.nPoints == 1, 'relativeLeftEarMicPosition must be an itaCoordinates with one point')
            this.mRelativeLeftEarMicPosition = pos;
        end
        function this = set.relativeRightEarMicPosition(this, pos)
            assert(this.mType == ReceiverType.UserDefined, 'relativeRightEarMicPosition can only be set for UserDefined receiver type')
            assert(isa(pos, 'itaCoordinates') && pos.nPoints == 1, 'relativeRightEarMicPosition must be an itaCoordinates with one point')
            this.mRelativeLeftEarMicPosition = pos;
        end
        function this = set.geometryFilename(this, strIn)
            assert(this.mType == ReceiverType.UserDefined, 'geometryFilename can only be set for UserDefined receiver type')
            assert(ischar(strIn) && isrow(strIn), 'geometryFilename must be a char row vector')
            this.mGeometryFilename = strIn;
        end
    end
    
    %% Get
    methods
        function out = get.type(this)
            out = this.mType;
        end
        function out = get.leftEarMicPosition(this)
            out = this.convertLocalToGlobalCoordinates(this.relativeLeftEarMicPosition);
        end
        function out = get.rightEarMicPosition(this)
            out = this.convertLocalToGlobalCoordinates(this.relativeRightEarMicPosition);
        end
        function out = get.geometryFilename(this)
            switch(this.mType)
                case ReceiverType.Monaural
                    out = '';
                case ReceiverType.ITADummyHead
                    out = this.mGeometryFilename;
                case ReceiverType.UserDefined
                    out = this.mGeometryFilename;
            end
        end
        
        function out = get.relativeLeftEarMicPosition(this)
            switch(this.mType)
                case ReceiverType.Monaural
                    out = itaCoordinates([0 0 0]);
                case ReceiverType.ITADummyHead
                    %out = itaCoordinates([0 0.07022 0]);
                    out = itaCoordinates([0 0.071 0]);
                case ReceiverType.UserDefined
                    out = this.mRelativeLeftEarMicPosition;
            end
        end
        function out = get.relativeRightEarMicPosition(this)
            switch(this.mType)
                case ReceiverType.Monaural
                    out = itaCoordinates([0 0 0]);
                case ReceiverType.ITADummyHead
                    %out =  itaCoordinates([0 -0.07147 0]);
                    out =  itaCoordinates([0 -0.072 0]);
                case ReceiverType.UserDefined
                    out = this.mRelativeLeftEarMicPosition;
            end
        end
    end
    
    %% Coordinate conversion
    methods(Access = private)
        function globalPos = convertLocalToGlobalCoordinates(this, localPos)
            assert(isa(localPos, 'itaCoordinates'), 'Input must be itaCoordinates')
            x = this.orientation.view; x = x/norm(x);
            z = this.orientation.up; z = z/norm(z);
            y = cross(z, x); %y = y/norm(y);
            orientationMatrix = [x; y; z];
            
            posWithGlobalOrientation = itaCoordinates(localPos.cart * orientationMatrix);
            globalPos = posWithGlobalOrientation + this.position;
        end
    end
    
    %% Booleans
    methods
        function bool = HasGaData(this)
            %Returns true if all data which is used for Geometrical
            %Acoustics (GA) is available
            bool = this.HasSpatialInformation();
        end
        function bool = HasWaveData(this)
            %Returns true if all data which is used for Wave-based
            %Acoustics is available
            bool = this.HasSpatialInformation() && ...
                (this.type.IsMonaural() || this.HasBinauralModelData());
        end
        function bool = HasBinauralModelData(this)
            bool = ~(   isempty(this.geometryFilename) ||...
                        isempty(this.relativeLeftEarMicPosition) ||...
                        isempty(this.relativeRightEarMicPosition)...
                     );
        end
    end
    
    %% Public functions    
    methods(Hidden = true)
        function obj = CrossfadeWaveAndGaData(this, crossfadeFreq)
            %Since the receiver has no frequency dependent data yet, no
            %crossfade is necessary
            warning('itaReceiver has no frequency dependent data. So this function does nothing.')
            obj = this;
        end
    end
    
    %% Ini-File
    properties(Constant = true, Access = private)
        iniSectionDummyHead = 'ITADummyHead';
        iniTagDummyHeadGeometryFile = 'GeometryFile';
    end
    
    methods(Static = true, Hidden = true)
        function OpenIniFile()
            %Opens the ini-file of the itaReceiver class in a text editor.
            winopen(itaReceiver.getIniFilname());
        end
    end
    methods(Access = private)
        function obj = readItaDummyHeadGeometryFile(obj)
            dummyHeadGeometryFile = obj.readIniFile();
            if isempty(dummyHeadGeometryFile) || ~exist(dummyHeadGeometryFile, 'file')
                errorHeader = ['[' class(obj) '] - Cannot set type to ITA Dummy Head:\n'];
                [selectedFile, selectedPath] = uigetfile('*.mphbin','No valid geometry file for ITA Dummy Head specified! Please select path to ITA_Kustkopf.mphbin', 'D:\');
                assert(ischar(selectedFile) && ~isempty(selectedFile), sprintf([errorHeader 'No geometry file was specified!']))
                
                dummyHeadGeometryFile = fullfile(selectedPath, selectedFile);
                assert(logical(exist(dummyHeadGeometryFile, 'file')), sprintf([errorHeader 'Specified geometry file does not exist!']))
                
                if ~contains(selectedFile, '.mphbin')
                    warning('The dummy head geometry file should be an .mphbin file. Did you select the correct file?')
                end
                obj.mGeometryFilename = dummyHeadGeometryFile;
                obj.writeIniFile();
            else
                obj.mGeometryFilename = dummyHeadGeometryFile;
            end
        end
        function dummyHeadGeometryFile = readIniFile(obj)
            receiverIni = IniConfig();
            iniFilename = obj.getIniFilname();
            receiverIni.ReadFile(iniFilename);
            dummyHeadGeometryFile = receiverIni.GetValues(obj.iniSectionDummyHead, obj.iniTagDummyHeadGeometryFile, '');
        end
        function writeIniFile(obj)
            iniFilename = obj.getIniFilname();
            receiverIni = IniConfig();
            receiverIni.ReadFile(iniFilename);
            if ~exist(iniFilename, 'file')
                receiverIni.AddSections({obj.iniSectionDummyHead});
                receiverIni.AddKeys(obj.iniSectionDummyHead, {obj.iniTagDummyHeadGeometryFile}, {obj.mGeometryFilename});
            else
                receiverIni.SetValues(obj.iniSectionDummyHead, {obj.iniTagDummyHeadGeometryFile}, {obj.mGeometryFilename});
            end
            receiverIni.WriteFile(iniFilename);
        end
    end
    methods(Access = private, Static = true)
        function iniFilename = getIniFilname()
            itaReceiverPath = fileparts( mfilename('fullpath') );
            iniFilename = fullfile(itaReceiverPath, 'itaReceiver.ini');
        end
    end
end