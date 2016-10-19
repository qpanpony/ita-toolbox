function [ freqs, mags, metadata ] = dfConvertFromSH( alpha, beta, h )

    freqs = h.radiation.bands.center_frequencies;
    
    direction = itaCoordinates( 1 );
    direction.r = 1.0;
    direction.phi_deg = alpha;
    direction.theta_deg = 180 - beta;
    
    h.sampling.cart = direction.cart;
    h.sampling.nmax = h.radiation.N; % Updates SH base function
    
    %reference_value = abs( max( max( h.radiation.pnm( :, : ) ) ) );
    
    numfreqs = length( freqs );
    mags = zeros( 1, numfreqs );
    for f = 1:numfreqs
        mags( f ) = abs( h.sampling.Y * h.radiation.pnm( :, f ) ); %/ reference_value;
    end
    
    metadata = [];
    
end
