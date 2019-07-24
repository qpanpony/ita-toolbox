function [ diffr_field, D, A ] = ita_diffraction_utd( wedge, source_pos, receiver_pos, frequency_vec, speed_of_sound )
%ITA_DIFFRACTION_UTD Calculates the diffraction filter based on uniform
%theory of diffraction (with Kawai approximation)
%
% Literature:
%   [1] Tsingos, Funkhouser et al. - Modeling Acoustics in Virtual Environments using the Uniform Theory of Diffraction
%   [2] Kouyoumjian and Pathak - A Uniform Geometrical Theory of Diffraction for an Edge in a Perfectly Conducting Surface
% 
% Example:
%   att = ita_diffraction_utd( wedge, source_pos, receiver_pos, frequenc_vec )
%

%% Assertions
if ~ita_diffraction_point_is_of_dim3( source_pos )
    error( 'Source point must be of dimension 3' )
end
if ~ita_diffraction_point_is_of_dim3( receiver_pos )
    error( 'Receiver point must be of dimension 3' )
end
if ~ita_diffraction_point_is_row_vector( source_pos )
    %source_pos = source_pos';
end
if ~ita_diffraction_point_is_row_vector( receiver_pos )
   % receiver_pos = receiver_pos';
end

%% Variables
apex_point = wedge.get_aperture_point( source_pos, receiver_pos );
rho = norm( apex_point - source_pos ); % Distance of source to aperture point
r = norm( receiver_pos - apex_point ); % Distance of receiver to aperture point
assert( rho + r ~= 0 && r ~= 0 );

src_facing_main_side = wedge.point_facing_main_side( source_pos );
alpha_i = wedge.get_angle_from_point_to_wedge_face( source_pos, src_facing_main_side );
alpha_d = wedge.get_angle_from_point_to_wedge_face( receiver_pos, src_facing_main_side );
theta_i = wedge.get_angle_from_point_to_aperture( source_pos, apex_point );

n = wedge.opening_angle / pi; % Variable dependend on opening angle of the wedge
k = (2 * pi * frequency_vec) ./ speed_of_sound; % Wavenumber

%% Calculations
H_i = 1 ./ rho .* exp( -1i * k .* rho ); % direct path from source to apex point
A = sqrt( rho ./ ( r .* ( rho + r ) ) ); % attenuation factor at receiver
D = get_diffr_coeff( wedge, k, alpha_d, alpha_i, rho, r, theta_i, n );

% Combined diffracted sound field filter at receiver
diffr_field = H_i .* D .* A .* exp( -1i .* k .* r );

end

function D = get_diffr_coeff( wedge, k, alpha_d, alpha_i, rho, r, theta_i, n )

    L = ( ( rho * r ) ./ ( rho + r ) ) * ( sin( theta_i ) ).^2;

    Cot1 = cot( ( pi + ( alpha_d - alpha_i ) ) ./ ( 2 * n ) );
    Cot2 = cot( ( pi - ( alpha_d - alpha_i ) ) ./ ( 2 * n ) );
    Cot3 = cot( ( pi + ( alpha_d + alpha_i ) ) ./ ( 2 * n ) );
    Cot4 = cot( ( pi - ( alpha_d + alpha_i ) ) ./ ( 2 * n ) );

    a1 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
    a2 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
    a3 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;
    a4 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;

    F1 = kawai_approx_fresnel( k .* L .* a1 );
    F2 = kawai_approx_fresnel( k .* L .* a2 );
    F3 = kawai_approx_fresnel( k .* L .* a3 );
    F4 = kawai_approx_fresnel( k .* L .* a4 );

    singularities_present = check_for_singularities( wedge, alpha_i, alpha_d, n );
    
    if any( singularities_present )
        [term1, term2, term3, term4] = approx_for_singularities( n, k, L, alpha_i, alpha_d, singularities_present );

    else
        term1 = Cot1 .* F1;
        term2 = Cot2 .* F2;
        term3 = Cot3 .* F3;
        term4 = Cot4 .* F4;
    end

    if wedge.is_boundary_condition_hard
        s = 1;
    else
        s = -1;
    end
    
    prefactor = -exp( -1i * pi / 4 ) ./ ( 2 * n * sqrt( 2* pi * k ) .* sin( theta_i ) );

    D = prefactor .* ( term1 + term2 + s * ( term3 + term4 ) );
