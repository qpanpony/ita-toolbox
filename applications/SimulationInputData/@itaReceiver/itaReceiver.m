classdef itaReceiver < itaSpatialSimulationInputItem
    %itaReceiver Summary of this class goes here
    %   Detailed explanation goes here
    
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
                case ReceiverType.DummyHead
                    out = 'D:\CAD data\Kunstkopf\ITA_Kunstkopf.mphbin'; %TODO: Read from ini
                case ReceiverType.UserDefined
                    out = this.mGeometryFilename;
            end
        end
        
        function out = get.relativeLeftEarMicPosition(this)
            switch(this.mType)
                case ReceiverType.Monaural
                    out = itaCoordinates([0 0 0]);
                case ReceiverType.DummyHead
                    out = itaCoordinates([0 0.0711 0]); %TODO: Read from ini
                case ReceiverType.UserDefined
                    out = this.mRelativeLeftEarMicPosition;
            end
        end
        function out = get.relativeRightEarMicPosition(this)
            switch(this.mType)
                case ReceiverType.Monaural
                    out = itaCoordinates([0 0 0]);
                case ReceiverType.DummyHead
                    out =  itaCoordinates([0 -0.0712 0]); %TODO: Read from ini
                case ReceiverType.UserDefined
                    out = this.mRelativeLeftEarMicPosition;
            end
        end
    end
    
    %% Coordinate conversion
    methods(Access = private)
        function globalPos = convertLocalToGlobalCoordinates(this, localPos)
            assert(isa(localPos, 'itaCoordinates'), 'Input must be itaCoordinates')
            x = this.orientation.view;
            z = this.orientation.up;
            y = cross(z, x);
            orientationMatrix = [x; y; z]';
            
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
    methods
        function obj = CrossfadeWaveAndGaData(this, crossfadeFreq)
            %Since the receiver has no frequency dependent data yet, no
            %crossfade is necessary
            warning('itaReceiver has no frequency dependent data. So this function does nothing.')
            obj = this;
        end
    end
end