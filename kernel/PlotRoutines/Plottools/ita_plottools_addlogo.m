function varargout = ita_plottools_addlogo(varargin)
% Adds a logo to an axes (by overlaying a stransparent axes)
%
%  call: ita_plottools_addlogo() - adds logo to current axes
%        h = ita_plottools_addlogo() - returns handle to logo 
%        [h_axes, h_image] = ita_plottools_addlogo() - returns handle to logo and image
%        ita_plottools_addlogo(axes_handle) - adds logo to axes
%        ita_plottools_addlogo(Options) - adds logo to (current) axes, using Options
%
%   Options:
%       parent 
%       logosize - relative size of logo (0-1)
%       logoposition - relative position of logo in axes ([0 0] left bottom; [1 1] right top)
%       logoalpha - alpha (1/transparency) of logo, [0-1] 0 invisible, 1 fully visible !!! Carefull, seems it wont work on semilog plots ??? 
%
% Author: Roman Scharrer - rsc@akustik.rwth-aachen.de
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% Parse input
sArgs = struct('parent',gca,'uselogo',ita_preferences('toolboxlogo'),'logosize',ita_preferences('logosize'),'logoposition',ita_preferences('logoposition'),'logoalpha',ita_preferences('logoalpha'));

if nargin == 1 && ishandle(varargin{1})
    sArgs.parent = varargin{1};
else
    sArgs = ita_parse_arguments(sArgs,varargin);
end

if ~sArgs.uselogo
    return % no logo wanted, return as fast as possible
end

%% Get position of axes
old_gca = sArgs.parent;
axes_pos = get(old_gca,'Position');

%% some calculations
logosize = sArgs.logosize;
if numel(logosize) == 1
    logosize = logosize * [1 0.21*axes_pos(3)/axes_pos(4)];
end

logooffset = sArgs.logoposition;

%% Calculate position
logo_pos = [axes_pos(1)+logooffset(1)*(axes_pos(3)*(1-logosize(1))) axes_pos(2)+logooffset(2)*axes_pos(4)*(1- logosize(2)) logosize(1)*axes_pos(3) logosize(2) * axes_pos(4)];

%% Create axes for logo
ha2 = axes('Position',logo_pos);

%% load logo and plot
persistent a_im;
if isempty(a_im)
    a_im = importdata(which('ita_toolbox_logo_wbg.jpg'));
end
h_i = image(a_im,'alphaData',sArgs.logoalpha);
set(h_i,'UserData','ITA-Toolbox-Logo'); % Write something to UserData so we can identify it
axis off;

%% Reselect old axes (axes(old_gca) wont work as it will shift old_gca to the front and the logo wont be visible)
set(get(old_gca,'Parent'),'CurrentAxes',old_gca);

%% output handling
if nargout >= 1
    varargout{1} = ha2;
end

if nargout >= 2
    varargout{2} = h_i;
end

end