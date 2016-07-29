classdef itaFatSplitMatrix < handle

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

    % a data structure to administrate matrices, which are too big to keep
    % them in memory. Tha matrix is split into parts along its dimension
    % given by "splitDimension". The parts are swaped to .mat-Files in a
    % directory specified by "folder". 
    % 
    % internal proceeding: The property "currentSegmentData" contains the recently used 
    % data part, the flag "currentSegmentDataChanged" serves to observe, if
    % this data segmnent has been changed and therefor needs to be saved
    % before another segment is beeing loaded.
    %
    % initialize:
    %   this = itaFatSplitMatrix([size_1 size_2 size_3 ...], splitDimension, precision);
    %   this.folder = ...
    %   this.MBytesPerSegment = ...
    % 
    % access: 
    %   - this.set_data(index1, index2 , ..., data);
    %   - this.get_data(index1, index2 , ...);
    % 
    % see also: 
    % save(this), remove(this), copy(this, 'newFolder'), size(this),
    % ita_read_itaFatSplitMatrix('filename')
    
    %% ***************** Properties****************************************
    properties (Access = public)      
        comment = ' ';    
        name = 'this';     % object's name
    end
    properties(SetAccess = private, GetAccess = public, Hidden = true)
        nSegments = [];
    end
    properties(Dependent = true)
        folder;           % home directory (must be set!)
        dataFileName;     % default: 'data'
        dataFolderName;   % default: 'data' 
        MBytesPerSegment; % maximum size of a segment in MByte
        dimension;        % vector of matrix dimension [dim1 dim2...]
        splitDimension;   % index of matrix dimension beeing split up
        precision;        % 'double'(default) / 'single'
    end
    properties(Access = private)
        mFolder = []
        mDataFileName = 'data';
        mDataFolderName = 'data';
        mMBytesPerSegment = 50;
        mDimension = [];    % size
        mSplitDimension = []; % matrix is cut into segments along this dimension
        mPrecision = 'double';
        
        nInSegment = [];
        
        %temporary data
        currentSegmentData = [];   
        currentIdxSegment  = [];            % indicates, which segment is loaded
        currentSegmentDataChanged = false; % flag: segment changed (set in updateCurrentData and set_data)
    end
    
    %% ***************** methods ****************************************
    methods
        % % constructor
        function this = itaFatSplitMatrix(varargin)
            % input: size-vector, index of split dimension, precision (optional)
            % examples: out = itaFatSplitMatrix([3 4 1000 2], 3);
            %           out = itaFatSplitMatrix([3 4 1000 2], 3, 'single');
            
            % initialize
            if nargin >= 2 && isnumeric(varargin{1}) &&  isnumeric(varargin{1})
%                 this = itaFatSplitMatrix;
                this.dimension = varargin{1};
                this.splitDimension = varargin{2};
                
                if nargin == 3 && ischar(varargin{3}) %set data_type
                    this.precision = varargin{3};
                end
                this.setDataStructure;
            
            % copy
            elseif nargin && isa(varargin{1}, 'itaFatSplitMatrix')
