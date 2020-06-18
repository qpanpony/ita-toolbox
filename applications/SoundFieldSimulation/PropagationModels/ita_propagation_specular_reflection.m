function [ freq_data_linear ] = ita_propagation_specular_reflection( anchor, source_direction, target_direction, fs, fft_degree )
%ITA_PROPAGATION_SPECULAR_REFLECTION Returns the attenuation transfer function
%of the specular reflection e.g. based on reflection factor in frequency domain for a
%given in/out direction, sampling rate and fft degree (defaults to fs = 44100 and fft_degree = 15)
%

if nargin < 2
   error 'You are missing second argument "target_direction"'
end

if nargin < 3
    fs = 44100;
end
if nargin < 4
    fft_degree = 15;
end

if ~isfield( anchor, 'anchor_type' )
    error( 'The anchor argument does not contain a field "anchor_type"' )
end

warning( 'ita_propagation_specular_reflection not implemented yet, returning perfectly reflected transfer function values' )
% @todo generate reflection data set from source_direction and
% target_direction, if necessary, and return attenuation filter



specrefl_tf = itaAudio;
specrefl_tf.samplingRate = fs;
specrefl_tf.fftDegree = fft_degree;
specrefl_tf.freqData = ones( specrefl_tf.nBins, 1 );
freq_data_linear = specrefl_tf.freqData;

end

