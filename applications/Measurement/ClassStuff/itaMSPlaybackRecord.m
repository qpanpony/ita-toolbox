classdef itaMSPlaybackRecord < itaMSRecord
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % This is a class for playing back and recording at the same time, but
    % without deconvolution
    %
    % See also: ita_measurement, itaMSRecord, itaMeasurementChain
    
    properties(Access = public, Hidden = true)
        mOutputamplification    = -40;
        mExcitation             = [];
        mOutputChannels         = [];
        mOutputMeasurementChain = itaMeasuringStation.loadCurrentOutputMC; %itaMeasurementChain('output');
        
        mOutputEqualizationFilters = [];
    end
    
    properties(Dependent = true, Hidden = false, Transient = true)
        outputamplification             % Attenuation factor of the output signal in dBFS (Fullscale)
        excitation                      % itaAudio containing the excitation signal, for this class. 1 channel.
    end
    
    properties(Dependent = true, Hidden = false, Transient = true, AbortSet = true, SetObservable = true) %triggers @this.init !!!
        outputChannels          % Vector specifying the output channel IDs e.g. [1 5]
        outputMeasurementChain  % itaMeasurementChain('output') defining all output measurement chain elements
        
        outputEqualizationFilters = []; % these filters are convolved with the excitation signal, but not the compensation
    end
    
    properties(Dependent = true, Hidden = true, Transient = true, AbortSet = true)
        outputamplification_lin % Linear factor from dBFS 'outputamplification' for multiplication
        final_excitation        % Excitation including compensation of relative output sensitivites/spectra - number of channels equal outputMC
        outputVoltage           % used to set outputamplification for a calibrated output chain
    end
    
    properties (Hidden = false, Transient = true, AbortSet = true, SetObservable = true)
        latencysamples  = 0;    % number of samples (positive integer) used to compensate the delay of the AD/DA conversion
    end
    
    properties (SetObservable = true, AbortSet = true)
        outputEqualization  = false;
    end
    
    methods
        
        %% CONSTRUCT / INIT / EDIT / COMMANDLINE
        
        function this = itaMSPlaybackRecord(varargin)
            % itaMSPlaybackRecord - Constructs an itaMSPlaybackRecord object.
            if nargin == 0
                
                % For the creation of itaMSPlaybackRecord objects from commandline strings
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
                % itaMSPlaybackRecord class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSPlaybackRecord class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSPlaybackRecord')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSPlaybackRecord')
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
                error('itaMSPlaybackRecord::wrong input arguments given to the constructor');
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            
            % not needed here, only in classes inherited from this one
        end
        
        function this = edit(this)
            % edit - Start GUI.
            %
            % This function calls the itaMSPlaybackRecord GUI.
            
            this = ita_msplaybackrecord_gui(this);
        end
        
        %% CALIBRATION
        
        function this = calibrate(this)
            % this will guide you thru the calibration process
            this = calibrate_input(this);
            % outputMeasurementChain
            this = calibrate_output(this);
        end
        
        function MS = calibrationMS(this)
            % Generates a simple Measurement Setup for calibration purposes.
            saveStruct = saveobj(this);
            % delete all fields that itaMSTF cannot handle
            % this is important when calling from inherited classes
            fieldNames = fieldnames(saveStruct);
            classFields = [itaMSRecord.propertiesSaved itaMSPlaybackRecord.propertiesSaved itaMSTF.propertiesSaved 'dateSaved'];
            additionalFields = fieldNames(~cellfun(@(x) any(strcmpi(classFields,x)),fieldNames));
            if ~isempty(additionalFields)
                saveStruct = rmfield(saveStruct,additionalFields);
            end
            
            saveStruct.mExcitation = itaAudio(); % erase excitation so it will be rebuilt
            saveStruct.mNSamples = 2^15;
            saveStruct.mType = 'exp';
            saveStruct.stopMargin = min(0.3,2^14/this.samplingRate); % for high sampling frequencies
            saveStruct.mOutputamplification = -50;           % Low amplification, to be safe. Will be autoranged later.
            saveStruct.mFreqrange = [1 this.samplingRate/2]; % Full range for calibration.
            saveStruct.applyBandpass = 0;
            saveStruct.pause = 0;                           % no pause for calibration
            MS = itaMSTF(saveStruct);                     % Init new MSTF object.
        end
        
        function this = calibrate_output(this,input_chain_number)
            % Calibrates all output chains, using only the first
            % (hopefully calibrated) input chain. Input chain calibration
            
            if ~exist('input_chain_number','var')
                input_chain_number = find(this.inputMeasurementChain.hw_ch == this.inputChannels(1));
            end
            ita_verbose_info(['Calibrating using input channel ' num2str(this.inputMeasurementChain(input_chain_number).hardware_channel)],1);
            
            MS = this.calibrationMS;            % Get new simple Measurement Setup for calibration. See above.
            mco = this.outputMeasurementChain;    % Get all output measurement chains.
            outChannels = this.outputChannels;    % Get all output channels.
            
            % The calibration of the multiple output measurement chains /
            % outout channels will be executed one-by-one.
            for outIdx = 1:numel(outChannels)
                chIdx = find(mco.hw_ch == outChannels(outIdx)); % Return single index of entry in 'mco', equal to the out channel, which is to be calibrated.
                MS.outputMeasurementChain = mco(chIdx);         % Set Measurement Setup's single output chain to match the one, which is to be calibrated.
                MS.outputChannels = outChannels(outIdx);        % Set Measurement Setup's single output channel to match the one, which is to be calibrated.
                
                % Execute calibration for every single element in the
                % current output measurement chain.
                % 'ita_mstfoutput_calibration' determines if the object can
                % be calibrated at all.
                for ele_idx = 1:length(mco(chIdx).elements)
                    MS = ita_measurement_chain_output_calibration(MS,input_chain_number,ele_idx);
                end
                
                % if there was no latency info before, copy it from the
                % calibrationMS because latency was measured in the output
                % calibration routine
                if this.latencysamples == 0
                    this.latencysamples = MS.latencysamples;
                end
                % Put the current calibrated measurement chain back into
                % its appropriate position in the list of all output
                % measurment chains.
                mco(chIdx) = MS.outputMeasurementChain;
            end
            this.outputMeasurementChain = mco;          % Copy over the list of all calibrated output measurement chains into the real Measurement Setup.
        end
        
        %% RUN
        function checkready(this)
            %check if the instance is ready for measurement run and ask for
            %missing entries
            if isempty(this.inputChannels) || isempty(this.outputChannels) || isempty(this.excitation)
                this.edit;
            end
            
        end
        
        function [result, max_rec_lvl] = run_raw(this)
            % run_raw - Run measurement
            this.checkready;
            singleprecision = strcmpi(this.precision,'single'); % Bool for single precision for portaudio.
            
            result = ita_portaudio(this.final_excitation,'InputChannels',this.inputChannels, ...
                'OutputChannels', this.outputChannels,'repeats',1,...
                'latencysamples',this.latencysamples,'singleprecision',singleprecision,'reset', this.reset);
            
            if this.outputVoltage ~= 1 % only if output is calibrated
                result.comment = [result.comment ' @' num2str(round(this.outputVoltage*1000)/1000) 'Vrms'];
            end
            max_rec_lvl = max(abs(result.timeData),[],1);
            
        end
        
        function [result, max_rec_lvl] = run(this)
            % run - Run standard measurement.
            %
            % This function runs a measurement, and compensates for the
            % input measurement chain. If the output is calibrated, the
            % output voltage will be stored in the comment, but it will
            % not be compensated for.
            
            [result, max_rec_lvl] = run_raw_imc(this);
            if this.applyBandpass
                result = ita_mpb_filter(result,this.freqRange,'zerophase');
            end
        end
        
        function [result, max_rec_lvl] = run_backgroundNoise(this)
            % run_backgroundNoise - Run simple background noise
            % measurement.
            %
            % This function runs a measurement with -500dBFS
            % outputamplification to measure the background noise.
            
            original_outputamplification = this.outputamplification;
            this.outputamplification = -500;
            [result, max_rec_lvl] = run_raw_imc(this);
            this.outputamplification = original_outputamplification;
        end
        
        function [result, max_rec_lvl] = run_raw_imc_omc(this)
            % run_raw_imc_omc - Run raw and compensate both input and output.
            
            [result, max_rec_lvl] = run_raw_imc(this);
            result = result / this.outputamplification_lin;
            result = compensateOutputMeasurementChain(this,result);
        end
        
        function [result, max_rec_lvl] = run_latency(this)
            % run_latency - Run measurement and determine the latency
            % samples.
            %
            % This function runs a not input/output measurement chain
            % compensated measurement, does the deconvolution itself,
            % analyzes the resulting impulse response and sets the latency
            % samples in the measurement setup. It returns the not
            % compensated impulse response and max recording level.
            
            ita_verbose_info('Measuring latency samples...',1);
            
            MS = this.calibrationMS;
            MS.inputChannels = MS.inputChannels(1);
            ita_verbose_info(['Using channel ' num2str(MS.inputChannels) ' for latency measurement'],1);
            MS.outputamplification = this.outputamplification;
            
            MS.latencysamples = 0;
            
            [result, max_rec_lvl] = run_raw(MS);
            result = result * MS.compensation / MS.outputamplification_lin;
            result.signalType = 'energy';
            
            [maxamplitude, lsamples]  = max(abs(result.timeData),[],1);      % Get the measurement's max absolute amplitude and exact sample position of max amplitude for each channel.
            [maxamplitude, idx] = max(maxamplitude); %#ok<ASGLU>
            
            lsamples = lsamples(idx) - 1;                               % Get the max of all position samples of all channels ans substract 1, to prevent anti-causal impuls responses.
            
            if (~isempty(lsamples) && lt(lsamples, 0)) || isempty(lsamples) % If result would be acausal... suppress it!
                ita_verbose_info('Could not find a suitable impulse! Try a higher output amplification.',0);
                this.latencysamples = [];
            else
                this.latencysamples = lsamples;
            end
            
        end
        
        function [result,signal,noise] = run_snr(this,fraction)
            % run noise and signal and compare
            if nargin < 2
                fraction = 3;
            end
            ita_verbose_info('Recording noise level for SNR',1);
            noise   = this.run_backgroundNoise;
            N       = ita_spk2frequencybands(noise,'bandsperoctave',fraction,'freqRange',[min(this.freqRange(:)) max(this.freqRange(:))]);
            ita_verbose_info('Recording signal level for SNR',1);
            signal  = this.run_raw_imc;
            sig     = sqrt(abs(signal')^2 - abs(noise')^2);
            S       = ita_spk2frequencybands(sig,'bandsperoctave',fraction,'freqRange',[min(this.freqRange(:)) max(this.freqRange(:))]);
            result  = S/N;
            result.comment = ['Signal-to-Noise Ratio in 1/' num2str(fraction) ' octave bands'];
        end
        
        %% Aux
        function result = compensateOutputMeasurementChain(this,result)
            % Apply the output measurement chain and the output
            % amplification to the result. It only makes sense to apply the
            % final response of the output measurement chain if only one
            % channel has been used during the measurement (no MIMO
            % calibration possible, here).
            if ~isempty(this.outputMeasurementChain)
                if length(this.outputChannels) <= 1
                    outChannel = this.outputChannels;
                    if this.outputEqualization && isa(this.outputMeasurementChain.hw_ch(outChannel).final_response,'itaAudio')
                        omc = this.outputMeasurementChain.hw_ch(outChannel);
                        final_response = ita_extend_dat(omc.final_response, this.fftDegree, 'symmetric');
                        omcTypes = {omc.elements.type};
                        lsIdx = find(strcmpi(omcTypes,'loudspeaker'));
                        if ~isempty(lsIdx) && ~isempty(omc.elements(lsIdx).response) % Houston, we have a Loudspeaker
                            % better use smaller freqRange, if LS is included
                            % lower frequency of 1 would lead to very high amplification
                            final_response = ita_smooth_notches(final_response,'bandwidth',1,'squeezeFactor',0.3);
                            outputFilter = ita_invert_spk_regularization(final_response,this.finalFreqRange,'filter');
                        else % otherwise just electrical
                            outputFilter = ita_invert_spk_regularization(final_response,[1 this.samplingRate/2],'filter');
                        end
                        outputFilter.channelNames(:) = {''};
                        result = result*outputFilter;
                    else
                        final_response = this.outputMeasurementChain.hw_ch(outChannel).sensitivity;
                        result = result/final_response;
                    end
                else
                    ita_verbose_info('Too many output channels. Output chain compensation not possible',0);
                end
            end
        end
        
        %% PLOT
        function plot(this)
            % plot - Plot ideal FRF and IR of excitation * compensation.
            
            ita_plot_all(this.excitation);
        end
        
        %% GET / SET
        % outputamplification
        function set.outputamplification(this,value)
            if ischar(value)
                value = str2num(value(~isstrprop(value,'alpha'))); %#ok<ST2NM>
            end
            this.mOutputamplification = -abs(value);
        end
        
        function res = get.outputamplification(this)
            res = [num2str(round(this.mOutputamplification)),'dBFS'];
        end
        
        function res = get.outputamplification_lin(this)
            res = 10^(this.mOutputamplification/20);
        end
        
        function plus(this,value)
            % increase output amplification
            this.outputamplification = min(this.mOutputamplification +  value,0);
            disp(['Output amplification: ' this.outputamplification]);
        end
        
        function minus(this,value)
            % decrease output amplification
            plus(this,-value);
        end
        
        function set.outputVoltage(this,value)
            if numel(this.outputChannels) ~= 1
                ita_verbose_info('Multiple output channels, selecting the one with maximum gain',0);
                [dummy,idx] = max(double(this.outputMeasurementChain.hw_ch(this.outputChannels).sensitivity('loudspeaker')));
                omc = this.outputMeasurementChain.hw_ch(this.outputChannels(idx));
            else
                omc = this.outputMeasurementChain.hw_ch(this.outputChannels);
            end
            if ~omc.calibrated || omc.sensitivity.value == 1
                ita_verbose_info('The outputMeasurementChain is not calibrated, this makes no sense then',1);
                ita_verbose_info('Leaving outputamplification unchanged',0);
            else
                outSens = omc.sensitivity('loudspeaker');
                this.outputamplification = 20*log10(abs(double(value/(this.raw_excitation.rms*outSens))));
            end
        end
        
        function res = get.outputVoltage(this) % including outputamplification
            omc = this.outputMeasurementChain.hw_ch(this.outputChannels);
            for iCh = 1:numel(omc)
                if ~omc(iCh).calibrated || double(omc(iCh).sensitivity) == 1
                    ita_verbose_info('The outputMeasurementChain is not calibrated, this makes no sense then',1);
                    res = 1;
                    return;
                end
            end
            
            outSens = double(omc.sensitivity('loudspeaker'));
            res = this.raw_excitation.rms*this.outputamplification_lin.*outSens;
        end
        
        function set.excitation(this,value)
            set_excitation(this,value);
        end
        
        function set_excitation(this,value)  %trick to overload in derivatives
            if isempty(value)
                error('itaMSPlaybackRecord::I cannot play empty signals');
            elseif isa(value,'itaAudio')
                value.dataType          = this.precision;
                value.dataTypeOutput    = this.precision;
                this.samplingRate       = value.samplingRate;
                this.fftDegree          = value.fftDegree;
                this.mExcitation        = ita_normalize_dat(value);
            else
                error(['itaMSPlaybackRecord::what kind of playback signal is this (class is: ' class(value) ')']);
            end
        end
        
        function res = get.excitation(this)
            % get final excitation
            res = this.final_excitation;
        end
        
        function res = raw_excitation(this)  %trick to overload in derivatives
            % build the elementary/raw excitation signal
            res = this.mExcitation;
        end
        
        function set.final_excitation(this,value)
            this.mExcitation = value;
        end
        
        function res = get.final_excitation(this)
            res = get_final_excitation(this); %trick to overload in derivatives
        end
        
        function res = get_final_excitation(this)
            % get the corrected excitation (outputamplification)
            res = this.raw_excitation * this.outputamplification_lin ;
            
            % if an outputequalization filter is set, convolve it with the
            % excitation
            if ~isempty(this.outputEqualizationFilters)
                res = res*this.outputEqualizationFilters;
            end
        end
        
        function set.outputChannels(this,value)
            if ~all(ismember(value,this.outputMeasurementChain.hw_ch))
                % pdi: this works as hell! ask joe for any comments
                this.mOutputChannels = value;
                newChannels = value(~ismember(value,this.outputMeasurementChain.hw_ch));
                % if the output chain is empty create a new one
                if numel(this.outputMeasurementChain) == 1 && this.outputMeasurementChain.hw_ch == 0
                    if this.useMeasurementChain
                        this.outputMeasurementChain = ita_measurement_chain_output(newChannels);
                    else % create an empty dummy chain
                        dummyChain = itaMeasurementChain(numel(newChannels));
                        for iCh = 1:numel(newChannels)
                            dummyChain(iCh).type = 'output';
                            dummyChain(iCh).hardware_channel = newChannels(iCh);
                        end
                        this.outputMeasurementChain = dummyChain;
                    end
                    % otherwise add new channels
                else
                    if this.useMeasurementChain
                        this.outputMeasurementChain = [this.outputMeasurementChain ita_measurement_chain_output(newChannels)];
                    else % create an empty dummy chain
                        dummyChain = itaMeasurementChain(numel(newChannels));
                        for iCh = 1:numel(newChannels)
                            dummyChain(iCh).type = 'output';
                            dummyChain(iCh).hardware_channel = newChannels(iCh);
                        end
                        this.outputMeasurementChain = [this.outputMeasurementChain dummyChain];
                    end
                end
                this.mOutputChannels = value;
            else
                this.mOutputChannels = value;
            end
            set_outputChannels(this,value);
        end
        
        function set_outputChannels(this,value)
            this.mOutputChannels = value;
            if ~isempty(this.outputEqualizationFilters)
                if (this.outputEqualizationFilters.nChannels ~= 1)
                   this.outputEqualizationFilters = [];
                   ita_verbose_info('Output Equalization Filter are removed!',0);
                end
            end
        end
        
        function res = get.outputChannels(this)
            res = this.mOutputChannels;
        end
        
        function set.outputMeasurementChain(this,value)
            this.mOutputMeasurementChain = value;
        end
        
        function res = get.outputMeasurementChain(this)
            res = this.mOutputMeasurementChain;
        end
        
        
        function set.outputEqualizationFilters(this,value)
            
            if isempty(value)
                this.mOutputEqualizationFilters = value;
                return
            end
            
            if ~isa(value,'itaAudio')
                error('Not an itaAudio. Doing nothing');
            end
            
            if value.nChannels ~= 1 & value.nChannels ~= size(this.outputChannels)
                error('The number of channels of the filter does not fit the number of the output channels');
            end
            this.mOutputEqualizationFilters = value;
        end
        
        function res = get.outputEqualizationFilters(this)
            res = this.mOutputEqualizationFilters;
        end
        
        
        %% commandline
        function str = commandline(this)
            % commandline - Generate comandline string.
            %
            % This function creates a commandline string for creating the
            % exact same measurement setup.
            % first get the values from parent class
            parentStr = commandline@itaMSRecord(this);
            str = ['itaMSPlaybackRecord' parentStr(12:end-2) ','];
            list = {'fftDegree','freqRange','outputamplification','latencysamples','outputEqualization','outputChannels'};
            for idx  = 1:numel(list)
                token = this.(list{idx});
                if isempty(token)
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
            % Begin Display Start Line
            classnameString = ['|' class(this) '|'];
            result = repmat('=',1,itaSuper.LINE_LENGTH);
            result(3:(2+length(classnameString))) = classnameString;
            disp(result);
            % End Display Start Line
            if ~isempty(this.excitation)
                commentStr = this.excitation.comment;
                if length(commentStr) > 10
                    commentStr = [commentStr(1:7) '...'];
                else
                    commentStr = [commentStr, repmat(' ',1,10-length(commentStr))];
                end
                trackLength = this.excitation.trackLength;
            else
                commentStr = 'empty';
                trackLength = 0;
            end
            
            % Start Display Values
            disp(['   excitation = ' commentStr ' samplingRate  = ' num2str(this.samplingRate) '        nSamples      = ' num2str(this.nSamples)])
            oa = repmat(' ',1,7);
            oa_temp = (this.outputamplification);
            oa(1:length(oa_temp)) = oa_temp;
            disp(['   length     = ' num2str(trackLength,5) ' s '  ' level         = ' oa '      freqRange     = [' num2str(this.freqRange(:)') ']  '])
            disp(['   averages   = ' num2str(this.averages) '          repeats       = ' num2str(this.repeats) '            latency       = ' num2str(this.latencysamples)])
            disp(['   output ch. = [' num2str(this.outputChannels) ']        input ch.     = [' num2str(this.inputChannels) ']'])
            % End Display Values
            
            global lastDiplayedVariableName
            lastDiplayedVariableName = inputname(1);
            
            if ita_preferences('dispVerboseFunctions')
                
                display_line4commands({'   MS      ', {'__.edit','.edit'},{'plot(__)','plot excitation'},{'builtin(''disp'',__)','Show Inside of Class'},' Level:',{'__ - 5','-5dB'},{'__ - 1','-1dB'},{'__ + 1','+1dB'},{'__ + 5','+5dB'}},lastDiplayedVariableName);
                display_line4commands({'   Measure ', {'__.run','.run'}, {'__.run_raw','.run_raw'}, {'__.run_latency','.run_latency'}, ...
                    {'__.run_backgroundNoise','.run_backgroundNoise'}, {'__.run_snr','.run_SNR'}},lastDiplayedVariableName);
            else
                display_line4commands({'                                                      ', ...
                    {'ita_preferences(''dispVerboseFunctions'',1); display(__)', 'What to do...?'}}, lastDiplayedVariableName);
            end
        end
        
        
        function this = force_calibration(this)
            %set all measurement chain components to status: 'calibrated'
            this.inputMeasurementChain  = this.inputMeasurementChain.force_calibration;
            this.outputMeasurementChain = this.outputMeasurementChain.force_calibration;
        end
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSRecord(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSPlaybackRecord.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            this = itaMSPlaybackRecord(sObj); % Just call constructor, he will take care
        end
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the list of all
            % properties to be saved during the saving process.
            
            % Get list of saved properties for this class.
            result = {'mOutputamplification', 'mOutputChannels','mOutputMeasurementChain','mExcitation','latencysamples','outputEqualization'};
        end
    end
    
end