function att = ita_diffraction_btm_infinite_wedge( wedge, source_pos, receiver_pos, sampling_rate, filter_length_samples, boundary_condition )
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
dim_src = size( source_pos );
dim_rcv = size( receiver_pos );
if dim_src(2) ~= 3
    if sim_src(1) ~= 3
        error( 'Source point(s) must be of dimension 3' )
    end
    source_pos = source_pos';
    dim_src = size( source_pos );
end
if dim_rcv(2) ~= 3
    if dim_rcv(1) ~= 3
        error( 'Reciever point(s) must be of dimension 3' )
    end
    receiver_pos = receiver_pos';
    dim_rcv = size( receiver_pos );
end
if dim_src(1) ~= 1 && dim_rcv(1) ~= 1 && dim_src(1) ~= dim_rcv(1)
    error( 'Number of receiver and source positions do not match' )
end
if dim_src(1) > dim_rcv(1)
    dim_n = dim_src(1);
    S = source_pos;
    R = repmat( receiver_pos, dim_n, 1 );
elseif dim_src(1) < dim_rcv(1)
    dim_n = dim_rcv(1);
    S = repmat( source_pos, dim_n, 1 );
    R = receiver_pos;
else
    dim_n = dim_src(1);
    S = source_pos;
    R = receiver_pos;
end


%% Variables
Apex_Point = wedge.get_aperture_point( S, R );
ref_face = wedge.point_facing_main_side( S );
theta_S = wedge.get_angle_from_point_to_wedge_face( S, ref_face );
theta_R = wedge.get_angle_from_point_to_wedge_face( R, ref_face );
theta_i = wedge.get_angle_from_point_to_aperture( S, Apex_Point );
theta_w = wedge.opening_angle;
SA = Norm( Apex_Point - S );
AR = Norm( R - Apex_Point );
r_S = SA .* sin(theta_i);
r_R = AR .* sin(theta_i);
z_R = (SA + AR) .* cos(theta_i);
ny = pi / theta_w;
L_0 = sqrt( (r_S + r_R).^2 + z_R.^2 );
c = 343.21; % Speed of sound at 20°C

att = itaAudio();
att.signalType = 'energy';
att.samplingRate = sampling_rate;
att.nSamples = filter_length_samples;
T = 1 / sampling_rate;
tau_0 = min( L_0 ) / c;
tau = ( tau_0 + T ) : T : ( tau_0 + T * (filter_length_samples) );

%% Calculation
Theta_S = repmat( theta_S, 1, numel(tau) );
Theta_R = repmat( theta_R, 1, numel(tau) );
Tau = repmat( tau, dim_n, 1 );
eta = acosh( ( (c .* Tau).^2 - (r_S.^2 + r_R.^2 + z_R.^2) ) ./ ( 2 * r_S .* r_R ) );

phi1 = pi + Theta_S + Theta_R;
phi2 = pi + Theta_S - Theta_R;
phi3 = pi - Theta_S + Theta_R;
phi4 = pi - Theta_S - Theta_R;

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

att.timeData = ( ( -(( c * ny ) / ( 2 * pi )) * beta ) ./ ( r_S .* r_R .* sinh( eta ) ) )' * T;

end

function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end
