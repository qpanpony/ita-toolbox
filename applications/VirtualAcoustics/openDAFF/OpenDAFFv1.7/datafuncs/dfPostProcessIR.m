function [ data, samplerate, metadata ] = dfPostProcessIR( alpha, beta, h )
    [ record_index, out_of_bounds ] = DAFFv17( 'getNearestNeighbourIndex', h, 'data', alpha, beta );
    props = DAFFv17( 'getProperties', h );
    samplerate = props.samplerate;
    metadata = [];
    assert( not ( out_of_bounds == 1 ) );
    data_in = DAFFv17( 'getRecordByIndex', h, record_index );
    
    ir = itaAudio();
    ir.timeData = data_in';
    
    % to something ...
    
    data = ir.timeData';
end
