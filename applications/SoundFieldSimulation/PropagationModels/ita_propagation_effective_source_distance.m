function [ distance ] = ita_propagation_effective_source_distance( propagation_path, anchor_idx )
%ITA_PROPAGATION_SPECULAR_REFLECTION Returns the attenuation transfer function
%of the specular reflection e.g. based on reflection factor in frequency domain for a
%given in/out direction sampling rate and fft degree (defaults to fs = 44100 and fft_degree = 15)
%

if nargin < 2
   error 'You are missing the arguments "propagation_path" and "anchor_idx"'
end

if anchor_idx < 2
    error 'Invalid anchor id, effective source distance calculation requires at least one previous propagation anchor'
end

warning( 'ita_propagation_effective_source_distance not implemented yet, returning neutral transfer function values' )
% @todo backtrace effective source distance

assert( numel( propagation_path.propagation_anchors ) >= anchor_idx );

last_segment_vec = propagation_path.propagation_anchors{ anchor_idx - 1 }.interaction_point - propagation_path.propagation_anchors{ anchor_idx }.interaction_point;
distance = norm( last_segment_vec );

for m = anchor_idx : -1 : 2
    anchor = propagation_path.propagation_anchors{ m - 1 };
    if strcmpi( anchor.anchor_type, 'specular_reflection' )
        current_segment_vec = propagation_path.propagation_anchors{ m - 1 }.interaction_point - propagation_path.propagation_anchors{ m }.interaction_point;
        distance = distance + norm( current_segment_vec );
    else
        break
    end
end

end

