%% Starts and prepares VA for experimental setup and exchanges binaural filters from an itaHRTF class
itaVA_experimental_start_server
itaVA_experimental_renderer_prepare

%% Execute RAVEN demo
ita_raven_demo % will generate BRIR 'binaural'

%% Exchange (variables prepared by itaVA_experimental_renderer_prepare)
mStruct = struct;
mStruct.listener = L;
mStruct.source = S;
mStruct.ch1 = double( binaural.ch( 1 ).timeData )';
mStruct.ch2 = double( binaural.ch( 2 ).timeData )';
mRes = va.callModule( mod_id, mStruct )
