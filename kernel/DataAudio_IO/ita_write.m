function varargout = ita_write( varargin )
%ITA_WRITE - Write audioObj to disk
%   This functions writes data to various file formats.
%   If no name specified it uses a GUI to get the filename. If the
%   audio data exceeds the limits for .wav, clipping is a avoided by
%   normalizing.
%
%   Call: ita_write(itaAudio,filename, Options)
%         ita_write(itaAudio)
%         ita_write(itaAudio,{'Cell of filenames'}) % Saves file in multiple formats
%
%
% Autor: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Init
thisFuncStr  = [upper(mfilename) ':'];

%% Initialize write directory
% scan directory
persistent extensionMap;
if isempty(extensionMap)
    [pathstr, name] = fileparts(mfilename('fullpath'));
    extensionMap = ita_io_get_daughter(pathstr, name);
end

%% Input check
% narginchk(0,3);
if nargin == 0
    ita_write_gui();
    return;
elseif nargin == 1 || isempty(varargin{2}) %no filename specified, load GUI
    %read in filename to store
    data        = varargin{1};
    filenameStr = data.fileName;
    %     oldDir      = pwd;
    %     cd(ita_preferences('DefaultPath')); %go to default path to show the GUI there
    
    [filename, pathname, filterindex] = uiputfile([extensionMap(:,1:2); {'*.*',  'All Files (*.*)'}],...
        'Save Audio Data',...
        filenameStr);
    %     cd(oldDir); %go back to old dir
    if filename == 0, return; end
    
    %     ita_preferences('DefaultPath',pathname); %save the new default path
    filename = fullfile(pathname,filename);
    
    if nargin > 2
        options = varargin(3:end);
    else
        options = {};
    end
    % User has already been asked on overwriting so add that option
    options = [options; {'overwrite'}];
    
elseif nargin >= 2 % audioObj and filename given
    data     = varargin{1};
    filename = varargin{2};
    options  = varargin(3:end);
end

%% check suffix
[a,b,c] = fileparts(filename); %#ok<ASGLU>
if isempty(c)
    filename = [filename , '.ita'];
    ita_verbose_info([thisFuncStr 'Saving in .ita format.'],1)
end

%% check for multiple names -pdi: who needs this??? please report
if ischar(filename)
    filename = {filename};
end

%% Call all write-functions
if exist('filterindex','var') % filter index given?
    try
        status = feval(extensionMap{filterindex,3},data,filename{1},options{:});
    catch theError
        if strcmp(theError.identifier, 'MATLAB:save:noParentDir')
            error('ita_write: cannot write in this directory')
        elseif ~isempty(strfind(lower(theError.identifier),'file')) && ~isempty(strfind(lower(theError.identifier),'exists'))
            %check for overwrite option
            ButtonName = questdlg('File already exists. Do you want to overwrite?', ...
                'Overwrite option','No', 'Yes', 'No');
            if strcmpi(ButtonName,'Yes')
                try
                    status = feval(extensionMap{filterindex,3},data,filename{1},[options{:} 'overwrite']);
                catch theError2
                    ita_verbose_info('File NOT saved!',0);
                    theError2 = addCause(theError2,theError);
                    rethrow(theError2);
                end
            else
                ita_verbose_info('File NOT saved!',0);
                status = 1;
            end
        else
            rethrow(theError);
        end
    end
else
    % normal saving
    status = [];
    for idfile = 1:numel(filename)
        for idext = 1:size(extensionMap,1)
            if strcmpi(extensionMap{idext,1}(2:end),filename{idfile}(end-numel(extensionMap{idext,1})+2:end))
                try
                    status(end+1) = feval(extensionMap{idext,3},data,filename{idfile},options{:}); %#ok<AGROW>
                catch  theError
                    if strcmp(theError.identifier, 'MATLAB:save:noParentDir')
                        error('ita_write: cannot write in this directory')
                    elseif ~isempty(strfind(lower(theError.identifier),'file')) && ~isempty(strfind(lower(theError.identifier),'exists'))
                        %check for overwrite option
                        ButtonName = questdlg('File already exists. Do you want to overwrite?', ...
                            'Overwrite option','No', 'Yes', 'No');
                        if strcmpi(ButtonName,'yes')
                            try
                                status(end+1) = feval(extensionMap{idext,3},data,filename{idfile},options{:}, 'overwrite'); %#ok<AGROW>
                            catch theError2
                                theError2 = addCause(theError2,theError);
                                rethrow(theError2);
                            end
                        else
                            ita_verbose_info('File NOT saved!',0);
                            status(end+1) = 1; %#ok<AGROW>
                        end
                    else
                        rethrow(theError);
                    end
                end
            end
        end
    end
end
if isempty(status)
    error([mfilename ': I can''t write that format']);
end

if nargout > 0
    varargout{1} = status;
end
