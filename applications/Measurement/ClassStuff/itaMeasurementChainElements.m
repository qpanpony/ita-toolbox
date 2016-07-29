classdef itaMeasurementChainElements
    % Definition of a single element of a measurement chain channel. Could be
    % used for input (sensor, preamp, AD) or output (DA, amp, actuator)
    %
    % See also: itaMSRecord etc., itaMeasurementChain,
    %            ita_measurement
    
    % Author: Pascal Dietrich - 2010 - pdi@akustik.rwth-aachen.d
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    properties(Access = private, Hidden = true)
        mSensitivity   = itaValue(1);
        mName          = 'name';
    end
    properties(Dependent = true, Hidden = false)
        sensitivity %get the overall sensitivy (itaValue) of this channel
        name % get the name (string) of this channel strip
    end
    properties(Dependent = true, Hidden = true)
        hidden_sensitivity %get the hidden sensitivity, no output strings!
    end
    properties(Hidden = true)
        hiddensensitivity = []; %only used for nexus commands
        picType     = 'mcet_none.jpg';
        picModel    = 'mcem_none.jpg';
    end
    properties
        type        = 'none'; %specify the type of the element ('preamp', 'amp'). TODO more documentation
        response    = []; %specify the response (FRF/IR) of this element, with 1 (0dB) at 1000Hz
        calibrated  = 0; %-1: not calibratable; 0: not calibrated 1: calibrated
    end
    
    methods
        %% constructor
        function MCE = itaMeasurementChainElements(varargin)
            switch nargin
                case 0
                    % no input given, make an empty object
                case 1
                    if iscell(varargin{1})
                        element_names = varargin{1};
                        idx2 = 1;
                        for idx = 1:length(varargin{1})
                            a = itaMeasurementChainElements(element_names{idx});
                            if length(a) == 2
                                MCE(idx2)   = a(1); %#ok<AGROW>
                                MCE(idx2+1) = a(2); %#ok<AGROW>
                                idx2 = idx+2;
                            else
                                MCE(idx2) = a; %#ok<AGROW>
                                idx2 = idx2 +1;
                            end
                        end
                    elseif ischar(varargin{1})
                        settype = true;
                        switch lower(varargin{1})
                            case 'ad'
                                MCE.mSensitivity = itaValue(1,'1/V');
                                MCE.picType = 'mcet_ad.jpg';
                            case 'da'
                                MCE.mSensitivity = itaValue(1,'V/1');
                                MCE.picType = 'mcet_da.jpg';
                            case 'sensor_pressure'
                                MCE.mSensitivity = itaValue(1,'V/Pa');
                                MCE.picType = 'mcet_mic.jpg';
                            case 'sensor_velocity'
                                MCE.mSensitivity = itaValue(1,'V')/itaValue('m/s');
                                MCE.picType = 'mcet_mic.jpg';
                            case 'sensor_acceleration'
                                MCE.mSensitivity = itaValue(1,'V')/itaValue('m/s^2');
                                MCE.picType = 'mcet_mic.jpg';
                            case 'sensor_voltage'
                                MCE.mSensitivity = itaValue(1,'V/V');
                                MCE.picType = 'mcet_none.jpg';
                            case 'sensor_current'
                                MCE.mSensitivity = itaValue(1,'V/A');
                            case 'sensor_force'
                                MCE.mSensitivity = itaValue(1,'V/N');
                                MCE.picType = 'mcet_mic.jpg';
                            case 'sensor'
                                MCE.mSensitivity = itaValue(1,'V/1');
                                MCE.picType = 'mcet_mic.jpg';
                            case 'vibrometer'
                                MCE.mSensitivity = itaValue(1,'V')/itaValue('m/s');
                                MCE.picType = 'mcet_mic.jpg';
                                MCE.calibrated = -1;
                            case 'preamp_var'
                                MCE.picType = 'mcet_preamp.jpg';
                            case 'preamp'
                                MCE.picType = 'mcet_preamp.jpg';
                            case 'amp'
                                MCE.picType = 'mcet_amp.jpg';
                            case 'actuator'
                                MCE.picType = 'mcet_ls.jpg';
                                MCE.picModel = 'mcem_shaker';
                            case 'loudspeaker'
                                MCE.mSensitivity = itaValue('Pa m / V');
                                MCE.picType = 'mcet_ls.jpg';
                            case 'amp_var'
                                MCE.picType = 'mcet_amp.jpg';
                            case 'preamp_aurelio'
                                MCE(2) = itaMeasurementChainElements('preamp_aurelio_fix');
                                MCE(2).calibrated = 0;
                                MCE(1) = itaMeasurementChainElements('preamp_aurelio_var');
                                MCE(1).calibrated = -1;
                                settype = false; %already set in subcalls
                            case 'preamp_aurelio_var'
                            case 'preamp_aurelio_fix'
                                MCE(1).calibrated = -1;
                            case 'preamp_modulita'
                                MCE(2) = itaMeasurementChainElements('preamp_modulita_fix');
                                MCE(2).calibrated = 0;
                                MCE(1) = itaMeasurementChainElements('preamp_modulita_var');
                                MCE(1).calibrated = -1;
                                settype = false; %already set in subcalls
                            case 'preamp_modulita_var'
                            case 'preamp_modulita_fix'
                                MCE(1).calibrated = -1;
                            case 'ad_modulita'
                            case 'preamp_robo_var'
                                MCE.calibrated = -1;
                                MCE.picModel = 'mcem_robo';
                            case 'preamp_robo_fix'
                                MCE.picModel = 'mcem_robo';
                            case {'robo_preamp','preamp_robo','robo'}
                                %this order is important: go backwards in
                                %the measurementchainelements (input) list for
                                %calibration
                                MCE(2) = itaMeasurementChainElements('preamp_robo_fix');
                                MCE(1) = itaMeasurementChainElements('preamp_robo_var');
                                MCE(1).calibrated = -1;
                                settype = false; %already set in subcalls
                            case 'amp_robo_var'
                                MCE.calibrated = -1;
                            case 'amp_robo_fix'
                                MCE.calibrated = 0;
                            case 'amp_robo'
                                %this order is important: go forward in
                                %the measurementchainelements (output) list for
                                %calibration
                                MCE(1) = itaMeasurementChainElements('amp_robo_var');
                                MCE(2) = itaMeasurementChainElements('amp_robo_fix');
                                settype = false; %already set in subcalls
                            case 'amp_modulita_var'
                                MCE.calibrated = -1;
                            case 'amp_modulita_fix'
                                MCE.calibrated = 0;
                            case 'amp_modulita'
                                %this order is important: go forward in
                                %the measurementchainelements (output) list for
                                %calibration
                                MCE(1) = itaMeasurementChainElements('amp_modulita_var');
                                MCE(2) = itaMeasurementChainElements('amp_modulita_fix');
                                settype = false; %already set in subcalls
                            case 'amp_aurelio_var'
                                MCE.calibrated = -1;
                            case 'amp_aurelio_fix'
                                MCE.calibrated = 0;
                            case 'amp_aurelio'
                                %this order is important: go forward in
                                %the measurementchainelements (output) list for
                                %calibration
                                MCE(1) = itaMeasurementChainElements('amp_aurelio_var');
                                MCE(2) = itaMeasurementChainElements('amp_aurelio_fix');
                                settype = false; %already set in subcalls
                            case {'nexus','preamp_nexus'}
                                MCE.calibrated = -1;
                                MCE.picModel = 'mcem_nexus';
                                MCE.type = 'preamp_nexus';
                            otherwise
                                error(['element type not in list: ' lower(varargin{1})])
                        end
                        if settype
                            MCE.type = varargin{1};
                        end
                    elseif isnumeric(varargin{1})
                        for idx = 1:varargin{1}
                            MCE(idx) = itaMeasurementChainElements();  %#ok<AGROW>
                        end
                    elseif isstruct(varargin{1})
                        MCEold = varargin{1};
                        propertylist = itaMeasurementChainElements.propertiesSaved;
                        for idx = 1:numel(propertylist)
                            MCE.(propertylist{idx}) = MCEold.(propertylist{idx});
                        end
                    else
                        error('itaMeasurementChainElements:No MeasurementChainElements given.')
                    end
                otherwise
                    error('syntax not correct, too many input arguments')
            end
            
        end %end constructor
        
        function this = set.hidden_sensitivity(this,value)
            this.mSensitivity = itaValue(value);
        end
        
        function this = set.sensitivity(this,value)
            if ischar(value)
                value = [value ' '];
                this.mSensitivity = itaValue(value);
            elseif double(value) == 0
                devListHandle = ita_device_list_handle;
                this.mSensitivity = devListHandle(this.type,this.name);
                this.calibrated = -1;
            elseif isa(value,'itaValue')
                this.mSensitivity = value;
            elseif isnumeric(value)
                this.mSensitivity = itaValue(value);
            end
            if this.calibrated == 0 %when sens is set, the element is assumed to be calibrated
                this.calibrated = 1;
            elseif this.calibrated == -1 %could be robo or nexus
                if strcmpi(this.type ,'preamp_robo_var')
                    [xx,b,c] = ita_robocontrol('getSettings');
                    if ischar(value)
                        value = str2double(value);
                    end
                    a = num2str(20*log10(value));
                    ita_robocontrol(a,b,c);
                elseif strcmpi(this.type,'preamp_nexus')
                    value = itaValue(value);
                    try
                        ita_nexus_sendCommand('device',1,'channel',this.internal_channel,'param','OutputSens','value',double(value))
                    catch %#ok<CTCH>
                        disp('Nexus settings could not be sent.')
                    end
                end
            end
            if ischar(value)
                if strcmpi(value,'auto')
                    this.calibrated = 0;
                end
                % TODO : ita_device_list ...
            end
        end
        
        %% get actual name
        function value = get.name(MCE) % no verbose output
            value = MCE.mName;
        end
        
        function MCE = set.name(MCE,name) % no verbose output
            MCE.mName = name;
            devListHandle = ita_device_list_handle;
            MCE = devListHandle(MCE);
        end
        
        %% get actual value
        function value = get.sensitivity(MCE) % no verbose output
            if ~MCE.calibrated && ita_preferences('useMeasurementChain')
                ita_verbose_info(['Element has not been calibrated yet! ' MCE.name ' - ' MCE.type],1)
            end
            value = sensitivity_silent(MCE);
        end
        
        %% disp
        function show(this)
            %show some nice output lines telling about the inside
            color_disp = 'g';
            add_str = '';
            if ~this.calibrated
                color_disp = 'r';
                add_str = ' - UNCALIBRATED';
            end
            if ~isempty(this.hiddensensitivity)
                add_str = [add_str ' [[' num2str(this.hiddensensitivity) ']]'];
            end
            try
                sensStr = num2str(this.sensitivity_silent);
            catch %#ok<CTCH>
                sensStr = ('ERROR!!!');
            end
            cdisp(color_disp, ['   ' upper(this.type) ': ' this.name ' [' sensStr ']' add_str]);
            %             disp('-----------------------------------------')
        end
        
