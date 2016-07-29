function varargout = ita_menu(varargin)
%ITA_MENU - Add the ita_menu to a window
%  Will add an ita_menu to a figure with the handle given
%
%   Call: ita_menu(Options)
%
%   Options: (default)
%       'handle' (gcf) - handle to the figure to use
%       'deletemenu' (~ita_preferences('menubar')) - delete the normal Matlab figure menu
%       'ita_menu_disable' ({}) - Cell containing menu entries that should not be shown
%       Name of any menuentry (true) - another way to disable entries
%
%
%   See also: ita_guimenuentries
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_menu">doc ita_menu</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];          % Use to show warnings or infos in this functions

%% All Menu-Entries in the parser, so they can be disabled
persistent MenuList; %pdi:performance
if isempty(MenuList)
    MenuList = ita_guimenuentries();
end

nameCell = ita_guisupport_removewhitespaces(cellfun(@getText,MenuList,'UniformOutput',0));
parentCell = ita_guisupport_removewhitespaces(cellfun(@getParent,MenuList,'UniformOutput',0));
for idx = 1:numel(MenuList)
    sArgs.(lower(nameCell{idx})) = 'on';
end

%% Initialization and Input Parsing
sArgs.handle            = gcf;
sArgs.deletemenu        = ~ita_preferences('menubar');
sArgs.ita_menu_disable  = cell(1);
sArgs.type              = itaAudio;
[sArgs]                 = ita_parse_arguments(sArgs,varargin);
fhandle                 = sArgs.handle;

%% Menubar Handling
if ishandle(fhandle)
    %     figure(fhandle);
else
    fhandle = ita_main_window;
end

% Go through all childs and clear ita menu entries
hchilds = get(fhandle,'Children');
for idchild = 1:numel(hchilds)
    if strcmpi(get(hchilds(idchild),'Type'),'uimenu') && (strcmpi(get(hchilds(idchild),'UserData'),'ITA-MENU') || strncmpi(get(hchilds(idchild),'callback'),'ita',3))
        delete(hchilds(idchild));
    end
end

% Disable matlab menu or insert seperator
if sArgs.deletemenu
    set(fhandle,'MenuBar','none');
else
    uimenu('Label',' --- ','UserData','ITA-MENU');
end

for idx = 1:numel(MenuList)
    %     name = ita_guisupport_removewhitespaces(MenuList{idx}.text);
    name = nameCell{idx};
    if ~isvarname(name)
        if ita_preferences('verboseMode')
            warning(['Na valid var name: ' name]);
        end
        name = 'istganzegalwirdehnichtgebraucht';
    end
    if ~isfield(MenuList{idx},'accelerator')
        MenuList{idx}.accelerator = '';
    end
    
    if strcmpi(MenuList{idx}.type,'function')
        funcname = name;
        callbackfunc = ['ita_menucallback_' funcname];
        if MenuList{idx}.valid %pdi: performance
            funchandle = str2func(callbackfunc);
        elseif exist(callbackfunc,'file')
            MenuList{idx}.valid = true;
            funchandle = str2func(callbackfunc);
        else
            funchandle = [];
            ita_verbose_info(['Function not found: ' callbackfunc],1);
        end
    else
        funchandle = [];
    end
    
    if isfield(MenuList{idx},'separator') && MenuList{idx}.separator
        separator = 'on';
    else
        separator = 'off';
    end
    
    
    switch(MenuList{idx}.type)
        case {'function' 'submenu'}
            if ~isfield(MenuList{idx},'parent') || isempty(MenuList{idx}.parent)
                hList.(name) = uimenu('Label',MenuList{idx}.text,'UserData','ITA-MENU');%,'callback','ita_main_window(gcf)');
            else
                parenthandle = hList.(parentCell{idx});
                hList.(name) = uimenu(parenthandle,'Label',MenuList{idx}.text,...
                    'Callback',funchandle,'Accelerator',MenuList{idx}.accelerator,'Separator',separator,'UserData','ITA-MENU');
            end
        case {'varlist'}
            [List, varStruct ,CellList] = ita_guisupport_getworkspacelist;
            hList.(name) = uimenu('Label',MenuList{idx}.text,'UserData','ITA-MENU');
            uimenu(hList.(name),'Label','Refresh','Callback','ita_menu()','UserData','ITA-MENU');
            separator = 'on';
            %uimenu(hList.(name),'Label','-------');
            audioObj = getappdata(fhandle, 'audioObj');
% %             if isempty(audioObj)
% %                 currentFileName = '';
% %             else
% %                 currentFileName = audioObj.fileName;
% %             end
            for idvar = 1:size(CellList,1)
% %                 if strcmp(CellList{idvar,1}, currentFileName);
% %                     checkstate = 'on';
% %                 else
                    checkstate = 'off';
% %                 end
                uimenu(hList.(name),'Label',CellList{idvar,2},'Callback',@ita_menucallback_varselect,...
                    'UserData',CellList{idvar,1},'Check',checkstate,'Separator',separator);
                separator = 'off';
            end
            uimenu(hList.(name),'Label','Export current variable to workspace','Callback','ita_menucallback_ExportToWorkspace;' ,'Separator','on','UserData','ITA-MENU');
%              uimenu(hList.(name),'Separator','on','UserData','ITA-MENU');
        case {'domainlist'}
            list = ita_guisupport_domainlist(sArgs.type);
            hList.(name) = uimenu('Label',MenuList{idx}.text,'UserData','ITA-MENU');%,'callback','ita_main_window(gcf)');
            for idvar = 1:numel(list)
                if strcmpi(list{idvar}.name, ita_guisupport_currentdomain());
                    checkstate = 'on';
                else
                    checkstate = 'off';
                end
                separator = 'off';
                if list{idvar}.separator
                    separator = 'on';
                end
                
                uimenu(hList.(name),'Label',list{idvar}.name,'Callback',@ita_menucallback_domainselect,...
                    'Checked',checkstate,'Separator',separator,'Accelerator',list{idvar}.accelerator,'UserData','ITA-MENU');
            end
        otherwise
            error([thisFuncStr ' I dont know that type: ' MenuList{idx}.type])
    end
    if ~sArgs.(lower(name)) || any(strcmpi(sArgs.ita_menu_disable,name))
        set(hList.(name),'Visible','off','Enable','off');
    end
end
result = 1;

%% Find output parameters
if nargout == 0 %User has not specified a variable
    
else
    % Write Data
    varargout(1) = {result};
end

%end function
end

%% subfunctions
function text = getText(in)
text = in.text;
end

function parent = getParent(in)
if isfield(in,'parent')
    parent = in.parent;
else
    parent = '';
end
end