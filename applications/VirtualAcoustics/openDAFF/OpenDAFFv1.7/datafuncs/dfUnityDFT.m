function [ data, samplerate, is_symetric, metadata ] = dfUnityDFT( ~, ~, unity_dft_config )
% Omnidirectional discrete Fourier transform
    
    if ~isempty( fieldnames( unity_dft_config ) )
        channels = unity_dft_config.channels;
        bins = unity_dft_config.length;
        is_symetric = unity_dft_config.is_symmetric;
        samplerate = unity_dft_config.samplerate;
        complex_value = unity_dft_config.complex_value;
    else
        channels = 1;
        bins = 128;
        is_symetric = false;
        samplerate = 44100;
        complex_value = 1 + 1i * 0;
    end
    
    metadata = [];
    data = zeros( channels, bins );
    for c = 1:channels
        for n = 1:bins
            data( c, n ) = complex_value;
        end
    end   
end
