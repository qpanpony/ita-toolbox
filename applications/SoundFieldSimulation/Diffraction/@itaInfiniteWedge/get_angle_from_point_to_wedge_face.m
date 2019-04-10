function theta = get_angle_from_point_to_wedge_face( obj, point_position, reference_face )
%GET_ANGLE_FROM_SOURCE_TO_WEDGE_FACE    Returns angle (radiant) between
%   given point and a wedge face.
%   input:  point_pos           arbitrary field point outside the wedge
%           reference_face      reference wedge face which the angle will
%                               be denoted from
%   output: theta               azimuth angle (radiant) in cylinder coordinates with
%                               the aperture as z axis

%% Assertions
dim = size( point_position );
if dim(2) ~= 3
    if dim(1) ~= 3
        error( 'Field points have to be of dimension 3' );
    end
    point_position = point_position';
    dim = size( point_position );
end
% if any( (reference_face ~= 'main face') & (reference_face ~= 'opposite face') )
%     error( 'Reference face must be either main face or opposite face. You may also use itaInfiniteWedge.get_source_facing_side().' )
% end
if any( ~obj.point_outside_wedge( point_position ) )
    error('Point(s) must be outside the wedge');
end

%% Begin
e_z = repmat( obj.aperture_direction, dim(1), 1 );
e_y = zeros( dim(1), 3 );
e_y( reference_face, : ) = repmat( obj.main_face_normal, sum( reference_face ), 1 );
e_y( ~reference_face, : ) = repmat( obj.opposite_face_normal, sum( ~reference_face ), 1 );
e_x = cross( e_z, e_y, 2 );

% Calculate angle between incedent ray from source to aperture point and source facing wedge
% side
x_i = dot( point_position - obj.location, e_x, 2 );  % coordinates in new coordinate system
y_i = dot( point_position - obj.location, e_y, 2 );
theta = atan2( y_i, x_i );
theta( theta < 0 ) = theta( theta < 0 ) + 2*pi;

end

