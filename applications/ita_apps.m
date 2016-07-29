function ita_apps(varargin)
%ITA_APPS - Show installed Applications 
%  This function shows the applications within the ITA-Toolbox you have
%  got.
%  Call ita_apps(1) to show more information

% <ITA-Toolbox>
% This file is part of the application  for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  23-Feb-2011 

%% Browse through app folder for description.txt
appfolder = fileparts(which('ita_apps.m'));
if isempty(appfolder)
    applist = [];
else
    applist = rdir([appfolder filesep '**' filesep 'AppDescription.txt']);
end

fullmode = (nargin == 1);
errorCell = cell(0);

nChars = ita_preferences('nchars'); %nice stars?
ita_disp(nChars); 
ita_disp(nChars,[ num2str(numel(applist)) ' Installed ITA-Toolbox Applications'])
ita_disp(nChars)


for idx = 1:numel(applist)
    filename = applist(idx).name;
    nameidx = strfind(filename,filesep);
    nameidx = nameidx(end-1:end);
    appname = filename(nameidx(1)+1:nameidx(2)-1);
    
    %show name
    if fullmode
        ita_disp(nChars);
        ita_disp(nChars,appname);
        ita_disp(nChars);
    end
    
    %show info
    fid = fopen(filename);
    data = fread(fid);
    fclose(fid);
    data = native2unicode(data)'; %#ok<N2UNI>
    
    % extract dependencies 
    depStr = data(strfind(data, 'Dependencies:')+13:end);
    idxComma = [0 strfind(depStr, ',') length(depStr)+1];
    appPath = fullfile(ita_toolbox_path, 'applications');
    for iDependency = 1:numel(idxComma)-1
        depName = strtrim(depStr(idxComma(iDependency)+1:idxComma(iDependency+1)-1));
        if strcmpi(depName, 'no dependencies')
            continue
        end
        if ~exist([appPath filesep depName], 'dir')
            errorCell{end+1} = sprintf('Couldn''t find %s-Application! (%s depends on %s.)',depName, appname, depName ); %#ok<AGROW>
        end
    end
    %get rid off strange line feeds
    jdx = isstrprop(data,'cntrl');
    jdxend   = find([0 diff(jdx) == 1]);
    jdxstart = find([1 diff(jdx) == -1]);

    %display data
    if fullmode
        disp(data(jdxstart(1):jdxend(1)-1 ));
        disp(data(jdxstart(2):jdxend(2)-1 ));
        disp(data(jdxstart(3):end));
    else
        desStr = data(jdxstart(2):jdxend(2)-1 );
        desStr = strtrim(desStr(min(strfind(desStr,':')+1):end));
        fprintf('** %-28s ** %s\n',appname,  desStr)
    end
    
end

%end stars...
ita_disp(nChars);
ita_disp(nChars);

if ~isempty(errorCell)
    for iError = 1:numel(errorCell)
        ita_verbose_info(errorCell{iError},0)
    end
end

%end function
end