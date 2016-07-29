function [view, up] = ita_quat2vu(q)
% function [view, up] = ita_quat2vu(q)
%
% This function calculates normalized view/up vectors from given quaternions.
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
% If M quaternions with dimension 1xM are used, i.e. size(q)=1xM, the function
% outputs matrices with size(view) = Mx3
%                       size(up)   = Mx3
%
% ATTENTION:
% Motive's quaternion output order is (qx, qy, qz, qw [real part]) but the
% implementation in this function needs the order (qw [real part], qx, qy, qz) !
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

%% Normalize and transform
qn   = q.normalize;
view = qn.RotateVector([0 0 -1]);
up   = qn.RotateVector([0 1 0]);

view = permute(view,[2,1,3]);
up   = permute(up,[2,1,3]);

end