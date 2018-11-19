function H_diffr = ita_diffraction_maekawa_approx( wedge, source_pos, receiver_pos, frequencies, speed_of_sound, transition_const )
% Calculates the attenuation filter(s) at a diffraction wedge for source
% and receiver location(s) at given frequencies with. For purpose of
% continuity at shadow boundary an interpolation with exponential function
% is used.
%
% wedge: diffracting wedge (itaInfiniteWedge or derived class
% itaFiniteWedge)
% source_pos: position of the source
% receiver_pos: position of the receiver


%% Assertions
assert( isa( wedge, 'itaInfiniteWedge' ) )
if nargin < 6
    transition_const = 0.2;
end
dim_src = size( source_pos );
dim_rcv = size( receiver_pos );
dim_f = size( frequencies );
if dim_src(2) ~= 3
    if dim_src(1) ~= 3
        error( 'Source point(s) must be of dimension 3')
    end
    source_pos = source_pos';
    dim_src = size( source_pos );
end
if dim_rcv(2) ~= 3
    if dim_rcv(1) ~= 3
        error( 'Receiver point(s) must be of dimension 3')
    end
    receiver_pos = receiver_pos';
    dim_rcv = size( receiver_pos );
end
if dim_src(1) ~= 1 && dim_rcv(1) ~= 1 && dim_src(1) ~= dim_rcv(1)
    error( 'Number of receiver and source positions do not match' )
end
if dim_f(1) ~= 1
    if dim_f(2) ~= 1
        error( 'Invalid frequency. Use row or column vector' );
    end
    frequencies = frequencies';
end


%% Variables
Apex_Point = wedge.get_aperture_point( source_pos, receiver_pos );
Src_Apex_Dir = ( Apex_Point - source_pos ) ./ Norm( Apex_Point - source_pos );
Apex_Rcv_Dir = ( receiver_pos - Apex_Point ) ./ Norm( receiver_pos - Apex_Point );
detour = Norm( Apex_Point - source_pos ) + Norm( receiver_pos - Apex_Point ) - Norm( receiver_pos - source_pos );
c = speed_of_sound;
lambda = c ./ frequencies;
N = 2 * detour ./ lambda; % Fresnel number N
r_dir = Norm( receiver_pos - source_pos );

in_shadow_zone = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos );

phi = acos( dot( Apex_Rcv_Dir( in_shadow_zone, : ), Src_Apex_Dir( in_shadow_zone, : ), 2 ) ); % angle between receiver and shadow boundary
phi( phi > pi/4 ) = pi/4;
phi_0 = transition_const;


c_norm = 10^(5/20);
c_approx = repmat( 1 + ( c_norm - 1 ) .* exp( -phi/phi_0 ), 1, numel(frequencies) );

%% Transfer function
% From Handbook of Acoustics page 117 eq. 4.13
H_dir = repmat( 1 ./ r_dir, 1, numel(frequencies) );
H_diffr( :, ~in_shadow_zone ) = zeros( numel( frequencies ), sum( ~in_shadow_zone ) );
H_diffr( :, in_shadow_zone ) = c_approx' .* ( ( 10^(5/20) * sqrt( 2 * pi * N(in_shadow_zone, :) ) ./ tanh( sqrt( 2*pi*N(in_shadow_zone, :) ) ) ).^(-1) .* H_dir(in_shadow_zone, :) )';

end

function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end