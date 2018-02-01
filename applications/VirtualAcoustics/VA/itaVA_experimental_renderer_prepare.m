% Prepare an experimental renderer using PrototypeGEnericPath
itaVAq
va.add_search_path( pwd );
va.reset();

mMods = va.get_rendering_modules();

if isstruct( mMods )
    gpg_renderer = mMods; % only one available
else
    gpg_renderer = mMods( 1 ); % use first
end

if strcmp( gpg_renderer.id, 'none' )
    disp( 'Could not find a generic path module, not activated in VA core configuration?' )
end



if ~exist( 'gpg_renderer', 'var' )
    error( 'No prototype generic path renderer found, please add or enable in VA configuration.' )
else
    disp( [ 'Using channel prototype generic path renderer with identifier: ' gpg_renderer.id ] )
end

% Classic VA module call with input and output arguments
mod_id = gpg_renderer.id;
in_args.info = true;
out_args = va.get_rendering_module_parameters( mod_id, in_args );
disp( [ 'Your experimental renderer has ' num2str( out_args.numchannels ) ' channels and an FIR filter length of ' num2str( out_args.irfilterlengthsamples ) ' samples' ] )

% Very simple scene with one path
L = va.create_sound_receiver( 'itaVA_ExperimentalListener' );
%va.setActiveListener( L );
S = va.create_sound_source( 'itaVA_ExperimentalListener' );

% Create a signal source and start playback
ita_write_wav( ita_demosound, 'ita_demosound.wav', 'overwrite' );
X = va.create_signal_source_buffer_from_file( 'ita_demosound.wav' );
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );
va.set_sound_source_signal_source( S, X );

disp( 'VA experimental renderer prepared.' )
