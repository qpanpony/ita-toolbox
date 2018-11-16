%% Config
% wedge
n1 = [1, 1, 0];
n2 = [-1, 1, 0];
loc = [0, 0, -3];
wedge = itaInfiniteWedge(n1, n2, loc);

% fin wedge
len = 20;
finw = itaFiniteWedge(n1, n2, loc, len);

% screen
n3 = [1, 0, 0];
apex_dir = [0, 0, 1];
screen = itaSemiInfinitePlane(n3, loc, apex_dir);

% fin screen
fins = itaFiniteWedge(n3 + [0, 0.0001, 0], -n3 + [0, 0.0001, 0], loc, len);
% fins.aperture_direction = apex_dir;

% source and receiver
src = 3 * [-1, 0, 0];
angle1 = deg2rad(15);
angle2 = deg2rad(-15);
rcv1 = 3 * [cos(angle1), sin(angle1), 0];
rcv2 = 3 * [cos(angle2), sin(angle2), 0];

% filter parameters
resolution = 5000;
% freq = linspace(20, 24000, resolution);
freq = ita_ANSI_center_frequencies;
c = 344;
f_s = 44100;
filter_length = 1024;
apex_point = wedge.get_aperture_point( src, rcv1 );
R0 = norm( apex_point - src ) + norm( rcv1 - apex_point );
tau0 = R0 / c;
tau = 0 : 1/f_s : tau0 + ( (filter_length - 1) * 1/f_s);

ref_face_wedge = wedge.point_facing_main_side(src);
ref_face_screen = screen.point_facing_main_side(src);

%% Filters
% Maekawa
% res_maekawa  = itaResult;
res_maekawa1 = itaResult;
res_maekawa2 = itaResult;
res_maekawa3 = itaResult;
res_maekawa4 = itaResult;

res_maekawa1.freqVector = freq;
res_maekawa2.freqVector = freq;
res_maekawa3.freqVector = freq;
res_maekawa4.freqVector = freq;

res_maekawa1.freqData = ita_diffraction_maekawa(wedge, src, rcv1, freq, c);
res_maekawa2.freqData = ita_diffraction_maekawa(wedge, src, rcv2, freq, c);
res_maekawa3.freqData = ita_diffraction_maekawa(screen, src, rcv1, freq, c);
res_maekawa4.freqData = ita_diffraction_maekawa(screen, src, rcv2, freq, c);

res_maekawa = ita_merge( res_maekawa1, res_maekawa2, res_maekawa3, res_maekawa4 );

% Maekawa approx
% res_maekawa_approx  = itaResult;
res_maekawa_approx1 = itaResult;
res_maekawa_approx2 = itaResult;
res_maekawa_approx3 = itaResult;
res_maekawa_approx4 = itaResult;

res_maekawa_approx1.freqVector = freq;
res_maekawa_approx2.freqVector = freq;
res_maekawa_approx3.freqVector = freq;
res_maekawa_approx4.freqVector = freq;

res_maekawa_approx1.freqData = ita_diffraction_maekawa_approx(wedge, src, rcv1, freq, c);
res_maekawa_approx2.freqData = ita_diffraction_maekawa_approx(wedge, src, rcv2, freq, c);
res_maekawa_approx3.freqData = ita_diffraction_maekawa_approx(screen, src, rcv1, freq, c);
res_maekawa_approx4.freqData = ita_diffraction_maekawa_approx(screen, src, rcv2, freq, c);

res_maekawa_approx = ita_merge( res_maekawa_approx1, res_maekawa_approx2, res_maekawa_approx3, res_maekawa_approx4 );

% UTD
% res_utd  = itaResult;
res_utd1 = itaResult;
res_utd2 = itaResult;
res_utd3 = itaResult;
res_utd4 = itaResult;

res_utd1.freqVector = freq;
res_utd2.freqVector = freq;
res_utd3.freqVector = freq;
res_utd4.freqVector = freq;

res_utd1.freqData = ita_diffraction_utd(wedge, src, rcv1, freq, c);
res_utd2.freqData = ita_diffraction_utd(wedge, src, rcv2, freq, c);
res_utd3.freqData = ita_diffraction_utd(screen, src, rcv1, freq, c);
res_utd4.freqData = ita_diffraction_utd(screen, src, rcv2, freq, c);

res_utd = ita_merge( res_utd1, res_utd2, res_utd3 ,res_utd4 );

% UTD approx
res_utd_approx1 = itaResult;
res_utd_approx2 = itaResult;
res_utd_approx3 = itaResult;
res_utd_approx4 = itaResult;

res_utd_approx1.freqVector = freq;
res_utd_approx2.freqVector = freq;
res_utd_approx3.freqVector = freq;
res_utd_approx4.freqVector = freq;

% res_utd_approx1.freqData = ita_diffraction_utd_approximated(wedge, src, rcv1, freq, c);
% res_utd_approx2.freqData = ita_diffraction_utd_approximated(wedge, src, rcv2, freq, c);
% res_utd_approx3.freqData = ita_diffraction_utd_approximated(screen, src, rcv1, freq, c);
% res_utd_approx4.freqData = ita_diffraction_utd_approximated(screen, src, rcv2, freq, c);

