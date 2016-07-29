function [fileType, openAction, loadAction, description] = finfo(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%% Check if file exists and get correct path
filename = varargin{1};
fid = fopen(filename, 'r');
if (fid == -1)
    if ~isempty(dir(filename))
        error('MATLAB:fileOpen', ['Can''t open file "%s" for reading;\nyou' ...
            ' may not have read permission.'], ...
            filename);
    else
        error('MATLAB:fileOpen', 'File "%s" does not exist or is not in path.', filename);
    end
    
else
    % File exists.  Get full filename.
    filename = fopen(fid);
    fclose(fid);
end

[filepath,filename,fileext] = fileparts(filename);
if isempty(filepath)
    filename = which([filename,fileext]);
else
    filename = fullfile(filepath,[filename,fileext]);
end

%% Get readable audio files
persistent extensionMap;
if isempty(extensionMap)
    [pathstr, name] = fileparts(which('ita_read.m'));
    extensionMap = ita_io_get_daughter(pathstr, name);
end

%% If file is a readable audio file, call ita_read
[~,~,fileType] = fileparts(varargin{1});
if any(strcmpi(fileType, extensionMap(:,1))) || ...   % ita read files
        any(strcmpi(['.' fileType], extensionMap(:,1)))
    openAction = 'ita_read_doubleclick';
    loadAction = 'ita_read_doubleclick';
    description = 'ITA file';
else
    % Move to original finfo folder and run it
    oldPath = pwd;
    path = fileparts(which('general/finfo.m'));
    cd(path)
    [fileType, openAction, loadAction, description] = finfo(filename,varargin{2:end});
    cd(oldPath)
end
end

