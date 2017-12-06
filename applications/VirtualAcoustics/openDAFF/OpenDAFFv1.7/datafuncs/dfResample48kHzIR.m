function [ data, samplerate, metadata ] = dfResample48kHzIR( alpha, beta, h )
    [ record_index, out_of_bounds ] = DAFFv17( 'getNearestNeighbourIndex', h, 'data', alpha, beta );
    
    metadata = [];
    assert( not ( out_of_bounds == 1 ) );
    data_in = DAFFv17( 'getRecordByIndex', h, record_index );
    props = DAFFv17( 'getProperties', h );
    
    ir = itaAudio();
    ir.samplingRate = props.samplerate;
    ir.timeData = data_in';
    
    new_samplerate = 48000;
    ir_r = ita_resample( ir, new_samplerate );
    ir_c = ita_time_crop( ir_r, [ 1 256 ], 'samples' );
    
    data = ir_c.timeData';
    samplerate = new_samplerate;
end
