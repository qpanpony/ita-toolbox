function ita_plot_zplane(inumz,idenz)
%ITA_PLOT_ZPLANE - plot zplane
%  This function plots a z plane 
%
%  Syntax:
%   audioObjOut = ita_plot_zplane(audioObjIn, options)
%
%  Example:
%   audioObjOut = ita_plot_zplane(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_zplane">doc ita_plot_zplane</a>

% <ITA-Toolbox>
% This file is part of the application PoleZeroProny for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal -- Email: pdi@akustik.rwth-aachen.de
% Created:  26-Aug-2010 


ita_plottools_figure;
zplane(inumz,idenz);
title('Poles and Zeros')
axis([-1.5 1.5 -1.5 1.5])
ita_plottools_maximize()

%end function
end