classdef itaHDF5data < handle

% <ITA-Toolbox>
% This file is part of the application BulkyAudioData for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    % Use the get_* and set_* functions for parital access of the data
    %
    % It is also possible to access .time and .freq (but it will access all
    % data and potentially fill up your RAM)
    
    properties
        name
    end
    properties(Dependent)
        samplingRate
        size_time
        size_freq
        validTime
        validFreq
        
        coordinates
        comment
    end
    properties(Dependent, Hidden)
        time    % accessor for all time data, use get_time for partial data
        freq    % accessor for all freq data, use get_freq for partial data
        ao      % accessor for all data in valid domain (default: time domain)
        
        userName
        userEmail
        dateCreation
        dateMeasurement
        pathRawData
        processing
        
        channelNames
        channelUnits
        maxFreq
        maxTime
    end
    properties(Hidden)
        mat     % this is a link to the object of the mother class
    end
    methods
        %% constructor
        function this = itaHDF5data(h5, name)
            this.mat = h5.mat;
            if nargin > 1
                this.name = name;
            end
        end
        %% initializer
        function init(this)
            this.maxFreq = 0;
            this.maxTime = 0;
            this.coordinates = itaCoordinates();
            this.comment = 'freshly created dataset in itaHDF5';
            this.samplingRate = 44100;
            this.channelNames = {''};
            this.channelUnits = {''};
            this.userName = ita_preferences('AuthorStr');
            this.userEmail = ita_preferences('EmailStr');
            this.dateCreation = datestr(now);
            this.validTime = false;
            this.validFreq = false;
        end
        %% get size of data
        function value = get.size_time(this)
            value = [];
            try
                sizeTime = size(this.mat, [this.name '_time']);
                if prod(sizeTime)
                    value = sizeTime;
                end
            catch
            end
        end
        function value = get.size_freq(this)
            value = [];
            try
                value = size(this.mat, [this.name '_freqReal']);
            catch
            end
        end
        %% get functions
        function value = get.name(this), value = this.name; end
        function value = get.time(this)
            value = this.get_time;
        end
        function value = get.freq(this)
            value = this.get_freq;
        end
        function value = get.ao(this)
            value = this.get_audio;
        end
        function value = get.userName(this), value = this.get_field('userName'); end
        function value = get.userEmail(this), value = this.get_field('userEmail'); end
        function value = get.dateCreation(this), value = this.get_field('dateCreation'); end
        function value = get.dateMeasurement(this), value = this.get_field('dateMeasurement'); end
        function value = get.pathRawData(this), value = this.get_field('pathRawData'); end
        function value = get.processing(this), value = this.get_field('processing'); end
        function value = get.coordinates(this), value = itaCoordinates(this.get_field('cartesianCoordinates')); end
        function value = get.comment(this), value = this.get_field('comment'); end
        function value = get.channelNames(this), value = cellstr(this.get_field('channelNames')); end
        function value = get.channelUnits(this), value = cellstr(this.get_field('channelUnits')); end
        function value = get.maxFreq(this), value = this.get_field('maxFreq'); end
        function value = get.maxTime(this), value = this.get_field('maxTime'); end
        function value = get.samplingRate(this), value = this.get_field('samplingRate'); end
        function value = get.validTime(this)
            value = this.get_field('isValidTime');
        end
        function value = get.validFreq(this)
            value = this.get_field('isValidFreq');
        end
        %% set functions
        function set.name(this, value), this.name = value; end
        function set.time(this, value)
            ao = itaAudio();
            ao.time = value;
            this.set_audio_time(ao);
        end
        function set.freq(this, value)
            ao = itaAudio();
            ao.freq = value;
            this.set_audio_freq(ao);
        end
        function set.ao(this, value)
            this.(value.domain) = value.(value.domain);
        end
        function set.userName(this, value), this.set_field('userName', value); end
        function set.userEmail(this, value), this.set_field('userEmail', value); end
        function set.dateCreation(this, value), this.set_field('dateCreation', value); end
        function set.dateMeasurement(this, value), this.set_field('dateMeasurement', value); end
        function set.pathRawData(this, value), this.set_field('pathRawData', value); end
        function set.processing(this, value), this.set_field('processing', value); end
        function set.coordinates(this, coord), this.set_field('cartesianCoordinates', coord.cart); end
        function set.comment(this, comment), this.set_field('comment', comment); end
        function set.channelNames(this, channelNames), this.set_field('channelNames', char(channelNames)); end
        function set.channelUnits(this, channelUnits), this.set_field('channelUnits', char(channelUnits)); end
        function set.maxFreq(this, value), this.set_field('maxFreq', value); end
        function set.maxTime(this, value), this.set_field('maxTime', value); end
        function set.samplingRate(this, value), this.set_field('samplingRate', value); end
        function set.validTime(this, value), this.set_field('isValidTime', value); end
        function set.validFreq(this, value), this.set_field('isValidFreq', value); end
        
        %% other get/set functions for high level access of data
        function value = get_time(this, varargin), value = this.get_field('time', varargin{:}); end
        function value = get_freq(this, varargin), value = this.get_field_complex('freq', varargin{:}); end
        function set_time(this, time, varargin)
            this.set_field('time', time, varargin{:});
            this.validTime = true;
        end
        function set_freq(this, freq, varargin)
            this.set_field_complex('freq', freq, varargin{:});
            this.validFreq = true;
        end
        
        %% low-level accessor fields
        function value = get_field(this, field, varargin)
            if isempty(varargin)
                value = this.mat.([this.name '_' field]);
            else
                value = this.mat.([this.name '_' field])(varargin{:});
            end
        end
        function value = get_field_complex(this, field, varargin)
            value = this.get_field([field 'Real'], varargin{:}) + ...
                1i .* this.get_field([field 'Imag'], varargin{:});
        end
        function set_field(this, field, value, varargin)
            if ~this.mat.Properties.Writable
                error('HDF5 file is opened read-only. Set the .writable property to true')
            end
            
            % eliminate "/" in the filename, just use part before "/"
            tmp_name = this.name;
            ind = strfind(tmp_name,'/');
            if ind
                tmp_name = tmp_name(1:(ind-1));
            end
            
            nValue = ndims(value);
            nVarargin = numel(varargin);
            if nVarargin > 0
                % check dimensions
                if nValue ~= nVarargin
                    if nValue > nVarargin
                        for ind = 1:(nValue - nVarargin)
                            varargin = [varargin {1:size(value,ind+nVarargin)}];
                        end
                    else
                        error('Number of dimensions does not match.');
                    end
                end
                
                % check for identical sizes
                for ind = 1:ndims(value)
                    if size(value,ind) ~=  numel(varargin{ind})
                        if strcmp(varargin{ind},':')
                            % use a linear index from the value field
                            varargin{ind} = 1:size(value,ind);
                        else
                            error(['Size does not match in dimension ' num2str(ind) ' of the itaAudio object.']);
                        end
                    end
                end
                this.mat.([tmp_name '_' field])(varargin{:}) = value;
            else
                this.mat.([tmp_name '_' field]) = value;
            end
        end
        function set_field_complex(this, field, value, varargin)
            this.set_field([field 'Real'], real(value), varargin{:});
            this.set_field([field 'Imag'], imag(value), varargin{:});
        end
        
        %% set audio data
        function set_audio_time(this, ao, varargin)
            % check for a channel information
            if nargin > 2
                varargin = [{1:ao.nSamples}; varargin(:)];
            end
            this.set_time(ao.time, varargin{:});
            if isa(ao, 'itaAudio')
                this.set_field('samplingRate', ao.samplingRate);
                this.set_field('isPower', logical(ao.isPower));
            else
                % itaResult
                this.set_field('timeVector', ao.timeVector);
            end
            %             this.validFreq = false;
        end
        function set_audio_freq(this, ao, varargin)
            % check for a channel information
            if nargin > 2
                varargin = [{1:ao.nBins}; varargin(:)];
            end
            this.set_freq(ao.freq, varargin{:});
            if isa(ao, 'itaAudio')
                this.set_field('samplingRate', ao.samplingRate);
                this.set_field('isPower', logical(ao.isPower));
            else
                % itaResult
                this.set_field('freqVector', ao.freqVector);
            end
            %             this.validTime = false;
        end
        function set_audio_both(this, ao, varargin)
            % choose the order to have only one transform
            if strcmp(ao.domain,'time')
                this.set_audio_time(ao, varargin{:});
                this.set_audio_freq(ao, varargin{:});
            else
                this.set_audio_freq(ao, varargin{:});
                this.set_audio_time(ao, varargin{:});
            end
            this.validTime = true;
            this.validFreq = true;
        end
        function set_audio(this, ao, varargin)
            if strcmp(ao.domain,'time')
                this.set_audio_time(ao, varargin{:});
            else
                this.set_audio_freq(ao, varargin{:});
            end
        end
        %% get audio data
        function ao = get_signalType(this, ao)
            if this.get_field('isPower')
                ao.signalType = 'power';
            else
                ao.signalType = 'energy';
            end
        end
        function ao = get_audio_time(this, varargin)
            if ~this.validTime
                ita_disp('Time domain not valid in the stored hdf5 file')
            end
            if nargin > 1
                varargin = [{':'} varargin];
            end
            ao = itaAudio;
            ao.samplingRate = this.samplingRate;
            ao.time = this.get_time(varargin{:});
            ao = this.get_signalType(ao);
        end
        function ao = get_audio_freq(this, varargin)
            if ~this.validFreq
                ita_disp('Freq domain not valid in the stored hdf5 file')
            end
            if nargin > 1
                varargin = [{':'} varargin];
            end
            ao = itaAudio;
            ao.samplingRate = this.samplingRate();
            ao.freq = this.get_freq(varargin{:});
            ao = this.get_signalType(ao);
        end
        function ao = get_audio(this, varargin)
            if this.validTime
                ao = this.get_audio_time(varargin{:});
            elseif this.validFreq
                ao = this.get_audio_freq(varargin{:});
            else
                error('No valid domain found.')
            end
        end
        %% apply functions
        function apply(this, function_handle, varargin)
            if numel(varargin)
                string = [', ...' num2str(numel(varargin)) ' parameters...'];
            else
                string = '';
            end
            disp(['calling: ' func2str(function_handle) '(' this.name, string, ')'])
            if this.validTime
                higherDims = this.size_time(2:end);
                get_function = @this.get_audio_time;
            elseif this.validFreq
                higherDims = this.size_freq(2:end);
                get_function = @this.get_audio_freq;
            else
                error('no valid domain found');
            end
            
            tic
            for ind1 = 1:higherDims(1)
                %                 if ~mod(ind1,25), disp(num2str(ind1)), end
                if numel(higherDims) == 1
                    ind = {ind1};
                else
                    ind = {ind1, 1:higherDims(2:end)};
                end
                ao = get_function(ind{:});
                ao_target = function_handle(ao, varargin{:});
                this.set_audio(ao_target, ind{:});
                if ind1 == 10
                    elapsedTime = toc;
                    disp(['Estimated speed: ' num2str(higherDims(1)/ind1*elapsedTime) ' seconds ...now calculating...']);
                end
            end
            disp('...DONE')
            
            
            % domain of target is important
            isTime = strcmp(ao_target.domain, 'time');
            isFreq = strcmp(ao_target.domain, 'freq');
                        
