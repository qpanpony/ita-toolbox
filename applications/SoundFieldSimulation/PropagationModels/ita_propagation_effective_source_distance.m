function [ distance ] = ita_propagation_effective_source_distance( propagation_path, anchor_idx )
%ITA_PROPAGATION_EFFECTIVE_SOURCE_DISTANCE Returns the backwards distance from given anchor index to
% the previous anchor type that provides a field value, e.g. a sensor or
% diffraction item. Integrates distance when one or multiple specular
% reflections are ahead.
%

if nargin < 2
   error 'You are missing the arguments "propagation_path" and "anchor_idx"'
end

if anchor_idx < 2
    error 'Invalid anchor id, effective source distance calculation requires at least one previous propagation anchor'
end

assert( numel( propagation_path.propagation_anchors ) >= anchor_idx );

if isa( propagation_path.propagation_anchors, 'cell' )
    last_segment_vec = propagation_path.propagation_anchors{ anchor_idx - 1 }.interaction_point - propagation_path.propagation_anchors{ anchor_idx }.interaction_point;
else
    last_segment_vec = propagation_path.propagation_anchors( anchor_idx - 1 ).interaction_point - propagation_path.propagation_anchors( anchor_idx ).interaction_point;
end
distance = norm( last_segment_vec );

for m = anchor_idx : -1 : 2
    if isa( propagation_path.propagation_anchors, 'cell' )
        anchor = propagation_path.propagation_anchors{ m - 1 };
    else
        anchor = propagation_path.propagation_anchors( m - 1 );
    end
    if strcmpi( anchor.anchor_type, 'specular_reflection' )
        if isa( propagation_path.propagation_anchors, 'cell' )
            current_segment_vec = propagation_path.propagation_anchors{ m - 2 }.interaction_point - anchor.interaction_point;
        else
            current_segment_vec = propagation_path.propagation_anchors( m - 2 ).interaction_point - anchor.interaction_point;
        end
        distance = distance + norm( current_segment_vec );
    else
        break
    end
end

end

