function [ linear_freq_data ] = tf_diffraction_maekawa( wedge, eff_source_pos, eff_receiver_pos )
%TF_DIFFRACTION_UTD Calculates the diffraction filter based on uniform
%theory of diffraction (with Kawai approximation). 

[ H_diffr, ~ ] = ita_diffraction_maekawa( wedge, eff_source_pos( 1:3 ), eff_receiver_pos( 1:3 ), obj.freq_vec( 2:end ), obj.c );
eff_direct = norm( eff_source_pos( 1:3 ) - eff_source_pos( 1:3 ) );
H_eff = 1 ./ eff_direct;
linear_freq_data = [ 0; H_diffr ./ H_eff ]; % Normalizing incident field, it's taken care of by previous segment.

end
