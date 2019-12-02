function [res, offs] = ita_diffraction_btms( fin_wedge, source_pos, receiver_pos, sample_rate, filter_length, speed_of_sound, use_approx )
%ITA_DIFFRACTION_BTM_FINITE_WEDGE Summary of this function goes here
%   Detailed explanation goes here

%% Assertions
if nargin < 7
    use_approx = true;
end
if ~isa( fin_wedge, 'itaFiniteWedge')
    error( 'Wedge must be object from class itaFiniteWedge' );
end
if ~ita_diffraction_point_is_of_dim3( source_pos )
    error( 'Source point must be of dimension 3' )
end
if ~ita_diffraction_point_is_of_dim3( receiver_pos )
    error( 'Receiver point must be of dimension 3' )
end
if ~ita_diffraction_point_is_row_vector( source_pos )
    source_pos = source_pos';
end
if ~ita_diffraction_point_is_row_vector( receiver_pos )
    receiver_pos = receiver_pos';
end


%% Variables
apex_point = fin_wedge.approx_aperture_point( source_pos, receiver_pos );
apex_dir = fin_wedge.aperture_direction;
ref_face = fin_wedge.point_facing_main_side( source_pos );
theta_S = fin_wedge.get_angle_from_point_to_wedge_face( source_pos, ref_face );
theta_R = fin_wedge.get_angle_from_point_to_wedge_face( receiver_pos, ref_face );
theta_i = fin_wedge.get_angle_from_point_to_aperture( source_pos, apex_point );
theta_w = fin_wedge.opening_angle;
SA = norm( apex_point - source_pos );
AR = norm( receiver_pos - apex_point );
r_S = SA .* sin( theta_i );
r_R = AR .* sin( theta_i );
z_S = dot( source_pos - fin_wedge.aperture_start_point, apex_dir );
z_R = dot( receiver_pos - fin_wedge.aperture_start_point, apex_dir );
% z_apex = dot( Apex_Point - wedge.aperture_start_point, Apex_Dir );

ny = pi / theta_w;
R_0 = sqrt( (r_S + r_R).^2 + (z_R - z_S).^2 );
c = speed_of_sound;

% res = itaAudio();
% res.signalType = 'energy';
% res.samplingRate = sampling_rate;
% res.nSamples = filter_length_samples;

T = 1 / sample_rate;
tau_0 = R_0 / c;
% tau = ( tau_0 ) : T : ( tau_0 + T * (N - 1) );

tau = 0 : T : T*(filter_length-1);

tau_offset = tau_0 / T;

% 
% tau = time_vec;
% T = tau(2) - tau(1);

%% Calculate positions of secondary sources on aperture
Z = secondary_source_coordinates_on_aperture( r_S, z_S, r_R, z_R, tau, c );
z_n_u = Z(1, :);
z_n_l = Z(2, :);

dZ = secondary_source_coordinates_on_aperture( r_S, z_S, r_R, z_R, tau + 0.5*T, c ) -...
     secondary_source_coordinates_on_aperture( r_S, z_S, r_R, z_R, tau - 0.5*T, c );


tau_end_upper_branch = ( norm( fin_wedge.aperture_end_point - source_pos ) + norm( receiver_pos - fin_wedge.aperture_end_point) ) / c;
tau_end_lower_branch = ( norm( fin_wedge.aperture_start_point - source_pos ) + norm( receiver_pos - fin_wedge.aperture_start_point) ) / c;

mask_u = ( tau <= tau_end_upper_branch );
mask_l = ( tau <= tau_end_lower_branch );

% Choose longer branch of the edge from aperture point
if sum(mask_u) >= sum(mask_l) % upper branch
    z_n = ( z_n_u(mask_u) )';
    mask_n = mask_u;
    dz = dZ(1, :);
    dz = ( dz(mask_u) )';
else % lower branch
    z_n = ( z_n_l(mask_l) )';
    mask_n = mask_l;
    dz = dZ(2, :);
    dz = ( dz(mask_l) )';
end

