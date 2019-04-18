function [ diffr_field, D ] = ita_diffraction_utd( wedge, source_pos, receiver_pos, frequency_vec, speed_of_sound )
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
dim_freq = size( frequency_vec );
dim_src = size( source_pos );
dim_rcv = size( receiver_pos );
if dim_freq(1) ~= 1
    if dim_freq(2) ~= 1
        error( 'Invalid frequency vector' );
    end
    frequency_vec = frequency_vec';
end
if dim_src(2) ~= 3
    if dim_src(1) ~= 3
        error( 'Source point(s) must be of dimension 3')
    end
    source_pos = source_pos';
    dim_src = size( source_pos );
end
if dim_src(1) == 0
    error( 'no source found' );
end
if dim_rcv(2) ~= 3
    if dim_rcv(1) ~= 3
        error( 'Receiver point(s) must be of dimension 3')
    end
    receiver_pos = receiver_pos';
    dim_rcv = size( receiver_pos );
end
if dim_rcv(1) == 0
    error( 'no receiver found' );
end
if dim_src(1) ~= 1 && dim_rcv(1) ~= 1 && dim_src(1) ~= dim_rcv(1)
    error( 'Number of receiver and source positions do not match' )
end
switch dim_src(1) >= dim_rcv(1)
    case true
        dim_n = dim_src(1);
    case false
        dim_n = dim_rcv(1);
end

%% Variables
if dim_src(1) == dim_n
    S = source_pos;
    if dim_rcv(1) == dim_n
        R = receiver_pos;
    else
        R = repmat( receiver_pos, dim_n, 1 );
    end
else
    R = receiver_pos;
    if dim_src(1) == dim_n
        S = source_pos;
    else
        S = repmat( source_pos, dim_n, 1 );
    end
end
Apex_Point = wedge.get_aperture_point( source_pos, receiver_pos );
rho = norm( Apex_Point - S ); % Distance of source to aperture point
r = norm( R - Apex_Point ); % Distance of receiver to aperture point
c = speed_of_sound;

face = wedge.point_facing_main_side( S );
alpha_i = wedge.get_angle_from_point_to_wedge_face( S, face );
alpha_d = wedge.get_angle_from_point_to_wedge_face( R, face );
theta_i = wedge.get_angle_from_point_to_aperture( S, Apex_Point );

n = wedge.opening_angle / pi; % Variable dependend on opening angle of the wedge

lambda = c ./ frequency_vec; % Wavelength
k = (2 * pi) ./ lambda; % Wavenumber


% Diffraction coefficient D
assert( all( rho + r ~= 0 ) && all( r ~= 0 )  );
L = repmat( ( ( rho .* r ) ./ ( rho + r ) ) .* ( sin( theta_i ) ).^2, 1, numel( frequency_vec ) );

D_factor = -exp( -1i * pi / 4 ) ./ ( 2 * n * sqrt( 2* pi * k ) .* sin( theta_i ) );

Cot1 = repmat( cot( ( pi + ( alpha_d - alpha_i ) ) ./ ( 2 * n ) ), 1, numel( frequency_vec ) );
Cot2 = repmat( cot( ( pi - ( alpha_d - alpha_i ) ) ./ ( 2 * n ) ), 1, numel( frequency_vec ) );
Cot3 = repmat( cot( ( pi + ( alpha_d + alpha_i ) ) ./ ( 2 * n ) ), 1, numel( frequency_vec ) );
Cot4 = repmat( cot( ( pi - ( alpha_d + alpha_i ) ) ./ ( 2 * n ) ), 1, numel( frequency_vec ) );

a1 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
a2 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
a3 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;
a4 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;

F1 = kawai_approx_fresnel( k .* L .* a1 );
F2 = kawai_approx_fresnel( k .* L .* a2 );
F3 = kawai_approx_fresnel( k .* L .* a3 );
F4 = kawai_approx_fresnel( k .* L .* a4 );

