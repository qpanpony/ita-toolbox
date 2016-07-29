classdef itaAudioAnalytic < itaAudio
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
    
    % <ITA-Toolbox>
    % This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % Author: Pascal Dietrich - pdi@akustik.rwth-aachen.de
    
    
    properties(Access = private, Hidden = true)
        % here are default values defined
        mSignalType   = 'energy';   % 'energy' only
        mEvenSamples  = true;
        mNSamples     = 2^16;
        mData         = [];
    end
    
    %     properties(Constant, Hidden = true)
    %         VALID_SIGNAL_TYPES = {'energy'};
    %     end
    
    properties(Dependent = true, Hidden = false)
        %         samplingRate    % sampling Rate in Hertz
        %         signalType      % energy (filter) or power (signal) normalization for FFT/IFFT
        %         fftDegree       % 2^fftDegree samples in time domain
        %          trackLength     % seconds long
        nSamples        % get/set number of samples - related to fftdegree and trackLength
    end
    
    methods
        function this = itaAudioAnalytic(varargin)
            % itaAudio - generates itaAudio Object
            %
            % itaAudio() - empty itaAudio object
            %    example: a = itaAudio;
            %
            % itaAudio(domainData, sr, domain) - generates itaAudio
            %        with the data specified in domainData, sampling rate
            %        sr and in the domain defined with the string domain
            %    example:      audioObj = itaAudio(timeData, 44100, 'time')
            
            this = [];
        end
        
        
        
        %% Get/Set Functions - overloaded from itaAudio
        function result = get.nSamples(this)
            result = this.mNSamples;
        end
        
        %         function this = set.fftDegree(this, value)
        %             nSamples = round(2^value);
        %             this     = set_nSamples(this, nSamples);
        %         end
        
        %         function result = get.trackLength(this)
        %             result = this.nSamples ./ this.samplingRate * itaValue('1s');
        %         end
        %
        %         function this = set.trackLength(this, value)
        %             nSamples = this.samplingRate * value;
        %             if isfinite(nSamples)
        %                 this = set_nSamples(this, nSamples);
        %             else
        %                 disp('Cannot set trackLength, nSamples are not finite. Check the samplingRate.');
        %             end
        %         end
        
    end
    
    %% Hidden Methods
    methods(Hidden = true)
        function this = set_nSamples(this, nSamples)
            this.mNSamples = round(nSamples);
        end
        
        
        %%
        
        function this = set_data(this,value)
            % set_data that is called from itaSuper
            if this.isTime
                if (rem(size(value,1),2) == 1)
                    this.mEvenSamples = false;
                else
                    this.mEvenSamples = true;
                end
            end
            this = set_data@itaSuper(this,value);
        end
    end
    
    %% Static Methods
    methods(Static)
        function this = loadobj(sObj)
            ita_verbose_info('HUHU',0)
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