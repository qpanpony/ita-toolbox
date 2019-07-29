function wedge_type_correct_ret_val = ita_propagation_validate_anchor_wedge_type( diffraction_wedge_anchor )

assert( strcmpi( diffraction_wedge_anchor.class, 'propagation_anchor' ) )

% Right handed system & outer edge -> same direction of aperture
aperture_direction_RHS = cross( diffraction_wedge_anchor.main_wedge_face_normal( 1:3 ), diffraction_wedge_anchor.opposite_wedge_face_normal( 1:3 ) );
same_direction = dot( aperture_direction_RHS,  diffraction_wedge_anchor.vertex_end( 1:3 ) - diffraction_wedge_anchor.vertex_start( 1:3 ) );

wedge_type_correct = false;
if strcmpi( diffraction_wedge_anchor.anchor_type, 'inner_edge_diffraction' )
    if same_direction <= 0
        wedge_type_correct = true;
    end
elseif strcmpi( diffraction_wedge_anchor.anchor_type, 'outer_edge_diffraction' )
    if same_direction > 0
        wedge_type_correct = true;
    end
else
    error 'Did not get an edge propagation anchor type'
end

if nargout == 0 && not( wedge_type_correct )
    raise 'Wedge type incorrect'
elseif nargout > 0
    wedge_type_correct_ret_val = wedge_type_correct;
end

end