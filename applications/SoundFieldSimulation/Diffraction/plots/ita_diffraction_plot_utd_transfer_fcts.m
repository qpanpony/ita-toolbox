%% Simple example
n1 = [ 1 0 1 ] ./ sqrt( 2 );
n2 = [ -1 0 1 ] ./ sqrt( 2 );
loc = [ 0 0 0 ]; % edge along Y axis
src = [ -1 0 -0.5 ]; % meter
rcv = [ 1 0 -0.75 ]; % meter
w = itaInfiniteWedge( n1, n2, loc ); % wedge object
freq = linspace( 20, 20000, 1000); % Hz
c = 343; % m/s
[ d_tf, D, A ] = ita_diffraction_utd( w, src, rcv, freq, c );

figure
semilogx( freq, 10*log10( abs( d_tf ) ) )
hold on
semilogx( freq, 10*log10( abs( D ) ) )
semilogx( freq, 10*log10( abs( A ) ) )
legend( 'transmission', 'diffraction coefficient', 'amplitude coefficient' )
title( 'UTD diffraction transfer function (simple example scene)' )
xlabel( 'Frequency / Hz' )
ylabel( 'Amplitude / dB' )


%% Distance dependency
far_distance_scaling = 10;
[ d_tf_far, D_far, A_far ] = ita_diffraction_utd( w, far_distance_scaling * src, far_distance_scaling * rcv, freq, c );

figure
semilogx( freq, [ 20*log10( abs( d_tf ) ); 20*log10( abs( d_tf_far ) ) ] )
hold on
semilogx( freq, [ 20*log10( abs( D ) ); 20*log10( abs( D_far ) ) ], 'lineWidth', 2 )
A_vec = zeros( size(freq) ); A_vec(:) = A;
A_far_vec = zeros( size(freq) ); A_far_vec(:) = A_far;
semilogx( freq, [ 20*log10( abs( A_vec ) ); 20*log10( abs( A_far_vec ) ) ] )
legend( 'transmission (near)', 'transmission (far)', ...
    'diffraction coefficient (near)', 'diffraction coefficient (far)', ...
    'amplitude coefficient (near)', 'amplitude coefficient (far)' )
title( 'UTD diffraction transfer function (distance dependency)' )
xlabel( 'Frequency / Hz' )
ylabel( 'Amplitude / dB' )
