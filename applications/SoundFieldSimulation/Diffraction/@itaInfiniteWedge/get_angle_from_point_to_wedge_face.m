function theta = get_angle_from_point_to_wedge_face( obj, point, use_main_face )
%GET_ANGLE_FROM_SOURCE_TO_WEDGE_FACE    Returns angle (radiant) between
%   given point and a wedge face.
%   input:  point           arbitrary field point outside the wedge.
%           use_main_face   True for main face, otherwise opposite face
%                           is used.
%   output: theta           azimuth angle (radiant) in cylinder coordinates with
%                           the aperture as z axis. Between [0, 2*pi]

%% Assertions
if ~ita_diffraction_point_is_of_dim3( point )
    error( 'Point has to be of dimension 3' );
end

if any( ~obj.point_outside_wedge( point ) )
    error('Point(s) must be outside the wedge');
end

if nargin < 3
    use_main_face = true;
end

%% Begin
% define cartesian coordinate system
e_z = obj.aperture_direction;
if use_main_face
    e_y = obj.main_face_normal;
else
    e_y = obj.opposite_face_normal;
end
e_x = cross( e_z, e_y );

% Determine coordinates of point in new coordinate system
x_new = dot( point - obj.location, e_x );  
y_new = dot( point - obj.location, e_y );

% Calculate angle between incedent ray from source to aperture point and reference wedge side
theta = atan2( y_new, x_new );
if theta < 0
    theta = theta + 2*pi; % -> output between [0, 2*pi]
end

end