Apex_Start = repmat( fin_wedge.aperture_start_point, numel( z_n ), 1 );
Z_n = repmat( z_n, 1, 3 );
apex_dir = repmat( fin_wedge.aperture_direction, numel( z_n ), 1 );
Sec_Source_Pos_On_Apex_n = Apex_Start + ( Z_n .* apex_dir );

%% Filter variables
% alpha_n = pi/2 - wedge.get_angle_from_point_to_aperture( source_pos, Sec_Source_Pos_On_Apex_n );
% gamma_n = pi/2 - wedge.get_angle_from_point_to_aperture( receiver_pos, Sec_Source_Pos_On_Apex_n );

m_n = Norm( Sec_Source_Pos_On_Apex_n - source_pos );
l_n = Norm( Sec_Source_Pos_On_Apex_n - receiver_pos );

% Calculation of dz for numerical integration
% dz_n = z_n - [ z_apex; z_n(1 : end-1) ];
% dz = ( [dz_n(2 : end); dz_n(end)] ./ 2 ) + ( dz_n ./ 2 );

%% Filter Calculation
y = ( m_n .* l_n + (z_n - z_S) .* (z_n - z_R) ) ./ ( r_S * r_R );
A = y + sqrt( y.^2 - 1 );
cosh_approx = 0.5 * ( A.^(ny) + A.^(-ny) );

% eta = acosh( ( 1 + sin( alpha_n ) .* sin( gamma_n ) ) ./ ( cos( alpha_n ) .* cos( gamma_n ) ) );


phi1 = pi + theta_S + theta_R;
phi2 = pi + theta_S - theta_R;
phi3 = pi - theta_S + theta_R;
phi4 = pi - theta_S - theta_R;

beta_pp = sin( ny * phi1 ) ./ ( cosh_approx - cos( ny * phi1 ) );
beta_pm = sin( ny * phi2 ) ./ ( cosh_approx - cos( ny * phi2 ) );
beta_mp = sin( ny * phi3 ) ./ ( cosh_approx - cos( ny * phi3 ) );
beta_mm = sin( ny * phi4 ) ./ ( cosh_approx - cos( ny * phi4 ) );

%% Seperate consideration of potential singularities at reflection or shadow boundary
z_rel = dz(1);
psi = theta_i;
rho = r_R / r_S;

% theta_RB = pi - theta_S;
% theta_SB = pi + theta_S;

symmetrical = (psi == pi/2) || (rho == 1);
if symmetrical
    B0_pp = B0( R_0, rho, psi, ny, phi1 );
    B0_pm = B0( R_0, rho, psi, ny, phi2 );
    B0_mp = B0( R_0, rho, psi, ny, phi3 );
    B0_mm = B0( R_0, rho, psi, ny, phi4 );

    B1_pp = B1( R_0, rho, ny, phi1 );
    B1_pm = B1( R_0, rho, ny, phi2 );
    B1_mp = B1( R_0, rho, ny, phi3 );
    B1_mm = B1( R_0, rho, ny, phi4 );

    B3_pp = B3( R_0, rho, psi );
    B3_pm = B3( R_0, rho, psi );
    B3_mp = B3( R_0, rho, psi );
    B3_mm = B3( R_0, rho, psi );

    if (psi == pi/2) && (rho == 1)
        B4_pp = B4( ny, phi1 );
        B4_pm = B4( ny, phi2 );
        B4_mp = B4( ny, phi3 );
        B4_mm = B4( ny, phi4 );
        
        h1_0 = - ( ny / (2*pi) ) * ( B4_pp / sqrt(B1_pp) ) * atan( z_rel / sqrt(B1_pp) );
        h2_0 = - ( ny / (2*pi) ) * ( B4_pm / sqrt(B1_pm) ) * atan( z_rel / sqrt(B1_pm) );
        h3_0 = - ( ny / (2*pi) ) * ( B4_mp / sqrt(B1_mp) ) * atan( z_rel / sqrt(B1_mp) );
        h4_0 = - ( ny / (2*pi) ) * ( B4_mm / sqrt(B1_mm) ) * atan( z_rel / sqrt(B1_mm) );
    else
        h1_0 = - ( ny / (2*pi) ) * ( B0_pp / (B3_pp - B1_pp) ) * ( ( 1 / sqrt(B1_pp) ) * atan( z_rel / sqrt(B1_pp) ) - ( 1 / sqrt(B3_pp) ) * atan( z_rel / sqrt(B3_pp) ) );
        h2_0 = - ( ny / (2*pi) ) * ( B0_pm / (B3_pm - B1_pm) ) * ( ( 1 / sqrt(B1_pm) ) * atan( z_rel / sqrt(B1_pm) ) - ( 1 / sqrt(B3_pm) ) * atan( z_rel / sqrt(B3_pm) ) );
        h3_0 = - ( ny / (2*pi) ) * ( B0_mp / (B3_mp - B1_mp) ) * ( ( 1 / sqrt(B1_mp) ) * atan( z_rel / sqrt(B1_mp) ) - ( 1 / sqrt(B3_mp) ) * atan( z_rel / sqrt(B3_mp) ) );
        h4_0 = - ( ny / (2*pi) ) * ( B0_mm / (B3_mm - B1_mm) ) * ( ( 1 / sqrt(B1_mm) ) * atan( z_rel / sqrt(B1_mm) ) - ( 1 / sqrt(B3_mm) ) * atan( z_rel / sqrt(B3_mm) ) );
    end
