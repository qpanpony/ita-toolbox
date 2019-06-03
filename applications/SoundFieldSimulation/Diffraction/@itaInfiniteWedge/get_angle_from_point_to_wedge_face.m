function resAngle = get_angle_from_point_to_wedge_face( obj, pointPos, referenceWedgeFaceIsMainSide )
%GET_ANGLE_FROM_SOURCE_TO_WEDGE_FACE    Returns angle (radiant) between
%   given point and a wedge face.
%   input:  point_pos           arbitrary field point outside the wedge
%           reference_face      reference wedge face which the angle will
%                               be denoted from
%   output: theta               azimuth angle (radiant) in cylinder coordinates with
%                               the aperture as z axis. Between [0, 2*pi]

%% Assertions
if ~ita_diffraction_point_is_of_dim3( pointPos )
    error( 'Point has to be of dimension 3' );
end

if any( ~obj.point_outside_wedge( pointPos ) )
    error('Point(s) must be outside the wedge');
end

%% Begin
% define cartesian coordinate system
e_z = obj.aperture_direction;
if referenceWedgeFaceIsMainSide
    e_y = obj.main_face_normal;
else
    e_y = obj.opposite_face_normal;
end
e_x = cross( e_z, e_y );

% Determine coordinates of point in new coordinate system
x_new = dot( pointPos - obj.location, e_x );  
y_new = dot( pointPos - obj.location, e_y );

% Calculate angle between incedent ray from source to aperture point and reference wedge side
resAngle = atan2( y_new, x_new );
if resAngle < 0
    resAngle = resAngle + 2*pi; % -> output between [0, 2*pi]
end

end

