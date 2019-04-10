classdef WRW3D_Mesh_Boundary < handle
    %WRW3D_MESH_BOUNDARY contains the mesh of a boundary (WRW3D_Boundary).
    
    properties
        normal    = [];                             % normal perpendicular to the boundary
        points    = [];                             % mesh points representing the boundary (barycenter of the elements)
        dA        = [];                             % area each of the mesh points is representing (area of the elements)
        elements  = [];                             % polygonal element which the mesh consists of. Different elements are seperated by rows filled with NaNs.
        npoints   = [];                             % number of mesh points
        is_portal = false;                          % flag whether boundary is a portal or not
        material  = WRW3D_Material.empty();         % (only if no portal) material the boundary consists of
        backside  = WRW3D_Mesh_Boundary.empty();    % (only if portal) backsided boundary in another geometry the portal is connected to
    end
    
    properties (Hidden)
        index_begin = [];                           % begin of index range of collected mesh points for simulation
        index_end   = [];                           % end of index range of collected mesh points for simulation
        geometry    = WRW3D_Mesh_Geometry.empty();  % parent geometry mesh the boundary mesh belongs to
        original    = WRW3D_Boundary.empty();       % original boundary the mesh is made from
    end
    
    methods
        function set.normal(obj, normal)
            if ~isfloat(normal),            error('WRW3D_Mesh_Boundary.set.normal: Value has to be a float.'); end
            if ~all(size(normal) == [1 3]), error('WRW3D_Mesh_Boundary.set.normal: Value has to be a 1x3 vector.'); end
            obj.normal = normal;
        end
        function set.points(obj, points)
            if ~isfloat(points),  error('WRW3D_Mesh_Boundary.set.points: Value has to be a float.'); end
            if isempty(points),   error('WRW3D_Mesh_Boundary.set.points: Value must not be empty.'); end
            if size(points,2)~=3, error('WRW3D_Mesh_Boundary.set.points: Given points have to be three-dimensional.'); end
            obj.points = points;
        end
        function set.dA(obj, dA)
            if ~isfloat(dA),  error('WRW3D_Mesh_Boundary.set.dA: Value has to be a float.'); end
            if ~iscolumn(dA), error('WRW3D_Mesh_Boundary.set.dA: Value has to be a column vector'); end
            obj.dA = dA;
        end
        function set.elements(obj, elements)
            if ~isfloat(elements),  error('WRW3D_Mesh_Boundary.set.elements: Value has to be a float.'); end
            if isempty(elements),   error('WRW3D_Mesh_Boundary.set.elements: Value must not be empty.'); end
            if size(elements,2)~=3, error('WRW3D_Mesh_Boundary.set.elements: Given elements have to be three-dimensional.'); end
            obj.elements = elements;
        end
        function set.npoints(obj, npoints)
            if ~isfloat(npoints),          error('WRW3D_Mesh_Boundary.set.npoints: Value has to be a float.'); end
            if ~isscalar(npoints),         error('WRW3D_Mesh_Boundary.set.npoints: Value has to be scalar.'); end
            if ~(npoints==floor(npoints)), error('WRW3D_Mesh_Boundary.set.npoints: Value has to be integer'); end
            obj.npoints = npoints;
        end
        function set.is_portal(obj, is_portal)
            if ~islogical(is_portal), error('WRW3D_Mesh_Boundary.set.is_portal: Value has to be a logical.'); end
            if ~isscalar(is_portal),  error('WRW3D_Mesh_Boundary.set.is_portal: Value has to be scalar.'); end
            obj.is_portal = is_portal;
        end
        function set.material(obj, material)
            if obj.is_portal,                   error('WRW3D_Mesh_Boundary.set.material: material property can not be set for a portal.'); end %#ok<MCSUP>
            if ~isscalar(material),             error('WRW3D_Mesh_Boundary.set.material: Value has to be scalar.'); end
            if ~isa(material,'WRW3D_Material'), error('WRW3D_Mesh_Boundary.set.material: Value has to be an instance of the class WRW3D_Material.'); end
            obj.material = material;
        end
        function set.backside(obj, backside)
            if ~obj.is_portal,                        error('WRW3D_Mesh_Boundary.set.backside: backside property can not be set for a boundary not being a portal.'); end %#ok<MCSUP>
            if ~isa(backside, 'WRW3D_Mesh_Boundary'), error('WRW3D_Mesh_Boundary.set.backside: Value has to be an instance of the class WRW3D_Mesh_Boundary.'); end
            if ~isscalar(backside),                   error('WRW3D_Mesh_Boundary.set.backside: Value has to be a scalar.'); end
            if ~backside.is_portal,                   error('WRW3D_Mesh_Boundary.set.backside: Given instance of the class WRW3D_Mesh_Boundary must be a portal.'); end
            obj.backside = backside;
        end
        function set.index_begin(obj, index_begin)
            if ~isfloat(index_begin),              error('WRW3D_Mesh_Boundary.set.index_begin: Value has to be a float.'); end
            if ~isscalar(index_begin),             error('WRW3D_Mesh_Boundary.set.index_begin: Value has to be scalar.'); end
            if ~(index_begin==floor(index_begin)), error('WRW3D_Mesh_Boundary.set.index_begin: Value has to be an integer.'); end
            if ~(index_begin>=0),                  error('WRW3D_Mesh_Boundary.set.index_begin: Value has to be greater or equal to zero.'); end
            obj.index_begin = index_begin;
        end
        function set.index_end(obj, index_end)
            if ~isfloat(index_end),            error('WRW3D_Mesh_Boundary.set.index_end: Value has to be a float.'); end
            if ~isscalar(index_end),           error('WRW3D_Mesh_Boundary.set.index_end: Value has to be scalar.'); end
            if ~(index_end==floor(index_end)), error('WRW3D_Mesh_Boundary.set.index_end: Value has to be an integer.'); end
            if ~(index_end>=0),                error('WRW3D_Mesh_Boundary.set.index_end: Value has to be greater or equal to zero.'); end
            obj.index_end = index_end;
        end
        function set.geometry(obj, geometry)
            if ~isa(geometry, 'WRW3D_Mesh_Geometry'), error('WRW3D_Mesh_Boundary.set.geometry: Value has to be an instance of the class WRW3D_Mesh_Geometry.'); end
            if ~isscalar(geometry),                   error('WRW3D_Mesh_Boundary.set.geometry: Value has to be scalar.'); end
            obj.geometry = geometry;
        end
        function set.original(obj, original)
            if ~isa(original, 'WRW3D_Boundary'), error('WRW3D_Mesh_Boundary.set.original: Value has to be an instance of the class WRW3D_Boundary.'); end
            if ~isscalar(original),              error('WRW3D_Mesh_Boundary.set.original: Value has to be scalar.'); end
            obj.original = original;
        end
    end

end

