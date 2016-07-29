function [out,varargout] = ita_read(filename,varargin)
%ITA_READ - This function reads supported files into the ITA-Toolbox class.
%
%   Call: itaClass = ita_read() opens a File GUI
%   Call: itaClass = ita_read(filename) opens file or directory
%   Call: itaClass = ita_read(filename, [sampleInterval],
%                                     [channelInterval],['time','sample'])
%                        reads only desired interval in file. If time
%                        interval can be given in time or samples (default)
%
%   Call: itaClass = ita_read(filename, options)
%
%   options:
%   interval:  [begin end], if scalar, then [1 int]
%   isTime:    is interval given in time? default = false
%   channels:  [begin end], if scalar, then [1 int]
%   metadata:  []    -> returns a struct only with the files metadata
%   extension: 'xxx' -> used to read only files of type xxx in a directory
%
%   See also ita_write
%
%$ENDHELP$
%
%==========================================================================
% This function opens different sub-functions depending on the type of the
% object named by the string NAME. This subfunctions should be saved at the
% directory "ita_read" and must have the following framework:
%
% fileType = ita_read_xxx() - Type of file that the function reads (.xxx)
%
% itaClass = ita_read_xxx(filename,options)
%                     Options are the same as listed above, given in the
%                     following format: 'optionName','optionValue',..
% itaClass = ita_read_xxx(filename,'metadata')
%                     Return itaAudioDevNull class without data information
%==========================================================================

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Initialize read directory
% scan directory
persistent extensionMap;
if isempty(extensionMap)
    [pathstr, name] = fileparts(mfilename('fullpath'));
    extensionMap = ita_io_get_daughter(pathstr, name);
end
nFiles = length(extensionMap);

%% Processing of optional input arguments
extensionType = '';
sArgs.isTime = false;
sArgs.metadata = false;
sArgs.interval = [];
sArgs.channels = [];

if (nargin > 1)
    if isnumeric(varargin{1})
        % interval is given
        sArgs.interval = varargin{1};
        
        if (nargin > 2)
            if isnumeric(varargin{2})
                sArgs.channels = varargin{2};
                if (nargin > 3)
                    if strcmpi(varargin{3},{'time'})
                        sArgs.isTime = true;
                    end
                end
            elseif strcmpi(varargin{2},{'time'})
                sArgs.isTime = true;
            end
        end
    elseif any(strcmpi(varargin,'metadata'))
        sArgs.metadata = true;
    elseif any(strcmpi(varargin,'extension'))
        idx = find(strcmpi(varargin,'extension'));
        if ~isempty(varargin{idx+1})
            extensionType = varargin{idx+1};
        else
            ita_verbose_info('Extension type not especified.',2)
        end
    else
        error('The arguments specified to call your function are not correct. Check the arguments, the corresponding values and the order.')
    end
end

fields = fieldnames(sArgs);
for idx = 1:numel(fields)
    aux{2*idx-1} = fields{idx};
    aux{2*idx} = sArgs.(fields{idx});
end
sArgs = aux; clear aux;

%% Initialization and Determination what to do
out = [];
% Get the filename list if missing
if nargin == 0 % No filename specified
    filenameList = get_files_with_gui(extensionMap); %pdi - fiita_make_headerlename deleted
    if isempty(filenameList)
        % Case user cancelled operation, terminate function
        ita_verbose_info('ITA_READ terminated by user.',2);
        return
    end
else
    filenameList = get_files_from_string(filename, extensionType, extensionMap);
end


%% pass on filename
for idx = 1:numel(filenameList)
    filename = filenameList{idx};
    
    [junk, name, fileExt] = fileparts(filename);
    fileTypeKnown = 0;
    for iFiles = 1:nFiles
        if strcmpi(extensionMap{iFiles,1},fileExt)
            % check for right extension
            fileTypeKnown = 1;
            read_file = str2func(extensionMap{iFiles,3});
            tmp = read_file(filename, sArgs{:});
            
            
            if iscell(tmp) && length(tmp) > 1  % Needed in case output is a cell, so that varargout can be set as a single cell
                    tmp = {tmp};
                    ita_verbose_info([upper(mfilename) ':subfunction returned more than one output, result is a cell'],1);
            end
            if numel(tmp) > 1
                result = tmp;
                if numel(filenameList) > 1
                    ita_verbose_info('ITA_READ:file contains multiple instances, reading only this file',1);
                    break;
                end
            elseif isempty(tmp)
                ita_verbose_info('ITA_READ:subfunction returned an empty result, that cannot be good!',0);
                break;
            else
                result(idx) = tmp;
            end
        end
    end
    if fileTypeKnown == 0
        error('ITA_READ:UnkownFiletype',sprintf('ITA_READ: Unknown filetype: %s',fileExt));
    end
end


%% Set Output
%  If user gave the same number of outputs as files read, set each file to
%  each output variable. Otherwise, just give back the audio object.
if numel(result) == nargout
    out = result(1);
    for idx = 2:nargout
        varargout{idx-1} = result(idx);
    end
else
    out = result;
end

end  % EOF ita_read


