classdef itaAudioMIMO < itaAudio
    
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    properties(Access = private, Hidden = true)
        
        mReceiverPosition = itaCoordinates();
        mReceiverUpVector = itaCoordinates();
        mReceiverViewVector = itaCoordinates();
        mSourcePosition = itaCoordinates();
        mSourceUpVector = itaCoordinates();
        mSourceViewVector = itaCoordinates();
    end
    
    properties(Dependent = true, Hidden = false)
        nSources
        nReceivers
        
    end
    properties(Dependent = true, Hidden = true)
        
    end
    methods
        
        
        function this = itaAudioMIMO(varargin)
            this = this@itaAudio(varargin{1}(1));
            
            [nReceivers, nSources] = size(varargin{1});
            nSamplesOrBins = size(this.data, 1);
            
                     
            this.(this.domain)         = zeros(nSamplesOrBins, nReceivers, nSources);
            channelNames = cell(nReceivers, nSources);
            for iReceiver = 1:nReceivers
                for iSource = 1:nSources
                    if varargin{1}(iReceiver, iSource).nChannels > 1
                        error('nur ein channel pro itaAudio. muss man anpassen wenn man was anderes will')
                    end
                    this.(this.domain)(:, iReceiver, iSource) = varargin{1}(iReceiver, iSource).(this.domain);
                    channelNames(iReceiver, iSource) = varargin{1}(iReceiver, iSource).channelNames;
                end
            end
            
            this.channelNames = channelNames;
        end
        
        
        function res = source(this, iSource)
            res = this;
            
            dataSize = [this.nReceivers this.nSources];
            
            % use linear index because channelNames is always 1-D and data 2-D
            linearIndex = sub2ind(dataSize, 1:dataSize(1), iSource*ones(1,dataSize(1)));
            
            res.data             = this.data(:, linearIndex);
            res.channelNames     = this.channelNames(linearIndex);
        end
        
        
        function res = receiver(this, iReceiver)
            res = this;
            
            dataSize = [this.nReceivers this.nSources];
            
            % use linear index because channelNames is always 1-D and data 2-D
            linearIndex = sub2ind(dataSize, iReceiver*ones(1,dataSize(2)), 1:dataSize(2));
            
            res.data             = this.data(:, linearIndex);
            res.channelNames     = this.channelNames(linearIndex);
        end
        
        
        function nSources = get.nSources(this)
            nSources = size(this.(this.domain), 3);
        end
        
        function nReceivers = get.nReceivers(this)
            nReceivers = size(this.(this.domain), 2);
        end
        
    end
end