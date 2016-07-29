classdef itaHDF5 < dynamicprops

% <ITA-Toolbox>
% This file is part of the application BulkyAudioData for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    % This class allows to store and retrieve itaAudio/itaResult data stored
    % in a HDF5 file on your hard drive. The data can be of infinite size,
    % as only subsets of the data are accessed. Data stored in this way can
    % be either or both time and freq domain, the properties validTime and
    % validFreq state the validity of these domains individually and can
    % (and should) be adjusted manually when writing data to the file.
    %
    % Syntax:
    %   h5 = itaHDF5(filename);  % initialize the HDF5 workspace in a .h5 file
    %   h5 = itaHDF5(filename, true);  % open with read-write access
    %   h5.writable = true;  % enable write-access
    %   h5.new('test');  % create a new dataset named 'test'
    %   h5.test.set_audio(audioObj, 1); % stores audioObj in ch1 of the h5-file
    %   h5.test.freq = freqdata; % stores freqdata as complete dataset in 'test'
    %   h5.test.set_freq(freqdata, :, 10); % stores freqdata in channel (:,10) of 'test'
    %   h5.test.get_time(1:200,50:100); % retrieves partial data in time domain
    %   h5 = itaHDF5.create; % create a new file from a set of .ita-data, l�ook below inside of itaHDF5.create for details
    %   h5_cloned = h5.clone('new_filename.h5'); % clones a HDF5-file
    %   h5.apply(@ita_time_window, [0.01 0.012], 'time');  % apply a standard ITA-Toolbox function to all channels
    
    properties
        filename  % the filename of the .h5 file
    end
    properties(Dependent)
        writable  % if the .h5 file is opened writable
    end
    properties
        mat  % an instance of a class created by builtin "matfile"
    end
    
    methods
        function this = itaHDF5(varargin)
            % constructor: call with filename as argument, writable as 2nd
            % argument
            if ~nargin, error('Call itaHDF5(filename) with a file name(s) as input parameter.'), end
                                    
            % check for old MATLAB versions which have a bug
            a = version;
            if str2double(a(1)) < 8
                ita_disp('Please use MATLAB 2012a or later for using this class. There is a bug in the previous versions that bloats up your .h5 file.')
                ita_disp('Check http://www.mathworks.co.uk/support/bugreports/784028 for details.')
            end
            
            if nargin && isa(varargin{1},'char')
                % add the file ending .h5 if no extension is given
                if isempty(strfind(varargin{1},'.'))
                    % no dot given
                    varargin{1} = [varargin{1} '.h5'];
                end
                this.filename = varargin{1};
            end
            
            % default writable flag
            writable = false;
            if ~exist(this.filename, 'file')
                writable = true;
                disp('HDF5-File does not exist, creating new file in case data is stored')
            end            
            if nargin > 1
                % set write property by explicit input argument
                writable = logical(varargin{2});
            end
            
            this.mat = matfile(this.filename, 'Writable', writable);
            this.update();
        end
        function value = get.writable(this)
            value = this.mat.Properties.Writable;
        end
        function set.writable(this, value)
            this.mat.Properties.Writable = logical(value);
        end
        function update(this)
            % re-loads the dynamic properties
            props = [];
            fields = fieldnames(this.mat);
            % check for this ending in the properties
            fieldname = '_cartesianCoordinates';
            nfields = length(fieldname);
            for ind = 1:numel(fields)
                try
                    if strcmp(fields{ind}(end-nfields+1:end), fieldname)
                        dataset_name = fields{ind}(1:end-nfields);
                        props = cat(1, props, addprop(this, dataset_name));
                        this.(dataset_name) = itaHDF5data(this, dataset_name);
                    end
                catch
                    %pass
                end
            end
        end
        
%         function visualize(this, varargin)
%             system(['itaBalloonGUI.py ' this.filename ' ' varargin{:}]);
%         end
        
        %% helper functions
        %         function value = get.filesize(this)
        %             % todo: implement file size output here
        %             value = nan();
        %         end
        function this = new(this, varargin)
            % creates a new dataset
            % Syntax:
            %   h5.new('new_name')
            
            if ~this.writable
                error('Please open the HDF5 file with rw-access (''Writable'',true)');
            end
            
            if nargin < 2
                varName = 'new_data';
            elseif numel(varargin) > 1
                for ind = 1:numel(varargin)
                    this.new(varargin{ind});
                end
                return
            else
                varName = varargin{:};
            end
            try
                % add the dynamic property of the new dataset name
                addprop(this, varName);
                this.(varName) = itaHDF5data(this, varName);
                this.(varName).init;
            catch
                warning(['itaHDF5: Dataset of name ' varName ' already exists. I am using this one.'])
            end
