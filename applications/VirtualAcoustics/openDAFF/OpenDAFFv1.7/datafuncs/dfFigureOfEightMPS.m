function [ freqs, data_complex, metadata ] = dfFigureOfEightMPS( alpha, beta, ~ )

    channelnum = 1;
    
    % Third-octave resolution
    freqs = [20 25 31.5 40 50 63 80 100 125 160 ...
             200 250 315 400 500 630 800 1000 1250 1600 ...
             2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
    
    metadata = [];
    
    data_complex = zeros( channelnum, numel( freqs ) );
    for c = 1:channelnum
        for f = 1:numel( freqs )
            magnitude = cos( deg2rad( alpha ) ) * sin( deg2rad( beta ) );
            phase = 2 * pi * magnitude;
            data_complex( c, f ) = abs( magnitude ) * exp( 1i * phase );
        end
    end
end
