%% Init
% infite wedge
infWdg = create_rectangular_wedge;

% Point
pointStartPos = [ 1, 0, 0];
pointEndPos = [-1, 0, 0];
numOfPositions = 100;

%% Align points around aperture
apexPoint = [0, 0, 0];
pointCornerCases = [pointStartPos; pointEndPos];

referenceFaceIsMainSide = infWdg.point_facing_main_side( srcPosFacingMainSide );

pointPosAngleStart = infWdg.get_angle_from_point_to_wedge_face(pointStartPos1, referenceFaceIsMainSide);
pointPosAngleEnd = infWdg.get_angle_from_point_to_wedge_face(pointEndPos1, referenceFaceIsMainSide);
pointAnglesFromRefFace = linspace( pointPosAngleStart, pointPosAngleEnd, numOfPositions );

%% Set different receiver positions rotated around the aperture
rcvPositions = ita_align_points_around_aperture( infWdg, pointStartPos1, pointAnglesFromRefFace, apexPoint, referenceFaceIsMainSide );

