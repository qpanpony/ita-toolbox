%% VA simple example code with sound source distance slider and optional reverberation

% Author: Lukas Aspöck, las@akustik.rwth-aachen.de
% date: 2019/12/19

%% Instruction to add reverb to the scene
% 1) If running, close the VAServer application
% 2) go to the VA/conf folder and open the file VACore.ini with a text editor
% 3) scroll down to the line [Renderer:MyBinauralArtificialReverb]
% 4) set the key "Enabled" to true
% 5) replace the line ReverberationTime = 0.71 with ReverberationTimes = 1, 1, 0.5
% 6) Restart VAServer (run_VAServer.bat) and rerun this script

% Create VA
va = VA;

% Connect to VA application (start the application first)
va.connect( 'localhost' )

% Reset VA to clear the scene
va.reset()

% Control output gain
va.set_output_gain( .25 )

% Add the current absolute folder path to VA application
va.add_search_path( pwd );

% Create a signal source and start playback
X = va.create_signal_source_buffer_from_file( '$(DemoSound)' );
va.set_signal_source_buffer_playback_action( X, 'play' )
va.set_signal_source_buffer_looping( X, true );

% Create a virtual sound source and set a position
S = va.create_sound_source( 'VA_Source' );
va.set_sound_source_position( S, [ 0.5 1.7 0.5 ] )

% Create a listener with a HRTF and position him
L = va.create_sound_receiver( 'VA_Listener' );
va.set_sound_receiver_position( L, [ 0 1.7 0 ] )

H = va.create_directivity_from_file( '$(DefaultHRIR)' );
va.set_sound_receiver_directivity( L, H );

% Connect the signal source to the virtual sound source
va.set_sound_source_signal_source( S, X )

% start slider gui to change the distance
va_sliderDistance(va,S)



