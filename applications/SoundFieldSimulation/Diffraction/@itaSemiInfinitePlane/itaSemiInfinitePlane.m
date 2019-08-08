classdef itaSemiInfinitePlane < itaInfiniteWedge
    %ITASEMIINFINITEPLANE Special case of itaInfiniteWedge
    %   Case of a wedge with opening angle of 2pi.
    % A right-handed coordinate system is assumed, where the face normal
    % and the aperture direction define the third axis to point INTO the
    % screen.
    
    methods
        function obj = itaSemiInfinitePlane( main_face_normal, location, aperture_direction )
            obj@itaInfiniteWedge( main_face_normal, -main_face_normal, location, 'outer_edge', aperture_direction );
        end
    end
end

