classdef (Abstract) itaSimulationDbItem
    %itaSimulationDbItem An abstract item that is used in a database for
    %acoustic simulations (wave-based and GA-based)
    
    
    %% Abstract - Overload these in derived class
    methods(Abstract)
        bool = HasGaData(this);   %Returns true if all data which is used for Geometrical Acoustics (GA) is available
        bool = HasWaveData(this); %Returns true if all data which is used for Wave-based Acoustics is available
        bool = isempty(this);     %Returns true if none of the frequency dependent data is set
        obj = CrossfadeWaveAndGaData(this, crossfadeFreq);
    end    
    
    methods(Abstract = true, Static = true, Hidden = true)
        out = DataTypeForFreqData();    %Define the valid data type for frequency data in derived class
    end
    
    %% Properties
    properties(Hidden = true)
        checkUnits = false;     %If this is set to true, units in itaSuper are tested when setting frequency dependent properties
    end  
    properties(Dependent = true)
        name;                   %String with a user given name for the item
    end
        
    properties(Access = protected)
        mName = '';
    end   
    
    %% Set / Get
    
    methods
        function this = set.checkUnits(this, bool)
            if ~islogical(bool) || ~isscalar(bool)
                error('Input must be a single boolean')
            end
            this.checkUnits = bool;
        end
        
        function this = set.name(this, strName)
            if ~ischar(strName) || ~isrow(strName)
                error('')
            end
            this.mName = strName;
        end
        function out = get.name(this)
            out = this.mName;
        end
    end
    
    %% Bool
    methods        
        function bool = HasName(this)
            bool = ~isempty(this.name);
        end
    end
    
    %% Protected    
    
    methods(Access = protected, Hidden = true)
        function checkDataTypeForFreqData(this, dataObj)
            %Throws an error if the given object does not match the allowed
            %data types for acoustic properties
            if ~isa(dataObj, this.DataTypeForFreqData())
               error(['Can only assign object of type ' this.DataTypeForFreqData()]) ;
            end
            
            if ~isscalar(dataObj)
                error('Input must be a single object')
            end
        end
    end
    
    methods(Static = true, Access = protected, Hidden = true)
        function checkInputForValidFrequency(freq, fMin, fMax)
            %Throws and error if the given input is not a frequency in a
            %specified range. If using a single input the default frequency
            %range of 20Hz to 20kHz is used.
            
            if nargin == 1
                fMin = 20;
                fMax = 20000;
            end
            
            if ~this.isSingleFrequency(freq,fMin,fMax)
                error(['Input must be a single frequency between ' num2str(fMin) ' and ' num2str(fMax) 'Hz'])
            end
        end
    end
    
    %% Private
    methods(Static = true, Access = private, Hidden = true)
        function bool = isSingleFrequency(freq, fMin, fMax)
            %Returns true if the given input is a frequency in a specified
            %range. If using a single input the default frequency range of
            %20Hz to 20kHz is used.
            
            if nargin == 1
                fMin = 20;
                fMax = 20000;
            end
            
            bool = isnumeric(freq) && isscalar(freq) && freq >= fMin && freq <= fMax;
        end
    end
    
end

