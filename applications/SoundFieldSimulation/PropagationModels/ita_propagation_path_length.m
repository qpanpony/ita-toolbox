function r = ita_propagation_path_length( pps )
%ITA_PROPAGATION_PATH_LENGTH Calculates the path length of all paths in
%propagation path list

N = numel( pps );
r = zeros( N, 1 );

if N == 0
    warning 'Got an empty path list, cannot calculate any path lengths'
    return
end

if ~isfield( pps, 'propagation_anchors' ) % not a list but only one path
    error( 'Need a propagation path or path list' )
end


for n = 1:N

    propagation_path = pps( n );
    
    M = numel( propagation_path.propagation_anchors );
    if M < 2
        error( 'Propagation path has less than two anchor points, cannot calculate a transfer function' )
    end
    
    for m = 1 : M-1
        
        if isa( propagation_path.propagation_anchors, 'cell' )
            prev_anchor_pos = propagation_path.propagation_anchors{ m }.interaction_point( 1:3 );
            next_anchor_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point( 1:3 );
        else
            prev_anchor_pos = propagation_path.propagation_anchors( m ).interaction_point( 1:3 );
            next_anchor_pos = propagation_path.propagation_anchors( m + 1 ).interaction_point( 1:3 );
        end
        r( n ) = r( n ) + norm( next_anchor_pos - prev_anchor_pos );
        
    end
end

end