res_utd_approx = ita_merge( res_utd_approx1, res_utd_approx2, res_utd_approx3, res_utd_approx4 );

% btms
res_btms1 = itaAudio;
res_btms2 = itaAudio;
res_btms3 = itaAudio;
res_btms4 = itaAudio;

res_btms1.signalType = 'energy';
res_btms2.signalType = 'energy';
res_btms3.signalType = 'energy';
res_btms4.signalType = 'energy';

res_btms1.samplingRate = f_s;
res_btms2.samplingRate = f_s;
res_btms3.samplingRate = f_s;
res_btms4.samplingRate = f_s;

res_btms1.nSamples = filter_length;
res_btms2.nSamples = filter_length;
res_btms3.nSamples = filter_length;
res_btms4.nSamples = filter_length;

res_btms1.timeData = ita_diffraction_btm_finite_wedge(finw, src, rcv1, tau, c, true );
res_btms2.timeData = ita_diffraction_btm_finite_wedge(finw, src, rcv2, tau, c );
res_btms3.timeData = ita_diffraction_btm_finite_wedge(fins, src, rcv1, tau, c );
res_btms4.timeData = ita_diffraction_btm_finite_wedge(fins, src, rcv2, tau, c );

res_btms = ita_merge( res_btms1, res_btms2, res_btms3, res_btms4 );

%% Plots
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );

str_lgnd = [ "wedge, illuminated"; "wedge, shadowed"; "screen, illuminated"; "screen, shadowed" ];

% maekawa
subplot( 2, 2, 1 );
semilogx( freq', res_maekawa1.freqData_dB, '--', freq', res_maekawa2.freqData_dB, freq', res_maekawa3.freqData_dB, '--', freq', res_maekawa4.freqData_dB );
title( 'Transfer function Maekawa method' );
legend( str_lgnd );
xlabel( 'f [Hz]' );
ylabel( 'H(f) [dB]' );
xlim( [freq(1), freq(end)] );
ylim( [-45, -15] );
grid on;

% maekawa approx
subplot( 2, 2, 2 );
semilogx( freq', res_maekawa_approx1.freqData_dB, '--', freq', res_maekawa_approx2.freqData_dB, freq', res_maekawa_approx3.freqData_dB, '--', freq', res_maekawa_approx4.freqData_dB );
title( 'Transfer function Maekawa approx' )
legend( str_lgnd );
xlabel( 'f [Hz]' );
ylabel( 'H(f) [dB]' );
ylim( [-45, -15] );
xlim( [freq(1), freq(end)] );
grid on;

% utd
subplot( 2, 2, 3 );
semilogx( freq', res_utd1.freqData_dB, '--', freq', res_utd2.freqData_dB, freq', res_utd3.freqData_dB, '--', freq', res_utd4.freqData_dB );
title( 'Transfer function UTD' );
legend( str_lgnd );
xlabel( 'f [Hz]' );
ylabel( 'H(f) [dB]' );
ylim( [-45, -15] );
xlim( [freq(1), freq(end)] );
grid on;

% utd approx
subplot( 2, 2, 4 );
semilogx( freq', res_utd_approx1.freqData_dB, '--', freq', res_utd_approx2.freqData_dB, freq', res_utd_approx3.freqData_dB, '--', freq', res_utd_approx4.freqData_dB );
title( 'Transfer function UTD approx' );
legend( str_lgnd );
xlabel( 'f [Hz]' );
ylabel( 'H(f) [dB]' );
ylim( [-45, -15] );
xlim( [freq(1), freq(end)] );
grid on;

% btms
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );

subplot( 2, 2, 1);
semilogx( tau', res_btms1.timeData, '--', tau', res_btms2.timeData, tau', res_btms3.timeData, '--', tau', res_btms4.timeData );
title( 'Impulse response BTMS' );
legend( str_lgnd );
xlabel( 't [s]' );
ylabel( 'h(t)' );
% ylim( [-45, -15] );
xlim( [tau(1), tau(120)] );
grid on;

subplot(2, 2, 2);
semilogx( res_btms1.freqVector, res_btms1.freqData_dB, '--', res_btms1.freqVector, res_btms2.freqData_dB, res_btms1.freqVector, res_btms3.freqData_dB, '--', res_btms1.freqVector, res_btms4.freqData_dB );
title( 'Transfer function BTMS' );
legend( str_lgnd );
xlabel( 'f [Hz]' );
ylabel( 'H(f)' );
ylim( [-45, -15] );
xlim( [res_btms1.freqVector(1), res_btms1.freqVector(end)] );
grid on;


%% more plots
% res_maekawa2.pf;
% res_maekawa_approx2.pf;
% 
% res_utd.pf;
% res_utd_approx.pf;
% 
% res_btms.pt;
