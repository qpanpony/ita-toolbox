function [ data, samplerate, metadata ] = dfDiracIR( ~, ~, dirac_ir_config )

    if ~isempty( dirac_ir_config )
        channels = dirac_ir_config.channels;
        filter_length = dirac_ir_config.numsamples;
        samplerate = dirac_ir_config.samplerate;
    else
        % use default values
        channels = 1;
        filter_length = 128;
        samplerate = 44100;
    end
    
    metadata = [];
    
    data = zeros( channels, filter_length );
    for c=1:size(data, 1)
        data( c, 1 ) = 1.0; % set first value to 1
    end
end
