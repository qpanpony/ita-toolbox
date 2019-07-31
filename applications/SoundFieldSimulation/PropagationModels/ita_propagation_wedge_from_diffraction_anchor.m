function [ w ] = ita_propagation_wedge_from_diffraction_anchor( a )
% ita_propagation_wedge_from_diffraction_anchor Generates a wedge based on the data from a
% diffraction anchor point
%
% Example: [ wedge ] = ita_propagation_wedge_from_diffraction_anchor( anchor )
%

if ~isfield( a, 'anchor_type' )
    error 'Anchor does not contain a type description'
end

if strcmpi( a.anchor_type, 'outer_edge_diffraction' )
    edge_type = 'outer_edge';
elseif strcmpi( a.anchor_type, 'inner_edge_diffraction' )
    edge_type = 'inner_edge';
else    
    error 'Invalid anchor type'
end

main_face_normal = a.main_wedge_face_normal( 1:3 );
opposite_face_normal = a.opposite_wedge_face_normal( 1:3 );
aperture_start = a.vertex_start( 1:3 );
vertex_length = norm( a.vertex_start - a.vertex_end );

w = itaFiniteWedge( main_face_normal, opposite_face_normal, aperture_start, vertex_length, edge_type );

end