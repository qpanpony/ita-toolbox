%% Config
n1 = [  1  1  0 ] / sqrt( 2 );
n2 = [ -1  1  0 ] / sqrt( 2 );
loc = [ 0 0 0 ];
source_pos = 5 * [ -1  0  0] / sqrt( 2 );
receiver_start_pos = 5 * [ -1  -1  0 ] / sqrt( 2 );
w = itaInfiniteWedge( n1, n2, loc );

apex_point = w.get_aperture_point( source_pos, receiver_start_pos );
apex_dir = w.aperture_direction;
%delta = 0.05;
c = 344; % Speed of sound

freq = [ 20, 50, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000 ]';

num_angles = 1000;
alpha_d_start = w.opening_angle;
alpha_d_end = 0;
alpha_d = linspace( alpha_d_start, alpha_d_end, num_angles );

% Set different receiver positions rotated around the aperture
recevier_positions = norm( receiver_start_pos ) * [ cos( alpha_d - pi/4 ); sin( alpha_d - pi/4 ); zeros( 1, numel( alpha_d ) ) ]';

% wavenumber
k = 2 * pi * freq ./ c;

% store results in ita audio format
res_data_template = itaResult();
res_data_template.resultType = 'signal';
res_data_template.freqVector = freq;

%% Calculations

N = size( recevier_positions, 1 );
for n = 1 : N
    
    receiver_pos = recevier_positions( n, 1:3 );
    
    r_dir = norm( receiver_pos  - source_pos );
    H_direct_field = 1 ./ r_dir .* exp( -1i .* k .* r_dir );

    rcv_in_shadow_zone = ita_diffraction_shadow_zone( w, source_pos, receiver_pos );

    % UTD total wave field
    H_diffracted_field = ita_diffraction_utd( w, source_pos, receiver_pos, freq, c );
    if rcv_in_shadow_zone
        H_total_field = H_diffracted_field;
    else
        H_total_field = H_diffracted_field + H_direct_field;
    end
    
    att_sum = res_data_template;
    att_sum.freqData = H_total_field ./ H_direct_field; % Insertion loss
    
    % UTD total wave field with approximation by Tsingos et. al.
    [ H_diffracted_field_approx ] = ita_diffraction_utd_approx( w, source_pos, receiver_pos, freq, c );
    if rcv_in_shadow_zone
        H_total_field_approx = H_diffracted_field_approx;
    else
        H_total_field_approx = H_diffracted_field_approx + H_direct_field;
    end
    
    att_sum_approx = res_data_template;
    att_sum_approx.freqData = H_total_field_approx ./ H_direct_field;

    % Error caused by approximation
    att_sum_error = att_sum_approx / att_sum;
    %att_sum_error.freqData = att_sum_approx.freqData ./ att_sum.freqData;

    att_sum_diffr = res_data_template;
    att_sum_diffr.freqData = ita_diffraction_utd( w, source_pos, receiver_pos, freq, c );
    att_sum_diffr.freqData = att_sum_diffr.freqData ./ H_direct_field;
    
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
angles = rad2deg( linspace( alpha_d( end ), alpha_d( 1 ), numel( alpha_d ) ) ); % Reverse angle on axis
figure( 'units', 'normalized', 'outerposition', [0 0 1 1] );
subplot( 2, 2, 1 );
plot( angles, att_sum_all.freqData_dB' )
title( 'Total wave field with UTD' )
legend( num2str( freq ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 2 );
plot( angles, att_sum_approx_all.freqData_dB' )
title( 'Tsingos et al.: Total wave field plot with approximated UTD (Figure 6b)' )
legend( num2str( freq ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 3 );
plot( angles, att_sum_error_all.freqData_dB' )
title( 'Tsingos et al.: Error by approximation (Figure 6c)' )
legend( num2str( freq ), 'Location', 'southwest' )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
ylim( [-35, 10] );
grid on;

subplot( 2, 2, 4 );
plot( angles, att_sum_diffr_only_all.freqData_dB' )
title( 'Diffracted field by UTD' )
legend( [num2str( freq ), repmat(' Hz', numel(freq),1)], 'Location', 'southeast' )
xlabel( 'theta_R [°]' )
ylabel( 'dB SPL' )
grid on;