% Avoid eventual singularities of the cot terms at the shadow or reflection boundary with a approximation by
% Kouyoumjian and Pathak
mask1 = ( alpha_d - alpha_i ) - 2 * pi * n * N_p( n, alpha_d - alpha_i ) + pi == 0;
mask2 = - ( alpha_d - alpha_i ) + 2 * pi * n * N_n( n, alpha_d - alpha_i ) + pi == 0;
mask3 = ( alpha_d + alpha_i ) - 2 * pi * n * N_p( n, alpha_d + alpha_i ) + pi == 0;
mask4 = - ( alpha_d + alpha_i ) + 2 * pi * n * N_n( n, alpha_d + alpha_i ) + pi == 0;
  
singularities = [ any( mask1 ~= 0 ), any( mask2 ~= 0 ), any( mask3 ~= 0 ), any( mask4 ~= 0 ) ];


if any( singularities )
    if singularities(1)
        eps1 =   ( alpha_d(mask1) - alpha_i(mask1) ) - 2 * pi * n * N_p( n, alpha_d(mask1) - alpha_i(mask1) ) + pi;
    else
        eps1 = 0;
    end
    if singularities(2)
        eps2 = - ( alpha_d(mask2) - alpha_i(mask2) ) + 2 * pi * n * N_n( n, alpha_d(mask2) - alpha_i(mask2) ) + pi;
    else
        eps2 = 0;
    end
    if singularities(3)
        eps3 =   ( alpha_d(mask3) + alpha_i(mask3) ) - 2 * pi * n * N_p( n, alpha_d(mask3) + alpha_i(mask3) ) + pi;
    else
        eps3 = 0;
    end
    if singularities(4)
        eps4 = - ( alpha_d(mask4) + alpha_i(mask4) ) + 2 * pi * n * N_n( n, alpha_d(mask4) + alpha_i(mask4) ) + pi;
    else
        eps4 = 0;
    end

    term1(mask1, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L(mask1, :) ) .* sgn( eps1 ) - 2 .* k .* L(mask1, :) .* eps1 * exp( 1i * pi/4 ) );
    term2(mask2, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L(mask2, :) ) .* sgn( eps2 ) - 2 .* k .* L(mask2, :) .* eps2 * exp( 1i * pi/4 ) );
    term3(mask3, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L(mask3, :) ) .* sgn( eps3 ) - 2 .* k .* L(mask3, :) .* eps3 * exp( 1i * pi/4 ) );
    term4(mask4, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* L(mask4, :) ) .* sgn( eps4 ) - 2 .* k .* L(mask4, :) .* eps4 * exp( 1i * pi/4 ) );
end

term1(~mask1, :) = Cot1(~mask1, :) .* F1(~mask1, :);
term2(~mask2, :) = Cot2(~mask2, :) .* F2(~mask2, :);
term3(~mask3, :) = Cot3(~mask3, :) .* F3(~mask3, :);
term4(~mask4, :) = Cot4(~mask4, :) .* F4(~mask4, :);

if wedge.is_boundary_condition_hard
    s = 1;
else
    s = -1;
end

D = D_factor .* ( term1 + term2 + s * ( term3 + term4 ) );


%% Combined diffracted sound field filter at receiver

H_i = 1 ./ rho .* exp( -1i * k .* rho ); % Consideration of transfer path from source to apex point
A = repmat( sqrt( rho ./ ( r .* ( rho + r ) ) ), 1, numel( frequency_vec ) ); % Amplitude

diffr_field = (  H_i .* D .* A .* exp( -1i .* k .* r ) )';


end


%% Auxiliary functions

% N+ function
function N = N_p( n, beta )
    N = zeros( numel( beta ), 1 );
    N( beta >  pi * ( 1 - n ) ) = 1;
end

% N- function
function N = N_n( n, beta )
    N = zeros( numel( beta ), 1 );
    N( beta < pi * ( 1 - n ) ) = -1;
    N( beta > pi * ( 1 + n ) ) = 1;
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