%                 this = itaFatSplitMatrix;
                prop = this.propertiesSaved;
                for idx = 1:length(prop)
                    this.(prop{idx}) = varargin{1}.(prop{idx});
                end
            end
        end
        % % administration
        function save(this) %save Object to disk
            if ~isdir(this.folder)
                mkdir(this.folder)
            end
            save_currentData(this);
            s = struct(this.name, itaFatSplitMatrix(this)); %#ok<NASGU>
            save([this.folder filesep this.name], '-struct', 's');
        end
        function out = isempty(this)
            if ~isempty(this.folder) && (isdir([this.folder filesep this.dataFolderName]) ...
                    && numel([this.folder filesep this.dataFolderName filesep this.dataFileName '*.mat'])...
                    || this.currentSegmentDataChanged);
                out = false;
            else
                out = true;
            end
        end
        function out = size(this)
            out = this.dimension;
        end
        
        function set_data(this, varargin)
            % inserts data into the segmented matrix (see help)
            % input: indicess, data
            %
            % examples:
            %  this.set_data(id1, id2, id3, value);
            %  this.set_data(1:2, 2:4, [1 2 3; 4 5 6]);
            
            
            if isempty(this.folder)
                error('You must set a folder');
            end
            if isempty(this.dimension)
                error('You must set a dimension');
            end
            if isempty(this.splitDimension)
                error('You must set splitDimension');
            end
            
            % check input 
            index = this.check_index(varargin(1:end-1));
            sizeIndex = zeros(length(index),1);
            for idx = 1:length(index) % ???
                sizeIndex(idx) = length(index{idx});
            end
            
            
            
            idxS = this.index2segment(index{this.splitDimension});
            idxSu = unique(idxS(:,1));
            
            % only access one data segment at a time
            % otherwise the function calls itsel recursively
            if length(idxSu) > 1
                for idx = 1:length(idxSu)
                    
                    part2index = find(idxS(:,1) == idxSu(idx));
                    % cut the index into parts
                    index_part = index;
                    index_part{this.splitDimension} = index{this.splitDimension}(part2index);
                    
                    %cut the data into parts
                    idx_data_part = cell(length(this.dimension),1);
                    for idx2 = 1:length(this.dimension)
                        idx_data_part{idx2} = 1:length(index{idx2});
                    end
                    idx_data_part{this.splitDimension} = part2index;
                    
                    %call this function for each part
                    if length(varargin{end}) == 1
                        this.set_data(index_part{:}, varargin{end});
                    else
                        this.set_data(index_part{:}, varargin{end}(idx_data_part{:}));
                    end
                        
                end
                
            else
                % check if currentData must be saved and displaced
                updateCurrentData(this, idxSu);
                
                % relative index in segment
                index_rel = index;
                index_rel{this.splitDimension} = idxS(:,2);
                
                % write data
                this.currentSegmentData(index_rel{:}) = cast(varargin{end}, this.precision);
                this.currentSegmentDataChanged = true;               
            end
        end
        function data = get_data(this, varargin)
            % returns the matrix's data
            % out = get_data(this, varargin)
            % input  :   indicees 
            % output :   matrix(indicees)
            
            % index of the matrix
            index = this.check_index(varargin(1:end));
            
            % index of the segment
            idxS = this.index2segment(index{this.splitDimension});
            idxSu = unique(idxS(:,1));
            
            % index in the segment (init)
            idxInS  = index;
            
            % index in the outputdata (init)
            idxInD = cell(length(this.dimension),1);
            dim    = zeros(1, length(this.dimension));
            for idx = 1:length(this.dimension)
                idxInD{idx} = 1:length(index{idx});
                dim(idx) = length(index{idx});
            end
            dummy = idxInD{this.splitDimension};
            
            data = zeros(dim, this.precision);
            for idx = 1:length(idxSu)
                updateCurrentData(this, idxSu(idx));
                
                %update indicees                
                idxInS{this.splitDimension} = idxS(idxS(:,1)  == idxSu(idx), 2);
                idxInD{this.splitDimension} = dummy(idxS(:,1) == idxSu(idx));
                
                %copy data
                data(idxInD{:}) = this.currentSegmentData(idxInS{:});
            end
        end
        % % get-set of dependent stuff
        function set.MBytesPerSegment(this, in)
            if ~this.isempty 
                this.error_notempty;
            end
            this.mMBytesPerSegment = in;
            this.setDataStructure;
        end
        function out = get.MBytesPerSegment(this)
            out = this.mMBytesPerSegment;
        end
        function set.folder(this, in)
            this.mFolder = in;
        end
        function out = get.folder(this)
            out = this.mFolder;
        end
        function set.dataFileName(this, in)
            if ~this.isempty, this.error_notempty; end
            this.mDataFileName = in;
        end
        function out = get.dataFileName(this)
            out = this.mDataFileName;
        end
        function set.dataFolderName(this, in)
             if ~this.isempty, this.error_notempty; end
             this.mDataFolderName = in;
        end
        function out = get.dataFolderName(this)
            out = this.mDataFolderName;
        end
        function set.dimension(this, in)
            if ~this.isempty, this.error_notempty; end
            this.mDimension = in;
            this.setDataStructure;
        end
        function out = get.dimension(this)
            out = this.mDimension;
        end
        function set.splitDimension(this, in)
            if ~this.isempty, this.error_notempty; end
            this.mSplitDimension = in;
            this.setDataStructure;
        end
        function out = get.splitDimension(this)
            out = this.mSplitDimension;
        end
        function set.precision(this, value)
