function diffr_field = ita_diffraction_utd_approx( wedge, source_pos, receiver_pos, freq_vec, speed_of_sound, transition_constant )
%ITA_DIFFRACTION_UTD Calculates the diffraction filter based on uniform
%theory off diffraction (with Kawai approximation) only in shadow regions.
%To preserve continuity of the total sound field in e.g. shadow boundaries,
%a normalization is taken to account (approximation by Tsingos et. al.)
%
% Literature:
%   [1] Tsingos, Funkhouser et al. - Modeling Acoustics in Virtual Environments using the Uniform Theory of Diffraction
%
% Example:
%   att = ita_diffraction_utd_approximated( wedge, source_pos, receiver_pos, frequency_vec, speed_of_sound )
%
%% Assertions
if nargin < 6
    transition_constant = 0.1;
end

in_shadow_zone = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos );
if ~in_shadow_zone
    diffr_field = zeros( size( freq_vec ) );
    return
end

%% Variables
apex_point = wedge.get_aperture_point( source_pos, receiver_pos );
dir_src_2_apex_pt = ( apex_point - source_pos ) ./ norm( apex_point - source_pos );
dir_apex_pt_2_rcv = ( receiver_pos - apex_point ) ./ norm( receiver_pos - apex_point );
r = norm( apex_point - source_pos );  % Distance Source to Apex point
rho = norm( receiver_pos - apex_point );  % Distance Apex point to Receiver
detour = r + rho;

% consider a virtual receiver located at the shadow boundary
virt_rcv_at_SB = source_pos + dir_src_2_apex_pt .* detour; % Virtual position of receiver at shadow boundary
if ~wedge.point_outside_wedge( virt_rcv_at_SB )
    diffr_field = zeros( size( f ) );
    return
end

angle_rcv_to_SB = acos( dot( dir_apex_pt_2_rcv, dir_src_2_apex_pt ) ); % angle between receiver and shadow boundary
if angle_rcv_to_SB > pi/4 
    angle_rcv_to_SB = pi/4;
end

% Incident field at shadow boundary
k = 2 * pi * freq_vec / speed_of_sound;
virt_inc_field_at_SB = 1 ./ norm( virt_rcv_at_SB - source_pos ) .* exp( -1i .* k .* detour );

% virutal diffracted field at shadow boundary
virt_diffr_field_at_SB = ita_diffraction_utd( wedge, source_pos, virt_rcv_at_SB, freq_vec, speed_of_sound );

% diffracted field at receiver position in shadow zone
diffr_field_at_rcv_pos = ita_diffraction_utd( wedge, source_pos, receiver_pos, freq_vec, speed_of_sound );

%% Filter Calculation
% Normalize diffracted field at receiver position in shadow zone
norm_factor = virt_inc_field_at_SB ./ virt_diffr_field_at_SB;
norm_diffr_field = norm_factor .* diffr_field_at_rcv_pos;

% Interpolate magnitude between orig diffracted field at receiver and normalized
% diffracted field
exp_term = exp( - angle_rcv_to_SB / transition_constant );
diffr_field = norm_diffr_field * exp_term + diffr_field_at_rcv_pos * ( 1 - exp_term );

end