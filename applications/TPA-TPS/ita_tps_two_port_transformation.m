function [Ys_incl Fb_iso] = ita_tps_two_port_transformation(Ys, Fb, A, B, C, D)
%ITA_TPS_TWO_PORT_TRANSFORMATION - include two-port into Ys
%  This function includes an isolator specified with the ABCD two-port
%  matrix into a new Ys_incl. This is equivalent to a source that includes
%  this isolator.
%
%  Syntax:
%   Ys_incl = ita_tps_two_port_transformation(Ys, A, B, C, D)
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tps_two_port_transformation">doc ita_tps_two_port_transformation</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  03-Aug-2011 

% id = 0 * Ys * pinv(Ys) + eye(size(Ys));

% Ys_incl = (D - C * pinv(A)*B) * pinv(Ys) * pinv(pinv(Ys) - pinv(A) * B) * (Ys - pinv(D)*C) * pinv(A-B*pinv(D)*C);

% Fb_factor1 = pinv(A - B*pinv(D)*C) * pinv((Ys - pinv(D)*C));
% vf_factor = (D - C *pinv(A)* B) * pinv( -Ys * pinv(A)*B  + eye(size(Ys)) );

pinvDC = pinv(D)*C;
pinvAB = pinv(A)*B;
Fb_factor1 = (A - B*pinvDC)  * pinv((Ys - pinvDC));
vf_factor  = (D - C *pinvAB) * pinv( -Ys * pinvAB  + eye(size(Ys)) );

% Ys_incl   = vf_factor * ((Ys - pinvDC)) * pinv(A - B * pinvDC);
Ys_incl   = vf_factor * pinv(Fb_factor1);

%% Bugfix Channel Units - Nothing more
for idx = 1:size(Ys,1)
    for jdx = 1:size(Ys,2)
        Ys_incl(idx,jdx).channelUnits = Ys(idx,jdx).channelUnits;
    end
end

% Ys_factor = vf_factor * pinv(Fb_factor)

Fb_iso = Fb_factor1 *  Ys * Fb;

%% improved formula - using (A * B)^-1 = B^-1 * A^-1
% tic
% id = 0 * Ys * pinv(Ys) + eye(size(Ys));
% toc
% 
% tic
% Ys_incl = (D - C * pinv(A)*B) * pinv(id - pinv(A) * B * Ys) * (Ys - pinv(D)*C) * pinv(A-B*pinv(D)*C);
% toc
% 
%end function
end