%             this.update;
        end
        % apply
        function apply(this, function_handle, varargin)
            names = fieldnames(this);
            for ind = 1:numel(names)
                if isa(this.(names{ind}), 'itaHDF5data')                    
                    ita_disp(names{ind})
                    this.(names{ind}).apply(function_handle, varargin{:})
                end
            end            
        end
        function that = clone(this, filename)
            disp(['Cloning:     ' this.filename '   to   ' filename ' ...']);
            copyfile(this.filename, filename);
%             system(['cp -a ' this.filename ' ' filename]);
            that = itaHDF5(filename);
            that.writable = true;
            disp('...DONE')
        end
        function fft(this)
            this.apply(@fft)
        end
        function ifft(this)
            this.apply(@ifft)
        end
    end
    methods(Hidden)
        %   add_dataset called from static create method:
        function this = add_dataset(this, folder, type, post_processing_handle, bundle_number)
            % This function adds a dataset from a set of .ita files in the
            % given folder. The function is called from the .create()
            % function of this class.
            %
            % Usually the .ita files are of two dimensions:
            % [time/freq  x  channels]
            %
            % However, for some measurements, a bunch of directions are
            % measured simultaeously (e.g. using the HRTF-Arc).
            % These files will be interpreted correctly if the .ita files
            % are of the following dimensionality:
            % [time/freq  x  channels  x  directions]
            
            % ignore . and .. or hidden files
            if folder(1) == '.', return, end
            
            % check for .ita files
            filelist = dir([folder filesep '*.ita']);
            if ~numel(filelist)
                if numel(dir([folder filesep 'data']))
                   % there are no .ita files, but a data folder
                   folder = [folder filesep 'data'];
                   % so set the new path and theck there for .ita files
                   filelist = dir([folder filesep '*.ita']);
                   if ~numel(filelist)
                       return
                   end
                else                    
                    return
                end
            end
            
            % sort files of "[1..n].ita" by their numbers
            filenumber = zeros(numel(filelist),1);
            for ind = 1:numel(filelist)
                filenumber(ind) = str2double(filelist(ind).name(1:end-4));
            end
            [~, index] = sort(filenumber);
            filelist = filelist(index);
            
            % it is a folder with .ita files in it: import it as a dataset
            nFiles = numel(filelist);
            
            disp(['  processing ' folder ' (' num2str(nFiles) ' files) using bundles of ' num2str(bundle_number) ' files']);
            
            % check if there is a processing file in the current folder
            filename_processing = ['.' filesep folder '.m'];
            processing_txt = '';
            if exist(filename_processing, 'file')
                filename_processing_handle = str2func(folder);
                
                fid = fopen(filename_processing);
                tline = fgetl(fid);
                while ischar(tline)
                    %                 processing_txt = [processing_txt tline '/n'];
                    processing_txt = [processing_txt sprintf('%s\n', tline)]; %#ok<AGROW>
                    tline = fgetl(fid);
                end
                disp(['    applying the folder processing file ' folder])
                fclose(fid);
            else
                % pass
                filename_processing_handle = @(x) x;
            end
            
            filename_processing = [func2str(post_processing_handle) '.m'];
            if ~strcmp(filename_processing, '@(x)x.m');
                try
                    fid = fopen(filename_processing);
                    tline = fgetl(fid);
                    % check here for a possible bug with empty lines
                    while ischar(tline)
                        %                 processing_txt = [processing_txt tline '/n'];
                        processing_txt = [processing_txt sprintf('%s\n', tline)]; %#ok<AGROW>
                        tline = fgetl(fid);
                    end
                    fclose(fid);
                catch
                    ita_disp(['Error opening the processing file: ' filename_processing], 0);
                end
            end
            
            % open single file to check for channels and dimensions
            audioObj = ita_read([folder filesep filelist(1).name]);
            nChannels_other = audioObj.dimensions(1);
            nChannels_spatial = prod(audioObj.dimensions(2:end));
            
            nDirections = nFiles * nChannels_spatial;
            coords = itaCoordinates(nDirections);
            
            datafield = [];
            
            % do not use the dataset name "data", use mother folder instead
            ind = strfind(folder,'/');
            if numel(ind) == 1
                % this is "name/data" format
                varName = folder(1:(ind-1));
            elseif strcmp(folder,'data')
                % "data" format
                [~, varName] = fileparts(pwd);
            else
                % foldername format
                varName = folder;
            end
            
            this.new(varName);
            
            %% initialize data
            %% todo: implement this for both and native
            switch type
                case 'time'
                    if nChannels_other == 1
                        this.(varName).set_time(1,audioObj.nSamples, nDirections);
                    else
                        this.(varName).set_time(1,audioObj.nSamples, nDirections, nChannels_other);
                    end
                case 'freq'
                    if nChannels_other == 1
                        this.(varName).set_freq(1,audioObj.nBins, nDirections);
                    else
                        this.(varName).set_freq(1,audioObj.nBins, nDirections, nChannels_other);
                    end
            end
            
            
            channelNames = cell(nDirections, 1);
            channelUnits = cell(nDirections, 1);
            
            max_time = 0;
            max_freq = 0;
            
