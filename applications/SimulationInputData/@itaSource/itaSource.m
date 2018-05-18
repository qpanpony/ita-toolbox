classdef itaSource < itaSimulationDbItem
    %itaSource represents a source and its acoustic properties which are
    %used for GA-based and wave-based simulations
    %   Properties:
    %   Pressure TF, velocity TF, directivity, position, orientation
    %   
    %   The velocity TF can either represent a point source, a piston or a
    %   distribution over a surface. In the latter case, the distribution
    %   on the surface must be represented by itaSuper.channelCoordinates.
    
    properties(Access = private, Hidden = true)
        mPressureTf;    %itaSuper
        mVelocityTf;    %itaSuper
        mDirectivity;   %itaSuper
        mPosition;      %itaCoordinates
        mOrientation;   %itaOrientation
    end
    
    properties(Dependent = true)
        pressureTf;     %pressure transfer function - itaSuper
        velocityTf;     %Velocity transfer function - itaSuper
        directivity;    %The directivity - itaSuper
        position;       %Position of the source in 3D space - itaCoordinates
        orientation;    %Orientation of the source in 3D space - itaOrientation
        velocityType;   %What does the velocity represent? - PointSource, Piston, SurfaceDistribution
        velocityDistribution; %Coordinates of the velocity surface distribution - get only
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
            if isnumeric(pressure) && isempty(pressure)
                this.mPressureTf = [];
                return;
            end            
            this.checkDataTypeForFreqData(pressure)
            this.mPressureTf = pressure;
        end
        function this = set.velocityTf(this, velocity)
            if isnumeric(velocity) && isempty(velocity)
                this.mVelocityTf = [];
                return;
            end            
            this.checkDataTypeForFreqData(velocity)            
            %TODO: Check if velocity has coordinates in case of surface
            %distribution            
            this.mVelocityTf = velocity;
        end
        function this = set.directivity(this, directivity)
            if isnumeric(directivity) && isempty(directivity)
                this.mDirectivity = [];
                return;
            end
            this.checkDataTypeForFreqData(directivity)
            this.mDirectivity = directivity;
        end
        
        function this = set.position(this, coord)
            if isnumeric(coord) && isempty(coord)
                this.mPosition = [];
                return;
            end
            
            if ~isa(coord, 'itaCoordinates') || ~isscalar(coord)
                error('Input must be a scalar of type itaCoordinates');
            end
            if coord.nPoints > 1
                error('Input must be a single set or coordinates or empty.')
            end
            this.mPosition = coord;
        end
        function this = set.orientation(this, orientation)
            if isnumeric(orientation) && isempty(orientation)
                this.mOrientation = [];
                return;
            end
            
            if ~isa(orientation, 'itaOrientation') || ~isscalar(orientation)
                error('Input must be a scalar of type itaOrientation');
            end
            if orientation.nPoints == 1 %Better would be > 1. But there is a bug in itaOrientation for empty objects
                error('Input must be a single orientation or empty.')
            end
            this.mOrientation = orientation;
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
        
        function out = get.velocityDistribution(this)
            out = [];
            if this.HasVelocityTf && this.velocityType == VelocityType.SurfaceDistribution
                out = this.mVelocityTf.channelCoordinates;
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
        function bool = HasPosition(this)
            bool = ~isempty(this.mPosition) && this.mPosition.nPoints == 1;
        end
        function bool = HasOrientation(this)
            bool = ~isempty(this.mOrientation) && this.mOrientation.nPoints == 1;
        end
        function bool = HasSpatialInformation(this)
            bool = this.HasPosition && this.HasOrientation;
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

