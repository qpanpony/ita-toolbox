classdef itaSource < itaSpatialSimulationInputItem
    %itaSource represents a source and its acoustic properties which are
    %used for GA-based and wave-based simulations
    %   Properties:
    %   Wave TF, Pressure TF, directivity, position, orientation
    %   
    %   The wave TF can either represent a point source, a piston or a
    %   distribution over a surface and is specified in one itaSource's
    %   subclasses.
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = protected, Hidden = true)
        mWaveTf;                                    %itaSuper
        mPressureTf;                                %itaSuper
        mDirectivity;                               %itaSuper
        mDirectivityFile;                           %Char vector
        mType = SourceType.PointSource;             %SourceType
        mPistonRadius;                              %Double scalar
    end
    
    properties(Dependent = true, SetAccess = private)
        waveTf;             %Transfer function for wave-based simulations - read-only (data can be set in subclass)
        soundPower;         %Calculates the sound power from the volume flow TF for a point source
        velocityCoordinates;%Returns the coordinates of the velocity TF for a surface distribution source
    end
    properties(Dependent = true)
        type;     %Iindicates what the wave TF represents - PointSource, Piston, SurfaceDistribution (see SourceType)
        
        volumeFlowTf; %volume flow transfer function of the point source used for wave-based simulations
        velocityTf;
        
        pressureTf;     %pressure transfer function - itaSuper
