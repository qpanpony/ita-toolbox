function diffr_field = ita_diffraction_utd_approximated( wedge, source_pos, receiver_pos, frequency_vec, speed_of_sound, transition_const )
%ITA_DIFFRACTION_UTD Calculates the diffraction filter based on uniform
%theory off diffraction (with Kawai approximation) only in shadow regions.
%To preserve continuity of the total sound field in e.g. shadow boundaries,
%a normalization is taken to account (approximation by Tsingos et. al.)
%
% Literature:
%   [1] Tsingos, Funkhouser et al. - Modeling Acoustics in Virtual Environments using the Uniform Theory of Diffraction
%
% Example:
%   att = ita_diffraction_utd( wedge, source_pos, receiver_pos, frequency_vec )
%
%% Assertions
if nargin < 6
    transition_const = 0.1;
end

%% Variables
Apex_Point = wedge.get_aperture_point( source_pos, receiver_pos );
Src_Apex_Dir = ( Apex_Point - source_pos ) ./ Norm( Apex_Point - source_pos );
Apex_Rcv_Dir = ( receiver_pos - Apex_Point ) ./ Norm( receiver_pos - Apex_Point );
rho = Norm( Apex_Point - source_pos );  % Distance Source to Apex point
r = Norm( receiver_pos - Apex_Point );  % Distance Apex point to Receiver
receiver_SB = source_pos + Src_Apex_Dir .* ( r + rho ); % Virtual position of receiver at shadow boundary
c = speed_of_sound;
k_vec = 2 * pi * frequency_vec ./ c; % Wavenumber

in_shadow_zone = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos );

phi = repmat( acos( dot( Apex_Rcv_Dir( in_shadow_zone, : ), Src_Apex_Dir( in_shadow_zone, : ), 2 ) ), 1, numel( frequency_vec ) ); % angle between receiver and shadow boundary
phi( phi > pi/4 ) = pi/4;
phi_0 = transition_const;

% Incident field at shadow boundary
E_incident_SB = ( 1 ./ Norm( receiver_SB - source_pos ) .* exp( -1i .* k_vec .* ( r + rho ) ) )';
% Diffracted field at shadow boundary
E_diff_SB = ita_diffraction_utd( wedge, source_pos, receiver_SB, frequency_vec, c );

%% Filter Calculation
% Normalization factor
C_norm = E_incident_SB( :, in_shadow_zone ) ./ E_diff_SB( :, in_shadow_zone );
% Considering Interpolation to standard UTD form
C_total = 1 + ( C_norm - 1 ) .* ( exp( -phi/phi_0 ) )';

% if any( any( receiver_pos( in_shadow_zone, : ) ) )
    att_shadow_zone = ita_diffraction_utd( wedge, source_pos, receiver_pos, frequency_vec, c );
    att_shadow_zone = C_total .* att_shadow_zone; % Normalization and interpolation
    diffr_field( :, in_shadow_zone ) = att_shadow_zone;
% end

diffr_field( :, ~in_shadow_zone ) = zeros( numel( frequency_vec ), sum( ~in_shadow_zone ) );

end

function res = Norm( A )
    res = sqrt( sum( A.^2, 2 ) );
end