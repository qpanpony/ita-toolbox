function [diffracted_field_TF_at_receiver] = ita_diffraction_order2_utd(infWedge1, infWedge2, sourcePos, receiverPos, freq, speedOfSound)
%ITA_DIFFRACTION_ORDER2_UTD double diffraction on two wedges with parallel
%aperture directions using the Uniform theory of diffraction (UTD)
%   algortithm from: Hyun_Sil Kim et al. - Sound diffraction by multiple
%   wedges and thin screens

%% assertions
% check for parallel apertures
assert(infWedge1.aperture_direction == infWedge2.aperture_direction);
%% params
k = (2 * pi * freq) / speedOfSound;

[apexPoint1, apexPoint2] = get_aperture_points(infWedge1, infWedge2, sourcePos, receiverPos);

n1 = infWedge1.get_opening_angle / pi;
n2 = infWedge2.get_opening_angle / pi;

srcFacingMainFaceOfWdg1 = infWedge1.point_facing_main_side(sourcePos);
apexPoint1FacingMainFaceOfWdg2 = infWedge2.point_facing_main_side(apexPoint1);
apexPoint2FacingMainFaceOfWdg1 = infWedge1.point_facing_main_side(apexPoint2);

thetaS1 = infWedge1.get_angle_from_point_to_wedge_face(sourcePos, srcFacingMainFaceOfWdg1);
theta1  = infWedge1.get_angle_from_point_to_wedge_face(apexPoint2, srcFacingMainFaceOfWdg1);
thetaS2 = infWedge2.get_angle_from_point_to_wedge_face(apexPoint1, apexPoint2FacingMainFaceOfWdg1);
theta2  = infWedge2.get_angle_from_point_to_wedge_face(receiverPos, apexPoint1FacingMainFaceOfWdg2);

theta_i1 = infWedge1.get_angle_from_point_to_aperture(sourcePos, apexPoint1);
theta_i2 = infWedge2.get_angle_from_point_to_aperture(apexPoint1, apexPoint2);

W = norm(apexPoint2 - apexPoint1);
r_total = rho_S + W + rho_R;

%% calc
A1 = ((W + rho_R) * rho_S) / r_total;
A2 = ((W + rho_S) * rho_R) / r_total;

B = (W * r_total) / ((W + rho_S) * (W + rho_R));
if X(theta1 - thetaS1, n1, k, A1) > X(theta2 - thetaS2, n2, k, A2)
    B1 = 1;
    B2 = B;
else
    B1 = B;
    B2 = 1;
end

D1 = D(rho_S, W, thetaS1, theta1, theta_i1, n, k, A1, B1);
D2 = D(W, rho_R, thetaS2, theta2, theta_i2, n, k, A2, B2);

H1 = 1/sqrt(A1 * B1) .* D1;
H2 = 1/sqrt(A2 * B2) .* D2;

if wedgesSharingOneFace(infWedge1, infWedge2)
    a = 1/2;
else
    a = 1;
end

diffracted_field_TF_at_receiver = a * (exp(-1i * k * r_total) / r_total) .* H1 .* H2;
end

%% helpers
function boolean = wedgesSharingOneFace(infWedge1, infWedge2)
    case1 = all(infWedge1.main_face_normal == infWedge2.main_face_normal);
    case2 = all(infWedge1.main_face_normal == infWedge2.opposite_face_normal);
    case3 = all(infWedge1.opposite_face_normal == infWedge2.main_face_normal);
    case4 = all(infWedge1.opposite_face_normal == infWedge2.opposite_face_normal);

    boolean = case1 || case2 || case3 || case4;
end


function res = X(theta, n, k, A)    
    res = 2 .* k .* A .* (cos((2 * pi * n * N_n(n, theta) - theta) / 2)).^2;
end

% get aperture point from two parallel apertures
function [apexPt1, apexPt2] = get_aperture_points(infWdg1, infWdg2, src, rcv)   
    apexDir1 = infWdg1.aperture_direction;
    apexDir2 = infWdg2.aperture_direction;
    connectionVector = infWdg2.location - infWdg1.location;
    
    connectionPlaneNormal = cross(apexDir1, connectionVector) ./ norm(cross(apexDir1, connectionVector));
    if ~infWdg1.point_outside_wedge(infWdg1.location + connectionPlaneNormal)
        connectionPlaneNormal = -connectionPlaneNormal; %invert direction
    end
    
    SR = rcv - src;
    SR_dir = SR ./ norm( SR );
    
    assert( norm( SR ) > 0 ); % @todo Auxiliar plane must be created differently if S and R are equal
    
    % Auxilary plane spanned by SR and aux_plane_dir
    aux_plane_dir = connectionPlaneNormal;
    aux_plane_normal = cross( SR_dir, aux_plane_dir ) ./ norm( cross( SR_dir, aux_plane_dir ) );

    % Distance of intersection of auxiliary plane and aperture direction
    % from aperture location
    % aux plane: dot( (x - source_point), aux_plane_normal) = 0
    % aperture line: x = location + dist * aperture_direction
    dist1 = dot( src - infWdg1.loaction, aux_plane_normal ) ./ dot( apexDir1, aux_plane_normal );
    apexPt1 = infWdg1.loaction + dist1 .* apexDir1;
    
    dist2 = dot( src - infWdg2.loaction, aux_plane_normal ) ./ dot( apexDir2, aux_plane_normal );
    apexPt2 = infWdg2.loaction + dist2 .* apexDir2;
    
