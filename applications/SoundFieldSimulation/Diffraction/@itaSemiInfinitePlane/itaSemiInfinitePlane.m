classdef itaSemiInfinitePlane < itaInfiniteWedge
    %ITASEMIINFINITEPLANE Special case of itaInfiniteWedge
    %   Case of a wedge with opening angle of 2pi.
    
    methods
        function obj = itaSemiInfinitePlane( main_face_normal, location, aperture_direction )
            obj@itaInfiniteWedge( main_face_normal, -main_face_normal, location );
            obj.aperture_direction = aperture_direction;
        end
    end
end

