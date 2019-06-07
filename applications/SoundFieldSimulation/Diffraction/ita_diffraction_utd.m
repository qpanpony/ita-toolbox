function [ diffr_field, D, A ] = ita_diffraction_utd( wedge, sourcePos, receiverPos, frequencyVec, speedOfSound )
%ITA_DIFFRACTION_UTD Calculates the diffraction filter based on uniform
%theory of diffraction (with Kawai approximation)
%
% Literature:
%   [1] Tsingos, Funkhouser et al. - Modeling Acoustics in Virtual Environments using the Uniform Theory of Diffraction
%   [2] Kouyoumjian and Pathak - A Uniform Geometrical Theory of Diffraction for an Edge in a Perfectly Conducting Surface
%
% Example:
%   att = ita_diffraction_utd( wedge, source_pos, receiver_pos, frequenc_vec )

%% Assertions
if ~ita_diffraction_point_is_of_dim3( sourcePos )
    error( 'Source point must be of dimension 3' )
end
if ~ita_diffraction_point_is_of_dim3( receiverPos )
    error( 'Receiver point must be of dimension 3' )
end
if ~ita_diffraction_point_is_row_vector( sourcePos )
    sourcePos = sourcePos';
end
if ~ita_diffraction_point_is_row_vector( receiverPos )
    receiverPos = receiverPos';
end

%% Variables
apexPoint = wedge.get_aperture_point( sourcePos, receiverPos );
distFromSrc2ApexPoint = norm( apexPoint - sourcePos ); % Distance of source to aperture point
distFromRcv2ApexPoint = norm( receiverPos - apexPoint ); % Distance of receiver to aperture point

sourceFacingMainSide = wedge.point_facing_main_side( sourcePos );
alpha_i = wedge.get_angle_from_point_to_wedge_face( sourcePos, sourceFacingMainSide );
alpha_d = wedge.get_angle_from_point_to_wedge_face( receiverPos, sourceFacingMainSide );
theta_i = wedge.get_angle_from_point_to_aperture( sourcePos, apexPoint );

n = wedge.opening_angle / pi; % Variable dependend on opening angle of the wedge

lambda = speedOfSound ./ frequencyVec; % Wavelength
k = 2 * pi ./ lambda; % Wavenumber


% Diffraction coefficient D
assert( all( distFromSrc2ApexPoint + distFromRcv2ApexPoint ~= 0 ) && all( distFromRcv2ApexPoint ~= 0 )  );
L = ( ( distFromSrc2ApexPoint .* distFromRcv2ApexPoint ) ./ ( distFromSrc2ApexPoint + distFromRcv2ApexPoint ) ) .* ( sin( theta_i ) ).^2; % -> distance dependency

D_factor = -exp( -1i * pi / 4 ) ./ ( 2 * n * sqrt( 2* pi * k ) .* sin( theta_i ) );

Cot1 = cot( ( pi + ( alpha_d - alpha_i ) ) ./ ( 2 * n ) );
Cot2 = cot( ( pi - ( alpha_d - alpha_i ) ) ./ ( 2 * n ) );
Cot3 = cot( ( pi + ( alpha_d + alpha_i ) ) ./ ( 2 * n ) );
Cot4 = cot( ( pi - ( alpha_d + alpha_i ) ) ./ ( 2 * n ) );

a1 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
a2 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d - alpha_i ) - ( alpha_d - alpha_i ) ) / 2 ) ).^2;
a3 = 2 * ( cos( ( 2 * pi * n * N_p( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;
a4 = 2 * ( cos( ( 2 * pi * n * N_n( n, alpha_d + alpha_i ) - ( alpha_d + alpha_i ) ) / 2 ) ).^2;

F1 = kawai_approx_fresnel( k .* L .* a1 ); % -> frequency dependent
F2 = kawai_approx_fresnel( k .* L .* a2 );
F3 = kawai_approx_fresnel( k .* L .* a3 );
F4 = kawai_approx_fresnel( k .* L .* a4 );


% Avoid eventual singularities of the cot terms at the shadow or reflection boundary with a approximation by
% Kouyoumjian and Pathak
mask1 =   ( alpha_d - alpha_i ) - 2 * pi * n * N_p( n, alpha_d - alpha_i ) + pi == 0;
mask2 = - ( alpha_d - alpha_i ) + 2 * pi * n * N_n( n, alpha_d - alpha_i ) + pi == 0;
mask3 =   ( alpha_d + alpha_i ) - 2 * pi * n * N_p( n, alpha_d + alpha_i ) + pi == 0;
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

term1(~mask1, :) = Cot1(~mask1, :) .* F1(~mask1, :); % -> frequency dependent
term2(~mask2, :) = Cot2(~mask2, :) .* F2(~mask2, :);
term3(~mask3, :) = Cot3(~mask3, :) .* F3(~mask3, :);
term4(~mask4, :) = Cot4(~mask4, :) .* F4(~mask4, :);

if wedge.is_boundary_condition_hard
    switchSign = 1;
else
    switchSign = -1;
end

D = ( D_factor .* ( term1 + term2 + switchSign * ( term3 + term4 ) ) )'; % -> frequency dependent


%% Combined diffracted sound field filter at receiver

H_i = exp( -1i * k' .* distFromSrc2ApexPoint ) ./ distFromSrc2ApexPoint; % Transfer path from spherical sound source to apex point
A = sqrt( distFromSrc2ApexPoint ./ ( distFromRcv2ApexPoint .* ( distFromSrc2ApexPoint + distFromRcv2ApexPoint ) ) ); % Amplitude divergion factor of modified sphere wavefront (apex->receiver)
H_o = exp( -1i .* k' .* distFromRcv2ApexPoint ); % Phase modification from apex point to receiver
diffr_field =  H_i .* D .* A .* H_o;


end


%% Auxiliary functions

% N+ function (plus)
function N = N_p( n, beta )
    N = zeros( numel( beta ), 1 );
    N( beta >  pi * ( 1 - n ) ) = 1;
end

% N- function (minus)
function N = N_n( n, beta )
    N = zeros( numel( beta ), 1 );
    N( beta < pi * ( 1 - n ) ) = -1;
    N( beta > pi * ( 1 + n ) ) = 1;
end

% Signum function
function res = sgn(x)
    if all( size(x) == 0 )
        res = 1;
        return;
    end
    res = ones( size(x) );
    res( x <= 0 ) = -1;
end

% Approximation of the Fresnel integral by Kawaii et al.
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
