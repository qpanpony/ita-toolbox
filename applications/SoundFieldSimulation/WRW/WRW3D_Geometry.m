classdef WRW3D_Geometry < handle
    %WRW3D_Geometry contains a konvex geometry in 3D space, which is used 
    %for a WRW simulation.
    %   Multiple geometries can be connected by portals.

    properties
        boundaries = WRW3D_Boundary.empty();    % boundaries forming the geometry
        sources    = WRW3D_Sources.empty();     % sources contained in the geometry
        detectors  = WRW3D_Detectors.empty();   % detectors contained in the geometry
    end
    
    properties (Hidden)
        plot_toggle = true;                     % flag whether boundary is plottet or not (true/false)
    end
    
    properties (Dependent, Hidden)
        non_portals;                            % vector of all boundaries which are no portals
        portals;                                % vector of all boundaries which are portals
    end

    methods
        function set.boundaries(obj, boundaries)
            if ~isa(boundaries, 'WRW3D_Boundary'), error('WRW3D_Geometry.set.boundaries: Value has to be an instance of the class WRW3D_Boundary.'); end
            if ~isrow(boundaries),                 error('WRW3D_Geometry.set.boundaries: Value has to be row vector.'); end
            obj.boundaries = boundaries;
        end
        function set.sources(obj, sources)
            if ~isa(sources, 'WRW3D_Sources'),        error('WRW3D_Geometry.set.sources: Value has to be an instance of the class WRW3D_Sources.'); end
            if ~(isrow(sources) || isempty(sources)), error('WRW3D_Geometry.set.sources: Value has to be row vector.'); end
            obj.sources = sources;
        end
        function set.detectors(obj, detectors)
            if ~isa(detectors, 'WRW3D_Detectors'),        error('WRW3D_Geometry.set.detectors: Value has to be an instance of the class WRW3D_Detectors.'); end
            if ~(isrow(detectors) || isempty(detectors)), error('WRW3D_Geometry.set.detectors: Value has to be row vector.'); end
            obj.detectors = detectors;
        end
        function set.plot_toggle(obj, plot_toggle)
            if ~islogical(plot_toggle), error('WRW3D_Geometry.set.plot_toggle: Value has to be a logical.'); end
            if ~isscalar(plot_toggle),  error('WRW3D_Geometry.set.plot_toggle: Value has to be scalar.'); end
            obj.plot_toggle = plot_toggle;
        end
        function non_portals = get.non_portals(obj)
            non_portals = obj.boundaries(~[obj.boundaries.is_portal]);
        end
        function portals = get.portals(obj)
            portals = obj.boundaries([obj.boundaries.is_portal]);
        end
    end

end




