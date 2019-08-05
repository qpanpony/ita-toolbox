function res = point_facing_main_side( obj, point )
% point_facing_main_side Returns true if the point is on the main side

if ~obj.point_outside_wedge( point )
    error( 'Source position(s) must be outside the wedge!' );
end

warning( 'This function has errors, consider to implement a robust function that does not require this.' )

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

res_t = true( 3, 1 );
res_t( temp2 < temp1 ) = false;

res = any( res_t );

end

