function bRes = point_outside_wedge( obj, point )
    % Returns true if point is outside the solid structure of
    % the infinite wedge
    
    assert( ita_diffraction_point_is_of_dim3( point ) );
        
    distFromPoint2MainFace = dot( point - obj.location, obj.main_face_normal );
    distFromPoint2OppositeFace = dot( point - obj.location, obj.opposite_face_normal );
    
    bRes = (distFromPoint2MainFace >= -obj.set_get_geo_eps) || (distFromPoint2OppositeFace >= -obj.set_get_geo_eps);
end
