%% itaVA tracked listener example code
% This assumes you already have set up a virtual scene without listener

% Create itaVA and connect
va = itaVA( 'localhost' )

% Create a listener
L = va.createListener( 'itaVA_Tracked_Listener' );

% OptiTrack tracker conneection and listener updates
va.setTrackedListener( L ) % For virtual scene / rendering
va.setTrackedRealWorldListener( L ) % For CTC reproductions
va.connectTracker
pause( 12 ) % Observe how you can move the virtual listener in VAGUI
va.disconnectTracker

% Remove listener again
va.deleteListener( L )

% Now close connection
va.disconnect()
