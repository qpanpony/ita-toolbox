function alpha = angle_opposite_face( obj, point )
%angle_opposite_face    Returns angle (radiant) between given point and the opposite wedge face.
%   input:  point           arbitrary field point outside the wedge.
%   output: theta           azimuth angle (radiant) in cylinder coordinates with
%                           the aperture as -z axis. Between [0, 2*pi]

alpha = obj.opening_angle - obj.angle_main_face( point );
assert( alpha >= 0 )

end

