function point_is_outside = point_outside_wedge( obj, point )
% point_outside_wedge Returns true if point is outside the solid structure of
% the infinite wedge

assert( ita_diffraction_point_is_of_dim3( point ) );

v = ( point - obj.location ) / norm( point - obj.location );
distance_main_plane = dot( v, obj.main_face_normal );
distance_opposite_plane = dot( v, obj.opposite_face_normal );

spatial_threshold = -obj.set_get_geo_eps * 10;
point_is_outside = ( distance_main_plane >= spatial_threshold ) || ...
                   ( distance_opposite_plane >= spatial_threshold );

end
