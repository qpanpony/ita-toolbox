%% Config
n1 = [ 1 1 0 ];
n2 = [ -1 1 0 ];
loc = [ 0 0 -2 ];
src = [ -5 0 0 ];
rcv = 3 * [ 1 -0.5 0 ];
rcv2 = [ 1 -0.99 0 ];
w = itaInfiniteWedge( n1, n2, loc );
freq = linspace( 20, 20000, 1000);
r_dir = norm( rcv - src );
c = 343;
k = 2 * pi * freq ./ c;


%% Filter
att = ita_diffraction_utd( w, src, rcv, freq );

% % E_dir = ( 1 / r_dir * exp( -1i .* k * r_dir ) )';
% % if ~ita_diffraction_shadow_zone(w, src, rcv)
% %     att.freqData = att.freqData + E_dir;
% % end
% % att.freqData = att.freqData ./ E_dir;

% plot(freq, att.freqData_dB);
semilogx(freq, att.freqData_dB);
xlim([freq(1), freq(end)]);
grid on
%att2 = ita_diffraction_utd( w, src, rcv2, ita_ANSI_center_frequencies );

%%
% % % a = itaAudio;
% % % a.samplingRate = 44100;
% % % a.nSamples = 44100;
% % % a.timeData( 2 ) = 1;
% % % a.pt
% % % 
% % % sl = ita_generate_sweep( 'mode', 'lin' )
