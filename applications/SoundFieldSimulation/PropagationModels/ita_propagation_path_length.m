function r = ita_propagation_path_length( propagation_path )
%ITA_PROPAGATION_PATH_LENGTH Calculates the path length

N = numel( propagation_path.propagation_anchors );
if N < 2
    error( 'Propagation path has less than two anchor points, cannot calculate a transfer function' )
end

r = 0;
for m = 1 : N-1

    prev_anchor_pos = propagation_path.propagation_anchors{ m }.interaction_point;
    next_anchor_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point;
    
    r = r + norm( next_anchor_pos - prev_anchor_pos );
    
end

end