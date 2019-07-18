function positions = ita_diffraction_align_points_around_aperture( wedge, field_point, angles, point_of_rotation, ref_face  )
% ITA_ALIGN_POINTS_AROUND_APERTURE rotates field point around the aperture
% of the wedge around the point of rotation with the vector of angles respective to the reference face.
% Returns a set of 3-dim vectors, corresponding to the number of angles, in
% cartesian coordinates: dim( positions ) = #angles x 3,
%   
%   wedge:              instance of class itaInfiniteWedge
%   field_point:        3-dim point outside the wedge
%   angles:             field_point will be rotated by the angle(s) of this
%                       vector. angles cannot be higher than opening angle of
%                       the wedge. (radiant)
%   point_of_rotation:  3-dim point on aperture the field point will be
%                       rotated around.
%   ref_face:           reference face angles are correspindingly denoted from
%                       (boolean: true if reference face is main face)

%% Assertions
if ~( isa( wedge, 'itaInfiniteWedge' ) )
    error( 'wedge must an instance of class itaInfiniteWedge' );
end

if ~ita_diffraction_point_is_of_dim3(field_point)
    error( 'field point must be of dimension 3' );
end

if ~ita_diffraction_point_is_row_vector(field_point)
    field_point = field_point';
end

if ~ita_diffraction_point_is_of_dim3(point_of_rotation)
    error( 'point of rotation must be of dimension 3' );
end

if ~ita_diffraction_point_is_row_vector(point_of_rotation)
    point_of_rotation = point_of_rotation';
end

if ~wedge.point_outside_wedge( field_point )
    error( 'field_point must be outside the wedge!' );
end

if ~wedge.point_outside_wedge( point_of_rotation )
    error( 'field_point must be outside the wedge!' );
end

if any( angles > wedge.opening_angle )
    error( 'angles must be of smaller value than the opening angle of the wedge' );
end

if size( angles, 1 ) ~= 1
    if size( angles, 2 ) ~= 1
        error( 'angles have to be of dimension n x 1 or 1 x n!' );
    end
    angles = angles';
end

%% Calculations
% initialize different positions rotated around the aperture
positions = zeros(numel( angles ), 3);
positions(1, :) = field_point;
apex_dir = wedge.aperture_direction;

% Coordinate transformation
switch ref_face
    case true
        e3 = apex_dir;
        e2 = wedge.main_face_normal;
        e1 = cross( e2, e3 );
        phase_shift_x = acos( dot( e1, [1, 0, 0] ) );
        phase_shift_y = acos( dot( e2, [0, 1, 0] ) );
    case false
        e3 = -apex_dir;
        e2 = wedge.opposite_face_normal;
        e1 = cross( e2, e3 );
        phase_shift_x = acos( dot( e1, [1, 0, 0] ) );
        phase_shift_y = - acos( dot( e2, [0, 1, 0] ) );
end

rho = repmat( norm( field_point - point_of_rotation ), numel( angles ), 1 );
z = repmat( field_point(3), numel( angles ), 1 );

% Set field position in cylindrical coordinates
pos_cylindrical = zeros( numel( angles ), 3 );
pos_cylindrical( :, 1 ) = rho;
pos_cylindrical( :, 2 ) = angles';
pos_cylindrical( :, 3 ) = z;

% Coordinate transformation to cartesian
positions( :, 1 ) = pos_cylindrical( :, 1 ) .* cos( pos_cylindrical( :, 2 ) + phase_shift_x );
positions( :, 2 ) = pos_cylindrical( :, 1 ) .* sin( pos_cylindrical( :, 2 ) + phase_shift_y );
positions( :, 3 ) = - pos_cylindrical( :, 3 );

end

