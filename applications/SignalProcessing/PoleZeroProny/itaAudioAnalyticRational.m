classdef itaAudioAnalyticRational < itaAudioAnalyticSuper
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
        mAnalyticData = itaPZ;
    end
    
    properties(Dependent = true, Hidden = false)
        analyticData;
    end
    
    properties
       timeDomain = false; 
    end
    
    methods
        
        function this = itaAudioAnalyticRational(varargin)
            % itaAudio - generates itaAudio Object
            %
            % itaAudio() - empty itaAudio object
            %    example: a = itaAudio;
            %
            % itaAudio(domainData, sr, domain) - generates itaAudio
            %        with the data specified in domainData, sampling rate
            %        sr and in the domain defined with the string domain
            %    example:      audioObj = itaAudio(timeData, 44100, 'time')
            this.domain     = 'freq';
            this.signalType = 'energy'; %this is most obvious
            if nargin == 1
                token = varargin{1};
                if isa(token,'itaAudioAnalyticSuper');
                    this = token;
                elseif isa(token,'itaPZ')
                    this.analyticData = token;
                    for idx = 1:numel(token)
                        this.channelUnits{idx} = token(idx).unit.unit;
                        this.channelNames{idx} = token(idx).comment;
                        
                    end
                elseif isstruct(token)
                    error('itaAudioAnalyticRational::this type is not allowed!')
                else
                end
            end
            
        end
        function varargout = plot_single_components(this,varargin)
            % plot all resonators as separate channels
            x = this;
            
            newanalyticData = this.analyticData(1);
            idxx            = find(newanalyticData.f >= 0);
            newanalyticData = newanalyticData.ch(idxx); %#ok<FNDSB>
            %             newanalyticData = newanalyticData.sort('freq');
            for idx = 1:length(newanalyticData.f)
                data = newanalyticData.ch(idx);
                x.analyticData(idx) = data;
                mode_decay = (data.T);
                if abs(mode_decay) < 0.01
                    mode_decay = [num2str(mode_decay*1000) 'ms'];
                else
                    mode_decay = [num2str(mode_decay) ''];
                end
                x.channelNames{idx} = [num2str(data.f) 'Hz, ' mode_decay ', ' num2str(round(20*log10(abs(data.C)))) 'dB'];
            end
            %             -6.9 ./ newanalyticData.sigma;
            if nargout == 1
                varargout{1} = x;
            else
                x.plot_spk(varargin{:})
                clear varargout;
            end
            
        end
        function this = set.analyticData(this,value)
            %             if isa(value,'rfmodel.rational') %cast to itaPZ
            %                 for idx = 1:numel(value)
            %                     valuePZ(idx) = itaPZ(value(idx));
            %                 end
            %             end
            this.mAnalyticData = value;
            this.dimensions    = numel(this.mAnalyticData);
        end
        
        function res = get.analyticData(this)
            res =  this.mAnalyticData;
        end
        
        %% Get/Set Functions - Trick 17 + 4 - overloaded from itaAudio
        function res = ifft(this)
            res = ifft(compile(this)); %make itaAudio first, then transform
        end
        
        function res = merge(this)
            % merge together
            res = this(1,1);
            res.analyticData = repmat(itaPZ,1,numel(this));
            count = 0;
            for idx = 1:size(this,1)
                for jdx = 1:size(this,2)
                    count = count + 1;
                    res.analyticData(count) = this(idx,jdx).analyticData;
                    if ~isempty(this(idx,jdx).channelNames)
                        res.channelNames{count} = this(idx,jdx).channelNames{1};
                    end
                    if ~isempty(this(idx,jdx).channelUnits)
                        res.channelUnits{count} = this(idx,jdx).channelUnits{1};
                    end
                end
            end
        end
        
        function this = mtimes(this,value)
            % multiply
            if isnumeric(value) || isa(value,'itaValue')
                if size(value) ~= size(this)
                    value = repmat(value(1,1),size(this));
                end
                for idx = 1:size(this,1)
                    for jdx = 1:size(this,2)
                        this(idx,jdx).analyticData = this(idx,jdx).analyticData * value(idx,jdx);
                    end
                end
            else
                ita_verbose_info('sorry, mtimes not implemented yet for itaAudioAnalyticRational',0)
            end
            
        end
        
        function res = fft(this)
            % normal fft by going to itaAudio
            res = this.compile; %itaAudio;
            res = fft(res);
        end
        function res = compile(this)
            
            if sum(size(this))>2
                res = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(this);
            else %normal case, no matrix given
                
                res  = itaAudio(this);                
                if this.timeDomain
                    time = zeros(this.nSamples,numel(this.analyticData));
                    for cdx = 1:numel(this.analyticData)
                        time(:,cdx) = this.analyticData(cdx).timeresp(this.timeVector)/this.samplingRate;
                    end
                    res.time = time;

                else %normal freq domain
                    freq = zeros(this.nBins,numel(this.analyticData));
                    for cdx = 1:numel(this.analyticData)
                        freq(:,cdx) = this.analyticData(cdx).freqresp(this.freqVector);
                    end
                    res.freq = freq;
                    
                end
                
                res = ita_metainfo_copy(res,this);
            end
            
        end
    end
    
    %% Hidden Methods
    methods(Hidden = true)
        function this = set_nSamples(this, nSamples)
            this.mNSamples = ita_nSamples(nSamples);
        end
        
        %%
        function this = set_data(this,value)
            this.analyticData = value;
            
            %             % set_data that is called from itaSuper
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
            ita_verbose_info('loadobj:itaAudioAnalyticRational',0)
            
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            analyticData = sObj.data;
            sObj.data = zeros(1,numel(analyticData));
            this = itaAudio(sObj); % Just call constructor, he will take care
            this = itaAudioAnalyticRational(this);
            this.analyticData = analyticData;
            switch this.dataType(1:3)
                case {'int'}
                    this.dataTypeOutput = 'single'; %Save solution
                otherwise
                    this.dataTypeOutput = this.dataType;
            end
        end
    end
end