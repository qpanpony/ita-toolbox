%% Starts and prepares VA for experimental setup
itaVA_experimental_start_server
itaVA_experimental_renderer_prepare


%% Direct signal out without room (variables L and S prepared by itaVA_experimental_renderer_prepare)
dirac = ita_amplify( ita_generate_impulse, '-12dB' );
update_t = struct;
update_t.receiver = L;
update_t.source = S;
update_t.ch1 = double( dirac.ch( 1 ).timeData )'; % dirac left
update_t.ch2 = double( dirac.ch( 1 ).timeData )'; % dirac right
va.set_rendering_module_parameters( mod_id, update_t );


%% Now execute RAVEN demo to aquire a BRIR
ita_raven_demo % will generate BRIR itaAudio object with name 'binaural'


%% Exchange BRIR
update_t.ch1 = double( binaural.ch( 1 ).timeData )';
update_t.ch2 = double( binaural.ch( 2 ).timeData )';
update_t.verbose = true;
va.set_rendering_module_parameters( mod_id, update_t )
