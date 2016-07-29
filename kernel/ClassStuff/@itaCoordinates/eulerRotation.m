function this = eulerRotation(this,a,b,c)

% Rotates the coordinates using euler angles. Angles are given in radians.
% Here the rotations around the z-axis (a), y-axis (b) and again z-axis (c)
% are used, as mentioned in Pendleton: "Euler angle geometry, helicity
% basis vectors, and the Wigner D-function addition theorem", 2003

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>
A = [cos(a) sin(a) 0; ...
    -sin(a) cos(a) 0; ...
    0 0 1];

B = [cos(b) 0 -sin(b); ...
    0 1 0;
    sin(b) 0 cos(b)];

C = [cos(c) sin(c) 0; ...
    -sin(c) cos(c) 0; ...
    0 0 1];

this.cart = this.cart * A * B * C;

end