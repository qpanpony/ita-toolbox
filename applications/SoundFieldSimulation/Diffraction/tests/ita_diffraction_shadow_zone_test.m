%% Init scene
% infite wedge
wdgNormal_1 = [1, 1, 0];
wdgNormal_2 = [-1, 1, 0];
wdgLoc = [0 0 2];
infWdg = itaInfiniteWedge(wdgNormal_1 / norm( wdgNormal_1 ), wdgNormal_2 / norm( wdgNormal_2 ), wdgLoc);

% screen
screenNormal_1 = [ 1, 0, 0];
screenNormal_2 = [-1, 0, 0];
screenLoc = wdgLoc;
screenApexDir = [0, 0, 1];
infScreen = itaSemiInfinitePlane(screenNormal_1, screenNormal_2, screenLoc);

% source
srcPosFacingMainSide = 3/sqrt(1) * [ 1, 0, 0];
srcPosFacingOppositeSide = 3/sqrt(1) * [-1, 0, 0];
srcPosFacingBothSides = 3/sqrt(1) * [ 0, 1, 0];

% receiver
rcvStartPos = 3/sqrt(2) * [ 1, -1, 0];
rcvEndPos = 3/sqrt(2) * [-1, -1, 0];
numOfRcvPositions = 100; % set number of receiver to be aligned around the aperture

% Discard boundary positions to avoid numerical inaccuracies (reasonable if these positions are on the wedge face)
discardRcvStartPos = true;
discardRcvEndPos = true;

%% Align receivers around aperture
apexPoint = infWdg.get_aperture_point(srcPosFacingMainSide, rcvStartPos);
referencFaceIsMainSide = infWdg.point_facing_main_side( srcPosFacingOppositeSide );

rcvPosAngleStart = infWdg.get_angle_from_point_to_wedge_face(rcvStartPos, referencFaceIsMainSide);
rcvPosAngleEnd = infWdg.get_angle_from_point_to_wedge_face(rcvEndPos, referencFaceIsMainSide);
rcvAnglesFromRefFace = linspace( rcvPosAngleStart, rcvPosAngleEnd, numOfRcvPositions );

% Set different receiver positions rotated around the aperture
rcvPositions = ita_align_points_around_aperture( infWdg, rcvStartPos, rcvAnglesFromRefFace, apexPoint, referencFaceIsMainSide );

% Avoid first and last receiver position if wanted
if discardRcvStartPos
    rcvPositions = rcvPositions(2:end, :);
end
if discardRcvEndPos
    rcvPositions = rcvPositions(1:end-1, :);
end
numOfRcvPositions = size(rcvPositions, 1); % update number of receiver positions

%% Calculations
inShadowZone_SrcFacingMainSide = false(numOfRcvPositions, 1);
inShadowZone_SrcFacingOppSide = false(numOfRcvPositions, 1);
inShadowZone_SrcFacingBothSides = false(numOfRcvPositions, 1);

% Case1: source is facing wedge main face
for i = 1 : numOfRcvPositions
    inShadowZone_SrcFacingMainSide(i) = ita_diffraction_shadow_zone( infWdg, srcPosFacingMainSide, rcvPositions(i, :) );
end

% Case2: source is face wegde opposite face
for i = 1 : numOfRcvPositions
    inShadowZone_SrcFacingOppSide(i) = ita_diffraction_shadow_zone( infWdg, srcPosFacingOppositeSide, rcvPositions(i, :) );
end
    
% Case3: sourc is faceing both wedge sides -> loacted above wedge
for i = 1 : numOfRcvPositions
    inShadowZone_SrcFacingBothSides(i) = ita_diffraction_shadow_zone( infWdg, srcPosFacingBothSides, rcvPositions(i, :) );
end

