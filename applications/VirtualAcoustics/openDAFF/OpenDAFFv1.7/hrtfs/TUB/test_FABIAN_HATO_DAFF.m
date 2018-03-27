h = DAFFv17( 'open', 'FABIAN_HATO_5x5x5_256_44100Hz.v17.ir.daff' );

[ hrir_left_raw, ~ ] = DAFFv17( h, 'getNearestNeighbourRecord', 'object', 90, 0 );

hrir_left_hato_0 = itaAudio;
hrir_left_hato_0.timeData = hrir_left_raw( 1:2, : )';

binaural_demosound = ita_convolve( ita_demosound, hrir_left_hato_0 );
binaural_demosound.play
