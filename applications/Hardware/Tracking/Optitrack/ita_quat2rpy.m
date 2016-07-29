function [r, p, y] = ita_quat2rpy(q)
% function [roll_rad, pitch_rad, yaw_rad] = ita_quat2rpy(quaternion)
%
% This function calculates roll/pitch/yaw angles in [rad] from given
% quaternions.
%
% Convention:
% Roll means a rotation around -Z, pitch means a rotation around +X, and
% yaw means a rotation around +Y (right-handed OpenGL coordinate system,
% used by Optitrack). All rotations are defined clockwise. This defines
% the default v vector in negative Z direction and the default u vector
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
% If M quaternions with dimension 1xM are used, i.e. size(q)=1xM, the function
% outputs matrices with size(roll_rad)  = Mx1
%                       size(pitch_rad) = Mx1
%                       size(yaw_rad)   = Mx1
%
% ATTENTION:
% Motive's quaternion output order is (qx, qy, qz, qw [real part]) but the
% implementation in this function uses the order (qw [real part], qx, qy, qz) !
%
% See also: quaternion.m
%
% Authors: Florian Pausch, Jonas Stienen
% e-Mail:  {fpa, jst}@akustik.rwth-aachen.de
% Version: 2016-04-04
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%% Check input
assert(isa(q,'quaternion'),'Input must be a quaternion() object.');

%% Transform
[v,u]   = ita_quat2vu(q);
[r,p,y] = ita_vu2rpy(v,u);
r       = real(r);
p       = real(p);
y       = real(y);

% TODO: the direct solution given below does not work yet (Tait-Bryan angles 
% following z-y’-x? convention, not the same convention as we use) 
% qw = q.e(1);
% qx = q.e(2);
% qy = q.e(3);
% qz = q.e(4);
% 
% r  = atan2( 2*(qw.*qx + qy.*qz), 1 - 2*(qx.^2+qy.^2) );
% p = asin ( 2*(qw.*qy - qz.*qx) );
% y  = atan2( 2*(qw.*qz + qx.*qy), 1-2*(qy.^2+qz.^2) );

end