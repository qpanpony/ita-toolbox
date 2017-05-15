%% itaVA simple example code

% Create itaVA
va = itaVA;

% Connect to VA application (start the application first)
va.connect( 'localhost' )

% Reset VA to clear the scene
va.reset()

% Control output gain
va.setOutputGain( .25 )

% Add the current absolute folder path to VA application
va.addSearchPath( pwd ); 

% Create a signal source and start playback
ita_write_wav( ita_demosound, 'ita_demosound.wav', 'overwrite' );
X = va.createAudiofileSignalSource( 'ita_demosound.wav' );
va.setAudiofileSignalSourcePlaybackAction( X, 'play' )
va.setAudiofileSignalSourceIsLooping( X, true );

% Create a virtual sound source and set a position
S = va.createSoundSource( 'itaVA_Source' );
va.setSoundSourcePosition( S, [0 1.7 -2] )

% Connect the signal source to the virtual sound source
va.setSoundSourceSignalSource( S, X )

% Create a listener with a HRTF and position him
H = va.loadHRIRDataset( '$(DefaultHRIR)' );
L = va.createListener( 'itaVA_Listener', 'default', H );
va.setListenerPosition( L, [0 1.7 0] )
va.setListenerOrientationYPR( L, [0 0 0] ) % Default view is to -Z (OpenGL)

% Set the listener as the active one
va.setActiveListener( L )

% Now close connection
va.disconnect()

% VA virtual scene is still active now ...

% Explore itaVA class ...
doc itaVA
