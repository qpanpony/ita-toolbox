%% itaVA tracked listener example code
% This assumes you already have set up a virtual scene without listener

% Create itaVA and connect
va = itaVA( 'localhost' )

% Create a listener
L = va.createListener( 'itaVA_Tracked_Listener' );

% OptiTrack tracker conneection and listener updates
va.setTrackedListener( L )
va.connectTracker

% apply pivot point offset to a rigid body
% Hint: the method .calibrate of itaOptirack() calculates the individual
% offset between a head-mounted rigid body and the center of the interaural
% axis of a listener
va.setRigidBodyIndex( 1 )                % set index of rigid body that should be manipulated (cf. Motive)
va.setRigidBodyTranslation( [0 -0.08 0] ) % translation in local coordinate system of rigid body [m]
                                         % move rigid body by 8 cm in
                                         % negative y direction
                                         
pause( 12 ) % Observe how you can move the virtual listener in VAGUI
va.disconnectTracker

% Remove listener again
va.deleteListener( L )

% Now close connection
va.disconnect()
