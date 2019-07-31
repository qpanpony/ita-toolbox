function alpha_rad = get_angle_from_point_to_aperture( obj, field_point, point_on_aperture )
%Returns angle (radiant) between the ray from field point to aperture point and the
%aperture of the wedge.
%   output angle alpha: 0 <= alpha <= pi/2


if ~obj.point_outside_wedge( field_point )
    error( 'Field point must be outside wedge' );
end
if ~obj.point_on_aperture( point_on_aperture )
    error( 'No point on aperture found' )
end

dir_vec = ( point_on_aperture - field_point ) / norm( point_on_aperture - field_point );
alpha_rad =dot( dir_vec, obj.aperture_direction );
if alpha_rad > pi/2
    alpha_rad = pi - alpha_rad;
end

end

