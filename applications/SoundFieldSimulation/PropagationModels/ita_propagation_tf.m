function [ freq_data_linear ] = ita_propagation_tf( propagation_path, fs, fft_degree )
%ITA_PROPAGATION_PATH_TRANSFER_FUNCTION Calculates the transfer function
%of a (geometrical) propagation path calculated in frequency domain for a
%given sampling rate and fft degree (defaults to fs = 44100 and fft_degree = 15)
%

if nargin < 2
    fs = 44100;
end
if nargin < 3
    fft_degree = 15;
end

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

freq_data_linear = ones( prop_tfs.nBins, 1 );


for m = 1 : N

    anchor = propagation_path.propagation_anchors{ m };
    assert( strcmpi( anchor.class, 'propagation_anchor' ) )
    
    assert( isfield( anchor, 'anchor_type' ) )
    switch( anchor.anchor_type )
        
        case { 'source', 'emitter', 'receiver', 'sensor' }
            
            if m == N
                target_pos = propagation_path.propagation_anchors{ N - 1 }.interaction_point;
            else
                target_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point;
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
            
            % @todo assemble wedge from anchor infos
            
            source_pos = propagation_path.propagation_anchors{ m - 1 }.interaction_point;
            target_pos = propagation_path.propagation_anchors{ m + 1 }.interaction_point;
            
            effective_source_position =  anchor.interaction_point - source_pos; % @todo backtrack effective emitting point via reflections!
            target_position =  target_pos - anchor.interaction_point;
            
            prop_tfs.freqData( :, m ) = ita_propagation_diffraction( anchor, effective_source_position, target_position, fs, fft_degree  );
            
        otherwise
            
            sprintf( 'Detected unrecognized anchor type "%s", attempting to continue', anchor.anchor_type )
        
    end

    freq_data_linear = freq_data_linear .* prop_tfs.freqData( :, m );

end


end

