classdef itaSphSynthDirectivity < handle
    % see also itaSphSynthSirectivity.tutorial
    
    % TO DO
    % - makeArraySampling(this), dann funktioniert erst die kodierte
    % Ansteuerung (Ansteuerung nach sphärischen Harmonischen)
    properties (Dependent = true)
        folder        % object's home directory
        array         % an itaSphericalLoudspeaker or an itaBalloonSH
        arrayChannels % indices of the array's speaker that shall be involved
        arrayNmax     % maximim degree for the synthesis of the super-array
        tiltAngle     % euler angle (see tutorial)
        rotationAngle % vector of rotation angles (see tutorial)
        measurementDataFolder % directories of your measurements
        freqRange
        precision
        MBytesPerSegment
    end
    properties(Access = private)
        mFolder                 = [];
        mArray                  = itaBalloon;
        mArrayChannels          = [];
        mArrayNmax              = nan;
        mTiltAngle              = {[0 0 0]};
        mRotationAngle          = 0;
        mMeasurementDataFolder  = {};
        mFreqRange              = [];
    end
    properties (Access = public)
        name                        = 'this';
        comment                     = ' ';
        regularization              = 1e-4;
        rotationAngle_counterClockWise  = true; %if measurements stem from itaItalian this must be set false!
        encodeNmax                  = 20;
        nmax                        = nan;
        filemask                    = '';
    end
    properties(GetAccess = public, SetAccess = private)
        freqVector                  = [];
        nSpeakers                   = [];      % set in makeSynthSpeaker
        nBins                       = [];
        idxTiltRot2idxFolderFile    = {};      % set in getPositions
        speaker2idxTiltRotCh        = [];      % set in makeSynthSpeaker
        SHType                      = [];
        
        arraySampling               = itaCoordinates;               % set in makeSpeakerSampling
    end
    properties(Access = private)
        internalFreqRange           = [];
        mDataSH                     = itaFatSplitMatrix;
        mFilterData                 = itaFatSplitMatrix;
        outputFormat                = [];
    end
    methods
        % constructor
        function this = itaSphSynthDirectivity(varargin)
            if ~nargin
                % initialize some stuff
                this.MBytesPerSegment = 200;
                this.precision        = 'single';
            else
                if isa(varargin{1}, 'itaSphSynthDirectivity')
                    prop = this.propertiesSaved;
                    for idx = 1:length(prop)
                        this.(prop{idx}) = varargin{1}.(prop{idx});
                    end
                    % call class's copy constructor
                    this.mDataSH     = itaFatSplitMatrix(varargin{1}.mDataSH);
                    this.mFilterData = itaFatSplitMatrix(varargin{1}.mFilterData);
                    
                    % load actual data
                    if ~isempty(varargin{1}.array)
                        this.mArray  = ita_read_itaBalloon([varargin{1}.array.balloonFolder filesep varargin{1}.array.name]);
                    end
                end
            end
        end
        
        
        % data administration 
        function idxFreq = freq2idxFreq(this,freq)
            % frequency 2 index of freqVector
            idxFreq = zeros(size(freq));
            for idx = 1:numel(freq)
                [dist idxFreq(idx)] = min(abs(this.freqVector-freq(idx))); %#ok<ASGLU>
            end
        end
        function value = freq2coefSH_synthArray(this, freq, varargin)
            % returns the spherical harmonic coefficients at given
            % frequencies
            % output-size: [coefficients(linear numbered); array-speaker; frequency]
            % options    : nmax: maximum degree of coefficient
            %            : channels: index of array-speaker
            sArgs = struct('nmax',this.arrayNmax,'channels',1:this.nSpeakers);
            if nargin > 2
                sArgs = ita_parse_arguments(sArgs,varargin);
            end
            
            %read data
            value = this.mDataSH.get_data(1:(sArgs.nmax+1)^2, sArgs.channels, this.freq2idxFreq(freq));
        end
        function filter = idxSH2filter(this, idxSH, varargin)
            % returns a filter that weights all the synthArrays speakers,
            % so that their superposition yields a directivity with the
            % surface of the spherical base function with the linear index
            % idxSH.
            %
            % the filter's frequency range can be extended using 
            % this.extendFreqRange
            %
            % if this.SHtype == 'complex', this function is a complex
            % valued spherical harmominc, if == 'real', ...
            %
            % if your array was an itaBalloon with a continuous
            % frequencyResponse, output will be an itaAudio, otherwise an
            % itaResult.
            %
            % otopn : 'speakers' default : 1:this.nSpeakers
            %
            % see also: tutorial, ita_sph_degreeorder2linear, ita_sph_base,
            % ita_sph_realvalued_basefunction, itaSamplingSph,
            % itaSamplingSphReal, extendFreqRange
            sArgs = struct('speakers',1:this.nSpeakers);
            if nargin > 2
                sArgs = ita_parse_arguments(sArgs, varargin);
            end
            if strcmpi(this.outputFormat, 'itaResult')
                filter = itaResult(length(idxSH),1);
                for idx = 1:length(idxSH)
                    filter(idx).freqVector = this.freqVector;
                end
            elseif strcmpi(this.outputFormat, 'itaAudio')
                filter = itaAudio(length(idxSH),1);
                for idx = 1:length(idxSH)
                    filter(idx).samplingRate = this.speaker.samplingRate;
                    filter(idx).signalType = 'energy';
                end
            else
                error(' unknown format');
            end
            
            for idx = 1:length(idxSH)
                filter(idx).dataType   = this.precision;
                
                idxOffset = length(this.speaker.freqVector(this.speaker.freqVector < this.freqVector));
                filter(idx).freqData(idxOffset+(1:this.nBins),:) = this.mFilterData.get_data(1:this.nBins,sArgs.speakers,idxSH(idx));
                
                filter(idx).channelUserData{1} = sArgs.speakers;
                [n m] = ita_sph_linear2degreeorder(idxSH(idx));
                filter(idx).comment = ['filter for the synthesis of SH ' int2str(n) ', ' int2str(m) ' (not smoothed)'];
            end
        end
        function out = encodeCoefSH(this, in)
            % in : [idxCoefSH idxRealChannel    idxFreq]
            % out: [idxCoefSH idxEncodedChannel idxFreq]
            
            % check if encoding must be initialized
            if ~isa(this.arraySampling, 'itaSamplingSph')...
                    || this.arraySampling.nPoints ~= this.nSpeakers
                this.makeArraySampling;
            end
            
            if this.encodeNmax ~= this.arraySampling.nmax
                if strcmpi(this.SHType, 'complex')
                    this.arraySampling = itaSamplingSph(this.arraySampling);
                elseif strcmpi(this.SHType, 'real')
                    this.arraySampling = itaSamplingSphReal(this.arraySampling);
                else
                    error('unknown SH-type');
                end
                this.arraySampling.nmax = this.encodeNmax;
                save(this);
            end
            
            % encoding
            out = zeros(size(in,1), (this.encodeNmax+1)^2, size(in,3));
            for idxF = 1:size(in,3)
                out(:,:,idxF) = in(:,:,idxF)*this.arraySamplingY(:,1:(this.encodeNmax+1)^2);
            end
        end
        function out = decodeCoefSH(this, in, maintainedFunctions)
            % in : [idxEncodedChannel idxFreq]
            % out: [idxRealChannel    idxFreq]
            
            out = zeros(size(this.arraySamplingY,1), size(in,2), size(in,3));
            for idxN = 1:size(in,3)
                out(:,:,idxN) = this.arraySamplingY(:,maintainedFunctions)*in(:,:,idxN);
            end
        end
        
        % set / get methods  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.folder(this, dir)
            this.mDataSH.folder        = dir;
            this.mFilterData.folder    = dir;
            this.mFolder               = dir;
        end
        function value = get.folder(this)
            value = this.mFolder;
        end
        function set.MBytesPerSegment(this, value)
            this.mDataSH.MBytesPerSegment     = value;
            this.mFilterData.MBytesPerSegment = value;
        end
        function value = get.MBytesPerSegment(this)
            value = this.mDataSH.MBytesPerSegment;
        end
        function set.array(this, value)
            check_empty(this);
            if isa(value, 'itaBalloonSH')
                if ~value.existSH
                    error('You must proceed a spherical harmonic transform of your array first!');
                end
                this.SHType = value.SHType;
                this.arrayNmax = min(this.arrayNmax, value.nmax);
                nChannels = value.nChannels;
            elseif isa(value, 'itaSphSphericalLoudspeaker');
                this.SHType = 'complex';
                nChannels = value.nApertures;
                
            else
                error('"this.array" must be either an itaBalloonSH or an itaSphericalLoudspeaker - object!!"');
            end
            this.mArray = value;
            
            if isempty(this.arrayChannels)
                this.arrayChannels = 1:nChannels;
            else
                this.arrayChannels = this.arrayChannels(this.arrayChannels<=nChannels);
            end
           
            %reset
            this.arraySampling  = itaCoordinates;
        end
        function value = get.array(this)
            value = this.mArray;
        end
        function set.arrayChannels(this, value)
            check_empty(this);
            this.mArrayChannels = value;
        end
        function value = get.arrayChannels(this)
            value = this.mArrayChannels;
        end
        function set.arrayNmax(this, value)
            check_empty(this);
            if isa(this.array, 'itaBalloonSH')
                value = min(value, this.array.nmax);
            end
            this.mArrayNmax = value;
        end
        function value = get.arrayNmax(this)
            value = this.mArrayNmax;
        end
        function set.tiltAngle(this, value)
            check_empty(this);
            if ~iscell(value)
                value = {value};
            end
            for idx = 1:length(value)
                if size(value{idx},2) ~= 3
                    error('input data size mismatch');
                end
            end
            this.mTiltAngle = value;
        end
        function value = get.tiltAngle(this)
            value = this.mTiltAngle;
        end
        function set.rotationAngle(this, value)
            check_empty(this);
            if ~iscell(value)
                value= {value};
            end
            this.mRotationAngle = value;
        end
        function value = get.rotationAngle(this)
            value = this.mRotationAngle;
        end
        function set.measurementDataFolder(this, value)
            check_empty(this);
            if ~iscell(value)
                value = {value};
            end
            this.mMeasurementDataFolder = value;
        end
        function value = get.measurementDataFolder(this)
            value = this.mMeasurementDataFolder;
        end
        function set.freqRange(this, value)
            check_empty(this);
            if length(value) ~= 2
                error('input data size mismatch');
            end
            this.mFreqRange = value;
            this.internalFreqRange = value .* [1/sqrt(2) sqrt(2)];
        end
        function value = get.freqRange(this)
            value = this.mFreqRange;
        end
        function set.precision(this, value)
            this.mDataSH.precision = value;
        end
        function value = get.precision(this)
            value = this.mDataSH.precision;
        end
        
        % administration
        function value = read(this,file)
            value = this.mDataSH.read(file);
        end
        function save(this)
            if ~isdir(this.folder)
                ita_verbose_info('Making folder for you...',1);
                mkdir(this.folder)
            end
            
            if ~isempty(this.mDataSH)
                this.mDataSH.save_currentData;
            end
            if ~isempty(this.mFilterData)
                this.mFilterData.save_currentData;
            end
            s = struct(this.name, itaSphSynthDirectivity(this)); %#ok<NASGU>
            save([this.folder filesep this.name],'-struct','s',this.name);
        end
        
        %% error messages
        function check_empty(this)
            if ~this.mDataSH.isempty
                error('itaSphSyntDirectivity::you can not set this property, because object is not empty');
            end
        end
    end
    methods(Hidden = true)
        % this ist just to hide all the handle functions...
        function varargout = addlistener(this, varargin), varargout = this.addlistener@handle(varargin); end
        function varargout = eq(this, varargin), varargout = this.eq@handle(varargin); end
        function varargout = findobj(this, varargin), varargout = this.findobj@handle(varargin); end
        function varargout = findprop(this, varargin), varargout = this.findprop@handle(varargin); end
        function varargout = ge(this, varargin), varargout = this.ge@handle(varargin); end
        function varargout = gt(this, varargin), varargout = this.gt@handle(varargin); end
        function varargout = le(this, varargin), varargout = this.le@handle(varargin); end
        function varargout = lt(this, varargin), varargout = this.lt@handle(varargin); end
        function varargout = ne(this, varargin), varargout = this.ne@handle(varargin); end
        function varargout = notify(this, varargin), varargout = this.notify@handle(varargin); end
        function varargout = delete(this, varargin), varargout = this.delete@handle(varargin); end
    end
    methods(Static, Hidden = true)
        function myWaitbar(in, text)
            persistent WB maxN string;
            
            if exist('text','var') % if there's a string, initialize
                maxN = in;
                string = text;
                WB = waitbar(0, [string ' (initialize)']);
                
            elseif in < maxN
                waitbar(in/maxN, WB, [string ' (proceed ' int2str(in) ' / ' int2str(maxN-1) ')']);
                
            else
                waitbar(1, WB, [string ' (finish)']);
            end
            
            if isempty(in)
                close(WB);
            end
        end
        function prop = propertiesSaved
            prop = {'mFolder','mArrayChannels',...
                'mArrayNmax','mTiltAngle','mRotationAngle','mMeasurementDataFolder','mFreqRange',...
                'name','comment','regularization','rotationAngle_counterClockWise','encodeNmax','nmax',...
                'freqVector','nSpeakers','nBins','idxTiltRot2idxFolderFile','speaker2idxTiltRotCh'...
                ,'SHType','arraySampling', 'internalFreqRange','filemask', 'outputFormat'};
            % mDataSH and mArray get an extra treatment ...(see
            % constructor)
        end
    end
end