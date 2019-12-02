% Config
n1 = [-1 1 0];
n2 = [1 1 0];
loc = [0 0 2];
src = [-1 0 0];
rcv = [1 1 0];

w = itaInfiniteWedge(n1, n2, loc);
apex_point = w.approx_aperture_point(src, rcv);
apex_dir = w.aperture_direction;

% freq = [100, 200, 400, 800, 1600, 3200, 6400, 12800, 24000];
freq = 2000;

delta = 0.01;
alpha_d = (5/4 * pi) - 2/8 * pi : delta : (5/4 * pi) + 2/8 * pi;
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
for j = 1 : numel(alpha_d)
    rcv_pos_cylindrical(j, :) = [rho, alpha_d(j), z];
end

for j = 2 : numel(rcv_positions(:, 1))
    rcv_positions(j, 1) = rcv_pos_cylindrical(j, 1) * cos( pi*5/4 - rcv_pos_cylindrical(j, 2) );
    rcv_positions(j, 2) = rcv_pos_cylindrical(j, 1) * sin( pi*5/4 - rcv_pos_cylindrical(j, 2) );
    rcv_positions(j, 3) = - rcv_pos_cylindrical(j, 3);
end


%% Variables
source_apex_direction = ( apex_point - src ) / norm( apex_point - src );
rho = norm( apex_point - src ); % Distance of source to aperture point
r = norm( rcv - apex_point ); % Distance of receiver to aperture point

c = 344; % Speed of Sound

% Coordinate transformation with aperture point as origin
z = apex_dir;
y = w.main_face_normal;
x = cross( y, z ); % direction of main face of the wedge

% Calculate angle between incedent ray from source to aperture point and source facing wedge
% side
u_i = dot( src - apex_point, x );  % coordinates in new coordinate system
v_i = dot( src - apex_point, y );
alpha_i = atan2( v_i, u_i );

if alpha_i < 0
    alpha_i = alpha_i + pi;
end


% Angle between incedent ray from source to aperture point and aperture
% direction
theta_i = acos( dot( source_apex_direction, apex_dir ) );
if theta_i > pi/2
    theta_i = pi - theta_i;
end

n = w.opening_angle / pi; % Variable dependend on opening angle of the wedge

lambda = c ./ freq; % Wavelength
k = (2 * pi) ./ lambda; % Wavenumber

%% Diffraction Coefficient
A = sqrt( rho / ( r * (rho + r) ) );
L = (rho * r) / (rho + r) * (sin( theta_i ))^2;

epsilon = zeros( 1, numel(alpha_d) );
data_1 = zeros( 2, numel( rcv_positions( :, 1 ) ) );
data_2 = zeros( 2, numel( rcv_positions( :, 1 ) ) );
data_3 = zeros( 2, numel( rcv_positions( :, 1 ) ) );
small = 0.14;

for j = 1 : numel(epsilon)
    D1_1 = cot( (pi + (alpha_d(j) - alpha_i)) ./ (2 * n) ) * F( k * L * a_plus(alpha_d(j) - alpha_i, n) );
    magn_1 = zeros(1, numel(D1_1));
    for n = 1 : numel(magn_1)
        magn_1(n) = 20 * log10( norm( D1_1(n) ) );
    end
    D1_2 = n * exp( 1i * pi/4 ) * ... 
           ( sqrt( 2 * pi .* k * L) * sgn( eps_plus(alpha_d(j) - alpha_i, n) ) - ...
           2 .* k * L * eps_plus(alpha_d(j) - alpha_i, n) * exp( 1i * pi/4 ) );
    magn_2 = zeros(1, numel(D1_2));
    for m = 1 : numel(magn_2)
        magn_2(m) = 20 * log10( norm( D1_2(m) ) );
    end
    data_1(1, j) = magn_1;
    data_1(2, j) = magn_2;
    epsilon(j) = (alpha_d(j) - alpha_i) - 2 * pi * n * N_plus(alpha_d(j) - alpha_i, n) + pi;
end

for i = 1 : numel(epsilon)
    if norm(epsilon(i)) < small
        data_3(1, i) = data_1(2, i);
    else
        data_3(1, i) = data_1(1, i);
    end
end

