function b = point_outside_wedge( obj, point )
    % Returns true if point is outside the solid structure of
    % the infinite wedge
    
    dim = size( point );
    if dim(2) ~= 3
        if dim(1) ~= 3
            error( 'Point(s) must be of dimension 3')
        end
        point = point';
        dim = size( point );
    end
    
    dist_from_main_face = sum( (point - obj.location) .* obj.main_face_normal, 2 );
    dist_from_opposite_face = sum( (point - obj.location) .* obj.opposite_face_normal, 2 );
    
    b = false( dim(1), 1 );
    mask = ( dist_from_main_face < -obj.set_get_geo_eps ) & ( dist_from_opposite_face < -obj.set_get_geo_eps );   
    b(~mask) = true;
    
end
