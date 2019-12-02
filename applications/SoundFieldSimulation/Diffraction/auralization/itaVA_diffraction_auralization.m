%% Paths
addpath( genpath( 'win32-x64.vc12' ) ) % VA binaries etc.
addpath( '../matlab' ) % diffraction simulation scripts
% addpath( 'sciebo/Bachelor Arbeit' )


%% Diffraction simulation setup
r = 5;
w = itaFiniteWedge( [ 1 1 0 ] ./ sqrt( 2 ), [ -1 1 0 ] ./ sqrt( 2 ), [ 0 0 5 ], 10 );
source_pos = [ -r 0 0 ];
f = ita_ANSI_center_frequencies;
ir_length = 4096;
fs = 44100;
c = 344; % m/s


%% VA server start
vaserver_binaray_path = which( 'VAServer.exe' );
if( isempty( vaserver_binaray_path ) )
    warning( 'Could not find VAServer executable, please add VA bin folder to Matlab path' )
    itaVA_setup
    vaserver_binaray_path = which( 'VAServer.exe' );
    assert( ~isempty( vaserver_binaray_path ) )
end

ini_file_name = 'VACore.diffraction_auralization.ini';
vaserver_call = [ '"' fullfile( vaserver_binaray_path ) '" localhost:12340 "' fullfile( pwd, ini_file_name ) '" &' ];
system( vaserver_call );


%% VA connection
va = itaVA;
while( true )
    try
        va.connect
        va.add_search_path( pwd )
    catch
        if ~va.get_connected
            disp( 'Waiting for server to come up' )
            pause( 0.2 )
            disp( 'Retrying' )
        else
            break
        end
    end
end

params = struct();
params.RecordOutputBaseFolder = fullfile( pwd, 'recording', datestr( now, 'yyyy-mm-dd_HH-MM-SS' ) );

renderer_id = 'GenericMaekawa';
params.RecordOutputFileName = [ renderer_id '.wav' ];
va.set_rendering_module_parameters( renderer_id, params );

renderer_id = 'GenericMaekawaApprox';
params.RecordOutputFileName = [ renderer_id '.wav' ];
va.set_rendering_module_parameters( renderer_id, params );

renderer_id = 'GenericUTD';
params.RecordOutputFileName = [ renderer_id '.wav' ];
va.set_rendering_module_parameters( renderer_id, params );

renderer_id = 'GenericUTDApprox';
params.RecordOutputFileName = [ renderer_id '.wav' ];
va.set_rendering_module_parameters( renderer_id, params );

renderer_id = 'GenericBTMSApprox';
params.RecordOutputFileName = [ renderer_id '.wav' ];
%va.set_rendering_module_parameters( renderer_id, params );



%% --------------- Auralization -----------------

L = va.create_sound_receiver( 'itaVA_Receiver' );

S = va.create_sound_source( 'itaVA_Source' );
va.set_sound_receiver_position( L, source_pos );
X = va.create_signal_source_buffer_from_file( 'chirp.wav' );
%X = va.create_signal_source_buffer_from_file( 'chirp.wav' );
%X = va.create_signal_source_buffer_from_file( 'gershwin-mono.wav' );
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );
va.set_sound_source_signal_source( S, X )

timestep = 128 / 44100; % here: depends on block size and sample rate
manual_clock = 0;
va.set_core_clock( 0 );

N = 3400;
disp( [ 'Auralization result length: ' num2str( N * timestep ) ' s' ] )

alpha_d_rad = linspace( pi, 3 * pi / 2, N );
receiver_pos = zeros( N, 3 );
receiver_pos( :, 1 ) = r * sin( alpha_d_rad - 3 * pi / 4 ); % x absolute position
receiver_pos( :, 2 ) = r * cos( alpha_d_rad - 3 * pi / 4 ); % y absolute position

