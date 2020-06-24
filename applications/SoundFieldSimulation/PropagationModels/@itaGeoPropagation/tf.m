function [ freq_data_linear ] = tf( obj, pp )
%TFS Calculates the transfer functions (tfs) of the (geometrical) propagation paths in frequency domain

if ~isfield( obj.pps, 'propagation_anchors' )
    error( 'The propagation_path argument does not contain a field "propagation_anchors"' )
end

N = numel( pp.propagation_anchors );
if N < 2
    error( 'Propagation path has less than two anchor points, cannot calculate a transfer function' )
end

freq_data_linear = ones( obj.num_bins, 1 );

%lambda = obj.c ./ obj.freq_vec( 2:end )'; % Wavelength
%k = ( 2 * pi ) ./ lambda; % Wavenumber

distance = ita_propagation_path_length( pp );
if distance / obj.c >  2 * obj.num_bins / obj.fs
    error 'Propagation path length too long, increase number of bins to generate transfer function for this propagation path'
end

incident_spreading_loss_applied = false;

for m = 1 : N
    
    if N > 2
        anchor = pp.propagation_anchors{ m };
    else
        anchor = pp.propagation_anchors( m );
    end
    assert( strcmpi( anchor.class, 'propagation_anchor' ) )
    
    assert( isfield( anchor, 'anchor_type' ) )
    switch( anchor.anchor_type )
        
        case { 'source', 'emitter', 'receiver', 'sensor' }
            
            if m == N
                if N > 2
                    target_pos = pp.propagation_anchors{ m - 1 }.interaction_point;
                else
                    target_pos = pp.propagation_anchors( m - 1 ).interaction_point;
                end
                
                % If not already applied by a corresponding anchor type
                % (i.e. diffraction), include incident field now
                if ~incident_spreading_loss_applied                    
                    effective_source_distance = ita_propagation_effective_source_distance( pp, m );
                    phase_by_delay = obj.phase_delay( effective_source_distance );
                    spreading_loss = ita_propagation_spreading_loss( distance, 'spherical' );
                    freq_data_linear = freq_data_linear .* phase_by_delay .* spreading_loss;
                    incident_spreading_loss_applied = true;                    
                end
                
            else
                if N > 2
                    target_pos = pp.propagation_anchors{ m + 1 }.interaction_point;
                else
                    target_pos = pp.propagation_anchors( m + 1 ).interaction_point;
                end
            end
            
            target_position_relative = target_pos - anchor.interaction_point; % Outgoing direction vector
            
            freq_data_linear = freq_data_linear .* obj.tf_directivity( anchor, target_position_relative / norm( target_position_relative ) );
            
            
        case 'specular_reflection'
            
            if m == 1 || m == N
                error( 'Detected a specular reflection at beginning or end of propagation path.' )
            end
            
            source_pos = pp.propagation_anchors{ m - 1 }.interaction_point;
            target_pos = pp.propagation_anchors{ m + 1 }.interaction_point;
            
            effective_source_position =  anchor.interaction_point - source_pos;
            target_position_relative =  target_pos - anchor.interaction_point;
            
            incident_direction_vec = effective_source_position / norm( effective_source_position );
            emitting_direction_vec = target_position_relative / norm( target_position_relative );
            
            freq_data_linear = freq_data_linear .* obj.tf_reflection( anchor, incident_direction_vec, emitting_direction_vec );
            
            
        case { 'outer_edge_diffraction', 'inner_edge_diffraction' }
            
            if m == 1 || m == N
                error( 'Detected a diffraction at beginning or end of propagation path.' )
            end
                        
            source_pos = pp.propagation_anchors{ m - 1 }.interaction_point;
            target_pos = pp.propagation_anchors{ m + 1 }.interaction_point;
            
            source_direction = ( source_pos - anchor.interaction_point ) / norm( source_pos - anchor.interaction_point );
            target_direction = ( target_pos - anchor.interaction_point ) / norm( target_pos - anchor.interaction_point );
            
            effective_source_distance = ita_propagation_effective_source_distance( pp, m );
            effective_target_distance = ita_propagation_effective_target_distance( pp, m );
            effective_source_position = anchor.interaction_point + source_direction * effective_source_distance;
            effective_target_position = anchor.interaction_point + target_direction * effective_target_distance;
            
            freq_data_linear = freq_data_linear .* obj.tf_diffraction( anchor, effective_source_position, effective_target_position );
            
            % If not already applied by another diffraction edge, include incident field
            if ~incident_spreading_loss_applied
                phase_by_delay = obj.phase_delay( effective_source_distance );
                spreading_loss = ita_propagation_spreading_loss( distance, 'spherical' );
                freq_data_linear = phase_by_delay .* spreading_loss;
                incident_spreading_loss_applied = true;
            end
            
        otherwise
            
            sprintf( 'Detected unrecognized anchor type "%s", attempting to continue', anchor.anchor_type )
            
    end
    
end

end
