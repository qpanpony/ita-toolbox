function ita_plot_zplanepz(varargin)
%ITA_PLOT_ZPLANE - plot pole zeroes in zplane
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_plot_zplane(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
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
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
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
    
m = 1;
if iscell(z) && iscell(z)
%     color = colormap;
    color = get(gca,'colororder');
    for idx = 1:length(z)
        local_plot(z{idx},p{idx},color(idx,:));
        m = ceil(max(m,max(max(abs(z{idx})),max(abs(p{idx})))));
    end
else
    local_plot(z,p,[0 0 0]);
    m = [];
end


if ~isempty(m)
    axis([-m m -m m])
end

%end function
end

function local_plot(z,p,color)

        % ita_plottools_figure;
        x = [0 0 0];%colormap;
        if size(p,2)>size(p,1)
            p = p(:).';z=z(:).';
        end
        for idx = 1:size(p,2)
            color1 = x( 1+mod((idx-1)*21+1,size(x,1) ),:);
            zplaneplot(z(:,idx),p(:,idx),repmat({(color+color1)/2},1,2) );
            hold on
        end
end