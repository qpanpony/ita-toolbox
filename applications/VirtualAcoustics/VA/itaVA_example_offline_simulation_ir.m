%% itaVA offline simulation/auralization example that uses impulse responses

% Requires VA to run with a virtual audio device that can be triggered by
% the user. Also the generic path prototype rendering module(s) has to record the output
% to hard drive.

buffer_size = 64;
sampling_rate = 44100;


%% Connect and set up simple scene
va = itaVA( 'localhost' );

L = va.create_sound_receiver( 'itaVA_Listener' );
va.set_sound_receiver_position( L, [ 0 1.7 0 ] )
H = va.create_directivity( '$(DefaultHRIR)' );
va.set_sound_receiver_directivity( L, H );

S = va.create_sound_source( 'itaVA_Source' );
X = va.create_signal_source_buffer_from_file( '$(DemoSound)' );
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );
va.set_sound_source_signal_source( S, X )


%% Example for a synchronized scene update & audio processing simulation/auralization

timestep = buffer_size / sampling_rate; % here: depends on block size and sample rate
manual_clock = 0;
va.set_core_clock( 0 );

spatialstep = 0.01;
disp( [ 'Resulting sound source speed: ' num2str( spatialstep / timestep ) ' m/s' ] )

numsteps = 3400;
disp( [ 'Simulation result duration: ' num2str( numsteps * timestep ) ' s' ] )

x = linspace( -1, 1, numsteps ) * 5; % motion from x = -5m to x = 5m

h = waitbar( 0, 'Hold on, running auralization' );
for n = 1:length( x )
    
    % Modify scene as you please (position has no real effect for prototype generic path renderer)
    pos = [ x( n ) 1.7 -1 ];
    distance = sum( abs( pos - [ 0 1.7 0 ] ) );
    va.set_sound_source_position( S, pos );    
    
    brir = itaAudio();
    brir.timeData = zeros( 1024, 2 );
    brir.timeData( 1, 1 ) = 1.0 / distance;
    brir.timeData( 1, 2 ) = 0.5 / distance; % just make inbalanced and distance dependent for fun
    
    path_update = struct();
    path_update.source = S;
    path_update.receiver = L;
    path_update.ch1 = brir.timeData( :, 1 );
    path_update.ch2 = brir.timeData( :, 2 );
    path_update.delay = distance / va.get_homogeneous_medium_sound_speed(); % will generate smooth Doppler even for fast motion
    va.set_rendering_module_parameters( 'MyGenericRenderer', path_update );
    
    % Increment core clock
    manual_clock = manual_clock + timestep;
    va.call_module( 'manualclock', struct( 'time', manual_clock ) );
    
    % Process audio chain by incrementing one block
    va.call_module( 'virtualaudiodevice', struct( 'trigger', true ) );
    
    waitbar( n / numsteps )
    
end
close( h )

va.disconnect

disp( 'Stop VA to export simulation results from rendering module(s)' )
