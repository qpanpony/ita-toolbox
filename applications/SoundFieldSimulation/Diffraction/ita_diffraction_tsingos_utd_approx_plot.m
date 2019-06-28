%% Config
n1 = [-1 1 0];
n2 = [1 1 0];
loc = [0 0 2];
src = 3 * [-1 0 0];
rcv = 3 * [1/sqrt(2) 1/sqrt(2) 0];
w = itaInfiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc);
apex_point = w.get_aperture_point(src, rcv);
apex_dir = w.aperture_direction;
c = 344; % Speed of sound

freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000];
alpha_d = linspace( pi, 3 * pi / 2, 500 );

% Set different receiver positions rotated around the aperture
rcv_positions = zeros(numel(alpha_d), 3);
rcv_positions(1, :) = rcv;

% Coordinate transformation
n3 = apex_dir;
n2 = w.main_face_normal;
n1 = cross( n2, n3 );

rho = norm( rcv - apex_point );
z = rcv(3);

rcv_pos_cylindrical = zeros(numel(alpha_d), 3);
for i = 1 : numel(alpha_d)
    rcv_pos_cylindrical(i, :) = [rho, alpha_d(i), z];
end

for j = 2 : numel(rcv_positions(:, 1))
    rcv_positions(j, 1) = rcv_pos_cylindrical(j, 1) * cos( pi*5/4 - rcv_pos_cylindrical(j, 2) );
    rcv_positions(j, 2) = rcv_pos_cylindrical(j, 1) * sin( pi*5/4 - rcv_pos_cylindrical(j, 2) );
    rcv_positions(j, 3) = - rcv_pos_cylindrical(j, 3);
end

%% Calculation
att_sum = itaResult;
k = 2 * pi * freq ./ c;

for j = 1 : numel(rcv_positions(:, 1))
    r_dir = norm( rcv_positions(j, :) - src );
    E_dir = 1 / r_dir * exp( -1i .* k * r_dir );
    if ~ita_diffraction_shadow_zone( w, src, rcv_positions(j, :) )
        E_approx = itaResult;
        E_approx.freqVector = freq;
        E_approx.freqData = ones( numel( freq ), 1 );
    else
        E_approx = ita_diffraction_utd_approx(w, src, rcv_positions(j, :), freq ) ./ E_dir;
    end
    att_sum = ita_merge( att_sum, E_approx );
end


%% Tsingos paper plot
figure
plot( rad2deg( alpha_d ), att_sum.freqData_dB' )
title( 'Tsingos et al.: UTD total wave field plot (Figure 6b)' )
legend( num2str( freq' ) )
xlabel( 'alpha_d in degree (shadow boundary at 225deg)' )
ylabel( 'dB SPL' )
ylim( [-35, 10] );
grid on;