function alpha = angle_main_face( obj, point )
%angle_main_face    Returns angle (radiant) between given point and a wedge face.
%   input:  point           arbitrary field point outside the wedge.
%   output: theta           azimuth angle (radiant) in cylinder coordinates with
%                           the aperture as z axis. Between [0, 2*pi]

if numel( point ) ~= 3
    error( 'Point has to be of dimension 3' );
end

if ~obj.point_outside_wedge( point )
    error 'Point was inside wedge'
end

% Transform coordinate system into the reference frame of wedge
% and use cylinder coordinates

e_y = obj.main_face_normal;
e_z = obj.aperture_direction;
e_x = cross( e_y, e_z );

x_cylinder = dot( point - obj.location, e_x );  
y_cylinder = dot( point - obj.location, e_y );

% Calculate angle between incedent ray from source to aperture point and
% wedge face
alpha = atan2( y_cylinder, x_cylinder );

% Adjust output, range must be between [ 0, 2 * pi ]
if alpha < 0
    alpha = alpha + 2 * pi;
end

end

