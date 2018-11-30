%% Config
% screen
n1 = [1  0  0];
n2 = [-1  0  0];

% % wedge
% n1 = [1, 1, 0];
% n2 = [-1, 1, 0];

apex_dir = [0  0  1];
loc = [0 0 2];
len = 10;

% screen
w = itaInfiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc);
w.aperture_direction = apex_dir;

n3 = [ 1, 0.00001, 0 ];
n4 = [-1, 0.00001, 0 ];
finw = itaFiniteWedge( n3 / norm(n3), n4 / norm(n4), loc, len );
% finw.aperture_direction = apex_dir;
% finw.aperture_end_point = (len);

% source and receiver
src = 3/sqrt(1) * [-1  0  0];
rcv_start_pos = 3/sqrt(2) * [ 1  1  0];
rcv_end_pos = 3/sqrt(2) * [ 1  -1  0];
apex_point = w.get_aperture_point(src, rcv_start_pos);

% parameters
delta = 0.05;
c = 344; % Speed of sound
angle_resolution = 100;
freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000];

f_s = 44100;
n = 1024;
R_0 = norm( apex_point - src ) + norm( rcv_start_pos - apex_point );
tau_0 = R_0 / c;
tau = tau_0 : 1/f_s : tau_0 + (n - 1) * 1/f_s;

%% Variables

ref_face = w.point_facing_main_side( src );
alpha_start = w.get_angle_from_point_to_wedge_face(rcv_start_pos, ref_face);
alpha_end = w.get_angle_from_point_to_wedge_face(rcv_end_pos, ref_face);
alpha_d = linspace( alpha_start, alpha_end, angle_resolution );



% Set different receiver positions rotated around the aperture
rcv_positions = ita_align_points_around_aperture( w, rcv_start_pos, alpha_d, apex_point, ref_face );

detour_vec = norm( apex_point - src ) + Norm( rcv_positions - apex_point ) - Norm( rcv_positions - src );

% Fresnel Number
lambda = c ./ freq;
N_vec = 2 * detour_vec ./ lambda;

%% Calculations
% total wave field
k = 2 * pi * freq ./ c;
R_dir = repmat( Norm( rcv_positions - src ), 1, numel(freq) );
E_dir = 1 ./ R_dir .* exp( -1i .* k .* R_dir );

in_shadow_zone = ita_diffraction_shadow_zone( w, src, rcv_positions );


