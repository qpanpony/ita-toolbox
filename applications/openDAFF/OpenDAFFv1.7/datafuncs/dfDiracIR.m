function [ data, samplerate, metadata ] = dfDiracIR( ~, ~, ~ )

    channels = 1;
    filter_length = 4;
    samplerate = 48000.0;
    
    metadata = [];
    
    data = zeros( channels, filter_length );
    for c=1:size(data, 1)
        data( c, 1 ) = 1.0; % set first value to 1
    end
end
