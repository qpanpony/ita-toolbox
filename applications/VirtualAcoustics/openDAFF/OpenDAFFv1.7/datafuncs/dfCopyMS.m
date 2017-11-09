function [ freqs, mags, metadata ] = dfCopyMS( alpha, beta, h )
    [ record_index, out_of_bounds ] = DAFFv17( 'getNearestNeighbourIndex', h, 'data', alpha, beta );
    assert( not ( out_of_bounds == 1 ) );
    
    mags = DAFFv17( 'getRecordByIndex', h, record_index );
    
    props = DAFFv17( 'getProperties', h );
    freqs = props.freqs;
    [ metadata, empty ] = DAFFv17( 'getRecordMetadata', h, record_index );
    if empty
        metadata = [];
    end
end
