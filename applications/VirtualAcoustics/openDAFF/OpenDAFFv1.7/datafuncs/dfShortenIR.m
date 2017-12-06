function [ data, samplerate, metadata ] = dfShortenIR( alpha, beta, h )
    [ record_index, out_of_bounds ] = DAFFv17( 'getNearestNeighbourIndex', h, 'data', alpha, beta );
    assert( not ( out_of_bounds == 1 ) );
    data_in = DAFFv17( 'getRecordByIndex', h, record_index );
    data = data_in( :, 1:128 );
    props = DAFFv17( 'getProperties', h );
    samplerate = props.samplerate;
    metadata = [];
end
