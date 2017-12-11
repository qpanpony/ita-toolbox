%% Starts and prepares VA for experimental setup and exchanges binaural filters from an itaHRTF class
itaVA_experimental_start_server
itaVA_experimental_renderer_prepare

%% Load
[ hrir_filename, hrir_base_path ] = uigetfile( { '*.daff', 'OpenDAFF IR file' }, 'Select an HRIR or HRTF input file' );
myhrirset = itaHRTF( 'daff', fullfile( hrir_base_path, hrir_filename ) );
myhrir_coords = itaCoordinates( 1 );
myhrir_coords.elevation = 40;
myhrir_coords.azimuth = 13;
myhrir = myhrirset.findnearestHRTF( myhrir_coords );
myhrir.pf

%% Exchange (variables prepared by itaVA_experimental_renderer_prepare)
mStruct = struct;
mStruct.receiver = L;
mStruct.source = S;
mStruct.ch1 = double( myhrir.ch( 1 ).timeData )';
mStruct.ch2 = double( myhrir.ch( 2 ).timeData )';
va.set_rendering_module_parameters( mod_id, mStruct )
