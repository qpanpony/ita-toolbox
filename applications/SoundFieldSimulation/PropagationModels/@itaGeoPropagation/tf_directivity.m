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

directivity_t = obj.directivity_db.( anchor.directivity_id );
directivity_data = directivity_t.data;

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
        directivity_dft = fft( directivity_ir, obj.num_bins * 2 - 1 ); % odd DFT length
        directivity_hdft = directivity_dft( 1:( ceil( obj.num_bins ) ) );
        
        if any( strcmpi( directivity_t.eq_type, { 'custom', 'front' } ) )
            linear_freq_data = directivity_hdft .* directivity_t.eq_filter;
        elseif strcmpi( directivity_t.eq_type, { 'gain' } )
            linear_freq_data = directivity_hdft .* directivity_t.eq_gain;
        elseif strcmpi( directivity_t.eq_type, { 'delay' } )
            phase_by_delay = [ 1; exp( -1i .* 2 * pi * obj.freq_vec( 2:end ) * directivity_t.eq_delay ) ];
            linear_freq_data = directivity_hdft ./ phase_by_delay;
        elseif strcmpi( directivity_t.eq_type, { 'none' } )
            linear_freq_data = directivity_hdft;    
        else
            warning 'Unknown equalization for directivity, using untouched data instead'
            linear_freq_data = directivity_hdft;
        end
        
        
    else
        warning( 'Unrecognized DAFF content type "%s" of directivity with id "%s"', directivity_data.properties.contentType, anchor.directivity_id )
    end
    
else
    warning( 'Unrecognized directivity format "%s" of directivity with id "%s"', class( directivity_data ), anchor.directivity_id )
end

end

