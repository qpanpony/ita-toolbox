classdef itaMaterial < itaSimulationInputItem
    %itaMaterial represents a material and its acoustic properties which are
    %used for GA-based and wave-based simulations
    %   Properties:
    %   Impedance, absorption, scattering
    %   
    %   See also itaSimulationInputItem, ImpedanceType, ScatteringType
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaMaterial">doc itaMaterial</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private, Hidden = true)
        mImpedanceType = ImpedanceType.UserDefined;
        mAbsorptionType = ImpedanceType.UserDefined;
        mScatteringType = ScatteringType.UserDefined;
        
        mImpedance;
        mAbsorption;
        mScattering;
    end
    
    properties
        rho0Air = [];    %The density of air which occured while measuring the data
        cAir = [];       %The speed of sound in air which was present while measuring the data
    end
    
    properties(Dependent = true)
        impedanceType;          %ImpedanceType
        absorptionType;         %ImpedanceType
        scatteringType;         %ScatteringType
        
        impedance;              %Impedance Z - itaSuper
        absorption;             %Absorption coefficient alpha - itaSuper
        scattering;             %Scattering coefficient s - itaSuper
    end
    properties(Dependent = true, SetAccess = private)
        absorptionFromImpedance;%Same as absorption but computed from impedance (get only)
    end
    
    %% Constructor
    methods
        function obj = itaMaterial(varargin)
            if nargin == 0
                return;
            end
            
            if nargin == 1
                copyObj = varargin{1};
                if ~isa(copyObj, 'itaMaterial')
                    error('Input for copy constructor must be an object of same class.')
                end
                
                obj.mImpedance = copyObj.impedance;
                obj.mAbsorption = copyObj.absorption;
                obj.mScattering = copyObj.scattering;
                obj.rho0Air = copyObj.rho0Air;
                obj.cAir = copyObj.cAir;
            end
        end
    end
    
    methods(Static = true)
        function obj = SoundHard()
            obj = itaMaterial;
            obj.mImpedanceType = ImpedanceType.SoundHard;
            obj.mAbsorptionType = ImpedanceType.SoundHard;
        end
        function obj = SoundHardNoScattering()
            obj = itaMaterial;
            obj.mImpedanceType = ImpedanceType.SoundHard;
            obj.mAbsorptionType = ImpedanceType.SoundHard;
            obj.mScatteringType = ScatteringType.Zero;
        end
    end
    
    %% Set functions
    methods
        function this = set.impedanceType(this, impedanceType)
            assert(isa(impedanceType, 'ImpedanceType'), 'The impedanceType property must be an object of the class ImpedanceType.')
            this.mImpedanceType = impedanceType;
        end
        function this = set.absorptionType(this, absorptionType)
            assert(isa(absorptionType, 'ImpedanceType'), 'The absorptionType property must be an object of the class ImpedanceType.')
            this.mAbsorptionType = absorptionType;
        end
        function this = set.scatteringType(this, scatterType)
            assert(isa(scatterType, 'ScatteringType'), 'The scatteringType property must be an object of the class ScatteringType.')
            this.mScatteringType = scatterType;
        end
        
        function this = set.impedance(this, impedance)
            if isnumeric(impedance) && isempty(impedance)
                this.mImpedance = [];
                return;
            end
            
            this.checkDataTypeForFreqData(impedance);
            this.mImpedance = impedance;
        end
        
        function this = set.absorption(this, alpha)
            if isnumeric(alpha) && isempty(alpha)
                this.mAbsorption = [];
                return;
            end
            
            this.checkDataTypeForFreqData(alpha);
            this.mAbsorption = alpha;
        end
        function this = set.scattering(this, scattering)
            if isnumeric(scattering) && isempty(scattering)
                this.mScattering = [];
            elseif isnumeric(scattering) && isscalar(scattering)
                assert(scattering >= 0 && scattering <= 1, 'When applying a constant scattering, the value must be between 0 and 1.')
                freqData = scattering*ones( size(this.gaThirdOctavefreqs) );
                this.mScattering = itaResult(freqData, this.gaThirdOctavefreqs, 'freq');
            else
                this.checkDataTypeForFreqData(scattering)
                this.mScattering = scattering;
            end
        end
        
        function this = set.rho0Air(this, rho0)
            if isnumeric(rho0) && isempty(rho0)
                this.rho0Air = [];
                return;
            end
            
            if ~isnumeric(rho0) || ~isscalar(rho0) || rho0 < 0
                error('Density must be a positive numeric scalar')
            end
            this.rho0Air = rho0;
        end
        function this = set.cAir(this, c)
            if isnumeric(c) && isempty(c)
                this.cAir = [];
                return;
            end
            assert(isnumeric(c) && isscalar(c) && c > 0, 'Speed of sound must be a positive numeric scalar')
            this.cAir = c;
        end
    end
    
    %% Get functions
    methods
        function impedanceType = get.impedanceType(this)
            impedanceType = this.mImpedanceType;
        end
        function absorptionType = get.absorptionType(this)
            absorptionType = this.mAbsorptionType;
        end
        function scatteringType = get.scatteringType(this)
            scatteringType = this.mScatteringType;
        end
        
        function alpha = get.absorption(this)
            switch this.mAbsorptionType
                case ImpedanceType.SoundHard
                    freqData = zeros( size(this.gaThirdOctavefreqs) );
                    alpha = itaResult(freqData, this.gaThirdOctavefreqs, 'freq');
                otherwise
                    alpha = this.mAbsorption;
            end
        end
        
        function alpha = get.absorptionFromImpedance(this)
            %Tries to convert the impedance to an absorption. Throws an
            %error if impedance is not defined or impedance of air is not
            %specified.
            if ~this.HasImpedance
                error('No impedance data defined yet')
            end
            if ~this.mediumImpedanceDefined
                error('Cannot convert without knowledge density and speed of sound of air. Set rho0Air and cAir first.');
            end
            
            alpha = this.convertImpedanceToAbsorption();
        end
        
        function scattering = get.scattering(this)
            switch this.mScatteringType
                case  ScatteringType.Zero
                    freqData = zeros( size(this.gaThirdOctavefreqs) );
                    scattering = itaResult(freqData, this.gaThirdOctavefreqs, 'freq');
                otherwise
                    scattering = this.mScattering;
            end
        end
        
        function Z = get.impedance(this)
            switch this.mImpedanceType
                case ImpedanceType.SoundHard
                    Z = inf;
                otherwise
                    Z = this.mImpedance;
            end
        end
    end
    
    %% Booleans
    
    methods
        function bool = HasImpedanceType(this, impedanceType)
            assert(isa(impedanceType, 'ImpedanceType'), 'Input must be an ImpedanceType')
            bool = arrayfun(@(x) x.mImpedanceType == impedanceType, this);
        end
        function bool = HasAbsorptionType(this, impedanceType)
            assert(isa(impedanceType, 'ImpedanceType'), 'Input must be an ImpedanceType')
            bool = arrayfun(@(x) x.mAbsorptionType == impedanceType, this);
        end
        function bool = HasScatteringType(this, scatterType)
            assert(isa(scatterType, 'ScatteringType'), 'Input must be a ScatteringType')
            bool = arrayfun(@(x) x.mScatteringType == scatterType, this);
        end
        
        function bool = HasAbsorption(this)
            bool = arrayfun(@(x) ~isempty(x.mAbsorption), this) | this.absorptionDefinedByType();
        end
        function bool = HasScattering(this)
            bool = arrayfun(@(x) ~isempty(x.mScattering), this) | this.scatteringDefinedByType();
        end
        function bool = HasImpedance(this)
            bool = arrayfun(@(x) ~isempty(x.mImpedance), this) | this.impedanceDefinedByType();
        end
        
        function bool = HasGaData(this)
            %Returns true if all data which is used for Geometrical
            %Acoustics (GA) is available
            bool = this.HasAbsorption() & this.HasScattering();
        end
        function bool = HasWaveData(this)
            %Returns true if all data which is used for Wave-based
            %Acoustics is available
            bool = this.HasImpedance();
        end
    end
    methods(Access = private)
        function bool = impedanceDefinedByType(this)
            bool = ~this.HasImpedanceType(ImpedanceType.UserDefined);
        end
        function bool = absorptionDefinedByType(this)
            bool = ~this.HasAbsorptionType(ImpedanceType.UserDefined);
        end
        function bool = scatteringDefinedByType(this)
            bool = ~this.HasScatteringType(ScatteringType.UserDefined);
        end
    end
    
    methods(Hidden = true)
        function bool = HasNonInfImpedance(this)
            bool = this.HasImpedance & ~this.HasImpedanceType(ImpedanceType.SoundHard);
        end
    end
    
    methods(Access = private)
        function bool = mediumImpedanceDefined(this)
            %Returns true if all parameters for the calculation of the
            %medium's impedance (usually air) are defined
            bool = ~isempty(this.rho0Air) && ~isempty(this.cAir);
        end
    end
    
    %% Public functions
    methods(Hidden = true)
        function obj = CrossfadeWaveAndGaData(this, crossfadeFreq)
            %Cross-fades the wave-based material properties with the
            %geometrical ones at a given frequency. Data is returned in as
            %a new object of this class.
            %
            %Still needs implementation...
            
            if ~this.HasGaData || ~this.HasWaveData
                error('Wave-based data and/or data for Geometrical Acoustics is not set.')
            end
            
            if ~this.mediumImpedanceDefined
                error('')
            end
            
            this.checkInputForValidFrequency(crossfadeFreq);
            
            obj = itaMaterial(this);
            
            
            %Do crossfade here
            %this.mImpedance & this.mAbsorption
            %What is with scattering?
        end
    end
    
    %% Conversions
    methods(Access = private)
        function alpha = convertImpedanceToAbsorption(this)
            %Converts the impedance of this object to an absorption
            %coefficient
            
            alpha = [];
            
            if ~this.HasImpedance()
                warning('No impedance data available, returning empty data')
                return
            elseif ~this.mediumImpedanceDefined()
                warning('No medium impedance (Z0) defined, returning empty data')
                return
            end
            
            Z0 = this.rho0Air * this.cAir;
            Z = this.impedance.freqData;
            abs_R = abs( (Z-Z0)./(Z+Z0) );
            
            alphaFreqData = 1 - abs_R.^2;
            
            alpha = itaResult(alphaFreqData, this.impedance.freqVector, 'freq');
        end
        
        function Z = convertAbsorptionToImpedance(this, h, T, p0)
            R = sqrt(1 - this.absorption.freqData);
            Z0 = ita_constants('z_0', 'medium', 'air', 'T', T, 'p', p0, 'phi', h/100);
            Z = Z0.value * (1+R)./(1-R);
            
            Z = itaResult(Z, this.absorption.freqVector, 'freq');
        end
    end
    
    %% Plot interface
    methods
        function varargout = plotImpedance(this, varargin)
            matVis = itaMaterialVisualizer(this);
            [fgh, ax] = matVis.plotImpedance(varargin{:});
            if nargout
                varargout{1} = fgh;
                varargout{2} = ax;
            end
        end
        function varargout = plotAbsorption(this, varargin)
            matVis = itaMaterialVisualizer(this);
            [fgh, ax] = matVis.plotAbsorption(varargin{:});
            if nargout
                varargout{1} = fgh;
                varargout{2} = ax;
            end
        end
        function varargout = plotScattering(this, varargin)
            matVis = itaMaterialVisualizer(this);
            [fgh, ax] = matVis.plotScattering(varargin{:});
            if nargout
                varargout{1} = fgh;
                varargout{2} = ax;
            end
        end
    end
    
end

