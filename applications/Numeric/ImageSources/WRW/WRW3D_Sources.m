classdef WRW3D_Sources < handle
    %WRW3D_SOURCE stores information about sources used in the simulation.
    
    properties
        points       = [0 0 0];                   % 3D locations of sources
        npoints      = 1;                         % number of source points
        pressures    = 1;                         % sound pressure of the sources
        directivity  = WRW3D_Directivity.empty(); % directivity of the sources
        x_directions = [];                        % direction in which the x-axis of the coordinate system of the directivity points
        z_directions = [];                        % direction in which the z-axis of the coordinate system of the directivity points
    end
    
    properties (Hidden)
        index_begin = [];                         % begin of index range of collected sources for simulation
        index_end   = [];                         % end of index range of collected sources for simulation
    end
    
    methods
        function set.points(obj, points)
            if ~isfloat(points),  error('WRW3D_Sources.set.points: Value has to be a float.'); end
            if isempty(points),   error('WRW3D_Sources.set.points: Value must not be empty.'); end
            if size(points,2)~=3, error('WRW3D_Sources.set.points: Given points have to be three-dimensional.'); end
            obj.points = points;
        end
        function set.npoints(obj, npoints)
            if ~isfloat(npoints),               error('WRW3D_Sources.set.npoints: Value has to be a float.'); end
            if ~isscalar(npoints),              error('WRW3D_Sources.set.npoints: Value has to be scalar.'); end
            if logical(npoints-floor(npoints)), error('WRW3D_Sources.set.npoints: Value has to be integer'); end
            obj.npoints = npoints;
        end
        function set.pressures(obj, pressures)
            if ~isfloat(pressures),  error('WRW3D_Sources.set.pressures: Value has to be a float.'); end
            if ~iscolumn(pressures), error('WRW3D_Sources.set.pressures: Value has to be a column vector'); end
            obj.pressures = pressures;
        end
        function set.directivity(obj, directivity)
            if ~isa(directivity, 'WRW3D_Directivity'), error('WRW3D_Sources.set.directivity: Value has to be an instance of WRW3D_Directivity.'); end
            if ~isscalar(directivity),                 error('WRW3D_Sources.set.directivity: Value must be scalar.'); end
            obj.directivity = directivity;
        end
        function set.x_directions(obj, x_directions)
            if ~isfloat(x_directions),  error('WRW3D_Sources.set.x_directions: Value has to be a float.'); end
            if size(x_directions,2)~=3, error('WRW3D_Sources.set.x_directions: Value has to be a Nx3 matrix.'); end
            if isempty(x_directions),   error('WRW3D_Sources.set.x_directions: Value must not be empty.'); end
            obj.x_directions = x_directions;
        end
        function set.z_directions(obj, z_directions)
            if ~isfloat(z_directions),  error('WRW3D_Sources.set.z_directions: Value has to be a float.'); end
            if size(z_directions,2)~=3, error('WRW3D_Sources.set.x_directions: Value has to be a Nx3 matrix.'); end
            if isempty(z_directions),   error('WRW3D_Sources.set.x_directions: Value must not be empty.'); end
            obj.z_directions = z_directions;
        end     
        function set.index_begin(obj, index_begin)
            if ~isfloat(index_begin),              error('WRW3D_Sources.set.index_begin: Value has to be a float.'); end
            if ~isscalar(index_begin),             error('WRW3D_Sources.set.index_begin: Value has to be scalar.'); end
            if ~(index_begin==floor(index_begin)), error('WRW3D_Sources.set.index_begin: Value has to be an integer.'); end
            if ~(index_begin>=0),                  error('WRW3D_Sources.set.index_begin: Value has to be greater or equal to zero.'); end
            obj.index_begin = index_begin;
        end
        function set.index_end(obj, index_end)
            if ~isfloat(index_end),            error('WRW3D_Sources.set.index_end: Value has to be a float.'); end
            if ~isscalar(index_end),           error('WRW3D_Sources.set.index_end: Value has to be scalar.'); end
            if ~(index_end==floor(index_end)), error('WRW3D_Sources.set.index_end: Value has to be an integer.'); end
            if ~(index_end>=0),                error('WRW3D_Sources.set.index_end: Value has to be greater or equal to zero.'); end
            obj.index_end = index_end;
        end
    end
    
end

