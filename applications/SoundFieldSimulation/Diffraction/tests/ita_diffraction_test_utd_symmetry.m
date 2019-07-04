%% Test symmetry of UTD diffraction

n1 = [ 1, 0, 1 ];
n2 = [ -1, 0, 1 ];
loc = [ 0 0 0 ];
w = itaInfiniteWedge( n1 / norm( n1 ), n2 / norm( n2 ), loc );

s = [  3.1 0 0 ];
r = [ -3.1 0 -0.1 ];

assert( w.point_outside_wedge( s ) )
assert( w.point_outside_wedge( r ) )
%assert( ita_diffraction_shadow_zone( w, s, r ) )

utd_tf = itaAudio( 1 );
utd_tf.fftDegree = 11;

f = utd_tf.freqVector( 2:end );
c = 341;

[ H1, D1, A1 ] = ita_diffraction_utd( w, s, r, f, c );
utd_tf.freqData( :, 1 ) = [ 0 H1 ];
utd_tf.freqData( :, 3 ) = [ 0 D1 ];
[ H2, D2, A2 ] = ita_diffraction_utd( w, r, s, f, c );
utd_tf.freqData( :, 2) = [ 0 H2 ];
utd_tf.freqData( :, 4 ) = [ 0 D2 ];

utd_tf.channelNames = { 'H1', 'H2', 'D1', 'D2' };

assert( sum( A1 - A2 ) < eps )

utd_tf.pf