%             % check for existing data, do not overwrite it
%             startFile = 1;
%             try
%                 startFile = this.(varName).size_time(2) + 1 - bundle_number;
%                 
%             catch
%                 try
%                     startFile = this.(varName).size_freq(2) + 1 - bundle_number;
%                 catch
%                     % nix
%                 end
%             end
%             if startFile > 1, ita_disp(['found old data, starting from file ' num2str(startFile)]); end
            startFile = 1
            
            tic
            for k = startFile:nFiles
                audioObj = ita_read([folder filesep filelist(k).name]); % app: aus dataset wird name
                audioObj = filename_processing_handle(audioObj);
                
                if prod(audioObj.dimensions(2:end)) ~= nChannels_spatial
                    error('Number of spatial channels does not match.')
                end
                
                % use channels as new 3rd dimension
                % new 2nd dimension is spatial information
                datafield = cat(2, datafield, permute(audioObj.(audioObj.domain), [1 3 2]));
                
                % calculate indices for the global data and the single file
                index_global_start = (k - 1) * nChannels_spatial + 1;
                index_global_end = k * nChannels_spatial;
                index_global = index_global_start:index_global_end;
                index_single = 1 : nChannels_other : (nChannels_other*nChannels_spatial);
                
                % set meta-data
                coords.cart(index_global,:) = audioObj.channelCoordinates.cart(index_single,:);
                channelNames(index_global,:) = (audioObj.channelNames(index_single));
                channelUnits(index_global,:) = (audioObj.channelUnits(index_single));
                
                if mod(k, bundle_number) && k < nFiles
                    % block of files not yet full
                    continue;
                end
                
                audioObj.(audioObj.domain) = datafield;
                datafield = [];
                
                if k == nFiles && mod(k, bundle_number)
                    maxVal = nChannels_spatial * mod(k, bundle_number); 
                else
                    maxVal = nChannels_spatial * bundle_number; 
                end
                
                % recalculate index for the block
                index_global_start = k * nChannels_spatial - maxVal + 1; %% zillekens: ???
                index_global = index_global_start:index_global_end;
                
                audioObj = post_processing_handle(audioObj); 
                is_timedomain = strcmp(audioObj.domain, 'time');
                disp(['    ' num2str(k) ' from ' num2str(nFiles) ' processed (using ' func2str(post_processing_handle) ')'])

                switch type
                    case 'time'
                        this.(varName).set_audio_time(audioObj, index_global);
                        max_time = max(max_time, max(abs(audioObj.timeData(:))));                        
                    case 'freq'
                        this.(varName).set_audio_freq(audioObj, index_global);
                        max_freq = max(max_freq, max(abs(audioObj.freqData(:))));
                    case 'both'
                        this.(varName).set_audio_both(audioObj, index_global);
                        max_time = max(max_time, max(abs(audioObj.timeData(:))));
                        max_freq = max(max_freq, max(abs(audioObj.freqData(:))));
                    case 'native'
                        this.(varName).set_audio(audioObj, index_global);
                        if is_timedomain
                            max_time = max(max_time, max(abs(audioObj.timeData(:))));
                        else
                            max_freq = max(max_freq, max(abs(audioObj.freqData(:))));
                        end
                    otherwise
                        error('I do not know this type of processing...')
                end
                toc
                tic
            end  % end of processing loop
            toc
            switch type
                case 'time'
                    this.(varName).validTime = true;
                case 'freq'                    
                    this.(varName).validFreq = true;
                case 'both'
                    this.(varName).validTime = true;
                    this.(varName).validFreq = true;
                case 'native'
                    if is_timedomain
                        this.(varName).validTime = true;
                        this.(varName).validFreq = false;
                    else
                        this.(varName).validTime = false;
                        this.(varName).validFreq = true;
                    end
            end
            
            % get the start date and time of the measurement
            tmp = dir([folder '/1.ita']);
            % check for possible error here (missing 1.ita)
            if isempty(tmp)
                error('Expecting a file named 1.ita, but not found.')
            end
            dateMeasurement = tmp.date;
            
            % todo: this.data.dataset = dirlist(1).dataset;
            
