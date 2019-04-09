%% itaVA tracked head-above-torso listener example code

% Create itaVA and connect
va = VA( 'localhost' );
va.reset()
va.set_output_gain( .25 )

% Create a signal source and start playback
X = va.create_signal_source_buffer_from_file( '$(DemoSound)' );
va.set_signal_source_buffer_playback_action( X, 'play' );
va.set_signal_source_buffer_looping( X, true );

% Create a virtual sound source and set a position
S = va.create_sound_source( 'itaVA_Source' );
va.set_sound_source_position( S, [ 0 1.7 -6 ] );
va.set_sound_source_signal_source( S, X );

% Create a sound receiver with HATO (actually OTAH) HRTF
L = va.create_sound_receiver( 'itaVA_Tracked_HATO_Listener' );
H = va.create_directivity_from_file( 'FABIAN_OTAH_5x5x5_256_44100Hz.v17.ir.daff' );
va.set_sound_receiver_directivity( L, H );


% OptiTrack tracker connection and sound receiver updates

% ... for rendering modules
va.set_tracked_sound_receiver( L );
va.set_tracked_sound_receiver_head_rigid_body_index( 1 );
va.set_tracked_sound_receiver_torso_rigid_body_index( 2 );

% ... for reproduction modules
va.set_tracked_real_world_sound_receiver( L );
va.set_tracked_real_world_sound_receiver_head_rigid_body_index( 1 );
va.set_tracked_real_world_sound_receiver_torso_rigid_body_index( 2 );

va.get_tracker_info

% Start!
va.connect_tracker( '137.226.61.85', '137.226.61.107' )


% pause( 12 )
% va.disconnect_tracker
