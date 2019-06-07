function [ H_diffr, detour ] = ita_diffraction_maekawa( wedge, source_pos, receiver_pos, frequencies, speed_of_sound )
% Calculates the attenuation filter(s) at a diffraction wedge for source
% and receiver location(s) at given frequencies
%
% wedge: diffracting wedge (itaInfiniteWedge or derived class
% itaFiniteWedge)
% source_pos: position of the source
% receiver_pos: position of the receiver

%% Assertions
assert( isa( wedge, 'itaInfiniteWedge' ) )
dim_src = size( source_pos );
dim_rcv = size( receiver_pos );
dim_f = size( frequencies );
if dim_src(2) ~= 3
    if dim_src(1) ~= 3
        error( 'Source point(s) must be of dimension 3' )
    end
    source_pos = source_pos';
    dim_src = size( source_pos );
end
if dim_rcv(2) ~= 3
    if dim_rcv(1) ~= 3
        error( 'Receiver point(s) must be of dimension 3' )
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
% att = itaResult();
% att.freqVector = frequencies';

Apex_Point = wedge.get_aperture_point( source_pos, receiver_pos );
r_dir = norm( receiver_pos - source_pos );
detour = norm( Apex_Point - source_pos ) + norm( receiver_pos - Apex_Point ) - norm( receiver_pos - source_pos );
c = speed_of_sound; % Speed of sound in air with a temprature of 20°C
lambda = c ./ frequencies;

N = 2 * detour ./ lambda; % Fresnel number N

in_shadow_zone = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos );

% N( ~in_shadow_zone, : ) = - N( ~in_shadow_zone, : );

%% Transfer function
H_dir = repmat( 1 ./ r_dir, 1, numel(frequencies) );
H_diffr( :, ~in_shadow_zone' ) = zeros( numel( frequencies ), sum( ~in_shadow_zone ) );
% From Handbook of Acoustics page 117 eq. 4.13 + inverted phase (pressure
% release first)
H_diffr( :, in_shadow_zone' ) = ( -1 ) * ( ( 10^(5/20) * sqrt( 2 * pi * N(in_shadow_zone, :) ) ./ tanh( sqrt( 2*pi*N(in_shadow_zone, :) ) ) ).^(-1) .* H_dir(in_shadow_zone, :) )';


end