%         directivity;    %The directivity loaded from the .daff file - itaSuper
        directivityFile;%Name of directivity .daff file
        
        pistonRadius;   %Radius used for sources of type Piston
    end
    
    %% Source Type
    methods
        function this = set.type(this, type)
            assert(isa(type, 'SourceType') && isscalar(type), 'Can only assign a single object of type SourceType')
            if this.mType == type; return; end
            
            this.mType = type;
            this.mWaveTf = [];
        end
        function out = get.type(this)
            out = char(this.mType);
        end
    end
    
    %% GA Properties
    %------Set-------------------------------------------------------------
    methods
        function this = set.pressureTf(this, pressure)
            if isnumeric(pressure) && isempty(pressure)
                this.mPressureTf = [];
                return;
            end            
            this.checkDataTypeForFreqData(pressure)
            this.mPressureTf = pressure;
        end
        function this = set.directivityFile(this, filename)
            if ~ischar(filename) || ~isrow(filename) || ~contains(filename, '.daff')
                error('directivityFile must be a filename pointing to a .daff file')
            end
            if ~exist(filename, 'file')
                error('File does not exist')
            end
            
            this.mDirectivityFile = filename;
            this.mDirectivity = [];
        end
    end
    %------Get-------------------------------------------------------------
    methods
        function out = get.pressureTf(this)            
            out = this.mPressureTf;
        end
        function out = get.directivityFile(this)
            out = this.mDirectivityFile;
        end
        
        function out = directivity(this)
            %Loads the directivity from the specified file and returns it.
            %This is just a placeholder and not yet implemented...
            
            %TODO: Remove this once implemented
            error('Reading daff files is not yet incoorporated');
            
            if isempty(this.mDirectivity)
                if ~isempty(this.mDirectivityFile) || ~exist(this.mDirectivityFile, 'file')
                    warning('Daff file not specified or not existing')
                    out = [];
                    return;
                end
                %TODO: Read daff file
                %this.mDirectivity = ...
            end
                
            out = this.mDirectivity;
        end
    end
    %% Wave Properties
    %------General---------------------------------------------------------
    methods
        function out = get.waveTf(this)
            out = this.mWaveTf;
        end
    end
    %------Point Source----------------------------------------------------
    methods
        function this = set.volumeFlowTf(this, flow)
            assert(this.mType == SourceType.PointSource, ...
                'Volume flow transfer function can only be set for a point source')
            if isnumeric(flow) && isempty(flow)
                this.mWaveTf = [];
                return;
            end
            this.checkDataTypeForFreqData(flow)
            this.mWaveTf = flow;
        end
        
        function out = get.volumeFlowTf(this)
            out = [];
            if this.mType == SourceType.PointSource
                out = this.mWaveTf;
            end
        end
        function out = get.soundPower(this)
            if isempty(this.volumeFlowTf)
                out = [];
                return;
            end
            out = this.volumeFlowTf;
            rho0 = ita_constants('rho_0');
            c = ita_constants('c');
            out.freqData = out.freqData.^2 * out.freqVector.^2 * pi * rho0 /(2*c) ;
        end
    end
        
    %------Surface Sources-------------------------------------------------
    methods
        function this = set.velocityTf(this, velocity)
            assert(this.mType == SourceType.Piston || this.mType == SourceType.SurfaceDistribution, ...
                'Velocity transfer function can only be set for Piston source and a velocity surface distribution')
            
            if isnumeric(velocity) && isempty(velocity)
                this.mWaveTf = [];
                return;
            end
            
            this.checkDataTypeForFreqData(velocity)
            if this.mType == SourceType.Piston
                assert(velocity.nChannels == 1, 'For a piston source, velocity transfer function must have exactly one channel')
            else
                assert(this.itaSuperHasCoordinates(velocity), 'For a surface distribution source, velocity transfer function must have coordinates specified for each channel')
            end
            
            this.mWaveTf = velocity;
        end
        
        function out = get.velocityTf(this)
            out = [];
            if this.mType == SourceType.Piston || this.mType == SourceType.SurfaceDistribution
                out = this.mWaveTf;
            end
        end
    end
    
    %------Surface Sources-------------------------------------------------
    methods
        function this = set.pistonRadius(this, radius)
            assert(( isscalar(radius) || isempty(radius) ) && isnumeric(radius) && isreal(radius),...
                'Piston radius must be a real-valued numeric scalar')
            this.mPistonRadius = radius;
        end
        function out = get.pistonRadius(this)
            out = this.mPistonRadius;
        end
    end
    
    %------Velocity Surface Distribution-----------------------------------
    methods
        function out = get.velocityCoordinates(this)
            out = [];
            if this.HasVelocityTf && this.mType == SourceType.SurfaceDistribution
                out = this.velocityTf.channelCoordinates;
            end
        end
    end


    %% Booleans
    %------General---------------------------------------------------------
    methods
        function bool = HasPistonRadius(this)
            bool = ~isempty(this.mPistonRadius);
        end
        function bool = HasSpatialInformation(this)
            bool = HasSpatialInformation@itaSpatialSimulationInputItem(this);
            if this.mType == SourceType.Piston
                bool = bool & this.HasPistonRadius();
            end
        end
        
        function bool = HasPressureTf(this)
            bool = ~isempty(this.mPressureTf);
        end
        function bool = HasWaveTf(this)
            bool = ~isempty(this.mWaveTf);
        end
        function bool = HasDirectivity(this)
            bool = ~isempty(this.mDirectivityFile);
        end
        
        function bool = HasGaData(this)
            %Returns true if all data which is used for Geometrical
            %Acoustics (GA) is available
            bool = this.HasDirectivity() & this.HasPressureTf() & this.HasSpatialInformation();
        end
        function bool = HasWaveData(this)
            %Returns true if all data which is used for Wave-based
            %Acoustics is available
            bool = this.HasWaveTf() & this.HasSpatialInformation();
        end
        
        function bool = isempty(this)
            %Returns true if none of the frequency dependent data is set
            bool =  isempty(this.mPressureTf) &&...
                    isempty(this.mWaveTf) &&...
                    isempty(this.mDirectivityFile);
        end
    end
    
    %------Source type specific--------------------------------------------
    methods
        function bool = HasVolumeFlow(this)
            bool = ~isempty(this.volumeFlowTf);
        end
        function bool = HasVelocityTf(this)
            bool = ~isempty(this.velocityTf);
        end
        function bool = HasVelocityCoordinates(this)
            %Checks whether the velocity transfer function has specified
            %channel coordinates for all channels
            bool = this.HasVelocityTf() & this.itaSuperHasCoordinates( this.velocity );
        end
    end
    methods(Access = private, Static = true)
        function bool = itaSuperHasCoordinates(obj)
            bool = ~any(any(isnan( obj.channelCoordinates.cart )));
        end
    end
    
    %% Public functions
    methods
        function obj = CrossfadeWaveAndGaData(this, crossfadeFreq)
            %Cross-fades the wave-based source properties with the
            %geometrical ones at a given frequency. Data is returned in as
            %a new object of this class.
            %
            %Still needs implementation...
            
            error('This function is not yet implemented...')
            
            if ~this.HasGaData || ~this.HasWaveData
                error('Wave-based data and/or data for Geometrical Acoustics is not set.')
            end            
            
            this.checkInputForValidFrequency(crossfadeFreq);
            
            obj = this;
            
            %TODO: Crossfade here / Probably needs to be moved to
            %subclasses
        end
    end
end

