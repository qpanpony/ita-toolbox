function [ freq_data_linear ] = ita_propagation_diffraction( anchor, effective_source_position, effective_receiver_position, diffraction_model, fs, fft_degree, c )
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
if nargin < 7
    c = 341;
end

if ~isfield( anchor, 'anchor_type' )
    error( 'The anchor argument does not contain a field "anchor_type"' )
end


diffraction_tf = itaAudio();
diffraction_tf.samplingRate = fs;
diffraction_tf.fftDegree = fft_degree;
diffraction_tf.freqData = ones( diffraction_tf.nBins, 1 );

% @todo filbert: assemble wedge from anchor infos

%aperture_point = anchor.interaction_point( 1:3 )';
n1 = anchor.main_wedge_face_normal( 1:3 )';
n2 = anchor.opposite_wedge_face_normal( 1:3 )';
loc = anchor.vertex_start( 1:3 )';
endPt = anchor.vertex_end( 1:3 )';
len = norm( endPt - loc );

% check if wedge is a screen
if( abs( cross(n1, n2) ) < itaInfiniteWedge.set_get_geo_eps )
    aperture_dir = ( anchor.vertex_end( 1:3 )' - anchor.vertex_start( 1:3 )' ) / len;
    w = itaSemiInfinitePlane( n1, loc, aperture_dir );
    if strcmpi( diffraction_model, 'btms' )
        finWedge = itaFiniteWedge( n1, n2, loc, len );
        finWedge.aperture_direction = aperture_dir;
        finWedge.aperture_end_point = endPt;
    end
else
    w = itaInfiniteWedge( n1, n2, loc );
end


% Legacy
if size( effective_source_position, 1 ) == 4
    effective_source_position = effective_source_position( 1:3 )';
end
if size( effective_receiver_position, 1 ) == 4
    effective_receiver_position = effective_receiver_position( 1:3 )';
end

switch( diffraction_model )
    case 'utd'
        [ utd_tf, ~, ~ ] = ita_diffraction_utd( w, effective_source_position, effective_receiver_position, diffraction_tf.freqVector( 2:end )', c ); 
        diffraction_tf.freqData = [ 0; utd_tf ];
        
        apex_point = w.get_aperture_point( effective_source_position, effective_receiver_position );
        distance = norm( apex_point - effective_source_position ) + norm( effective_receiver_position - apex_point );
        spreading_loss = ita_propagation_spreading_loss( distance );
        phase_delay = ita_propagation_delay( distance, c, fs, fft_degree );
        
        normilization_porpagation = spreading_loss * phase_delay;
        
        diffraction_tf.freqData = diffraction_tf.freqData ./ normilization_porpagation;
        
    case 'maekawa'
        error 'not implemented'
        
    case 'btms'
        btms_tf = ita_diffraction_btms( finWedge, effective_source_position( 1:3 )', effective_receiver_position( 1:3 )', diffraction_tf.samplingRate, diffraction_tf.nBins, c );
        diffraction_tf.freqData = btms_tf;
        
        apex_point = w.get_aperture_point( effective_source_position( 1:3 )', effective_receiver_position( 1:3 )' );
        distance = norm( apex_point - effective_source_position ) + norm( effective_receiver_position - apex_point );
        spreading_loss = ita_propagation_spreading_loss( distance );
        phase_delay = ita_propagation_delay( distance, c, fs, fft_degree );
        
        normilization_porpagation = spreading_loss * phase_delay;
        
        diffraction_tf.freqData = diffraction_tf.freqData ./ normilization_porpagation;
end

freq_data_linear = diffraction_tf.freqData;

end

