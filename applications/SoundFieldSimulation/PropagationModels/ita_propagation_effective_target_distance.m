function [ distance ] = ita_propagation_effective_target_distance( propagation_path, anchor_idx )
%ITA_PROPAGATION_EFFECTIVE_TARGET_DISTANCE Returns the forward distance from given anchor index to
% the next anchor type that requires a field value, e.g. a sensor or
% diffraction item. Integrates distance when one or multiple specular
% reflections are ahead.
%

if nargin < 2
   error 'You are missing the arguments "propagation_path" and "anchor_idx"'
end

if anchor_idx < 1
    error 'Invalid anchor id, was zero or negative'
end

N = numel( propagation_path.propagation_anchors );
if anchor_idx >= N
    error 'Invalid anchor id, greater or equal than number of anchors'
end

next_segment_vec = propagation_path.propagation_anchors{ anchor_idx + 1 }.interaction_point - propagation_path.propagation_anchors{ anchor_idx }.interaction_point;
distance = norm( next_segment_vec );

for m = anchor_idx : 1 : N - 1
    anchor = propagation_path.propagation_anchors{ m + 1 };
    if strcmpi( anchor.anchor_type, 'specular_reflection' )
        current_segment_vec = propagation_path.propagation_anchors{ m + 1 }.interaction_point - propagation_path.propagation_anchors{ m }.interaction_point;
        distance = distance + norm( current_segment_vec );
    else
        break
    end
end

end

