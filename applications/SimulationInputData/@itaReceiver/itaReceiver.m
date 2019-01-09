classdef itaReceiver < itaSpatialSimulationInputItem
    %itaReceiver Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        %mFemGroup;
        mType = ReceiverType.Monaural;
    end
    properties(Dependent = true)
        %TODO:
        %Not sure if femGroup is really needed or if we can use the
        %position directly (which would be much better)
        %femGroup;    %Corresponding group in FE mesh
        type;        %Receiver type used for FE simulations [ReceiverType]
    end
    
    %% Set
    methods
        function this = set.type(this, type)
            assert(isa(type, 'ReceiverType') && isscalar(type), 'Can only assign a single object of type ReceiverType');
            
            this.mType = type;
        end
    end
    
    %% Get
    methods
%         function out = get.femGroup(this)
%             out = this.mFemGroup;
%         end
        function out = get.type(this)
            out = this.mType;
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
            bool = this.HasSpatialInformation();
            %If we use a femGroup, we could use this later on
            %bool = ~isempty(this.mFemGroup);
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