else
    B0_pp = B0( R_0, rho, psi, ny, phi1 );
    B0_pm = B0( R_0, rho, psi, ny, phi2 );
    B0_mp = B0( R_0, rho, psi, ny, phi3 );
    B0_mm = B0( R_0, rho, psi, ny, phi4 );

    B1_pp = B1( R_0, rho, ny, phi1 );
    B1_pm = B1( R_0, rho, ny, phi2 );
    B1_mp = B1( R_0, rho, ny, phi3 );
    B1_mm = B1( R_0, rho, ny, phi4 );

    B2_pp = B2( R_0, rho, psi );
    B2_pm = B2( R_0, rho, psi );
    B2_mp = B2( R_0, rho, psi );
    B2_mm = B2( R_0, rho, psi );

    B3_pp = B3( R_0, rho, psi );
    B3_pm = B3( R_0, rho, psi );
    B3_mp = B3( R_0, rho, psi );
    B3_mm = B3( R_0, rho, psi );
    
    q1 = 4 * B3_pp - B2_pp^2;
    q2 = 4 * B3_pm - B2_pm^2;
    q3 = 4 * B3_mp - B2_mp^2;
    q4 = 4 * B3_mm - B2_mm^2;
    
    
    C1 = ( B0_pp * B2_pp ) / ( B1_pp * B2_pp^2 + ( B1_pp - B3_pp )^2 );
    C2 = ( B0_pm * B2_pm ) / ( B1_pm * B2_pm^2 + ( B1_pm - B3_pm )^2 );
    C3 = ( B0_mp * B2_mp ) / ( B1_mp * B2_mp^2 + ( B1_mp - B3_mp )^2 );
    C4 = ( B0_mm * B2_mm ) / ( B1_mm * B2_mm^2 + ( B1_mm - B3_mm )^2 );
    
    D1 = 0.5 * log( abs( ( B3_pp * ( z_rel^2 + B1_pp ) ) / ( B1_pp * ( z_rel^2 + B2_pp * z_rel + B3_pp ) ) ) );
    D2 = 0.5 * log( abs( ( B3_pm * ( z_rel^2 + B1_pm ) ) / ( B1_pm * ( z_rel^2 + B2_pm * z_rel + B3_pm ) ) ) );
    D3 = 0.5 * log( abs( ( B3_mp * ( z_rel^2 + B1_mp ) ) / ( B1_mp * ( z_rel^2 + B2_mp * z_rel + B3_mp ) ) ) );
    D4 = 0.5 * log( abs( ( B3_mm * ( z_rel^2 + B1_mm ) ) / ( B1_mm * ( z_rel^2 + B2_mm * z_rel + B3_mm ) ) ) );
    
    E1 = ( ( B1_pp - B3_pp ) / ( sqrt(B1_pp) * B2_pp ) ) * atan( z_rel / sqrt(B1_pp) );
    E2 = ( ( B1_pp - B3_pm ) / ( sqrt(B1_pm) * B2_pm ) ) * atan( z_rel / sqrt(B1_pm) );
    E3 = ( ( B1_pp - B3_mp ) / ( sqrt(B1_mp) * B2_mp ) ) * atan( z_rel / sqrt(B1_mp) );
    E4 = ( ( B1_pp - B3_mm ) / ( sqrt(B1_mm) * B2_mm ) ) * atan( z_rel / sqrt(B1_mm) );
    
    G1 = ( ( 2 * ( B3_pp - B1_pp ) - B2_pp^2 ) / ( 2 * B2_pp ) ) * F( q1, z_rel, B2_pp, rho, psi );
    G2 = ( ( 2 * ( B3_pm - B1_pm ) - B2_pm^2 ) / ( 2 * B2_pm ) ) * F( q2, z_rel, B2_pm, rho, psi );
    G3 = ( ( 2 * ( B3_mp - B1_mp ) - B2_mp^2 ) / ( 2 * B2_mp ) ) * F( q3, z_rel, B2_mp, rho, psi );
    G4 = ( ( 2 * ( B3_mm - B1_mm ) - B2_mm^2 ) / ( 2 * B2_mm ) ) * F( q4, z_rel, B2_mm, rho, psi );
    
    h1_0 = ( ny / (2*pi) ) * C1 * ( D1 + E1 + G1 );
    h2_0 = ( ny / (2*pi) ) * C2 * ( D2 + E2 + G2 );
    h3_0 = ( ny / (2*pi) ) * C3 * ( D3 + E3 + G3 );
    h4_0 = ( ny / (2*pi) ) * C4 * ( D4 + E4 + G4 );
