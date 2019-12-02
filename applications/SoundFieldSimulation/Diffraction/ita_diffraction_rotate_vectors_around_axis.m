function v_rot = ita_diffraction_rotate_vectors_around_axis( v, k, theta )
%ita_diffraction_rotate_vectors_around_axis rotates array of vectors by the angle theta
% around the axis k. Direction of the rotation is determined by a right
% handed system.
% v:        Array can be composed of N rows of 3D row vectors or N columns of 3D column vectors. 
%           If v is 3x3 array, it is assumed that it is 3 rows of 3 3D row vectors.
% k:        Rotation axis doesn't have to be normalized.
% theta:    Rotation angle in radiant.

[m, n] = size(v);
if m ~= 3 && n ~= 3
    error('input vector is/are not three dimensional')
end
if size(v) ~= size(k) 
    error('rotation vector v and axis k have different dimensions')
end

k = k / norm( k );
N = numel( v ) / 3;
v_rot = v;    % Initialize result vector array

if n == 3   % Row vectors
    for i = 1 : N
        v_rot(i, :) = v(i, :) * cos(theta) + cross( k, v ) * sin(theta) + k * dot( k, v ) * ( 1 - cos(theta) );
    end
else    % Column vectors
    for i = 1 : N
        v_rot(:, i) = v(:, i) * cos(theta) + cross( k, v ) * sin(theta) + k * dot( k, v ) * ( 1 - cos(theta) );
    end
end
end

