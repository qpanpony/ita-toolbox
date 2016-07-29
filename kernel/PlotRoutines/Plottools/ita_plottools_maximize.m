function ita_plottools_maximize(fgh)
%ITA_PLOTTOOLS_MAXIMIZE - Maximize Figure
%  This function maximizes the figure for MS Windows machines and
%  Matlab version 7.6
%
%  Syntax: ita_plottools_maximize()
%
%   See also ita_plot.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_maximize">doc ita_plottools_maximize</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created: 25-Sep-2008

if ispc && ita_preferences('maximizedPlot')
    if ~exist('fgh','var')
        fgh = gcf;
    end
    
    warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    drawnow()               % mgu: avoid java nullpointer exception
    set(get(fgh,'JavaFrame'),'Maximized',1);
    % set(fgh,'Interruptible','off','BusyAction','cancel');
end

