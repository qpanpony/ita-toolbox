function [ freq_data_linear ] = ita_propagation_tf( propagation_path, fs, fft_degree, c )
%ITA_PROPAGATION_PATH_TF Calculates the transfer function (tf)
%of a (geometrical) propagation path in frequency domain for a
%given sampling rate and fft degree. Provide speed of sound, see also
%ita_propagation_load_defaults
%

if ~isfield( propagation_path, 'propagation_anchors' )
    error( 'The propagation_path argument does not contain a field "propagation_anchors"' )
end

N = numel( propagation_path.propagation_anchors );
if N < 2
    error( 'Propagation path has less than two anchor points, cannot calculate a transfer function' )
end


prop_tfs = itaAudio;
prop_tfs.samplingRate = fs;
prop_tfs.fftDegree = fft_degree;
prop_tfs.freqData = ones( prop_tfs.nBins, N );

lambda = c ./ prop_tfs.freqVector( 2:end )'; % Wavelength
k = (2 * pi) ./ lambda; % Wavenumber

distance = ita_propagation_path_length( propagation_path );
if distance / c > prop_tfs.trackLength
    error 'Propagation path length too long, increase fft degree to generate transfer function for this propagation path'
end

phase_by_delay = ita_propagation_delay( distance, c, fs, fft_degree );
spreading_loss = ita_propagation_spreading_loss( distance, 'spherical' );

freq_data_linear = phase_by_delay .* spreading_loss;

for m = 1 : N

    if N > 2
        anchor = propagation_path.propagation_anchors{ m };
    else
        anchor = propagation_path.propagation_anchors( m );
    end
    assert( strcmpi( anchor.class, 'propagation_anchor' ) )
    
    assert( isfield( anchor, 'anchor_type' ) )
    switch( anchor.anchor_type )
        
        case { 'source', 'emitter', 'receiver', 'sensor' }
            
            if m == N
                if N > 2
                            target_pos = propagation_path.propagation_anchors{ N - 1 }.interaction_point;
                else
                            target_pos = propagation_path.propagation_anchors( N - 1 ).interaction_point;
                end
            else
                if N > 2
                    target_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point;
                else
                    target_pos = propagation_path.propagation_anchors( m + 1 ).interaction_point;
                end
            end

            target_position = target_pos - anchor.interaction_point; % Outgoing direction vector
            
            prop_tfs.freqData( :, m ) = ita_propagation_directivity( anchor, target_position / norm( target_position ), fs, fft_degree );
        
            
        case 'specular_reflection'
            
            if m == 1 || m == N
                error( 'Detected a specular reflection at beginning or end of propagation path.' )
            end
            
            source_pos = propagation_path.propagation_anchors{ m - 1 }.interaction_point;
            target_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point;
            
            effective_source_position =  anchor.interaction_point - source_pos;
            target_position =  target_pos - anchor.interaction_point;
            
            incident_direction_vec = effective_source_position / norm( effective_source_position );
            emitting_direction_vec = target_position / norm( target_position );
            
            prop_tfs.freqData( :, m ) = ita_propagation_specular_reflection( anchor, incident_direction_vec, emitting_direction_vec, fs, fft_degree  );


        case { 'outer_edge_diffraction', 'inner_edge_diffraction' }
            
            if m == 1 || m == N
                error( 'Detected a diffraction at beginning or end of propagation path.' )
            end
            
            source_pos = propagation_path.propagation_anchors{ m - 1 }.interaction_point;
            target_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point;
            
            source_direction = ( source_pos - anchor.interaction_point ) / norm( source_pos - anchor.interaction_point );
            target_direction = ( target_pos - anchor.interaction_point ) / norm( target_pos - anchor.interaction_point );
            
            effective_source_distance = ita_propagation_effective_source_distance( propagation_path, m );
            effective_target_distance = ita_propagation_effective_target_distance( propagation_path, m );
            effective_source_position = anchor.interaction_point + source_direction * effective_source_distance;
            effective_target_position = anchor.interaction_point + target_direction * effective_target_distance;
                        
            prop_tfs.freqData( :, m ) = ita_propagation_diffraction( anchor, effective_source_position, effective_target_position, 'utd', fs, fft_degree );
            
        otherwise
            
            sprintf( 'Detected unrecognized anchor type "%s", attempting to continue', anchor.anchor_type )
        
    end
    
    freq_data_linear = freq_data_linear .* prop_tfs.freqData( :, m );


end

end
