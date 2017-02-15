classdef itaMSTF < itaMSPlaybackRecord
    % This is a class for Transfer Function or Impulse Response
    % measurements. It directly supports sweep measurements (linear,
    % exponential). The parameters of the measurement can be set
    % comfortably by tweaking the class properties, e.g. output
    % amplification to
    %
    %  Syntax:
    %     MS = itaMSTF();
    %     h  = MS.run;
    %     h.plot_time_dB
    %
    % See also: itaMSPlaybackRecord, itaMSRecord, itaMeasurementChain
    
    % Author: Pascal Dietrich 2010 - pdi@akustik.rwth-aachen.de
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties(Access = public, Hidden = true) % internal variables most controlled by dependent variables
        mCompensation           = []; % compensation for deconvolution
        mFinalCompensation      = []; % finally used for compensation
        mPreemphesis            = []; %not used, yet!
        mType                   = 'exp'; % excitation type
        mBandwidth              = 2/12; % broader freq range used in measurement than requested
        mFinalFreqRange         = []; % this is the final freq range used, lager than requested one
        mPreScaling             = []; % use different levels at different outputs
        invert_phase            = false; % invert the phase of the excitation signal and the compensation, e.g. to suppress even harmonic orders
    end
    
    properties (Hidden = false, Transient = true, AbortSet = true, SetObservable = true)
        ditherType                = 'none';  % rect, tri, white
        nBits                     = 24;      % set quantization of sound card for dithering
        regularization            = true;    % use reg parameter for inversion / deconvolution
        minimumphasedeconvolution = false;   % use ase part for deconvolution -> causal IRs!
        filter                    = false;   % use extra frequency filter for regularization result
    end
    
    properties(Dependent = true, Hidden = false, Transient = true)
        compensation                    % Compensation spectrum for deconvolution. Usually 1/excitation
    end
    
    properties(Dependent = true, Hidden = false, Transient = true, AbortSet = true, SetObservable = true) %triggers @this.init !!!
        type                    % Type of signal 'exp','lin', 'noise', or itaAudio
    end
    
    properties(Dependent = true, Hidden = true, Transient = true, AbortSet = true, SetObservable = true) %triggers @this.init !!!
        bandwidth               % used to extend final frequency range for signal generation
        finalFreqRange          % final frequency range used for signal generation
        pre_scaling;            % Change the output signal individually (not compensated after measurement!)
    end
    
    properties(Dependent = true, Hidden = true, Transient = true, AbortSet = true)
        final_compensation      % Compensation including output spectra (not sensitivites), including norm factor
    end
    
    properties (SetObservable = true, AbortSet = true)
        stopMargin                  = 0.1;       % Time to wait for the system to decay in seconds.
        lineardeconvolution         = false;     % Default:false, commonly circular deconvolution is used. IR has same number of samples as excitation signal.
        shelving                    = [];        % shelving filter as pre-emphasis
        reference                   = [];        % reference spectrum
    end
    
    methods
        
        %% CONSTRUCT / INIT / EDIT / COMMANDLINE
        
        function this = itaMSTF(varargin)
            % itaMSTF - Constructs an itaMSTF object.
            if nargin == 0
                
                % For the creation of itaMSTF objects from commandline strings
                % like the ones created with the commandline method of this
                % class, 2 or more input arguments have to be allowed. All
                % desired properties have to be given in pairs of two, the
                % first element being an identifying string which will be used
                % as field name for the property, and the value of the
                % specified property.
            elseif nargin >= 2
                if ~isnatural(nargin/2)
                    error('Even number of input arguments expected!');
                end
                
                % For all given pairs of two, use the first element as
                % field name, the second one as value. The validity of the
                % field names will NOT be checked.
                for idx = 1:2:nargin
                    this.(varargin{idx}) = varargin{idx+1};
                end
                
                % Only one input argument is required for the creation of an
                % itaMSTF class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSTF class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSTF')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSTF')
                    %The save struct is obtained by using the saveobj
                    % method, as in the case in which a struct is given
                    % from the start (see if-case above).
                    varargin{1} = saveobj(varargin{1});
                    % have to delete the dateSaved field to make clear it
                    % might be from an inherited class
                    varargin{1} = rmfield(varargin{1},'dateSaved');
                end
                if isfield(varargin{1},'dateSaved')
                    varargin{1} = rmfield(varargin{1},'dateSaved');
                    fieldName = fieldnames(varargin{1});
                else %we have a class instance here, maybe a child
                    fieldName = fieldnames(rmfield(this.saveobj,'dateSaved'));
                end
                
                for ind = 1:numel(fieldName);
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            else
                error('itaMSTF::wrong input arguments given to the constructor');
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            addlistener(this,'samplingRate','PostSet',@this.init);
            addlistener(this,'stopMargin','PostSet',@this.init);
            addlistener(this,'fftDegree','PostSet',@this.init);
            addlistener(this,'trackLength','PostSet',@this.init);
            addlistener(this,'freqRange','PostSet',@this.init);
            addlistener(this,'bandwidth','PostSet',@this.init);
            addlistener(this,'finalFreqRange','PostSet',@this.init);
            
            addlistener(this,'ditherType','PostSet',@this.init);
            addlistener(this,'nBits','PostSet',@this.init);
            addlistener(this,'regularization','PostSet',@this.init);
            addlistener(this,'minimumphasedeconvolution','PostSet',@this.init);
            addlistener(this,'filter','PostSet',@this.init);
            
            addlistener(this,'type','PostSet',@this.init);
            addlistener(this,'shelving','PostSet',@this.init);
            addlistener(this,'lineardeconvolution','PostSet',@this.initoutput);
            addlistener(this,'outputMeasurementChain','PostSet',@this.initoutput);
        end
        
        function init(this,varargin)
            % init - Initialize the itaMSTF class object.
            %
            % This function initializes the itaMSTF class object by
            % deleting its excitation, causing the excitation to be built
            % anew, according to the properties specified in the
            % measurement setup, the next time it is needed.
            %             disp('init ms')
            ita_verbose_info('MeasurementSetup::Initializing...',1);
            this.excitation = itaAudio;
            if ~isempty(this.reference)
                this.reference        = [];
                ita_verbose_info('Reference Measurement deleted!',0);
            end
        end
        
        function initoutput(this,varargin)
            % initoutput - Initialize the output.
            %
            % This function initializes the output of the class object, by
            % deleting the final_excitation and compensation, while keeping
            % the excitation. This causes the final_excitation and
            % compensation to be created anew, respecting the output
            % properties specified in the measurement setup.
            ita_verbose_info('MeasurementSetup::Initializing output...',1);
            this.final_excitation = itaAudio;
            this.compensation     = itaAudio;
        end
        
        function this = edit(this)
            % edit - Start GUI.
            %
            % This function calls the itaMSTF GUI.
            
            this = ita_mstf_gui(this);
        end
        
        %% RUN
        function checkready(this)
            %check if the instance is ready for measurement run and ask for
            %missing entries
            if isempty(this.inputChannels) || isempty(this.outputChannels)
                this.edit;
            end
        end
        
        function [result, max_rec_lvl] = run_raw_imc_dec(this)
            % run_raw_imc_dec - Run measurement, regard input
            % measurement chain, deconvolve.
            %
            % This function runs a measurement, regards the input
            % measurment chain and executes the deconvolution, yielding the
            % impulse response without regarding the output measurement
            % chain properties.
            
            % Get raw data at recording position and max recording level.
            [result, max_rec_lvl] = run_raw_imc(this);
            
            % Deconvolution with the excitation
            result = this.deconvolve(result);
            
        end
        
        function [result, max_rec_lvl] = run_raw_imc_dec_omc(this)
            % run_raw_imc_dec_omc - Run measurement, regard input
            % measurement chain, deconvolve, regard output measurement
            % chain.
            %
            % This function runs a measurement, regards the input
            % measurement chain, executes the deconvolution and regards the
            % output measruement chain, yielding the fully corrected
            % impulse response.
            
            % Get deconvolved data at the recording position. The output
            % measurement chain has not been considered, yet.
            [result, max_rec_lvl] = run_raw_imc_dec(this);
            % compensate output
            result = result / this.outputamplification_lin;
            result = this.compensateOutputMeasurementChain(result);
        end
        
        function [result, max_rec_lvl] = run_raw_imc_dec_omc_ref(this)
            % run_raw_imc_dec_omc_ref - Run measurement, regard input
            % measurement chain, deconvolute, regard output measurement
            % chain + optional reference measurement.
            %
            % This function runs a measurement, regards the input
            % measurement chain, executes the deconvolution and regards the
            % output measruement chain, yielding the fully corrected
            % impulse response.
            
            % Get deconvolved data with compensated output at the
            % recording position.
            [result, max_rec_lvl] = run_raw_imc_dec_omc(this);
            if ~isempty(this.reference)
                result = ita_divide_spk( result , this.reference,'regularization',this.freqRange);
            end
        end
        
        function [result, max_rec_lvl] = run(this)
            % run - Run standard measurement.
            %
            % This function runs a full measurement, including all possible
            % corrections (input-, output-measurement chain) as well as the
            % deconvolution + optional reference measurement. This should be the suitable method for
            % standard transfer function measurements.
            
            [result, max_rec_lvl] = run_raw_imc_dec_omc_ref(this);
            
        end
        
        function [result, max_rec_lvl] = run_noEvenHarmonicOrders(this)
            % run_noEvenHarmonicOrders - Run two measurements with opposite
            % phase
            %
            % This suppresses even harmonic orders when measuring a nonlinear system.
            
            [result, max_rec_lvl] = run_raw_imc_dec_omc_ref(this);
            
            this.invert_phase =  ~this.invert_phase; %invert the phase
            [result_inv, max_rec_lvl_inv] = run_raw_imc_dec_omc_ref(this);
            max_rec_lvl = max(max_rec_lvl,max_rec_lvl_inv);
            this.invert_phase =  ~this.invert_phase; %set back to original value
            result = result + result_inv;
            
        end
        
        function [result, max_rec_lvl] = run_autorange(this, type, initialAmp)
            % run_autorange - Set output amplification to its optimum.
            %
            % This function optimizes the output amplification of the
            % current measurement setup. Type 0 is designed for electrical
            % measurements (e.g. calibration, NO SPEAKER ATTACHED!),
            % type 1 regards the THD and thus should be used for acoustical
            % measurements.
            
            ita_verbose_info('Autoranging...',1);
            if ~exist('initialAmp','var')
                this.outputamplification = -50;
            else
                this.outputamplification = initialAmp;
            end
            
            if ~exist('type','var')
                type = 1;
            end
            
            if type == 0
                MS = this.calibrationMS;
                MS.outputamplification = this.outputamplification;
                [result, max_rec_lvl] = run_raw_imc_dec(MS);
                if max_rec_lvl < 10^(-71/20) % no input
                    ita_verbose_info('DA level very low. Input connected?',0);
                elseif max_rec_lvl >= 1 % clipping
                    while max_rec_lvl >= 1
                        MS.outputamplification = floor(20*log10(MS.outputamplification_lin*(10^(-3/20))));
                        [result, max_rec_lvl] = run_raw_imc_dec(MS);
                    end
                end
                % measurement okay
                outputamplification_lin = MS.outputamplification_lin/max_rec_lvl;
                if outputamplification_lin > 1
                    outputamplification_lin = 1;
                end
                this.outputamplification = floor(20*log10(outputamplification_lin*(10^(-3/20))));
            else
                max_rec_lvl = 0;
                linear = 0;
                thd = 1;
                while max_rec_lvl < 0.9 && xor(ge(thd, 0.03),(linear == 1))
                    [result, max_rec_lvl] = run_HD(this);
                    thd = ita_thd(this,result);
                    if lt(max_rec_lvl, 10^(-71/20))
                        ita_verbose_info('DA level very low. Input connected?',0);
                        break;
                    else
                        if max_rec_lvl < 0.9 && ((ge(thd, 0.03) && linear == 0) || lt(thd, 0.03))
                            this.outputamplification = floor(20*log10(this.outputamplification_lin * (10^(5/20))));
                            if lt(thd, 0.03); linear = 1; end
                        else
                            this.outputamplification = floor(20*log10(this.outputamplification_lin * (10^(-5/20))));
                        end
                    end
                end
            end
            
            ita_verbose_info(['New output amplification: ' this.outputamplification],1);
        end
        
        %% Aux
        function result = deconvolve(this,result)
            % Deconvolution of raw measurement result
            resultChNames = result.channelNames;
            if ~exist('result','var')
                result = this.excitation;
            end
            
            % If linear deconvolution is desired, extend result data to
            % number of samples of the final compensation.
            if this.lineardeconvolution
                ita_verbose_info('Using linear deconvolution instead of cyclic.',2)
                result = ita_extend_dat(result,this.final_compensation.nSamples);
            end
            
            % Deconvolution.
            % this.compensation, as well as this.excitation do NOT include
            % ANY output measurement chain compensation.
            if (length(result.timeData) == length(this.compensation.timeData))
                result = result*this.compensation;
            else
                ita_verbose_info('Size does not match. Returning only measured data',0);
            end
            
            % Set signaltype.
            result.signalType = 'energy';
            result.channelNames = resultChNames;
        end
        
        function sweepRate = sweepRate(this,value)
            % get the sweep rate of the excitation
            
            %% sweep rate from analytic calculation, only using sweep parameters / PDI
            nSamples                = ita_nSamples( this.fftDegree );
            finalFreqRange          = this.finalFreqRange;
            % MMT: use nSamples-1 here to be conform with sweep calculation
            % based on timeVector and chirp function
            finalExcitationLength   = (nSamples-1)/this.samplingRate - this.stopMargin;
            sweepRate(1)            = log2(finalFreqRange(2)/finalFreqRange(1))/finalExcitationLength;
            
            %% sweep rate of analysis of excitation signal
            sweepRate(2)    = ita_sweep_rate(this.raw_excitation,[2000 this.samplingRate/3]);
            if exist('value','var')
                sweepRate = sweepRate(value);
            end
        end
        
        function a = idealresponse(this)
            % ideal FRF and IR of excitation * compensation.
            
            excitation = this.excitation;
            if this.lineardeconvolution
                excitation = ita_extend_dat(excitation,2*excitation.nSamples);
            end
            a = excitation * this.compensation;
            a.signalType = 'energy';
            a.comment = 'IR of Measurement Setup - excitation*compensation';
        end
        
        %% PLOT
        function plot(this)
            % plot - Plot ideal FRF and IR of excitation * compensation.
            a = this.idealresponse;
            ita_plot_all(a);
        end
        
        %% Reference
        function run_reference(this)
            this.reference = [];
            this.reference = this.run;
        end
        
        %% GET / SET
        % freqrange
        function res = get.finalFreqRange(this)
            if isempty(this.mFinalFreqRange)
                res = min( [min(this.freqRange(:)) max(this.freqRange(:))] .* 2.^(this.bandwidth * [-1 1])  , this.samplingRate/2);
            else
                res = this.mFinalFreqRange;
            end
        end
        
        function set.finalFreqRange(this,value)
            this.mFinalFreqRange = value;
            this.mBandwidth = 0;
        end
        
        % bandwidth
        function set.bandwidth(this,value)
            this.mBandwidth = value;
            this.mFinalFreqRange = [];
        end
        
        function res = get.bandwidth(this)
            res = this.mBandwidth;
        end
        
        % pre_scaling
        function set.pre_scaling(this,value)
            if ~isempty(value)
                if max(abs(value)) > 1
                    ita_verbose_info('Normalizing pre-scaling for you...',1);
                    value = value / max(abs(value));
                end
                if ~eq(length(value),numel(this.outputChannels))
                    ita_verbose_info('Given vector does not match pre scaling matrix length! Will set all entries to 1...',0);
                    value = [];
                end
            end
            this.mPreScaling = value;
        end
        
        function res = get.pre_scaling(this)
            % used to attenuate some outputchannels or switch phase of them
            if isempty(this.mPreScaling)
                res = ones(1,numel(this.outputChannels));
            elseif ~eq(length(this.outputChannels),length(this.mPreScaling))
                ita_verbose_info('Wrong pre scaling matrix size. Resetting to ones ...',0);
                this.mPreScaling = [];
            else
                res = this.mPreScaling;
            end
        end
        
        function set_excitation(this,value)
            if isempty(value)
                this.mExcitation = value;
            elseif isa(value, 'itaAudio')
                value.dataType          = this.precision;
                value.dataTypeOutput    = this.precision;
                this.samplingRate       = value.samplingRate;
                this.fftDegree          = value.fftDegree;
                this.mExcitation        = ita_normalize_dat(value);
            elseif isa(value, 'char')
                this.type = value;
            else
                error('Unknown type of excitation!')
            end
            this.compensation = itaAudio; %compensation has to take care of that side
        end
        
        function res = raw_excitation(this)
            % build the elementary/raw excitation signal
            res = this.mExcitation;
            if isempty(res) %rebuild?
                ita_verbose_info('MeasurementSetup::Generating Excitation Signal...',1);
                
                if isa(this.type,'itaAudio')
                    this.mExcitation = this.type; %take the given itaAudio
                elseif ischar(this.type)
                    sr         = this.samplingRate;
                    fft_degree = this.fftDegree;
                    
                    switch lower(this.type)
                        case{'exp','lin'}
                            this.excitation = ita_generate_sweep('mode',this.type,'freqRange',this.finalFreqRange,'fftDegree',fft_degree,...
                                'stopMargin',this.stopMargin,'samplingRate',this.samplingRate,'bandwidth',0);
                        case 'noise'
                            noise = ita_generate('noise',1,sr,log2((2^fft_degree) - round(this.stopMargin*this.samplingRate/2)*2));
                            this.excitation = ita_extend_dat(noise,fft_degree);
                        case{'mls'}
                            this.stopMargin = 0; % MMT: have to call before, as this triggers init
                            this.excitation = ita_generate('mls',1,sr,fft_degree);
                        otherwise
                            error('ITA_MSTF::raw_excitation: type of signal not supported')
                    end
                else
                    error('ITA_MSTF::raw_excitation: input for excitation type not supported')
                end
                
                res = this.mExcitation; %get the best result
                
                %% shelving?
                if ~isempty(this.shelving)
                    res = ita_normalize_dat(ita_filter(res,'shelf','low',this.shelving));
                    this.mExcitation = res;
                end
            end
        end
        
        function res = get_final_excitation(this)
            % get the corrected excitation (outputamplification) and
            % calibrated (using outputMeasurementChain) compensation
            if isempty(this.mExcitation)
                res  = this.raw_excitation; %not greater than 0dBFS
                this.mExcitation = res;
            end
            res = this.mExcitation * this.outputamplification_lin * (-1)^double(this.invert_phase);
            
            % apply dithering?
            if ~strcmpi(this.ditherType, 'none')
                res = ita_dither(res,'type',this.ditherType,'nBits',this.nBits(1),'quiet',false);
            end
            
            % if an outputequalization filter is set, convolve it with the
            % excitation
            if ~isempty(this.outputEqualizationFilters)
                  res = res*this.outputEqualizationFilters;
            end
            
        end
        
        function set.compensation(this,value)
            this.mCompensation = value;
            this.mFinalCompensation = [];
        end
        
        function res = get.compensation(this)
            res = get_compensation(this);
        end
        
        function res = get_compensation(this)
            res = this.raw_compensation;
        end
        
        function res = raw_compensation(this)
            % get raw compensation without output amplification correction
            if isempty(this.mCompensation)
                ita_verbose_info('MeasurementSetup::Generating Compensation Signal...',1);
                factor = 1;
                if this.lineardeconvolution
                    factor = 2;
                end
                if this.minimumphasedeconvolution
                    % get minimumphase part of deconvolution, neglect
                    % all-pass component
                    [this.mCompensation, allpass_component] = ita_invert_spk_regularization(ita_extend_dat(this.raw_excitation,this.final_excitation.nSamples*factor),[min(this.freqRange(:)) max(this.freqRange(:))],'filter',this.filter);
                else
                    this.mCompensation = ita_invert_spk_regularization(ita_extend_dat(this.raw_excitation,this.final_excitation.nSamples*factor),[min(this.freqRange(:)) max(this.freqRange(:))],'filter',this.filter);
                end
            end
            res = this.mCompensation;
        end
        
        function set.final_compensation(this,value)
            this.mFinalCompensation = value;
        end
        
        function res = get.final_compensation(this)
            res = get_final_compensation(this);
            res.comment = 'compensation data';
            res.channelNames(:) = {''};
        end
        
        function res = get_final_compensation(this)
            % get the corrected (outputamplification) and calibrated (using
            % outputMeasurementChain) compensation
            if isempty(this.mFinalCompensation)
                ita_verbose_info('MeasurementSetup::Storing the final calibrated compensation data for you...');
                % QUICKFIX: length(this.outputChannels) <= 1 for
                % itaMSTFinterleaved.
                % isa(this.outputMeasurementChain(1).final_response,'itaAudio')
                % + ita_extend_dat to stretch calibration responses to
                % actual fftDegree
                this.mFinalCompensation = this.compensateOutputMeasurementChain(this.raw_compensation);
            end
            res = this.mFinalCompensation;
            res = res / this.outputamplification_lin;
        end
        
        function set.type(this,value)
            this.mType = value;
        end
        
        function res = get.type(this)
            res = this.mType;
        end
        
        %% commandline
        function str = commandline(this)
            % commandline - Generate comandline string.
            %
            % This function creates a commandline string for creating the
            % exact same measurement setup.
            % first get the values from parent class
            parentStr = commandline@itaMSPlaybackRecord(this);
            str = ['itaMSTF' parentStr(20:end-2) ','];
            list = {'type','stopMargin','lineardeconvolution'};
            for idx  = 1:numel(list)
                token = this.(list{idx});
                if isempty(token) || isa(token,'itaSuper')
                    continue;
                end;
                
                if ischar(token)
                    token = ['''' token ''''];
                elseif isnumeric(token) || islogical(token)
                    token = num2str(token);
                    if numel(token) > 1
                        token = ['[' token ']'];
                    end
                else
                    error([upper(mfilename) '.commandline: What kind of field value is this?']);
                end;
                str = [str '''' list{idx} '''' ',' token ];
                
                if idx < numel(list)
                    str = [str ',']; %#ok<*AGROW>
                end
            end
            str = [str ');'];
        end
    end
    
    %% Hidden methods
    methods(Hidden = true)
        function display(this)
            this.excitation; %pre-init
            
            % Begin Display Start Line
            classnameString = ['|' class(this) '|'];
            result = repmat('=',1,itaSuper.LINE_LENGTH);
            result(3:(2+length(classnameString))) = classnameString;
            disp(result);
            % End Display Start Line
            
            % Start Display Values
            disp(['   type       = ' this.type '       samplingRate  = ' num2str(this.samplingRate) '        nSamples      = ' num2str(this.nSamples)])
            oa = repmat(' ',1,7);
            oa_temp = (this.outputamplification);
            oa(1:length(oa_temp)) = oa_temp;
            disp(['   length     = ' num2str(this.excitation.trackLength,5) ' s '  ' level         = ' oa '      freqRange     = [' num2str(this.freqRange(:)') ']  '])
            disp(['   averages   = ' num2str(this.averages) '         repeats       = ' num2str(this.repeats) '            latency       = ' num2str(this.latencysamples)])
            disp(['   output ch. = [' num2str(this.outputChannels) ']       input ch.     = [' num2str(this.inputChannels) ']'])
            % End Display Values
            
            global lastDiplayedVariableName
            lastDiplayedVariableName = inputname(1);
            
            if ita_preferences('dispVerboseFunctions')
                
                display_line4commands({'   MS      ', {'__.edit','.edit'},{'plot(__)','plot ideal IR'},{'builtin(''disp'',__)','Show Inside of Class'},' Level:',{'__ - 5','-5dB'},{'__ - 1','-1dB'},{'__ + 1','+1dB'},{'__ + 5','+5dB'}},lastDiplayedVariableName);
                display_line4commands({'   Measure ', {'__.run','.run'}, {'__.run_raw','.run_raw'}, {'__.run_latency','.run_latency'},{'__.run_reference','.run_reference'}, ...
                    {'__.run_backgroundNoise','.run_backgroundNoise'}, {'__.run_snr','.run_SNR'}},lastDiplayedVariableName);
            else
                display_line4commands({'                                                      ', ...
                    {'ita_preferences(''dispVerboseFunctions'',1); display(__)', 'What to do...?'}}, lastDiplayedVariableName);
            end
        end
        
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSPlaybackRecord(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSTF.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            
        end
        
        % CHECK FOR NEW HARDWARE
        function this = check_for_new_outputhardware(this)
            outputMC = this.outputMeasurementChain;
            nChains  = numel(outputMC);
            isOutput = zeros(nChains,1);
            % only output measurement chains will be handled here
            % input is handled in measurement chain function
            for i = 1:nChains
                isOutput(i) = strcmpi(outputMC(i).type,'output');
            end
            outputMC = outputMC(logical(isOutput));
            nChains = numel(outputMC);
            nNew = 0;
            % go through all measurement chains to search for new devices
            for i = 1:nChains
                chain = outputMC(i);
                hwStr = ['hwch' num2str(chain.hw_ch)];
                for ele = 1:numel(chain.elements)
                    tmp = chain.elements(ele);
                    % do not check the default elements none or unknown
                    if (strcmpi(tmp.name,'none') || strcmpi(tmp.name,'unknown'))
                        continue;
                        % we do not want to enter variable elements
                    elseif ~isempty(strfind(tmp.type,'var'))
                        continue;
                        % for the fix part just adjust the type
                    elseif ~isempty(strfind(tmp.type,'fix')) && ~isempty(strfind(tmp.type,'amp'))
                        tmp.type = 'amp';
                    end
                    if isempty(strfind(tmp.name,hwStr)) && ~strcmpi(tmp.type,'actuator')
                        tmp.name = [tmp.name ' ' hwStr];
                    end
                    devListHandle = ita_device_list_handle;
                    if double(devListHandle(tmp.type,tmp.name)) < 0
                        nNew = nNew + 1;
                        newDevices(nNew) = tmp;
                    end
                end
            end
            
            % if there are new devices ask user whether to add them to the device list
            if nNew > 0
                if nNew == 1
                    guiString = 'You have entered 1 new output device, would you like to add it to the device list';
                else
                    guiString = ['You have entered ' num2str(nNew) ' new output devices, would you like to add them to the device list'];
                end
                choice1 = 'Yes, please';
                choice2 = 'Yes, but calibrate them first';
                choice3 = 'No, thanks';
                choice = questdlg('New devices found!', guiString, ...
                    choice1,choice2,choice3,choice1);
                switch choice
                    case choice1
                        for i = 1:nNew
                            ita_add_hardware_to_devicelist(newDevices(i));
                        end
                    case choice2
                        iMCCalibrated = zeros(numel(this.inputMeasurementChain),1);
                        for i = 1:numel(this.inputMeasurementChain)
                            iMCCalibrated(i) = this.inputMeasurementChain(i).calibrated;
                        end
                        if ~all(iMCCalibrated)
                            this = calibrate(this);
                        else
                            this = calibrate_output(this);
                        end
                        this = check_for_new_hardware(this);
                    otherwise
                        
                end
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.
            
            this = itaMSTF(sObj);
        end
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the list of all
            % properties to be saved during the saving process.
            
            % Get list of saved properties for this class.
            result = {'mCompensation','mPreScaling','mFinalCompensation', 'stopMargin', 'mPreemphesis','mType','mFinalFreqRange','mBandwidth'};
        end
    end
    
end