classdef itaPlaneWedge < itaInfiniteWedge
    %ITAPLANEWEDGE special case of itaInfiniteWedge
    %   Case of wedge with opening angle of pi
    
    methods
        function obj = itaPlaneWedge( plane_normal, location, aperture_direction )
            obj@itaInfiniteWedge( plane_normal, plane_normal, location );
            obj.aperture_direction = aperture_direction;
        end
    end
end