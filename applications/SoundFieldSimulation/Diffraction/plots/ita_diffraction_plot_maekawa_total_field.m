%% Config
% simple Screen
n1Screen = [1, 0, 0];
apex_dir = [0, 0, 1];
infScreen = itaSemiInfinitePlane(n1Screen, loc, apex_dir);

% Source and receiver setup
src_pos = 15/sqrt(1) * [-1  0  0];
rcv_start_pos = 15/sqrt(2) * [ 1, 1, 0 ];
rcv_end_pos = 15/sqrt(2) * [ 1, -1, 0 ];

% Set receiver positions alligned around the aperture
apex_point = infScreen.approx_aperture_point(src_pos, rcv_start_pos);
src_is_facing_main_face = infScreen.point_facing_main_side( src_pos );
alpha_start = infScreen.get_angle_from_point_to_wedge_face(rcv_start_pos, src_is_facing_main_face);
alpha_end = infScreen.get_angle_from_point_to_wedge_face(rcv_end_pos, src_is_facing_main_face);
alpha_res = 200;
alpha_d = linspace( alpha_start, alpha_end, alpha_res );

rcv_positions = ita_diffraction_align_points_around_aperture( infScreen, rcv_start_pos, alpha_d, apex_point, src_is_facing_main_face );
rcv_in_shadow_zone = zeros(size(rcv_positions, 1), 1);
for i = 1:size(rcv_positions, 1)
    rcv_in_shadow_zone(i) = ita_diffraction_shadow_zone( infScreen, src_pos, rcv_positions(i, :) );
end

% Params
freq = ita_ANSI_center_frequencies';
speed_of_sound = 344; % Speed of sound
transitionConstant = 0.1; % for smoothening approximations


%% Calculations
resData = itaAudio();

resMaekawa = resData;
resMaekawa_approx = resData;
tempData = resData;

k = 2* pi * freq / speed_of_sound;
% diffraction using maekawa model
for i = 1:size(rcv_positions, 1)
    r_dir = norm( rcv_positions(i, :) - src_pos );
    direct_field_component = 1 / r_dir .* exp( -1i * k .* r_dir );
    tempData.freqData = ita_diffraction_maekawa(infScreen, src_pos, rcv_positions(i, :), freq, speed_of_sound);
    if ~rcv_in_shadow_zone(i)
        tempData.freqData = tempData.freqData + direct_field_component;
    end
    tempData.freqData = tempData.freqData ./ direct_field_component;
    if i == 1
        resMaekawa.freqData = tempData.freqData;
    else
        resMaekawa = ita_merge(resMaekawa, tempData);
    end    
end

% diffraction using maekawa model with smoothening approximation
for i = 1:size(rcv_positions, 1)
    r_dir = norm( rcv_positions(i, :) - src_pos );
    direct_field_component = 1 / r_dir .* exp( -1i * k .* r_dir );
    tempData.freqData = ita_diffraction_maekawa_approx(infScreen, src_pos, rcv_positions(i, :), freq, speed_of_sound, transitionConstant);
    if ~rcv_in_shadow_zone(i)
        tempData.freqData = tempData.freqData + direct_field_component;
    end
    tempData.freqData = tempData.freqData ./ direct_field_component;
    if i == 1
        resMaekawa_approx.freqData = tempData.freqData;
    else
        resMaekawa_approx = ita_merge(resMaekawa_approx, tempData);
    end
end


%% Plot
str_freqs = repmat( ' Hz', numel( freq(1:2:end) ), 1 );
legend_freqs = [num2str( round( freq(1:2:end) ) ), str_freqs];

resPlotMaekawa = resMaekawa.freqData_dB;
resPlotMaekawa_approx = resMaekawa_approx.freqData_dB;

figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
subplot( 2, 1, 1 );
plot( rad2deg(alpha_d), resPlotMaekawa(1:2:end, :) );
title( 'Maekawa diffraction for various receiver positions' );
legend( legend_freqs, 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(end)), rad2deg(alpha_d(1))] );
grid on

subplot( 2, 1, 2 );
plot( rad2deg(alpha_d), resPlotMaekawa_approx(1:2:end, :) );
title( 'Maekawa approx diffraction for various receiver positions' );
legend( legend_freqs, 'Location', 'southwest' );
xlabel( 'theta_R [°]' );
ylabel( 'p_{total} [dB]' );
ylim( [-35, 10] );
xlim( [rad2deg(alpha_d(end)), rad2deg(alpha_d(1))] );
grid on


