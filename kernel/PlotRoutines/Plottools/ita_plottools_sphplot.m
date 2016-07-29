function fgh = ita_plottools_sphplot(cartesian)
%ITA_PLOTTOOLS_SPHPLOT - plots a spherical function

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created: 16-Sep-2008 

%% Get ITA Toolbox preferences
verboseMode  = ita_preferences('verboseMode');
% PlotPreferences = getpref('RWTH_ITA_ToolboxPrefs','PlotSettings');
blackbackground = ita_preferences('blackbackground');
menubar = ita_preferences('menubar');
colorTableName = ita_preferences('colorTableName');
linewidth = ita_preferences('linewidth');
aspectratio = ita_preferences('aspectratio');

hfig = figure;

if menubar == 1
    set(hfig,'Units','normal', 'Outerposition',[0 0 1 1]);
else
    set(hfig,'Units','normal', 'Outerposition',[0 0 1 1], 'menubar', 'none');
end

set(hfig,'KeyPressFcn',@ita_plottools_buttonpress_spherical);

% ita_plottools_figure;

set(gcf, 'renderer', 'opengl');

cartesian.freqIndex = 1;
if verboseMode, disp('start with lowest frequency'); end

% step sizes for arrow navigation in degrees
cartesian.stepSizeElevation = 10;
cartesian.stepSizeAzimuth = 10;

set(gcf,'userdata',setfield(get(gcf,'userdata'),'sphericalData',cartesian));
% set(gcf,'userdata',setfield(get(gcf,'userdata'),'frequencyIndex', freqIndex));
% set(gcf,'userdata',setfield(get(gcf,'userdata'),'frequencies', cartfreqIndex));

fgh = surf(cartesian.X(:,:,cartesian.freqIndex), cartesian.Y(:,:,cartesian.freqIndex), ...
    cartesian.Z(:,:,cartesian.freqIndex), cartesian.color(:,:,cartesian.freqIndex) ...
    ); % this causes flickering: , 'EraseMode','none'); 

% shading flat;
%colormap(jet);
colorbar;

switch cartesian.type
    case 'complex'
        colormap(hsv)
        maxRadius = cartesian.maxValue;
    case 'magnitude'
        colormap(jet)
        maxRadius = cartesian.maxValue;        
    case 'sphere'
        colormap(jet)
        maxRadius = 1;
    otherwise
        error('Uuuups, what type is this.')
end

caxis([0 cartesian.maxColor]);

if strcmp(cartesian.type, 'sphere')
    maxRadius = 1;
else
    maxRadius = cartesian.maxValue;
end

% shading interp

xlim([-maxRadius maxRadius]);
ylim([-maxRadius maxRadius]);
zlim([-maxRadius maxRadius]);

daspect([1 1 1]);
axis vis3d % off
% axis([-1 1 -1 1 -1 1])
grid on;
% bigger and fatter fonts
set(gca, 'FontSize', 12, 'FontWeight', 'bold');
% set background color to white
% set(gcf, 'Color', 'w');
% view(90,0);
view(3);
% view(0,90);
% rotate3d;
rotate3d off; % use key bindings from ita_plottools_buttonpress

xlabel('x');
ylabel('y');
zlabel('z');

title([cartesian.comment ' [f = ' num2str(cartesian.usedFreqs(cartesian.freqIndex)) ']']);

