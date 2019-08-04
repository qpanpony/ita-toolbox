function in_shadow = ita_diffraction_shadow_zone( wedge, source_pos, receiver_pos )
%ITA_DIFFRACTION_SHADOW_ZONE Returns true if receiver is, from the source's
%point of view, covered by the wedge and therefor inside the shadow region

%% assertions
if ~numel( source_pos ) == 3
    error( 'Source point must be of dimension 3')
end
if ~numel( receiver_pos )
    error( 'Receiver point must be of dimension 3')
end

if ~wedge.point_outside_wedge( source_pos )
    error( 'Source point must be outside of wedge' )
end

if ~wedge.point_outside_wedge( receiver_pos )
    error( 'Receiver point must be outside of wedge' )
end


%% Validations

% Inner edges can't create shadow zones
if isa( wedge, 'itaInfiniteWedge' )
    if strcmpi( wedge.edge_type, 'inner_edge' )
        in_shadow = false;
        return
    end
end

source_pos_above_main_plane = dot( wedge.main_face_normal, source_pos - wedge.location ) >= 0;
source_pos_above_opposite_plane = dot( wedge.opposite_face_normal, source_pos - wedge.location ) >= 0;

receiver_pos_above_main_face = dot( wedge.main_face_normal, receiver_pos - wedge.location ) >= 0;
receiver_pos_above_opposite_face = dot( wedge.opposite_face_normal, receiver_pos - wedge.location ) >= 0;

if source_pos_above_main_plane && receiver_pos_above_main_face
    in_shadow = false;
    return
end

if source_pos_above_opposite_plane && receiver_pos_above_opposite_face
    in_shadow = false;
    return
end

% Only cases left: one of source / receiver is above main and other below
% opposite face plane

if source_pos_above_main_plane
    source_shadow_boundary_plane_dir = cross( wedge.aperture_direction, source_pos - wedge.location );
    source_shadow_boundary_plane_normal = source_shadow_boundary_plane_dir / norm( source_shadow_boundary_plane_dir );
    if dot( source_shadow_boundary_plane_normal, receiver_pos - source_pos ) >= 0
        in_shadow = false;
    else
        in_shadow = true;
    end
    return
end

if source_pos_above_opposite_plane
    source_shadow_boundary_plane_dir = cross( wedge.aperture_direction, source_pos - wedge.location );
    source_shadow_boundary_plane_normal = source_shadow_boundary_plane_dir / norm( source_shadow_boundary_plane_dir );
    if dot( source_shadow_boundary_plane_normal, receiver_pos - source_pos ) >= 0
        in_shadow = true;
    else
        in_shadow = false;
    end
    return
end

assert( false ) % We should have a decision and used a return directive until this line

end
