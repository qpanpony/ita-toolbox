classdef WRW3D_Detectors < handle
    %WRW3D_DETECTORS stores information about detectors used in the
    %simulation.
    %   Instance can either be created by constructor or by the functions
    %   wrw3d_detector_grid or wrw3d_detector_line.
        
    properties
        points      = [1 1 1];          % 3D locations of detectors
        npoints     = 1;                % number of detector locations
    end
    
    properties (Hidden)
        index_begin = [];               % begin of index range of collected detectors for simulation
        index_end   = [];               % end of index range of collected detectors for simulation
        plot_toggle = true;             % flag whether boundary is plottet or not (true/false)
        is_grid     = false;            % flag whether detectors are arranged as grid and will be plotted as surface
        grid = struct('corner', [],...  % corner of generated grid
                      'edgeA', [],...   % direction vector of  first edge
                      'edgeB', [],...   % direction vector of second edge
                      'edgeA_n', [],... % number of grid points along first edge
                      'edgeB_n', [],... % number of grid points along second edge
                      'distance', []);  % distance between detectors
    end
    
    methods
        function set.points(obj, points)
            if ~isfloat(points),  error('WRW3D_Detectors.set.points: Value has to be a float.'); end
            if isempty(points),   error('WRW3D_Detectors.set.points: Value must not be empty.'); end
            if size(points,2)~=3, error('WRW3D_Detectors.set.points: Given points have to be three-dimensional.'); end
            obj.points = points;
        end
        function set.npoints(obj, npoints)
            if ~isfloat(npoints),               error('WRW3D_Detectors.set.npoints: Value has to be a float.'); end
            if ~isscalar(npoints),              error('WRW3D_Detectors.set.npoints: Value has to be scalar.'); end
            if logical(npoints-floor(npoints)), error('WRW3D_Detectors.set.npoints: Value has to be integer'); end
            obj.npoints = npoints;
        end
        function set.index_begin(obj, index_begin)
            if ~isfloat(index_begin),              error('WRW3D_Detectors.set.index_begin: Value has to be a float.'); end
            if ~isscalar(index_begin),             error('WRW3D_Detectors.set.index_begin: Value has to be scalar.'); end
            if ~(index_begin==floor(index_begin)), error('WRW3D_Detectors.set.index_begin: Value has to be an integer.'); end
            if ~(index_begin>=0),                  error('WRW3D_Detectors.set.index_begin: Value has to be greater or equal to zero.'); end
            obj.index_begin = index_begin;
        end
        function set.index_end(obj, index_end)
            if ~isfloat(index_end),            error('WRW3D_Detectors.set.index_end: Value has to be a float.'); end
            if ~isscalar(index_end),           error('WRW3D_Detectors.set.index_end: Value has to be scalar.'); end
            if ~(index_end==floor(index_end)), error('WRW3D_Detectors.set.index_end: Value has to be an integer.'); end
            if ~(index_end>=0),                error('WRW3D_Detectors.set.index_end: Value has to be greater or equal to zero.'); end
            obj.index_end = index_end;
        end
        function set.plot_toggle(obj, plot_toggle)
            if ~islogical(plot_toggle), error('WRW3D_Detectors.set.plot_toggle: Value has to be a logical.'); end
            if ~isscalar(plot_toggle),  error('WRW3D_Detectors.set.plot_toggle: Value has to be scalar.'); end
            obj.plot_toggle = plot_toggle;
        end
        function set.is_grid(obj, is_grid)
            if ~islogical(is_grid), error('WRW3D_Detectors.set.is_grid: Value has to be a logical.'); end
            if ~isscalar(is_grid),  error('WRW3D_Detectors.set.is_grid: Value has to be scalar.'); end
            obj.is_grid = is_grid;
        end
        function set.grid(obj, grid)
            if ~isstruct(grid),          error('WRW3D_Detectors.set.grid: Value has to be a struct.'); end
            if ~all(isfield(grid,{'corner','edgeA','edgeB','edgeA_n','edgeB_n','distance'})),...
                                         error('WRW3D_Detectors.set.grid: Struct has to contain the fields corner, edgeA, edgeB, edgeA_n, edgeB_n and distance.'); end
            if ~isfloat(grid.distance),  error('WRW3D_Detectors.set.view.distance: Value of the field distance has to be a float.'); end
            if ~isscalar(grid.distance), error('WRW3D_Detectors.set.view.distance: Value of the field distance has to be scalar.'); end
            if ~(grid.distance>0),       error('WRW3D_Detectors.set.view.distance: Value of the field distance has to be greater than 0.'); end
            for field_cell = {'corner', 'edgeA', 'edgeB'}
                field = field_cell{:};
                if ~isfloat(grid.(field)),          error(['WRW3D_Detectors.set.grid.',field,': Value of the field ',field,' has to be a float.']); end
                if ~all(size(grid.(field))==[1,3]), error(['WRW3D_Detectors.set.grid.',field,': Value of the field ',field,' has to be a 1x3 vector.']); end
            end
            for field_cell = {'edgeA_n', 'edgeB_n'}
                field = field_cell{:};
                if ~isfloat(grid.(field)),               error(['WRW3D_Detectors.set.grid.',field,': Value of the field ',field,' has to be a float.']); end
                if ~isscalar(grid.(field)),              error(['WRW3D_Detectors.set.grid.',field,': Value of the field ',field,' has to be scalar.']); end
                if ~(grid.(field)==floor(grid.(field))), error(['WRW3D_Detectors.set.grid.',field,': Value of the field ',field,' has to be an integer.']); end
                if ~(grid.(field)>=0),                   error(['WRW3D_Detectors.set.grid.',field,': Value of the field ',field,' has to be greater or equal to zero.']); end
            end
            obj.grid = grid;
        end
    end
    
end

