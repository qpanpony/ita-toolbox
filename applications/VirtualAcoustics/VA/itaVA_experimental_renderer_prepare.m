% Prepare an experimental renderer using PrototypeGEnericPath
itaVAq
va.addSearchPath( pwd ); 
va.reset();

% Find first PGP renderer
for n=1:numel( va.getRenderingModules )
    if strcmp( va.getRenderingModules( n ).class, 'PrototypeGenericPath' )
        gpg_renderer = va.getRenderingModules( n );
        break;
    end
end

if ~exist( 'gpg_renderer', 'var' )
    error( 'No prototype generic path renderer found, please add or enable in VA configuration.' )
else
    disp( [ 'Using channel prototype generic path renderer with identifier: ' gpg_renderer.id ] )
end

% Classic VA module call with input and output arguments
mod_id = [ gpg_renderer.class ':' gpg_renderer.id ];
in_args.info = true;
out_args = va.callModule( mod_id, in_args );
disp( [ 'Your experimental renderer has ' num2str( out_args.numchannels ) ' channels and an FIR filter length of ' num2str( out_args.irfilterlengthsamples ) ' samples' ] )

% Very simple scene with one path
L = va.createListener( 'itaVA_ExperimentalListener' );
%va.setActiveListener( L );
S = va.createSoundSource( 'itaVA_ExperimentalListener' );

% Create a signal source and start playback
ita_write_wav( ita_demosound, 'ita_demosound.wav', 'overwrite' );
X = va.createAudiofileSignalSource( 'ita_demosound.wav' );
va.setAudiofileSignalSourcePlaybackAction( X, 'play' )
va.setAudiofileSignalSourceIsLooping( X, true );
va.setSoundSourceSignalSource( S, X );
