function [ data, samplerate, metadata ] = dfFigureOfEightIR( alpha, beta, ~ )

    channels = 1;
    filter_length = 4;
    samplerate = 48000.0;
    
    metadata = [];
    
    data = zeros( channels, filter_length );
    for c=1:size(data, 1)
        data( c, 1 ) = cos( alpha * pi / 180.0 ) * sin( beta * pi / 180.0 ); % set first value only
    end
end
