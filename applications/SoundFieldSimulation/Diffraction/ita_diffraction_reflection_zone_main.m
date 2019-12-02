function reflection_zone = ita_diffraction_reflection_zone_main( wedge, source_pos, receiver_pos )
%ITA_DIFFRACTION_REFLECTION_ZONE returns true if receiver is within range
%of reflective waves by a wedge face
reflection_zone = false;

if ~wedge.point_outside_wedge( source_pos ) || ~wedge.point_outside_wedge( receiver_pos )
    error( 'invalid source or receiver location!' );
end

apex_point = wedge.approx_aperture_point( source_pos, receiver_pos );
source_apex_direction = ( apex_point - source_pos ) / norm( apex_point - source_pos );
eps = wedge.set_get_geo_eps;

% Distances of source from wedge faces
d1 = dot( source_pos, wedge.main_face_normal );
d2 = dot( source_pos, wedge.opposite_face_normal );
    
% Check for the source facing side(s) of the wedge
if d1 >= -eps && d2 >= -eps
%% Source facing both sides of the wedge
    % Check if source position is below face normal from aperture point
    check_normal_main_face = cross( wedge.main_face_normal, wedge.aperture_direction );
    check_normal_opposite_face = cross( -wedge.opposite_face_normal, wedge.aperture_direction );

    dist_below_main_face_normal = dot( -source_apex_direction, check_normal_main_face );
    dist_below_opposite_face_normal = dot( -source_apex_direction, check_normal_opposite_face );
    
    if dist_below_main_face_normal >= -eps && dist_below_opposite_face_normal >= -eps % Opening angle of wedge > 180°
        reflection_zone = true;
    elseif dist_below_main_face_normal >= -eps % Opening angle of wedge between 90° and 180°
        % Use of an auxiliary plane which is spanned by source apex direction and
        % aperture direction for evaluating if receiver is between source
        % position and wedge face.
        aux_norm = cross( -source_apex_direction, wedge.aperture_direction );
        dist = dot( receiver_pos - apex_point, aux_norm );
        if dist >= -eps
            reflection_zone = true;
        else
            % Angle of incidence
            beta = acos( dot( -source_apex_direction, wedge.opposite_face_normal ) );

            % Use of auxiliary plane describing the boundary of the
            % reflection zone
            refl_boundary_opposite_face = ita_rotation_rodrigues( -source_apex_direction, wedge.aperture_direction, 2*beta );
            refl_plane_normal_opposite_face = cross( refl_boundary_opposite_face, wedge.aperture_direction );

            % Check if receiver is in reflection zone
            dist_refl_opposite_face = dot( receiver_pos, refl_plane_normal_opposite_face );
            if dist_refl_opposite_face >= -eps
                reflection_zone = true;
            end
        end
    elseif dist_below_opposite_face_normal >= -eps % Opening angle of wedge between 90° and 180°
        % Use of an auxiliary plane which is spanned by source apex direction and
        % aperture direction for evaluating if receiver is between source
        % position and wedge face.
        aux_norm = cross( -source_apex_direction, wedge.aperture_direction );
        dist = dot( receiver_pos - apex_point, aux_norm );
        if dist >= -eps
            reflection_zone = true;
        else
            % Angle of incidence
            alpha = acos( dot( -source_apex_direction, wedge.main_face_normal ) );

            % Use of auxiliary plane describing the boundary of the
            % reflection zone
            refl_boundary_main_face = ita_rotation_rodrigues( -source_apex_direction, -wedge.aperture_direction, 2*alpha );
            refl_plane_normal_main_face = cross( -refl_boundary_main_face, wedge.aperture_direction );

            % Check if receiver is in reflection zone
            dist_refl_main_face = dot( receiver_pos, refl_plane_normal_main_face );
            if dist_refl_main_face >= -eps
                reflection_zone = true;
            end
        end
    else % Opening angle of wedge < 90°    
        % Angles of incidence
        alpha = acos( dot( -source_apex_direction, wedge.main_face_normal ) );
        beta = acos( dot( -source_apex_direction, wedge.opposite_face_normal ) );

        % Use of auxiliary planes describing the boundary of the
        % reflection zone
        refl_boundary_main_face = ita_diffraction_rotate_vectors_around_axis( -source_apex_direction, -wedge.aperture_direction, 2*alpha );
        refl_boundary_opposite_face = ita_diffraction_rotate_vectors_around_axis( -source_apex_direction, wedge.aperture_direction, 2*beta );
        refl_plane_normal_main_face = cross( -refl_boundary_main_face, wedge.aperture_direction );
        refl_plane_normal_opposite_face = cross( refl_boundary_opposite_face, wedge.aperture_direction );

        % Check if receiver is in reflection zone
        dist_refl_main_face = dot( receiver_pos, refl_plane_normal_main_face );
        dist_refl_opposite_face = dot( receiver_pos, refl_plane_normal_opposite_face );
        if dist_refl_main_face >= -eps || dist_refl_opposite_face >= -eps
            reflection_zone = true;
        end
    end
elseif d1 >= -eps
%% Source facing main face of the wedge
    % Check if source position is below face normal from aperture point
    check_normal = cross( wedge.main_face_normal, wedge.aperture_direction );
    if dot( -source_apex_direction, check_normal ) >= - eps
        % Angle of incidence
        alpha = acos( dot( -source_apex_direction, wedge.main_face_normal ) ); % Angle of incidence

        % Use of an auxiliary plane describing the boundary of the
        % reflection zone
        refl_boundary = ita_diffraction_rotate_vectors_around_axis( -source_apex_direction, wedge.aperture_direction, 2*alpha );
        refl_plane_normal = cross( refl_boundary, wedge.aperture_direction );

        % Check if receiver is in reflection zone
        dist = dot( receiver_pos - apex_point, refl_plane_normal );
        if dist >= -eps
            reflection_zone = true;
        end
    else
        % Use of an auxiliary plane which is spanned by source apex direction and
        % aperture direction for evaluating if receiver is between source
        % position and wedge face.
        aux_normal = cross( -source_apex_direction, wedge.aperture_direction );
        dist = dot( receiver_pos - apex_point, aux_normal );
        if dist >= -eps
            reflection_zone = true;
        end
    end
else
%% Source facing opposite face of the wedge
    % Check if source position is below face normal from aperture point
    check_normal = cross( wedge.opposite_face_normal, -wedge.aperture_direction );
    if dot( -source_apex_direction, check_normal ) >= - eps
        % Angle of incidence
        alpha = acos( dot( -source_apex_direction, wedge.opposite_face_normal ) ); % Angle of incidence

        % Use of an auxiliary plane describing the boundary of the
        % reflection zone
        refl_boundary = ita_diffraction_rotate_vectors_around_axis( -source_apex_direction, -wedge.aperture_direction, 2*alpha );
        refl_plane_normal = cross( wedge.aperture_direction, refl_boundary );

        % Check if receiver is in reflection zone
        dist = dot( receiver_pos - apex_point, refl_plane_normal );
        if dist >= -eps
            reflection_zone = true;
        end
    else
        % Use of an auxiliary plane which is spanned by source apex direction and
        % aperture direction. 
        aux_normal = cross( -source_apex_direction, -wedge.aperture_direction );
        dist = dot( receiver_pos - apex_point, aux_normal );
        if dist >= -eps
            reflection_zone = true;
        end
    end
end

end

