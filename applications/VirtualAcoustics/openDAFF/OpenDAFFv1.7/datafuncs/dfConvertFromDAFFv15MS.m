function [ freqs, mags, metadata ] = dfConvertFromDAFFv15MS( alpha, beta, h )
    [ record_index, out_of_bounds ] = DAFFv15( 'getNearestNeighbourIndex', h, 'data', alpha, beta );
    assert( not ( out_of_bounds == 1 ) );
    
    % if you want to transform magnitudes into amplitudes
    %mags = 10.^( DAFFv15( 'getRecordByIndex', h, record_index ) ./ 10 );
    % else
    mags = abs( DAFFv15( 'getRecordByIndex', h, record_index ) );
    
    props = DAFFv15( 'getProperties', h );
    freqs = props.freqs;
    [ metadata, empty ] = DAFFv15( 'getRecordMetadata', h, record_index );
    if empty
        metadata = [];
    end
end
