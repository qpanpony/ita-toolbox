%% Test transition at shadown zone of UTD diffraction

w = itaInfiniteWedge( [ 1 0 0 ], [ 0 0 -1 ], [ 0 0 0 ] ); % OpenGL coordinates

delta = 0.001;
s_shadow = [ ( -3 - delta ) 0 -3 ];
s_illuminated = [ ( -3 + delta ) 0 -3 ];
r = [ 3 0 3 ];

assert( ita_diffraction_shadow_zone( w, s_shadow, r ) )
assert( ~ita_diffraction_shadow_zone( w, s_illuminated, r ) )

utd_tf = itaAudio( 1 );
utd_tf.fftDegree = 11;

f = utd_tf.freqVector( 2:end );
c = 341;

[ H1, D1, A1 ] = ita_diffraction_utd( w, s_shadow, r, f, c );
utd_tf.freqData( :, 1 ) = [ 0 H1 ];

[ H2, D2, A2 ] = ita_diffraction_utd( w, s_illuminated, r, f, c );
utd_tf.freqData( :, 2 ) = [ 0 H2 ];

d = norm( r - s_illuminated );
c = 343;
k = 2 * pi * f / c;
H_direct = 1 ./ d .* exp( -1i .* k .* d );

utd_tf.freqData( :, 3 ) = [ 0 H1 ./ H_direct ];
utd_tf.freqData( :, 4 ) = [ 0 ( H2 + H_direct ) ./ H_direct ];

utd_tf.channelNames = { 'Diffracted field (shadow)', 'Diffracted field (illuminated)', 'Insertion loss (shadowed)', 'Insertion loss (illuminated)' };

utd_tf.pf
