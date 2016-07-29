function [ data, samplerate, metadata ] = dfConvertFromDAFFv15IR( alpha, beta, h )
    [ record_index, out_of_bounds ] = DAFFv15( 'getNearestNeighbourIndex', h, 'data', alpha, beta );
    assert( not ( out_of_bounds == 1 ) );
    data = DAFFv15( 'getRecordByIndex', h, record_index );
    props = DAFFv15( 'getProperties', h );
    samplerate = props.samplerate;
    [ metadata, empty ] = DAFFv15( 'getRecordMetadata', h, record_index );
    if empty
        metadata = [];
    end
end