end

%% Filter Results
switch fin_wedge.is_boundary_condition_hard
    case true
        beta = ( beta_pp + beta_pm + beta_mp + beta_mm ); % factor 2 from Svensson - An analytic secondary source model... eq (17)
        h_0 = h1_0 + h2_0 + h3_0 + h4_0;
    case false
        beta = ( -beta_pp + beta_pm + beta_mp - beta_mm );
        h_0 = - h1_0 + h2_0 + h3_0 - h4_0;
end

scaling = ( mask_u +  mask_l )'; % factor 2 from Svensson - An analytic secondary source model... eq (17)
integrand = ( (scaling(mask_n) .* beta) ./ (m_n .* l_n) );

h_diffr = zeros( numel(tau), 1 );
h_diffr(mask_n) = - ( ny / (4*pi) ) * integrand .* dz;
if use_approx
    h_diffr(1) = h_0;
end
% res.timeData = h_diffr;

if nargout > 1
    res = h_diffr;
    offs = tau_0;
else
    res = h_diffr;
end

%% test output

% res = [h1_0 , h2_0, h3_0, h4_0];


end


% function Z = secondary_source_coordinates_on_aperture( r_S, z_S, r_R, z_R, tau, c )
%     z_RS = z_R - z_S;
% 
%     p_n = ( c * tau ).^2;
% 
%     a = z_RS.^2 + r_S.^2 + r_R.^2;
%     b = 2 * z_RS;
%     q = (z_RS.^2 + r_R.^2 - r_S.^2).^2;
% 
%     u_n = b.^2 - 4 * p_n;
%     v_n = 4 * z_RS .* p_n - 4 * z_RS .* (z_RS.^2 + r_R.^2 - r_S.^2);
%     w_n = p_n.^2 - 2 * a .* p_n + q;
% 
%     z_n_u = (-v_n ./ (2 * u_n)) + sqrt( 0.25 * (v_n ./ u_n).^2 - (w_n ./ u_n) ) + z_S;
%     z_n_l = (-v_n ./ (2 * u_n)) - sqrt( 0.25 * (v_n ./ u_n).^2 - (w_n ./ u_n) ) + z_S;
%     
%     z_n_u = real(z_n_u);
%     z_n_l = real(z_n_l);
%     
%     Z = [ z_n_u; z_n_l ];
% end

