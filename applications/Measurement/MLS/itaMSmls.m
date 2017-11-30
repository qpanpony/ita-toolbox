classdef itaMSmls < itaMSTF
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % This is a class for Transfer Function or Impulse Response measurements
    %
    % See also: ita_measurement, itaMSSuper, itaMeasurementChain
    
    properties(Access = public, Hidden = true)
        mPermuteVec1           = [];
        mPermuteVec2           = [];
        mRealAverages          = 1;
    end
    
    methods
        
        %% CONSTRUCT / INIT / EDIT / COMMANDLINE
        
        function this = itaMSmls(varargin)
            % itaMSmsl - Constructs an itaMSmsl object.
            if nargin == 0
                
                % For the creation of itaMSmsl objects from commandline strings
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
                % itaMSmsl class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSmsl class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSmsl')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSmsl')
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
                
                for ind = 1:numel(fieldName)
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            else
                error('itaMSmsl::wrong input arguments given to the constructor');
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            addlistener(this,'samplingRate','PostSet',@this.init);
            addlistener(this,'fftDegree','PostSet',@this.init);
            addlistener(this,'outputMeasurementChain','PostSet',@this.initoutput);
        end
        
        function init(this,varargin)
            % init - Initialize the itaMSmsl class object.
            %
            % This function initializes the itaMSmsl class object by
            % deleting its excitation, causing the excitation to be built
            % anew, according to the properties specified in the
            % measurement setup, the next time it is needed.
            
            ita_verbose_info('MeasurementSetup::Initializing...',1)
            this.excitation = itaAudio;
        end
        
        function initoutput(this,varargin)
            % initoutput - Initialize the output.
            %
            % This function initializes the output of the class object, by
            % deleting the final_excitation and compensation, while keeping
            % the excitation. This causes the final_excitation and
            % compensation to be created anew, respecting the output
            % properties specified in the measurement setup.
            
            this.final_excitation = itaAudio;
            this.compensation     = itaAudio;
        end
        
        function this = edit(this)
            % edit - Start GUI.
            %
            % This function calls the itaMSmsl GUI.
            
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
            % measurement chain, deconvolute.
            %
            % This function runs a measurement, regards the input
            % measurment chain and executes the deconvolution, yielding the
            % impulse response without regarding the output measurement
            % chain properties.
            
            %
            this.mRealAverages = this.averages;
            this.averages = 1;
            
            % Get raw data at recording position and max recording level.
            [result, max_rec_lvl] = run_raw_imc(this);
            
            this.averages = this.mRealAverages;
            % Deconvolution with the excitation
            result = this.deconvolve(result);
            
        end
        
        function [result, max_rec_lvl] = run_raw_imc_dec_omc(this)
            % run_raw_imc_dec_omc - Run measurement, regard input
            % measurement chain, deconvolute, regard output measurement
            % chain.
            %
            % This function runs a measurement, regards the input
            % measurement chain, executes the deconvolution and regards the
            % output measruement chain, yielding the fully corrected
            % impulse response.
            
            % Get deconvoluted data at the recording position. The output
            % measurement chain has not been considered, yet.
            [result, max_rec_lvl] = run_raw_imc_dec(this);
            result = result / this.outputamplification_lin;
            result = this.compensateOutputMeasurementChain(result);
        end
        
        function [result, max_rec_lvl] = run(this)
            % run - Run standard measurement.
            %
            % This function runs a full measurement, including all possible
            % corrections (input-, output-measurement chain) as well as the
            % deconvolution. This should be the suitable method for
            % standard transfer function measurements.
            
            [result, max_rec_lvl] = run_raw_imc_dec_omc(this);
            
        end
        
        %% Aux
        function result = deconvolve(this,result)
            % Deconvolution of raw measurement
            
            if ~exist('result','var')
                result = this.excitation;
            end
            
            nMLSsamples = 2^round(this.fftDegree)-1;
            
            %cut presend
            result.timeData = result.timeData(nMLSsamples+1:end, :);
            
            % do averages
            if this.averages > 1
                result.timeData = squeeze(mean(reshape(result.timeData, [nMLSsamples, this.averages result.nChannels]),2));
            end
            
            % permute & add zero
            result.timeData = [zeros(1, result.nChannels); result.timeData(this.mPermuteVec1,:)];
            
            % fast hadamard transformation
            tmpRes = ita_fht(result);
            
            % pemute & drop first sample & add zero
            result.time = [tmpRes(this.mPermuteVec2+1,:) / nMLSsamples ;zeros(1,result.nChannels)];
            % Set signaltype.
            result.signalType = 'energy';
        end
                
        
        %% PLOT
        function plot(this)
            % plot - Plot ideal FRF and IR of excitation * compensation.
            
            excitation = this.excitation;
            if this.lineardeconvolution
                excitation = ita_extend_dat(excitation,2*excitation.nSamples);
            end
            a = this.deconvolve(excitation)/this.outputamplification_lin;
            a.signalType = 'energy';
            a.comment = 'IR of Measurement Setup - excitation*compensation';
            ita_plot_all(a);
        end
        
        
        %% GET / SET
        function set_excitation(this,value)
            if isempty(value)
                this.mExcitation = value;
            else
                value.dataType          = this.precision;
                value.dataTypeOutput    = this.precision;
                this.samplingRate       = value.samplingRate;
                this.fftDegree          = value.fftDegree;
                this.mExcitation        = (value);
                %                 this.mExcitation        = ita_normalize_dat(value);
            end
        end
        
        function res = raw_excitation(this)
            % build the elementary/raw excitation signal
            res = this.mExcitation;
            if isempty(res) %rebuild?
                ita_verbose_info('MeasurementSetup::Generating Excitation Signal...',1);
                
                [this.excitation, this.mPermuteVec1, this.mPermuteVec2] = ita_generate_mls('fftDegree', this.fftDegree, 'samplingRate', this.samplingRate);
                
                res = this.mExcitation; %get the best result
            end
        end
        
        function res = get_final_excitation(this)
            % get the corrected excitation (outputamplification) and
            % calibrated (using outputMeasurementChain) compensation
            if isempty(this.mExcitation)
                res  = this.raw_excitation; %not greater than 0dBFS
                this.mExcitation = res;
            end
            
            tmpExcitation = this.mExcitation;
            tmpExcitation.timeData = repmat(tmpExcitation.timeData, this.mRealAverages +1, 1); % pre-send + averages
            
            res = tmpExcitation * this.outputamplification_lin ;
        end
        
        function res = get_final_compensation(this)
            % get the corrected (outputamplification) and calibrated (using
            % outputMeasurementChain) compensation
            if isempty(this.mFinalCompensation)
                ita_verbose_info('MeasurementSetup::Storing the final calibrated compensation data for you...');
                this.mFinalCompensation = this.compensateOutputMeasurementChain(this.raw_compensation);
            end
            res = this.mFinalCompensation;
            res = res / this.outputamplification_lin;
        end
        
        
        
        %% SAVE / LOAD
        function str = commandline(this)
            % commandline - Generate comandline string.
            %
            % This function creates a commandline string for creating the
            % exact same measurement setup.
            
            str = 'itaMSmsl(';
            
            list = {'fftDegree','freqRange','outputamplification','type','outputChannels','inputChannels','stopMargin','lineardeconvolution','averages','repeats','pause'};
            for idx  = 1:numel(list)
                token = this.(list{idx});
                if isempty(token)
                    continue;
                end
                
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
                end
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
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSmls.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            
        end
        
        % CHECK FOR NEW HARDWARE
        function this = check_for_new_outputhardware(this)
            outputMC = this.outputMeasurementChain;
            nChains = numel(outputMC);
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
            
            this = itaMSmls(sObj);
        end
        
        function result = propertiesSaved
            % propertiesSaved - Creates a list of all the properties to be
            % saved of the current measurement setup.
            %
            % This function gets the list of all
            % properties to be saved during the saving process.
            % Get list of saved properties for this class.
            result = {'mPermuteVec1','mPermuteVec2','mRealAverages'};
        end
    end
    
end