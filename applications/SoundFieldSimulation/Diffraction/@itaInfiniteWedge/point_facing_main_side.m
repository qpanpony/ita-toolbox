function res = point_facing_main_side( obj, point  )
% Returns string including the face normal of source
%   facing wedge side
%   output: 'n1' -> source is facing main face of wedge
%           'n2' -> source is facing opposite face of wedge

%% Assertions
dim = size( point );
if dim(2) ~= 3
    if dim(1) ~= 3
        error( 'Position vectors must be of dimension 3!' );
    end
    %point = point';
    dim = size( point );
end
if any( ~obj.point_outside_wedge( point ) )
    error( 'Source position(s) must be outside the wedge!' );
end

%% begin
% Coordinate transformation with aperture location as origin
% e_z = repmat( obj.aperture_direction, dim(1), 1 );
% e_y1 = repmat( obj.main_face_normal, dim(1), 1 );
%e_x1 = cross( e_y1, e_z, 2 ); % direction of main face of the wedge
%e_y2 = repmat( obj.opposite_face_normal, dim(1), 1 );
%e_x2 = cross( e_z, e_y2, 2 );

e_z = obj.aperture_direction;
e_y1 = obj.main_face_normal;
e_x1 = cross( e_y1, e_z );

e_y2 = obj.opposite_face_normal;
e_x2 = cross( e_z, e_y2 );

% Calculate angle between incedent ray from source to aperture point and source facing wedge
% side
x_i1 = dot( point - obj.location, e_x1, 2 );  % coordinates in new coordinate system
y_i1 = dot( point - obj.location, e_y1, 2 );
temp1 = atan2( y_i1, x_i1 );
temp1( temp1 < 0 ) = temp1( temp1 < 0 ) + 2*pi;

x_i2 = dot( point - obj.location, e_x2, 2 );  % coordinates in new coordinate system
y_i2 = dot( point - obj.location, e_y2, 2 );
temp2 = atan2( y_i2, x_i2 );
temp2( temp2 < 0 ) = temp2( temp2 < 0 ) + 2*pi;

res = true( dim(1), 1 );
res( temp2 < temp1 ) = false;

end

