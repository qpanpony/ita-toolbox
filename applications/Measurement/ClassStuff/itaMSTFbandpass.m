classdef itaMSTFbandpass < itaMSTF
    
    % <ITA-Toolbox>
    % This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
    % You can find the license for this m-file in the application folder.
    % </ITA-Toolbox>
    
    % This is a class for Transfer Function measurements with splitting
    % multiple frequency bands into output channels
    
    properties(Access = public, Hidden = true)
        mFilterType             = 'LiRi';   % type of bandpass filter
        mFilterOrder            = 12;       % bandpass filter order
        mFinalExcitation        = itaAudio();
    end
    
    properties(Dependent = true, Hidden = false, Transient = true, SetObservable = true, AbortSet = true)
        filterOrder; % bandpass filter order
        filterType; % type of bandpass filter
    end
    
    properties(Constant = true)
        possibleFilterTypes = {'LiRi','Butter'};
    end
    
    methods
        
        %% CONSTRUCT
        
        function this = itaMSTFbandpass(varargin)
            % itaMSTFBandpass - Constructs an itaMSTFBandpass object.
            if nargin == 0
                
                % For the creation of itaMSTFBandpass objects from commandline strings
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
                % itaMSTFBandpass class object from a struct, created by the saveobj
                % method, or as a copy of an already existing itaMSTFBandpass class
                % object. In the latter case, only the properties contained in
                % the list of saved properties will be copied.
            elseif isstruct(varargin{1}) || isa(varargin{1},'itaMSTF')
                % Check type of given argument and obtain the list of saved
                % properties accordingly.
                if isa(varargin{1},'itaMSTF')
                    %The save struct is obtained by using the saveobj
                    % method, as in the case in which a struct is given
                    % from the start (see if-case above).
                    if isa(varargin{1},'itaMSTFbandpass')
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
                
                for ind = 1:numel(fieldName);
                    try
                        this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                    catch errmsg
                        disp(errmsg);
                    end
                end
            else
                error('itaMSTFbandpass::wrong input arguments given to the constructor');
            end
            
            % Define listeners to automatically call the init function of
            % this class in case of a change the the below specified
            % properties.
            addlistener(this,'filterType','PreSet',@this.init);
            addlistener(this,'filterOrder','PreSet',@this.init);
        end
        
        function init(this,varargin)
            % init - Initialize the itaMSTF class object.
            %
            % This function initializes the itaMSTF class object by
            % deleting its excitation, causing the excitation to be built
            % anew, according to the properties specified in the
            % measurement setup, the next time it is needed.
            
            ita_verbose_info('MeasurementSetup::Initializing...',1);
            this.excitation = itaAudio;
            this.mFinalExcitation = itaAudio;
            this.compensation     = itaAudio;
        end
        
        function res = get_final_excitation(this)
            % get the corrected excitation (outputamplification) and
            % calibrated (using outputMeasurementChain) compensation
            if isempty(this.mFinalExcitation)
                res  = this.raw_excitation; %not greater than 0dBFS
                % now apply the bandpasses
                freqFilters = get_freqFilters(this);
                exc = res*freqFilters;
                % window out zerophase effects at the end
                exc = ita_time_window(exc,res.trackLength - [0.7 0.5].*this.stopMargin,'time');
                if strcmpi(this.type,'exp')
                    % careful this only works for strictly exponential sweeps
                    fr = this.finalFreqRange;
                    % sweep rate, do this again because excitation has changed
                    swprt = log2(fr(2)/fr(1))./(res.trackLength - this.stopMargin);
                    % time when the filter is at -90dB (-84 from xover) or
                    % at least 10ms
                    tGoal = max(0.01,(log2(this.freqRange(1,2)/fr(1))-14/this.filterOrder)/swprt);
                    % window out pre-ringing for all channels but the first one
                    exc = merge(exc.ch(1),ita_time_window(exc.ch(2:exc.nChannels),[1.05 1].*tGoal,'time'));
                    % TODO (MMT): check for correct excitation signal
                end
                this.mFinalExcitation = exc;
            end
            res = this.mFinalExcitation * this.outputamplification_lin;
        end
        
        function res = get_freqFilters(this)
            % make the bandpasses
            nFilters = size(this.freqRange,1);
            flat = ita_generate('flat',1,this.samplingRate,this.fftDegree);
            if nFilters > 1 && numel(this.outputChannels) ~= nFilters && numel(this.outputChannels) ~= 1
                error('Number of output channels does not match the number of filters');
            elseif nFilters == 1
                filters = flat;
            else
                % iterative filter generation to achieve correct sum
                % zerophase, just want amplitude attenuation
                filters = itaAudio([nFilters 1]);
                freqRange = this.freqRange;
                filterCall = 'ita_filter_LiRi';
                if strcmpi(this.filterType,'butter')
                    filterCall = 'ita_mpb_filter';
                end
                filters(1) = abs(eval([filterCall '(flat,[0 max(freqRange(1,:))],''order'',this.filterOrder)']));
                overlappingFlag = false;
                for iFilter = 2:nFilters
                    if min(freqRange(iFilter,:)) < max(freqRange(iFilter-1,:)) || overlappingFlag % overlapping filters
                        filters(iFilter) = abs(eval([filterCall '(flat,[min(freqRange(iFilter,:)) max(freqRange(iFilter,:))],''order'',this.filterOrder)']));
                        overlappingFlag = true;
                    else % make filters form the perfect impulse if added
                        residual = flat - sum(filters(1:iFilter-1));
                        if iFilter < nFilters
                            filters(iFilter) = abs(ita_filter_LiRi(residual,[0 max(this.freqRange(iFilter,:))],'order',this.filterOrder));
                        else
                            filters(iFilter) = abs(residual);
                        end
                    end
                end
                
                filters = merge(filters);
            end
            % apply bandpasses
            res = filters;
            bandStr = mat2str(this.freqRange);
            bandStr = regexp(bandStr(2:end-1),';','split');
            channelNamesStr = cell(numel(bandStr),1);
            for iStr = 1:numel(bandStr)
                channelNamesStr{iStr} = ['Excitation, Output Channel #' num2str(iStr) ' [' bandStr{iStr} ']'];
            end
            res.channelNames = channelNamesStr;
        end
        
        function set_freqRange(this, value)
            if size(value,2) ~= 2
                error('Frequency range must have dimensions [nBands, 2]');
            else
                this.mFreqrange = value;
            end
        end
        
        function set.filterType(this,value)
            if ischar(value) && ismember(value,this.possibleFilterTypes)
                this.mFilterType = value;
            else
                error('Wrong input for filterType');
            end
        end
        
        function res = get.filterType(this)
            res = this.mFilterType;
        end
        
        function set.filterOrder(this,value)
            if isnumeric(value)
                if value < 1 || value > 100
                    error('value for filterOrder is not within the allowed range ([1 100])');
                else
                    this.mFilterOrder = value;
                end
            else
                error('filterOrder has to be numeric!');
            end
        end
        
        function res = get.filterOrder(this)
            res = this.mFilterOrder;
        end
        
        function sObj = saveobj(this)
            % saveobj - Saves the important properties of the current
            % measurement setup to a struct.
            
            sObj = saveobj@itaMSTF(this);
            % Get list of properties to be saved for this measurement
            % class.
            propertylist = itaMSTFbandpass.propertiesSaved;
            
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
            result = {'mFilterType','mFilterOrder'};
        end
        
        function this = loadobj(sObj)
            % loadobj - Creates a new measurement setup and loads the
            % properties of a save struct into it.
            %
            % This function creates a new measurement setup by calling the
            % class constructor and passes it the specified save struct.
            
            this = itaMSTFbandpass(sObj);
        end
    end
end