%% Config
% rectangular wedge
inf_wdg = ita_diffraction_create_standard_rectangular_wedge();

% Source and receiver setup
src_pos = 15/sqrt(1) * [-1  0  0];
rcv_start_pos = 15/sqrt(2) * [ 1, 1, 0 ];
rcv_end_pos = 15/sqrt(2) * [ 1, -1, 0 ];
angle_resolution = 200;

% Params
freq = ita_ANSI_center_frequencies';
speed_of_sound = 344;
transition_constant = 0.1; % Smoothening factor

%% Calculations
% Set receiver positions alligned around the aperture
apex_point = inf_wdg.approx_aperture_point(src_pos, rcv_start_pos);
src_is_facing_main_face = inf_wdg.point_facing_main_side( src_pos );
alpha_start = inf_wdg.get_angle_from_point_to_wedge_face(rcv_start_pos, src_is_facing_main_face);
alpha_end = inf_wdg.get_angle_from_point_to_wedge_face(rcv_end_pos, src_is_facing_main_face);
alpha_d = linspace( alpha_start, alpha_end, angle_resolution );

rcv_positions = ita_diffraction_align_points_around_aperture( inf_wdg, rcv_start_pos, alpha_d, apex_point, src_is_facing_main_face );
rcv_in_shadow_zone = zeros(size(rcv_positions, 1), 1);
for i = 1:size(rcv_positions, 1)
    rcv_in_shadow_zone(i) = ita_diffraction_shadow_zone( inf_wdg, src_pos, rcv_positions(i, :) );
end

wave_number = 2* pi * freq / speed_of_sound;

resData = itaResult();
resData.freqVector = freq;

res_total_field = resData;
res_diffr_only = resData;
tempData = resData;

% total field with diffraction using UTD
for i = 1:size(rcv_positions, 1)
    r_dir = norm( rcv_positions(i, :) - src_pos );
    direct_field_component = 1 / r_dir .* exp( -1i * wave_number .* r_dir );
    tempData.freqData = ita_diffraction_utd_approx( inf_wdg, src_pos, rcv_positions(i, :), freq, speed_of_sound, transition_constant );
    if ~rcv_in_shadow_zone(i)
        tempData.freqData = tempData.freqData + direct_field_component;
    end
    tempData.freqData = tempData.freqData ./ direct_field_component;
    if i == 1
        res_total_field.freqData = tempData.freqData;
    else
        res_total_field = ita_merge( res_total_field, tempData );
    end    
end

% diffraction field only using UTD
for i = 1:size(rcv_positions, 1)
    tempData.freqData = ita_diffraction_utd_approx( inf_wdg, src_pos, rcv_positions(i, :), freq, speed_of_sound, transition_constant );
    tempData.freqData = tempData.freqData ./ direct_field_component;
    if i == 1
        res_diffr_only.freqData = tempData.freqData;
    else
        res_diffr_only = ita_merge( res_diffr_only, tempData );
    end
end


%% Plot
str_freqs = repmat( ' Hz', numel( freq(1:2:end) ), 1 );
legend_freqs = [num2str( round( freq(1:2:end) ) ), str_freqs];

res_plot_total_field = res_total_field.freqData_dB;
res_plot_diffr_only = res_diffr_only.freqData_dB;

figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
subplot( 2, 1, 1 );
plot( rad2deg(alpha_d), res_plot_diffr_only(1:2:end, :) );
title( 'UTD diffraction field for various receiver positions' );
legend( legend_freqs, 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(end)), rad2deg(alpha_d(1))] );
grid on

subplot( 2, 1, 2 );
plot( rad2deg(alpha_d), res_plot_total_field(1:2:end, :) );
title( 'UTD total field for various receiver positions' );
legend( legend_freqs, 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(end)), rad2deg(alpha_d(1))] );
grid on
