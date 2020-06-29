%% Input data
if ~exist( 'genelec8020', 'var' )
    genelec8020 = DAFF( 'Genelec8020_2016_1x1.v17.ir.daff' );
    md = genelec8020.metadata;
    %delay_seconds_daff = md( 3 ).value / genelec8020.properties.samplerate; % 232.8, different value :/
end

if ~exist( 'gpsim', 'var' )
    gpsim = itaGeoPropagation();
    directivity_id = gpsim.load_directivity( 'Genelec8020_2016_1x1.v17.ir.daff', 'Genelec8020' );
end

genelec_front = itaAudio();
genelec_front.freqData = zeros( gpsim.num_bins, 1);
genelec_front.timeData( 1:genelec8020.properties.filterLength ) = genelec8020.nearest_neighbour_record( 0, 0 )';
genelec_front.channelNames = { 'DAFF front @~1m' };
p_eff_genelec = rms( fft( genelec8020.nearest_neighbour_record( 0, 0 ) ) );
p_eff = rms( genelec_front.freqData ); % Pa
fprintf( 'Genelect LS pressure measured @ approx 1m: %.1f dB re 20uPa\n', mag2db( p_eff / 20e-6 ) );

[ ~, delay_samples ] = max( abs( genelec_front.timeData ) );
delay_seconds = delay_samples / genelec8020.properties.samplerate;
fprintf( 'Measurement delay: %.1fms\n', delay_seconds  * 1e3 ) 

genelec_back = itaAudio();
genelec_back.freqData = zeros( gpsim.num_bins, 1);
genelec_back.timeData = genelec8020.nearest_neighbour_record( 180, 0 )';
genelec_back.channelNames = { 'DAFF back' };

genelec_top_right = itaAudio();
genelec_top_right.freqData = zeros( gpsim.num_bins, 1);
genelec_top_right.timeData = genelec8020.nearest_neighbour_record( -45, 35.26 )';
genelec_top_right.channelNames = { 'DAFF top-right' };


%% Simulation

% Prepare paths

gpsim.load_paths( 'Genelec8020_2m.json' );

gpsim.pps( 1 ).propagation_anchors{ 1 }.interaction_point = [ 0 0 0 ]; % LS at coord center
%p_eff = 1; % 1 Pa reference @ 1m spherical spreading
r = 1;
A = ( 4 * pi * r^2 );
rho_0 = 1.292; % Density of air
Z_0 = ( rho_0 * gpsim.c );
I = p_eff_genelec^2 / Z_0;
P = I * A; % Power for 1 Pa at 1m distance spherical wave in air
gpsim.pps( 1 ).propagation_anchors{ 1 }.sound_power = P;

gpsim.pps( 1 ).propagation_anchors{ 2 }.interaction_point = 2 * [ 1.0129 0 0 ]; % source in front

fprintf( 'Simulation wave front propagation time: %.1fms\n', ita_propagation_path_length( gpsim.pps ) / gpsim.c * 1e3 ) 

%view = [ 1 1 1 ];
%q = quaternion.rotateutov( [ 1 0 0 ], view / norm( view ) ); % azi -45 ele 35.26
q = quaternion.eye;
gpsim.pps( 1 ).propagation_anchors{ 1 }.orientation = q.double';


% Run simulations with different directivity eq settings

gpsim_front = itaAudio();
gpsim.set_directivity_eq( directivity_id, 'none' );
gpsim_front.freqData = gpsim.run();
gpsim_front.channelNames = { 'Simulation (not calibrated, LS power + directivity apmlification)' };
p_eff = rms( gpsim_front.freqData ); % Pa
fprintf( 'Genelect LS pressure (uncalibrated) simulated @ approx 2m: %.1f dB re 20uPa\n', mag2db( p_eff / 20e-6 ) );

gpsim_front_n = itaAudio();
gpsim.set_directivity_eq( directivity_id, 'front' );
gpsim_front_n.freqData = gpsim.run();
gpsim_front_n.channelNames = { 'Simulation (normalized front)' };
p_eff = rms( gpsim_front_n.freqData ); % Pa
fprintf( 'Genelect LS pressure (front normalized) simulated @ approx 2m: %.1f dB re 20uPa\n', mag2db( p_eff / 20e-6 ) );

gpsim_front_g = itaAudio();
gpsim.set_directivity_eq( directivity_id, 'gain', 1 ./ p_eff_genelec );
gpsim_front_g.freqData = gpsim.run();
gpsim_front_g.channelNames = { 'Simulation (gain: directivity rms equalized)' };
p_eff = rms( gpsim_front_g.freqData ); % Pa
fprintf( 'Genelect LS pressure (dir gain equalized) simulated @ 2m: %.1f dB re 20uPa\n', mag2db( p_eff / 20e-6 ) );

gpsim_front_d = itaAudio();
gpsim.set_directivity_eq( directivity_id, 'delay', delay_seconds );
gpsim_front_d.freqData = gpsim.run();
gpsim_front_d.channelNames = { 'Simulation (delay compensated)' };
p_eff = rms( gpsim_front_d.freqData ); % Pa
fprintf( 'Genelect LS pressure (delay comp) simulated @ 2m: %.1f dB re 20uPa\n', mag2db( p_eff / 20e-6 ) );

gpsim_front_c = itaAudio();
phase_by_delay = [ 0; exp( -1i .* 2 * pi * gpsim.freq_vec( 2:end ) * delay_seconds ) ]; % Note: DC value set to ZERO
gpsim.set_directivity_eq( directivity_id, 'custom', conj( phase_by_delay ) ./ p_eff_genelec );
gpsim_front_c.freqData = gpsim.run();
gpsim_front_c.channelNames = { 'Simulation (custom: amplitude and group delay compensated)' };
p_eff = rms( gpsim_front_c.freqData ); % Pa
fprintf( 'Genelect LS pressure (delay and rms comp) simulated @ 2m: %.1f dB re 20uPa\n', mag2db( p_eff / 20e-6 ) );


%% Eval

a_comp = ita_merge( genelec_front, gpsim_front_c, gpsim_front, gpsim_front_n, gpsim_front_g, gpsim_front_d );
%a_comp = ita_normalize_spk( a_comp, 'allchannels' );
a_comp.pf
