function varargout = ita_plot_nyquist(varargin)
%ITA_PLOT_NYQUIST - Nyquist plot
%  This function makes a Nyquist plot from input audioObject
%
%  Syntax:
%   audioObjOut = ita_plot_nyquist(audioObjIn, options)
%
%
%  Example:
%   audioObjOut = ita_plot_nyquist(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_plot_nyquist">doc ita_plot_nyquist</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Alexandre Bleus -- Email: alexandre.bleus@akustik.rwth-aachen.de
% Created:  08-Jul-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back 
%   Number of input arguments
narginchk(1,1);

Z=varargin{1};

Z_im=imag(Z.freqData);
Z_real=real(Z.freqData);

plot(Z_real,Z_im,'Color', 'r')
xlabel('Real Part [Ohm]')
ylabel('Imaginary Part [Ohm]')
title('Nyquist Plot')

%end function
end