h = waitbar( 0, 'Hold on, running auralization' );
for n = 1:N
    
    r_pos = receiver_pos( n, : );
    va.set_sound_source_position( S, r_pos );
    
    
    %% Detour
    
    in_shadow_zone = ita_diffraction_shadow_zone( w, source_pos, r_pos );
    if in_shadow_zone
        % Detour over aperture point
        apex = w.approx_aperture_point( source_pos, r_pos );
        distance =  norm( source_pos - apex ) + ...
                    norm( r_pos - apex );
    else
        % Direct line-of-sight
        distance = norm( source_pos - r_pos );
    end
    
    
    %% Direct sound
    ir_direct_sound = itaAudio( 1 );
    ir_direct_sound.samplingRate = fs;
    ir_direct_sound.timeData = zeros( ir_length, 1 );
    if ~in_shadow_zone
        k = 2 * pi * f' ./ c;
        tf_direct_sound = exp( -1i * k * distance ) ./ distance;
        k = 2 * pi * ir_direct_sound.freqVector ./ c;
        ir_direct_sound.freqData = exp( -1i * k * distance ) ./ distance;
    else
        tf_direct_sound = zeros( numel( f ), 1 );
    end
    
    
    %% Maekawa
    
    % Get Maekawa diffraction simulation TF
    tf_maekawa = ita_diffraction_maekawa( w, source_pos, r_pos, f, c );
        
    ir_maekawa = itaAudio( 1 );
    ir_maekawa.samplingRate = fs;
    ir_maekawa.timeData = itaVA_convert_thirds( tf_maekawa + tf_direct_sound, ir_length + 2, fs, f );

    path_update = struct();
    path_update.source = S;
    path_update.receiver = L;
    path_update.ch1 = ir_maekawa.timeData( :, 1 );
    path_update.ch2 = ir_maekawa.timeData( :, 1 );
    path_update.delay = distance / va.get_homogeneous_medium_sound_speed();
    va.set_rendering_module_parameters( 'GenericMaekawa', path_update );
    
    
    %% Maekawa shadow zone approximation
    
    % Get Maekawa diffraction simulation TF
    tf_maekawa_a = ita_diffraction_maekawa_approx( w, source_pos, r_pos, f, c );
        
    ir_maekawa_a = itaAudio( 1 );
    ir_maekawa_a.samplingRate = fs;
    ir_maekawa_a.timeData = itaVA_convert_thirds( tf_maekawa_a + tf_direct_sound, ir_length + 2, fs, f );

    path_update = struct();
    path_update.source = S;
    path_update.receiver = L;
    path_update.ch1 = ir_maekawa_a.timeData( :, 1 );
    path_update.ch2 = ir_maekawa_a.timeData( :, 1 );
    path_update.delay = distance / va.get_homogeneous_medium_sound_speed();
    va.set_rendering_module_parameters( 'GenericMaekawaApprox', path_update );
    
    
    %% UTD
        
    % Get UTD diffraction simulation TF
    tf_utd = ita_diffraction_utd( w, source_pos, r_pos, f, c );
        
    ir_utd = itaAudio( 1 );
    ir_utd.samplingRate = fs;
    ir_utd.timeData = itaVA_convert_thirds( tf_utd + tf_direct_sound, ir_length + 2, fs, f );

    path_update = struct();
    path_update.source = S;
    path_update.receiver = L;
    path_update.ch1 = ir_utd.timeData( :, 1 );
    path_update.ch2 = ir_utd.timeData( :, 1 );
    path_update.delay = distance / va.get_homogeneous_medium_sound_speed();
    va.set_rendering_module_parameters( 'GenericUTD', path_update );
    
    
    %% UTD shadow zone approximation
        
    % Get UTD approximation diffraction simulation TF
    tf_utd_a = ita_diffraction_utd_approximated( w, source_pos, r_pos, f, c );
        
    ir_utd_a = itaAudio( 1 );
    ir_utd_a.samplingRate = fs;
    ir_utd_a.timeData = itaVA_convert_thirds( tf_utd_a + tf_direct_sound, ir_length + 2, fs, f );

    path_update = struct();
    path_update.source = S;
    path_update.receiver = L;
    path_update.ch1 = ir_utd_a.timeData( :, 1 );
    path_update.ch2 = ir_utd_a.timeData( :, 1 );
    path_update.delay = distance / va.get_homogeneous_medium_sound_speed();
    va.set_rendering_module_parameters( 'GenericUTDApprox', path_update );
    
    
    %% BTM(S)?
    % @todo
    
    
    %% Continue auralization processing
    
    % Increment core clock
    manual_clock = manual_clock + timestep;
    va.call_module( 'manualclock', struct( 'time', manual_clock ) );
    
    % Process audio chain by incrementing one block
    va.call_module( 'virtualaudiodevice', struct( 'trigger', true ) );
    
    waitbar( n / N )
    
end
close( h )

va.disconnect

disp( 'Stop VA to export simulation results from rendering module(s)' )
