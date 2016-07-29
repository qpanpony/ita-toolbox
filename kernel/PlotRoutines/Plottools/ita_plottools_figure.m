function varargout = ita_plottools_figure(varargin)
%ITA_PLOTTOOLS_FIGURE - Open Empty Fullscreen Figure
%  This function opens a fullscreen figure and returns the figure handle if
%  requested
%
%  Syntax: hfig = ita_plottools_figure()
%
%   See also ita_plottools_buttonpress, ita_plottools_blackbackground.
%
%   Reference page in Help browser
%        <a href="matlab:doc fullscreen_figure">doc fullscreen_figure</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Aug-2008

persistent fig_ID
if isempty(fig_ID)
    fgh = figure;
    fig_ID = 1;
else
    fig_ID = fig_ID + 1;
    if (~exist('fgh','var')) % make new figure
        fgh = figure;
    else
        fgh = figure(fig_ID); % figure already exist, just get a new one
    end
end
if nargin >= 1
    fgh = varargin{1}; % get User figure handle
end

%% pdi - correct handling with 2 or more monitors
try
    mpos = get(0,'Monitor');
catch %#ok<CTCH>
    mpos = [0 0 0 0];
end
units = 'pixel';
if size(mpos,1) > 1
    [value, idx] = max(mpos(:,3) -mpos(:,1) + 1);
    mpos = [-1 -1 mpos(idx,3:4)]; %get only main monitor, which is the bigger one
else
    mpos = [0 0 1 1];
    units = 'normalized';
end

if mpos(:,3)==0 || mpos(:,4)==0
    mpos = [0 0 1 1];
    units = 'normalized';
end

%% Menubar ?
if ita_preferences('menubar') == 1
    menubar = 'figure';
else
    menubar = 'none';
end

%% Generate Fullscreen Window
set(fgh,'Units',units, 'Outerposition',mpos,'menubar',menubar);

%% Find output parameters
varargout(1) = {fgh};
%end function
end

