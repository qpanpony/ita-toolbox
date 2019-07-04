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


%% Calculation
apex_Point = wedge.get_aperture_point( source_pos, receiver_pos );
r_dir = norm( receiver_pos - source_pos );
detour = norm( apex_Point - source_pos ) + norm( receiver_pos - apex_Point ) - norm( receiver_pos - source_pos );
lambda = speed_of_sound ./ frequencies;

N = 2 * detour ./ lambda; % Fresnel number N

in_shadow_zone = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos );

H_dir = 1 ./ r_dir;
if in_shadow_zone
    % From Handbook of Acoustics page 117 eq. 4.13 + inverted phase (pressure release first)
    H_diffr = ( -1 ) * ( ( 10^(5/20) * sqrt( 2 * pi * N ) ./ tanh( sqrt( 2 * pi * N ) ) ).^(-1) .* H_dir );
else
    H_diffr = zeros( size(frequencies) ); % diffraction field outside the shadow zone is not considered with Maekawa's method
end

end
