h = DAFF( 'FABIAN_HATO_5x5x5_256_44100Hz.v17.ir.daff' );
sound_sample = ita_read('Bongos.wav');
[ hrir_front_raw, ~ ] = h.get_nearest_neighbour_record( 0, 0 );

% for i = 1:17
%     a = 2*i - 1;
%     b = 2*i;
%     hrir_left_hato_0 = itaAudio;
%     hrir_left_hato_0.timeData = hrir_front_raw( a:b, : )';
% 
%     binaural_demosound = ita_convolve( sound_sample, hrir_left_hato_0 );
%     binaural_demosound.play
% end


hrir_left_hato_0 = itaAudio;
hrir_left_hato_0.timeData = hrir_front_raw( 1:2, : )';

binaural_demosound_hato_0 = ita_convolve( sound_sample, hrir_left_hato_0 );
binaural_demosound_hato_0.play


hrir_left_hato_320 = itaAudio;
hrir_left_hato_320.timeData = hrir_front_raw( 3:4, : )';

binaural_demosound_hato_320 = ita_convolve( sound_sample, hrir_left_hato_320 );
binaural_demosound_hato_320.play


hrir_left_hato_40 = itaAudio;
hrir_left_hato_40.timeData = hrir_front_raw( 33:34, : )';

binaural_demosound_hato_40 = ita_convolve( sound_sample, hrir_left_hato_40 );
binaural_demosound_hato_40.play



% [ hrir_front_raw, ~ ] = DAFFv17( 'getNearestNeighbourRecord', h , 'object', 90, -40 );
% 
% hrir_left_hato_0 = itaAudio;
% hrir_left_hato_0.timeData = Shrir_front_raw( 1:2, : )';
% 
% binaural_demosound = ita_convolve( sound_sample, hrir_left_hato_0 );
% binaural_demosound.play
% 
% 
% [ hrir_front_raw, ~ ] = DAFFv17( 'getNearestNeighbourRecord', h , 'object', 90, 40 );
% 
% hrir_left_hato_0 = itaAudio;
% hrir_left_hato_0.timeData = hrir_front_raw( 1:2, : )';
% 
% binaural_demosound = ita_convolve( sound_sample, hrir_left_hato_0 );
% binaural_demosound.play


% for i = 1:4
%     [ hrir_front_raw, ~ ] = DAFFv17( 'getNearestNeighbourRecord', h , 'object', 90, (-50 + i*10) );
% 
%     hrir_left_hato_0 = itaAudio;
%     hrir_left_hato_0.timeData = hrir_front_raw( 1:2, : )';
% 
%     binaural_demosound = ita_convolve( sound_sample, hrir_left_hato_0 );
%     binaural_demosound.play
% end
% 
% for i = 1:4
%     [ hrir_front_raw, ~ ] = DAFFv17( 'getNearestNeighbourRecord', h , 'object', 90, i*10 );
% 
%     hrir_left_hato_0 = itaAudio;
%     hrir_left_hato_0.timeData = hrir_front_raw( 1:2, : )';
% 
%     binaural_demosound = ita_convolve( sound_sample, hrir_left_hato_0 );
%     binaural_demosound.play
% end