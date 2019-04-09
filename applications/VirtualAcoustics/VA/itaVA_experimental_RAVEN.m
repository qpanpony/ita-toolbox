%% Starts and prepares VA for experimental setup
itaVA_experimental_start_server
itaVA_experimental_renderer_prepare

% @todo apply new VA method naming conventions (all small caps with
% underscores between words)

%% Direct signal out without room (variables L and S prepared by itaVA_experimental_renderer_prepare)
dirac = ita_amplify( ita_generate_impulse, '-12dB' );
mStruct = struct;
mStruct.listener = L;
mStruct.source = S;
mStruct.ch1 = double( dirac.ch( 1 ).timeData )'; % dirac left
mStruct.ch2 = double( dirac.ch( 1 ).timeData )'; % dirac right
va.callModule( mod_id, mStruct );


%% Now execute RAVEN demo to aquire a BRIR
ita_raven_demo % will generate BRIR itaAudio object with name 'binaural'


%% Exchange BRIR
mStruct.ch1 = double( binaural.ch( 1 ).timeData )';
mStruct.ch2 = double( binaural.ch( 2 ).timeData )';
mStruct.verbose = true;
va.callModule( mod_id, mStruct )
