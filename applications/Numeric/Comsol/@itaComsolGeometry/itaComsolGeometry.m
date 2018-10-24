classdef itaComsolGeometry < itaComsolNode
    %itaComsolGeometry Interface to the geom (=geometry) nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolGeometry(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'geom', 'com.comsol.clientapi.impl.GeomSequenceClient')
        end
    end
    
    %% 0D - Points
    methods
        function [pointNode, selectionTag] = CreatePointWithSelection(obj, pointTag, coords)
            %Creates a point for the active geometry as well as an
            %selection for this point. Returns the Comsol node of the point
            %and the selection tag.
            %   Inputs:
            %   pointTag:   Base tag for naming created elements
            %   coords:     Coordinates of point - itaCoordinates or 3-element vector
            geomNode = obj.mActiveNode;
            pointNode = obj.CreatePoint(pointTag, coords);
            %TODO: Change workPlaneNode.label so that the selection can be filtered out later on
            pointNode.set('selresult', true);
            pointNode.set('selresultshow', 'pnt');
            
            selectionTag = [char(geomNode.tag) '_' pointTag '_pnt'];
        end
        function pointNode = CreatePoint(obj, pointTag, coords)
            %Creates a point for the active geometry and returns its Comsol
            %node
            %   Inputs:
            %   pointTag:   Base tag for naming created elements
            %   coords:     Coordinates of point - itaCoordinates or 3-element vector
            assert(ischar(pointTag) && isrow(pointTag), 'First input must be a char row vector')
            assert( (isnumeric(coords) && isvector(coords) && numel(coords)==3) ||...
                (isa(coords, 'itaCoordinates') && coords.nPoints==1), 'Second input must be a cartesian vector or a single itaCoordinates');
            geomNode = obj.mActiveNode;
            
            if ~obj.hasFeatureNode(geomNode, pointTag)
                geomNode.create(pointTag, 'Point');
                geomNode.feature(pointTag).label(pointTag);
            end
            
            if isa(coords, 'itaCoordinates'); coords = coords.cart; end
            if isrow(coords); coords = coords.'; end
            
            pointNode = geomNode.feature(pointTag);
            pointNode.set('p', coords);
            geomNode.run();
        end
    end
    
    %% 2D - Boundaries
    methods
        function [circleNode, selectionTag] = CreatePistonGeometry(obj, pistonGeometryBaseTag, source)
            %Creates a geometry for a piston based on an itaSource object
            %   Inputs:
            %   pistonGeometryBaseTag:  Base tag for naming created elements
            %   source:                 itaSourceObject of type Piston
            assert(ischar(pistonGeometryBaseTag) && isrow(pistonGeometryBaseTag), 'First input must be a char row vector')
            assert(isa(source, 'itaSource') && isscalar(source), 'Second input must be a single itaSource object')
            assert(source.type == SourceType.Piston,'SourceType of given source must be Piston')
            
            center = source.position.cart;
            p1 = center + source.orientation.up;
            p2 = center + cross(source.orientation.up, source.orientation.view);
            radius = source.pistonRadius;
            [circleNode, selectionTag] = obj.createCircleOnPlane(pistonGeometryBaseTag, radius, center, p1, p2);
        end
    end
    methods(Access = private)
        function [circleNode, selectionTag] = createCircleOnPlane(obj, baseTag, radius, center, p1, p2)
            workPlaneTag = [baseTag '_workPlane'];
            circleTag = [baseTag '_circle'];
            [workPlaneNode, selectionTag] = obj.createWorkPlaneWithSelection(workPlaneTag, center, p1, p2);
            
            if ~obj.hasFeatureNode(workPlaneNode.geom, circleTag)
                workPlaneNode.geom.create(circleTag, 'Circle');
            end
            circleNode = workPlaneNode.geom.feature(circleTag);
            circleNode.set('r', radius);
            %circleNode.set('pos', [-0.75 0.25]); %To move circle off center with dx dy
            
            geomNode = obj.mActiveNode;
            geomNode.run();
        end
        function [workPlaneNode, selectionTag] = createWorkPlaneWithSelection(obj, workPlaneTag, p0, p1, p2)
            geomNode = obj.mActiveNode;
            workPlaneNode = obj.createWorkPlane(workPlaneTag, p0, p1, p2);
            
            %TODO: Change workPlaneNode.label so that the selection can be filtered out later on
            workPlaneNode.set('selresult', true);
            workPlaneNode.set('selresultshow', 'bnd');
            selectionTag = [char(geomNode.tag) '_' char(workPlaneNode.tag) '_bnd'];
        end
        function workPlaneNode = createWorkPlane(obj, workPlaneTag, p0, p1, p2)
            geomNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(geomNode, workPlaneTag)
                geomNode.create(workPlaneTag, 'WorkPlane');
            end
            workPlaneNode = geomNode.feature(workPlaneTag);
            workPlaneNode.set('planetype', 'coordinates');
            workPlaneNode.set('genpoints', [p0; p1; p2]);
            workPlaneNode.set('unite', true);
        end
    end
end