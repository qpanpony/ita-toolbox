function in_shadow = ita_diffraction_shadow_zone( wedge, sourcePos, receiverPos )
%ITA_DIFFRACTION_SHADOW_ZONE Returns true if receiver is, from the source's
%point of view, covered by the wedge and therefor inside the shadow region

%% assertions
if ~numel( sourcePos ) == 3
    error( 'Source point must be of dimension 3')
end
if ~numel( receiverPos )
    error( 'Receiver point must be of dimension 3')
end

if ~wedge.point_outside_wedge( sourcePos )
    error( 'Source point must be outside of wedge' )
end

if ~wedge.point_outside_wedge( receiverPos )
    error( 'Receiver point must be outside of wedge' )
end

%% Set variables
apexPoint = wedge.get_aperture_point( sourcePos, receiverPos ); % point on aperture which is on shortest connection of source and receiver across the aperture
referenceFaceIsMainFace = ~wedge.point_facing_main_side( sourcePos ); % true if main wedge face is starting point for every angle measure from face into the room

% choose coordinate system of face normals and aperture direction according
% to source facing wedge face resulting in a clockwise rotation system
if referenceFaceIsMainFace
    mainWedgeFaceNormal = wedge.main_face_normal;
    oppositeWedgeFaceNormal = wedge.opposite_face_normal;
    apexDir =  wedge.aperture_direction;
else
    mainWedgeFaceNormal = wedge.opposite_face_normal;
    oppositeWedgeFaceNormal = wedge.main_face_normal;
    apexDir = -wedge.aperture_direction;
end

                         
% Use auxiliary shadow plane defined by aperture and source position -> border of the shadow zone
sourceApexDirection = ( apexPoint - sourcePos ) ./ norm( apexPoint - sourcePos ) ;

% Define shadow plane normal always pointing away from the wedge
shadowPlaneNormal = -cross( sourceApexDirection, apexDir ) ./ norm( cross( sourceApexDirection, apexDir ) );

% Distances from source position to each wedge face
distFromSrc2MainFace = dot( sourcePos - apexPoint, mainWedgeFaceNormal );
distFromSrc2OppositeFace = dot( sourcePos - apexPoint, oppositeWedgeFaceNormal );

% Check if source position is above wedge facing both wedge faces
sourceFacingBothWedgeFaces = distFromSrc2MainFace >= -wedge.set_get_geo_eps && distFromSrc2OppositeFace >= -wedge.set_get_geo_eps;


%% Consider different cases
if sourceFacingBothWedgeFaces 
    % no shadow region possible
    in_shadow = false;
else
    % shadow region exists
    distFromRcv2ShadowPlane = dot( receiverPos - apexPoint, shadowPlaneNormal );
    distFromRcv2MainFace = dot( receiverPos -apexPoint, mainWedgeFaceNormal );

    rcvInFrontOfMainFace = distFromRcv2MainFace >= -wedge.set_get_geo_eps;
    rcvAboveShadowPlane = distFromRcv2ShadowPlane >= -wedge.set_get_geo_eps;

    if rcvAboveShadowPlane || rcvInFrontOfMainFace
        in_shadow = false;
    else
        in_shadow = true;
    end
end

end
