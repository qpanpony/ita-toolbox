classdef itaMSTFinterleaved < itaMSTF
    % This is class for Transfer Function measurements with novel
    % interleaved excitation method.
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % Author: Pascal Dietrich 2011 - pdi@akustik.rwth-aachen.de
    % Modified: Johannes Klein 2011, Bendikt Krechel 2012
    
    properties(Access = protected)
        mTwait          = 0.1;  % Time to wait between sweeps.
        mCommentData    = {};   % Comment data.
        mFinalExcitation = [];  % Final interleaved data
        
        mSkipCrop = 0;
    end
    
    properties(Dependent = true, Hidden = false, Transient = true, SetObservable = true, AbortSet = true)
        twait;        % Time to wait between sweeps.
        skipCrop;
    end
    properties(Dependent = true)
        nWait % samples between two subsequent sweeps
    end
    properties(Dependent = false, Hidden = false, SetObservable = true, AbortSet = true)
        repetitions = 1; % how many times do you want the signal to be played?
    end
    
    methods
        
        %% CONSTRUCT
        
        function this = itaMSTFinterleaved(varargin)
            % itaMSTFinterleaved - Constructs an itaMSTFinterleaved object.
            %
            % This function formally constructs a new itaMSTFinterleaved
            % class object, although it actually only does the exception
            % handling for the case that an input arguemnt is given. The
            % construction of the class object itself is being done by the
            % Matlab class handler, according to the list of properties in
            % this class and its parent class.
            
            % Create itaMSTF class object as base for the
            % itaMSTFinterleaved object.
            %             this = this@itaMSTF(varargin{:});
            
            % Given input arguments have to be structs created with the
            % saveobj method or itaMSTFinterleaved objects.
            if nargin == 1
                
                % Standard itaMSTF objects cannot be converted.
                % Keep in mind  that isa(... 'itaMSTF') will always be true for
                % itaMSTFinterleaved objects, since they are derived from
                % the itaMSTF class, so just testing for that doesn't work
                % too well.
                if isa(varargin{1},'itaMSTF') && ~isa(varargin{1}, 'itaMSTFinterleaved')
                    error('Conversion from itaMSTF to itaMSTFinterleaved is not allowed');
                    
                    % The list of to be saved properties of the given
                    % itaMSTFinterleaved object can be obtained by using the
                    % propertiesSaved method.
                    % Try to copy all the properties over to the new
                    % itaMSTFinterleaved object.
                elseif isa(varargin{1}, 'itaMSTFinterleaved')
                    prop = this.propertiesSaved;
                    for idx = 1:length(prop)
                        this.(prop{idx}) = varargin{1}.(prop{idx});
                    end
                    
                    % The struct created by the saveobj method contains
                    % list of saved properties in its first field.
                    % Since the propertiesSaved field is the first in the save
                    % struct, try to copy all the properties, starting with
                    % element 2 in the list, over to the new itaMSTFinterleaved
                    % object.
                elseif isstruct(varargin{1})
                    varargin{1} = rmfield(varargin{1},'dateSaved');
                    fieldName = fieldnames(varargin{1});
                    for ind = 2:numel(fieldName);
                        try this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg; disp(errmsg);
                        end
                    end
                end
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            addlistener(this,'twait','PreSet',@this.init);
            addlistener(this,'outputChannels','PreSet',@this.init);
            addlistener(this,'repetitions','PreSet',@this.init);
        end
        
        %% INIT
        function init(this,varargin)
            % init - Initialize the itaMSTF class object.
            %
            % This function initializes the itaMSTF class object by
            % deleting its excitation, causing the excitation to be built
            % anew, according to the properties specified in the
            % measurement setup, the next time it is needed.
            
            ita_verbose_info('MeasurementSetup::Initializing...',1)
            this.excitation = itaAudio;
            this.mFinalExcitation = [];
            this.compensation = [];
        end
        
        
        %% SPECIAL PROPERTIES
        
        function set.twait(this, value)
            % set.twait - Set the value of twait.
            %
            % This function sets the value of twait in the current
            % measurement setup. It does not return anything.
            
            this.mTwait = round(value * this.samplingRate) / this.samplingRate;
            
        end
        
        function value = get.twait(this)
            % get.twait - Returns the current value of twait.
            %
            % This function reads out and returns set value of twait, set
            % in the current measurement setup.
            
            value = this.mTwait;
            
        end
        
        function set.skipCrop(this, value)
            % set.skipCrop - Set the value of skipCrop.
            %
            % This function sets the value of skipCrop in the current
            % measurement setup. It does not return anything.
            % skipCrop skips the crop in the run to improve meausrement
            % time
            this.mSkipCrop = value;
            
        end
        
        function value = get.skipCrop(this)
            % get.skipCrop - Returns the current value of skipCrop.
            %
            % This function reads out and returns set value of skipCrop, set
            % in the current measurement setup.
            % skipCrop skips the crop in the run to improve meausrement
            % time
            value = this.mSkipCrop;
            
        end
        
        function value = get.nWait(this)
            % get.nWait - Get number of samples between two subsequent sweeps
            %
            % this is always a vector with the length of output channels-1
            
            value = round(this.twait * this.samplingRate);
            if (numel(value) ~= numel(this.outputChannels)-1 || numel(value) ~= numel(this.outputChannels)) && (numel(this.outputChannels) ~= 1)
                value = repmat(value,numel(this.outputChannels)-1,1);
            end
            
        end
        
        
        %% OPTIMIZATION
        
        function [t_wait, sweeprate] = optimize(this, varargin)
            % This function will optimize t_wait and sweeprate within a
            % given range and given nonlinearities which will lead to the
            % shortest possible measurement duration:
            
            %% INITS
            sArgs = struct('tIR',0.005,'tSpace',0,'tRIR',0.03,...
                'harmonicOrder',5,... %consider up to this harmonic order
                'SNR',80,... %in dB
                'iterationStep',50,... % for twait in samples
                'searchRange', 20 , ... %search for a twait up to searchRange*tRIR
                'mode','cyclic',... %standard or cyclic (excitation length is based on number of output channels)
                'fixedSweepRate',false, ... %fix the sweep rate during optimizing process
                'sweepRateIncrement',0.01,...
                'harmonicDecrease',30,... %each harmonic order is assumed to decrease by this amount of energy in dB
                'harmonicDecreaseVector', [20 20 20 20],... % if this is NOT empty than this values will be used as harmonic decrease!
                'L', 64,... %Number of Loudspeakers, only used in cyclic mode to ensure that only one sweep is played per loudspeaker at the same time!
                'sweeprate_range', [5 10],... % => FFT-degree ~15-16.5
                'freq_range', this.freqRange,...
                'plot', false);
            
            
            %input parsing
            sArgs = ita_parse_arguments(sArgs,varargin);
            
            
            
            % harmonic orders
            if isempty(sArgs.harmonicDecreaseVector)
                o         = 2:1:sArgs.harmonicOrder;
            else
                o = 2:1:length(sArgs.harmonicDecreaseVector)+1;
            end
            
            % starting values
            t_IR     = ceil(sArgs.tIR*this.samplingRate)/this.samplingRate;    % Time between IR and first room reflection.
            t_space  = ceil(sArgs.tSpace*this.samplingRate)/this.samplingRate; % Time between IR and non-lins, right of IR.
            t_RIR    = ceil(sArgs.tRIR*this.samplingRate)/this.samplingRate;   % Timespan of the full RIR.
            
            % define avoid zone (az)
            t_az_start = - t_space;
            t_az_end   = t_IR + t_space;
            
            %sweep_rate_values = 0.1:0.1:60;
            sweep_rate_values = sArgs.sweeprate_range(1):sArgs.sweepRateIncrement:sArgs.sweeprate_range(2);
            % new version 2D -- tWait and Sweep rate loop
            t_wait = t_RIR:(sArgs.iterationStep/this.samplingRate/5):t_RIR*sArgs.searchRange*2;
            
            result2d = zeros(numel(t_wait),numel(sweep_rate_values));
            
            % Assuming the level of the harmonic distrotions
            % decreases by xdB with every order, generate a list of
            % the absolute attenuation of every order.
            if isempty(sArgs.harmonicDecreaseVector)
                HDmax_o  = sArgs.harmonicDecrease * (1:sArgs.harmonicOrder-1) ;
            else
                HDmax_o =  sArgs.harmonicDecreaseVector;
            end
            
            % With the knowledge about the harmonics attenuation, compute the timespan of the non-linearities area up
            % to the to be considered order (till they disappear in noise).
            t_RIR_o   = (sArgs.SNR-HDmax_o) * t_RIR / sArgs.SNR; %pdi: correct: snr1/t1=snr2/t2!
            
            % Check if the duration of the ith harmonic is longer than zero - otherwise
            % the harmonic is already below the threshold...
            t_RIR_valid = t_RIR_o > 0;
            t_RIR_valid_mul = repmat(t_RIR_valid', 1, length(t_wait));
            
            result1d = zeros(numel(sweep_rate_values), 1);
            for idx = 1:numel(sweep_rate_values)
                sweep_rate = sweep_rate_values(idx);
                
                % Get vector of time displacements between the
                % non-liniearity incidences of the regarded orders.
                delta_t     = log2(o)/sweep_rate ;
                
                % start time of the NLIR inside a segment, no time offset anymore!
                startTimeNLIR = bsxfun(@times, mod(-repmat(delta_t.',1,numel(t_wait) )./repmat(double(t_wait),numel(delta_t),1),1) ,t_wait);
                endTimeNLIR   = bsxfun(@plus,startTimeNLIR , t_RIR_o.');
                
                % NLIR start behind avoid zone
                check1a = (startTimeNLIR > t_az_end);
                % check if the harmonic is above noise floor
                check1 = check1a | ~t_RIR_valid_mul;
                
                % NLIR end before next avoid zone starts
                check2a = (endTimeNLIR < repmat((t_az_start + t_wait),numel(delta_t),1));
                % check if the harmonic is above noise floor
                check2 = check2a | ~t_RIR_valid_mul;
                
                %---------------------------------------------
                % Benedikt:
                %---------------------------------------------
                if strcmpi(sArgs.mode, 'cyclic')
                    % calculate sweep time:
                    t_sweep = log2(sArgs.freq_range(2)/sArgs.freq_range(1))/sweep_rate;
                    % now check that two sweeps for one loudspeaker do not overlap:
                    check3 = t_sweep < (sArgs.L * t_wait);
                    result2d(:,idx) = sum( ~check1 ,1) == 0 & sum( ~check2,1 ) == 0 & check3;
                else
                    result2d(:,idx) = sum( ~check1 ,1) == 0 & sum( ~check2,1 ) == 0;
                end
                temp = find(result2d(:,idx), 1, 'first');
                if isempty(temp)
                    result1d(idx) = NaN;
                else
                    result1d(idx) = temp;
                end
            end
            
            if sArgs.plot % Do some plotting:
                figure;
                imagesc(sweep_rate_values,(t_wait),result2d)
                xlabel('sweeprate in oct/sec')
                ylabel('twait in sec')
                title(sprintf('SNR: %d dB, harmonicOrder: %d, harmonicDecrease: %d dB/harmonic', sArgs.SNR, sArgs.harmonicOrder, sArgs.harmonicDecrease))
                set(gca,'Ydir','normal')
                colormap([1 0 0; 0 1 0])
                colorbar off
                figure;
                a = result1d;
                a(isnan(result1d)) = length(t_wait); % for ploting reasons!
                plot(sweep_rate_values, t_wait(a));
                xlabel('sweeprate in oct/sec')
                ylabel('twait in sec')
                title(sprintf('SNR: %d dB, harmonicOrder: %d, harmonicDecrease: %d dB/harm,tRIR: %d tIR:%d tspace:%d', sArgs.SNR, sArgs.harmonicOrder, sArgs.harmonicDecrease, sArgs.tRIR,sArgs.tIR,sArgs.tSpace))
                hold on
                plot(sweep_rate_values, sweep_rate_values*0+sArgs.tRIR,'red')
                ylim([0 0.25])
                
            end
            % Find smallest t_wait in given sweep_rate_range
            lowidx = find(sweep_rate_values==sArgs.sweeprate_range(1));
            highidx = find(sweep_rate_values==sArgs.sweeprate_range(2));
            [t_wait, temp] = min(t_wait(result1d(lowidx:highidx)));
            sweeprate = sweep_rate_values(lowidx+temp-1);
            % Some output:
            ita_verbose_info(['Optimized sweeprate: ' num2str(sweeprate)], 1);
            ita_verbose_info(['Optimized t_wait: ' num2str(t_wait)], 1);
            
            % sweep:
            %             t_sweep     =   log2(20000/50)/sweeprate;
            %             nSamples = round(t_sweep*44100/2)*2;
            % Bugfix Aug 2013, Thanks to Alexander Fuss, Berlin
            t_sweep = log2(this.freqRange(2)/this.freqRange(1))/sweeprate;
            nSamples = round(t_sweep*this.samplingRate/2)*2;
            
            this.twait     = t_wait;
            this.nSamples = nSamples;
            
            this.type = ita_generate_sweep('freqRange',this.freqRange,'bandwidth',this.bandwidth,'sweeprate',sweeprate, 'stopMargin', this.stopMargin);
        end
        
        function [t_wait_vector, sweeprate_new] = optimize_majdak(this, varargin)
            % MESM according to Majdak. Optimization for minimal
            % measurement duration while keeping the SNR constant.
            
            sArgs = struct( 'tRIR'  ,0.03,...
                'harmonicOrder',4,... %consider up to this harmonic order or calculate max. order if 0
                'SNR',80,... %in dB
                'harmonicDecrease',30,... %each harmonic order is assumed to decrease by this amount of energy in dB
                'harmonicDecreaseVector', [30 50 70 90],... % if this is NOT empty than this values will be used as harmonic decrease!
                'L', 64,...
                'freq_range', this.freqRange,...
                'sweeprate', 9.1);
            
            if isempty(sArgs.harmonicDecreaseVector)
                HDmax_o  = sArgs.harmonicDecrease * (1:sArgs.harmonicOrder-1) ;
            else
                HDmax_o =  sArgs.harmonicDecreaseVector;
            end
            
            % With the knowledge about the harmonics attenuation, compute the timespan of the non-linearities area up
            % to the to be considered order (till they disappear in noise).
            t_RIR_o   = (sArgs.SNR-HDmax_o) * sArgs.tRIR / sArgs.SNR; %pdi: correct: snr1/t1=snr2/t2!
            
            
            % MAJDAK-Method:
            T = log2(sArgs.freq_range(2)/sArgs.freq_range(1))/sArgs.sweeprate;
            L1 = sArgs.tRIR;% L1 = Length of the fundamental impulse response
            L2 = t_RIR_o(1);% L2 = Length of the first harmonic impulse response
            
            % According to Majdak: (Paper Equation 14)
            % T_MESM(eta) = 1/ln2 * [eta*L1*(c-ln K) + (L2-L1)/(c-ln K) +
            % N*L1*ln (2K) + (L2+L1)*N*ln(K)/eta
            
            % Optimization for minimal measurement duration: (Paper Equation 15)
            % eta_opt_T = floor( (T*ln(2)/c/L1) + (L1+L2)/L1 )
            %   if L1 >= L2 (this will be the case in normal applications!)
            eta_opt_T = floor( (T*log(2)/sArgs.sweeprate/L1) + (L1+L2)/L1 ) ;
            T_new = ((eta_opt_T-1)*L1 + L2) * sArgs.sweeprate/log2(2);
            if T_new < T
                T_new = T;
            end
            sweeprate_new = log2(sArgs.freq_range(2)/sArgs.freq_range(1))/T_new;
            tau_k_new = log2(sArgs.harmonicOrder)/sweeprate_new;
            number_of_systems = sArgs.L;
            t_wait_vector = L1 * ((1:number_of_systems)-1) + floor(((1:number_of_systems)-1)/ eta_opt_T) * tau_k_new;
        end
        
        
        function result = calculate_excitation(this)
            % this.checkready; % input/output Channels set? jck: Using
            % checkready leads to the problem that the edit menu pops open
            % if the output is defined before the input during the manual
            % initialization in scripts. Workaround (checkready without inputchannel check):
            
            nOutputChannels = length(this.outputChannels);                              % Determine the number of output channels.
            if nOutputChannels == 0
                this.edit;
                nOutputChannels = length(this.outputChannels);
            end
            
            % Set variables
            excitation_raw  = this.raw_excitation;                                      % Call to itaMSTF.raw_excitation. Generates the raw specified excitation signal.
            
            % Maybe put stuff below in get_final_excitation ??
            % Would be better for including the outchan matrix, too.
            % The above would then be the same as get_excitation in itaMSTF.      
            
            
            nWait = this.nWait;
            if numel(nWait) == nOutputChannels
                nWaitSum = sum(nWait); % jri: does this ever happen?
            else
                nWaitSum = sum(nWait) + nWait(end);
            end

            nSamplesStint = excitation_raw.nSamples + nWaitSum;   % Determine total number of samples for one stint through all output channels.
            
            % Create single stint excitation
            excitation_raw = single(ita_extend_dat(excitation_raw, nSamplesStint));             % Extend the raw excitation to total number of stint samples.
            for ch_idx = 1:nOutputChannels
                nWaits = this.nWait(1:ch_idx-1);
                excitation_interleaved_single(ch_idx) = ita_time_shift(excitation_raw, sum([0; nWaits(:)]),'samples');  %#ok<AGROW>
            end
            result = merge(excitation_interleaved_single);       % Merge all 'excitation_interleaves_single' itaAudio objects into one with several channels.
            clear excitation_interleaved_single
            
            % END OLD
            singleTimeData = single(result.timeData).';
            nSamples       = result.nSamples;
            
            % extend result
            result.nSamples = nSamples + nWaitSum * (this.repetitions - 1);
            timeData         = single(result.time).';
            idxx_init        = (1:nSamples);
            ita_verbose_info('itaMSTFinterleaved::appending time data.',1);
            for idx = 2:this.repetitions
                idxx            = idxx_init+nWaitSum * (idx-1);
                timeData(:,idxx) = timeData(:,idxx) + singleTimeData;
            end
            result.time = timeData.';
            
        end
        
        function res = get_final_excitation(this)
            % get the corrected excitation (outputamplification) and
            % calibrated (using outputMeasurementChain) compensation
            if isempty(this.mFinalExcitation)
                res  = this.calculate_excitation; %not greater than 0dBFS
                this.mFinalExcitation = res;
            end
            
            res = this.mFinalExcitation .*  this.pre_scaling .* this.outputamplification_lin;
            
            % if an outputequalization filter is set, convolve it with the
            % excitation
            if ~isempty(this.outputEqualizationFilters)
                  res = ita_convolve(res,this.outputEqualizationFilters,'circular',1);
            end
        end
        
        %% MEASURE NONLINS AND TRIR
        function nonlinearities_level = measure_nonlins(this, varargin)
            % This function will perform a measurement of the room impulse
            % response and the result will be used to optimize the t_wait of
            % the interleaved sweeps.
            
            % Save in- and outputchannels and restore after measurement!
            
            outputvec = this.outputChannels;
            inputvec = this.inputChannels;
            % Use first inputchannel!
            this.inputChannels = inputvec(1);
            % Measure nonlins f???r alle LS einzeln:
            for idx = 1:numel(outputvec)
                this.outputChannels = outputvec(idx);
                nonlinearities = this.run_HD(varargin{:});
                diffs = nonlinearities / nonlinearities.ch(1);
                start_vec = find(diffs.freqVector>200, 1, 'first');
                end_vec = find(diffs.freqVector<10000, 1, 'last');
                level(idx,:) = 20*log10(max(abs(diffs.freqData(start_vec:end_vec,2:end)))); %#ok<AGROW>
            end
            % Find maximum:
            nonlinearities_level = max(level,[],1);
            
            % Restore settings:
            this.outputChannels = outputvec;
            this.inputChannels = inputvec;
            
            
            %nonlinearities_level = reshape(20*log10(max(nonlinearities.timeData)), numel(this.inputChannels), nonlinearities.nChannels/numel(this.inputChannels));
            %nonlinearities_level = repmat(nonlinearities_level(:,1), 1, size(nonlinearities_level,2)-1 )-nonlinearities_level(:,2:end);
        end
        
        %% RUN / CROP
        
        function [result, max_rec_lvl] = run(this)
            % run - Run standard interleaved measurement.
            %
            % This function runs a standard interleaved measurement, using
            % the run_raw_imc_dec function (measurement, input
            % compensation, devoncolution) of its itaMSTF parent class and
            % crops the data, resulting in the expected number of single
            % impulse responses in separate channels.
            
            % Measurement, see itaMSTF class.
            [result, max_rec_lvl] = run_raw_imc_dec(this);
            
            % Cropping.
            if ~this.skipCrop
                result = this.crop(result);
            end    
        end
        
        function [result, max_rec_lvl] = run_separate(this, varargin)
            % run separate - Run standard measurement, but each loudspeaker
            % seperatly - NO INTERLEAVING!
            %
            % Crop (default = true): Crop data to same length as interleaved measurement
            
            sArgs = struct('crop', true);
            sArgs = ita_parse_arguments(sArgs, varargin);
            
            MS = itaMSTF(this);
            MS.init;
            for idx = 1:numel(this.outputChannels)
                MS.outputChannels = this.outputChannels(idx);
                result(idx) = ita_extract_dat(MS.run, round(this.twait*this.samplingRate/2)*2); %#ok<AGROW>
            end
            for idx = 1:numel(this.inputChannels)
                temp(idx) = merge(result.ch(idx)); %#ok<AGROW>
            end
            result = merge(temp);
            if sArgs.crop
                result = ita_extract_dat(result, max(this.nWait) ,'forcesamples', true);
            end
            max_rec_lvl = 0;
        end
        
        function [result] = run_THDN(this, varargin)
            % Run some kind of THD+N-Measurement.
            % Measure interleaved, but turn off one loudspeaker for each measurement. Evaluate
            % energy of the impulse response of the loudspeaker while on (Signal + Harmonic Distortion + Noise)
            % and in the same time slot while loudspeaker is off (Harmonic Distortion + Noise).
            %
            % tIR (default = 5 ms): Length of relevant impulse response
            % (NOT equivalent to length of total impulse response!)
            % tSpace (default = 2 ms): Additional length before and after the
            % relevant impulse response.
            
            sArgs = struct('tIR', 0.005, 'tSpace', 0.002);
            sArgs = ita_parse_arguments(sArgs, varargin);
            reps = this.repetitions;
            this.repetitions = 1;
            % Measure Signal, Distortion and Noise:
            SDN = this.run;
            % Measure Distortion and Noise: (Turn off one loudspeaker each measurement)
            for idx = 1:numel(this.outputChannels)
                this.pre_scaling = [ones(1,idx-1) 0 ones(1, numel(this.outputChannels)-idx)];
                temp = this.run;
                DN(idx) = temp.ch(idx); %#ok<AGROW>
            end
            this.pre_scaling = ones(1,numel(this.outputChannels));
            this.repetitions = reps;
            DN = merge(DN);
            
            % Apply window:
            [~, start_pos] = max(SDN.timeData);
            SDN2 = ita_time_window(SDN, round([start_pos'-sArgs.tSpace*this.samplingRate+1 start_pos'-sArgs.tSpace*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate+1])',@rectwin, 'samples');
            DN2 = ita_time_window(DN, round([start_pos'-sArgs.tSpace*this.samplingRate+1 start_pos'-sArgs.tSpace*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate+1])',@rectwin, 'samples');
            
            % Calculate THD+N:
            result = DN2 / (SDN2-DN2);
        end
        
        function [result] = run_snr(this, varargin)
            % Measure Signal-to-Noise-Ratio. First measure Noise (all
            % Loudspeakers turned off) and then signal level for each
            % loudspeaker seperatly.
            
            % tIR (default = 5 ms): Length of relevant impulse response
            % (NOT equivalent to length of total impulse response!)
            % tSpace (default = 2 ms): Additional length before and after the
            % relevant impulse response.
            
            sArgs = struct('tIR', 0.005, 'tSpace', 0.002);
            sArgs = ita_parse_arguments(sArgs, varargin);
            
            this.pre_scaling = zeros(1,numel(this.outputChannels));
            noise = this.run;
            for idx = 1:numel(this.outputChannels)
                this.pre_scaling = [zeros(1,idx-1) 1 zeros(1, numel(this.outputChannels)-idx)];
                temp = this.run;
                signal(idx) = temp.ch(idx); %#ok<AGROW>
            end
            signal = merge(signal);
            [~, start_pos] = max(signal.timeData);
            signal = ita_time_window(signal, round([start_pos'-sArgs.tSpace*this.samplingRate+1 start_pos'-sArgs.tSpace*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate+1])',@rectwin, 'samples');
            noise = ita_time_window(noise, round([start_pos'-sArgs.tSpace*this.samplingRate+1 start_pos'-sArgs.tSpace*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate start_pos'+(sArgs.tSpace+sArgs.tIR)*this.samplingRate+1])',@rectwin, 'samples');
            result = noise / (signal-noise);
        end
        
        function [result] = run_HD(this, varargin)
            % Measure harmonic distortion for each loudspeaker.
            %
            % Based on run_HD of itaMSTF. Returns a vector of itaAudio with
            % the result for each loudspeaker.
            
            outs = this.outputChannels;
            for idx = 1:numel(outs)
                this.outputChannels = outs(idx);
                result(idx) = this.run_HD@itaMSTF(varargin{:}); %#ok<AGROW>
            end
            this.outputChannels = outs;
        end
        
        function result = crop(this,data)
            % crop - Crop interleaved measurement data.
            %
            % This function crops the multiple impulse responses data of a
            % standard interleaved measurement into single impulse
            % responses in separate channels.
            
            % Read variables.
            %             tic
            %             nSamplesExcitation = this.excitation.nSamples;      % Get total number of samples in excitation (see 'get_excitation').
            %             toc
            nSamplesWait       = this.nWait;                    % Retrieve number of samples to wait between sweeps.
            nOutputChannels = numel(this.outputChannels);
            if numel(nSamplesWait) == numel(this.outputChannels)-1
                nSamplesWait = [nSamplesWait; nSamplesWait(end)];
            end
            %--------------------------------------------------------------
            % Added by Benedikt Krechel, Feb. 2012:
            % Speedup if no output measurement chain compensation needed
            % and all twaits/nWaits are equal:
            
            fast = true;
            for ch_idx = 1:nOutputChannels
                final_response = this.outputMeasurementChain.hw_ch(this.outputChannels(ch_idx)).final_response;
                if ~isa(final_response, 'itaValue')
                    % output measurement chain compensation needed - stop
                    % fast cropping:
                    fast = false;
                    break
                end
            end
            if (min(nSamplesWait) == max(nSamplesWait)) && (fast == true)
                nSamplesWait = nSamplesWait(1);
                % No compensation needed and all twaits are equal:
                result = ita_time_crop(data ,[1 nSamplesWait] ,'samples');
                % jri: changed default output behaviour to multi instance 
                %      this is done to have a consistent behaviour with
                %      each use case of the class
                timeData = reshape(data.timeData(1:nSamplesWait*this.repetitions*nOutputChannels, :),...
                    nSamplesWait, data.nChannels*this.repetitions*nOutputChannels);                
                if (nOutputChannels > 1)
                   resultsMI = itaAudio(1,nOutputChannels);
                   for index = 1:nOutputChannels
                      resultsMI(index) = result;
                      resultsMI(index).timeData = timeData(:,index:nOutputChannels:end);
                      repmatFactor = resultsMI(index).nChannels/result.nChannels;
                      resultsMI(index).channelNames = repelem(result.channelNames,repmatFactor,1);
                      resultsMI(index).channelUnits = repelem(result.channelUnits,repmatFactor,1);
                   end
                   result = resultsMI;
                else
                    result.timeData = timeData;
                end
                return;
            end
            % no speed up possible... do it the slow way:
            %--------------------------------------------------------------
            
            nSamplesWait = repmat(nSamplesWait,this.repetitions,1);
            final_idx          = numel(this.outputChannels) * this.repetitions; % Compute total number of sweeps that has been played back.
            
            % Prepare data for cropping. Extract as many samples from
            % recording data as originally were in the excitation.
            %             data      = ita_extract_dat(data,nSamplesExcitation);
            
            % Memory init / Pre-allocate
            data_part = repmat(ita_time_crop(data ,[1 max(nSamplesWait)] ,'samples'),1,final_idx);
            
            % Up until here data is just a string of impulse responses.
            % Every single IR has to be cut out and saved in a separate
            % channel. Afterwards, the specified time window will be
            % applied.
            
            % TODO: Shift complete IR according to phase information of
            % regarded channel. ;
            % Benedikt: twait/nwait in most cases one value - therefore speedup as explained above possible and this part not executed!
            
            for ch_idx = 1:nOutputChannels
                final_response = this.outputMeasurementChain.hw_ch(this.outputChannels(ch_idx)).final_response;
                if ~isa(final_response, 'itaValue')
                    final_response = ita_extend_dat(final_response, data.nSamples, 'symmetric');
                    currentData = ita_divide_spk(data,final_response,'regularization', this.freqRange).';
                else
                    %force time domain object
                    currentData = data.';
                end
                
                for idx = ch_idx:nOutputChannels:(this.repetitions * nOutputChannels)
                    
                    % Crop data to an interval equal to the number of the wait samples.
                    % Move this interval by the number of wait samples for every loop iteration.
                    data_part(idx).timeData = currentData.timeData((1:nSamplesWait(ch_idx))+sum(nSamplesWait(1:idx-1)),:);
                end
                
                
            end
            
            % Write result.
            result = (data_part); %pdi: no merge
            
        end
        
        function result = compensate_omc(this,data)
            % Compensate measurement chain for multiple outputs
            
            final_idx = 1*length(this.outputChannels);
            result = repmat(itaAudio,1,final_idx);
            for idx = 1:final_idx
                final_response = this.outputMeasurementChain.hw_ch(this.outputChannels(idx)).final_response;
                if ~isa(final_response, 'itaValue')
                    final_response = ita_extend_dat(final_response, data.nSamples, 'symmetric');
                end
                result(idx) = ita_divide_spk(data.ch(idx),final_response,'regularization', this.freqRange);
            end
            
            result = merge(result);
            
        end
        
        %% SAVE/LOAD
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a sturct.
            %
            % This function gets the list of to be saved properties for
            % this measurement class and saves all the according items of
            % the current measurement setup to a struct, which can later
            % be used to create an exact copy of this measurement setup.
            % Even though it is the exact same function as in the parent
            % class, this piece of code is neccessary here, to be able to
            % access the 'm' properties.
            
            % Get list of properties to be saved for this measurement
            % class.
            
            
            sObj = saveobj@itaMSTF(this);
            
            propertylist = itaMSTFinterleaved.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            
        end
        
    end
    
    methods(Static, Hidden = true)
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the basic list of all to be saved
            % properties from its parent class and adds its own special
            % properties to the list, creating the final list of all
            % properties to be saved during the savin process.
            
            
            result = {'mTwait','mCommentData', 'repetitions'};
            
        end
        
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.
            
            this = itaMSTFinterleaved(sObj);
            
        end
        
    end
    
    methods
        
        %% GET/SET
        function set_outputChannels(this, value)
            % set_outputChannels - Sets the output channels.
            %
            % This function sets the output channels of the current
            % itaMSTFinterleaved object to the specified vector.
            % Even though it is the exact same function as in the parent
            % class, this piece of code is neccessary here, to be able to
            % access the mOutputChannels propertiy.
            
            this.mOutputChannels = value; 
        end
    end
end