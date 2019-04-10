function [res, offs] = ita_diffraction_btms_approx( wedge, source, receiver, f_s, filter_length, c, integrand_approx, theta_0  )
%ITA_DIFFRACTION_BTMS_APPROX Summary of this function goes here
%   Detailed explanation goes here

%% Assertions
if ~isa( wedge, 'itaFiniteWedge')
    error( 'Wedge must be object from class itaFiniteWedge' );
end
dim_src = size( source );
dim_rcv = size( receiver );
% dim_tau = size( time_vec );
if dim_src(2) ~= 3
    if sim_src(1) ~= 3
        error( 'Source point(s) must be of dimension 3' )
    end
    source = source';
    dim_src = size( source );
end
if dim_rcv(2) ~= 3
    if dim_rcv(1) ~= 3
        error( 'Reciever point(s) must be of dimension 3' )
    end
    receiver = receiver';
    dim_rcv = size( receiver );
end
if dim_src(1) ~= 1 && dim_rcv(1) ~= 1 && dim_src(1) ~= dim_rcv(1)
    error( 'Number of receiver and source positions do not match' )
end
% if dim_tau(1) ~= 1
%     if dim_tau(2) ~= 1
%         error( 'Invalid time vector. Use (1 x n) or (n x 1) for n-dimensional time vector!' );
%     end
%     time_vec = time_vec';
%     dim_tau = size( time_vec );
% end
if nargin < 8
    theta_0 = 0.1;
end
if nargin < 7
    integrand_approx = true;
end


%%
% if ~in_shadow_zone
%     h_diffr_approx = ( zeros( dim_tau ) )';
% else
%     apex_point = wedge.get_aperture_point( source, receiver );
%     src_ap_dir = (apex_point - source) / norm(apex_point - source);
%     rho_S = norm( apex_point - source );
%     rho_R = norm( receiver - apex_point );
%     receiver_SB = ( rho_S + rho_R ) * src_ap_dir + source;
%     
%     ref_face = wedge.point_facing_main_side( source );
%     theta_tolerance = deg2rad(5);
%     theta_R = wedge.get_angle_from_point_to_wedge_face( receiver, ref_face );
%     theta_SB = wedge.get_angle_from_point_to_wedge_face( receiver_SB, ref_face ) + theta_tolerance;
%     
%     receiver_SB = ita_align_points_around_aperture( wedge, receiver_SB, theta_tolerance, apex_point, ref_face );
%     theta_rel = theta_R - theta_SB;
%     if theta_rel > pi/4
%         theta_rel = pi/4;
%     end
%     
%     R_dir = norm( receiver - source );
%     
%     % determine nearest time sample at direct impact
%     tau_eps = min( abs( time_vec - R_dir/c ) );
%     tau_dir = R_dir/c + tau_eps;
%     
%     h_dir_SB = ( zeros( dim_tau ) )';
%     h_dir_SB( time_vec == tau_dir ) = 1 / R_dir;
%     h_diffr_SB = ita_diffraction_btm_finite_wedge( wedge, source, receiver_SB, time_vec, c, integrand_approx );
%     
%     c_norm = h_dir_SB ./ h_diffr_SB;
%     c_approx = 1 + ( c_norm - 1 ) .* exp( - theta_rel / theta_0 );
%     
%     h_diffr = ita_diffraction_btm_finite_wedge( wedge, source, receiver, time_vec, c, integrand_approx );
%     h_diffr_approx = c_approx .* h_diffr;
% end

%% Variables
in_shadow_zone = ita_diffraction_shadow_zone( wedge, source, receiver );
ref_face = wedge.point_facing_main_side( source );
apex_point = wedge.get_aperture_point( source, receiver );
src_ap_dir = (apex_point - source) / norm(apex_point - source);
rho_S = norm( apex_point - source );
rho_R = norm( receiver - apex_point );
receiver_SB = ( rho_S + rho_R ) * src_ap_dir + source;
theta_SB = wedge.get_angle_from_point_to_wedge_face( receiver_SB, ref_face );
    
tau_0 = (rho_S + rho_R)/c;

if ~in_shadow_zone
    if nargout > 1
        res = zeros( filter_length, 1 );
        offs = tau_0 / (1/f_s);
    else
        res = zeros( filter_length, 1 );
    end
else
    
    ref_face = wedge.point_facing_main_side( source );
    theta_tolerance = deg2rad(0.000001);
    theta_R = wedge.get_angle_from_point_to_wedge_face( receiver, ref_face );
    theta_SB = wedge.get_angle_from_point_to_wedge_face( receiver_SB, ref_face ) + theta_tolerance;
    
    receiver_SB = ita_align_points_around_aperture( wedge, receiver_SB, theta_tolerance + theta_SB, apex_point, ref_face );
    theta_rel = theta_R - theta_SB;
    if theta_rel > pi/4
        theta_rel = pi/4;
    end
    
    f1 = linspace( 0, f_s/2, filter_length/2 + 1 );
    f2 = linspace( -f_s/2, 0, filter_length/2 + 1 );
    f = [f1, f2(2 : end-1)];
    k = 2* pi * f / c;
    R_dir = norm( receiver_SB - source );
    
    H_i_SB = 1 / R_dir;% * exp( -1i * k * R_dir );
    
    if nargout > 1 
        [h_diffr_SB, tau_offs_SB] = ita_diffraction_btms( wedge, source, receiver_SB, f_s, filter_length, c, integrand_approx );
        [h_diffr, tau_offs] = ita_diffraction_btms( wedge, source, receiver, f_s, filter_length, c, integrand_approx );
    else
        h_diffr_SB = ita_diffraction_btms( wedge, source, receiver_SB, f_s, filter_length, c, integrand_approx );
        h_diffr = ita_diffraction_btms( wedge, source, receiver, f_s, filter_length, c, integrand_approx );
    end
    H_diffr_SB_double_sided = fft( h_diffr_SB );
    H_diffr_double_sided = fft( h_diffr );
    
    H_diffr_SB = H_diffr_SB_double_sided;
    H_diffr = H_diffr_double_sided;
%     H_diffr_SB = H_diffr_SB_double_sided( 1 : filter_length/2 + 1 );
%     H_diffr = H_diffr_double_sided( 1 : filter_length/2 + 1 );
    
    c_norm = H_i_SB' ./ H_diffr_SB;
    c_approx = 1 + ( c_norm - 1 ) .* exp( - theta_rel / theta_0 );
    
    H_diffr_approx = c_approx .* H_diffr;
    h_diffr_approx = ifft( H_diffr_approx );
    if nargout > 1
        res = h_diffr_approx;
        offs = tau_offs;
    else
        res = h_diffr_approx;
    end
end