function filenameList = get_files_with_gui(extensionMap)
%% This function calls a GUI for the user to choose what files to read
% if ispref('RWTH_ITA_ToolboxPrefs','defaultPath') %pdi added, now uses matlab preferences
%     defaultPath = ita_preferences('defaultPath');
%     % bma: no need to open the directory, just give it to the uigetfile
%     % function.
% %     if ischar(defaultPath) ... % mpo: isdir can give error otherwise
% %             && isdir(defaultPath)
% %         cd(defaultPath)
% %     end
% else
    defaultPath = pwd;
%     addpref('RWTH_ITA_ToolboxPrefs','defaultPath',defaultPath);
% end

allFiles = [];
for idx = 1:size(extensionMap,1)
    if extensionMap{idx,1}(1) == '.'
        extensionMap{idx,1} = ['*' extensionMap{idx,1}];
    else
        extensionMap{idx,1} = ['*.' extensionMap{idx,1}];
    end
    allFiles = [allFiles extensionMap{idx,1} ';']; %#ok<AGROW>
end
[filename, pathname] = uigetfile( ...
    [{allFiles,'Audio-Files'}; ...
    extensionMap(:,1:2); ...
    {'*.*',  'All Files (*.*)'}], ...
    'Read Audio Files', ...
    defaultPath,...
    'MultiSelect', 'on');

if isnumeric(filename)
    if (filename == 0)
        filenameList = {}; return;
    end
end

if iscell(filename) % if multiple files get full list including path
    filename = sort(filename); %pdi UI puts the last file on first position.
    filenameList = cell(1,length(filename));
    for i = 1:length(filenameList)
        filenameList{i} = [pathname filename{i}];
    end
else
    filenameList{1}     = [pathname filename];
end
% ita_preferences('defaultPath',pathname);

end
%EOF get_files_with_gui

function filenameList = get_files_from_string(filename, extensionType, extensionMap)
%% This function extract single file names from a file string.
allowedFileExtensions = extensionMap(:,1);
extension = [];
% if extension type given, check if is valid
if ~isempty(extensionType)
    if ~iscell(extensionType) % Little trick to allow cell and string inputs
        extensionType = cellstr(extensionType);
    end
    
    for idx = 1:length(extensionType)
        aux = strfind(allowedFileExtensions,extensionType{idx});
        if any([aux{:}])
            if extensionType{idx}(1) == '.'
                extension = [extension extensionType(idx)];
            else
                extension = [extension {['.' extensionType{idx}]}];
            end
        else
            ita_verbose_info(['The extension ' extensionType{idx} ' is not allowed.'],2)
        end
    end
    
    if isempty(extension)
        error('Given extensions are not yet supported. Please check function help.')
    end
else
    extension = allowedFileExtensions;
end
% write all allowed filenames in a cell array (check lower and upper case)
if isunix
    allFileExtensions = [extension upper(extension)];
else
    allFileExtensions = extension;
end


% if is a cell, check that filenames end with correct extension.
if ~iscell(filename)
    filename = cellstr(filename);
end

% create a list with fullpath of all files to be read.
filenameList = {};
notRead = {};
for idx = 1:length(filename)
    if exist(filename{idx}, 'file')
        if isdir(filename{idx}) % no file but directory given
            ita_verbose_info('ITA_READ: This is a directory. Reading files in it.',2);
            
            oldDirectory = cd(filename{idx});
            fullpath = pwd;
            
%             for n = 1:length(allFileExtensions)
            for n = 1:numel(allFileExtensions) % mpo
                filenameStruct = dir(['*' allFileExtensions{n}]);
                for idfn = 1:numel(filenameStruct)
                    filenameList = [filenameList {fullfile(fullpath,filenameStruct(idfn).name)}]; %#ok<AGROW>
                end
            end
            cd(oldDirectory)
        else
            [path,name,ext] = fileparts(filename{idx});
            
            % certify that path is the full path, using the current
            % directory
             if isempty(path)
                path = fileparts(which(filename{idx})); % Also search the matlab path for file
             elseif strcmpi(path(1),'.') % relative path
                 path = cd(cd(path));
             end
            thisFile = fullfile(path,[name ext]);
            filenameList = [filenameList; thisFile]; %#ok<AGROW>
        end
    else
        %% File search using dir (Needed for uses of * in filenames)
        dirresult = dir(filename{idx});
        path = fileparts(filename{idx});

        if isempty(dirresult)
            notRead = [notRead filename(idx)]; %#ok<AGROW>
        else
            for iddirresult = 1:numel(dirresult)
                if ~isempty(path)
                    dirresult(iddirresult).name = [path filesep dirresult(iddirresult).name];
                end
                
                filenameList = [filenameList get_files_from_string(dirresult(iddirresult).name,[],extensionMap)]; %#ok<AGROW>
            end
        end
        % if the file is not found, warn that this file was not found
        if ~isempty(notRead)
            for iNotRead = 1:numel(notRead)
                ita_verbose_info(['ITA_READ: I can''t find file ' notRead{iNotRead} ' using ''dir'''],1);
            end
        end
    end
end

% warn about errors
if ~isempty(notRead)
    for idx = 1:numel(notRead)
        ita_verbose_info([upper(mfilename) ':No file or directory found with the name ' notRead{idx}],0);
    end
end

% check for no input
if isempty(filenameList);
    error('ITA_READ:NoInputFile','File not found.');
end
end