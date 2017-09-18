classdef itaMSRecord < itaHandle
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    % This is the mother of all measurement classes, directly implementing
    % the recording function only, everything else is done by the other
    % classes, e.g. itaMSPlaybackRecord, itaMSTF etc.
    %
    % See also: ita_measurement, itaMSPlaybackRecord, itaMeasurementChain
    
    properties(Access = protected, Hidden = true)
        mInputChannels          = [];
        mPrecision              = 'single';
        mNSamples               = ita_nSamples(ita_preferences('fftDegree'));
        mFreqrange              = [20 ita_preferences('samplingRate')/2];
    end
    
    properties(Hidden = true, GetAccess = private, Constant = true)
        mCreateFunction = '';
    end
    
    properties(Dependent = true, Hidden = false, Transient = true, SetObservable = true, AbortSet = true)
        fftDegree               % Length of excitation signal in 2^fftDegree samples
        nSamples                % Number of Samples of Excitation
        trackLength             % Length of excitation signal in seconds
        freqRange               % Freq range for measurement
        inputChannels           % Vector with IDs of input channels e.g. [5 1 2]
        precision               % data type, could be ('single' (faster, less memory) or 'double' (standard)).
    end
    
    properties (Hidden = false)
        inputMeasurementChain  = itaMeasuringStation.loadCurrentInputMC; % Definition of the components of your input measurement chain used for absolute measurements and calibration
        averages        = 1;    % number of averages (positive integer) used to calculate the result
        repeats         = 1;    % number of repetitions (positive integer) of the measurement. The results are written separately
        pause           = 0;    % pause in seconds (double) between two subsequent measurements
        comment         = '';   % text (string) describing the measurement task
    end
    
    properties (Hidden = true)
        reset           = false; % portAudio reset before each measurement (slow, but could be less problematic)
        exportvariable  = '';   % export to variable with this name (string) to workspace.
        DateCreated     = datestr(now);
        User            = ita_preferences('authorStr');
    end
    
    properties (SetObservable = true, AbortSet = true)
        samplingRate    = ita_preferences('samplingRate');  % Get Samplingrate from preferences.
        applyBandpass   = false;
        useMeasurementChain = ita_preferences('useMeasurementChain');
    end
    
    %% Methods
    methods
        %% constructor
        function this = itaMSRecord(varargin)
            % itaMSRecord - Constructs an itaMSRecord object.
            if nargin == 0
                
                % For the creation of itaMSRecord objects from commandline strings
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
                % itaMSRecord class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSRecord class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSRecord')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSRecord')
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
                error('itaMSRecord::wrong input arguments given to the constructor');
            end
        end
        
        %% get/set
        function res = get.precision(this)
            res = this.mPrecision;
        end
        
        function set.precision(this,value)
            switch(lower(value))
                case 'single'
                    this.mPrecision = 'single';
                case 'double'
                    this.mPrecision = 'double';
                otherwise
                    ita_verbose_info('Sorry only single or double precision possible',0)
            end
            
        end
        
        function set.samplingRate(this,value)
            if numel(value) == 1 && isnumeric(value) && isfinite(value)
                this.samplingRate = value;
            else
                error('samplingRate not valid');
            end
        end
        
        function set.fftDegree(this, value)
            if numel(value) == 1 && isnumeric(value) && isfinite(value)
                this.mNSamples = ita_nSamples(value);
            else
                error('fftDegree not valid');
            end
        end
        
        function res = get.fftDegree(this)
            res = log2(this.mNSamples);
        end
        
        function set.trackLength(this, value)
            if numel(value) == 1 && isnumeric(value) && isfinite(value)
                nSamples = value * this.samplingRate;
                this.mNSamples = round(nSamples/2) * 2;
            else
                error('trackLenth not valid. enter length in seconds!');
            end
        end
        
        function res = get.trackLength(this)
            res = this.mNSamples / this.samplingRate;
        end
        
        function set.nSamples(this,value)
            this.fftDegree = value;
        end
        
        function res = get.nSamples(this)
            res = this.mNSamples;
        end
        
        function set.freqRange(this, value)
            set_freqRange(this,value); % workaround for inherited classes
        end
        
        function set_freqRange(this,value)
            if numel(value) == 2
                this.mFreqrange = value;
            else
                ita_verbose_info('freqRange has to be a vector with two elements',0);
            end
        end
        
        function res = get.freqRange(this)
            res = this.mFreqrange;
        end
        
        function res = get.inputChannels(this)
            res = this.mInputChannels;
        end
        
        function set.inputChannels(this,value)
            if ~all(ismember(value,this.inputMeasurementChain.hw_ch));
                % pdi: it works as hell! ask joe for any comments
                newChannels = value(~ismember(value,this.inputMeasurementChain.hw_ch));
                if isempty(this.inputChannels)
                    if this.useMeasurementChain
                        this.inputMeasurementChain = ita_measurement_chain(newChannels);
                    else % create an empty dummy chain
                        dummyChain = itaMeasurementChain(numel(newChannels));
                        for iCh = 1:numel(newChannels)
                            dummyChain(iCh).hardware_channel = newChannels(iCh);
                        end
                        this.inputMeasurementChain = dummyChain;
                    end
                else
                    if this.useMeasurementChain
                        this.inputMeasurementChain = [this.inputMeasurementChain ita_measurement_chain(newChannels)];
                    else % create an empty dummy chain
                        dummyChain = itaMeasurementChain(numel(newChannels));
                        for iCh = 1:numel(newChannels)
                            dummyChain(iCh).hardware_channel = newChannels(iCh);
                        end
                        this.inputMeasurementChain = [this.inputMeasurementChain dummyChain];
                    end
                    
                end
                this.mInputChannels = value;
            else
                this.mInputChannels = value;
            end
        end
        
        %% additional methods
        function this = edit(this)
            % This function calls the itaMSRecord GUI.
            this = ita_msrecord_gui(this);
        end
        
        %% Run
        function this = calibrate(this)
            % this will guide you through the calibration process
            this = calibrate_input(this);
        end
        
        %% RUN
        function checkready(this)
            %check if the instance is ready for measurement run and ask for
            %missing entries
            if isempty(this.inputChannels)
                this.edit;
            end
            
        end
        
        function [result, max_rec_lvl] = run_raw(this)
            % run_raw - Run measurement
            this.checkready;
            singleprecision = strcmpi(this.precision,'single'); % Bool for single precision for portaudio.
            
            result = ita_portaudio(this.nSamples,'InputChannels',this.inputChannels, ...
                'repeats',1,'singleprecision',singleprecision,'reset', this.reset);
            max_rec_lvl = max(abs(result.timeData),[],1);
            
            % add history line
            commitID = ita_git_getMasterCommitHash;
            if ~isempty(commitID)
                result = ita_metainfo_add_historyline(result,'Measurement',commitID);
            end
            
        end
        
        function [result, max_rec_lvl] = run_raw_imc(this)
            % run_raw_imc - Run measurement, regard input
            % measurement chain.
            %
            % This function runs a measurement and only regards the
            % input chain properties, thus yielding the unaltered measurement
            % signal present at the receiving position.
            
            % Measurement.
            % Execute as many averages as specified in the measurement
            % setup wit a pause before each measurement.
            result = itaAudio([this.averages 1]);
            max_rec_lvl = zeros(this.averages,numel(this.inputChannels));
            for rep_idx = 1:this.averages
                pause(this.pause); %#ok<CPROP>
                [result_tmp, max_rec_lvl_tmp] = run_raw(this);
                if isempty(result_tmp)
                    result = result_tmp;
                    return;
                end
                result(rep_idx) = result_tmp;
                max_rec_lvl(rep_idx,:) = max_rec_lvl_tmp;
                
            end
            
            % Level analysis block
            % Get the absolute max recording level, before any further
            % processing.
            max_rec_lvl = max(max_rec_lvl,[],1);
            
            % Averaging block
            % If more than one measurement has been done, get the average.
            if numel(result) > 1
                result = mean(result);
            end
            
            % Input measurement chain block
            % If an input measurement chain is defined, apply it to the
            % recorded data. The result of this operations corresponds to
            % the physically present levels at the recording position.
            % TODO: replace by compensate input meas chain.!!
            if ~isempty(this.inputMeasurementChain)
                result = this.inputMeasurementChain.hw_ch(this.inputChannels) * result;
            end
            
            % Write result
            result.comment = [this.comment result.comment];     % Add comment.
            result = ita_metainfo_rm_historyline(result,'all'); % Remove all history lines.
        end
        
        function [result, max_rec_lvl] = run(this)
            % run - Run standard measurement.
            %
            % This function runs a full measurement, including all possible
            % corrections (inputmeasurement chain)
            
            [result, max_rec_lvl] = run_raw_imc(this);
            if this.applyBandpass
                result = ita_mpb_filter(result,this.freqRange,'zerophase');
            end
        end
        
        function res = run2file(this,varargin)
            %directly write measurement results to a file on harddisk.
            %useful for repeated measurements
            res = ita_measurement_run2file(this,varargin{:});
        end
        
        %% Calibrate
        function this = calibrate_input(this)
            % only calibrate input Measurement chain
            % and only active channels
            imcIdx = zeros(numel(this.inputChannels),1);
            for chIdx = 1:numel(this.inputChannels)
                imcIdx(chIdx) = find(this.inputMeasurementChain.hw_ch == this.inputChannels(chIdx));
            end
            this.inputMeasurementChain(imcIdx) = this.inputMeasurementChain(imcIdx).calibrate;
        end
        
        %% commandline
        function str = commandline(this)
            % commandline - Generate comandline string.
            %
            % This function creates a commandline string for creating the
            % exact same measurement setup.
            
            str = 'itaMSRecord(';
            list = {'useMeasurementChain','samplingRate','fftDegree','freqRange','inputChannels','precision','averages','repeats','pause','comment','applyBandpass'};
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
    
    %% Hidden Methods
    methods(Hidden = true)
        %% show
        function display(this)            
            % Begin Display Start Line
            classnameString = ['|' class(this) '|'];
            result = repmat('=',1,itaSuper.LINE_LENGTH);
            result(3:(2+length(classnameString))) = classnameString;
            disp(result);
            % End Display Start Line
            
            % Start Display Values
            disp(['   samplingRate  = ' num2str(this.samplingRate) '        nSamples  = ' num2str(this.nSamples)])
            disp(['   length        = ' num2str(this.nSamples/this.samplingRate,5) ' s ' '    fftDegree = ' num2str(this.fftDegree) '      freqRange = [' num2str(this.freqRange(:)') ']  '])
            disp(['   averages      = ' num2str(this.averages) '            repeats   = ' num2str(this.repeats)])
            disp(['   input ch.     = [' num2str(this.inputChannels) ']'])
            % End Display Values
            
            global lastDiplayedVariableName
            lastDiplayedVariableName = inputname(1);
            
            if ita_preferences('dispVerboseFunctions')
                display_line4commands({'   MS           ', {'__.edit','.edit'},{'builtin(''disp'',__)','Show Inside of Class'}},lastDiplayedVariableName);
                display_line4commands({'   Measure      ', {'__.run','.run'}, {'__.run_raw','.run_raw'}},lastDiplayedVariableName);
            else
                display_line4commands({'                                                      ', ...
                    {'ita_preferences(''dispVerboseFunctions'',1); display(__)', 'What to do...?'}}, lastDiplayedVariableName);
            end
        end
        
        function this = force_calibration(this)
            %set all measurement chain components to status: 'calibrated'
            this.inputMeasurementChain = this.inputMeasurementChain.force_calibration;
        end
        
        function str = createFunction(this)
            str = this.mCreateFunction;
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            propertylist = itaMSRecord.propertiesSaved;
            
            % Write the content of every item in the list of the to be saved
            % properties into its own field in the save struct.
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
            % Set DateSaved
            sObj.dateSaved = datevec(now);
        end
    end
    
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            this = itaMSRecord(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2956 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            result = {'DateCreated','User','samplingRate','mInputChannels', 'mPrecision','inputMeasurementChain', 'averages', 'repeats', 'pause', 'comment', 'reset', 'exportvariable','mNSamples', 'mFreqrange','applyBandpass','useMeasurementChain'};
        end
    end
end