%             % if data was shrunken, set the dimensions
            if isTime && this.size_time(1) > ao.nSamples
                disp('  shrinking time data')
                fieldname = [this.name '_time'];
                truncate(this, fieldname, ao.nSamples);
            elseif isFreq && this.size_freq(1) > ao.nBins
                disp('  shrinking freq data')
                fieldname = [this.name '_freqReal'];
                truncate(this, fieldname, ao.nBins);
                fieldname = [this.name '_freqImag'];
                truncate(this, fieldname, ao.nBins);
            end
%             this.validTime = isTime;
%             this.validFreq = isFreq;
        end
        function truncate(this, fieldname, nData)
            sizeData = size(this.mat, fieldname);
            rangeData = {1:nData};
            for ind = 2:numel(sizeData)
                rangeData = [rangeData, 1:sizeData(ind)];
            end
            this.mat.(fieldname) = this.mat.(fieldname)(rangeData{:});
        end
        function ifft(this)
            this.apply(@ifft);
        end
        function fft(this)
            this.apply(@fft);
        end
    end
    methods(Hidden)
        % this ist just to hide all the handle functions...
        function varargout = addlistener(this, varargin), varargout = this.addlistener@handle(varargin); end
        function varargout = addprop(this, varargin), varargout = this.addprop@handle(varargin); end
        %         function varargout = isvalid(this, varargin), varargout = this.isvalid@handle(varargin); end
        function varargout = eq(this, varargin), varargout = this.eq@handle(varargin); end
        function varargout = findobj(this, varargin), varargout = this.findobj@handle(varargin); end
        function varargout = findprop(this, varargin), varargout = this.findprop@handle(varargin); end
        function varargout = ge(this, varargin), varargout = this.ge@handle(varargin); end
        function varargout = gt(this, varargin), varargout = this.gt@handle(varargin); end
        function varargout = le(this, varargin), varargout = this.le@handle(varargin); end
        function varargout = lt(this, varargin), varargout = this.lt@handle(varargin); end
        function varargout = ne(this, varargin), varargout = this.ne@handle(varargin); end
        function varargout = notify(this, varargin), varargout = this.notify@handle(varargin); end
        function varargout = delete(this, varargin), varargout = this.delete@handle(varargin); end
    end
end
