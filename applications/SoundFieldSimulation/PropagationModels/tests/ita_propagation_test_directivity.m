if ~exist( 'gpsim', 'var' )
    gpsim = itaGeoPropagation();
    gpsim.load_directivity( 'Genelec8020_2016_1x1.v17.ir.daff', 'Genelec8020', 1.0129 / gpsim.c * gpsim.fs );
end

gpsim.load_paths( 'Genelec8020_2m.json' );

gpsim.pps( 1 ).propagation_anchors{ 1 }.interaction_point = [ 0 0 0 ]; % LS at coord center
gpsim.pps( 1 ).propagation_anchors{ 2 }.interaction_point = 2 * [ 1.0129 0 0 ]; % source in front

%view = [ 1 1 1 ];
%q = quaternion.rotateutov( [ 1 0 0 ], view / norm( view ) ); % azi -45 ele 35.26
q = quaternion.eye;
gpsim.pps( 1 ).propagation_anchors{ 1 }.orientation = q.double';

gpsim_front = itaAudio(); % -6 dB?
gpsim_front.freqData = gpsim.run();
gpsim_front.channelNames = { 'Simulation' };

if ~exist( 'genelec8020', 'var' )
    genelec8020 = DAFF( 'Genelec8020_2016_1x1.v17.ir.daff' );
end

genelec_front = itaAudio();
genelec_front.timeData = genelec8020.nearest_neighbour_record( 0, 0 )';
genelec_front.channelNames = { 'DAFF front' };
genelec_back = itaAudio();
genelec_back.timeData = genelec8020.nearest_neighbour_record( 180, 0 )';
genelec_back.channelNames = { 'DAFF back' };
genelec_top_right = itaAudio();
genelec_top_right.timeData = genelec8020.nearest_neighbour_record( -45, 35.26 )';
genelec_top_right.channelNames = { 'DAFF top-right' };

a_comp = ita_merge( gpsim_front, genelec_front );
a_comp = ita_normalize_spk( a_comp, 'allchannels' );
a_comp.pf
