classdef itaAudio < itaSuper
        
    %ITAAUDIO - class for complete (playable) audio data files
    %
    %
    % These objects can be used for all data which is directly convertable
    % between frequency domain and time domain. Equally spaced samples or
    % bins.

    %
    % itaAudio Properties:
    %   samplingRate
    %
    %   Reference page in Help browser
    %        <a href="matlab:doc itaAudio">doc itaAudio</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>

    
    
    properties(Access = private, Hidden = true)
        % here are default values defined
        mSamplingRate = ita_preferences('samplingRate');
        mSignalType = 'power';   % 'power' / 'energy'
        mEvenSamples = true;
    end
    
    properties(Constant, Hidden = true)
        VALID_SIGNAL_TYPES = {'power', 'energy'};
    end
    
    properties(Dependent = true, Hidden = false)
        samplingRate    % sampling Rate in Hertz
        signalType      % energy (filter) or power (signal) normalization for FFT/IFFT
        fftDegree       % 2^fftDegree samples in time domain
        trackLength     % seconds long
        wavenumber      % k = 2*pi*f/c
    end
    
    properties(Dependent = true, Hidden = true)
        dat             % alternative syntax, equals .timeData.'
        spk             % alternative syntax, equals .freqData.'
        freqAmp         % delivers the amplitude value of the FFT, i.e, no signal type correction
    end
    
    methods
        function this = itaAudio(varargin)
            % itaAudio - generates itaAudio Object
            %
            % itaAudio() - empty itaAudio object
            %    example: a = itaAudio;
            %
            % itaAudio(domainData, sr, domain) - generates itaAudio
            %        with the data specified in domainData, sampling rate
            %        sr and in the domain defined with the string domain
            %    example:      audioObj = itaAudio(timeData, 44100, 'time')
            
            isSpecialCase = false;
            if nargin == 3 && ischar(varargin{3})
                isSpecialCase = true;
                % this special case is itaAudio specific:
                % example:      audioObj = itaAudio(timeData, 44100, 'time')
                domainData = varargin{1};
                samplingRate = varargin{2};
                domain = varargin{3};
                varargin = {};      % just ask for itaSuper([])
            end
            this = this@itaSuper(varargin{:});
            
            if isSpecialCase
                this.domain = domain;
                this.samplingRate = samplingRate;
                this.(domain) = domainData;
            end
        end
        
        
        
        %% Get/Set Functions
        function result = get.spk(this)
            result = this.freqData.';
        end
        
        function this = set.spk(this,value)
            this.freqData = value.';
        end
                
        function result = get.freqAmp(this)
            aux = fft(this.timeData,[],1);
            result = aux(1:floor(size(aux,1)/2)+1,:);
        end
        
        function this = set.freqAmp(this,value)
            this.timeData = ifft([value; value(end-1:-1:2,:)],[],1,'symmetric');
        end
              
        function result = get.dat(this)
            result = this.timeData.';
        end
        function this = set.dat(this,value)
            this.timeData = value.';
        end
        
        function result = get.samplingRate(this)
            result = this.mSamplingRate;
        end
        
        function this = set.samplingRate(this,value)
            if isscalar(value)
                this.mSamplingRate = value;
            else
                error('%s.set.samplingRate  samplingRate must be a scalar value',mfilename);
            end
        end
        
        %% signal type
        function result = get.signalType(this)
            result = this.mSignalType;
        end
        
        function this = set.signalType(this,value)
            if ismember(value, this.VALID_SIGNAL_TYPES)
                this.mSignalType = value;
            else
                warning([upper(mfilename) '.set.signalType  ignoring unknown input'])
            end
        end
        
        %% fft degree
        function result = get.fftDegree(this)
            result = ita_fftDegree(this.nSamples);
        end
        
        function this = set.fftDegree(this, value)
            if value>31
                warning('FFT degree higher than 31 are not converted in to number of Samples anymore in itaAudio.setfftDegree! If you did not expect this message, please report to the toolbox support team.');
            end
            nSamples    = ita_nSamples(value, 'fftDegree');
            this        = set_nSamples(this, nSamples);
        end
        
        %% track length
        function result = get.trackLength(this)
            %get track Length in seconds
            result = this.nSamples ./ this.samplingRate;% * itaValue('1s');
            % mpo: changed the output back to double, simpler to work with
        end
        
        function this = set.trackLength(this, value)
            nSamples = this.samplingRate * double(value);
            if nSamples<32
                warning('Warning! Samples numbers smaller than 32 are not converted to FFT degree anymore in itaAudio.nSamples! If you did not expect this message, please report to the toolbox support team.');
            end
            if isfinite(nSamples)
                this = set_nSamples(this, nSamples);
            else
                disp('Cannot set trackLength, nSamples are not finite. Check the samplingRate.');
            end
        end
        
        %%  wavenumber
        function result = get.wavenumber(this)
            c = double(ita_constants('c'));
            result = 2*pi.*this.freqVector./c;
        end
        
        %% other functions
        function result = or(this,that)
            % or - Parallel Impedance Calculation
            result = ita_impedance_parallel(this,that);
        end
        
        %% Other stuff
        % Now implemented as dependent property
        %         function result = trackLength(this)
        %             result = (this.nSamples -1)./ this.samplingRate * itaValue('1s');
        %         end
        %
        %
        %         function result = fftDegree(this)
        %             result = log2(this.nSamples);
        %         end
        
        function result = isEvenSamples(this)
            %isEvenSamples - return 1 if sample number is even
            result = this.mEvenSamples;
        end
        
        function result = isPower(this)
            %isPower - returns 1 if power signal
            result = nan(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).signalType,'power');
            end
        end
        
        function result = isEnergy(this)
            %isEnergy - returns 1 if energy signal
            result = nan(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).signalType,'energy');
            end
        end
        
        function result = timeVector(this,index)
            %timeVector - get the time vector (x-axis) in seconds starting at 0
            %seconds till trackLength
            if numel(this) ~= 1
                error('just works on single instances');
            end
            result = linspace(0,double(this.trackLength),this.nSamples+1).';
            result(end) = [];
            % the ischar command is a bugfix when the colon operator is used
            % to get the entire timeVector
            if nargin == 2 && ~ischar(index)
                result = result(index);
            end
        end
        
        function result = freqVector(this, index)
            %freqVector - returns the frequency vector (x-axis) in Hz
            if numel(this) ~= 1
                error('just works on single instances');
            end
            SR = this.samplingRate;
            if isnan(SR) || isinf(SR) || ~isscalar(SR)
                error([upper(mfilename) '.freqVector  wrong samplingRate set']);
            end
            % the ischar command is a bugfix when the colon operator is used
            % to get the entire freqVector
            if nargin < 2 || ischar(index)
                if this.isEvenSamples
                    result = linspace(0,this.samplingRate/2,this.nBins).';
                else
                    result = linspace(0,this.samplingRate/2*(1-1/(2*this.nBins-1)),this.nBins).';
                end
            else
                if this.isEvenSamples
                    result = (index-1)/(this.nBins-1) * this.samplingRate/2;
                else
                    result = (index-1)/(this.nBins-0.5) * this.samplingRate/2;
                end
            end
        end
        
        
        
        
    end
    
    %% Hidden Methods
    methods(Hidden = true)
        function displayChannelString(this,fHandle)
            % same function as in itaSuper, but with play
            global lastDiplayedVariableName
            chStr = '';
            if ismember(this.nChannels, 1:20)
                chStr = '- play ch: ';
                for ind = 1:this.nChannels
                    chStr = [chStr '<a href = "matlab: play(ch(' lastDiplayedVariableName ',' num2str(ind) '))' '">' num2str(ind) '</a> '];
                end
            end
            
            prefName = 'dispVerboseChannels'; dispName = 'channels';
            nChannels = this.nChannels;
            if nChannels == 1; dispName = dispName(1:end-1); end %get rid off plural 's'
            dispName = [num2str(nChannels) ' ' dispName ' (dimensions = ' this.dimString ') ' ];
            if ita_preferences('dispVerboseChannels')
                middleLine = this.LINE_MIDDLE;
                middleLine(3:(2+length(dispName))) = dispName;
                fprintf(['<a href = "matlab: ita_preferences(''' prefName ''',0); display(' lastDiplayedVariableName ')">-</a> ' middleLine(3:end) '\n']);
                fHandle(this);
            else
                fprintf(['<a href = "matlab: ita_preferences(''' prefName ''',1); display(' lastDiplayedVariableName ');">+</a> ' dispName  chStr '\n']);
            end
        end
        
        function this = set_nSamples(this, nSamples)
            if nSamples<32
                warning('Warning! Samples numbers smaller than 32 are not converted to FFT degree anymore in itaAudio.nSamples! If you did not expect this message, please report to the toolbox support team.');
            end
            % set nSamples and trim audio time data accordingly
            nSamples = ita_nSamples(nSamples,'samples');
            if nSamples == this.nSamples
                return; % nothing to do, length is OK
            elseif nSamples > this.nSamples
                nToFill = nSamples - this.nSamples;
%                 this.timeData = [this.timeData; zeros(nToFill,this.nChannels)];
                % jri: this is _much_ more efficient 
                this.timeData(nSamples,:) = 0;
                ita_verbose_info(['I am adding zeros to the data to fill it to nSamples = ' num2str(nSamples)],2);
            else
                this.timeData = this.timeData(1:nSamples,:);
                ita_verbose_info(['I am cutting the data to nSamples = ' num2str(nSamples)]);
            end
        end
        
        function [this1, this2] = prepare4merge(this1, this2)
            % Prepare two object for merge, check if compatible and try to fix problems
            
            % Check samplingRate
            if this1.samplingRate ~= this2.samplingRate
                ita_verbose_info('merge@itaAudio: samplingRates do not match, resampling',0)
                this2 = ita_resample(this2,this1.samplingRate);
            end
            
            % Check signalType
            if ~strcmp(this1.signalType, this2.signalType)
                ita_verbose_info('merge@itaAudio: signalTypes do not match, using first',0)
                this2.signalType = this1.signalType;
            end
            
            % Check nSamples
            if this1.nSamples ~= this2.nSamples %nSamples does not agree
                if strcmp(this1.signalType, 'energy') % its an energy signal
                    this2 = ita_interpolate_spk(this2,this1.fftDegree); %Interpolation in frequency domain is saver, though not perfect
                    ita_verbose_info('merge@itaAudio: signal length does not match, interpolation in frequency domain',0)
                else % its power, extract samples
                    if this1.nSamples > this2.nSamples
                        this1 = ita_extract_dat(this1, this2.nSamples);
                    else
                        this2 = ita_extract_dat(this2, this1.nSamples);
                    end
                    ita_verbose_info('merge@itaAudio: signal length does not match, extracting samples. Some samples will be lost!',0)
                end
            end
            
            switch this1.domain
                %domain - returns domain string ('time' or 'freq')
                case {'time'}
                    this2 = ifft(this2);
                case {'freq'}
                    this2 = fft(this2);
                otherwise
                    error('How did we get here?');
            end
            
            [this1, this2] = prepare4merge@itaSuper(this1, this2);
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            sObj = saveobj@itaSuper(this);
            
            % Copy all properties that were defined to be saved
            propertylist = itaAudio.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        function res = conv(this,value)
           res = ita_convolve(this,value);
        end
        
        %% conversion nSamples <=> nBins
        function nBins = nSamples2nBins(this)
            %nSamples2nBins - converts between sample and bin number
            nSamples = this.nSamples;
            % check for empty data
            if nSamples == 0, nBins = 0; return, end
            % check if odd number of samples
            if this.isEvenSamples
                nBins = (nSamples/2) + 1;
                %                 error([upper(mfilename) '.nSamples2nBins odd number of samples not allowed']);
            else
                nBins = (nSamples+1) / 2;
            end
        end
        
        function nSamples = nBins2nSamples(this)
            %nSamples2nBins - converts between sample and bin number
            
            % check for empty data
            nBins = this.nBins;
            if nBins == 0, nSamples = 0; return, end
            if this.isEvenSamples
                nSamples = 2 * (nBins - 1);
            else
                nSamples = (nBins * 2) - 1;
            end
        end
        
        function this = set_data(this,value)
            % set_data that is called from itaSuper
            if this.isTime
                if (rem(size(value,1),2) == 1)
                    this.mEvenSamples = false;
                else
                    this.mEvenSamples = true;
                end
                %                 error([upper(mfilename) '.set_data  only even number of samples allowed in time domain']);
            end
            this = set_data@itaSuper(this,value);
        end
    end
    
    %% Static Methods
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            superclass = false;
            
            % change mpo: not relying on svn properties anymore
            try
                if sObj.classrevision > 2600 ...
                        || isnan(sObj.classrevision) % for non-SVN clients
                    superclass = true;
                end
            catch
                % all right: it was NO superclass
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
            
            % change mpo: not relying on svn properties anymore
            try
                sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            catch
                % fields were not there obviously
            end
            
            % change mpo: not relying on svn properties anymore          
            if isstruct(sObj)
                this = itaAudio(sObj); % Just call constructor, he will take care
            else
                this = sObj;
            end
            switch this.dataType(1:3)
                case {'int'}
                    this.dataTypeOutput = 'single'; %Save solution
                otherwise
                    this.dataTypeOutput = this.dataType;
            end
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 12930 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            %propertiesSaved - these properties will be saved
            result = {'samplingRate', 'signalType'};
        end
        
    end
end