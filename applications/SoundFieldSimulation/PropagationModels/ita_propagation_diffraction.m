function [ freq_data_linear ] = ita_propagation_diffraction( anchor, effective_source_position, target_position, diffraction_model, fs, fft_degree )
%ITA_PROPAGATION_DIFFRACTION Returns the attenuation transfer function
%of the edge diffraction for certain model and given effective in/out positions 
%sampling rate and fft degree (defaults to fs = 44100 and fft_degree = 15)
%

if nargin < 3
   error 'You are missing several input argument'
end

if nargin < 4
    diffraction_model = 'utd';
end
if nargin < 5
    fs = 44100;
end
if nargin < 6
    fft_degree = 15;
end

if ~isfield( anchor, 'anchor_type' )
    error( 'The anchor argument does not contain a field "anchor_type"' )
end

warning( 'ita_propagation_diffraction not implemented yet, returning neutral transfer function values' )
% @todo generate diffraction filter from input values and generate
% according to requested model

specrefl_tf = itaAudio;
specrefl_tf.samplingRate = fs;
specrefl_tf.fftDegree = fft_degree;
specrefl_tf.freqData = ones( 1, specrefl_tf.nBins );

switch( diffraction_model )
    case 'utd'
    case 'maekawa'
    case 'btms'
end

freq_data_linear = specrefl_tf.freqData;

end

