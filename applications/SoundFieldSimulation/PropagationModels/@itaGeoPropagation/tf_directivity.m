function [ linear_freq_data ] = tf_directivity( obj, anchor, wave_front_direction )
%TF_DIRECTIVITY Returns the directivity transfer function for an anchor and
%a target (incoming or outgoing wave front direction relative (not in world coordinates!) to anchor point)

assert( isa( anchor, 'struct' ) )

linear_freq_data = ones( obj.num_bins, 1 );

if ~isfield( anchor, 'directivity_id' )
    return
end

if ~isfield( obj.directivity_db, anchor.directivity_id )
    warning( 'Directivity id "%s" not found in database, skipping directivity tf calculation', anchor.directivity_id )
    return
end

directivity_data = obj.directivity_db.( anchor.directivity_id ).data;
delay_samples = obj.directivity_db.( anchor.directivity_id ).delay_samples;

if isa( directivity_data, 'DAFF' )

    q_object = quaternion( anchor.orientation );
    v = wave_front_direction( 1:3 ) / norm( wave_front_direction( 1:3 ) );
    q_target = quaternion.rotateutov( [ 1 0 0 ], v );
    q_combined = q_target * conj( q_object );
    euler_angles = q_combined.EulerAngles( 'ZYX' );
    azi_deg = rad2deg( real( euler_angles( 1 ) ) );
    ele_deg = rad2deg( real( euler_angles( 2 ) ) );
    idx = directivity_data.nearest_neighbour_index( azi_deg, ele_deg );
    
    if strcmpi( directivity_data.properties.contentType, 'ir' )
        directivity_ir = directivity_data.record_by_index( idx )';
        assert( numel( directivity_ir ) > delay_samples );
        
        directivity_dft = fft( directivity_ir, obj.num_bins * 2 - 1 ); % odd DFT length
        
        dirac_delay = zeros( numel( directivity_ir ), 1 );
        dirac_delay( ceil( delay_samples ) ) = 1;        
        directivity_dft_group_delay = fft( dirac_delay, obj.num_bins * 2 - 1 ); % odd DFT length
        
        directivity_dft_compensated = directivity_dft ./ directivity_dft_group_delay;
                
        directivity_hdft = directivity_dft_compensated( 1:( ceil( obj.num_bins ) ) );
        linear_freq_data = directivity_hdft;
    else
        warning( 'Unrecognized DAFF content type "%s" of directivity with id "%s"', directivity_data.properties.contentType, anchor.directivity_id )
    end
    
else
    warning( 'Unrecognized directivity format "%s" of directivity with id "%s"', class( directivity_data ), anchor.directivity_id )
end

end

