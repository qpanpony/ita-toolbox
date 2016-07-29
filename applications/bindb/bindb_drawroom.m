function bindb_drawroom( canvas, data )
% Synopsis:
%   bindb_drawroom( axes, data )
% Description:
%   <Description>
% Parameters:
%   (handle) canvas
%	The axes used to draw the room, must have size of 401x401 pixels.
%   (string) data
%	Layout data for the room.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Set axes
axes(canvas);

% Draw grid
imshow(bindb_filepath('root', 'grid.png'));

% Draw grid only id no data
if strcmp(data, '')
    return;
end

% Get lines from data
while 1
    % Read current line
    [token, rest] = strtok(data, ';');        
    ld = textscan(token, '%f', 'delimiter', ',')';
    ld = ld{1};
    
    % Get color and width
    if ld(7) == 2
        color = [0, 0.8, 1];
        width = 3;
    elseif ld(7) == 3
        color = [0.5, 0, 0];
        width = 3;        
    else
        color = [0.642, 0.642, 0.642];
        width = 2;        
    end
        
    if ld(8) == 0
        % Draw line
        line([ld(1) ld(3)], [ld(2) ld(4)], 'Color', color, 'LineWidth', width);
    else
        % Get end points
        e1 = ld(1:2)';
        e2 = ld(3:4)';
        
        % Get arc stregnth
        strength = ld(8);
        
        % Get angle between endpoints at center
        arcangle = acos(1 - norm(e1 - e2)^2 / 2 / abs(strength)^2);

        % Get normal vector to e1e2
        n = (e1 - e2) * [0, -1; 1, 0];
        n = n/norm(n);

        % Make space
        k = 200;
        t = linspace(0, arcangle, k)';

        % Cet arc center
        c = (e1 + e2) / 2 + n * strength * cos(arcangle / 2);

        % Get arc data
        if sign(strength) == 1
            % Calc data
            phi = atan2(e1(2) - c(2), e1(1) - c(1));
            xy = repmat(c, k, 1) + strength * [cos(t + phi), sin(t + phi)];
        else
            % Calc data
            phi = atan2(e1(2) - c(2), e1(1) - c(1));
            xy = repmat(c, k, 1) + abs(strength) * [cos(-t + phi), sin(-t + phi)];
        end
        
        % Draw arc
        line(xy(:,1), xy(:,2), 'Color', color, 'LineWidth', width);
    end

    if strcmp(rest, ';')
        break;
    else
        data = rest;
    end
end

