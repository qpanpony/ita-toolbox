%% itaVA tracked listener example code
% This assumes you already have set up a virtual scene without listener

% Create itaVA and connect
va = itaVA( 'localhost' );

% Create a sound receiver
L = va.create_sound_receiver( 'itaVA_Tracked_Listener' );

% OptiTrack tracker conneection and sound receiver updates
va.set_tracked_sound_receiver( L ) % For virtual scene / rendering
va.set_tracked_real_world_sound_receiver( L ) % For CTC reproductions
va.connect_tracker
pause( 12 ) % Observe how you can move the virtual sound receiver
va.disconnect_tracker

% Remove listener again
va.delete_sound_receiver( L )