figure()
yyaxis left
plot( epsilon, data_1 );
ylabel( 'magnitude in dB' );
yyaxis right
plot( epsilon, alpha_d .* (360 / (2*pi)) );
ylabel( 'alpha_d(°)' );

xlabel( 'eps' );
legend( 'cot...', 'sqrt...', 'alpha_d' );
hold on
plot(epsilon, data_3(1, :));

for j = 1 : numel(epsilon)
    D2_1 = cot( (pi - (alpha_d(j) - alpha_i)) ./ (2 * n) ) * F( k * L * a_minus(alpha_d(j) - alpha_i, n) );
    magn_1 = zeros(1, numel(D2_1));
    for n = 1 : numel(magn_1)
        magn_1(n) = 20 * log10( norm( D2_1(n) ) );
    end
    D2_2 = n * exp( 1i * pi/4 ) * ... 
             ( sqrt( 2 * pi .* k * L) * sgn( eps_minus(alpha_d(j) - alpha_i, n) ) - ...
             2 .* k * L * eps_minus(alpha_d(j) - alpha_i, n) * exp( 1i * pi/4 ) );
    magn_2 = zeros(1, numel(D2_2));
    for m = 1 : numel(magn_2)
        magn_2(m) = 20 * log10( norm( D2_2(m) ) );
    end
    data_2(1, j) = magn_1;
    data_2(2, j) = magn_2;
    epsilon(j) = 2 * pi * n * N_minus(alpha_d(j) - alpha_i, n) + pi - (alpha_d(j) - alpha_i);
end

for i = 1 : numel(epsilon)
    if norm(epsilon(i)) < small
        data_3(2, i) = data_2(2, i);
    else
        data_3(2, i) = data_2(1, i);
    end
end

figure();
yyaxis left
plot( epsilon, cot( (pi - (2*pi*n*N_minus(alpha_d(j) - alpha_i, n) + pi - epsilon))/(2*n) ) );

yyaxis left
plot( epsilon, data_2 );
ylabel( 'magnitude in dB' );
yyaxis right
plot( epsilon, alpha_d .* (360 / (2*pi)) );
ylabel( 'alpha_d(°)' );

xlabel( 'eps' );
legend( 'cot...', 'sqrt...', 'alpha_d' );
hold on
plot(epsilon, data_3(2, :));


%% Auxiliary Functions

function res = a_plus( beta , n)
    N = N_plus( beta, n );
    res = 2 * ( cos( ( 2 * pi * n * N - beta ) / 2 ) ) ^ 2;
end

function res = a_minus( beta, n )
    N = N_minus(beta, n);
    res = 2 * ( cos( ( 2 * pi * n * N - beta ) / 2 ) ) ^ 2;
end

% Transition function with Kawai approximation
function out = F( X )
    out = zeros( 1, numel( X ) );
    for m = 1 : numel( out )
        if X(m) < 0.8
            out(m) = sqrt( pi * X(m) ) * ( 1 - ( sqrt(X(m)) / ( 0.7 * sqrt(X(m)) * 1.2 ) ) ) * exp( 1i * pi/4 * ( 1 - sqrt( X(m) / ( X(m) + 1.4 ) ) ) );
        else
            out(m) = ( 1 - ( 0.8 / ( X(m) + 1.25 ) .^ 2 ) ) * exp( 1i * pi/4 * ( 1 - sqrt( X(m) / ( X(m) + 1.4 ) ) ) );
        end
    end
end

function res = eps_plus( beta, n )
    N = N_plus( beta, n );
    res = beta - 2 * pi * n * N + pi;
end

function res = eps_minus( beta, n )
    N = N_minus( beta, n );
    res = 2 * pi * n * N + pi - beta;
end

function res = sgn(x)
    if x > 0
        res = 1;
    else
        res = -1;
    end
end

function N = N_plus( beta, n )
    x = (pi + beta) / (2 * pi * n);
    a = floor(x);
    b = floor(x) + 1;
    d_a = norm(x - a);
    d_b = norm(x - b);
    if d_a < d_b
        N = a;
    else
        N = b;
    end
end

function N = N_minus( beta, n )
    x = (beta - pi) / (2 * pi * n);
    a = floor(x);
    b = ceil(x);
    d_a = norm(x - a);
    d_b = norm(x - b);
    if d_a < d_b
        N = a;
    else
        N = b;
    end
end