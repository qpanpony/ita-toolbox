classdef WRW3D_Mesh < handle
    %WRW3D_MESH containing the mesh used for the simulation.
    %   Analog to the model the mesh is made from the mesh consists of
    %   (convex) geometries (WRW3D_Mesh_Geometry) which themselves consists
    %   of boundaries (WRW3D_Mesh_Boundaries).
    
    properties
        geometries        = WRW3D_Mesh_Geometry.empty(); % (convex) geometries (WRW3D_Mesh_Geometry) the mesh consists of
        ngeometries       = [];                          % number of geometries
        npoints           = [];                          % number of mesh points in the whole mesh
        npoints_sources   = [];                          % number of source points in the whole mesh
        npoints_detectors = [];                          % number of detector points in the whole mesh
    end
    
    methods
        function set.geometries(obj, geometries)
            if ~isa(geometries, 'WRW3D_Mesh_Geometry'), error('WRW3D_Mesh.set.geometries: Value has to be an instance of the class WRW3D_Mesh_Geometry.'); end
            if ~isrow(geometries),                      error('WRW3D_Mesh.set.geometries: Value has to be a row vector.'); end
            obj.geometries = geometries;
        end
        function set.ngeometries(obj, ngeometries)
            if ~isfloat(ngeometries),              error('WRW3D_Mesh.set.ngeometries: Value has to be a float.'); end
            if ~isscalar(ngeometries),             error('WRW3D_Mesh.set.ngeometries: Value has to be scalar.'); end
            if ~(ngeometries==floor(ngeometries)), error('WRW3D_Mesh.set.ngeometries: Value has to be integer'); end
            if ~(ngeometries>=0),                  error('WRW3D_Mesh.set.ngeometries: Value has to be greater or equal to zero.'); end
            obj.ngeometries = ngeometries;
        end
        function set.npoints(obj, npoints)
            if ~isfloat(npoints),          error('WRW3D_Mesh.set.npoints: Value has to be a float.'); end
            if ~isscalar(npoints),         error('WRW3D_Mesh.set.npoints: Value has to be scalar.'); end
            if ~(npoints==floor(npoints)), error('WRW3D_Mesh.set.npoints: Value has to be integer'); end
            if ~(npoints>=0),              error('WRW3D_Mesh.set.npoints: Value has to be greater or equal to zero.'); end
            obj.npoints = npoints;
        end
        function set.npoints_sources(obj, npoints_sources)
            if ~isfloat(npoints_sources),                  error('WRW3D_Mesh.set.npoints_sources: Value has to be a float.'); end
            if ~isscalar(npoints_sources),                 error('WRW3D_Mesh.set.npoints_sources: Value has to be scalar.'); end
            if ~(npoints_sources==floor(npoints_sources)), error('WRW3D_Mesh.set.npoints_sources: Value has to be integer'); end
            if ~(npoints_sources>=0),                      error('WRW3D_Mesh.set.npoints_sources: Value has to be greater or equal to zero.'); end
            obj.npoints_sources = npoints_sources;
        end
        function set.npoints_detectors(obj, npoints_detectors)
            if ~isfloat(npoints_detectors),                    error('WRW3D_Mesh.set.npoints_detectors: Value has to be a float.'); end
            if ~isscalar(npoints_detectors),                   error('WRW3D_Mesh.set.npoints_detectors: Value has to be scalar.'); end
            if ~(npoints_detectors==floor(npoints_detectors)), error('WRW3D_Mesh.set.npoints_detectors: Value has to be integer'); end
            if ~(npoints_detectors>=0),                        error('WRW3D_Mesh.set.npoints_detectors: Value has to be greater or equal to zero.'); end
            obj.npoints_detectors = npoints_detectors;
        end
    end
    
end

