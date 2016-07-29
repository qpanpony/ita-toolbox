function [pos] = basistransformation(ppos, opos, oview, oup)
% Rewrite the position vector ppos in the new coordinate system given by
% opos, oview and oup. These are the position and two orthogonal vectors
% that define the new system, but writen on the same basis as ppos.

% <ITA-Toolbox>
% This file is part of the application Tracking for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Certify that vectors are column vectors
ppos  = ppos(:);
opos  = opos(:);
oview = oview(:);
oup   = oup(:);

% Define third orthogonal vector
oside = [oview(2)*oup(3) - oview(3)*oup(2); ...
         oview(3)*oup(1) - oview(1)*oup(3); ...
         oview(1)*oup(2) - oview(2)*oup(1)];

% Generate the basis transformation matrix
T = [oview';
     oup';
     oside'];

% Resulting vector in original basis
r = ppos - opos;

% Stylus position with sensor as origin of the coordinate system
pos = (T*r)';