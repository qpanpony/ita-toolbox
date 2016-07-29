function ita_plot_zplanepz(varargin)
%ITA_PLOT_ZPLANE - plot zplane w poles zeroes
%  This function plots poles and zeros in z plane
%
%  Syntax:
%   audioObjOut = ita_plot_zplane(z,p,k)
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


if nargin == 3
    z = varargin{1};
    p = varargin{2};
    k = varargin{3};
else
   [z,p,k] = tf2zpk(varargin{1},varargin{2});
end
    
    
ita_plottools_figure;
x = colormap;
if size(p,2)>size(p,1)
    p = p(:).';z=z(:).';
end
for idx = 1:size(p,2)
    color = x( 1+mod((idx-1)*21+1,size(x,1) ),:);
    zplaneplot(z(:,idx),p(:,idx),repmat({color},1,2) );
    hold on
end

axis([-2 2 -2 2])

%end function
end