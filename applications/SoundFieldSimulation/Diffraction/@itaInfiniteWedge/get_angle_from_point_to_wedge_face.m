function alpha = get_angle_from_point_to_wedge_face( obj, point, use_main_face )
%get_angle_from_point_to_wedge_face    Returns angle (radiant) between
%   given point and a wedge face.
%   input:  point           arbitrary field point outside the wedge.
%           use_main_face   True for main face, otherwise opposite face
%                           is used.
%   output: theta           azimuth angle (radiant) in cylinder coordinates with
%                           the aperture as z axis. Between [0, 2*pi]

if nargin < 2 || use_main_face
    alpha = obj.angle_main_face( point );
else
    alpha = obj.angle_opposite_face( point );
end

end

