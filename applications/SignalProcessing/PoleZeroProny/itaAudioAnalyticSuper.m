classdef itaAudioAnalyticSuper < itaAudio

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    %ITAAUDIOAnalytic - super class for analytic audio data files
    %
    %
    % These objects can be used for all data with is directly convertable
    % between frequency domain and time domain. Equally spaced samples or
    % bins.
    %
    % itaAudio Properties:
    %   samplingRate
    %
    %   Reference page in Help browser
    %        <a href="matlab:doc itaAudio">doc itaAudio</a>
    
    properties(Access = protected, Hidden = true)
        % here are default values defined
        mNSamples     = 2^14;
    end
    
    properties(Dependent = true, Hidden = true)
        mData;
    end
    
    properties(Abstract,Dependent = true, Hidden = false)
        analyticData
    end
    methods
        
        function res = get.mData(this)
%             disp('calledjkljkljkljkljkljkl')
            res = this.freq;
        end
        
        %% not used yet...
        function [this1, this2] = prepare4calculation(this1, this2)
            
            %first one is analytic, second arbitrary
            
            if isa(this2,'itaSuper')
                this1.fftDegree    = this2.fftDegree;
                this1.samplingRate = this2.samplingRate;
            end
        end
        function [this1, this2] = prepare4merge(this1, this2)
            ita_verbose_info('itaAudioAnalyticSuper.m prepare 4 merge',1);
            [this1, this2] = prepare4calculation(this1, this2);
            [this1, this2] = prepare4merge@itaAudio(this1, this2);
            
            
        end
        
        
    end
    methods(Abstract)
        %% Get/Set Functions - Trick 17 + 4 - overloaded from itaAudio
        res = ifft(this)
        res = fft(this)
    end
    
    %% Hidden Methods
    methods(Hidden = true)
        function this = set_nSamples(this, nSamples)
            this.mNSamples = round(nSamples);
        end
        
        
        %%
        function result = get_data(this)
           result = this.analyticData; 
        end
        function this = set_data(this,value)
            % set_data that is called from itaSuper
            this.analyticData = value;
%             if this.isTime
%                 if (rem(size(value,1),2) == 1)
%                     this.mEvenSamples = false;
%                 else
%                     this.mEvenSamples = true;
%                 end
%             end
%             this = set_data@itaSuper(this,value);
        end
        
        function result = get_nBins(this)
            result = this.nSamples2nBins;
        end
        
        function result = get_nSamples(this)
            result = this.mNSamples;
        end
        
        
    end
    
    
    %% Static Methods
    methods(Static)
        function this = loadobj(sObj)
%             ita_verbose_info('HUHU',0)
            % Called when an object is loaded
            superclass = false;
            if isfield(sObj,'classrevision')
                if sObj.classrevision > 2600
                    superclass = true;
                end
            end
            
            if ~superclass
                if isfield(sObj,'header')
                    %is first version, with header
                    this = ita_import_old(sObj);
                    return
                else
                    % is headerless
                    sObj.dimensions = sObj.dims;
                    sObj.samplingRate = sObj.sr;
                    sObj.signalType = sObj.fftnorm;
                    sObj.channelCoordinates = itaCoordinates(sObj.channelcoordinates);
                    sObj.channelOrientation = itaCoordinates(sObj.channelorientation);
                    sObj = rmfield(sObj,{'dims','sr','fftnorm','channelcoordinates','channelorientation'});
                end
            end
            sObj.dataType = class(sObj.data); % RSC: overwrite save dataType with real class of data
            sObj.dataTypeOutput = class(sObj.data);
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaAudioAnalytic(sObj); % Just call constructor, he will take care
            switch this.dataType(1:3)
                case {'int'}
                    this.dataTypeOutput = 'single'; %Save solution
                otherwise
                    this.dataTypeOutput = this.dataType;
            end
        end
    end
end