%             this.(varName) = itaHDF5data(this, folder);
            
            this.(varName).userName = ita_preferences('AuthorStr');
            this.(varName).userEmail = ita_preferences('EmailStr');
            this.(varName).dateCreation = datestr(now);
            this.(varName).dateMeasurement = dateMeasurement;
            this.(varName).pathRawData = pwd;
            this.(varName).processing = processing_txt;
            this.(varName).coordinates = coords;
            this.(varName).comment = audioObj.comment;
            this.(varName).channelNames = channelNames;
            this.(varName).channelUnits = channelUnits;
            this.(varName).maxFreq = max_freq;
            this.(varName).maxTime = max_time;            
            disp('    storing data....        DONE')
        end        
    end
    methods(Static)
        function h5 = create(type, post_processing_handle, bundle_number)
            % This function creates a h5-file from a set of .ita spherical
            % measurements. Start this script in the folder that contains
            % the folders with the measurement sets of .ita files.
            % Available parameters:
            %   'type' can be 'native', 'time', 'freq' or 'both', the
            %       latter storing the data if both domains
            %   'post_processing_handle' is optional and allows to give a
            %       function that eats and processes itaAudios.
            %       Additionally for each folder name a script with the
            %       same name (+ '.m' ending) is called, useful e.g. for
            %       coordinate transforms.
            %   'bundle_number' is an integer with the number of files
            %       being processed before using the (slow) Matlab-HDF5
            %       function. Default is 100.
            %
            % Example: h5 = itaHDF5.create('native', @batch_processing, 500)
            
            if ~nargin
                type = 'native';
                disp(['using default save type: ' type])
            end
            if nargin < 2
                % default: no post processing
                post_processing_handle = @(x) x;
            end
            if nargin < 3
                % default: process 100 files at once
                bundle_number = 100;
            end
            
            dirlist = dir('.');
            
            % kick out the non-directories and . and ..
            for ind = numel(dirlist):-1:1
                if ~dirlist(ind).isdir || dirlist(ind).name(1) == '.'
                    % take out the non dirs
                    dirlist(ind) = [];
                end
            end
            nFiles = numel(dirlist);
            
            % h5filename is current folder name
            % in case there is no processing done, we add the term '_raw'
            [~, h5filename] = fileparts(pwd);
            is_raw = strcmp(func2str(post_processing_handle), '@(x)x');
            if is_raw, h5filename = [h5filename '_raw']; end
            h5 = itaHDF5(h5filename, true);
            
            %             if nFiles == 1 && strcmp(dirlist.name,'data')
            %                 dirlist.name = h5filename;
            %             end
            
            disp('******** Start processing files ********');
            for ind = 1:nFiles
                disp('__')
                h5.add_dataset(dirlist(ind).name, type, post_processing_handle, bundle_number);
%                 h5.data_list = [this.data_list, h5.];
            end
            disp('********        D O N E         ********');
%             h5.update;
        end
    end
    methods(Hidden)
        % this ist just to hide all the handle functions...
        function varargout = addlistener(this, varargin), varargout = this.addlistener@handle(varargin); end
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
