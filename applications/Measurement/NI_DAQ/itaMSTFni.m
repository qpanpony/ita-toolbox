classdef itaMSTFni < itaMSTF
    % This is a class for Transfer Function or Impulse Response
    % measurements with a National Instruments (NI) DAC using the DAQ toolbox.
    % It supports everything that the regular itaMSTF class does, so see that for
    % more info.
    %
    % Specific to this class: the NI setup is done with the Data
    % Acquisition Toolbox, and changes to the channel setup have to be
    % monitored and the NI session has to be updated accordingly.
    %
    % See also: itaMSTF
    
    % Author: Markus Mueller-Trapet 2017 - markus.mueller-trapet@nrc.ca
    
    properties(Access = public, Hidden = true) % internal variables
        niSession = []; % to store information about NI card setup
    end
    
    methods
        
        %% CONSTRUCT / INIT / EDIT / COMMANDLINE
        
        function this = itaMSTFni(varargin)
            % itaMSTFni - Constructs an itaMSTFni object.
            if nargin == 0
                
                % For the creation of itaMSTFni objects from commandline strings
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
                % itaMSTFni class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSTFni class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSTF')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSTF')
                    %The save struct is obtained by using the saveobj
                    % method, as in the case in which a struct is given
                    % from the start (see if-case above).
                    if isa(varargin{1},'itaMSTFni')
                        deleteDateSaved = true;
                    else
                        deleteDateSaved = false;
                    end
                    varargin{1} = saveobj(varargin{1});
                    % have to delete the dateSaved field to make clear it
                    % might be from an inherited class
                    if deleteDateSaved
                        varargin{1} = rmfield(varargin{1},'dateSaved');
                    end
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
                error('itaMSTFni::wrong input arguments given to the constructor');
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change in the below specified
            % properties.
            addlistener(this,'samplingRate','PostSet',@this.init);
            addlistener(this,'inputChannels','PostSet',@this.init);
            addlistener(this,'outputChannels','PostSet',@this.init);
        end
        
        function init(this,varargin)
            % init - Initialize the itaMSTFni class object.
            % call the parent init function first
            init@itaMSTF(this);
            
            % then run the NI card initialization
            this.niSession = init_NI_card(this);
        end
        
        function MS = calibrationMS(this)
            % call the parent function
            MS = calibrationMS@itaMSTF(this);
            % convert to instance of this class
            MS = itaMSTFni(MS);
            % release NI hardware to enable measurement with calibrationMS
            this.niSession.release;
        end
        
        function [result, max_rec_lvl] = run_raw(this)
            % run_raw - Run measurement
            this.checkready;
            singleprecision = strcmpi(this.precision,'single'); % Bool for single precision for portaudio.
            
            result = ita_NI_daq_run(this.final_excitation,this.niSession,'InputChannels',this.inputChannels, ...
                'OutputChannels', this.outputChannels,'repeats',1,...
                'latencysamples',this.latencysamples,'singleprecision',singleprecision);
            
            if this.outputVoltage ~= 1 % only if output is calibrated
                result.comment = [result.comment ' @' num2str(round(this.outputVoltage*1000)/1000) 'Vrms'];
            end
            max_rec_lvl = max(abs(result.timeData),[],1);
        end
        
        function [result, max_rec_lvl] = run_latency(this)
            % call parent function
            [result, max_rec_lvl] = run_latency@itaMSTF(this);
        end
        
        function this = calibrate_input(this,elementIds)
            % have to do this here because of different run function
            % do only specific elements (e.g. only AD)
            if ~exist('elementIds','var')
                elementIds = 1:3;
            else
                elementIds = unique(min(3,max(1,elementIds)));
            end
            % and only active channels
            inputChannels = this.inputChannels;
            imcIdx = zeros(numel(inputChannels),1);
            for chIdx = 1:numel(inputChannels)
                imcIdx(chIdx) = find(this.inputMeasurementChain.hw_ch == inputChannels(chIdx));
            end
            tmpChain = this.inputMeasurementChain(imcIdx);
            % element by element
            for iElement = elementIds
                for iCh = 1:numel(imcIdx)
                    this.inputChannels = inputChannels(iCh);
                    if numel(tmpChain(iCh).elements) >= iElement
                        hw_ch = tmpChain(iCh).hardware_channel;
                        disp(['Calibration of sound card channel ' num2str(hw_ch)])
                        % go thru all elements of the chain and calibrate
                        if tmpChain(iCh).elements(iElement).calibrated ~= -1 % only calibratable devices
                            disp(['   Calibration of ' upper(tmpChain(iCh).elements(iElement).type) '  ' tmpChain(iCh).elements(iElement).name])
                            this.inputChannels = inputChannels(iCh);
                            [tmpChain(iCh).elements(iElement).sensitivity] = measurement_chain_elements_calibration_ni(this.niSession,tmpChain(iCh),iElement); %calibrate each element
                        end
                    end
                end
            end
            this.inputMeasurementChain(imcIdx) = tmpChain;
            this.inputChannels = inputChannels;
            disp('****************************** FINISHED *********************************')
        end
        
        function this = calibrate_output(this,input_chain_number)
            % have to do this here because of different run function
            % Calibrates all output chains, using only the first
            % (hopefully calibrated) input chain. Input chain calibration
            if ~exist('input_chain_number','var')
                input_chain_number = find(this.inputMeasurementChain.hw_ch == this.inputChannels(1));
            end
            ita_verbose_info(['Calibrating using input channel ' num2str(this.inputMeasurementChain(input_chain_number).hardware_channel)],1);
            
            MS = this.calibrationMS;   % Get new simple Measurement Setup for calibration. See above.
            MS.inputChannels = MS.inputChannels(input_chain_number);
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
                    MS = measurement_chain_output_calibration_ni(MS,input_chain_number,ele_idx);
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
            % release hardware for the standard object
            MS.niSession.release;
        end
        
        function [niSession,Channels] = init_NI_card(this,sens)
            % uses Christoph Hoellers's (hoellerc@nrc.ca) code for initilaization of NI session
            % for now only as simple DAC, so only Voltage type
            if nargin < 2
                sens = 0.01;
            end
            
            % create channel data from MS
            Channels = struct();
            Channels.name = {'IN1','IN2','IN3','IN4'};
            Channels.type = {'Voltage','Voltage','Voltage','Voltage'};
            Channels.sensitivity = sens.*ones(1,4);
            Channels.isActive = ismember(1:4,this.inputChannels);
            
            % Initialization
            niDevices	= daq.getDevices();	% returns an object with all the NI cards
            niSession	= daq.createSession('ni');
            nDevice		= length(niDevices);
            nChannels   = 4 ; %NI cDAQ-9178 and NI USB-4431 has 4 input channels per module/system
            
            % If everything else fails, use these default settings
            if (~exist('Channels','var')) || ~(nDevice == size(Channels.isActive,1))
                for iDevice = 1:nDevice
                    for iChannel = 1:nChannels
                        Channels.isActive(iDevice,iChannel)	= 0;
                        Channels.name{iDevice,iChannel} = niDevices(iDevice).Subsystems(1).ChannelNames{iChannel,1};
                        Channels.type{iDevice,iChannel}			= 'Voltage';
                        Channels.sensitivity(iDevice,iChannel)	= sens;
                    end
                end
            end
            
            warning('off','daq:Session:clockedOnlyChannelsAdded') % turn off useless warning
            
            % Add analog input channels
            for iDevice = 1:nDevice
                for iChannel = 1:nChannels
                    if Channels.isActive(iDevice,iChannel)
                        niSession.addAnalogInputChannel(get(niDevices(iDevice),'ID'),iChannel-1,Channels.type{iDevice,iChannel});
                        niSession.Channels(end).Name = Channels.name{iDevice,iChannel};
                        % set to AC coupling to get rid of large DC offset
                        niSession.Channels(end).Coupling = 'AC';
                        %                         if any(strcmpi(Channels.type{iDevice,iChannel},{'Accelerometer' 'Microphone'}))
                        %                             niSession.Channels(end).Sensitivity = Channels.sensitivity(iDevice,iChannel);
                        %                         end
                    end
                end
            end
            
            % Add analog output channel (for now, only one)
            if ~isempty(this.outputChannels)
                niSession.addAnalogOutputChannel(get(niDevices(1),'ID'),0,'Voltage');
                if numel(this.outputChannels) > 1 || any(this.outputChannels > 1)
                    warning('Currently only one output channel supported');
                end
            end
            
            % set sampling rate
            niSession.Rate = this.samplingRate;
            
        end % function
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSTF(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSTFni.propertiesSaved;
            
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
            
            this = itaMSTFni(sObj);
        end
    end
    
end % classdef

%% subfunctions
function varargout = measurement_chain_elements_calibration_ni(niSession,MC,element_idx,oldSens,oldReference)
% calibration routine for input elements using the NI hardware (ita_NI_daq_run)
% otherwise identical to ita_measurement_chain_elements_calibration (except ModulITA, Aurelio etc.)
MCE = MC(1).elements(element_idx);
if ~exist('oldSens','var')
    oldSens = MCE.sensitivity_silent;
end

hw_ch = MC(1).hardware_channel;
preamp_var = false;
switch(lower(MCE.type))
    case {'sensor'}
        sInit.Reference = '94';
        sInit.Unit = 'dB re Pa';
    case {'preamp','ad','preamp_robo_fix'}
        sInit.Reference = '1';
        sInit.Unit = 'V';
    case ('preamp_var')
        preamp_var = true;
    case ('none')
        varargout(1) = {1};
        return
    otherwise
        error(['which element type is this - ' lower(MCE.type)]);
end

if exist('oldReference','var')
    sInit.Reference = oldReference;
end

old_sens_str = [' {old: ' num2str(oldSens) '}'];

%% GUI
pList = [];

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = ['Calibrating: ' upper(MCE.type) '::' MCE.name '::'  'Hardware Channel: ' num2str(hw_ch) '...'];

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

calibrated_str = '';
if  MCE.calibrated == 0
    calibrated_str = '(UNCALIBRATED)';
end

if preamp_var
    ele = numel(pList)+1;
    pList{ele}.description = 'Ext. Preamp Gain [dB]'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'External gain of preamp, e.g. BK Type 2610'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 20*log10(double(MCE.sensitivity_silent)); %default value, could also be empty, otherwise it has to be of the datatype specified above
else
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = ['Current Sensitivity: ' num2str(MCE.sensitivity) ' ' calibrated_str  old_sens_str];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.description = ['Reference [' num2str(sInit.Unit) ']']; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Reference voltage or sound pressure level'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = sInit.Reference; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Sampling Rate [Hz]'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Sampling Rate'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ita_preferences('samplingRate'); %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.description = 'Length [s]'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Time to wait for the calibration to be finished'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 2; %default value, could also be empty, otherwise it has to be of the datatype specified above
end

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

%call GUI
if preamp_var
    pList = ita_parametric_GUI(pList,['Ext. Preamp Gain: ' MCE.type '::' MCE.name ' - hwch: ' ...
        num2str(hw_ch)]);
    if isempty(pList)
        varargout{1} = MCE.sensitivity;
    else
        varargout{1} = 10^(pList{1}/20);
    end
    return;
else
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Settings for Calibration Device';
    
    pList = ita_parametric_GUI(pList,['Calibration: ' MCE.type '::' MCE.name ' - hwch: ' num2str(hw_ch)],'buttonnames',{'Accept','Calibrate'});
end

if isempty(pList)
    ita_verbose_info(['Accepting sensitivity for ' MCE.type ' - ' MCE.name ' - hwch: ' num2str(hw_ch)],1)
    varargout{1} = MCE.sensitivity;
    return;
end

%% Initialization
%default init struct
oldSens = MCE.sensitivity;
sInit.Channel       = hw_ch;
if strcmpi(sInit.Unit,'V')
    sInit.Reference = itaValue(pList{1},'V');
else
    sInit.Reference = itaValue(10^(pList{1}/20)*2e-5,'Pa');
end
sInit.samplingRate = pList{2};
sInit.length = pList{3}*sInit.samplingRate;

%% Measurement
% record data
signalRecord = ita_NI_daq_run(sInit.length,niSession,'inputchannels',sInit.Channel,'samplingRate',sInit.samplingRate);
signalRecord = ita_filter_bandpass(signalRecord,'lower',20,'zerophase',false);
signalRecord = signalRecord / MC(1).sensitivity(MCE.type); % compensation of rest

%% Evaluate
calibrationDomain = ita_preferences('calibrationDomain');
if ~(strcmpi(calibrationDomain,'time') || strcmpi(calibrationDomain,'frequency'))
    error('ita_measurement_chain_elements_calibration: Unknown calibration mode. Please set calibration mode in ita_preferences->ExpertSettings to either ''Time'' or ''Frequency''!');
end

validCalibFreqs = ita_preferences('calibrationFrequencies');
if numel(validCalibFreqs)==0 || any(validCalibFreqs<0)
    error('ita_measurement_chain_elements_calibration: No valid calibration Frequency defined. Please set list of valid calibration frequencies in ita_preferences->ExpertSettings!');
end

calibFreqTolerance = ita_preferences('calibrationFrequencyTolerance');
if ~isnumeric(calibFreqTolerance) || ~isfinite(calibFreqTolerance) || calibFreqTolerance<0
    error('ita_measurement_chain_elements_calibration: Invalid calibration frequency tolerance. Please set calibration frequency tolerance  in Cent (Default 100) in ita_preferences->ExpertSettings!');
end

if strcmpi(calibrationDomain,'time')
    nBlocks = 5;
    % Signal Segmentation
    for idxBlock = 1:nBlocks
        signalSegment(idxBlock) = ita_time_crop(signalRecord,[((idxBlock-1)*signalRecord.nSamples/nBlocks+1),(idxBlock*signalRecord.nSamples/nBlocks)],'samples'); %#ok<AGROW>
        signalSegment(idxBlock).comment = ['Block number ' num2str(idxBlock)]; %#ok<AGROW>
    end
    signalSegment = signalSegment.merge;
    
    % Test single blocks for correct frequency
    % in case of low battery or bad signal, the frequency will change
    signalTimeWindow = ita_time_window(signalSegment, ...
        [round(0.5*signalSegment.nSamples), 1, ...
        round(0.5*signalSegment.nSamples)+1, signalSegment.nSamples], ...
        'samples',@hann); % multiply with window before FFT
    freq_vec = signalTimeWindow.freqVector;
    rmsVals  = signalSegment.rms;
    % look for maxMagnitude and its frequency -> should be somewhere near
    % calibration frequency; if not, don't consider block for sensitivity calculation
    [dummy,maxFrequencyIdx] = max(abs(signalTimeWindow.freq),[],1); %#ok<ASGLU>
    maxFrequency = freq_vec(maxFrequencyIdx);
    idxRMSValid = 0;
    validBlock = zeros(nBlocks,1);
    for idxBlock = 1:nBlocks
        ita_verbose_info(['maxFrequency of block number :' num2str(idxBlock) ': ' num2str(maxFrequency(idxBlock)) 'Hz'],1)
        validBlock(idxBlock) = any((maxFrequency(idxBlock) > (validCalibFreqs*2.^(-calibFreqTolerance/1200))) & (maxFrequency(idxBlock) < (validCalibFreqs*2.^(calibFreqTolerance/1200))));
        if validBlock(idxBlock)==0
            ita_verbose_info('Invalid frequency detected',0);
        else % Calculate rms value for each valid block
            idxRMSValid = idxRMSValid+1;
            rmsValid(idxRMSValid) = rmsVals(idxBlock); %#ok<AGROW>
        end
    end
    ita_verbose_info(['Number of valid blocks: ' num2str(idxRMSValid)],2)
    
    % Take Median as most representative value
    % check first if enough blocks have been verified as valid
    if idxRMSValid == 0
        signalRecord.channelNames{1} = 'CALIBRATION FAILED::INPUT SIGNAL LOOKS LIKE THIS!';
        ita_plot_time(signalRecord);
        ita_verbose_info('Signal does not have any of the allowed calibration frequencies.',0);
        SensValid = MCE.sensitivity;
    elseif idxRMSValid <= round(nBlocks/2)
        ita_verbose_info('Measurement might not be accurate. Bad signal.',1);
        SensValid = itaValue(median(rmsValid),signalRecord.channelUnits{1})/sInit.Reference;
    else
        SensValid = itaValue(median(rmsValid),signalRecord.channelUnits{1})/sInit.Reference;
    end
    
elseif strcmpi(calibrationDomain,'frequency')
    str = num2cell(validCalibFreqs);
    ok = 0;
    while ~ok
        [selection,ok] = listdlg('PromptString','Select a calibration frequency:',...
            'SelectionMode','single',...
            'ListString',str);
        if ok
            freqStart = validCalibFreqs(selection)*2^(-calibFreqTolerance/1200);
            freqStop  = validCalibFreqs(selection)*2^(+calibFreqTolerance/1200);
            
            % look for maxMagnitude and its frequency -> should be somewhere near
            % the chosen calibration frequency; if not, give out warning
            freq_vec = signalRecord.freqVector;
            [dummy,maxIdx] = max(abs(signalRecord.freqData),[],1); %#ok<ASGLU>
            maxFrequency = freq_vec(maxIdx);
            ita_verbose_info(['Frequency with highest Amplitude in recorded signal :' num2str(maxFrequency) 'Hz'],1)
            if (maxFrequency < freqStart) || (maxFrequency > freqStop)
                ita_verbose_info('Oh dear, the signal at you''re calibration frequency is not the strongest component in your signal. I hope you know what you''re doing!',0);
                ita_plot_freq(signalRecord)
            end
            
            % Calculate RMS at calibration frequency and consider leakage
            calibValues = signalRecord.freq2value(freqStart,freqStop); % make row vector
            calibRMS = sqrt(calibValues' * calibValues);
            SensValid = itaValue(calibRMS,signalRecord.channelUnits{1})/sInit.Reference;
        else
            disp('ita_measurement_chain_elements_calibration: Please choose a calibration frequency!');
        end
    end
end

MC(1).elements(element_idx).sensitivity = SensValid;
SensValid = measurement_chain_elements_calibration_ni(niSession,MC,element_idx,oldSens,pList{1});

varargout(1) = {SensValid};
end % function

function MS = measurement_chain_output_calibration_ni(MS,input_chain_number,ele_idx,old_sens)
% calibration routine for output elements using the NI hardware (ita_NI_daq_run)
% otherwise identical to ita_measurement_chain_output_calibration (except ModulITA, Aurelio etc.)
if ~exist('old_sens','var')
    old_sens_str = '';
else
    old_sens_str = [' {old: ' num2str(old_sens) '}'];
end

sensFactor = 1;
MC = MS.outputMeasurementChain(1); %always get the latest measurement chain to be on the safe side

if MC.elements(ele_idx).calibrated ~= -1
    %% GUI
    pListExtra = {};
    
    MCE = MC.elements(ele_idx);
    if any(strfind(lower(MCE.name),'robo')) || any(strfind(lower(MCE.type),'robo'))
        default_output2input = 'preamp';
    elseif ismember(MCE.type,{'actuator'})
        default_output2input = 'sensor';
    elseif ismember(MCE.type,{'loudspeaker'})
        default_output2input = 'sensor';
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Distance to Loudspeaker [m]'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'distance in meters'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'double'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = 1; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Microphone on the floor?'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'semi-anechoic chamber, microphone on the floor'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Window start time[s]'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'starting time of symmetrical window function'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = 0.05; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.description = 'Window end time[s]'; %this text will be shown in the GUI
        pListExtra{ele}.helptext    = 'end time of symmetrical window function'; %this text should be shown when the mouse moves over the textfield for the description
        pListExtra{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
        pListExtra{ele}.default     = 0.1; %default value, could also be empty, otherwise it has to be of the datatype specified above
        
        ele = numel(pListExtra)+1;
        pListExtra{ele}.datatype    = 'line';
    else
        default_output2input = 'ad';
    end
    hw_ch = MC.hardware_channel;
    
    pList = [];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = ['Calibrating: ' upper(MCE.type) '::' MCE.name '::'  'Hardware Channel: ' num2str(hw_ch) '...'];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    calibrated_str = '';
    if  MCE.calibrated == 0
        calibrated_str = '(UNCALIBRATED)';
    end
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = ['Current Sensitivity: ' num2str(MCE.sensitivity) ' ' calibrated_str  old_sens_str];
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    ele = numel(pList)+1;
    pList{ele}.description = 'output2input'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Output is connected to this element'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.list        = 'ad|preamp|sensor';
    pList{ele}.default     = default_output2input; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.description = 'outputamplification'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'in dBFS'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = MS.outputamplification; %default value, could also be empty, otherwise it has to be of the datatype specified above
    
    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';
    
    pList = [pList pListExtra];
    
    %call GUI
    pList = ita_parametric_GUI(pList,['Calibration: ' MCE.type '::' MCE.name ' - hwch: ' num2str(hw_ch)],'buttonnames',{'Accept','Calibrate'});
    
    if isempty(pList)
        ita_verbose_info(['Accepting sensitivity for ' MCE.type ' - ' MCE.name ' - hwch: ' num2str(hw_ch)],1)
        MC.elements(ele_idx).sensitivity = MCE.sensitivity; %set sensitivity
        MS.outputMeasurementChain = MC;
        return;
    else
        output2input = pList{1};
        MS.outputamplification = pList{2};
        
        %% measurement
        %try to get the sensitivity of the chain. modulita and robo could
        %be uninitialized
        old_sens = MCE.sensitivity;
        
        MS.inputChannels = MS.inputMeasurementChain(input_chain_number).hardware_channel;
        %TODO: Create latency vector
        if MS.latencysamples == 0
            MS.run_latency;
        end
        % for electrical measurements, get best SNR with autoranging
        if ~strcmpi(output2input,'sensor')
            MS.run_autorange(0,pList{2});
        end
        
        inputChannels = MS.inputChannels;
        outputChannels = MS.outputChannels;
        samplingRate = MS.samplingRate;
        final_excitation = MS.final_excitation;
        latencysamples = MS.latencysamples;
        
        % measure TF
        a = ita_NI_daq_run(final_excitation,MS.niSession,'InputChannels',inputChannels, ...
            'OutputChannels', outputChannels,'latencysamples',latencysamples,'samplingRate',samplingRate);
        
        a = a * MS.compensation / MS.outputamplification_lin;
        a.signalType = 'energy';
        
        if ~isempty(pListExtra)
            %% compensation of distance
            distance = itaValue(pList{3},'m');
            travel_time = distance / ita_constants('c');
            
            a = ita_time_shift(a,-double(travel_time),'time');
            a = a * distance;
            
            %% floor compensation
            if pList{4}
                a = ita_amplify(a,'-6dB');
            end
            
            %% time windowing
            a = ita_time_window(a,[pList{5} pList{6}],'time','symmetric');
            
        end
        
        %% get FRF up to this point
        frf_upto = MC.response(lower(MC.elements(ele_idx).type));
        if ~isempty(frf_upto)
            a = a*ita_invert_spk_regularization(frf_upto,[1 MS.samplingRate/2],'filter');
        end
        
        %% get sensitivity of element around 1kHz
        value = itaValue ( mean(abs(a.freq2value(950:1050))) , a.channelUnits{1});
        MC.elements(ele_idx).response = a / value;
        switch lower(output2input)
            case {'ad'}
                value = value / sensFactor / MS.inputMeasurementChain(input_chain_number).sensitivity('preamp') ...
                    / MS.outputMeasurementChain.sensitivity(MCE.type);
                
            case {'preamp'}
                value = value / sensFactor / MS.inputMeasurementChain(input_chain_number).sensitivity('sensor')...
                    / MS.outputMeasurementChain.sensitivity(MCE.type);
                
            case {'sensor'}
                value = value / sensFactor / MS.inputMeasurementChain(input_chain_number).sensitivity()...
                    / MS.outputMeasurementChain.sensitivity(MCE.type);
            otherwise
                error('element type unknown')
        end
        
        MC.elements(ele_idx).sensitivity = value;
        MS.outputMeasurementChain = MC;
    end
    MS = measurement_chain_output_calibration_ni(MS,input_chain_number,ele_idx,old_sens);
end
end % function
