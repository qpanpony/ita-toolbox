function [ freqs, mags, metadata ] = dfFigureOfEightMS( alpha, beta, ~ )

    channels = 1;
    
    % Third-octave resolution
    freqs = [20 25 31.5 40 50 63 80 100 125 160 ...
             200 250 315 400 500 630 800 1000 1250 1600 ...
             2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
    
    metadata = [];
    
    mags = zeros( channels, size( freqs, 1 ) );
    for c=1:size(mags, 1)
        for f=1:size(freqs, 1)
            mags( c, f ) = abs( cos( alpha * pi / 180.0 ) * sin( beta * pi / 180.0 ) ); % set first value only
        end
    end
end
