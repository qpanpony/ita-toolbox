function varargout = ita_main_window(varargin)
%ITA_MAIN_WINDOW - Get handle to ita main window
%  This function will return the handle to an existing ita_window or create a new one
%
%  Syntax:
%    handle = ita_main_window()
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_main_window">doc ita_main_window</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  19-Jun-2009

%% Check for Toolboxsetup

ita_check4toolboxsetup();

%% Get ITA Toolbox preferences and Function String
persistent ita_main_window_handle;
if nargin == 1 || nargin ==2 && isempty(varargin{2}) % Callback usage
   varargin{2} = varargin{1};
   varargin{1} = 'handle';
end

%% Initialization and Input Parsing
sArgs = struct('handle',ita_main_window_handle,'type',itaAudio);
sArgs = ita_parse_arguments(sArgs,varargin); 

%% 
if ~isempty(sArgs.handle) && all(ishandle(sArgs.handle)) %Its a valid figure handle
    error('keiner weiﬂ wozu man die funktion noch braucht')
        fgh = sArgs.handle;
        while ~strcmpi(get(fgh,'Type'),'figure') && ~isempty(get(fgh,'Parent'))
            fgh = get(fgh,'Parent');
        end
elseif strcmpi(sArgs.handle,'new') %Create a new one    
    %% Get defaults
    if ita_preferences('menubar')
        menubar = 'figure';
    else
        menubar = 'none';
    end
    
    fgh = ita_plottools_figure();
    set(fgh,'Name','ITA TOOLBOX','NumberTitle','off','DeleteFcn','disp([''See you '' ita_preferences(''AuthorStr'') ''!'']);','ToolBar',menubar);
    ita_menu('handle',fgh);
    ita_plottools_maximize();
    ita_plottools_ita_logo('centered');
else
    error('keine weiﬂ wozu man die funktion noch braucht')
    fgh = [];
end

ita_main_window_handle = fgh;

% get axes, without drawing new axis
% set(fgh,'KeyPressFcn', @ita_plottools_buttonpress) %pdi: done in figure_preparation now

if ~isempty(fgh) && ~isfield(getappdata(fgh),'AxisHandles')
    x = get(gcf,'children');
    
    for idx = 1:numel(x);
        if strcmpi( get(x(idx),'type'), 'axes')
            setappdata(fgh,'AxisHandles',x(idx));
            break
        end
    end
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {fgh};
end

%end function
end
% % function commandPress(s,e)
% % switch(e.Key)
% %     case {'return', 'escape' }
% %         commandwindow();
% %         
% % end
% % end



