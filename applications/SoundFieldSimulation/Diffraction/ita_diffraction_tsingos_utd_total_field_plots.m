%% Config
n1 = [1  1  0];
n2 = [-1  1  0];
loc = [0 0 2];
src = 5/sqrt(1) * [-1  0  0];
rcv_start_pos = 3/sqrt(2) * [ -1  -1  0];
w = itaInfiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc);
apex_point = w.get_aperture_point(src, rcv_start_pos);
apex_dir = w.aperture_direction;
delta = 0.05;
c = 344; % Speed of sound

freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000];
ref_face = w.point_facing_main_side( src );
alpha_d = linspace( w.get_angle_from_point_to_wedge_face(rcv_start_pos, ref_face), w.opening_angle, 1200 );

% Set different receiver positions rotated around the aperture
rcv_positions = ita_align_points_around_aperture( w, rcv_start_pos, alpha_d, apex_point, ref_face );

%% Calculations

att_sum_all = itaAudio();

N = size( rcv_positions, 1 );
for n = 1 : N
    
    rcv_position = rcv_positions( n, 1:3 );
    
    k = 2 * pi * freq ./ c;
    R_dir = repmat( sqrt( sum( ( rcv_position  - src ).^2, 2 ) ), 1, numel(freq) );
    E_dir = 1 ./ R_dir .* exp( -1i .* k .* R_dir );

    in_shadow_zone = ita_diffraction_shadow_zone( w, src, rcv_position );

    % UTD total wave field
    att_sum = itaResult;
    att_sum.freqVector = freq;
    att_sum.freqData = ita_diffraction_utd( w, src, rcv_position, freq', c );
    att_sum.freqData( :, ~in_shadow_zone' ) = att_sum.freqData( :, ~in_shadow_zone' ) + ( E_dir( ~in_shadow_zone, : ) )';
    att_sum.freqData = att_sum.freqData ./ E_dir';
    
    % UTD combined with Approximation by Tsingos et. al.
    att_sum_approx = itaResult;
    att_sum_approx.freqVector = freq;
    att_sum_approx.freqData = ita_diffraction_utd_approximated( w, src, rcv_position, freq, c );
    att_sum_approx.freqData( :, ~in_shadow_zone' ) = att_sum_approx.freqData( :, ~in_shadow_zone' ) + ( E_dir( ~in_shadow_zone, : ) )';
    att_sum_approx.freqData = att_sum_approx.freqData ./ E_dir';

    % Error caused by approximation
    att_sum_error = itaResult;
    att_sum_error.freqVector = freq;
    att_sum_error.freqData = att_sum_approx.freqData ./ att_sum.freqData;

    att_sum_diffr = itaResult;
    att_sum_diffr.freqVector = freq;
    att_sum_diffr.freqData = ita_diffraction_utd( w, src, rcv_position, freq, c );
    att_sum_diffr.freqData = att_sum_diffr.freqData ./ E_dir';
    
    if n == 1
        att_sum_all = att_sum;
        att_sum_approx_all = att_sum_approx;
        att_sum_error_all = att_sum_error;
        att_sum_diffr_all = att_sum_diffr;
    else
        att_sum_all = ita_merge( att_sum_all, att_sum );
        att_sum_approx_all = ita_merge( att_sum_approx_all, att_sum_approx );
        att_sum_error_all = ita_merge( att_sum_error_all, att_sum_error );
        att_sum_diffr_all = ita_merge( att_sum_diffr_all, att_sum_diffr );
    end
    
end

%% Tsingos paper plot
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
subplot( 2, 2, 1 );
plot( rad2deg( alpha_d ), att_sum_all.freqData_dB' )
title( 'total wave field with UTD' )
legend( num2str( freq' ), 'Location', 'southwest' )
xlabel( 'theta_R in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
xlim( [alpha_d(1), w.opening_angle_deg] );
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 2 );
plot( rad2deg( alpha_d ), att_sum_approx_all.freqData_dB' )
title( 'Tsingos et al.: UTD total wave field plot with Approximation (Figure 6b)' )
legend( num2str( freq' ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
xlim( [alpha_d(1), w.opening_angle_deg] );
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 3 );
plot( rad2deg( alpha_d ), att_sum_error_all.freqData_dB' )
title( 'Tsingos et al.: Error by approximation (Figure 6c)' )
legend( num2str( freq' ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
xlim( [alpha_d(1), w.opening_angle_deg] );
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 4 );
plot( rad2deg( alpha_d ), att_sum_diffr_all.freqData_dB' )
title( 'Diffracted field by UTD' )
legend( [num2str( freq' ), repmat(' Hz', numel(freq),1)], 'Location', 'southeast' )
xlabel( 'theta_R [°]' )
ylabel( 'dB SPL' )
xlim( [alpha_d(1), w.opening_angle_deg] );
grid on;
