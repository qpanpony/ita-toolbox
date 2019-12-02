function H_diffr = ita_diffraction_maekawa_approx( wedge, source_pos, receiver_pos, frequencies, speed_of_sound, transition_const )
% Calculates the attenuation filter at a diffraction wedge for source
% and receiver location(s) at given frequencies. For purpose of
% continuity at shadow boundary, an interpolation with exponential function
% towards target response in shadow region is used.
%
% Usage: see ita_diffraction_maekawa
% Parameter: transition_const = 0.2 rad (default) determines the angle into
% shadow region where transition reaches target filter of Maekawa's
% formula.
%


%% Assertions
assert( isa( wedge, 'itaInfiniteWedge' ) )
if nargin < 6
    transition_const = 0.2;
end

%% Variables
apex_point = wedge.approx_aperture_point( source_pos, receiver_pos );
SA = ( apex_point - source_pos ) ./ norm( apex_point - source_pos );
AR = ( receiver_pos - apex_point ) ./ norm( receiver_pos - apex_point );
detour = norm( apex_point - source_pos ) + norm( receiver_pos - apex_point ) - norm( receiver_pos - source_pos );
c = speed_of_sound;
lambda = c ./ frequencies;
N = 2 * detour ./ lambda; % Fresnel number N
r_dir = norm( receiver_pos - source_pos );

in_shadow_zone = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos );

phi = acos( dot( AR, SA ) ); % angle between receiver and shadow boundary
if phi > pi/4
    phi = pi/4;
end
phi_0 = transition_const;

c_norm = 10^(5/20);
c_approx = repmat( 1 + ( c_norm - 1 ) .* exp( -phi/phi_0 ), 1, numel(frequencies) )';

%% Transfer function
if in_shadow_zone
    H_diffr = zeros( numel( frequencies ), 1 );
else
    % From Handbook of Acoustics page 117 eq. 4.13
    H_diffr = c_approx .* ( c_norm * sqrt( 2 * pi * N ./ tanh( sqrt( 2*pi*N ) ) ).^(-1) ./ r_dir );
end

end
