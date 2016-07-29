function pos = VR_loudspeaker_position

% Give back the position, in meters, of the 8 loudspeakers in the VR lab.
%
% Used coordinate system
%                   Z
%                   |
%                   |
%                   |
%                   | - - - - Y
%                  /
%                 /
%                /
%               X

% <ITA-Toolbox>
% This file is part of the application SpatialAudio for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


pos = itaCoordinates(8);

% X     Y     Z
pos.cart = [...
-1.75 -1.75 -0.80;...
-1.75  1.75 -0.80;...
 1.75  1.75 -0.80;...
 1.75 -1.75 -0.80;...
-1.75 -1.75  0.80;...
-1.75  1.75  0.80;...
 1.75  1.75  0.80;...
 1.75 -1.75  0.80];