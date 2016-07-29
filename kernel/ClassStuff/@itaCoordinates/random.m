function this = random(this,n)
% Randomly distributed points on sphere with radius 1
%
%   Coords = random(Coords)  % Fill Coords with random directions
%   Coords = random(Coords, n) % Fill Coords with n random directions
%
% see http://www.math.niu.edu/~rusin/known-math/96/sph.rand

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer - rsc@akustik.rwth-aachen.de

if nargin < 2
    n = this.nPoints;
end

z = rand(n,1)*2-1; 	%(a) Choose z uniformly distributed in [-1,1].
t = rand(n,1)*2*pi; %(b) Choose t uniformly distributed on [0, 2*pi).
r = sqrt(1-z.^2);   %(c) Let r = sqrt(1-z^2).
x = r.* cos(t);	    %(d) Let x = r * cos(t).
y = r.*sin(t);      %(e) Let y = r * sin(t).

this.cart = [x y z];

end
