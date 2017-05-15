function ita_plottools_ita_logo(varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


%% Toolbox Logo
mode = 'normal';
if nargin == 1
    mode = varargin{1};
end
% with lightgrey bg
a_im = importdata(which('ita_toolbox_logo_lightgrey.png'));
graph_size = size(a_im);
graph_size = [graph_size(1) graph_size(2)];
axes();
image(a_im);
axis equal
axis off

switch lower(mode)
    case 'normal'
        pos = [0 0 400 83]*0.3;
    case 'centered'
        if strcmpi(get(gca,'Unit'),'normalized')
            set(gca,'Unit','pixel')
            pos = get(gca,'Position');
            set(gca,'Unit','normalized');
        else
            pos = get(gca,'Position');
        end
        scaling_factor = pos(3) ./ graph_size(1);
        graph_size = scaling_factor * graph_size;
        x_center = pos(1) + pos(3)/2;
        y_center = pos(2) + pos(4)/2;
        x_start = x_center - graph_size(1)/2;
        x_length = graph_size(1);
        y_start = y_center - graph_size(2)/2;
        y_length = graph_size(2);
        pos = [x_start y_start x_length y_length];
end
set(gca,'Units','pixel', 'Position', pos);
set(gca,'Units','normalized');
end
