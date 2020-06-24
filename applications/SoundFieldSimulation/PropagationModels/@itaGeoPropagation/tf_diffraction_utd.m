function [ linear_freq_data ] = tf_diffraction_utd( obj, wedge, source_pos, receiver_pos )
%TF_DIFFRACTION_UTD Calculates the diffraction filter based on uniform
%theory of diffraction (with Kawai approximation). 

[ ~, D, A ] = ita_diffraction_utd( wedge, source_pos, receiver_pos, obj.freq_vec( 2:end ), obj.c );
linear_freq_data = [ 0; A .* D ];

end
