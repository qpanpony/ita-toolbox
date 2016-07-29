%% itaVA simple example for random numbers from random locations

va = itaVA( 'localhost' );
va.reset;

H = va.loadHRIRDataset( '$(VADefaultHRIRDataset)' );
L = va.createListener( 'matlab_listener', 'all', H );
va.setListenerPosition( L, [0 0 0] )
va.setActiveListener( L )

base_path = 'D:\Users\stienen\Arbeitsumgebung\VA\VAData\Audiofiles\Numbers'; % See \\ITA-NAS\Messdaten\[Recordings]\[Speech]
listing = dir( fullfile( base_path, '*.wav' ) );
numaudiofiles = size( listing, 1 );

disp( [ 'Found ' num2str( numaudiofiles ) ' wave files in base path.' ] )
assert( numaudiofiles > 1 )

X = cell( numaudiofiles, 2 );
disp_warning_sample_length = false;
for i=1:numaudiofiles
    filepath_absolute = fullfile( base_path, listing(i).name );
    X{i,1} = va.createAudiofileSignalSource( filepath_absolute );
    va.setAudiofileSignalSourceIsLooping( X{i,1}, false );
    
    a = ita_read( filepath_absolute, 'metadata' );
    X{i,2} = a.trackLength;
    
    if X{i,2} > 10
        disp_warning_sample_length = true;
    end
end

if disp_warning_sample_length
    disp( 'One or more samples are long, use CTRL+C to interupt after closing stop dialog' )
end

h = msgbox( 'Stop' );
while( ishandle( h ) )
    
    % Select random index of samples
    random_idx = ceil( rand * numaudiofiles );
    if random_idx == 0 
        random_idx = 1; % Unusual case, but prevent exception
    end
    x = X{random_idx,1};
    
    s = va.createSoundSource( 'matlab_sound_source' );
    azi = 2 * pi * rand;
    ele = 2 * pi * rand;
    r = 1.5;    
    [pos_x,pos_y,pos_z] = sph2cart( azi, ele, r ) % ... on sphere with radius r
    va.setSoundSourcePosition( s, [pos_x,pos_y,pos_z] );
    va.setSoundSourceSignalSource( s, x );
    va.setAudiofileSignalSourcePlaybackAction( x, 'play' )
    
    pause( X{random_idx,2} ) % Initial wait, use track length
    while strcmp( va.getAudiofileSignalSourcePlaybackState( x ), 'PLAYING' )
        pause( 0.1 ) % Correct wait uses a polling test on play state until stopped
    end
    
    va.deleteSoundSource( s );
    
    pause( 0.4 )
end

va.reset;
va.disconnect;
