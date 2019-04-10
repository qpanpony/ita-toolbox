function Y = ita_diffraction_kawai_approx_fresnel( X )
%ita_diffraction_kawai_approx_fresnel Evaluates the approximation of the Fresnel integral equation by Kawai et al.
%
% Example:
%
%   X = logspace( -3, 1 )
%   Y = ita_diffraction_kawai_approx_fresnel( X )
% 

if any( X < 0 )
    error( 'No negative values for Kawai approximation of Fresnel integral allowed' )
end

X_l_idx = X < 0.8;
X_l = X( X_l_idx );
X_geq_idx = ( X >= 0.8 );
X_geq = X( X_geq_idx );

Y( X_l_idx ) = sqrt( pi * X_l ) .* ( 1 - sqrt( X_l ) ./ ( 0.7 * sqrt( X_l ) + 1.2 ) ) .* exp( 1i * pi/4 * ( 1 - sqrt( X_l ./ ( X_l + 1.4 ) ) ) );
Y( X_geq_idx ) = ( 1 - 0.8 ./ ( X_geq + 1.25 ) .^ 2 ) .* exp( 1i * pi/4 * ( 1 - sqrt( X_geq ./ ( X_geq + 1.4 ) ) ) );

end
