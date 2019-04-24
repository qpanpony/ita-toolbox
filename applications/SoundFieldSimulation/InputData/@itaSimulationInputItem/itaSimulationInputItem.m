classdef (Abstract) itaSimulationInputItem
    %itaSimulationInputItem An abstract item that is used to represent
    %input data for sound field simulations (wave-based and GA-based)
    %   
    %   See also itaMaterial, itaSource, itaReceiver
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaSimulationInputItem">doc itaSimulationInputItem</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    %% Abstract - Overload these in derived class
    methods(Abstract)
        bool = HasGaData(this);   %Returns true if all data which is used for Geometrical Acoustics (GA) is available
        bool = HasWaveData(this); %Returns true if all data which is used for Wave-based Acoustics is available
        obj = CrossfadeWaveAndGaData(this, crossfadeFreq);
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
    
    properties(Access = protected, Constant = true)
        gaThirdOctavefreqs = [20, 25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000]';
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
            assert( ischar(strName) && isrow(strName), 'name must be a char row vector')
            this.mName = strName;
        end
        function out = get.name(this)
            out = this.mName;
        end
    end
    
    %% Booleans - also work on multi instances
    methods        
        function bool = HasName(this)
            bool = arrayfun(@(x) ~isempty(x.name), this);
        end
        
        function bool = HasUniqueNames(this)
            %Returns true if the names of this matrix of
            %itasimulationInputItems are unique.
            bool = numel( unique({this.name}) ) == numel(this);
        end
        
        function bool = SharesNameWith(this, otherInputItems)
            %Compares this matrix of itaSimulationInputItem with another
            %matrix and returns true if they share atleast one name.
            assert(isa(otherInputItems, 'itaSimulationInputItem'), 'Input must be of type itaSimulationInputItem.')
            bool = any( ismember({this.name}, {otherInputItems.name}) );
        end
    end
    
    %% Check Data
    methods(Static = true, Access = protected, Hidden = true)
        function checkDataTypeForFreqData(dataObj)
            %Throws an error if the given object does not match the allowed
            %data types for acoustic properties
            assert(isa(dataObj, 'itaSuper') && isscalar(dataObj), 'Can only assign a single object of type itaSuper');
        end
        
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

