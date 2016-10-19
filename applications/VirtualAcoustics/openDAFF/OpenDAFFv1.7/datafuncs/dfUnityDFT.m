function [ data, sampleRate, isSymetric, metadata ] = dfUnityDFT( ~, ~, ~ )
% Omnidirectional discrete Fourier transform
    
    channels = 1;
    bins = 128;
    
    data = zeros( channels, bins );
    metadata = [];
    isSymetric = false;
    sampleRate = 44100;
    
    for c = 1:channels
        for n = 1:bins
            data( c, n ) = 1.0 + 1i*0.0;
        end
    end   
end
