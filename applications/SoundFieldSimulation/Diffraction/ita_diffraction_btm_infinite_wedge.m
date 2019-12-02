function att_ir = ita_diffraction_btm_infinite_wedge( wedge, source_pos, receiver_pos, sampling_rate, filter_length_samples, boundary_condition )
%ITA_DIFFRATION_BIOT_TOLSTOY Summary of this function goes here
%   Detailed explanation goes here

%% Assertions
if nargin < 4
    sampling_rate = 44100;
end
if nargin < 5
    filter_length_samples = 1024;
end
if nargin < 6
    boundary_condition = 'hard';
end
if ~( isequal(boundary_condition, 'hard') || isequal(boundary_condition, 'soft') )
    error('invalid boundary condition. Use hard or soft.');
end
if ~isa(wedge, 'itaInfiniteWedge')
    error('Invalid wedge input. use itaInfiniteWedge.')
end


%% Variables
A = wedge.get_aperture_point( source_pos, receiver_pos );
ref_face = wedge.point_facing_main_side( source_pos );
theta_S = wedge.get_angle_from_point_to_wedge_face( source_pos, ref_face );
theta_R = wedge.get_angle_from_point_to_wedge_face( receiver_pos, ref_face );
theta_i = wedge.get_angle_from_point_to_aperture( source_pos, A );
theta_w = wedge.opening_angle;
SA = norm( A - S );
AR = norm( R - A );
r_S = SA .* sin(theta_i);
r_R = AR .* sin(theta_i);
z_R = (SA + AR) .* cos(theta_i);
ny = pi / theta_w;
L_0 = sqrt( (r_S + r_R).^2 + z_R.^2 );
c = 343.21; % Speed of sound at 20°C

T = 1 / sampling_rate;
tau_0 = min( L_0 ) / c;
tau = ( tau_0 + T ) : T : ( tau_0 + T * (filter_length_samples) );

%% Calculation
eta = acosh( ( (c .* tau).^2 - (r_S.^2 + r_R.^2 + z_R.^2) ) ./ ( 2 * r_S .* r_R ) );

phi1 = pi + theta_S + theta_R;
phi2 = pi + theta_S - theta_R;
phi3 = pi - theta_S + theta_R;
phi4 = pi - theta_S - theta_R;

beta_pp = sin( ny * phi1 ) ./ ( cosh( ny .* eta ) - cos( ny * phi1 ) );
beta_pm = sin( ny * phi2 ) ./ ( cosh( ny .* eta ) - cos( ny * phi2 ) );
beta_mp = sin( ny * phi3 ) ./ ( cosh( ny .* eta ) - cos( ny * phi3 ) );
beta_mm = sin( ny * phi4 ) ./ ( cosh( ny .* eta ) - cos( ny * phi4 ) );

switch boundary_condition
    case 'hard'
        beta = beta_pp + beta_pm + beta_mp + beta_mm;
    case 'soft'
        beta = -beta_pp + beta_pm + beta_mp - beta_mm;
end

att_ir = ( ( -(( c * ny ) / ( 2 * pi )) * beta ) ./ ( r_S .* r_R .* sinh( eta ) ) )' * T;

end
