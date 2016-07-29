classdef WRW3D_Boundary < handle
    %WRW3D_BOUNDARY contains one surface, which is part of a geometry used
    %for a WRW simulation in 3D space.

    properties
        polygon     = [];                           % surrounding polygon
        normal      = [];                           % normal vector of the polygon
        is_portal   = false;                        % flag whether boundary is a portal connecting two geometries or not
        material    = WRW3D_Material.empty();       % (only if no portal) material the boundary consists of
        backside    = WRW3D_Mesh_Boundary.empty();  % (only if portal) backsided boundary in another geometry the portalcc is connected to
        elements    = [];
    end
    
    properties (Hidden)
        plot_toggle = true;                         % flag wether boundary is plottet or not (true/false)
    end
    
    
    methods
        function set.elements(obj, elements)
            
            obj.elements = elements;
        end
            
            function set.normal(obj, normal)
            if ~isfloat(normal),  error('WRW3D_Boundary.set.normal: Value has to be a float.'); end
            if isempty(normal),   error('WRW3D_Boundary.set.normal: Given normal is empty.'); end
            if size(normal,2)~=3, error('WRW3D_Boundary.set.normal: Given normal has wrong dimensions.'); end
            if size(normal,1)<3,  error('WRW3D_Boundary.set.normal: Given normal has to consist of at least three points.'); end
            % Ensure that normal is closed:
            if ~(normal(1,1)==normal(end,1) && normal(1,2)==normal(end,2) && normal(1,3)==normal(end,3))
                normal = [normal; normal(1,:)];
            end
            obj.normal = normal;
            end
        
        function set.polygon(obj, polygon)
            if ~isfloat(polygon),  error('WRW3D_Boundary.set.polygon: Value has to be a float.'); end
            if isempty(polygon),   error('WRW3D_Boundary.set.polygon: Given polygon is empty.'); end
            if size(polygon,2)~=3, error('WRW3D_Boundary.set.polygon: Given polygon has wrong dimensions.'); end
            if size(polygon,1)<3,  error('WRW3D_Boundary.set.polygon: Given polygon has to consist of at least three points.'); end
            % Ensure that polygon is closed:
            if ~(polygon(1,1)==polygon(end,1) && polygon(1,2)==polygon(end,2) && polygon(1,3)==polygon(end,3))
                polygon = [polygon; polygon(1,:)];
            end
            obj.polygon = polygon;
        end
        function set.is_portal(obj, is_portal)
            if ~islogical(is_portal), error('WRW3D_Boundary.set.is_portal: Value has to be a logical.'); end
            if ~isscalar(is_portal),  error('WRW3D_Boundary.set.is_portal: Value has to be scalar.'); end
            obj.is_portal = is_portal;
        end
        function set.material(obj, material)
            if obj.is_portal,                   error('WRW3D_Boundary.set.material: material property can not be set for a portal.'); end %#ok<MCSUP>
            if ~isscalar(material),             error('WRW3D_Boundary.set.material: Value has to be scalar.'); end
            if ~isa(material,'WRW3D_Material'), error('WRW3D_Boundary.set.material: Value has to be an instance of the class WRW3D_Material.'); end
            obj.material = material;
        end
        function set.backside(obj, backside)
            if ~obj.is_portal,                   error('WRW3D_Boundary.set.backside: backside property can not be set for a boundary not being a portal.'); end %#ok<MCSUP>
            if ~isa(backside, 'WRW3D_Boundary'), error('WRW3D_Boundary.set.backside: Value has to be an instance of the class WRW3D_Boundary.'); end
            if ~isscalar(backside),              error('WRW3D_Boundary.set.backside: Value has to be a scalar.'); end
            if ~backside.is_portal,              error('WRW3D_Boundary.set.backside: Given instance of the class WRW3D_Boundary must be a portal.'); end
            obj.backside = backside;
        end
        function set.plot_toggle(obj, plot_toggle)
            if ~islogical(plot_toggle), error('WRW3D_Boundary.set.plot_toggle: Value has to be a logical.'); end
            if ~isscalar(plot_toggle),  error('WRW3D_Boundary.set.plot_toggle: Value has to be scalar.'); end
            obj.plot_toggle = plot_toggle;
        end
    end

end



