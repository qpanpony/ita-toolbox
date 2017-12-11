%% itaVA simple example code

% Create itaVA
va = itaVA;

% Connect to VA application (start the application first)
va.connect( 'localhost' )

% Reset VA to clear the scene
va.reset()

% Control output gain
va.set_output_gain( .25 )

% Add the current absolute folder path to VA application
va.add_search_path( pwd );

% Create a signal source and start playback
X = va.create_signal_source_buffer_from_file( '$(DemoSound)' );
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );

% Create a virtual sound source and set a position
S = va.create_sound_source( 'itaVA_Source' );
va.set_sound_source_position( S, [ 2 1.7 2 ] )

% Create a listener with a HRTF and position him
L = va.create_sound_receiver( 'itaVA_Listener' );
va.set_sound_receiver_position( L, [ 0 1.7 0 ] )

H = va.create_directivity( '$(DefaultHRIR)' );
va.set_sound_receiver_directivity( L, H );

% Connect the signal source to the virtual sound source
va.set_sound_source_signal_source( S, X )

% More information
disp( 'Type ''doc itaVA'' for more information.' )
