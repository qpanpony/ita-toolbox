function [ freq_data_linear ] = ita_propagation_diffraction( anchor, effective_source_position, effective_receiver_position, diffraction_model, fs, fft_degree )
%ITA_PROPAGATION_DIFFRACTION Returns the attenuation transfer function
%of the edge diffraction for certain model and given effective in/out positions 
%sampling rate and fft degree (defaults to fs = 44100 and fft_degree = 15)
%

global ita_speed_of_sound

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

if exist( 'ita_speed_of_sound', 'var' )
    c = ita_speed_of_sound; % m/s, speed of sound
else
    c = 341; % m/s, speed of sound
end

specrefl_tf = itaAudio;
specrefl_tf.samplingRate = fs;
specrefl_tf.fftDegree = fft_degree;
specrefl_tf.freqData = ones( specrefl_tf.nBins, 1 );

% @todo filbert: assemble wedge from anchor infos

%aperture_point = anchor.interaction_point( 1:3 )';
n1 = anchor.main_wedge_face_normal( 1:3 )';
n2 = anchor.opposite_wedge_face_normal( 1:3 )';
loc = anchor.vertex_start( 1:3 )';

w = itaInfiniteWedge( n1, n2, loc );

switch( diffraction_model )
    case 'utd'
        [ ~, D, ~ ] = ita_diffraction_utd( w, effective_source_position( 1:3 )', effective_receiver_position( 1:3 )', specrefl_tf.freqVector( 2:end ), c ); 
        specrefl_tf.freqData = [ 0 D ]';
        
    case 'maekawa'
    case 'btms'
end

freq_data_linear = specrefl_tf.freqData;

end