function Z = secondary_source_coordinates_on_aperture( r_S, z_S, r_R, z_R, tau, c )    
    a = z_S^2 + z_R^2 + r_S^2 + r_R^2;
    b = 2 * (z_S + z_R);
    d = 2 * ( z_S * (z_R^2 + r_R^2) + z_R * (z_S^2 + r_S^2) );
    e = (z_S^2 + r_S^2) * (z_R^2 + r_R^2);
    f = z_S^2 + z_R^2 + r_S^2 + r_R^2 + 4*z_R*z_S;
    
    p_n = (c * tau).^2;
    u_n = b.^2 + 4*a - 4.*p_n - 4*f;
    v_n = 2 .* p_n .* b - 2 .* a .* b + 4*d;
    w_n = p_n.^2 - 2 .* a .* p_n + a.^2 - 4*e;
    
    det = 0.25 * (v_n ./ u_n).^2 - (w_n ./ u_n);
    det(det < 0) = 0;
    
    z_n_u = (-v_n ./ (2 * u_n)) + sqrt( det );
    z_n_l = (-v_n ./ (2 * u_n)) - sqrt( det );
    
    Z = [z_n_u; z_n_l];
end
function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end

function res = B0( R_0, rho, psi, ny, phi )
    res = ( 4 * R_0^2 * rho^3 * sin( ny * phi ) ) / ( ny^2 * (1 + rho)^4 * ( (1 + rho)^2 * sin( psi )^2 - 2 * rho ) );
end

function res = B1( R_0, rho, ny, phi )
    res = ( 4 * R_0^2 * rho^2 * sin( (ny * phi) / 2 )^2 ) / ( ny^2 * (1 + rho)^4 );
end

function res = B2( R_0, rho, psi )
    res = - ( 2 * R_0 * (1 - rho) * rho * cos( psi ) ) / ( (1 + rho) * ( (1 + rho)^2 * sin( psi )^2 - 2 * rho ) );
end

function res = B3( R_0, rho, psi )
    res = ( 2 * R_0^2 * rho^2 ) / ( (1 + rho)^2 * ( (1 + rho)^2 * sin( psi )^2 - 2 * rho ) );
end

function res = B4( ny, phi )
    res = sin( ny * phi ) / ( 2 * ny^2 );
end

function res = F( q, z_rel, B2, rho, psi )
    if q < 0
        res = ( 1 / sqrt(-q) ) * log( abs( ( 2*z_rel + B2 - sqrt(-q) * B2 + sqrt(-q) ) / ( 2*z_rel + B2 - sqrt(-q) * B2 - sqrt(-q) ) ) );
    elseif q > 0
        res = ( 2 / sqrt(q) ) * ( atan( (2*z_rel + B2) / sqrt(q) ) - atan( B2 / sqrt(q) ) );
    else
        res = ( 4 * z_rel ) / ( B2 * ( 2*z_rel + B2 ) );
    end
    if abs( sin(psi)^2 - ( 2*rho ) / ( ( 1 + rho )^2 ) ) <= 10^(-6)
        res = 0;
    end
end

% function Z = test_sec_source_position_on_aperture(r_S, r_R, z_S, z_R, z_A, tau)  
%     c = 343.21;
%     
%     z_S_rel = z_S - z_A;
%     z_R_rel = z_R - z_A;
% 
%     D = c .* tau;
%     m_0 = sqrt( r_S.^2 + z_S_rel.^2 );
%     l_0 = sqrt( r_R.^2 + z_R_rel.^2 );
%     K = m_0.^2 - l_0.^2 - D.^2;
%     B = ( 2 * D.^2 .* z_R_rel - K .* ( z_S_rel - z_R_rel ) ) ./ ( ( z_S_rel - z_R_rel ).^2 - D.^2 );
%     C = ( 0.25 .* K.^2 - D.^2 * l_0.^2 ) ./ ( ( z_S_rel - z_R_rel ).^2 - D.^2 );
%     
%     z_rel1 = ( -B + sqrt( B.^2 - 4 .* C ) ) ./ 2;
%     z_rel2 = ( -B - sqrt( B.^2 - 4 .* C ) ) ./ 2;
%     
%     Z = [ z_rel1; z_rel2 ]';
% end