end

function res = check_for_singularities( wedge, alpha_i, alpha_d, n )
    % Avoid eventual singularities of the cot terms at the shadow or reflection boundary with a approximation by
    % Kouyoumjian and Pathak
    eps = wedge.set_get_geo_eps;
    is_singular_1 = abs( ( alpha_d - alpha_i ) - 2 * pi * n * N_p( n, alpha_d - alpha_i ) + pi ) < eps;
    is_singular_2 = abs( - ( alpha_d - alpha_i ) + 2 * pi * n * N_n( n, alpha_d - alpha_i ) + pi ) < eps;
    is_singular_3 = abs( ( alpha_d + alpha_i ) - 2 * pi * n * N_p( n, alpha_d + alpha_i ) + pi ) < eps;
    is_singular_4 = abs( - ( alpha_d + alpha_i ) + 2 * pi * n * N_n( n, alpha_d + alpha_i ) + pi ) < eps;
    res = [is_singular_1, is_singular_2, is_singular_3, is_singular_4];
end

function [term1, term2, term3, term4] = approx_for_singularities( n, k, L, alpha_i, alpha_d, singularities_present )
    if singularities_present(1)
        eps1 =   ( alpha_d - alpha_i ) - 2 * pi * n * N_p( n, alpha_d - alpha_i ) + pi;
    else
        eps1 = 0;
    end
    if singularities_present(2)
        eps2 = - ( alpha_d - alpha_i ) + 2 * pi * n * N_n( n, alpha_d - alpha_i ) + pi;
    else
        eps2 = 0;
    end
    if singularities_present(3)
        eps3 =   ( alpha_d + alpha_i ) - 2 * pi * n * N_p( n, alpha_d + alpha_i ) + pi;
    else
        eps3 = 0;
    end
    if singularities_present(4)
        eps4 = - ( alpha_d + alpha_i ) + 2 * pi * n * N_n( n, alpha_d + alpha_i ) + pi;
    else
        eps4 = 0;
    end

    term1 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L ) .* sgn( eps1 ) - 2 .* k .* L .* eps1 * exp( 1i * pi/4 ) );
    term2 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L ) .* sgn( eps2 ) - 2 .* k .* L .* eps2 * exp( 1i * pi/4 ) );
    term3 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L ) .* sgn( eps3 ) - 2 .* k .* L .* eps3 * exp( 1i * pi/4 ) );
    term4 = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L ) .* sgn( eps4 ) - 2 .* k .* L .* eps4 * exp( 1i * pi/4 ) );
end

%% Auxiliary functions
% N+ function
function N = N_p( n, beta )
    if beta > pi * (n - 1)
        N = 1;
    else
        N = 0;
    end
end

% N- function
function N = N_n( n, beta )
    if beta > pi * (1 + n)
        N = 1;
    elseif beta < pi * (n - 1)
        N = -1;
    else
        N = 0;
    end
end

% signum function
function res = sgn(x)
    if all( size(x) == 0 )
        res = 1;
        return;
    end
    res = ones( size(x) );
    res( x <= 0 ) = -1;
end

function Y = kawai_approx_fresnel( X )
    if any( X < 0 )
        error( 'No negative values for Kawai approximation of Fresnel integral allowed' )
    end
    X_s_idx = X < 0.8;
    X_geq_idx = ( X >= 0.8 );
    Y = zeros( size(X) );
    Y( X_s_idx ) = sqrt( pi * X( X_s_idx ) ) .* ( 1 - sqrt( X( X_s_idx ) ) ./ ( 0.7 * sqrt( X( X_s_idx ) ) + 1.2 ) ) .* exp( 1i * pi/4 * ( 1 - sqrt( X( X_s_idx ) ./ ( X( X_s_idx ) + 1.4 ) ) ) );
    Y( X_geq_idx ) = ( 1 - 0.8 ./ ( X( X_geq_idx ) + 1.25 ) .^ 2 ) .* exp( 1i * pi/4 * ( 1 - sqrt( X( X_geq_idx ) ./ ( X( X_geq_idx ) + 1.4 ) ) ) );
end