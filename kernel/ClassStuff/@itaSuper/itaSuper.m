classdef itaSuper < itaMeta
    
    
    %ITASUPER - Mother of all ita data-object classes (itaAudio/itaResult)
    %   Detailed explanation goes here
    %
    %   Reference page in Help browser
    %   <a href="matlab:doc itaSuper">doc itaSuper</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private, Hidden = true)
        % Internal fields, no access from outside the class
        mData = [];
        mDimensions = 0;
        mDomain = 'time';                % 'time' / 'freq'
        mChannelNames = {};
        mChannelUnits = {};
        mChannelCoordinates = itaCoordinates();
        mChannelOrientation = itaCoordinates();
        mChannelSensors = {};
        mChannelUserData = {};
        mAllowDBPlot = true;
        
        % up and view vector for hrtf data
        mObjectCoordinates = itaCoordinates();
        mObjectViewVector = itaCoordinates();
        mObjectUpVector = itaCoordinates();
        
        mDataType = 'double';           % Type for internal data
        mDataTypeOutput = 'double';     % Type used for output
        mDataTypeEqual = true;          % On/Off Switch for data type casts (speed reason)
        mDataFactor = 1;                % Factor for scaling if using int
    end
    
    properties(Constant, Hidden = true)
        % display options
        LINE_LENGTH  = 90;
    end
    
    %     properties(Abstract)
    %         % Properties that all sub-classes have but are not used in this class
    %         %freqVector
    %         %timeVector
    %     end
    
    properties(Dependent = true, Hidden = false)
        
        time %time domain data (get/set) - full dimensions
        timeData %time domain data in 2D
        
        freq %frequency domain data (get/set) - full dimensions
        freqData %frequency domain data in 2D
        
        
        nBins %number of frequency samples called bins
        nSamples % number of time samples
        
        domain % domain of data ('time'/'freq')
        dimensions % dimensions of the data field
        
        dataType %raw data type, data is stored in... (single/double)
        dataTypeOutput %data type when you access data (single/double), conversion
        
        channelNames %Names for each channel (cell string)
        channelUnits %Units for each channel (cell string)
        channelCoordinates %Coordinates for each channel (have to be itaCoordinates)
        channelOrientation %Orientation for each channel (have to be itaCoordinates)
        channelUserData %arbitrary userdata for each channel (cell array)
        
        allowDBPlot % Does a dB Plot make any sense ?
        
        objectCoordinates   % the coordinates of the measured object
        objectViewVector    % view direction of the measured object
        objectUpVector      % up vector of the measured object
    end
    properties(Dependent = true, Hidden = true)
        channelSensors %Sensor name for each channel (cell string)
        data %raw data, could be time or frequency domain (CAREFUL!)
        dataFactor %ask RSC?
    end
    methods
        
        function this = itaSuper(varargin)
            % Constructor
            % Calls:
            %   itaMeta() - Empty object
            %   itaMeta(n) or itaMeta([x y z]) - Preinitialize n*n or x*y*z objects
            %   itaMeta(itaMeta) - Copy-Constructor
            %   itaMeta(Struct) - convert/import struct
            %   itaMeta( ... ,n) or itaMeta(... , [a b c]) - Prinitialize with datafield size a*b*c
            
            %this = this@itaMeta(varargin);
            
            if nargin == 0
                %Nothing to do
            elseif nargin >= 1
                if isnumeric([varargin{:}]) % Preinitialize n-Instances
                    if any([varargin{:}] > 1)
                        this = repmat(this,[varargin{:}]);
                    end
                end
                if isa(varargin{1},mfilename) % Copy-Constructor
                    prop = properties(varargin{1});
                    % first tell domain and data, otherwise errors might occur
                    prop = [{'domain';'data'}; prop];              % 3.8.11 added data, mpo
                    % all domain specific data is not needed here
                    % TODO: Shift this somehow to itaAudio.m
                    try
                        prop{strcmp(prop,'dat')} = 'VOID';
                    catch %#ok<CTCH>
                        ita_verbose_info('constructor of itaSuper: skipping property dat');
                    end
                    try
                        prop{strcmp(prop,'spk')} = 'VOID';
                    catch %#ok<CTCH>
                        ita_verbose_info('constructor of itaSuper: skipping property spk');
                    end
                    prop{strcmp(prop,'time')} = 'VOID';
                    prop{strcmp(prop,'timeData')} = 'VOID';
                    prop{strcmp(prop,'freq')} = 'VOID';
                    prop{strcmp(prop,'freqData')} = 'VOID';
                    
                    for ind = 1:length(prop)
                        try
                            this.(prop{ind}) = varargin{1}.(prop{ind});
                        catch
                            ita_verbose_info(['constructor of itaSuper: ignoring property ' prop{ind}]);
                        end
                    end
                end
                if isstruct(varargin{1}) % Struct input/convert
                    fieldName = fieldnames(varargin{1});
                    preDataFields = {'domain', 'dataType', 'dataTypeOutput','mDataFactor','dataFactor'}; %RSC: Fields that must be set bevor data may be set
                    for idfn = 1:numel(preDataFields)
                        if find(strcmpi(fieldName,preDataFields{idfn})) > find(strcmpi(fieldName,'data'))
                            idx = find(strcmpi(fieldName,preDataFields{idfn}));
                            varargin{1} = orderfields(varargin{1},[idx,1:idx-1,idx+1:numel(fieldName)]);
                            fieldName = fieldnames(varargin{1});
                        end
                    end
                    for ind = 1:numel(fieldName)
                        try
                            this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg
                            disp(errmsg);
                        end
                    end
                end
            end
            if nargin == 2
                for idx = 1:numel(this)
                    this(idx).mData = deal(nan(varargin{2})); %#ok<AGROW>
                end
            end
            
            %% Add history line
            commitID = ita_git_getMasterCommitHash;
            if ~isempty(commitID)
                this = ita_metainfo_add_historyline(this,'GitVersion',commitID);
            end
        end
        
        
        %% Get/set Stuff
        function result = get.time(this)
            % output n-dimensions
            result = reshape(this.timeData, [this.nSamples this.dimensions]);
        end
        function this = set.time(this,value)
            dimensionsValue = size(value);
            this.timeData = reshape(value, dimensionsValue(1), []);
            this.dimensions = dimensionsValue(2:end);
        end
        function result = get.freq(this)
            % output n-dimensions
            result = reshape(this.freqData, [this.nBins this.dimensions]);
        end
        function this = set.freq(this,value)
            dimensionsValue = size(value);
            this.freqData = reshape(value, dimensionsValue(1), []);
            this.dimensions = dimensionsValue(2:end);
        end
        
        function result = get.timeData(this)
            this = ifft(this);
            result = this.data;
        end
        function this = set.timeData(this,value)
            this.domain = 'time';
            this.data = value;
        end
        function result = get.freqData(this)
            this = fft(this);
            result = this.data;
        end
        
        function this = set.freqData(this,value)
            this.domain = 'freq';
            this.data = value;
        end
        
        function result = get.data(this)
            result = get_data(this);
        end
        
        function this = set.data(this,value)
            sizeValue = size(value);
            
            if numel(sizeValue) > 2
                error([upper(mfilename) '.set.data  only 2D-data is allowed, use .freq or .time for higher dimensions']);
            end
            
            % BMA: Vector can be given as columns or rows.
            %if sizeValue(1) == 1
            %    value = value(:); % RSC - there is a bug here a = itaResult; a.freq = zeros(1,3); leads to a result with 3 bins and 3 channels
            %end
            
            this = set_data(this, value);
            this.dateModified = datevec(now);
            
            if prod(this.dimensions) ~= sizeValue(2)
                % only set the dimensions if there is inconsistent data
                this.dimensions = sizeValue(2);
            end
        end
        
        function result = get.domain(this)
            result = this.mDomain;
        end
        function this = set.domain(this,value)
            % only do something if there is a change
            if strcmpi(this.domain, value)
                return;
            end
            
            % the domain will be switched, data set to NaNs
            %             nChannels = this.nChannels;
            switch lower(value)
                case 'time'
                    %                   this.data = nan(this.nSamples, nChannels);
                    this.mDomain = 'time';
                case 'freq'
                    %                     nBins = this.nBins;
                    this.mDomain = 'freq';
                    %                    this.data = nan(nBins, nChannels) + 1i * nan(nBins, nChannels);
                otherwise
                    error('%s:I don''t know this domain.',upper(mfilename))
            end
        end
        
        %% Channel Stuff
        function this = channelDelete(this, idxChDelete)
            % Example: oAudio = oAudio.channelDelete(1); %object has to be
            % set to itself again, since itaSuper is no handle class.
            validateattributes(idxChDelete,{'numeric'},{'vector','nonempty','integer'})
            if numel(this) > 1 
                ita_verbose_info('This does not work for multiinstance itaAudio objects.',0);
                return;
            end
            idxChToKeep              = 1:this.nChannels;
            idxChToKeep(idxChDelete) = [];
            this                     = this.ch(idxChToKeep);
        end
            
        function result = get.channelNames(this)
            result = this.mChannelNames;
            if numel(result) ~= this.nChannels
                result(end+1:this.nChannels) = {''};
                result(this.nChannels+1:end) = [];
            end
        end
        function this = set.channelNames(this,value)
            if iscellstr(value)
                if numel(value) ~= this.nChannels
                    value(end+1:this.nChannels) = {''};
                    value(this.nChannels+1:end) = [];
                end
                this.mChannelNames = value(:);
            else
                error('itaAudio: Wrong data type for channelNames. channelNames has to be cell of strings.')
            end
        end
        
        function result = get.channelUnits(this)
            result = this.mChannelUnits;
            if numel(result) ~= this.nChannels
                result(end+1:this.nChannels) = {''};
                result(this.nChannels+1:end) = [];
            end
        end
        function this = set.channelUnits(this,value)
            if iscellstr(value)
                if numel(value) ~= this.nChannels
                    value(end+1:this.nChannels) = {''};
                    value(this.nChannels+1:end) = [];
                end
                this.mChannelUnits = value(:);
            elseif ischar(value) %pdi: all channels with the same unit
                for idx = 1:this.nChannels
                    this.mChannelUnits{idx} = value;
                end
            elseif isa(value,'itaValue')
                this.mChannelUnits{1} = value.unit;
            else
                error('itaAudio: Wrong data type for channelUnits')
            end
        end
        
        function result = get.channelCoordinates(this)
            result = this.mChannelCoordinates;
            if result.nPoints ~= this.nChannels
                %if result.nPoints < this.nChannels
                result = resize(result,this.nChannels);
            end
        end
        function this = set.channelCoordinates(this,value)
            if isa(value,'itaCoordinates')
                if isa(value,'itaSamplingSPH')
                    value = itaCoordinates(value);
                end
                if numel(value) ~= this.nChannels
                    value = resize(value,this.nChannels);
                end
                this.mChannelCoordinates = value(:);
            else
                error('itaAudio: Wrong data type for channelCoordinates')
            end
        end
        
        function result = get.channelOrientation(this)
            result = this.mChannelOrientation;
            if numel(result) ~= this.nChannels
                %if result.nPoints < this.nChannels
                result = resize(result,this.nChannels);
            end
        end
        function this = set.channelOrientation(this,value)
            if isa(value,'itaCoordinates')
                if numel(value) ~= this.nChannels
                    value = resize(value,this.nChannels);
                end
                this.mChannelOrientation = value(:);
            else
                error('itaAudio: Wrong data type for channelOrientation')
            end
        end
        
        function result = get.channelSensors(this)
            result = this.mChannelSensors;
            if numel(result) ~= this.nChannels
                result(end+1:this.nChannels) = {''};
                result(this.nChannels+1:end) = [];
            end
        end
        function this = set.channelSensors(this,value)
            if iscellstr(value)
                if numel(value) ~= this.nChannels
                    value(end+1:this.nChannels) = {''};
                    value(this.nChannels+1:end) = [];
                end
                this.mChannelSensors = value(:);
            else
                error('itaAudio: Wrong data type for channelSensors')
            end
        end
        
        function result = get.channelUserData(this)
            result = this.mChannelUserData;
            if numel(result) ~= this.nChannels
                result(end+1:this.nChannels) = {[]};
                result(this.nChannels+1:end) = [];
            end
        end
        function this = set.channelUserData(this,value)
            if iscell(value)
                if numel(value) ~= this.nChannels
                    value(end+1:this.nChannels) = {[]};
                    value(this.nChannels+1:end) = [];
                end
                this.mChannelUserData = value(:);
            else
                error('itaAudio: Wrong data type for channelUserData')
            end
        end
        
        function result = get.dimensions(this)
            result = this.mDimensions;
        end
        function this = set.dimensions(this,value)
            if isnumeric(value)
                nChannels = prod(value);
                if nChannels > prod(this.dimensions)
                    this.channelNames(end+1:nChannels) = {''};
                    this.channelUnits(end+1:nChannels) = {''};
                    this.channelCoordinates = resize(this.channelCoordinates,nChannels);
                    this.channelOrientation = resize(this.channelOrientation,nChannels);
                    this.channelSensors(end+1:nChannels) = {''};
                    this.channelUserData(end+1:nChannels) = {[]};
                elseif nChannels < prod(this.dimensions)
                    this.channelNames(nChannels+1:end) = [];
                    this.channelUnits(nChannels+1:end) = [];
                    this.channelCoordinates = resize(this.channelCoordinates,nChannels);
                    this.channelOrientation = resize(this.channelOrientation,nChannels);
                    this.channelSensors(nChannels+1:end) = [];
                    this.channelUserData(nChannels+1:end) = [];
                else
                    % nothing to do
                end
                this.mDimensions = value;
            else
                error('itaAudio: dimensions must be numeric!')
            end
        end
        
        %% Other Stuff
        function result = get.allowDBPlot(this)
            result = this.mAllowDBPlot;
        end
        
        function this = set.allowDBPlot(this,value)
            this.mAllowDBPlot = value;
        end
        
        
        function result = get.objectCoordinates(this)
            result = this.mObjectCoordinates;
        end
        
        function this = set.objectCoordinates(this,value)
            this.mObjectCoordinates = value;
        end
        
        function result = get.objectViewVector(this)
            result = this.mObjectViewVector;
        end
        
        function this = set.objectViewVector(this,value)
            this.mObjectViewVector = value;
        end
        
        function result = get.objectUpVector(this)
            result = this.mObjectUpVector;
        end
        
        function this = set.objectUpVector(this,value)
            this.mObjectUpVector = value;
        end
        
        function write(this,varargin)
            %writes audioObj to disk
            ita_write(this.merge,varargin{:})
        end
        function result = get.dataType(this)
            result = class(this.mData);
        end
        function this = set.dataType(this,value)
            this = cast(this,value);
        end
        
        function result = get.dataTypeOutput(this)
            result = this.mDataTypeOutput;
        end
        function this = set.dataTypeOutput(this,value)
            this.mDataTypeOutput = value;
            if strcmp (this.dataType, value)
                this.mDataTypeEqual = true;
            else
                this.mDataTypeEqual = false;
            end
            if strncmp('int', value, 3)
                ita_verbose_info('Sorry, but ''int'' is really dangerous for dataTypeOutput, please use double or single.',1)
            end
        end
        
        function result = get.dataFactor(this)
            result = this.mDataFactor;
        end
        
        function this = set.dataFactor(this,value)
            this.mDataFactor = value;
            if value ~= 1
                ita_verbose_info('Please be carefull setting dataFactor!');
            end
        end
        
        function result = get.nBins(this)
            result = get_nBins(this);
        end
        
        function result = get.nSamples(this)
            result = get_nSamples(this);
        end
        
        function this = set.nSamples(this,value)
            this = set_nSamples(this,value);
        end
        
        function result = nChannels(this)
            % get the number of channels
            %dims = size(this.data);
            %result = prod(dims(2:end));
            result = prod(this.dimensions(:));
        end

        function res = get_diag(this)
			% use eye as mask for diagonal
			res = this(eye(size(this,1)));
        end

        function this = diag(this,diagonalshift,blocksize)
            %diagonal of matrix, or build diagonal matrix out of vector
            if nargin == 1 || isempty(diagonalshift)
                diagonalshift = max(size(this));
            end
            if nargin <= 2
                blocksize = 1;
            end
            
            if blocksize == 1
                if size(this,1) > 1 && size(this,2) > 0
                    for idx = 1:blocksize:size(this,1)
                        for jdx = 1:blocksize:size(this,2)
                            if ~(mod(idx,diagonalshift) == mod(jdx,diagonalshift) ) %elements not on the diagonal must be set to zero
                                this(idx,jdx) = this(idx,jdx)*0;
                            end
                        end
                    end
                end
            else
                if size(this,1) > 1 && size(this,2) > 0
                    for idx = 1:blocksize:size(this,1)
                        for jdx = 1:blocksize:size(this,2)
                            
                            %                             this(idx,jdx) = this(idx,jdx)*0;
                            idxx = idx:1:min(idx+diagonalshift/blocksize-1,size(this,1)); %get indeces of submatrix
                            jdxx = jdx:1:min(jdx+diagonalshift/blocksize-1,size(this,2));
                            submatrix = this(idxx , jdxx);
                            
                            if ~(mod(idx,diagonalshift) == mod(jdx,diagonalshift) ) %elements not on the diagonal must be set to zero
                                submatrix = submatrix * 0;
                            else
                                %                                 submatrix = diag(submatrix,1);
                            end
                            
                            this (idxx, jdxx) = submatrix;
                            
                        end
                    end
                end
            end
            
            %             else % diagonal shift
            %                 if size(this,1) > 1 && size(this,2) > 0
            %                     for idx = 1:diagonalshift:size(this,1)
            %                         for jdx = 1:diagonalshift:size(this,2)
            %
            %
            %
            %                         end
            %                     end
            %                 end
            
        end
        
        
        function result = split(this, index)
            %split different channels of the Obj to a new Obj
            if numel(this) > 1 % Multi Instance splitting
                result = this;
                for idx = 1:numel(this)
                    result(idx) = this(idx).split(index);
                end
                return;
            end
            
            if numel(this.dimensions) == 2
                newindex = [];
                for idx = 1:numel(index)
                    newindex = [newindex index(idx):this.mDimensions(1):prod(this.mDimensions)]; %#ok<AGROW>
                end
                index = newindex;
            else
            end
            
            %pdi: we have to use a different output variable. otherwise the
            %channel information gets lost! changing 'this' to 'result'
            result = this;
            
            % only use the reduced data
            result.data = this.data(:,index);
            
            % mpo: if we are dealing with a logical index, do a different
            % determination of the dimensions
            if islogical(index)
                result.dimensions = sum(index);
            else
                result.dimensions = numel(index);
            end
            
            % and select the appropriate Channel struct(s)
            %% merge channelInfo
            channelFields = properties(this);
            channelFields = channelFields(strncmp('channel',channelFields,7));
            
            for idchfield = 1:numel(channelFields)
                thisFieldName = channelFields{idchfield};
                if any(strcmp('split',methods(this.(thisFieldName)))) % Check if it has a split-function
                    result.(thisFieldName) = split(this.(thisFieldName),index);
                else % just use cat
                    result.(thisFieldName) = this.(thisFieldName)(index);
                end
            end
        end
        
        function this = merge(this, varargin)
            % merge several Objs to only one Obj
            
            % Only one
            if nargin == 1 && numel(this) == 1
                return;
                
                % Array
            elseif nargin == 1 && numel(this) > 1
                if any(isempty(this(:))) % any empty objects
                    ita_verbose_info(sprintf('Merge: Skipping %i empty objects.',sum(isempty(this(:)) )),1)
                    this = this(~isempty(this(:)));
                end
                this2 = this(2:end);
                this = this(1);
                for idx = 1:numel(this2)
                    this = merge(this,this2(idx));
                end
                
                % Cell
            elseif iscell(this)
                this = [this{:}];
                this = merge(this);
                return;
                
                % called merge(a1,a2,a3,a4,...)
            elseif nargin > 2
                for idx = 1:numel(varargin)
                    this = merge(this,varargin{idx});
                end
                
                % second argument is a cell
            elseif iscell(varargin{1})
                tmp = varargin{1};
                this = [tmp{:}];
                clear tmp;
                this = merge(this);
                
                % Two itaAudios
            elseif isa(varargin{1},'itaSuper')
                if isempty(this)
                    this = varargin{1};
                else
                    this2 = varargin{1};
                    [this, this2] = prepare4merge(this,this2);
                    
                    %% merge data
                    thischannels = this.nChannels;
                    this.data = [this.data  this2.data];
                    
                    %% merge channelInfo
                    channelFields = properties(this);
                    channelFields = channelFields(strncmp('channel',channelFields,7));
                    
                    for idchfield = 1:numel(channelFields)
                        thisFieldName = channelFields{idchfield};
                        if any(strcmp('merge',methods(this.(thisFieldName)))) % Check if it has a merge-function
                            this.(thisFieldName) = merge(split(this.(thisFieldName),(1:thischannels)),  this2.(thisFieldName));
                        else % just use cat
                            this.(thisFieldName) = [this.(thisFieldName)(1:thischannels);  this2.(thisFieldName)(:)];
                        end
                    end
                    
                    %% Merge history
                    this = ita_metainfo_add_historyline(this,'merge',this2,'withSubs');
                end
            else
                ita_verbose_info('merge@itaSuper: I dont know what to do with this argument, ignoring it',0);
            end
            
        end
        
        function [this1, this2] = prepare4merge(this1, this2)
            % Prepare two object for merge, check if compatible and try to fix problems
            
            %% Check
            
            if ~strcmpi(this1.domain,this2.domain)
                error('Merge: These objects won''t work together: ill-suited domain')
            end
            if this1.nSamples ~= this2.nSamples 
                error('Merge: These objects won''t work together: ill-suited number of samples');
            end
            if ~strcmp(class(this1),class(this2)) 
                error('Merge: These objects won''t work together: ill-suited class');
            end
            if  numel(this1.dimensions) ~= numel(this2.dimensions)
                error('Merge: These objects won''t work together: ill-suited dimensions');
            end

            
        end
        
        function result = ch(this, channels)
            %split single channels from multichannel Obj
            result = split(this,channels); %pdi
            %             if nargin > 1
            %                 result.data = this.data(:,channels);
            %             end
        end
        
        
        %% new plot naming
        function plot_cmplx(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_cmplx(this,varargin{:})
        end
        function plot_freq(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_freq(this,varargin{:})
        end
        function plot_phase(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_phase(this,varargin{:})
        end
        function plot_freq_phase(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_freq_phase(this,varargin{:})
        end
        function plot_freq_groupdelay(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_freq_groupdelay(this,varargin{:})
        end
        function plot_time(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_time(this,varargin{:})
        end
        function plot_time_dB(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_time_dB(this,varargin{:})
        end
        function plot_spectrogram(this,varargin)
            %plot spectrogram (itaAudio)
            ita_plot_spectrogram(this,varargin{:})
        end
        function plot_all(this,varargin)
            %plot everything in one plot (if freq and time data available)
            ita_plot_all(this,varargin{:})
        end
        
        
        %% get DATA in dB
        function result = freqData_dB(this,varargin)
            %Returns frequency data in dB
            [sArgs] = ita_parse_arguments(struct('log_prefix',[]),varargin);
            
            %get logarithmic frequency data 20*log10(abs(Obj.freq)/referenceValue)
            [~,  refValues, log_prefix] = itaValue.log_reference(this.channelUnits);
            if sArgs.log_prefix
                log_prefix = sArgs.log_prefix;
            end
            % changed from log10(x) to log(x)/log(10) because it is faster
            result = bsxfun(@times, log_prefix(:).'./log(10), log(abs(this.freqData + realmin))); %plus eps to avoid -Inf
            result = bsxfun(@plus,result, log_prefix(:).'./log(10).*log(1./refValues(:).'));
        end
        
        function result = timeData_dB(this,varargin)
            %Returns frequency data in dB
            [sArgs] = ita_parse_arguments(struct('log_prefix',[]),varargin);
            
            %get logarithmic frequency data 20*log10(abs(Obj.freq)/referenceValue)
            [~,  refValues, log_prefix] = itaValue.log_reference(this.channelUnits);
            if sArgs.log_prefix
                log_prefix = sArgs.log_prefix;
            end
            % changed from log10(x) to log(x)/log(10) because it is faster
            result = bsxfun(@times, log_prefix(:).'./log(10), log(abs(this.timeData + realmin))); %plus eps to avoid -Inf
            result = bsxfun(@plus,result, log_prefix(:).'./log(10).*log(1./refValues(:).'));
        end
        
        %% Overloaded functions
        
        function scatter(this,freq,varargin)
            %plot data by using coordinates
            % scatter(Obj, freq(double), ['axishandle',handle, 'size', double, 'title', titleStr])
            sArgs = struct('axishandle',[],'size',10,'title',this.comment,'noabs',false,'filled','square');
            sArgs = ita_parse_arguments(sArgs,varargin);
            if isempty(sArgs.axishandle)
                figure;
            else
                axes(sArgs.axishandle);
            end
            if sArgs.noabs
                scatter(this.channelCoordinates.x,this.channelCoordinates.y, ...
                    this.freq2value(freq)*0+sArgs.size,(this.freq2value(freq)),'filled',sArgs.filled);
            else
                scatter(this.channelCoordinates.x,this.channelCoordinates.y, ...
                    this.freq2value(freq)*0+sArgs.size,abs(this.freq2value(freq)),'filled',sArgs.filled);
            end
            axis image; colorbar
            title([sArgs.title ' (' this.channelUnits{1} ') - ' num2str(freq) ' Hz ' ]);
            xlabel('x');
            ylabel('y');
        end
        
        
        %         function pcolor(this,freq,varargin)
        %             %plot data by using coordinates
        %             % pcolor(Obj, freq(double), ['axishandle',handle, 'size', double, 'title', titleStr])
        % pdi: does not work in this way !!!
        %             sArgs = struct('axishandle',[],'size',10,'title',this.comment,'noabs',false);
        %             sArgs = ita_parse_arguments(sArgs,varargin);
        %             if isempty(sArgs.axishandle)
        %                 figure;
        %             else
        %                 axes(sArgs.axishandle);
        %             end
        %             if sArgs.noabs
        %                 pcolor(this.channelCoordinates.x,this.channelCoordinates.y, ...
        %                 this.freq2value(freq));
        %             else
        %                 pcolor(this.channelCoordinates.x,this.channelCoordinates.y, ...
        %                     this.freq2value(freq)*0+sArgs.size,abs(this.freq2value(freq)),'filled','square');
        %             end
        %             axis image; colorbar
        %             title([sArgs.title ' (' this.channelUnits{1} ') - ' num2str(freq) ' Hz ' ]);
        %             xlabel('x');
        %             ylabel('y');
        %         end
        
    end
    
    methods(Hidden = true)
        % shortcuts for plots!
        function pt(this,varargin)
            ita_plot_time(this,varargin{:})
        end
        function ptd(this,varargin)
            ita_plot_time_dB(this,varargin{:})
        end
        function pf(this,varargin)
            ita_plot_freq(this,varargin{:})
        end
        function pfp(this,varargin)
            ita_plot_freq_phase(this,varargin{:})
        end
        function pfg(this,varargin)
            ita_plot_freq_groupdelay(this,varargin{:})
        end
    end
    
    %% ******** Hidden Methods *******************************************
    methods(Hidden = true)
        function res = legend(this,varargin)
            % build a cell of strings for the plot legend
            if nargin == 1
                mode = 'log';
            else
                mode = varargin{1};
            end
            tmp_channelNames = this.channelNames;
            tmp_channelUnits = this.channelUnits;
            tmp_channelUnits(strcmpi(tmp_channelUnits,'')) = {'1'};
			res = cell(1,this.nChannels);
            for idx = 1:this.nChannels
                if strcmpi(mode,'nodb')
                    res{idx} = [tmp_channelNames{idx} ' [' tmp_channelUnits{idx} ']' ];
                elseif strcmpi(mode,'nothing')
                    res{idx} = [tmp_channelNames{idx}];
                else
                    res{idx} = [tmp_channelNames{idx} ' [dB re ' itaValue.log_reference( tmp_channelUnits{idx}) ']' ];
                end
            end
        end
        
		% TODO What is this supposed to do?
        % function res = log_reference(this)
        %     
        % end
        
        function result = get_data(this)
            if ~this.mDataTypeEqual || any(this.mDataFactor ~= 1)
                if strncmp('int', this.dataTypeOutput, 3)
                    result = cast(this.mData,this.dataTypeOutput);
                else
                    result = cast(this.mData,this.dataTypeOutput)  .* this.mDataFactor;
                end
            else
                result = this.mData;
            end
        end
        function this = set_data(this,value)
            % this functions is needed for class itaAudioDevNull
            % and for the check of even number of samples
            if ~isa(value, this.dataType)
                if any(strncmp('int', this.dataType, 3)) && ~any(strcmp('int', this.dataTypeOutput, 3))
                    this.dataFactor = double(max(max(abs(value)))) ./ (double(intmax(this.dataType))-1);
                    value = value ./ this.mDataFactor;
                end
                wstate = [warning('off','MATLAB:intConvertNonIntVal') warning('off','MATLAB:intConvertNaN')];
                this.mData = cast(value,this.dataType);
                warning(wstate);
                ita_verbose_info('Changing data-type. Some information may be lost',2)
            else
                this.mData = value;
            end
        end
        function result = get_nBins(this)
            if this.isFreq
                result = size(this.data,1);
            else
                result = this.nSamples2nBins;
            end
        end
        
        function result = get_nSamples(this)
            if this.isTime
                result = size(this.data,1);
            else
                result = this.nBins2nSamples;
            end
        end
        
        %% is* Stuff
        function result = isTime(this)
            result = zeros(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).domain,'time');
            end
        end
        function result = isFreq(this)
            result = zeros(size(this));
            for ind = 1:numel(result)
                result(ind) = strcmp(this(ind).domain,'freq');
            end
        end
        
        function result = isempty(this)
            result = false(size(this));
            for idx = 1:numel(this)
                result(idx) = isempty(this(idx).data);
            end
        end
        function nBins = nSamples2nBins(this)       %#ok<MANU>
            nBins = NaN;
        end
        
        function nSamples = nBins2nSamples(this) %#ok<MANU>
            nSamples = NaN;
        end
        
        function sObj = saveobj(this)
            
            % Called whenever an object is saved
            sObj = saveobj@itaMeta(this);
            
            this.dataTypeOutput = this.dataType; % Save the extact data we really have
            
            % Copy all properties that were defined to be saved
            propertylist = itaSuper.propertiesSaved;
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
        
        function displayLineStart(this)
            %internal stuff
            classnameString = ['|' class(this) '|'];
            result = this.LINE_START;
            result(3:(2+length(classnameString))) = classnameString;
            disp(result);
        end
        function displayChannelString(this,fHandle)
            prefName = 'dispVerboseChannels'; dispName = 'channels';
            global lastDiplayedVariableName
            nChannels = this.nChannels;
            if nChannels == 1; dispName = dispName(1:end-1); end %get rid off plural 's'
            dispName = [num2str(nChannels) ' ' dispName ' (' this.dimString ') ' ];
            if ita_preferences('dispVerboseChannels')
                middleLine = this.LINE_MIDDLE;
                middleLine(3:(2+length(dispName))) = dispName;
                fprintf(['<a href = "matlab: ita_preferences(''' prefName ''',0); display(' lastDiplayedVariableName ')">-</a> ' middleLine(3:end) '\n']);
                fHandle(this);
            else
                fprintf(['<a href = "matlab: ita_preferences(''' prefName ''',1); display(' lastDiplayedVariableName ');">+</a> ' dispName '\n']);
            end
        end
        
        function displayOptions(this, prefName, fHandle)
            global lastDiplayedVariableName
            dispName = lower(prefName(12:end));
            if strcmp(dispName,'channels')
                nChannels = this.nChannels;
                if nChannels == 1; dispName = dispName(1:end-1); end %get rid off plural 's'
                dispName = [num2str(nChannels) ' ' dispName ' (' this.dimString ') ' ];
            end
            dispName = [dispName ' '];
            if ~strcmpi(prefName, 'dispVerboseErrors') || any(numel(this.errorLog)) % get rid off error display if no errors
                if ita_preferences(prefName)
                    middleLine = this.LINE_MIDDLE;
                    middleLine(3:(2+length(dispName))) = dispName;
                    fprintf(['<a href = "matlab: ita_preferences(''' prefName ''',0); display(' lastDiplayedVariableName ')">-</a> ' middleLine(3:end) '\n']);
                    fHandle(this);
                else
                    fprintf(['<a href = "matlab: ita_preferences(''' prefName ''',1); display(' lastDiplayedVariableName ');">+</a> ' dispName '\n']);
                end
            end
        end
        function displayLineEnd(this)
            disp(this.LINE_END);
        end
        function displayEndOfClass(this, classname)
            classnameString = ['(' classname ')'];
            result = repmat(' ', 1, length(this.LINE_START) - length(classnameString));
            disp([result classnameString]);
        end
        
        function result = unit(this,value)
            % get or set itaValues where the units are the same as in the itaSuper
            if nargin == 1 % only get
                for idx = 1:size(this,1)
                    for jdx = 1:size(this,2)
                        for ndx = 1:this(idx,jdx).nChannels
                            result(idx,jdx,ndx) = itaValue(1,this(idx,jdx).channelUnits{ndx});
                        end
                    end
                end
            else % set values
                for idx = 1:size(this,1)
                    for jdx = 1:size(this,2)
                        for ndx = 1:this(idx,jdx).nChannels
                            this(idx,jdx,ndx).channelUnits{ndx} = value(idx,jdx);
                        end
                    end
                end
                result = this;
            end
        end
        
        function plot_multiple(this,plotStr,varargin)
            % plot multi instance in subplots
            %
            % syntax e.g. ARRAY.plot_multiple('plot_freq',xlim,[100 5000])
            h = ita_plottools_figure;
            
            for idx = 1:numel(this)
                axh(idx) = subplot(numel(this), 1, idx);
                this(idx).(plotStr)('axes_handle',axh(idx), 'figure_handle',h,varargin{:});
            end
            linkaxes(axh);
            
        end
        
    end
    
    methods(Hidden = true)
        function showHistory(this)
            display(this)
            disp('  History Log ')
            ita_metainfo_show_history(this);
        end
        
        function dimString = dimString(this)
            % get a nice dimension string
            dimString = [];
            tmp_dimensions = this.dimensions;
            for ind = 1:numel(tmp_dimensions)
                dimString = [dimString num2str(tmp_dimensions(ind))]; %#ok<AGROW>
                if ind < numel(tmp_dimensions)
                    dimString = [dimString ' x ']; %#ok<AGROW>
                end
            end
        end
        
        %% some plot routine routes
        function plot_TPA(this,varargin)
            ita_plot_TPA(this,varargin{:})
        end
        
        function plot_spkphase(this,varargin)
            %plot spectrum and phase (if freq data available)
            ita_plot_freq_phase(this,varargin{:})
        end
        function plot_spkgdelay(this,varargin)
            %plot spectrum and group delay (if freq data available)
            ita_plot_freq_groupdelay(this,varargin{:})
        end
        function plot_spk(this,varargin)
            %plot spectrum (if freq data available)
            ita_plot_freq(this,varargin{:})
        end
        function plot_dat(this,varargin)
            %plot time history (if time data available)
            ita_plot_time(this,varargin{:})
        end
        function plot_dat_dB(this,varargin)
            %plot time energy history  (if freq data available)
            ita_plot_time_dB(this,varargin{:})
        end
        
    end
    
    
    
    %% Static Methods
    methods(Static, Hidden = true)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            sObj.dataType = class(sObj.data); % Set dataType equal to class(data)
            this = itaSuper(sObj); % Just call constructor, he will take care
            switch this.dataType(1:3)
                case {'int'}
                    this.dataTypeOutput = 'single'; %Save solution
                otherwise
                    this.dataTypeOutput = this.dataType;
            end
        end
        function result = metaDataFields
            % meta data fields for copying
            result = {'channelNames','channelUnits','channelCoordinates','channelOrientation','channelSensors','channelUserData',...
                'comment' 'history','objectCoordinates','objectViewVector','objectUpVector'};
        end
        function result = propertiesSaved
            % important: first domain, then data
            result = {'domain','data','dimensions',...
                'channelNames','channelUnits','channelCoordinates',...
                'channelOrientation','channelSensors','channelUserData',...
                'dataType','dataTypeOutput','dataFactor','allowDBPlot','objectCoordinates','objectViewVector','objectUpVector'};
        end
        function res = LINE_MIDDLE()
            res = repmat('-',1,itaSuper.LINE_LENGTH);
        end
        function res = LINE_END()
            res = repmat('-',1,itaSuper.LINE_LENGTH);
        end
        function res = LINE_START()
            res = repmat('=',1,itaSuper.LINE_LENGTH);
        end
        
    end
end