%             if ~this.isempty, this.error_notempty; end
            if ~strcmpi(value, 'double') && ~strcmpi(value, 'single')
                error('precision can be either "single" or "double"');
            end
            this.mPrecision = value;
        end
        function out = get.precision(this)
            out = this.mPrecision;
        end
        function remove(this)
            % deletes all corresponding files and folders
            if isdir([this.folder filesep this.dataFolderName])
                rmdir([this.folder filesep this.dataFolderName], 's');
            end
        end
        function son = copy(this, newFolder)
            % copies data to a new directory (syntax: copy(this, 'new_directory');)
            if ~exist('newFolder','var')
                error('Give me a folder where I shall copy your stuff!');
            end
            
            this.save_currentData;
            son = itaFatSplitMatrix(this);
            son.folder = newFolder;
            
            newDataFolder = [son.folder filesep this.dataFolderName];
            if ~isdir(newDataFolder)
                mkdir(newDataFolder)
            end
            copyfile([this.folder filesep this.dataFolderName], newDataFolder);
            save(son);
        end
    end
    %% ***************** methods , hidden ********************************
    methods(Hidden = true)
        function data = read(this,file) %#ok<MANU>
            % function value = read(this,file)
            % returns the first value in a Matlab-file "file"
            if ~exist(file,'file')
                if exist([file '.mat'],'file')
                    file = [file '.mat'];
                else
                    error(['There is no such file: ' file]);
                end
            end
            inFile = load(file);
            bla    = fieldnames(inFile(1));
            data  = inFile.(bla{1});
        end 
        function save_currentData(this)
            if this.currentSegmentDataChanged
                % I found no other way to save this, than first copying
                % the data, maybe there is another possibility
                data = this.currentSegmentData; %#ok<NASGU>
                if ~isdir([this.folder filesep this.dataFolderName])
                    mkdir([this.folder filesep this.dataFolderName]);
                end
                save([this.folder filesep this.dataFolderName filesep this.dataFileName int2str(this.currentIdxSegment) '.mat'], 'data');
                %update flag
                this.currentSegmentDataChanged = false;
            end
        end      
         function out = index2segment(this,index) 
            % rooting split matrix dimension 2 swapped segment
            if size(index,2) > 1
                index = index.';
            end
            out = [floor((index-1)/this.nInSegment)+1 mod((index-1), this.nInSegment)+1];
        end
        function index = segment2index(this,idxS, idxInS)
            % rooting swapped segment to split matrix dimensiom
            if nargin == 2 && numel(idxS) == 1
                index = (idxS-1)*this.nInSegment + (1:this.nInSegment);
                index = index(index <= this.dimension(this.splitDimension));
                
            elseif nargin == 2 && numel(idxS) == 2
                index = (idxS(1)-1)*this.nInSegment + idxS(2);
                if index > this.dimension(this.splitDimension)
                    error('Index exceeds matrix dimension');
                end
            elseif nargin == 3 && length(idxS) == length(idxInS)
                index = (idxS-1)*this.nInSegment + idxInS;
            else
                error('Wrong size of input arguments');
            end
            index = index(index ~=0);
        end
        
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
    
    %% ***************** methods , private ********************************
    methods(Access = private)
        function setDataStructure(this)
            if ~isempty(this.dimension) && ~isempty(this.splitDimension) ...
                    && ~isempty(this.MBytesPerSegment)
            dum = zeros(1,this.precision); %#ok<NASGU>
            a = whos('dum');
            idDim = 1:length(this.dimension); idDim = idDim(idDim ~= this.splitDimension);
            this.nInSegment = max(floor(this.MBytesPerSegment * 2^20 / a.bytes / prod(this.dimension(idDim)) / 2), 1);
            this.nSegments = ceil(this.dimension(this.splitDimension)/this.nInSegment);
            end
        end
        function updateCurrentData(this, idxSu)
            % checks if currentData must be saved and displaced
            
            % idxSu: index of the segment that shall be copied to
            % currentData
            if isempty(this.currentIdxSegment)
                load_new = true;
                
            elseif this.currentIdxSegment ~= idxSu
                this.save_currentData;
                load_new = true;
            else
                load_new = false;
            end
            
            if load_new % initialize / load segment data
                if exist([this.folder filesep this.dataFolderName filesep this.dataFileName int2str(idxSu) '.mat'], 'file')
                    this.currentSegmentData = this.read([this.folder filesep this.dataFolderName filesep this.dataFileName int2str(idxSu)]);
                else
                    dim = this.dimension;
                    dim(this.splitDimension) = size(this.segment2index(idxSu),2);
                    this.currentSegmentData = zeros(dim, this.precision);
                end
                
                % update flags
                this.currentIdxSegment = idxSu;
            end
        end   
        function error_dim(this) %#ok<MANU>
            error('index exceeds matrix dimension');
        end
        function error_notempty(this) %#ok<MANU>
            % some parameters my only be changed, if no data have been
            % saved jet.
            error('There are already data in your folder or object is not empty');
        end    
        function index = check_index(this, index)
            if length(index) ~= length(this.dimension)
                error('index size mismatch');
            else
                for idx = 1:length(this.dimension)
                    if max(index{idx}) > this.dimension(idx)
                        this.error_dim;
                    end
                end
            end
        end
    end
    methods(Static, Hidden = true)
        function result = propertiesSaved
           result =  {'comment','name','nSegments',...
               'mFolder','mDataFileName','mDataFolderName','mMBytesPerSegment',...
               'mDimension','mSplitDimension','mPrecision',...
               'nInSegment'};
        end
    end
end