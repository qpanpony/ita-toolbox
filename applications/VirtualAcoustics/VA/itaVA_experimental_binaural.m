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
mStruct.listener = L;
mStruct.source = S;
mStruct.ch1 = myhrir.ch( 1 ).timeData;
mStruct.ch2 = myhrir.ch( 2 ).timeData;
mRes = va.callModule( mod_id, mStruct )
