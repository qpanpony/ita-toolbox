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

distance_p = ita_propagation_path_length( pp );
if distance_p / obj.c >  2 * obj.num_bins / obj.fs
    error 'Propagation path length too long, increase number of bins to generate transfer function for this propagation path'
end

incident_spreading_loss_applied = false;

for n = 1 : N
    
    if isa( pp.propagation_anchors, 'cell' )
        anchor = pp.propagation_anchors{ n };
    else
        anchor = pp.propagation_anchors( n );
    end
    assert( strcmpi( anchor.class, 'propagation_anchor' ) )
    
    assert( isfield( anchor, 'anchor_type' ) )
    switch( anchor.anchor_type )
        
        case { 'source', 'emitter', 'receiver', 'sensor' }
            
            if n == N
                if isa( pp.propagation_anchors, 'cell' )
                    target_pos = pp.propagation_anchors{ n - 1 }.interaction_point;
                else
                    target_pos = pp.propagation_anchors( n - 1 ).interaction_point;
                end
                
                % If not already applied by a corresponding anchor type
                % (i.e. diffraction), include incident field now
                if ~incident_spreading_loss_applied
                    if ~obj.sim_prop.diffraction
                        effective_source_distance = distance_p; % whole distance in this case
                    else
                        effective_source_distance = ita_propagation_effective_source_distance( pp, n );
                    end
                    phase_by_delay = obj.phase_delay( effective_source_distance );
                    spreading_loss = ita_propagation_spreading_loss( effective_source_distance, 'spherical' );
                    freq_data_linear = freq_data_linear .* phase_by_delay .* spreading_loss;
                    incident_spreading_loss_applied = true;
                end
                
            else
                
                if isa( pp.propagation_anchors, 'cell' )
                    target_pos = pp.propagation_anchors{ n + 1 }.interaction_point;
                else
                    target_pos = pp.propagation_anchors( n + 1 ).interaction_point;
                end
                
                % Check if sound power is set
                if n == 1
                    
                    p_factor = 1;
                    if isfield( anchor, 'sound_power' )
                        
                        r = 1;
                        rho_0 = 1.292; % Density of air
                        Z_0 = ( rho_0 * obj.c );
                        A = ( 4 * pi * r^2 );
                        I = anchor.sound_power / A;
                        p_factor = sqrt( I * Z_0 ); % Pressure factor @ 1m reference distance
                        
                    end
                    
                    assert( numel( p_factor ) == 1 ) % signal value scalar
                    freq_data_linear = freq_data_linear .* p_factor; % Apply factor corresponding to given sound power
                    
                end
                
            end
            
            target_position_relative = target_pos( 1:3 ) - anchor.interaction_point( 1:3 ); % Outgoing direction vector
            
            if obj.sim_prop.directivity
                freq_data_linear = freq_data_linear .* obj.tf_directivity( anchor, target_position_relative / norm( target_position_relative ) );
            end
            
        case 'specular_reflection'
            
            if n == 1 || n == N
                error( 'Detected a specular reflection at beginning or end of propagation path.' )
            end
            
            source_pos = pp.propagation_anchors{ n - 1 }.interaction_point;
            target_pos = pp.propagation_anchors{ n + 1 }.interaction_point;
            
            effective_source_position =  anchor.interaction_point - source_pos;
            target_position_relative =  target_pos - anchor.interaction_point;
            
            incident_direction_vec = effective_source_position / norm( effective_source_position );
            emitting_direction_vec = target_position_relative / norm( target_position_relative );
            
            if obj.sim_prop.reflection
                freq_data_linear = freq_data_linear .* obj.tf_reflection( anchor, incident_direction_vec, emitting_direction_vec );
            end
            
        case { 'outer_edge_diffraction', 'inner_edge_diffraction' }
            
            if n == 1 || n == N
                error( 'Detected a diffraction at beginning or end of propagation path.' )
            end
            
            source_pos = pp.propagation_anchors{ n - 1 }.interaction_point( 1:3 );
            target_pos = pp.propagation_anchors{ n + 1 }.interaction_point( 1:3 );
            
            source_direction = ( source_pos - anchor.interaction_point( 1:3 ) ) / norm( source_pos - anchor.interaction_point( 1:3 ) );
            target_direction = ( target_pos - anchor.interaction_point( 1:3 ) ) / norm( target_pos - anchor.interaction_point( 1:3 ) );
            
            effective_source_distance = ita_propagation_effective_source_distance( pp, n );
            effective_target_distance = ita_propagation_effective_target_distance( pp, n );
            effective_source_position = anchor.interaction_point( 1:3 ) + source_direction * effective_source_distance;
            effective_target_position = anchor.interaction_point( 1:3 ) + target_direction * effective_target_distance;
            
            if obj.sim_prop.diffraction
                freq_data_linear = freq_data_linear .* obj.tf_diffraction( anchor, effective_source_position, effective_target_position );
                
                % If not already applied by another diffraction edge, include incident field
                if ~incident_spreading_loss_applied
                    phase_by_delay = obj.phase_delay( effective_source_distance );
                    spreading_loss = ita_propagation_spreading_loss( effective_source_distance, 'spherical' );
                    freq_data_linear = freq_data_linear .* phase_by_delay .* spreading_loss;
                    incident_spreading_loss_applied = true;
                end
                
            end
            
        otherwise
            
            sprintf( 'Detected unrecognized anchor type "%s", attempting to continue', anchor.anchor_type )
            
    end
    
end

end
