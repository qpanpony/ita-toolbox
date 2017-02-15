itaVAq;
va.reset;
va.setOutputGain( .25 );
va.addSearchPath( pwd );
ita_write_wav( ita_demosound, 'ita_demosound.wav', 'overwrite' );
X = va.createAudiofileSignalSource( 'ita_demosound.wav' );
va.setAudiofileSignalSourcePlaybackAction( X, 'play' )
va.setAudiofileSignalSourceIsLooping( X, true );
S = va.createSoundSource( 'itaVA_Source' );
va.setSoundSourcePosition( S, [ 0 1.7 -2 ] );
va.setSoundSourceSignalSource( S, X );
H = va.loadHRIRDataset( '$(DefaultHRIR)' );
L = va.createListener( 'itaVA_Listener', 'default', H );
va.setListenerPosition( L, [ 0 1.7 0 ] );
va.setActiveListener( L );