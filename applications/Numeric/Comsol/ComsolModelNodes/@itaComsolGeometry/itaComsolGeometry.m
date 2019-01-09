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
            %   source:                 itaSource object of type Piston
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
    
    %% 3D - Volumes
    methods
        function CreateDummyHeadGeometry(obj, geometryBaseTag, receiver)
            %Creates a geometry for a piston based on an itaSource object
            %   Inputs:
            %   geometryBaseTag:    Base tag for naming created elements
            %   receiver:           itaReceiver object of type DummyHead
            assert(ischar(pistonGeometryBaseTag) && isrow(pistonGeometryBaseTag), 'First input must be a char row vector')
            assert(isa(receiver, 'itaReceiver') && isscalar(receiver), 'Second input must be a single itaReceiver object')
            assert(receiver.type == ReceiverType.DummyHead,'ReceiverType of given receiver must be DummyHead')
            
            geomNode = obj.mActiveNode;
            
            importTag = [geometryBaseTag '_import'];
            filename = 'D:\CAD data\Kunstkopf\KK_lowPoly.mphbin';
            obj.createImport(importTag, filename)
            
            view = itaCoordinates(receiver.orientation.view);
            phi = view.phi_deg;
            %itaCoord.theta_deg: 0 = up, 180 = down. We need -90 = up, 90 down, 0 front
            theta = view.theta_deg - 90;
            azimuthRotAxis = [0 0 1];
            elevationRotAxis = [0 0 0];
            azimuthRotationTag = [geometryBaseTag '_azimuthRotation'];
            elevationRotationTag = [geometryBaseTag '_azimuthRotation'];
            
            elevationRotWorkPlaneXY = itaCoordinates([1 0 0; 1 0 0], 'cyl');
            elevationRotWorkPlaneXY.phi_deg = [phi phi+90];
            
            obj.createRotation(azimuthRotationTag, phi, [0 0 1], importTag)
            obj.createRotationViaWorkPlane(elevationRotationTag, theta, [0 1 0], azimuthRotationTag,...
                elevationRotWorkPlaneXY.cart(1, :), elevationRotWorkPlaneXY.cart(2, :))
            
            geomNode.create('rot1', 'Rotate');
            obj.mActiveNode.feature('rot1').setIndex('rot', '90', 0);
            obj.mActiveNode.feature('rot1').set('axis', [0 0 1]);
            obj.mActiveNode.feature('rot1').selection('input').set({'imp1'});
            
            obj.mActiveNode.create('wp1', 'WorkPlane');
            obj.mActiveNode.feature('wp1').set('planetype', 'coordinates');
            obj.mActiveNode.feature('wp1').set('genpoints', [0 0 0; 0 1 0; -1 0 0]);
            obj.mActiveNode.feature('wp1').set('unite', true);
            obj.mActiveNode.create('rot2', 'Rotate');
            obj.mActiveNode.feature('rot2').set('workplane', 'wp1');
            obj.mActiveNode.feature('rot2').setIndex('rot', '-45', 0);
            obj.mActiveNode.feature('rot2').set('axis', [0 1 0]);
            obj.mActiveNode.feature('rot2').selection('input').set({'rot1'});
            
            obj.mActiveNode.create('mov1', 'Move');
            obj.mActiveNode.feature('mov1').setIndex('displx', '1', 0);
            obj.mActiveNode.feature('mov1').setIndex('disply', '2', 0);
            obj.mActiveNode.feature('mov1').setIndex('displz', '3', 0);
            obj.mActiveNode.feature('mov1').selection('input').set({'rot2'});
            obj.mActiveNode.run;
        end
    end
    methods(Access = private)
        function importNode = createImport(obj, importTag, filename)
            geomNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(geomNode, importTag)
                geomNode.create(importTag, 'Import');
            end
            importNode = geomNode.feature(importTag);
            importNode.set('type', 'native');
            importNode.set('filename', filename);
        end
        function rotationNode = createRotation(obj, rotationTag, angle, axis, geomTags, workPlaneTag)
            if ~iscell(geomTags); geomTags = {geomTags}; end
            assert(isnumeric(angle) && isscalar(angle), 'angle must be a numeric scalar');
            assert(isnumeric(axis) && isrow(axis) && numel(axis)==3, 'axis must be a numeric 1x3 vector');
            assert(iscellstr(geomTags), 'geomTags must be a char row vector or cell string');
            
            geomNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(geomNode, rotationTag)
                geomNode.create(rotationTag, 'Rotate');
            end
            rotationNode = obj.mActiveNode.feature(rotationTag);
            rotationNode.setIndex('rot', angle, 0); %TODO: Is num2str needed?
            rotationNode.set('axis', axis);
            rotationNode.selection('input').set(geomTags);
            if nargin == 6
                rotationNode.set('workplane', workPlaneTag);
            end
        end
        function rotationNode = createRotationViaWorkPlane(obj, rotationTag, angle, axis, geomTags, workPlaneXVec, workPlaneYVec, workPlaneOrigin)
            if nargin == 7; workPlaneOrigin = [0 0 0]; end
            if ~iscell(geomTags); geomTags = {geomTags}; end
            assert(isnumeric(angle) && isscalar(angle), 'angle must be a numeric scalar');
            assert(isnumeric(axis) && isrow(axis) && numel(axis)==3, 'axis must be a numeric 1x3 vector');
            assert(iscellstr(geomTags), 'geomTags must be a char row vector or cell string');
            
            workPlaneTag = [rotationTag '_wp'];
            obj.createWorkPlane(workPlaneTag, workPlaneOrigin, workPlaneXVec, workPlaneYVec);
            
            rotationNode = obj.createRotation(rotationTag, angle, axis, geomTags, workPlaneTag);
        end
    end
end