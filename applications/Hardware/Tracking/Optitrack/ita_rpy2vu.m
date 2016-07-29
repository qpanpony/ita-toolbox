function [v, u] = ita_rpy2vu(r, p, y)
% [view, up] = ita_rpy2vu(roll, pitch, yaw)
%
% This function calculates normalized view/up vectors from given roll/pitch/yaw
% angles [rad].
%
% Convention:
% Roll means a rotation around -Z, pitch means a rotation around +X, and
% yaw means a rotation around +Y (right-handed OpenGL coordinate system,
% used by Optitrack). All rotations are defined clockwise. This defines
% the default view vector in negative Z direction and the default up vector
% in positive Y direction.
%
%                             (+Y)
%                               |
%                               |
%                               . - - (+X)
%                              /
%                             /
%                           (+Z)
%
% If roll/pitch/yaw vectors with M entries are used, function outputs 
% normalized view/up vectors with size(view) = Mx3
%                                 size(up)   = Mx3
%
% See also: quaternion.m
%
% Author:  Florian Pausch
% e-Mail:  fpa@akustik.rwth-aachen.de
% Version: 2016-04-05
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%% Check input
if isvector(r) % force roll/pitch/yaw to be column vectors
    r = r(:);
    p = p(:);
    y = y(:);
end

%% Transform
q      = ita_rpy2quat(r, p, y);
[v, u] = ita_quat2vu(q);

end