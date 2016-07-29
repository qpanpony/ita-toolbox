classdef itaSyntheticDir < itaMotherBalloonSynth
    % I promise, in january there will be a documentaion !
    properties(Access = public)
        speaker    = [];
        speaker_channels = [];  
        speaker_nmax = 20;
        encode_nmax = 15;
        freq_range = [];
        
        nmax       = 20;
        
        regularization = 1e-5;
        target_tolerance = -0.1;
        nIterations = 3;
        
        euler_tilt  = {[0 180 0; 38.5 16.2 0]}; %euler_angle
        angle_rot   = {};  % set in getPositions, or by user
        
        measurementDataFolder = {};
        
        % italian turntable moves clockwise for a positive phi-angle...
        measurementCoordinates_are_itaItalian = true;
    end 
    properties(SetAccess = private, GetAccess = public)
        nApertures = [];                    % set in makeSynthSpeaker
        idxTiltRot2idxFolderFile = cell(0); % set in getPositions
        aperture2idxTiltRotCh = [];         % set in makeSynthSpeaker
        speakerSampling = [];               % set in makeSpeakerSampling
        speakerSampling_basefunctions = [];
        spherical_harmonics_type = [];      % set in makeSynthSpeaker
    end 
    properties(Access = private)
    end 
    methods 
        function this = itaSyntheticDir 
        end
        function set.speaker(this,speak)
            if this.stillempty
                this.speaker = speak;

                if isa(this.speaker, 'itaBalloon') && isempty(this.freqRange) %#ok<MCSUP>
                   this.freqRange = [min(speak.freqVector)*sqrt(2) max(speak.freqVector)/sqrt(2)]; %#ok<MCSUP>
                end
                this.speaker_nmax = min(this.speaker_nmax, speak.nmax); %#ok<MCSUP>
            end
        end
        function set.freqRange(this, value)
            if this.stillempty, this.freqRange = value; end
        end
        function set.nmax(this, value)
            if this.stillempty, this.nmax = value; end
        end
        function set.euler_tilt(this, value)
            if this.stillempty,
                if ~iscell(value)
                    this.euler_tilt = {value};
                else
                    this.euler_tilt = value;
                end
            end
        end
        function set.angle_rot(this, value)
            if this.stillempty,
                if ~iscell(value) 
                    this.angle_rot = {value};
                else
                    this.angle_rot = value;
                end
            end
        end
        function set.measurementDataFolder(this, value)
            if this.stillempty,
                if ~iscell(value)
                    this.measurementDataFolder = {value};
                else
                    this.measurementDataFolder = value;
                end
            end
        end
        
        function set.speaker_channels(this, value)
            if this.stillempty, this.speaker_channels = value; end
        end        
        function set.target_tolerance(this, value)
           this.target_tolerance = -abs(value);
        end
        
        function value = freq2coefSH_synthSpeaker(this, freq, varargin)
            sArgs = struct('nmax',this.speaker_nmax,'channels',1:this.nApertures);
            if nargin > 2
                for idx = 3:nargin
                    if strcmpi(varargin{idx-2},'normalized')
                        outputEqualized = true; 
                        varargin = varargin((1:end) ~= idx-2);
                        break;
                    else
                        outputEqualized = false; 
                    end
                end
                sArgs = ita_parse_arguments(sArgs,varargin);
            else
                outputEqualized = false; 
            end
            
            nC = (sArgs.nmax+1)^2;
            nFreq = numel(freq); 
            
            if  nFreq > this.nMaxPerCalculation
                disp('Warning: This is a big matrix, better split the frequency-Vektor');
            end
            
            idxBlock = this.mux_idxFreq2block(this.freq2idxFreq(freq),:);
            value = zeros(nC, length(sArgs.channels), nFreq);
            
            actBlock = []; 
            for idxF = 1:nFreq
                if isempty(actBlock) || idxBlock(idxF,1) ~= actBlock
                    actBlock = idxBlock(idxF,1);
                    data = this.read([this.folder filesep 'synthSuperSpeaker' filesep 'freqDataSH_' int2str(actBlock)]);
                end
                value(:,:,idxF) = data(1:nC, sArgs.channels, idxBlock(idxF,2)); 
            end
            
            if ~outputEqualized
                if isa(this.speaker, 'itaBalloon') && ~isempty(this.speaker.sensitivity)
                    realChannels = this.aperture2idxTiltRotCh(sArgs.channels,3);
                   value = bsxfun(@times, value, this.speaker.sensitivity.value(realChannels));
                end
            end
        end
        
        function out = coefSH2synthFilter(this,input, varargin)
            sArgs = struct('nmax', this.nmax, 'optimize_freq_range', [], 'freqRange', this.freqRange, 'encoded', false);
            if nargin > 2
                sArgs = ita_parse_arguments(sARgs, varargin);
            end
            
            if length(input) <= 2
                if length(input) == 2
                    input = ita_sph_degreeorder2linear(input(1), input(2));
                end
                coefSH = zeros((this.nmax+1)^2,1);
                coefSH(input) = 1;
            elseif length(input) == (this.nmax+1)^2;
                coefSH = input;
            else
                error(['I need a vector "coefSH" which weights all the ' int2str((this.nmax+1)^2) ' base functions']);
            end
            
            if size(coefSH,1) > size(coefSH,2)
                coefSH = coefSH.';
            end
            if size(coefSH,1) ~= 1
                error('I need a vector, not a matrix');
            end
            
            out = this.freqData2synthesisRule(coefSH, 1, 'optimize_freq_range', sArgs.optimize_freq_range, 'freqRange', sArgs.freqRange, 'encoded',sArgs.encoded);
        end
    end
    methods (Access = private)
        function out = stillempty(this)
            if numel(dir([this.folder filesep 'synthSpeaker' filesep 'freqDataSH_*']))
                error('I can not set this value any more since this object is not empty!!');
            else
                out = true;
            end
        end
        function out = freq_range_intern(this)            
            out = this.freqRange.*[1/sqrt(2) sqrt(2)];            
        end
        
        function out = encodeCoefSH(this, in)
            % in : [idxCoefSH idxRealChannel    idxFreq]
            % out: [idxCoefSH idxEncodedChannel idxFreq]
            if sqrt(size(this.speakerSampling_basefunctions,2))-1 < this.encode_nmax
                disp('must calculate new basefunctions');
                this.makeSpeakerSampling;
            end
            out = zeros(size(in,1), (this.encode_nmax+1)^2, size(in,3));
            for idxF = 1:size(in,3)
               out(:,:,idxF) = in(:,:,idxF)*this.speakerSampling_basefunctions(:,1:(this.encode_nmax+1)^2);
            end
        end
        function out = decodeCoefSH(this, in, maintainedFunctions)
            % in : [idxEncodedChannel idxFreq]
            % out: [idxRealChannel    idxFreq]
            
            out = zeros(size(this.speakerSampling_basefunctions,1), size(in,2), size(in,3));
            for idxN = 1:size(in,3)
                out(:,:,idxN) = this.speakerSampling_basefunctions(:,maintainedFunctions)*in(:,:,idxN);
            end
        end
    end 
end