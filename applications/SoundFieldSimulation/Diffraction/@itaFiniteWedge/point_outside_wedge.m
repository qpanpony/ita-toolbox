function b = point_outside_wedge( obj, point )
    % point_outside_wedge Returns true if the point is outside the solid structure of
    % the finite wedge
    %
    % Example: b = w.point_outside_wedge( point )
    %
    
    assert( all( size( point ) == size( obj.location ) ) )
    assert( abs( norm( obj.main_face_normal ) - 1 ) < obj.set_get_geo_eps )
    assert( abs( norm( obj.opposite_face_normal ) - 1 ) < obj.set_get_geo_eps )

    % Use Hesse normal form
    d1 = dot( point - obj.location, obj.main_face_normal );
    d2 = dot( point - obj.location, obj.opposite_face_normal );
    
    % Bad error propagation for face normals ... use a very soft resolution
    % for a point beeing inside or outside a wedge.
    b = any( [ d1 d2 ] > (-2) * obj.set_get_geo_eps);
    
end
