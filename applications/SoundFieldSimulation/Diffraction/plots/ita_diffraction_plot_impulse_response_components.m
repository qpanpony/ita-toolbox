%% Config
n1 = [1  1  0];
n2 = [-1  1  0];
loc = [0 0 -3];
len = 8;
src = 0.2/sqrt(1) * [-1  0  0];
rcv_start_pos = 1/sqrt(2) * [ -1, -1,  0];
infw = itaInfiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc);
finw = itaFiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc, len);
apex_dir = infw.aperture_direction;
apex_point = infw.get_aperture_point(src, rcv_start_pos);
delta = 0.05;
speed_of_sound = 343.21;

f_sampling = 384000;
filter_length = 1024;
angle_resolution = 2000;

%% Calculations
ref_face = infw.point_facing_main_side( src );
alpha_d = linspace( infw.get_angle_from_point_to_wedge_face(rcv_start_pos, ref_face), infw.opening_angle, angle_resolution );
rcv_positions = ita_diffraction_align_points_around_aperture( infw, rcv_start_pos, alpha_d, apex_point, ref_face );

h1_0 = zeros( 1, numel(alpha_d) );
h2_0 = zeros( 1, numel(alpha_d) );
h3_0 = zeros( 1, numel(alpha_d) );
h4_0 = zeros( 1, numel(alpha_d) );
R_0 = norm( src ) + norm( rcv_start_pos );

for j = 1 : numel( alpha_d )
    H = ita_diffraction_btms( finw, src, rcv_positions( j, : ), f_sampling, filter_length, speed_of_sound );
    h1_0(j) = H(  1 );
    h2_0(j) = H(  2 );
    h3_0(j) = H(  3 );
    h4_0(j) = H(  4 );
end


%% Plots
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );

subplot( 2, 2, 1 );
plot( rad2deg( alpha_d(2:end) ), h1_0(2:end) .* R_0 );
title( 'h1(n_0)' );
xlabel( 'theta_R in degree' );
ylabel( 'h1(n_0) rel. 1/R_0' );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;

subplot( 2, 2, 2 );
plot( rad2deg( alpha_d(2:end) ), h2_0(2:end) .* R_0 );
title( 'h2(n_0)' );
xlabel( 'theta_R in degree' );
xlabel( 'theta_R in degree' )
ylabel( 'h2(n_0) rel. 1/R_0' );
ylim( [-0.6, 0.6] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;

subplot( 2, 2, 3 );
plot( rad2deg( alpha_d(2:end) ), h3_0(2:end) .* R_0 );
title( 'h3(n_0)' );
xlabel( 'theta_R in degree' );
ylabel( 'h3(n_0) rel. 1/R_0' );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;

subplot( 2, 2, 4 );
plot( rad2deg( alpha_d(2:end) ), h4_0(2:end) .* R_0 );
title( 'h4(n_0)' );
xlabel( 'theta_R in degree' );
ylabel( 'h4(n_0) rel. 1/R_0' );
ylim( [-0.6, 0.6] );
xlim( [rad2deg(alpha_d(1)), rad2deg(alpha_d(end))] );
grid on;