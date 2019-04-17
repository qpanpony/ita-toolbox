function [ freq_data_linear ] = ita_propagation_directivity( anchor, target_direction, fs, fft_degree )
%ITA_PROPAGATION_DIRECTIVITY Calculates the directivity function
% in frequency domain for a given target direction, sampling rate and fft degree (defaults to fs = 44100 and fft_degree = 15)
% Can be used for emitter and sensor objects.

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

warning( 'ita_propagation_directivity not implemented yet, returning neutral transfer function values' )
% @todo select target_direction data set from directivity database and interpolate in frequency
% domain, if necessary

directivity_tf = itaAudio();
directivity_tf.samplingRate = fs;
directivity_tf.fftDegree = fft_degree;
directivity_tf.freqData = ones( 1, directivity_tf.nBins );
freq_data_linear = directivity_tf.freqData;

end

