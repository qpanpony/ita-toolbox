function q = ita_vu2quat(v, u)
% q = ita_vu2quat(v, u)
%
% This function calculates normalized quaternions from given view/up vectors.
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
% If M view/up vectors are used dimensions must be Mx3, i.e. size(view)=Mx3.
% Function output is a normalized quaternion object with size(q)  = 1xM
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
if ~ismatrix(v) && ~ismatrix(u)
    error('[ita_vu2quat] Input must be vectors/matrices with dimensions Mx3 each.')
end

if isvector(v)     % force view/up to be row vectors
    v = (v(:))';
    u   = (u(:))';
elseif ismatrix(v) % check size of input matrices
    if size(v,2)~=3
        error('[ita_vu2quat] Input dimensions for v and u must be Mx3 each.')
    end
end

% check if view/up are orthogonal
if abs(dot(v,u,2)) > 1e-5
   error('[ita_vu2rpy] view/up are not orthogonal to each other.') 
end

% normalize view/up vectors
[~,colv]=size(v);
[~,colu]=size(u);
if (colv == 1)
    v(~isnan(v(:,1)),:) = v(~isnan(v(:,1)),:) ./ abs(v(~isnan(v(:,1)),:));
    u(~isnan(u(:,1)),:) = u(~isnan(u(:,1)),:) ./ abs(u(~isnan(u(:,1)),:));
else
    v = sqrt( ones ./ (sum((v(~isnan(v(:,1)),:).*v(~isnan(v(:,1)),:))')) )' * ones(1,colv).*v(~isnan(v(:,1)),:);
    u = sqrt( ones ./ (sum((u(~isnan(u(:,1)),:).*u(~isnan(u(:,1)),:))')) )' * ones(1,colu).*u(~isnan(u(:,1)),:);
end

% calculate side vector
s = cross(v, u, 2); %NOTE PSC: Matlab thinks in column vectors, so this would fail in case of two 3x3 matrices when not transposing v and u.

% build rotation matrix
vec_ent = size(v,1);
qw = NaN(vec_ent,1);
qx = qw;
qy = qw;
qz = qw;

for idx = 1:vec_ent
    
    % build rotation matrix
    R = [s(idx,:); u(idx,:); -v(idx,:)];
    
    % calculate quaternion
    m00 = R(1,1);
    m01 = R(1,2);
    m02 = R(1,3);
    m10 = R(2,1);
    m11 = R(2,2);
    m12 = R(2,3);
    m20 = R(3,1);
    m21 = R(3,2);
    m22 = R(3,3);
    
    tr = sum(diag(R));
    if tr>0
        
        S = sqrt(tr+1) * 2;
        qw(idx) = 0.25 * S;
        qx(idx) = -(m21 - m12) / S;
        qy(idx) = -(m02 - m20) / S;
        qz(idx) = -(m10 - m01) / S;
        
    elseif (m00 > m11) && (m00 > m22)
        
        S = sqrt(1 + m00 - m11 - m22) * 2;
        qw(idx) = (m21 - m12) / S;
        qx(idx) = -0.25 * S;
        qy(idx) = -(m01 + m10) / S;
        qz(idx) = -(m02 + m20) / S;
        
    elseif (m11 > m22)
        
        S = sqrt(1 + m11 - m00 - m22) * 2;
        qw(idx) = (m02 - m20) / S;
        qx(idx) = -(m01 + m10) / S;
        qy(idx) = -0.25 * S;
        qz(idx) = -(m12 + m21) / S;
        
    else
        
        S = sqrt(1 + m22 - m00 - m11) * 2;
        qw(idx) = (m10 - m01) / S;
        qx(idx) = -(m02 + m20) / S;
        qy(idx) = -(m12 + m21) / S;
        qz(idx) = -0.25 * S;
        
    end
    
end

% create normalized quaternion object
q = quaternion([qw qx qy qz]);
q = q.normalize;

end