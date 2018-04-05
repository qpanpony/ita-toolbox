function [r, p, y] = ita_vu2rpy(v, u)
% function [roll_rad, pitch_rad, yaw_rad] = ita_vu2rpy(v, u)
%
% This function calculates yaw/pitch/roll angles in [rad] from given
% view/up vectors.
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
% If M view/up vectors are used dimensions must be Mx3. Function output is 
% a matrix with size(roll_rad)  = Mx1
%               size(pitch_rad) = Mx1
%               size(yaw_rad)   = Mx1
%
% See also: quaternion.m
%
% Authors: Florian Pausch, Jonas Stienen
% e-Mail:  {fpa, jst}@akustik.rwth-aachen.de
% Version: 2018-04-05
%
% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

%% Check input
if ~ismatrix(v) && ~ismatrix(u)
    error('[ita_vu2rpy] Input must be a vector/matrix with dimensions Mx3 each.')
end

if isvector(v)     % force view/up to be row vectors
    v = (v(:))';
    u   = (u(:))';
elseif ismatrix(v) % check size of input matrices
    if size(v,2)~=3
        error('[ita_vu2rpy] Input dimensions for view/up must be Mx3 each.')
    end
end

% return NaN values for roll/pitch/yaw if all elements of view/up are NaN
if sum(isnan(v(:)))==numel(v) || sum(isnan(u(:)))==numel(u)
    r = NaN(size(v,1),1);
    p = r;
    y = r;
    return
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
    v = sqrt( ones ./ (nansum((v.*v)')) )' * ones(1,colv).*v;
    u = sqrt( ones ./ (nansum((u.*u)')) )' * ones(1,colu).*u;
end

% init.
y = NaN(size(v,1),1);
p = y;
r = y;

gimbal_eps = 1e-2;    % define epsilon for gimbal lock

%% Transform (solve gimbal locks)
%% Problem 1: view points to north pole => Gimbal lock between yaw and roll
if sum(v(:,2) >= (1 - gimbal_eps))
    cond1 = v(:,2)>=(1-gimbal_eps);
    
    y(cond1) = atan2(u(cond1,1),u(cond1,3));
    p(cond1) = pi/2;
    r(cond1) = 0;
end

%% Problem 2: view points to south pole => Gimbal lock between yaw and roll
if sum(v(:,2) <= -(1 - gimbal_eps))
    cond2 = ( v(:,2)<=-(1-gimbal_eps) ) & isnan(y);
    
    y(cond2) = atan2(-u(cond2,1),-u(cond2,3));
    p(cond2) = -pi/2;
    r(cond2) = 0;
end

%% Problem 3: View does not point to a pole (see above)
%             but up-vector lies within horizontal XZ plane.
%
%  Solution: Roll can only be +90°/-90°.
%            Decide by hemisphere which crossprod(v,u) falls.
%            Upper hemisphere (y>=0) means -90°

if sum(~(v(:,2)>=(1-gimbal_eps)) & ~(v(:,2)<=-(1-gimbal_eps)))
    cond3 = ~(v(:,2)>=(1-gimbal_eps)) & ~(v(:,2)<=-(1-gimbal_eps));
    
    y(cond3) = atan2( -v(cond3,1),-v(cond3,3)); %yaw=atan2(v(x),v(z))
    p(cond3) = asin( v(cond3,2) );   %pitch=asin(v(y))
    
    % Calculate Roll
    z        = zeros(size(v,1),1);
    z(cond3) = v(cond3,3).*u(cond3,1) - v(cond3,1).*u(cond3,3);
    
    if ( u(cond3,2)<=gimbal_eps ) & ( u(cond3,2)>=-gimbal_eps ) %#ok<AND2>
        
        cond4 = z<=0 & isnan(r);
        cond5 = z>0 & isnan(r);
        
        if sum(z(cond3) <= 0)
            r(cond4) = pi/2;
        end
        
        if sum(z(cond3) > 0)
            r(cond5) = -pi/2;
        end
        
    else
        
        % Hint: cos(pitch) = cos( arcsin(vy) ) = sqrt(1-vy^2)
        cp = sqrt( 1 - v(:,2).*v(:,2) );
        
        cond4 = z<=0 & isnan(r);
        cond5 = z>0 & isnan(r);
        
        if sum(z(cond3) <= 0)
            r(cond4) = acos( u(cond4, 2) ./ cp(cond4) );
        end
        
        if sum(z(cond3) > 0)
            r(cond5) = -acos( u(cond5, 2) ./ cp(cond5) );
        end
        
    end
    
end

% set all values of rpy to NaN where vu is NaN
if sum(isnan(v(:)))>1 || sum(isnan(u(:)))>1
   r(isnan(v(:,1))) = NaN;
   p(isnan(v(:,1))) = NaN;
   y(isnan(v(:,1))) = NaN;
end

