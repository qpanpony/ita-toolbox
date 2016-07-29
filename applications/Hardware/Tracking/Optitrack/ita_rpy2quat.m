function q = ita_rpy2quat(r, p, y)
% quaternion = ita_rpy2quat(roll, pitch, yaw)
%
% This function calculates normalized quaternions from given roll/pitch/yaw
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
% If roll/pitch/yaw vectors with M entries are used, function outputs a
% normalized quaternion object with size(quaternion) = 1xM.
%
% See also: quaternion.m
%
% Authors: Florian Pausch
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

% calculate quaternion from Euler Angles (z-y'-x'' intrinsic) = roll/pitch/yaw angles
qw = cos(-r/2).*cos(p/2).*cos(y/2) + sin(-r/2).*sin(p/2).*sin(y/2);
qz = cos(-r/2).*sin(p/2).*sin(y/2) - sin(-r/2).*cos(p/2).*cos(y/2);
qx = cos(-r/2).*sin(p/2).*cos(y/2) + sin(-r/2).*cos(p/2).*sin(y/2);
qy = cos(-r/2).*cos(p/2).*sin(y/2) - sin(-r/2).*sin(p/2).*cos(y/2);

% create normalized quaternion object
q = quaternion([qw qx qy -qz]);
q = q.normalize;

end