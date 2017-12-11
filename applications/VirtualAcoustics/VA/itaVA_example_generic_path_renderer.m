%% itaVA simple example code for generic path renderer
itaVAq
va.reset();
va.add_search_path( pwd );

X = va.create_signal_source_buffer_from_file( '$(DemoSound)' );
va.set_signal_source_buffer_playback_action( X, 'play' );
va.set_signal_source_buffer_looping( X, true );
S = va.create_sound_source( 'itaVA_Source' );
va.set_sound_source_signal_source( S, X );
L = va.create_sound_receiver( 'itaVA_Listener' );
va.set_active_sound_receiver( L );

mMods = va.get_rendering_modules();

modname = 'none';
if isstruct( mMods )
    modname = mMods.id; % only one available
else
    modname = mMods( 1 ).id; % use first
end

if strcmp( modname, 'none' )
    disp( 'Could not find a generic path module, not activated in VA core configuration?' )
end


% How to get help
mStruct = struct;
mStruct.help = ''; % or true or anything
mRes = va.get_rendering_module_parameters( modname, mStruct );
disp( mRes.help )

% How to update using a file with two channels (matching channels required)
a = ita_merge( ita_amplify( ita_generate_impulse, '-21dB' ), ita_amplify( ita_generate_impulse, '-12dB' ) );
ita_write_wav( a, 'unequal_dirac.wav', 'overwrite' );
mStruct = struct;
mStruct.verbose = ''; % Verbose output for testing only, costly ...
mStruct.receiver = L;
mStruct.source = S;
mStruct.filepath = fullfile( pwd, 'unequal_dirac.wav' );
va.set_rendering_module_parameters( modname, mStruct )

% How to update a path sending floating point data (separate channels possible)
b = ita_generate_impulse( 'fftDegree', 18 );
mStruct = struct;
mStruct.verbose = true; % ... remove line if verbosity not required anymore.
mStruct.receiver = L;
mStruct.source = S;
mStruct.ch2 = b.timeData / 104; % here, only update channel 2
va.set_rendering_module_parameters( modname, mStruct ) % Currently under testing, use short IRs only

va.disconnect()
