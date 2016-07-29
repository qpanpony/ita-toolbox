classdef itaMSTFaurelio < itaMSTF

% <ITA-Toolbox>
% This file is part of the application RoboAurelioModulITAControl for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    % This is a class for Transfer Function or Impulse Response measurements
    %
    % See also: ita_measurement, itaMeasurementChain
    
    methods
        
        %% CONSTRUCT / INIT / EDIT / COMMANDLINE
        function this = itaMSTFaurelio(varargin)
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
               if isa(varargin{1},'itaMST')
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
            addlistener(this,'freqRange','PostSet',@this.init);
            addlistener(this,'bandwidth','PostSet',@this.init);
            addlistener(this,'finalFreqRange','PostSet',@this.init);
            addlistener(this,'type','PostSet',@this.init);
            addlistener(this,'shelving','PostSet',@this.init);
            addlistener(this,'lineardeconvolution','PostSet',@this.initoutput);
            addlistener(this,'outputMeasurementChain','PostSet',@this.initoutput);
        end
        
    %% RUN
        function [result, max_rec_lvl] = run_raw(this)
            % run_raw - Run measurement
            
            singleprecision = strcmpi(this.precision,'single'); % Bool for single precision for portaudio.
            
            if this.samplingRate > 96000
                samplingRate = this.samplingRate / 2;
                if any(this.inputChannels) > 4
                    this.inputChannels = this.inputChannels(this.inputChannels <= 4);
                    ita_verbose_info('Only four input channels with this samplingRate, taking care of that');
                end
                
                if any(this.outputChannels) > 4
                    this.outputChannels = this.outputChannels(this.outputChannels <= 4);
                    ita_verbose_info('Only four output channels with this samplingRate, taking care of that');
                end
                
                inputChannels = [this.inputChannels  4+this.inputChannels];
                outputChannels = [this.outputChannels  2+this.outputChannels];
                final_excitation = this.final_excitation;
                
                final_excitation.timeData = [final_excitation.timeData(1:2:end,:) final_excitation.timeData(2:2:end,:)];
                
                final_excitation.samplingRate = samplingRate;
                latencysamples = this.latencysamples/2;
                if ~isnatural(latencysamples)
                    ita_verbose_info('Warning, your latencysettings do not make sense, willl remeasure latency',0);
                    this.run_latency;
                    latencysamples = this.latencysamples/2;
                end
            else
                inputChannels = this.inputChannels;
                outputChannels = this.outputChannels;
                samplingRate = this.samplingRate;
                final_excitation = this.final_excitation;
                latencysamples = this.latencysamples;
            end
            
            result = ita_portaudio(final_excitation,'InputChannels',inputChannels, ...
                'OutputChannels', outputChannels,'repeats',1,...
                'latencysamples',latencysamples,'singleprecision',singleprecision,'reset', this.reset,'samplingRate',samplingRate);
            
            
            if this.samplingRate > 96000
                for idx = 1:numel(this.inputChannels)
                    res(idx) = merge(result.ch(idx) , result.ch(idx+numel(this.inputChannels)));
                    tmp = (res(idx).time.');
                    res(idx).time = tmp(:);
                    res(idx).samplingRate = this.samplingRate;
                end
                result = res.merge;
            end
            
            max_rec_lvl = max(abs(result.timeData),[],1);
                    
        end
        
        function MS = calibrationMS(this)
            % Generates a simple Measurement Setup for calibration purposes.
            saveStruct = saveobj(this);
            % delete all fields that itaMSTF cannot handle
            % this is important when calling from inherited classes
            fieldNames = fieldnames(saveStruct);
            classFields = [itaMSRecord.propertiesSaved itaMSPlaybackRecord.propertiesSaved itaMSTF.propertiesSaved];
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
            MS = itaMSTFaurelio(saveStruct);                     % Init new MSTF object.
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
            
            % for sampling rates higher than 96000, latency is still
            % determined by half the sampling rate, e.g. 96k for 192k
            
            ita_verbose_info('Measuring latency samples...',1);
            
            MS = this.calibrationMS;
            if MS.samplingRate > 96000
                latencyFactor = 2;
                MS.samplingRate = MS.samplingRate/2;
            else
                latencyFactor = 1;
            end
            
            MS.inputChannels = MS.inputChannels(1);
            ita_verbose_info(['Using channel ' num2str(MS.inputChannels(1)) ' for latency measurement'],1);
            MS.outputamplification = this.outputamplification;
            
            MS.latencysamples = 0;
            
            [result, max_rec_lvl] = run_raw(MS);
            result = result * MS.compensation;
            
            [maxamplitude, lsamples]  = max(abs(result.timeData),[],1);      % Get the measurement's max absolute amplitude and exact sample position of max amplitude for each channel.
            [maxamplitude, idx] = max(maxamplitude); %#ok<ASGLU>
            
            lsamples = lsamples(idx) - 1;                               % Get the max of all position samples of all channels ans substract 1, to prevent anti-causal impuls responses.
            
            if (~isempty(lsamples) && lt(lsamples, 0)) || isempty(lsamples) % If result would be acausal... suppress it!
                ita_verbose_info('Could not find a suitable impulse! Try a higher output amplification.',0);
                this.latencysamples = [];
            else
                this.latencysamples = lsamples*latencyFactor;
            end
        end
  
        
    %% SAVE / LOAD
        function str = commandline(this)
            % commandline - Generate comandline string.
            %
            % This function creates a commandline string for creating the
            % exact same measurement setup.

            str = 'itaMSTF(';
            
            list = {'fftDegree', 'freqRange','outputamplification','type','outputChannels','inputChannels','stopMargin','lineardeconvolution','averages','repeats','pause'};
            for idx  = 1:numel(list)
                token = this.(list{idx});
                if isempty(token)
                    continue;
                end;
                
                if ischar(token) 
                    token = ['''' token ''''];
                elseif isnumeric(token) || islogical(token)
                    if numel(token) > 1
                        token = ['[' num2str(token) ']'];
                    else
                        token = num2str(token);
                    end
                else
                    error('what is this')
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
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSTF(this);
        end 
    end
    
    methods(Static, Hidden = true)
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the list of all
            % properties to be saved during the saving process.
            
            % Get list of saved properties for this class.
            result = {};
        end       
        
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.

            this = itaMSTFaurelio(sObj);
        end        
                
    end
    
end 