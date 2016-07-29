classdef itaDirectivity < itaAudio

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    properties
        mDirections = itaCoordinates();
    end
    
    properties(Dependent = true, Hidden = false)
        directions
    end
    
    methods
        function this = itaDirectivity(varargin)
            this = this@itaAudio(varargin{:});            
        end
        
        function result = nChannels(this)
            result = prod(this.dimensions(2:end));
        end
        
        function this = reduce(this,resolution)
           [this.directions, ind] = this.directions.reduce_equiangular_grid(resolution);
           this.freq = this.freq(:,ind,:);
        end
        
        function this = set.directions(this,value)
            if ~isa(value,'itaCoordinates')
               error('itaDirectivity: I need some form of itaCoordinates') 
            end
            this.mDirections = makeCart(value);
            this.mDirections = build_search_database(this.mDirections);
        end
        
        function result = get.directions(this)
            result = this.mDirections;
        end
        
        function result = getNearestFreq(this,searchDirection)
            result = itaAudio;
            result.domain = 'freq';
            result.freq = getNearestFreqData(this,searchDirection);
            result.samplingRate = this.samplingRate;
            
            result.channelNames = this.channelNames;
            result.channelUnits = this.channelUnits;
            result.channelCoordinates = this.channelCoordinates;
            result.signalType = this.signalType;
            % ToDo: The rest of channel... stuff
            if ~strcmp(this.domain,result.domain)
                ita_verbose_info('itaDirectivity: Carefull, wrong domain, I will have to do an transformation')
            end
            
        end
        
        function result = getNearest(this,searchDirection)
            result = itaAudio;
            result.domain = this.domain;
            switch this.domain
                case 'time'
                    result.time = getNearestTimeData(this,searchDirection);
                case 'freq'
                    result.freq = getNearestFreqData(this,searchDirection);
            end
            result.samplingRate = this.samplingRate;
            result.channelNames = this.channelNames;
            result.channelUnits = this.channelUnits;
            % ToDo: The rest of channel... stuff
              if ~strcmp(this.domain,result.domain)
                ita_verbose_info('itaDirectivity: Carefull, wrong domain, I will have to do an transformation')
            end
            
        end
        
        function result = getNearestTime(this,searchDirection)
            result = itaAudio;
            result.domain = 'time';
            result.time = getNearestTimeData(this,searchDirection);
            result.samplingRate = this.samplingRate;
            
            result.channelNames = this.channelNames;
            result.channelUnits = this.channelUnits;
            % ToDo: The rest of channel... stuff
              if ~strcmp(this.domain,result.domain)
                ita_verbose_info('itaDirectivity: Carefull, wrong domain, I will have to do an transformation')
            end
            
        end
        
        function result = getNearestFreqData(this,searchDirection)
            nearestInd = this.directions.findnearest(searchDirection,[],1);
            result = this.freq(:,nearestInd,:);
        end
        
        function result = getNearestTimeData(this,searchDirection)
            nearestInd = this.directions.findnearest(searchDirection,[],1);
            result = this.time(:,nearestInd,:);
        end
        
        
        function result = split(this, index)
            
            result = this;
            
            % only use the reduced data 
            result.(result.domain) = this.(result.domain)(:,:,index);
            %result.dimensions = numel(index);
            
            % and select the appropriate Channel struct(s)
            result.channelNames = this.channelNames(index);
            result.channelUnits = this.channelUnits(index);
            result.channelCoordinates = this.channelCoordinates.n(index);
            result.channelOrientation = this.channelOrientation.n(index);
            result.channelSensors = this.channelSensors(index);
            result.channelUserData = this.channelUserData(index);

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
            this = itaDirectivity(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 3071 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'directions'};
        end
    end
    

end
