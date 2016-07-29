classdef itaMSImpedance < itaMSTF
    
    % <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
    
    % This is the class for Loudspeaker impedance measurements
    
    properties(Access = private)
        
    end
    properties(Dependent = true, Hidden = false)
        
    end
    properties (Hidden = true)
    end
    
    properties
        % reference is defined in itaMSTF
        %reference              = itaAudio(); %measured reference spectrum used for impedance calculation
        shunt_resistance       = itaValue(1,'Ohm');%value of the shunt resistance (itaValue)
        calibration_resistance = itaValue(10,'Ohm');%value of the calibration resistance (itaValue)
        time_window            = [0.1 0.2]; % apply symmetric time window to reduce noise (seconds)
        device                 = 'robo'; %robo or modulita or aurelio
    end
    
    methods
        %% constructor
        function this = itaMSImpedance(varargin)
            % itaMSImpedance - Constructs an itaMSImpedance object.
            if nargin == 0
                
                % For the creation of itaMSImpedance objects from commandline strings
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
                % itaMSImpedance class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSImpedance class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSImpedance')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSImpedance')
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
                error('itaMSImpedance::wrong input arguments given to the consructor');
            end
%             addlistener(this,'latencysamples','PostSet',@this.init);
            this.useMeasurementChain = false;
        end
        
        %% edit
        function this = edit(this)
            % use superclass constructor first for the signal properties
            this.useMeasurementChain = false;
            this = edit@itaMSTF(this);
            this = ita_msimpedance_gui(this);
        end
        
        %% init routine
        function init(this,varargin)
            % delete reference measurement if excitation is changed
            %             disp('init imp')
            this.reference = [];
            this.useMeasurementChain = false;
            init@itaMSTF(this);
        end
        
        %% calibration
        function this = calibrate(this,outputAmp)
            % do a reference measurement of the amplifier with a known
            % calibration resistance
            
            %% preamp amp settings
            switch (lower(this.device))
                case 'modulita'
                    ita_modulita_control('mode','lineref')
                    pause(0.5)
                    ita_modulita_control('mode','ampref')
                    pause(0.5)
                    ita_modulita_control('mode','imp')
                    ita_modulita_control('mode','impref')
                case 'robo'
                    [oldIn,oldMode,oldOut] = ita_robocontrol('getSettings');
                    ita_robocontrol(oldIn,'10Ohm',oldOut);
                case 'aurelio'
                    ita_aurelio_control('mode','impref');
            end
            
            %% measurement
            if nargin < 2
                outputAmp = -1;
            end
            oa                          = this.outputamplification;
            this.outputamplification    = outputAmp;
            this.reference              = this.run_raw_imc_dec_omc;
            this.outputamplification    = oa;
            
            %% restore normal settings
            switch lower(this.device)
                case 'modulita'
                    ita_modulita_control('mode','norm');
                case 'robo'
                    [oldIn,oldMode,oldOut] = ita_robocontrol('getSettings');
                    ita_robocontrol(oldIn,'norm',oldOut);
                case 'aurelio'
                    ita_aurelio_control('mode','norm')
            end
            
            %% latency samples
            if this.latencysamples == 0
                [xx, lsamples]  = max(abs(this.reference.timeData),[],1); %#ok<*ASGLU>
                lsamples = max(lsamples - 1 , 0);  %pdi: The latency is the number of samples BEFORE the arrival of the impulse but we should keep a small delay to prevent non causal responses
                if lsamples == 0
                    lsamples = [];
                end
                this.latencysamples = lsamples;
                this.reference = ita_time_shift(this.reference,-this.latencysamples, 'samples');
                
            end
            this.reference.channelUnits{1} = 'V';
            
        end
        
        function result = run(this)
            % do a measurement. if not calibrated, it automatically
            % switches to impedance mode and does a reference measurement
            if isempty(this.reference)
                ita_verbose_info('You need to do a reference measurement first. I will take care of this',0);
                this.calibrate;
            end
            
            if strcmpi(this.device,'modulita')
                ita_modulita_control('mode','imp')
                pause(0.5)
            elseif strcmpi(this.device,'robo')
                [oldIn,oldMode,oldOut] = ita_robocontrol('getSettings');
                ita_robocontrol(oldIn,'imp',oldOut);
            elseif strcmpi(this.device,'aurelio')
                ita_aurelio_control('mode','imp')
            end
            raw = this.run_raw_imc_dec_omc;
            
            if strcmpi(this.device,'modulita') % set mode back to norm
                pause(0.5);
                ita_modulita_control('mode','norm')
            elseif strcmpi(this.device,'robo')
                [oldIn,oldMode,oldOut] = ita_robocontrol('getSettings');
                ita_robocontrol(oldIn,'norm',oldOut);
            elseif strcmpi(this.device,'aurelio')
                ita_aurelio_control('mode','norm')
            end
            
            U_m = raw(1);
            U_m = U_m * itaValue(1,'V');
            
            U_m  = ita_time_window(U_m, this.time_window,'time','symmetric');
            U_rr = ita_time_window(this.reference,this.time_window,'time','symmetric');
            
            imp_01 = this.shunt_resistance;
            imp_101 = this.calibration_resistance+this.shunt_resistance;
            freq_vec = this.freqRange;
            %             freq_vec = [0 freq_vec(2)*(2)];
            result   =  ita_divide_spk(U_rr , U_m,'regularization',freq_vec) * imp_101 - imp_01;
            result.channelNames(:) = {'Electrical Impedance'};
            
            if length(raw) > 1;
                result = [result raw(1:end)];
            end
        end
    end
    
    methods(Hidden = true)
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSTF(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSImpedance.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            
        end
    end
    
    methods(Static, Hidden = true)
        function this = findobj(this)
            this = builtin('findobj',this);
        end
        
        function this = loadobj(sObj)
            this = itaMSImpedance(sObj); % Just call constructor, he will take care
        end
        
        function result = propertiesSaved
            result = {'reference','shunt_resistance','calibration_resistance','time_window',...
                'device'};
        end
    end
    
    
end