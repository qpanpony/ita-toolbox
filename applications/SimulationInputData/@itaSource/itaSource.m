classdef itaSource < itaSimulationDbItem
    %itaSource Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private, Hidden = true)
        mPressureTf;    %itaSuper
        mVelocityTf;    %itaSuper
        mDirectivity;   %itaSuper
        mPosition;      %itaCoordinates
        mOrientation;   %itaOrientation
    end
    
    properties(Dependent = true)
        pressureTf;
        velocityTf;
        directivity;
        position;
        orientation;
        velocityType;
    end
    
    %% Constructor
    methods
        function obj = itaSource(varargin)
            if nargin == 0
                return;
            end
            
            if nargin == 1
                copyObj = varargin{1};
                if ~isa(copyObj, 'itaSource')
                    error('Input for copy constructor must be an object of same class.')
                end
                
                obj.mPressureTf = copyObj.mPressureTf;
                obj.mVelocityTf = copyObj.mVelocityTf;
                obj.mDirectivity = copyObj.mDirectivity;
                obj.mPosition = copyObj.mPosition;
                obj.mOrientation = copyObj.mOrientation;
            end
        end
    end
        
    %% Set functions
    methods
        function this = set.pressureTf(this, pressure)
            this.checkDataTypeForFreqData(pressure)
            this.mPressureTf = pressure;
        end
        function this = set.velocityTf(this, velocity)
            this.checkDataTypeForFreqData(velocity)
            this.mVelocityTf = velocity;
        end
        function this = set.directivity(this, directivity)
            this.checkDataTypeForFreqData(directivity)
            this.mDirectivity = directivity;
        end
        
        function this = set.position(this, coord)
            if ~isa(coord, 'itaCoordinates')
                error('Input must be of type itaCoordinates');
            end
            this.mPosition = coord;
        end
        function this = set.orientation(this, orientation)
            if ~isa(orientation, 'itaOrientation')
                error('Input must be of type itaOrientation');
            end
            this.mPosition = orientation;
        end
    end
    
    %% Get functions
    methods
        function out = get.pressureTf(this)            
            out = this.mPressureTf;
        end
        function out = get.velocityTf(this)
            out = this.mVelocityTf;
        end
        function out = get.directivity(this)
            out = this.mDirectivity;
        end
        function out = get.position(this)
            out = this.mPosition;
        end
        function out = get.orientation(this)
            out = this.mOrientation;
        end
        
        function out = get.velocityType(this)
            out = [];
            if this.HasVelocityTf
                out = char(VelocityType.PointSource);
            end
        end
    end

    %% Booleans
    methods
        function bool = HasPressureTf(this)
            bool = ~isempty(this.mPressureTf);
        end
        function bool = HasVelocityTf(this)
            bool = ~isempty(this.mVelocityTf);
        end
        function bool = HasDirectivity(this)
            bool = ~isempty(this.mDirectivity);
        end
        function bool = HasSpatialInformation(this)
            bool = ~isempty(this.mPosition) && ~isempty(this.mOrientation);
        end
        
        function bool = HasGaData(this)
            %Returns true if all data which is used for Geometrical
            %Acoustics (GA) is available
            bool = this.HasDirectivity && this.HasPressureTf;
        end
        function bool = HasWaveData(this)
            %Returns true if all data which is used for Wave-based
            %Acoustics is available
            bool = this.HasVelocityTf;
        end
        
        function bool = isempty(this)
            %Returns true if none of the frequency dependent data is set
            bool =  isempty(this.mPressureTf) &&...
                    isempty(this.mVelocityTf) &&...
                    isempty(this.mDirectivity);
        end
    end
    
    %% Public functions
    
    methods
        function obj = CrossfadeWaveAndGaData(this, crossfadeFreq)
            %Cross-fades the wave-based material properties with the
            %geometrical ones at a given frequency. Data is returned in as
            %a new object of this class.
            %
            %Still needs implementation...
            
            if ~this.HasGaData || ~this.HasWaveData
                error('Wave-based data and/or data for Geometrical Acoustics is not set.')
            end            
            
            this.checkInputForValidFrequency(crossfadeFreq);
            
            obj = AcousticMaterial(this);
            
            
            %Do crossfade here
            %this.mImpedance & this.mAbsorption
            %What is with scattering?
        end
    end
    
    %% Static
    
    methods(Static = true, Hidden = true)
        function out = DataTypeForFreqData()
            %Returns the allowed data type for frequency data as string
            out = 'itaSuper';
        end
    end
    
end

