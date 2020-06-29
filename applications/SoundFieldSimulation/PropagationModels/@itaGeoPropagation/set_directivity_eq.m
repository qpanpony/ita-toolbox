function set_directivity_eq( obj, directivity_id, eq_type, eq_param )
%set_directivity_eq Sets an equalization type and corresponding parameter
%that is used in the tf functions

if ~isfield( obj.directivity_db, directivity_id )
    error( 'Could not find directivity "%s"', directivity_id )
end

if all( ~strcmpi( eq_type, { 'none', 'front', 'gain', 'custom', 'delay' } ) )
    error( 'Could not understand eq type "%s"', eq_type )
end

obj.directivity_db.( directivity_id ).eq_type = eq_type;

if strcmpi( eq_type, 'custom' )
    
    assert( isnumeric( eq_param ) )
    assert( size( eq_param, 1 ) == obj.num_bins )
    obj.directivity_db.( directivity_id ).eq_filter = eq_param;
    
elseif strcmpi( eq_type, 'gain' )
    
    assert( isnumeric( eq_param ) )
    obj.directivity_db.( directivity_id ).eq_gain = eq_param;
    
elseif strcmpi( eq_type, 'delay' )
    
    assert( isnumeric( eq_param ) )
    obj.directivity_db.( directivity_id ).eq_delay = eq_param;
    
elseif strcmpi( eq_type, 'front' )
        
    if isa( obj.directivity_db.( directivity_id ).data, 'DAFF' )

        directivity_data = obj.directivity_db.( directivity_id ).data;
        daff_front_idx = directivity_data.nearest_neighbour_index( 0, 0 );
        
        if strcmpi( directivity_data.properties.contentType, 'ir' )

            directivity_ir = directivity_data.record_by_index( daff_front_idx )';
            directivity_dft = fft( directivity_ir, obj.num_bins * 2 - 1 ); % odd DFT length
            directivity_hdft = directivity_dft( 1:( ceil( obj.num_bins ) ) );

            obj.directivity_db.( directivity_id ).eq_filter = 1 ./ directivity_hdft;

        else
            warning( 'Unrecognized DAFF content type "%s" of directivity with id "%s", cannot set eq filter', directivity_data.properties.contentType, anchor.directivity_id )
        end

    end

end

end
