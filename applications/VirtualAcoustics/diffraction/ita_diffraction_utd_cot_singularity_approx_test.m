% Config
n1 = [-1 1 0];
n2 = [1 1 0];
loc = [0 0 0];
wedge = itaInfiniteWedge(n1, n2, loc);
source_pos = [-1 0 0];
receiver_pos = [1 -0.0001 0];
frequency_vec = ita_ANSI_center_frequencies;

% Variables
apex_point = wedge.get_aperture_point( source_pos, receiver_pos );
apex_dir = wedge.aperture_direction;
source_apex_direction = ( apex_point - source_pos ) / norm( apex_point - source_pos );
rho = norm( apex_point - source_pos ); % Distance of source to aperture point
r = norm( receiver_pos - apex_point ); % Distance of receiver to aperture point
attenuation = itaResult;
attenuation.freqVector = frequency_vec;
attenuation.freqData = ones( numel( frequency_vec ), 1 );
c = 344; % Speed of Sound

if size( frequency_vec, 1 ) ~= 1 && size( frequency_vec, 2 ) ~= 1
    error( 'Invalid frequency vector' );
end

% Coordinate transformation with aperture point as origin
z = apex_dir;
y = wedge.main_face_normal;
x = cross( y, z ); % direction of main face of the wedge

% Calculate angle between incedent ray from source to aperture point and source facing wedge
% side
u_i = dot( source_pos - apex_point, x );  % coordinates in new coordinate system
v_i = dot( source_pos - apex_point, y );
alpha_i = atan2( v_i, u_i );

if alpha_i < 0
    alpha_i = alpha_i + pi;
end


% Calculate angle between ray from aperture point to receiver and receiver facing wedge
% side
u_d = dot( receiver_pos - apex_point, x );  % coordinates in new coordinate system
v_d = dot( receiver_pos - apex_point, y );
alpha_d = atan2( v_d, u_d );

if alpha_d < 0
    alpha_d = alpha_d + 2*pi;
end

% Angle between incedent ray from source to aperture point and aperture
% direction
theta_i = acos( dot( source_apex_direction, apex_dir ) );
if theta_i > pi/2
    theta_i = pi - theta_i;
end

n = wedge.opening_angle / pi; % Variable dependend on opening angle of the wedge

lambda = c ./ frequency_vec; % Wavelength
k = (2 * pi) ./ lambda; % Wavenumber


% Diffraction coefficient D
assert( rho + r ~= 0 )
A = sqrt( rho / ( r * ( rho + r ) ) );
L = rho * r / ( rho + r ) * ( sin( theta_i ) )^2;

D_factor = -exp( -1i * pi / 4 ) ./ ( 2 * n * sqrt( 2* pi * k ) * sin( theta_i ) );

cot1 = cot( ( pi + ( alpha_d - alpha_i ) ) ./ ( 2 * n ) );
cot2 = cot( ( pi - ( alpha_d - alpha_i ) ) ./ ( 2 * n ) );
cot3 = cot( ( pi + ( alpha_d + alpha_i ) ) ./ ( 2 * n ) );
cot4 = cot( ( pi - ( alpha_d + alpha_i ) ) ./ ( 2 * n ) );

a1 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
a2 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
a3 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;
a4 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;

F1 = ita_diffraction_kawai_approx_fresnel( k * L * a1 );
F2 = ita_diffraction_kawai_approx_fresnel( k * L * a2 );
F3 = ita_diffraction_kawai_approx_fresnel( k * L * a3 );
F4 = ita_diffraction_kawai_approx_fresnel( k * L * a4 );


%%% ------ approximation ------ %%%
eps1 =   ( alpha_d - alpha_i ) - 2 * pi * n * N_p( n, alpha_d - alpha_i ) + pi;
eps2 = - ( alpha_d - alpha_i ) + 2 * pi * n * N_n( n, alpha_d - alpha_i ) + pi;
eps3 =   ( alpha_d + alpha_i ) - 2 * pi * n * N_p( n, alpha_d + alpha_i ) + pi;
eps4 = - ( alpha_d + alpha_i ) + 2 * pi * n * N_n( n, alpha_d + alpha_i ) + pi;

approx1 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k * L) * sgn( eps1 ) - 2 .* k * L * eps1 * exp( 1i * pi/4 ) );
approx2 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k * L) * sgn( eps2 ) - 2 .* k * L * eps2 * exp( 1i * pi/4 ) );
approx3 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k * L) * sgn( eps3 ) - 2 .* k * L * eps3 * exp( 1i * pi/4 ) );
approx4 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k * L) * sgn( eps4 ) - 2 .* k * L * eps4 * exp( 1i * pi/4 ) );
%%% --------------------------- %%%

%%% ------- Test Plots ------- %%%
term1 = cot1 .* F1;
term2 = cot2 .* F2;
term3 = cot3 .* F3;
term4 = cot4 .* F4;


plot_data = [term2; approx2];
loglog( frequency_vec, abs(plot_data) );
legend('summand', 'approx', 'location', 'south' );
%%% -------------------------- %%%


D = D_factor .* ( cot1 .* F1 + cot2 .* F2 + cot3 .* F3 + cot4 .* F4 );


% Combined diffracted sound field propagation filter at receiver
attenuation.freqData = ( D .* A .* exp( -1i * k * r ) )';



%% Auxiliary functions

% N+ function
function N = N_p( n, beta )
    N = 0;
    if beta > pi * ( 1 - n )
        N = 1;
    end
end

% N- function
function N = N_n( n, beta )
    N = 0;
    if beta < pi * ( 1 - n )
        N = -1;
    elseif beta > pi * ( 1 + n )
        N = 1;
    end
end

% signum function
function res = sgn(x)
    if x > 0
        res = 1;
    else
        res = -1;
    end
end