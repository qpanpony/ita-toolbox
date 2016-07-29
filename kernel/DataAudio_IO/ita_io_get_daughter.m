function extensionMap = ita_io_get_daughter(pathstr, name)
%ITA_IO_GET_DAUGHTER - Get daughter functions
%  This function scans a subdirectory to provide the calling function with
%  all its daughter functions.
%
%  Daughter functions must be located in a folder with the same name as
%  the caller function and the beginning of their name must be the same as
%  the name of the caller function.
%
%  Syntax:
%   audioObjOut = ita_io_get_daughter(pathstr, name)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_io_get_daughter">doc ita_io_get_daughter</a>
% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  16-Nov-2009 

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


fileNameList = dir(fullfile(pathstr, name, [name '_*.m']));
nFiles = numel(fileNameList);

% pre-initialize extention map
% [filename, functionName]
extensionMap = cell(nFiles,2);

% now call all the functions
% use try - catch later
idx = 1;
for iFiles = 1:nFiles
    fileName = fileNameList(iFiles);
    functionName = fileName.name(1:end-2);
    fileExtention = eval(functionName);
    for iExt = 1:numel(fileExtention)
        extensionMap{idx,1} = fileExtention{iExt}.extension;
        extensionMap{idx,2} = fileExtention{iExt}.comment;
        extensionMap{idx,3} = functionName;
        idx = idx+1;
    end
    % TODO: check for conflicts
end
end
