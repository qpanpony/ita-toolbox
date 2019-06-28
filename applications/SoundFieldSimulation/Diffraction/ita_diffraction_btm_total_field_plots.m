%% Config
n1 = [1  1  0];
n2 = [-1  1  0];
% apex_dir = [0  0  1];
loc = [0 0 -3];
len = 8;
src = 3/sqrt(1) * [-1  0  0];
rcv_start_pos = 3/sqrt(2) * [ 1, 1, 0 ];
rcv_end_pos = 3/sqrt(2) * [ 1, -1, 0 ];
infw = itaInfiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc);
finw = itaFiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc, len);
apex_dir = infw.aperture_direction;
% w.aperture_direction = apex_dir;
apex_point = infw.get_aperture_point(src, rcv_start_pos);
delta = 0.05;
c = 344; % Speed of sound

% screen
n3 = [1, 0.00001, 0];
n4 = [-1, 0.00001, 0];
screen = itaFiniteWedge(n3/norm(n3), n4/norm(n4), loc, len); 


wdg = finw;
%freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000];
f_sampling = 44100;
filter_length = 1024;
ref_face = wdg.point_facing_main_side( src );
alpha_start = wdg.get_angle_from_point_to_wedge_face(rcv_start_pos, ref_face);
alpha_end = wdg.get_angle_from_point_to_wedge_face(rcv_end_pos, ref_face);
alpha_res = 200;

alpha_d = linspace( alpha_start, alpha_end, alpha_res );



% Set Receiver Positions
rcv_positions = ita_align_points_around_aperture( wdg, rcv_start_pos, alpha_d, apex_point, ref_face );
for i = 1:size(rcv_positions, 1)
    in_shadow_zone = ita_diffraction_shadow_zone( wdg, src, rcv_positions(i, :) );
end

% Direct field component for normalization of total field
f = linspace( 0, f_sampling/2, filter_length/2 + 1 );
k = 2* pi * f / c;
R_dir = repmat( sqrt( sum( ( rcv_positions - src ).^2, 2 ) ), 1, numel(f) );
E_dir = 1 ./ R_dir .* exp( -1i .* k .* R_dir );


%% Calculations
%%% BTM infinite wedge %%%-------------------------
att_sum_btm_inf = ita_diffraction_btm_infinite_wedge( infw, src, rcv_positions, f_sampling, filter_length );

% f = att_sum_btm_inf.freqVector';
% k = 2 * pi * f ./ c;

% R_dir = repmat( sqrt( sum( ( rcv_positions - src ).^2, 2 ) ), 1, numel(f) );
% E_dir = 1 ./ R_dir .* exp( -1i .* k .* R_dir );

