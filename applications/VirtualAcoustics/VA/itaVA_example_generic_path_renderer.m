%% itaVA simple example code for generic path renderer

va = itaVA( 'localhost' )
va.reset();

ita_write_wav( ita_demosound, 'ita_demosound.wav', 'overwrite' );
va.addSearchPath( pwd );
X = va.createAudiofileSignalSource( 'ita_demosound.wav' );
va.setAudiofileSignalSourcePlaybackAction( X, 'play' );
va.setAudiofileSignalSourceIsLooping( X, true );
S = va.createSoundSource( 'itaVA_Source' );
va.setSoundSourceSignalSource( S, X );
L = va.createListener( 'itaVA_Listener' );
va.setActiveListener( L );

mMods = va.enumerateModules;

modname = 'none';
for n = size( mMods, 1 )
    if strcmp( 'PrototypeGenericPath', mMods(n).name( 1:size( 'PrototypeGenericPath', 2 ) ) )
        modname = mMods(n).name;
        break; % use first one found
    end
end

if strcmp( modname, 'none' )
    error( 'Could not find a generic path module, not activated in VA core configuration?' )
end


%% How to get help
mStruct = struct;
mStruct.help = ''; % or true or anything
mRes = va.callModule( modname, mStruct );
disp( mRes.help )

%% How to get infos
mStruct = struct;
mStruct.info = ''; % or true or anything
mRes = va.callModule( modname, mStruct )

%% How to update using a file with two channels (matching channels required)
a = ita_merge( ita_amplify( ita_generate_impulse, '-12dB' ), ita_amplify( ita_generate_impulse, '-21dB' ) );
ita_write_wav( a, 'unequal_dirac.wav', 'overwrite' );
mStruct = struct;
mStruct.verbose = ''; % Verbose output for testing only, costly ...
mStruct.listener = L;
mStruct.source = S;
mStruct.filepath = fullfile( pwd, 'unequal_dirac.wav' );
mRes = va.callModule( modname, mStruct )

%% How to update a path sending floating point data (separate channels possible)
b = ita_generate_impulse( 'fftDegree', 15 );
mStruct = struct;
mStruct.verbose = true; % ... remove line if verbosity not required anymore.
mStruct.listener = L;
mStruct.source = S;
mStruct.ch2 = b.timeData / 2; % here, only update channel 2
mRes = va.callModule( modname, mStruct )