%         function disp(this)
            %show some nice output lines telling about the inside
%             this.show;
%         end
        
        % CALIBRATION (is not done here, so error!)
        function this = calibrate(this,multFactor,hw_ch) %#ok<INUSD,MANU>
            error('How did we get here? Calibration should be done in the MeasurementChain, not here!');
        end
        
    end
    
    %% ************************** HIdden **************
    methods(Hidden = true)
        function value = sensitivity_silent(MCE)
            %get actual sens, e.g. of nexus and robo
            value = MCE.mSensitivity;
            switch lower(MCE.type)
                case {'amp_robo_var'}
                    [xx,xx,value] = ita_robocontrol('getSettings'); %#ok<*ASGLU>
                    value = 10^(value/20);
                case {'preamp_robo_var'}
                    [value_db robomode x] = ita_robocontrol('getSettings'); %#ok<NASGU>
                    value = 10^(-value_db/20);
                    
                    if strcmpi(robomode,'ampref')
                        value = value * 10^(-20.8514/20); %amp ref does 20dB attenuation inside!!!
                    end
                case {'preamp_aurelio_var'}
                    oldSettings = ita_aurelio_control('getSettings');
                    value = oldSettings.ch(MCE.internal_channel).inputrange;
                    value = 10^(-value/20);
                case {'preamp_modulita_var'}
                    oldSettings = ita_modulita_control('getSettings');
                    value = oldSettings.ch(MCE.internal_channel).inputrange;
                    value = 10^(-value/20);
                    if strcmpi(oldSettings,'ampref')
                        value = value * 10^(-20/10); %amp ref does 20dB attenuation inside!!!
                    end
                case {'vibrometer'}
                    value = eval('ita_vibro_getLaserSensitivity()');
                case {'amp_modulita_var'}
                    a = ita_modulita_control('getSettings');
                    value = 10^(a.davolume/20);
                case {'amp_aurelio_var'}
                    a = ita_aurelio_control('getSettings');
                    value = 10^(a.amp_gain/20);
                otherwise
                    %                     ita_verbose_info(['this type is not in the list: '  MCE.type],0)
            end
        end
        
        function ch_idx = internal_channel(this)
            switch lower(this.type)
                case {'preamp_modulita_var','preamp_nexus','preamp_aurelio_var'}
                    idx = strfind(this.name,'hwch');
                    if (length(this.name) >= idx+5) && isstrprop(this.name(idx+5),'digit')
                        token = this.name(idx+4:idx+5);
                    else
                        token = this.name(idx+4);
                    end
                    ch_idx = str2double(token);
                otherwise
                    ch_idx = [];
            end
        end
        
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % disp('itaMeasurementChainElements is beeing saved.')
            % Store class name and class revision
            sObj.classname = class(this);
            sObj.classrevision = this.classrevision;
            % Copy all properties that were defined to be saved
            propertylist = itaMeasurementChainElements.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            % Set DateSaved
            sObj.dateSaved = datevec(now);
        end
        
        function res = isPreamp(this)
            res = ismember(this.type(1:min(6,length(this.type))),{'preamp'});
        end
        
        function res = isAmp(this)
            res = ismember(this.type(1:min(3,length(this.type))),{'amp'});
        end
        
        function res = isSensor(this)
            res = ismember(this.type(1:min(6,length(this.type))),{'sensor'});
        end
        
        function res = isActuator(this)
            res = ismember(this.type(1:min(8,length(this.type))),{'actuator'});
        end
        
    end
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % Called when an object is loaded
            this = itaMeasurementChainElements(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2956 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'mSensitivity','type','mName','response','calibrated'};
        end
    end
end
