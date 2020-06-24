function [ linear_freq_data ] = tf_directivity( obj, anchor, wave_front_direction )
%TF_DIRECTIVITY Returns the directivity transfer function for an anchor and
%a target (incoming or outgoing wave front direction relative (not in world coordinates!) to anchor point)

linear_freq_data = ones( obj.num_bins, 1 );

if ~isfield( anchor, 'directivity_id' )
    return
end

if ~isfield( obj.directivity_db, anchor.directivity_id )
    warning( 'Directivity id "%s" not found in database, skipping directivity tf calculation', anchor.directivity_id )
    return
end

directivity_data = obj.directivity_db.( anchor.directivity_id );

if isa( directivity_data, 'DAFF' )

    q_object = quaternion( anchor.orientation );
    v = wave_front_direction( 1:3 ) / norm( wave_front_direction( 1:3 ) );
    q_target = quaternion.rotateutov( [ 1 0 0 ], v );
    q_combined = q_target * conj( q_object );
    euler_angles = q_combined.EulerAngles( 'zxy' );
    azi_deg = rad2deg( euler_angles( 1 ) );
    ele_deg = rad2deg( euler_angles( 2 ) );
    idx = directivity_data.nearest_neighbour_index( azi_deg, ele_deg );
    
    if strcmpi( directivity_data.properties.contentType, 'ir' )
        directivity_ir = directivity_data.record_by_index( idx )';
        directivity_dft = fft( directivity_ir, obj.num_bins * 2 - 1 ); % odd DFT length
        directivity_hdft = directivity_dft( 1:( ceil( obj.num_bins ) ) );
        linear_freq_data = directivity_hdft;
    else
        warning( 'Unrecognized DAFF content type "%s" of directivity with id "%s"', directivity_data.properties.contentType, anchor.directivity_id )
    end
    
else
    warning( 'Unrecognized directivity format "%s" of directivity with id "%s"', class( directivity_data ), anchor.directivity_id )
end

end

