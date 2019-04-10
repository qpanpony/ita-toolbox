%% itaVA simple example code for a text-to-speech sound source

% @todo apply new VA method naming conventions (all small caps with
% underscores between words)

% Quick setup
itaVAq
va.reset();
va.setOutputGain( .25 );

% Create a text-to-speech audio signal source
X = va.createTextToSpeechSignalSource( 'tts_demo' );

% Create a virtual sound source and set a position
S = va.createSoundSource( 'itaVA_Source' );
va.setSoundSourcePosition( S, [ -2 1.7 -1 ] )

% Connect the signal source to the virtual sound source
va.setSoundSourceSignalSource( S, X )

% Create a listener with an HRTF and position him
H = va.loadHRIRDataset( '$(DefaultHRIR)' );
L = va.createListener( 'itaVA_Listener', 'default', H );
va.setListenerPosition( L, [ 0 1.7 0 ] )

% Set the listener as the active one
va.setActiveListener( L )

%% Control TTS
tts_in = struct();
tts_in.list_voices = true;
tts_out = va.getSignalSourceParameters( X, tts_in )
assert( tts_out.number > 0 )

tts_in = struct();
tts_in.voice = 'Heather';
tts_in.id = 'id_vr';
tts_in.prepare_text = 'virtual acoustics is a real-time auralization framework for scientific research in Virtual Reality created by the institute of technical acoustics, RWTH aachen university';
tts_in.direct_playback = true;
va.setSignalSourceParameters( X, tts_in )
pause( 5 )

tts_in = struct();
tts_in.id = 'id_ok';
tts_in.prepare_text = 'OK';
va.setSignalSourceParameters( X, tts_in )

tts_in = struct();
tts_in.id = 'id_alright';
tts_in.prepare_text = 'Alright';
va.setSignalSourceParameters( X, tts_in )

tts_in_ok.play_speech = 'id_ok';
tts_in_alright.play_speech = 'id_alright';

va.setSignalSourceParameters( X, tts_in_alright )
pause( 1 )
va.setSignalSourceParameters( X, tts_in_ok )
pause( 1.5 )
va.setSignalSourceParameters( X, tts_in_ok )
pause( 1 )
va.setSignalSourceParameters( X, tts_in_alright )

tts_in = struct();
tts_in.id = 'id_excidea';
tts_in.prepare_text = 'That is an excellent idea!';
tts_in.direct_playback = true;
va.setSignalSourceParameters( X, tts_in )

while( true )
    txt = inputdlg;
    if isempty( txt )
        break;
    end
    tts_in = struct();
    tts_in.direct_playback = true;
    tts_in.prepare_text = txt{1};
    if isempty( tts_in.prepare_text )
        break;
    end
    va.setSignalSourceParameters( X, tts_in )
end