% normalization
att_sum_btm_inf.freqData( :, ~in_shadow_zone ) = att_sum_btm_inf.freqData( :, ~in_shadow_zone ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_btm_inf.freqData = att_sum_btm_inf.freqData ./ E_dir';
%---------------------------------------------------


%%% BTM finite wedge %%%----------------------------
R0 = norm( apex_point - src ) + norm( rcv_start_pos - apex_point );
tau0 = R0 / c;
tau = tau0 : 1/f_sampling : tau0 + ( (filter_length - 1) * 1/f_sampling );

att = itaAudio();
% att.timeVector = tau;
att.signalType = 'energy';
att.samplingRate = f_sampling;
att.nSamples = filter_length;

att_sum_btm_fin1 = itaAudio;
for j = 1 : numel(rcv_positions(:,1))
    att.timeData = ita_diffraction_btms_approx( wdg, src, rcv_positions(j, :), f_sampling, filter_length, c, true );
    att_sum_btm_fin1 = ita_merge( att_sum_btm_fin1, att );
end
% normalization
att_sum_btm_fin1.freqData( :, ~in_shadow_zone ) = att_sum_btm_fin1.freqData( :, ~in_shadow_zone ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_btm_fin1.freqData = att_sum_btm_fin1.freqData ./ E_dir';


att_sum_btm_fin2 = itaAudio;
for l = 1 : numel(rcv_positions(:,1))
    att.timeData = ita_diffraction_btms( wdg, src, rcv_positions(l, :), f_sampling, filter_length, c, true );
    att_sum_btm_fin2 = ita_merge( att_sum_btm_fin2, att );
end
% normalization
att_sum_btm_fin2.freqData( :, ~in_shadow_zone ) = att_sum_btm_fin2.freqData( :, ~in_shadow_zone ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_btm_fin2.freqData = att_sum_btm_fin2.freqData ./ E_dir';
%---------------------------------------------------


%%% UTD %%%-----------------------------------------
att_sum_utd = itaResult;
att_sum_utd.freqVector = f;
att_sum_utd.freqData = ita_diffraction_utd( infw, src, rcv_positions, f, c );
% normalization
att_sum_utd.freqData( :, ~in_shadow_zone' ) = att_sum_utd.freqData( :, ~in_shadow_zone' ) + ( E_dir( ~in_shadow_zone, : ) )';
att_sum_utd.freqData = att_sum_utd.freqData ./ E_dir';
%---------------------------------------------------


%%% Maekawa %%%-------------------------------------
%---------------------------------------------------

%%% Svensson implementation %%%-

% % fs = f_sampling;
% % closwedang = finw.wedge_angle;
% % rs = sqrt( src(1)^2 + src(2)^2 );
% % thetas = infw.get_angle_from_point_to_wedge_face( src, ref_face ); 
% % zs = 0;
% % zr = rcv_positions(1, 3) - src(3);
% % zw = [ loc(3) - src(3), len - src(3) ];
% % Method = 'New';
% % 
% % att_sum_svensson = itaResult;
% % att_temp = itaResult;
% % for j = 1 : numel( rcv_positions(:, 1) )
% %     rr = sqrt( rcv_positions(j, 1)^2 + rcv_positions(j, 2)^2 );
% %     thetar = infw.get_angle_from_point_to_wedge_face( rcv_positions(j, :), ref_face );
% %     [ir,initdelay,singularterm] = EDB2wedge1st_int( fs, closwedang, rs, thetas, zs, rr, thetar, zr, zw, Method );
% %     att_temp.freqData = ir( ir ~= 0 );
% %     att_sum_svensson = ita_merge( att_sum_svensson, att_temp );
% % end
% % 
% % % normalization
% % % % att_sum_svensson.freqData( :, ~in_shadow_zone ) = att_sum_svensson.freqData( :, ~in_shadow_zone ) + ( E_dir( ~in_shadow_zone, : ) )';
% % % % att_sum_svensson.freqData = att_sum_svensson.freqData ./ E_dir';

%--------------------------------


%%% deviation between utd and btm %%%-------------------
% att_deviation = itaAudio;
% att_deviation.freqData = att_sum_utd.freqData ./ att_sum_btm_fin.freqData;
%-------------------------------------------------------


%% Plot
% f_plot = att_sum_btm_fin.freqVector( 6 : 50 : end );
% 
% figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
% subplot( 2, 2, 1 );
% res_utd = att_sum_utd.freqData_dB;
% plot( rad2deg( alpha_d ), (res_utd(  6 : 30 : end, : ) )' );
% title( 'Tsingos et al.: UTD total wave field plot (Figure 6a)' );
% legend( num2str( f_plot' ), 'Location', 'southwest' )
% xlabel( 'alpha_d in degree (shadow boundary at 225deg)' );
% ylabel( 'dB SPL' );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% ylim( [-35, 10] );
% grid on;
% 
% subplot( 2, 2, 2 );
% res_btm_inf = att_sum_btm_inf.freqData_dB;
% plot( rad2deg(alpha_d), ( res_btm_inf( 6 : 30 : end, : ) )' );
% title( 'BTM diffraction for infinite wedge' )
% legend( num2str( f_plot' ), 'Location', 'southwest' )
% xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
% ylabel( 'dB SPL' )
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;
% 
% subplot( 2, 2, 3 );
% res_btm_fin = att_sum_btm_fin.freqData_dB;
% plot( rad2deg(alpha_d), ( res_btm_fin( 6 : 30 : end, : ) )' );
% title( 'BTM diffraction for finite wedge' );
% legend( num2str( f_plot' ), 'Location', 'southwest' );
% xlabel( 'alpha_d in degree (shadow boundary at 225deg)' );
% ylabel( 'dB SPL' );
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;
% 
% subplot( 2, 2, 4 );
% res_deviation = att_deviation.freqData_dB;
% plot( rad2deg(alpha_d), ( res_deviation( 6 : 30 : end, : ) )' );
% title( 'Deviation between UTD and BTM' )
% legend( num2str( f_plot' ), 'Location', 'southwest' )
% xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
% ylabel( 'dB SPL' )
% ylim( [-35, 10] );
% xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% grid on;

%% plots for thesis
f_plot = att_sum_btm_fin1.freqVector( 6 : 50 : end );
str_hz = repmat( ' Hz', numel( f_plot ), 1 );
res_btm_fin_approx = att_sum_btm_fin2.freqData_dB;
res_btm_fin = att_sum_btm_fin1.freqData_dB;

figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );

subplot( 2, 2, 1 );

plot( rad2deg(alpha_d), ( res_btm_fin_approx( 6 : 50 : end, : ) )' );
title( 'BTMS' );
legend( [num2str( round( f_plot' ) ), str_hz], 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;

subplot( 2, 2, 2 );

plot( rad2deg(alpha_d), ( res_btm_fin( 6 : 50 : end, : ) )' );
title( 'BTMS with approx' );
legend( [num2str( round( f_plot' ) ), str_hz], 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;



% % subplot( 2, 2, 4 );
% % plot( rad2deg(alpha_d), att_sum_svensson.freqData_dB );
% % title( 'BTM diffraction with svensson implementation' )
% % % legend( num2str( f_plot' ), 'Location', 'southwest' )
% % xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
% % ylabel( 'dB SPL' )
% % % ylim( [-35, 10] );
% % xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
% % grid on;
