classdef WRW3D_Mesh_Geometry < handle
    %WRW3D_MESH_GEOMETRY contains the mesh of a (convex) geometry
    %(WRW3D_Geometry). 
    
    properties
        boundaries         = WRW3D_Mesh_Boundary.empty();   % boundaries forming the geometry
        sources            = WRW3D_Sources.empty();         % sources contained in the geometry
        detectors          = WRW3D_Detectors.empty();       % detectors contained in the geometry
        nboundaries        = [];                            % number of boundaries
        nsources           = [];                            % number of source points
        ndetectors         = [];                            % number of detector points
        npoints            = [];                            % number of mesh points
    end
    
    properties (Hidden)
        original           = WRW3D_Geometry.empty();        % original geometry the mesh is made from
    end
    
    properties (Dependent, Hidden)
        non_portals;                                        % vector of all boundaries which are no portals
        portals;                                            % vector of all boundaries which are portals
    end
    
    methods
        function set.boundaries(obj, boundaries)
            if ~isa(boundaries, 'WRW3D_Mesh_Boundary'), error('WRW3D_Mesh_Geometry.set.boundaries: Value has to be an instance of the class WRW3D_Mesh_Boundary.'); end
            if ~isrow(boundaries),                      error('WRW3D_Mesh_Geometry.set.boundaries: Value has to be a row vector.'); end
            obj.boundaries = boundaries;
        end
        function set.sources(obj, sources)
            if ~isa(sources, 'WRW3D_Sources'),        error('WRW3D_Mesh_Geometry.set.sources: Value has to be an instance of the class WRW3D_Sources.'); end
            if ~(isrow(sources) || isempty(sources)), error('WRW3D_Mesh_Geometry.set.sources: Value has to be row vector.'); end
            obj.sources = sources;
        end
        function set.detectors(obj, detectors)
            if ~isa(detectors, 'WRW3D_Detectors'),        error('WRW3D_Mesh_Geometry.set.detectors: Value has to be an instance of the class WRW3D_Detectors.'); end
            if ~(isrow(detectors) || isempty(detectors)), error('WRW3D_Mesh_Geometry.set.detectors: Value has to be a row vector.'); end
            obj.detectors = detectors;
        end
        function set.nboundaries(obj, nboundaries)
            if ~isfloat(nboundaries),              error('WRW3D_Mesh_Geometry.set.nboundaries: Value has to be a float.'); end
            if ~isscalar(nboundaries),             error('WRW3D_Mesh_Geometry.set.nboundaries: Value has to be scalar.'); end
            if ~(nboundaries==floor(nboundaries)), error('WRW3D_Mesh_Geometry.set.nboundaries: Value has to be integer'); end
            obj.nboundaries = nboundaries;
        end
        function set.nsources(obj, nsources)
            if ~isfloat(nsources),           error('WRW3D_Mesh_Geometry.set.nsources: Value has to be a float.'); end
            if ~isscalar(nsources),          error('WRW3D_Mesh_Geometry.set.nsources: Value has to be scalar.'); end
            if ~(nsources==floor(nsources)), error('WRW3D_Mesh_Geometry.set.nsources: Value has to be integer'); end
            obj.nsources = nsources;
        end
        function set.ndetectors(obj, ndetectors)
            if ~isfloat(ndetectors),             error('WRW3D_Mesh_Geometry.set.ndetectors: Value has to be a float.'); end
            if ~isscalar(ndetectors),            error('WRW3D_Mesh_Geometry.set.ndetectors: Value has to be scalar.'); end
            if ~(ndetectors==floor(ndetectors)), error('WRW3D_Mesh_Geometry.set.ndetectors: Value has to be integer'); end
            obj.ndetectors = ndetectors;
        end
        function set.npoints(obj, npoints)
            if ~isfloat(npoints),          error('WRW3D_Mesh_Geometry.set.npoints: Value has to be a float.'); end
            if ~isscalar(npoints),         error('WRW3D_Mesh_Geometry.set.npoints: Value has to be scalar.'); end
            if ~(npoints==floor(npoints)), error('WRW3D_Mesh_Geometry.set.npoints: Value has to be integer'); end
            obj.npoints = npoints;
        end
        function set.original(obj, original)
            if ~isa(original, 'WRW3D_Geometry'), error('WRW3D_Mesh_Boundary.set.original: Value has to be an instance of the class WRW3D_Geometry.'); end
            if ~isscalar(original),              error('WRW3D_Mesh_Boundary.set.original: Value has to be scalar.'); end
            obj.original = original;
        end
        function non_portals = get.non_portals(obj)
            non_portals = obj.boundaries(~[obj.boundaries.is_portal]);
        end
        function portals = get.portals(obj)
            portals = obj.boundaries([obj.boundaries.is_portal]);
        end
    end   
    
end