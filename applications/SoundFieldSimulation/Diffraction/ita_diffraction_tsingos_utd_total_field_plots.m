%% Config
n1 = [1  1  0];
n2 = [-1  1  0];
loc = [0 0 2];
src = 5/sqrt(1) * [-1  0  0];
rcv_start_pos = 3/sqrt(2) * [ -1  -1  0];
inf_wdg = itaInfiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc);
apex_point = inf_wdg.get_aperture_point(src, rcv_start_pos);
apex_dir = inf_wdg.aperture_direction;
delta = 0.05;
c = 344; % Speed of sound

freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000]';
ref_face = inf_wdg.point_facing_main_side( src );
alpha_d = linspace( inf_wdg.get_angle_from_point_to_wedge_face(rcv_start_pos, ref_face), inf_wdg.opening_angle, 1000 );

% Set different receiver positions rotated around the aperture
rcv_positions = ita_align_points_around_aperture( inf_wdg, rcv_start_pos, alpha_d, apex_point, ref_face );
rcv_positions = rcv_positions(2 : end-1, :);

% wavenumber
k = 2 * pi * freq ./ c;

% store results in ita audio format
res_data = itaResult();
res_data.resultType = 'signal';
res_data.freqVector = freq;

%% Calculations

att_sum_all = itaAudio();

N = size( rcv_positions, 1 );
for n = 1 : N
    
    current_rcv_pos = rcv_positions( n, 1:3 );
    
    r_dir = norm( current_rcv_pos  - src );
    dir_field_comp = 1 ./ r_dir .* exp( -1i .* k .* r_dir );

    rcv_in_shadow_zone = ita_diffraction_shadow_zone( inf_wdg, src, current_rcv_pos );

    % UTD total wave field
    att_sum = res_data;
    att_sum.freqData = ita_diffraction_utd( inf_wdg, src, current_rcv_pos, freq, c );
    if ~rcv_in_shadow_zone
        att_sum.freqData = att_sum.freqData + dir_field_comp;
    end
    att_sum.freqData = att_sum.freqData ./ dir_field_comp;
    
    % UTD combined with Approximation by Tsingos et. al.
    att_sum_approx = res_data;
    att_sum_approx.freqData = ita_diffraction_utd_approx( inf_wdg, src, current_rcv_pos, freq, c );
    if ~rcv_in_shadow_zone
        att_sum_approx.freqData = att_sum_approx.freqData + dir_field_comp;
    end
    att_sum_approx.freqData = att_sum_approx.freqData ./ dir_field_comp;

    % Error caused by approximation
    att_sum_error = res_data;
    att_sum_error.freqData = att_sum_approx.freqData ./ att_sum.freqData;

    att_sum_diffr = res_data;
    att_sum_diffr.freqData = ita_diffraction_utd( inf_wdg, src, current_rcv_pos, freq, c );
    att_sum_diffr.freqData = att_sum_diffr.freqData ./ dir_field_comp;
    
    if n == 1
        att_sum_all = att_sum;
        att_sum_approx_all = att_sum_approx;
        att_sum_error_all = att_sum_error;
        att_sum_diffr_only_all = att_sum_diffr;
    else
        att_sum_all = ita_merge( att_sum_all, att_sum );
        att_sum_approx_all = ita_merge( att_sum_approx_all, att_sum_approx );
        att_sum_error_all = ita_merge( att_sum_error_all, att_sum_error );
        att_sum_diffr_only_all = ita_merge( att_sum_diffr_only_all, att_sum_diffr );
    end
    
end

%% Tsingos paper plot
angles = rad2deg( alpha_d(2 : end-1) );
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
subplot( 2, 2, 1 );
plot( angles, att_sum_all.freqData_dB' )
title( 'Total wave field with UTD' )
legend( num2str( freq ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
xlim( [alpha_d(1), inf_wdg.opening_angle_deg] );
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 2 );
plot( angles, att_sum_approx_all.freqData_dB' )
title( 'Tsingos et al.: Total wave field plot with approximated UTD (Figure 6b)' )
legend( num2str( freq ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
xlim( [angles(1), inf_wdg.opening_angle_deg] );
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 3 );
plot( angles, att_sum_error_all.freqData_dB' )
title( 'Tsingos et al.: Error by approximation (Figure 6c)' )
legend( num2str( freq ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
xlim( [angles(1), inf_wdg.opening_angle_deg] );
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 4 );
plot( angles, att_sum_diffr_only_all.freqData_dB' )
title( 'Diffracted field by UTD' )
legend( [num2str( freq ), repmat(' Hz', numel(freq),1)], 'Location', 'southeast' )
xlabel( 'theta_R [°]' )
ylabel( 'dB SPL' )
xlim( [angles(1), inf_wdg.opening_angle_deg] );
grid on;
