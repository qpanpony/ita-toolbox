%% Config
n1 = [1  1  0];
n2 = [-1  1  0];
loc = [0 0 2];
src = 5/sqrt(1) * [-1  0  0];
rcv_start_pos = 5/sqrt(2) * [ 1  1  0];
len = 15;
w = itaFiniteWedge(n1 / norm( n1 ), n2 / norm( n2 ), loc, len);
apex_point = w.get_aperture_point(src, rcv_start_pos);
apex_dir = w.aperture_direction;
delta = 0.05;
c = 344; % Speed of sound

freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000];
alpha_d = linspace( pi, 3 * pi / 2, 500 );

% Set different receiver positions rotated around the aperture
rcv_positions = zeros(numel(alpha_d), 3);
rcv_positions(1, :) = rcv_start_pos;

% Coordinate transformation
n3 = apex_dir;
n2 = w.main_face_normal;
n1 = cross( n2, n3 );

rho = norm( rcv_start_pos - apex_point );
z = rcv_start_pos(3);

rcv_pos_cylindrical = zeros(numel(alpha_d), 3);
for i = 1 : numel(alpha_d)
    rcv_pos_cylindrical(i, :) = [rho, alpha_d(i), z];
end

for j = 2 : numel(rcv_positions(:, 1))
    rcv_positions(j, 1) = rcv_pos_cylindrical(j, 1) * cos( pi*5/4 - rcv_pos_cylindrical(j, 2) );
    rcv_positions(j, 2) = rcv_pos_cylindrical(j, 1) * sin( pi*5/4 - rcv_pos_cylindrical(j, 2) );
    rcv_positions(j, 3) = - rcv_pos_cylindrical(j, 3);
end

%% Calculations
att_sum = itaAudio;
k = 2 * pi * freq ./ c;

% BTM total wave field
for j = 1 : numel(rcv_positions(:, 1))
    r_dir = norm( rcv_positions(j, :) - src );
    E_dir = ( 1 / r_dir * exp( -1i .* k * r_dir ) )';
    att = ita_diffraction_btm_finite_wedge(w, src, rcv_positions(j, :),  );
    % adding part of the incidence field if receiver not shadowed by wedge
    if ~ita_diffraction_shadow_zone(w, src, rcv_positions(j, :))
        att.freqData = ( att.freqData + E_dir );
    end
    att.freqData = att.freqData ./ E_dir;
    att_sum = ita_merge( att_sum, att );
end