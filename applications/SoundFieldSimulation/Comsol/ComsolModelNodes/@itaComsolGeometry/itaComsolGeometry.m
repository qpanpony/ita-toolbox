classdef itaComsolGeometry < itaComsolNode
    %itaComsolGeometry Interface to the geom (=geometry) nodes of an itaComsolModel
    %   Can be used to create certain types of geometry that refer to
    %   objects such as itaSource or itaReceiver. This is done using the
    %   Create...-functions of this class.
    %   These functions are given a unique tag. Existing geometries can be
    %   adjusted by the same function that created them using the same tag.
    %   
    %   See also itaComsolModel, itaComsolNode, itaComsolSource,
    %   itaComsolReceiver
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolGeometry">doc itaComsolGeometry</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
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
        function [geometryNodes, selectionTag] = ImportReceiverGeometry(obj, geometryBaseTag, receiver)
            %Creates a geometry for a receiver based on an itaReceiver object
            %   Inputs:
            %   geometryBaseTag:    Base tag for naming created elements
            %   receiver:           itaReceiver object of a type that works with a geometry file
            assert(ischar(geometryBaseTag) && isrow(geometryBaseTag), 'First input must be a char row vector')
            assert(isa(receiver, 'itaReceiver') && isscalar(receiver), 'Second input must be a single itaReceiver object')
            assert(receiver.type.NeedsGeometryFile(),'ReceiverType of given receiver must work with geometry files')
            
            %---Import---
            importTag = [geometryBaseTag '_import'];
            importNode = obj.createImport(importTag, receiver.geometryFilename);
            
            %---Orientation---
            [orientationGeomTag, yawRotationNode, pitchRotationNode, rollRotationNode] =...
                obj.ApplyOrientationToGeometry(geometryBaseTag, receiver.orientation, importTag);
            
            %---Translation---
            moveTag =  [geometryBaseTag '_move'];
            moveNode = obj.createMove(moveTag, receiver.position.cart, orientationGeomTag);
            selectionTag = obj.createSelectionForGeomNode(moveNode, 2);
            
            geometryNodes = [importNode, yawRotationNode, pitchRotationNode, rollRotationNode, moveNode];
        end
        
        function [outputGeometryTag, yawRotationNode, pitchRotationNode, rollRotationNode] =...
                ApplyOrientationToGeometry(obj, baseTag, orientation, geomTags, position)
            %Applies the given orientation to the geometry nodes with the
            %given tags.
            %   Inputs (default)
            %   baseTag:        Basis for the tags of all created rotation nodes [char vector]
            %   orientation:    Orientation to be applied [itaOrientation with one element]
            %   geomTags:       Tags of geometry objects that are to be rotated [char vector/string cell]
            %   position:       Origin for all rotations [1x3 vector] ([0 0 0])
            %   
            %   Internally, three rotations are performed in the given order:
            %   1) yaw (around z-axis)
            %   2) pitch (around y-axis)
            %   3) roll (around x-axis)
            %
            %   Make sure that your baseTag is unique. Otherwise old
            %   rotation nodes might be overwritten.
            if nargin == 4; position = [0 0 0]; end
            if ~iscell(geomTags); geomTags = {geomTags}; end
            assert(ischar(baseTag) && isrow(baseTag), 'baseTag must be a char row vector');
            assert(iscellstr(geomTags), 'geomTags must be a char row vector or cell string');
            assert(isa(orientation, 'itaOrientation') && orientation.nPoints == 1, 'orientation must be an itaOrientation object with one element');
            assert(isnumeric(position) && isrow(position) && numel(position)==3, 'position must be a numeric 1x3 vector');
            
            %Note: In Comsol we work in Matlab coordinates. But
            %itaOrientation works with openGL coordinates so we have to
            %convert the view-up vectors to OpenGL to get correct roll,
            %pitch and yaw values.
            %Also the sign for the pitch value has to be changed, since in
            %openGL the pitch axis is 90° clockwise to the roll axis while
            %in Matlab it is 90° counter clockwise.
            viewOgl = orientation.view([2 3 1]); viewOgl = viewOgl .* [-1 1 -1];
            upOgl = orientation.up([2 3 1]); upOgl = upOgl .* [-1 1 -1];
            orientation = itaOrientation.FromViewUp(viewOgl, upOgl);
            roll = orientation.roll_deg;
            pitch = -orientation.pitch_deg;
            yaw = orientation.yaw_deg;
            
            yawRotationTag = [baseTag '_yawRotation'];
            pitchRotationTag = [baseTag '_pitchRotation'];
            rollRotationTag = [baseTag '_rollRotation'];
            
            yawAxis = [0 0 1];
            localYAxisAfterYawRotation = itaCoordinates([1 (yaw+90)*pi/180 0], 'cyl');
            pitchRotAxis = localYAxisAfterYawRotation.cart;
            localXAxisAfterPitchRotation = itaCoordinates([1 (pitch+90)*pi/180 yaw*pi/180], 'sph');
            rollRotAxis = localXAxisAfterPitchRotation.cart;
            
            yawRotationNode = obj.createRotation(yawRotationTag, yaw, yawAxis, geomTags, position);
            pitchRotationNode = obj.createRotation(pitchRotationTag, pitch, pitchRotAxis, yawRotationTag, position);
            rollRotationNode = obj.createRotation(rollRotationTag, roll, rollRotAxis, pitchRotationTag, position);
            
            outputGeometryTag = rollRotationTag;
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
        function rotationNode = createRotation(obj, rotationTag, angle, axis, geomTags, position, workPlaneTag)
            if ~iscell(geomTags); geomTags = {geomTags}; end
            assert(isnumeric(angle) && isscalar(angle), 'angle must be a numeric scalar');
            assert(isnumeric(axis) && isrow(axis) && numel(axis)==3, 'axis must be a numeric 1x3 vector');
            assert(iscellstr(geomTags), 'geomTags must be a char row vector or cell string');
            if nargin < 6; position = [0 0 0]; end
            
            geomNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(geomNode, rotationTag)
                geomNode.create(rotationTag, 'Rotate');
            end
            rotationNode = obj.mActiveNode.feature(rotationTag);
            
            rotationNode.setIndex('rot', angle, 0);
            rotationNode.set('axis', axis);
            %rotationNode.set('axistype', 'cartesian');
            %rotationNode.set('ax3', axis);
            rotationNode.selection('input').set(geomTags);
            rotationNode.set('pos', position);
            if nargin == 7
                rotationNode.set('workplane', workPlaneTag);
            end
        end
        function [rotationNode, workPlaneNode] = createRotationViaWorkPlane(obj, rotationTag, angle, axis, geomTags, workPlaneXVec, workPlaneYVec, workPlaneOrigin)
            if nargin == 7; workPlaneOrigin = [0 0 0]; end
            if ~iscell(geomTags); geomTags = {geomTags}; end
            assert(isnumeric(angle) && isscalar(angle), 'angle must be a numeric scalar');
            assert(isnumeric(axis) && isrow(axis) && numel(axis)==3, 'axis must be a numeric 1x3 vector');
            assert(iscellstr(geomTags), 'geomTags must be a char row vector or cell string');
            
            workPlaneTag = [rotationTag '_wp'];
            workPlaneNode = obj.createWorkPlane(workPlaneTag, workPlaneOrigin, workPlaneOrigin+workPlaneXVec, workPlaneOrigin+workPlaneYVec);
            
            rotationNode = obj.createRotation(rotationTag, angle, axis, geomTags);
            rotationNode.set('workplane', workPlaneTag);
        end
        function moveNode = createMove(obj, moveTag, translationVec, geomTags)
            if ~iscell(geomTags); geomTags = {geomTags}; end
            assert(isnumeric(translationVec) && isrow(translationVec) && numel(translationVec)==3, 'translationVec must be a numeric 1x3 vector');
            assert(iscellstr(geomTags), 'geomTags must be a char row vector or cell string');
            
            geomNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(geomNode, moveTag)
                geomNode.create(moveTag, 'Move');
            end
            moveNode = obj.mActiveNode.feature(moveTag);
            moveNode.setIndex('displx', translationVec(1), 0);
            moveNode.setIndex('disply', translationVec(2), 0);
            moveNode.setIndex('displz', translationVec(3), 0);
            moveNode.selection('input').set(geomTags);
        end
    end
    
    %% Selections
    methods(Access = private)
        function selectionTag = createSelectionForGeomNode(obj, geomFeatureNode, dimension)
            geomFeatureNode.set('selresult', true);
            geomFeatureNode.set('selresultshow', obj.dimensionToTag(dimension));
            selectionTag = obj.getSelectionTag(geomFeatureNode, dimension);
        end
        function selectionTag = getSelectionTag(obj, geomFeatureNode, dimension)
            geomNode = obj.activeNode;
            selectionTag = [char(geomNode.tag) '_' char(geomFeatureNode.tag) '_' obj.dimensionToTag(dimension)];
        end
    end
    methods(Access = private, Static = true)
        function dimTag = dimensionToTag(dimension)
            dimTag = '';
            switch dimension
                case 0
                    dimTag = 'pnt';
                case 1
                    dimTag = '';
                case 2
                    dimTag = 'bnd';
                case 3
                    dimTag = 'dom';
            end
        end
    end
end