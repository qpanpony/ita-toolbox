%% VA offline simulation/auralization example

% Requires VA to run with a virtual audio device that can be triggered by
% the user. Also the rendering module(s) have to be set to record the output
% to hard drive.

buffer_size = 64;
sampling_rate = 44100;


%% Connect and set up simple scene
va = VA( 'localhost' );

L = va.create_sound_receiver( 'VA_Listener' );
va.set_sound_receiver_position( L, [ 0 1.7 0 ] )
H = va.create_directivity_from_file( '$(DefaultHRIR)' );
va.set_sound_receiver_directivity( L, H );

S = va.create_sound_source( 'VA_Source' );
X = va.create_signal_source_buffer_from_file( '$(DemoSound)' );
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );
va.set_sound_source_signal_source( S, X )


%% Example for a synchronized scene update & audio processing simulation/auralization

timestep = buffer_size / sampling_rate; % here: depends on block size and sample rate
manual_clock = 0;
va.set_core_clock( 0 );

spatialstep = 0.005;
disp( [ 'Resulting sound source speed: ' num2str( spatialstep / timestep ) ' m/s' ] )

numsteps = 6000;
disp( [ 'Simulation result duration: ' num2str( numsteps * timestep ) ' s' ] )

x = linspace( -1, 1, numsteps ) * 60; % motion from x = -100m to x = 100m

h = waitbar( 0, 'Hold on, running auralization' );
for n = 1:length( x )
    
    % Modify scene as you please
    va.set_sound_source_position( S, [ x( n ) 1.7 -3 ] );
    
    % Increment core clock
    manual_clock = manual_clock + timestep;
    va.call_module( 'manualclock', struct( 'time', manual_clock ) );
    
    % Process audio chain by incrementing one block
    va.call_module( 'virtualaudiodevice', struct( 'trigger', true ) );
    
    waitbar( n / numsteps )
    
end
close( h )

va.disconnect

disp( '!!! Please stop VA manually to export simulation results from rendering module(s) !!!' )
