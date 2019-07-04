%% Plot the Kawai approximation of Fresnel integral in range 0.001 to 10.0

% Evaluation
X = logspace( -3, 1 );
Y = ita_diffraction_kawai_approx_fresnel( X );

% Plot
figure(); clf;
title( 'Kawai approximation of Fresnel integral' )
yyaxis left
semilogx( X, abs( Y ) )
xlabel( 'X' );
ylabel( 'magnitude' )
yyaxis right
semilogx( X, rad2deg( angle( Y ) ) )
ylabel( 'phase in degree' );
ylim( [0, 50] );
legend( 'magnitude', 'phase', 'location', 'north' )
