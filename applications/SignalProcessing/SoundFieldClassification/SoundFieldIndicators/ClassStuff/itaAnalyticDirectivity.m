classdef itaAnalyticDirectivity < itaDirectivity

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    properties
        mFunctionHandle = @ita_analytic_directivity_freefield;
    end
    
    properties(Dependent = true, Hidden = false)
        %nChannels;
        %directions
        functionHandle
    end
    
    methods
        function this = itaAnalyticDirectivity(varargin)
            this = this@itaDirectivity(varargin{:});
        end
        
        
        
        function result = getNearestFreq(this,searchDirection)
            result = this.functionHandle(this,searchDirection);
            result = result';
        end
        
        function result = getNearestTime(this,searchDirection)
            result = this.functionHandle(this,searchDirection);
            result = result.';
        end
        
        function result = getNearest(this,searchDirection)
            result = this.functionHandle(this,searchDirection);
        end
        
        
        function result = getNearestFreqData(this,searchDirection)
            result = getNearestFreq(this,searchDirection);
            result = result.freqData;
        end
        
        function result = getNearestTimeData(this,searchDirection)
            result = getNearestTime(this,searchDirection);
            result = result.timeData;
        end
        
        function this = set.functionHandle(this,value)
            this.mFunctionHandle = value;
        end
        
        function value = get.functionHandle(this)
            value = this.mFunctionHandle;
        end
        
        function result = split(this, index)
            
            result = this;
            
            % only use the reduced data 
            result.(result.domain) = this.(result.domain)(:,:,index);
            %result.dimensions = numel(index);
            
            % and select the appropriate Channel struct(s)
            result.channelNames = this.channelNames(index);
            result.channelUnits = this.channelUnits(index);
            result.channelCoordinates = this.channelCoordinates(index);
            result.channelOrientation = this.channelOrientation(index);
            result.channelSensors = this.channelSensors(index);
            result.channelUserData = this.channelUserData(index);
        end
        
      function result = sample(this, grid)
            if nargin == 1 || isempty(grid)
                grid = this.directions;
            end
           
            result = itaDirectivity;
            result.domain = this.domain;
            resultfreq = nan(this.nBins,grid.nPoints,this.nChannels) + 1j .* nan(this.nBins,grid.nPoints,this.nChannels);
            wb = itaWaitbar(grid.nPoints);
            nBins = this.nBins;
            nChannels = this.nChannels;
            for idx = 1:grid.nPoints
                wb.inc;
                resultfreq(1:nBins, idx,1:nChannels) = this.getNearestFreq(grid.n(idx)).freq;
            end
            result.freq = resultfreq;
             wb.close;
            result.directions = grid;
            
            result.channelNames = this.channelNames;
            result.channelUnits = this.channelUnits;
            result.channelCoordinates = this.channelCoordinates;
            result.channelOrientation = this.channelOrientation;
            result.channelSensors = this.channelSensors;
            result.channelUserData = this.channelUserData;
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaSuper(this);
            
            % Copy all properties that were defined to be saved
            propertylist = this.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaAnalyticDirectivity(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 3071 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'functionHandle'};
        end
    end
    

end