end

function res = D(rho_S, rho_R, theta_S, theta_R, theta_i, n, k, A, B)
    % Diffraction coefficient D
    assert( all( rho_S + rho_R ~= 0 ) && all( rho_R ~= 0 )  );

    D_factor = -exp( -1i * pi / 4 ) ./ ( 2 * n * sqrt( 2* pi * k ) .* sin( theta_i ) );

    Cot1 = cot( ( pi + ( theta_R - theta_S ) ) ./ ( 2 * n ) );
    Cot2 = cot( ( pi - ( theta_R - theta_S ) ) ./ ( 2 * n ) );
    Cot3 = cot( ( pi + ( theta_R + theta_S ) ) ./ ( 2 * n ) );
    Cot4 = cot( ( pi - ( theta_R + theta_S ) ) ./ ( 2 * n ) );

    a1 = 2 * ( cos( ( 2 * pi * n * N_p( n, theta_R - theta_S ) - ( theta_R - theta_S ) ) / 2 ) ).^2;
    a2 = 2 * ( cos( ( 2 * pi * n * N_n( n, theta_R - theta_S ) - ( theta_R - theta_S ) ) / 2 ) ).^2;
    a3 = 2 * ( cos( ( 2 * pi * n * N_p( n, theta_R + theta_S ) - ( theta_R + theta_S ) ) / 2 ) ).^2;
    a4 = 2 * ( cos( ( 2 * pi * n * N_n( n, theta_R + theta_S ) - ( theta_R + theta_S ) ) / 2 ) ).^2;

    F1 = kawai_approx_fresnel( k .* A .* B .* a1 ); % -> frequency dependent
    F2 = kawai_approx_fresnel( k .* A .* B .* a2 );
    F3 = kawai_approx_fresnel( k .* A .* B .* a3 );
    F4 = kawai_approx_fresnel( k .* A .* B .* a4 );


    % Avoid eventual singularities of the cot terms at the shadow or reflection boundary with a approximation by
    % Kouyoumjian and Pathak
    mask1 =   ( theta_R - theta_S ) - 2 * pi * n * N_p( n, theta_R - theta_S ) + pi == 0;
    mask2 = - ( theta_R - theta_S ) + 2 * pi * n * N_n( n, theta_R - theta_S ) + pi == 0;
    mask3 =   ( theta_R + theta_S ) - 2 * pi * n * N_p( n, theta_R + theta_S ) + pi == 0;
    mask4 = - ( theta_R + theta_S ) + 2 * pi * n * N_n( n, theta_R + theta_S ) + pi == 0;

    singularities = [ any( mask1 ~= 0 ), any( mask2 ~= 0 ), any( mask3 ~= 0 ), any( mask4 ~= 0 ) ];

    if any( singularities )
        if singularities(1)
            eps1 =   ( theta_R(mask1) - theta_S(mask1) ) - 2 * pi * n * N_p( n, theta_R(mask1) - theta_S(mask1) ) + pi;
        else
            eps1 = 0;
        end
        if singularities(2)
            eps2 = - ( theta_R(mask2) - theta_S(mask2) ) + 2 * pi * n * N_n( n, theta_R(mask2) - theta_S(mask2) ) + pi;
        else
            eps2 = 0;
        end
        if singularities(3)
            eps3 =   ( theta_R(mask3) + theta_S(mask3) ) - 2 * pi * n * N_p( n, theta_R(mask3) + theta_S(mask3) ) + pi;
        else
            eps3 = 0;
        end
        if singularities(4)
            eps4 = - ( theta_R(mask4) + theta_S(mask4) ) + 2 * pi * n * N_n( n, theta_R(mask4) + theta_S(mask4) ) + pi;
        else
            eps4 = 0;
        end

        term1(mask1, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* A(mask1, :) ) .* sgn( eps1 ) - 2 .* k .* A(mask1, :) .* eps1 * exp( 1i * pi/4 ) );
        term2(mask2, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* A(mask2, :) ) .* sgn( eps2 ) - 2 .* k .* A(mask2, :) .* eps2 * exp( 1i * pi/4 ) );
        term3(mask3, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* A(mask3, :) ) .* sgn( eps3 ) - 2 .* k .* A(mask3, :) .* eps3 * exp( 1i * pi/4 ) );
        term4(mask4, :) = n * exp( 1i * pi/4 ) * ( sqrt( 2 * pi .* k .* A(mask4, :) ) .* sgn( eps4 ) - 2 .* k .* A(mask4, :) .* eps4 * exp( 1i * pi/4 ) );
    end

    term1(~mask1, :) = Cot1(~mask1, :) .* F1(~mask1, :); % -> frequency dependent
    term2(~mask2, :) = Cot2(~mask2, :) .* F2(~mask2, :);
    term3(~mask3, :) = Cot3(~mask3, :) .* F3(~mask3, :);
    term4(~mask4, :) = Cot4(~mask4, :) .* F4(~mask4, :);

    res = ( D_factor .* ( term1 + term2 + term3 + term4 ) )'; % -> frequency dependent
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