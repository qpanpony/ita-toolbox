function in_reflection_zone = ita_diffraction_reflection_zone( wedge, source_pos, receiver_pos, use_main_face )
%ITA_DIFFRACTION_REFLECTION_ZONE Returns true if receiver is, from the source's
%point of view, in the reflection zone of wedge's main (use_main_face = true) or opposite face
%
% Example: in_reflection_zone = ita_diffraction_reflection_zone( wedge, source_pos, receiver_pos, use_main_face )
%

%% Assertions

if ~numel( source_pos ) == 3
    error( 'Source point must be of dimension 3')
end

if ~numel( receiver_pos )
    error( 'Receiver point must be of dimension 3')
end


if use_main_face
    n = wedge.main_face_normal;
    cs_sign = 1;
else
    n = wedge.opposite_face_normal;
    cs_sign = -1;
end


%% Validations

source_distance = dot( n, source_pos - wedge.location );
source_pos_above_main_plane = ( source_distance >= 0 );
receiver_distance = dot( n, receiver_pos - wedge.location );
receiver_pos_above_main_face = ( receiver_distance >= 0 );

if ~source_pos_above_main_plane || ~receiver_pos_above_main_face
    in_reflection_zone = false;
    return;
end

% Point-
source_pos_proj = source_pos - source_distance * n;
receiver_pos_proj = receiver_pos - receiver_distance * n;

t = source_distance / ( source_distance + receiver_distance );
intersection_point = source_pos_proj + ( receiver_pos_proj - source_pos_proj ) * t;

e_z = cs_sign * cross( n, wedge.aperture_direction );

if dot( e_z, intersection_point - wedge.location ) >= 0
    % Intersection point lies to the left of aperture on wedge face ->
    % valid reflection
    in_reflection_zone = true;
else
    in_reflection_zone = false;
end

end