% Maekawa diffraction attenuation
att_sum_maekawa = itaResult;
att_sum_maekawa.freqVector = freq;
att_sum_maekawa.freqData = ita_diffraction_maekawa( w, src, rcv_positions, freq, c );
att_sum_maekawa.freqData( :, ~in_shadow_zone' ) = att_sum_maekawa.freqData( :, ~in_shadow_zone' ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_maekawa.freqData = att_sum_maekawa.freqData ./ E_dir';


% Maekawa approximated diffraction attenuation
att_sum_maekawa_approx = itaResult;
att_sum_maekawa_approx.freqVector = freq;
att_sum_maekawa_approx.freqData = ita_diffraction_maekawa_approx( w, src, rcv_positions, freq, c );
att_sum_maekawa_approx.freqData( :, ~in_shadow_zone ) = att_sum_maekawa_approx.freqData( :, ~in_shadow_zone ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_maekawa_approx.freqData = att_sum_maekawa_approx.freqData ./ E_dir';


% UTD total wave field
att_sum_utd = itaResult;
att_sum_utd.freqVector = freq;
att_sum_utd.freqData = ita_diffraction_utd( w, src, rcv_positions, freq, c );
att_sum_utd.freqData( :, ~in_shadow_zone' ) = att_sum_utd.freqData( :, ~in_shadow_zone' ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_utd.freqData = att_sum_utd.freqData ./ E_dir';


% UTD approximated wave field
att_sum_utd_approx = itaResult;
att_sum_utd_approx.freqVector = freq;
att_sum_utd_approx.freqData = ita_diffraction_utd_approximated( w, src, rcv_positions, freq, c );
att_sum_utd_approx.freqData( :, ~in_shadow_zone' ) = att_sum_utd_approx.freqData( :, ~in_shadow_zone' ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_utd_approx.freqData = att_sum_utd_approx.freqData ./ E_dir';


% BTMS total field
att_btms = itaAudio;
att_btms.signalType = 'energy';
att_btms.samplingRate = f_s;
att_btms.nSamples = n;

att_sum_btms = itaAudio;
for j = 1 : numel( alpha_d )
    att_btms.timeData = ita_diffraction_btm_finite_wedge( finw, src, rcv_positions( j, : ), tau, c, true );
    att_sum_btms = ita_merge( att_sum_btms, att_btms );
end
f_btms = att_sum_btms.freqVector';
f_plot = f_btms( 6 : 50 : end );
k2 = 2 * pi * f_btms ./ c;
R_dir2 = repmat( Norm( rcv_positions - src ), 1, numel(f_btms) );
E_dir2 = 1 ./ R_dir2 .* exp( -1i .* k2 .* R_dir2 );

att_sum_btms.freqData( :, ~in_shadow_zone ) = att_sum_btms.freqData( :, ~in_shadow_zone ) + ( E_dir2( ~in_shadow_zone, : ) )';
att_sum_btms.freqData = att_sum_btms.freqData ./ E_dir2';


% maekawa with btms freq
att_sum_maekawa_comp = itaResult;
att_sum_maekawa_comp.freqData = ita_diffraction_maekawa( w, src, rcv_positions, f_btms, c );
att_sum_maekawa_comp.freqData( :, ~in_shadow_zone' ) = att_sum_maekawa_comp.freqData( :, ~in_shadow_zone' ) + ( E_dir2( ~in_shadow_zone, : ) )';
att_sum_maekawa_comp.freqData = att_sum_maekawa_comp.freqData ./ E_dir2';

% error calculation
att_sum_error = itaResult;
att_sum_error.freqVector = freq;
att_sum_error.freqData = ( att_sum_maekawa_comp.freqData ./ att_sum_btms.freqData ).^(-1);


% error
att_sum_error_approx = itaResult;
att_sum_error_approx.freqVector = freq;
att_sum_error_approx.freqData = att_sum_maekawa_approx.freqData ./ att_sum_utd_approx.freqData;

%% Comparison to UTD plot
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
% subplot( 2, 2, 1 );
% plot( rad2deg( alpha_d ), att_sum_maekawa.freqData_dB' )
% title( 'Maekawa diffraction' )
% legend( [num2str( freq' ), repmat(' Hz', numel(freq), 1)], 'Location', 'southwest' )
% xlabel( 'theta_R [°]' )
% ylabel( 'p_{total} [dB]' )
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;
% 
% subplot( 2, 2, 2 );
% plot( rad2deg( alpha_d ), att_sum_maekawa_approx.freqData_dB' )
% title( 'Maekawa approximation' )
% legend( [num2str( freq' ), repmat(' Hz', numel(freq), 1)], 'Location', 'southwest' )
% xlabel( 'theta_R [°]' )
% ylabel( 'p_{total} [dB]' )
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;

res_btms = att_sum_btms.freqData_dB';
subplot( 2, 2, 1 );
plot( rad2deg( alpha_d ), res_btms( :, 6 : 50 : end ) )
title( 'diffraction by screen modeled with BTMS method' )
legend( [num2str( round( f_plot' ) ), repmat(' Hz', numel(f_plot), 1)], 'Location', 'southwest' )
xlabel( 'theta_R [°]' )
ylabel( 'p_{total} [dB]' )
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;

res_error = att_sum_error.freqData_dB';
subplot( 2, 2, 2 );
plot( rad2deg( alpha_d ), res_error( :, 6 : 50 : end ) )
title( 'deviation BTMS from Maekawa method' )
legend( [num2str( round( f_plot' ) ), repmat(' Hz', numel(f_plot), 1)], 'Location', 'southwest' )
xlabel( 'theta_R [°]' )
ylabel( 'p_{total} [dB]' )
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;
%
% subplot( 3, 2, 5 );
% plot( rad2deg( alpha_d ), att_sum_utd_approx.freqData_dB' )
% title( 'UTD total wave field plot' )
% legend( num2str( freq' ), 'Location', 'southwest' )
% xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
% ylabel( 'dB SPL' )
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;
% 
% subplot( 3, 2, 6 );
% plot( rad2deg( alpha_d ), att_sum_error_approx.freqData_dB' )
% title( 'UTD total wave field plot' )
% legend( num2str( freq' ), 'Location', 'southwest' )
% xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
% ylabel( 'dB SPL' )
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;

function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end