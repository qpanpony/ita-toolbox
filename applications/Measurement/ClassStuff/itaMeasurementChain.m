classdef itaMeasurementChain
    % Definition of the components of a measurement chain channel. Could be
    % used for input (sensor, preamp, AD) or output (DA, amp, actuator)
    %
    % See also: itaMSRecord etc., itaMeasurementChainElements,
    %            ita_measurement
    
    % Author: Pascal Dietrich - 2010 - pdi@akustik.rwth-aachen.de
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties
        name        = ''; %description of this channel of the measurement chain
        elements    = itaMeasurementChainElements; %itaMeasurementChainElements describing the elements in order of appearance
        type        = 'input'; %could be 'input' or 'output'
        coordinates = itaCoordinates(); %Coordinate of this sensor or actuator
    end
    properties(Hidden = true)
        orientation      = itaCoordinates(); % TODO %??
        userdata         = [];%what ever you want to put here
        hardware_channel = 0; %this is the actual hardware channel of the soundcard
    end
    properties(Dependent = true, Hidden = false)
        calibrated %is the channel calibrated? -1: not calibratable
    end
    methods
        %% constructor
        function this = itaMeasurementChain(varargin)
            % Constructor:
            %  MC = itaMeasurementChain() - empty Obj
            %  MC = itaMeasurementChain(ChannelSettingsStruct) - convert
            %                   old channel settings
            switch nargin
                case 0
                    % no input given, make an empty object
                case 1
                    if isa(varargin{1},'itaMeasurementChain')
                        this = varargin{1};
                    elseif isnumeric(varargin{1}) %make measurement chain
                        for idx =1:varargin{1}
                            this(idx) = itaMeasurementChain; %#ok<AGROW>
                            this(idx).hardware_channel = idx; %#ok<AGROW>
                        end
                    elseif ischar(varargin{1})
                        this.type = varargin{1};
                    elseif isstruct(varargin{1}) && isfield(varargin{1},'elements')
                        MCold = varargin{1};
                        propertylist = itaMeasurementChain.propertiesSaved;
                        for idx = 1:numel(propertylist)
                            this.(propertylist{idx}) = MCold.(propertylist{idx});
                        end
                    elseif isstruct(varargin{1}) && length(varargin{1}) == 1 && isfield(varargin{1},'Sensor') && iscell(varargin{1}.Sensor) %hoeller / lievens
                        CS = varargin{1};
                        jdx = 1;
                        for idx = 1:length(CS.hw_ch)
                            if strcmpi(CS.State{idx},'on')
                                CSnew(jdx).Unit = CS.Unit{idx}; %#ok<AGROW>
                                CSnew(jdx).hw_ch = CS.hw_ch(idx); %#ok<AGROW>
                                CSnew(jdx).Sensor = CS.Sensor{idx}; %#ok<AGROW>
                                CSnew(jdx).Name = CS.Name{idx}; %#ok<AGROW>
                                if ~any(strfind(CS.AD{idx},'hwch'))
                                    CS.AD{idx} = [CS.AD{idx} '_hwch' num2str(CS.hw_ch(idx))];
                                end
                                CSnew(jdx).AD = CS.AD{idx}; %#ok<AGROW>
                                CSnew(jdx).PreAmp = CS.PreAmp{idx}; %#ok<AGROW>
                                CSnew(jdx).Sensitivity_AD= CS.Sensitivity_AD(idx); %#ok<AGROW>
                                CSnew(jdx).Sensitivity_PreAmp = CS.Sensitivity_PreAmp(idx); %#ok<AGROW>
                                CSnew(jdx).Sensitivity_Sensor = CS.Sensitivity_Sensor(idx); %#ok<AGROW>
                                CSnew(jdx).Coordinates = CS.Coordinates(idx); %#ok<AGROW>
                                CSnew(jdx).UserData = []; %#ok<AGROW>
                                CSnew(jdx).Orientation = CS.Orientation(idx); %#ok<AGROW>
                                jdx = jdx + 1;
                            end
                        end
                        this = itaMeasurementChain(CSnew);
                    elseif isstruct(varargin{1}) && isfield(varargin{1},'Name')
                        %% convert OLD input format - alias channel settings
                        CS = (varargin{1});
                        this = itaMeasurementChain(length(CS));
                        for idx = 1:length(CS)
                            this(idx).name = CS(idx).Name;
                            this(idx).coordinates = CS(idx).Coordinates;
                            this(idx).orientation = CS(idx).Orientation;
                            this(idx).userdata    = CS(idx).UserData;
                            this(idx).hardware_channel = CS(idx).hw_ch;
                            if isfield(CS,'Sensor')
                                % chain could have more than 3 elements, therefore
                                this(idx).elements(1) = itaMeasurementChainElements('ad');
                                this(idx).elements(1).name = CS(idx).AD;
                                this(idx).elements(1).hidden_sensitivity = CS(idx).Sensitivity_AD;
                                %MC(idx).elements(1).calibrated = 0;
                                % TODO pdi huhu
                                % preamp
                                if strfind (lower(CS(idx).PreAmp),'type 2610')
                                    robo_elements = itaMeasurementChainElements('preamp_var');
                                    robo_elements(1).name = CS(idx).PreAmp;
                                    this(idx).elements = [this(idx).elements robo_elements];
                                elseif strfind(lower(CS(idx).PreAmp),'robo')
                                    robo_elements = itaMeasurementChainElements('preamp_robo');
                                    robo_elements(1).name = CS(idx).PreAmp;
                                    robo_elements(2).name = CS(idx).PreAmp;
                                    this(idx).elements = [this(idx).elements robo_elements];
                                    this(idx).elements(3).hidden_sensitivity = itaValue(CS(idx).Sensitivity_PreAmp);
                                elseif strfind(lower(CS(idx).PreAmp),'modulita')
                                    newElements = itaMeasurementChainElements('preamp_modulita');
                                    newElements(1).name = CS(idx).PreAmp;
                                    newElements(2).name = CS(idx).PreAmp;
                                    newElements(2).hidden_sensitivity = CS(idx).Sensitivity_PreAmp;
                                    this(idx).elements = [this(idx).elements newElements];
                                elseif strfind(lower(CS(idx).PreAmp),'aurelio')
                                    newElements = itaMeasurementChainElements('preamp_aurelio');
                                    newElements(1).name = CS(idx).PreAmp;
                                    newElements(2).name = CS(idx).PreAmp;
                                    newElements(2).hidden_sensitivity = CS(idx).Sensitivity_PreAmp;
                                    this(idx).elements = [this(idx).elements newElements];
                                elseif strfind(lower(CS(idx).PreAmp),'nexus')
                                    newElements = itaMeasurementChainElements('preamp_nexus');
                                    newElements(1).name = CS(idx).PreAmp;
                                    newElements(1).sensitivity = CS(idx).Sensitivity_PreAmp;
                                    this(idx).elements = [this(idx).elements newElements];
                                else %noname preamp
                                    this(idx).elements(2) = itaMeasurementChainElements('preamp');
                                    this(idx).elements(2).name = CS(idx).PreAmp;
                                    this(idx).elements(2).hidden_sensitivity = itaValue(CS(idx).Sensitivity_PreAmp);
                                end
                                % sensor
                                %"end" is used as index
                                if strcmpi(CS(idx).Sensor,'Laser Doppler Vibrometer')
                                    %insert laser doppler?
                                    this(idx).elements(end+1) = itaMeasurementChainElements('vibrometer');
                                end
                                this(idx).elements(end+1) = itaMeasurementChainElements('sensor');
                                this(idx).elements(end).name = CS(idx).Sensor;
                                this(idx).elements(end).hidden_sensitivity = itaValue(CS(idx).Sensitivity_Sensor);
                            else
                                % output
                                this(idx).type = 'output';
                                this(idx).elements(1) = itaMeasurementChainElements('da');
                                this(idx).elements(1).name = CS(idx).DA;
                                this(idx).elements(1).hidden_sensitivity = CS(idx).Sensitivity_DA;
                                %                                 MC(idx).elements(1).calibrated = 0;
                                if strfind(lower(CS(idx).Amp),'robo')
                                    robo_elements = itaMeasurementChainElements('amp_robo');
                                    robo_elements(1).name = CS(idx).Amp;
                                    robo_elements(2).name = CS(idx).Amp;
                                    robo_elements(2).hidden_sensitivity = itaValue(CS(idx).Sensitivity_Amp);
                                    %                                     robo_elements(2).calibrated = 0;
                                    this(idx).elements = [this(idx).elements robo_elements];
                                elseif strfind(lower(CS(idx).Amp),'modulita')
                                    modulita_elements = itaMeasurementChainElements('amp_modulita');
                                    modulita_elements(1).name = CS(idx).Amp;
                                    modulita_elements(2).name = CS(idx).Amp;
                                    %                                     robo_elements(1).calibrated = -1; %var amp
                                    modulita_elements(2).hidden_sensitivity = itaValue(CS(idx).Sensitivity_Amp);
                                    %                                     robo_elements(2).calibrated = 0;
                                    this(idx).elements = [this(idx).elements modulita_elements];
                                elseif strfind(lower(CS(idx).Amp),'aurelio')
                                    aurelio_elements = itaMeasurementChainElements('amp_aurelio');
                                    aurelio_elements(1).name = CS(idx).Amp;
                                    aurelio_elements(2).name = CS(idx).Amp;
                                    %                                     robo_elements(1).calibrated = -1; %var amp
                                    aurelio_elements(2).hidden_sensitivity = itaValue(CS(idx).Sensitivity_Amp);
                                    %                                     robo_elements(2).calibrated = 0;
                                    this(idx).elements = [this(idx).elements aurelio_elements];
                                else %unknown amp
                                    this(idx).elements(2) = itaMeasurementChainElements('amp');
                                    this(idx).elements(2).name = CS(idx).Amp;
                                    this(idx).elements(2).hidden_sensitivity = itaValue(CS(idx).Sensitivity_Amp);
                                    %                                     MC(idx).elements(2).calibrated = 0;
                                end
                                this(idx).elements(end+1) = itaMeasurementChainElements('loudspeaker');
                                this(idx).elements(end).name = CS(idx).Actuator;
                                this(idx).elements(end).hidden_sensitivity = itaValue(CS(idx).Sensitivity_Actuator);
                                %                                 MC(idx).elements(end).calibrated = 0;
                            end
                        end
                    end
                otherwise
                    error('syntax not correct, too many input arguments')
            end
            %             MC = check_for_new_inputhardware(MC);
        end %end constructor
        
        function res = hw_ch(this,ch_id)
            % extract channels with the hardware channel id in correct order
            if nargin == 1 %get all available hardware channels
                for idx = 1:length(this)
                    res(idx) = this(idx).hardware_channel; %#ok<AGROW>
                end
            else
                for jdx = 1:length(ch_id)
                    res(jdx) = itaMeasurementChain(); %#ok<AGROW>
                    for idx = 1:length(this)
                        if this(idx).hardware_channel == ch_id(jdx)
                            res(jdx) = this(idx); %#ok<AGROW>
                            break
                        end
                    end
                    if isnumeric(res(jdx))
                        ita_verbose_info([mfilename 'Hardware channel cannot be found, taking channel 1'],0)
                        res(jdx) = this(1); %#ok<AGROW>
                    end
                end
            end
        end
        
        function res = isempty(this)
            res = any(this.hw_ch == 0);
        end
        
        function this = calibrate(this)
            %calibrate the entire channel of this measurement chain
            if strcmpi(this(1).type,'input')
                % Input measurement chain calibration
                for idx = 1:numel(this(1).elements);
                    disp('*************************************************************************')
                    
                    for ch_idx = 1:length(this) % go thru all channels
                        if numel(this(ch_idx).elements) >= idx
                            hw_ch = this(ch_idx).hardware_channel;
                            disp(['Calibration of sound card channel ' num2str(hw_ch)])
                            % go thru all elements of the chain and calibrate
                            if this(ch_idx).elements(idx).calibrated == -1 % uncalibratable devices
                                if strcmpi(this(ch_idx).elements(idx).type ,'preamp_nexus')
                                    %send sensor data to nexus
                                    MCE = this(ch_idx).elements(idx);
                                    if isempty(this(ch_idx).elements(idx+1).hiddensensitivity)
                                        sensor_value = (this(ch_idx).elements(idx+1).sensitivity);
                                    else
                                        sensor_value = (this(ch_idx).elements(idx+1).hiddensensitivity); %get the old value
                                    end
                                    
                                    this(ch_idx).elements(idx+1).sensitivity = sensor_value/double(sensor_value);
                                    ita_nexus_sendCommand('device',1,'channel',MCE.internal_channel,'param','TransducerSens','value',double(sensor_value))
                                    this(ch_idx).elements(idx+1).hiddensensitivity = sensor_value;
                                end
                            else
                                disp(['   Calibration of ' upper(this(ch_idx).elements(idx).type) '  ' this(ch_idx).elements(idx).name])
                                [this(ch_idx).elements(idx).sensitivity] = ita_measurement_chain_elements_calibration(this(ch_idx),idx); %calibrate each element
                            end
                        end
                    end
                    disp('****************************** FINISHED *********************************')
                end
            else
                % Output measurement chain calibration
                disp('This is done in MeasurementSetup not here!!!')
            end
        end
        
        %% get/set
        function this = set.calibrated(this,value)
            ita_verbose_info('I hope you know what you are doing, Matthias! We will take care of NEXUS here',0)
            for idx = 1:length(this)
                for jdx = 1:length(this(idx).elements)
                    if strcmpi(this(idx).elements(jdx).type ,'preamp_nexus')
                        % send sensor data to nexus
                        MCE = this(idx).elements(jdx);
                        if isempty(this(idx).elements(jdx+1).hiddensensitivity)
                            sensor_value = (this(idx).elements(jdx+1).sensitivity);
                        else
                            sensor_value = (this(idx).elements(jdx+1).hiddensensitivity); %get the old value
                        end
                        
                        this(idx).elements(jdx+1).sensitivity = sensor_value/double(sensor_value);
                        ita_nexus_sendCommand('device',1,'channel',MCE.internal_channel,'param','TransducerSens','value',double(sensor_value))
                        this(idx).elements(jdx+1).hiddensensitivity = sensor_value;
                    elseif this(idx).elements(jdx).calibrated ~= -1
                        this(idx).elements(jdx).calibrated = value;
                    end
                end
            end
        end
        
        function res = get.calibrated(this)
            res = true;
            for idx = length(this.elements)
                res = and(res,this.elements(idx).calibrated);
            end
        end
        
        function sens = sensitivity(this,up2element)
            % get overall sensitivity of this channel
            if nargin == 1
                up2element = [];
            end
            for ch_idx = 1:length(this)
                sens(ch_idx) = itaValue(1); %#ok<AGROW>
                for idx = 1:numel(this(ch_idx).elements)
                    %get sensitivity up to this element (excluding)
                    if ~isempty(up2element)
                        switch lower(up2element)
                            case {'preamp'}
                                if isPreamp(this(ch_idx).elements(idx));
                                    break
                                end
                            case {'sensor'}
                                laserTest = strcmpi(this(ch_idx).elements(idx).type,'vibrometer') && (numel(this(ch_idx).elements)>=idx+1) && isSensor(this(ch_idx).elements(idx+1));
                                if isSensor(this(ch_idx).elements(idx)) || laserTest;
                                    break
                                end
                            case {'ad'}
                                break;
                                %useful for the OTHERSIDE
                            otherwise %could be preamp_robo preamp_modulita
                                if strcmpi(up2element,this(ch_idx).elements(idx).type) %go up to this element
                                    break;
                                else
                                    ita_verbose_info('itaMeasurementChain:Calibration:We are not there yet!',2);
                                end
                        end
                    end
                    % accumulate sensitivities
                    sens(ch_idx) = sens(ch_idx) * this(ch_idx).elements(idx).sensitivity; %#ok<AGROW>
                end
            end
        end
        
        %% response
        function response = response_not_empty(this,up2element)
            if nargin == 1
                up2element = [];
            end
            response = this.response(up2element);
            if isempty(response)
                response = 1;
            end
        end
        
        function response = response(this,up2element)
            % get overall response of this channel
            if nargin == 1
                up2element = [];
            end
            response = itaAudio([numel(this),1]);
            for ch_idx = 1:length(this)
                for idx = 1:numel(this(ch_idx).elements)
                    % get sensitivity up to this element (excluding)
                    if ~isempty(up2element)
                        switch lower(up2element)
                            % input section
                            case {'ad'} % always the first
                                break;
                            case {'preamp'}
                                if isPreamp(this(ch_idx).elements(idx));
                                    break;
                                end
                            case {'sensor'}
                                if isSensor(this(ch_idx).elements(idx));
                                    break;
                                end
                                % output section
                            case {'da'} % always the first
                                if strcmpi(this(ch_idx).type,'output')
                                    break;
                                else
                                    error('How did we get here? This only makes sense for output measurement chains');
                                end
                            case {'amp'}
                                if strcmpi(this(ch_idx).type,'output')
                                    if isAmp(this(ch_idx).elements(idx));
                                        break;
                                    end
                                else
                                    error('How did we get here? This only makes sense for output measurement chains');
                                end
                            otherwise % could be preamp_robo preamp_modulita
                                if strcmpi(up2element,this(ch_idx).elements(idx).type) %go up to this element
                                    break;
                                else
                                    ita_verbose_info('itaMeasurementChain:Calibration:We are not there yet!',2);
                                end
                        end
                    end
                    % accumulate responses
                    if isempty(response(ch_idx))
                        response(ch_idx) =  this(ch_idx).elements(idx).response;
                    elseif isempty( this(ch_idx).elements(idx).response)
                        % do nothing, is already empty
                    else
                        response(ch_idx) = response(ch_idx) * this(ch_idx).elements(idx).response;
                    end
                end
                
            end
        end
        
        function final_response = final_response(this,up2element)
            if nargin == 1
                up2element = [];
            end
            final_response = this.response_not_empty(up2element)*this.sensitivity(up2element);
        end
        
        function disp(this)
            %give some information on the inside
            this.show;
        end
    end
    
    %% Hidden Methods ********************************
    methods(Hidden = true)
        function res = mtimes(this,res)
            % apply MC to itaAudio
            if isa(res, 'itaAudio') && (res.nChannels == length(this))
                %apply channel settings
                channelCoordinates = itaCoordinates;
                % safer multiplication using multiple instances
                tmp = itaAudio([res.nChannels 1]);
                for idx = 1:res.nChannels
                    res.channelNames{idx} = this(idx).name;
                    MultFactorSingle = 1/this(idx).sensitivity;
                    res.channelUnits{idx} = MultFactorSingle.unit;
                    MultFactor(idx) = double(MultFactorSingle); %#ok<AGROW>
                    channelCoordinates = [channelCoordinates this(idx).coordinates]; %#ok<AGROW>
                    res.userData{1}    = this(idx).userdata;
                    tmp(idx) = res.ch(idx)*MultFactor(idx);
                end
                res = merge(tmp);
                res.channelCoordinates = channelCoordinates;
            else
                ita_verbose_info('itaMeasurementChain::Cannot apply channels settings, results uncalibrated!',0)
            end
        end
        
        function show(this)
            %give some information on the inside
            disp('-----------------------------------------')
            disp(['   Measurement Chain with ' num2str(length(this)) ' channels'])
            for idx = 1:length(this)
                disp('-----------------------------------------')
                disp([' Sound card channel ' num2str(this(idx).hardware_channel) ' consists of:'])
                for jdx = 1:length(this(idx).elements)
                    show(this(idx).elements(jdx));
                end
                disp('-----------------------------------------')
            end
        end
        
        %% calibration
        function this = calibrate_per_channel(this)
            if strcmpi(this(1).type,'input')
                % Input measurement chain calibration
                for ch_idx = 1:length(this) % go thru all channels
                    disp('*************************************************************************')
                    hw_ch = this(ch_idx).hardware_channel;
                    disp(['Calibration of sound card channel ' num2str(hw_ch)])
                    for idx = 1:length(this(ch_idx).elements);
                        % go thru all elements of the chain and calibrate
                        if this(ch_idx).elements(idx).calibrated == -1
                            if strcmpi(this(ch_idx).elements(idx).type ,'preamp_nexus')
                                %send sensor data to nexus
                                MCE = this(ch_idx).elements(idx);
                                if isempty(this(ch_idx).elements(idx+1).hiddensensitivity)
                                    sensor_value = (this(ch_idx).elements(idx+1).sensitivity);
                                else
                                    sensor_value = (this(ch_idx).elements(idx+1).hiddensensitivity); %get the old value
                                end
                                
                                this(ch_idx).elements(idx+1).sensitivity = sensor_value/double(sensor_value);
                                ita_nexus_sendCommand('device',1,'channel',MCE.internal_channel,'param','TransducerSens','value',double(sensor_value))
                                this(ch_idx).elements(idx+1).hiddensensitivity = sensor_value;
                            end
                        else
                            disp(['   Calibration of ' upper(this(ch_idx).elements(idx).type) '  ' this(ch_idx).elements(idx).name])
                            this(ch_idx).elements(idx).sensitivity = ita_measurement_chain_elements_calibration(this(ch_idx),idx); %calibrate each element
                        end
                    end
                    disp('****************************** FINISHED *********************************')
                end
            else
                % Output measurement chain calibration
                disp('This is done in MeasurementSetup not here!!!')
            end
        end
        
        function this = edit(this)
            %modify your measurement chain. TODO...
            ita_verbose_info('sorry not implemented, yet. Do you like to write some code for that?',0)
            %             MC = itaChannelSettings(MC);
        end
        
        function CS = MC2CS(this)
            for idx = 1:length(this)
                switch this(idx).type
                    case 'input'
                        %destructure conversion
                        CS(idx).Name = this(idx).name; %#ok<AGROW>
                        CS(idx).hw_ch = num2str(this(idx).hardware_channel); %#ok<AGROW>
                        CS(idx).Sensitivity_AD = this(idx).elements(1).sensitivity; %#ok<AGROW>
                        CS(idx).AD = this(idx).elements(1).name; %#ok<AGROW>
                        CS(idx).PreAmp = this(idx).elements(end-1).name; %#ok<AGROW>
                        CS(idx).Sensitivity_PreAmp = this(idx).elements(end-1).sensitivity; %#ok<AGROW>
                        CS(idx).Sensitivity_Sensor = this(idx).elements(end).sensitivity; %#ok<AGROW>
                        CS(idx).Sensor = this(idx).elements(end).name; %#ok<AGROW>
                        CS(idx).Coordinates  = this(idx).coordinates; %#ok<AGROW>
                        CS(idx).Orientation  = this(idx).orientation; %#ok<AGROW>
                        CS(idx).UserData  = this(idx).userdata; %#ok<AGROW>
                    case 'output'
                        CS(idx).Name = this(idx).name; %#ok<AGROW>
                        CS(idx).hw_ch = num2str(this(idx).hardware_channel); %#ok<AGROW>
                        CS(idx).Sensitivity_DA = this(idx).elements(1).sensitivity; %#ok<AGROW>
                        CS(idx).DA = this(idx).elements(1).name; %#ok<AGROW>
                        CS(idx).Amp = this(idx).elements(end-1).name; %#ok<AGROW>
                        CS(idx).Sensitivity_Amp = this(idx).elements(end-1).sensitivity; %#ok<AGROW>
                        CS(idx).Sensitivity_Actuator = this(idx).elements(end).sensitivity; %#ok<AGROW>
                        CS(idx).Actuator = this(idx).elements(end).name; %#ok<AGROW>
                        CS(idx).Coordinates  = this(idx).coordinates; %#ok<AGROW>
                        CS(idx).Orientation  = this(idx).orientation; %#ok<AGROW>
                        CS(idx).UserData  = this(idx).userdata; %#ok<AGROW>
                end
            end
        end
        
        function this = force_calibration(this)
            for idx = 1:length(this)
                this(idx).calibrated = 1;
            end
        end
        
        function this = check_for_new_inputhardware(this)
            nChains = numel(this);
            isInput = zeros(nChains,1);
            % only input measurement chains will be handled here
            % output is handled in the measurement setup
            for i = 1:nChains
                isInput(i) = strcmpi(this(i).type,'input');
            end
            inputMC = this(logical(isInput));
            nChains = numel(inputMC);
            nNew = 0;
            deviceHandle = ita_device_list_handle;
            % go through all measurement chains to search for new devices
            for i = 1:nChains
                chain = inputMC(i);
                hwStr = ['hwch' num2str(chain.hw_ch,'%02d%')];
                for ele = 1:numel(chain.elements)
                    tmp = chain.elements(ele);
                    % do not check the default elements none or unknown
                    if (strcmpi(tmp.name,'none') || strcmpi(tmp.name,'unknown'))
                        continue;
                        % we do not want to enter variable elements
                    elseif ~isempty(strfind(tmp.type,'var'))
                        continue;
                        % for the fix part just adjust the type
                    elseif ~isempty(strfind(tmp.type,'fix')) && ~isempty(strfind(tmp.type,'preamp'))
                        tmp.type = 'preamp';
                    end
                    if isempty(strfind(tmp.name,hwStr)) && strcmpi(tmp.type,'ad')
                        tmp.name = [tmp.name ' ' hwStr];
                    end
                    % if it is not in the list, mark it for adding
                    if double(deviceHandle(tmp.type,tmp.name)) < 0
                        nNew = nNew + 1;
                        newDevices(nNew) = tmp; %#ok<AGROW>
                    end
                end
            end
            
            % if there are new devices ask user whether to add them to the device list
            if nNew > 0
                if nNew == 1
                    guiString = 'You have entered 1 new input device, would you like to add it to the device list';
                else
                    guiString = ['You have entered ' num2str(nNew) ' new input devices, would you like to add them to the device list'];
                end
                choice1 = 'Yes, please';
                choice2 = 'Yes, but calibrate them first';
                choice3 = 'No, thanks';
                choice = questdlg('New input devices found!', guiString, ...
                    choice1,choice2,choice3,choice1);
                switch choice
                    case choice1
                        for i = 1:nNew
                            ita_add_hardware_to_devicelist(newDevices(i));
                        end
                    case choice2
                        this = check_for_new_inputhardware(calibrate(this));
                    otherwise
                        
                end
            end
        end % end function
        
        %% Save object
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % disp('itaMeasurementChain is beeing saved.')
            % Store class name and class revision
            sObj.classname = class(this);
            sObj.classrevision = this.classrevision;
            
            % Copy all properties that were defined to be saved
            propertylist = itaMeasurementChain.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            
            % Set DateSaved
            sObj.dateSaved = datevec(now);
        end
    end
    
    %% Static methods
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % Called when an object is loaded
            this = itaMeasurementChain(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2956 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'name','elements','type','coordinates','orientation','userdata','hardware_channel'};
        end
    end
end
