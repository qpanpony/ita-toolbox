function [ reflection_order, diffraction_order ] = ita_propagation_path_orders( pp )
% ita_propagation_path_orders Returns the reflection and diffraction order
% of the path.

reflection_order = 0;
diffraction_order = 0;

anchors = pp.propagation_anchors;
N = numel( anchors );

if N < 2 
    error 'Invalid propagation paths, at least to anchors expected'
end

for n = 1:N
    
    if isa( anchors, 'struct' )
        anchor = anchors( n );
    else
        anchor = anchors{ n };
    end
    
    switch anchor.anchor_type
        case { 'outer_edge_diffraction', 'inner_edge_diffraction' }
            diffraction_order = diffraction_order + 1;
        case 'specular_reflection'
            reflection_order = reflection_order + 1;
    end
    
end

end