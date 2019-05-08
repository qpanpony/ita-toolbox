classdef itaComsolSource < handle
    %itaComsolSource Represents an itaSource in an itaComsolModel
    %   Provides static create functions that generate an itaComsolSource
    %   for a given itaComsolModel using an itaSource. Therefore depending
    %   on the source type, suitable physics, geometry and interpolation
    %   nodes are created and linked apropriately. All comsol nodes
    %   representing this source are stored for later modification.
    %   
    %   See also itaComsolModel, itaComsolServer, itaComsolReceiver,
    %   itaComsolImpedance
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolSource">doc itaComsolSource</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mModel;
        mGeometryNode;
        mBoundaryImpedanceNode;
        mPhysicsNode;
        mRealDataNode;
        mImagDataNode;
    end
    
    properties(Constant = true)
        pistonGeometryTagSuffix = '_pistonSourceGeometry';
        pointSourceGeometryTagSuffix = '_pointSourcePosition';
        geometryTagSuffixes = {itaComsolSource.pistonGeometryTagSuffix, itaComsolSource.pointSourceGeometryTagSuffix};
    end
    
    %% Constructor
    methods
        function obj = itaComsolSource(comsolModel, sourceGeometryNode, sourcePhysicsNode, realInterpolationNode, imagInterpolationNode, boundaryImpedanceNode)
            %Constructor should only be used to create empty object (no
            %input). To create a non-empty object, use static Create functions!
            
            %To create empty object
            if nargin == 0
                return;
            end
            
            %Geometry only
            assert(isa(comsolModel, 'itaComsolModel'), 'First input must be a single itaComsolModel')
            assert(isa(sourceGeometryNode, 'com.comsol.clientapi.impl.GeomFeatureClient'), 'Second input must be a comsol geometry feature node')
            
            %Full source data
            if nargin > 2
                assert(isa(sourcePhysicsNode, 'com.comsol.clientapi.physics.impl.PhysicsFeatureClient'), 'Third input must be a comsol physics feature node')
                assert(isa(realInterpolationNode, 'com.comsol.clientapi.impl.FunctionFeatureClient') ||...
                    (isnumeric(realInterpolationNode) && isempty(realInterpolationNode)),...
                    'Fourth input must be a comsol function feature node')
                assert(isa(imagInterpolationNode, 'com.comsol.clientapi.impl.FunctionFeatureClient') ||...
                    (isnumeric(realInterpolationNode) && isempty(realInterpolationNode)),...
                    'Fifth input must be a comsol function feature node')
            else
                sourcePhysicsNode = [];
                realInterpolationNode = [];
                imagInterpolationNode = [];
            end
            if nargin == 6
                assert(isa(boundaryImpedanceNode, 'com.comsol.clientapi.physics.impl.PhysicsFeatureClient'), 'Sixth input must be a comsol physics feature node')
            else
                boundaryImpedanceNode = [];
            end
            
            obj.mModel = comsolModel;
            obj.mGeometryNode = sourceGeometryNode;
            obj.mPhysicsNode = sourcePhysicsNode;
            obj.mRealDataNode = realInterpolationNode;
            obj.mImagDataNode = imagInterpolationNode;
            obj.mBoundaryImpedanceNode = boundaryImpedanceNode;
        end
    end
    
    %----------Static Creators------------
    methods(Static = true)
        function obj = CreateGeometry(comsolModel, source)
            %Creates an source geometry for the given comsol model using
            %an itaSource depending on its SourceType.
            %   Inputs:
            %   comsolModel     Comsol model, the source is created for [itaComsolModel]
            %   source          Object with source data [single itaSource]
            %
            %   Supported source types: Piston
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolSource.checkInputForValidItaSource(source, true);
            switch source.type
                case SourceType.PointSource
                    obj = itaComsolSource();
                case SourceType.Piston
                    obj = itaComsolSource.CreatePistonSourceGeometry(comsolModel, source);
                otherwise
                    error('Unknown source type. No source was created')
            end
        end
        function obj = CreatePistonSourceGeometry(comsolModel, source)
            %Creates a piston source geometry given an itaSource
            %   In Comsol internally, a workplane with a circle in its center
            %   is created using the source position and the view and up
            %   vectors.
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolSource.checkInputForValidItaSource(source, true);
            assert(source.type == SourceType.Piston,'SourceType of given source must be Piston')
            
            baseTag = strrep(source.name, ' ', '_');
            sourceGeometryBaseTag = [baseTag itaComsolSource.pistonGeometryTagSuffix];

            physicsNode = comsolModel.physics.activeNode;
            geometry = itaComsolGeometry(comsolModel);
            geometry.activeNode = comsolModel.modelNode.geom(physicsNode.geom);
            [sourceGeometryNode, ~] = geometry.CreatePistonGeometry(sourceGeometryBaseTag, source);
            
            obj = itaComsolSource(comsolModel, sourceGeometryNode);
            obj.Enable();
        end
        
        
        function obj = Create(comsolModel, source)
            %Creates an acoustic source for the given comsol model using
            %an itaSource. Geometry and physics of the source depends on
            %the SourceType.
            %   Inputs:
            %   comsolModel     Comsol model, the source is created for [itaComsolModel]
            %   source          Object with source data [single itaSource]
            %
            %   Supported source types: PointSource, Piston
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolSource.checkInputForValidItaSource(source);
            switch source.type
                case SourceType.PointSource
                    obj = itaComsolSource.CreatePointSource(comsolModel, source);
                case SourceType.Piston
                    obj = itaComsolSource.CreatePistonSource(comsolModel, source);
                otherwise
                    error('Unknown source type. No source was created')
            end
        end
        
        function obj = CreatePistonSource(comsolModel, source)
            %Creates a piston source for the active physics node given an itaSource
            %   In Comsol internally, a workplane with a circle in its center
            %   is created using the source position and the view and up
            %   vectors. Then this circle is linked to a normal velocity
            %   that is created for the physics node.
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolSource.checkInputForValidItaSource(source);
            assert(source.type == SourceType.Piston,'SourceType of given source must be Piston')
            
            baseTag = strrep(source.name, ' ', '_');
            sourceGeometryBaseTag = [baseTag itaComsolSource.pistonGeometryTagSuffix];
            sourceTag = [baseTag '_pistonSource'];
            interpolationBaseTag = [baseTag '_pistonSourceVelocity'];
            
            physicsNode = comsolModel.physics.activeNode;
            geometry = itaComsolGeometry(comsolModel);
            geometry.activeNode = comsolModel.modelNode.geom(physicsNode.geom);
            [sourceGeometryNode, selectionTag] = geometry.CreatePistonGeometry(sourceGeometryBaseTag, source);
            
            %soundHardTag = [baseTag '_pistonSourceSoundHardBoundary'];
            %soundHardBoundaryNode = comsolModel.physics.CreateSoundHardBoundary(soundHardTag, selectionTag);
            
            if source.sensitivityType == SensitivityType.UserDefined
                [realInterpolationNode, imagInterpolationNode, funcExpression] = ...
                    itaComsolSource.createVelocityInterpolation(comsolModel, interpolationBaseTag, source.velocityTf.freqVector, source.velocityTf.freqData);
            else
                funcExpression = '1[m/s]'; %TODO: Change this so that this becomes 1Pa at 1m on main axis
                realInterpolationNode = []; imagInterpolationNode = [];
            end
            normalVelocityNode = comsolModel.physics.CreateNormalVelocity(sourceTag, selectionTag, funcExpression);
            
            obj = itaComsolSource(comsolModel, sourceGeometryNode, normalVelocityNode, realInterpolationNode, imagInterpolationNode);
            obj.Enable();
        end
        function obj = CreatePointSource(comsolModel, source)
            %Creates a point source for the given comsolModel using an
            %itaSource and returns it as itaComsolSource
            %   In Comsol internally, a point is created for the physics'
            %   geometry and then linked to the point source that is
            %   created for the physics node
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolSource.checkInputForValidItaSource(source);
            assert( ~comsolModel.physics.IsBoundaryMethod(), 'Point sources are not allowed for physics with boundary methods')
            assert(source.type == SourceType.PointSource,'SourceType of given source must be PointSource')
            
            baseTag = strrep(source.name, ' ', '_');
            pointTag = [baseTag itaComsolSource.pointSourceGeometryTagSuffix];
            sourceTag = [baseTag '_pointSource'];
            interpolationBaseTag = [baseTag '_pointSourceVolumeFlow'];
            
            physicsNode = comsolModel.physics.activeNode;
            geometry = itaComsolGeometry(comsolModel);
            geometry.activeNode = comsolModel.modelNode.geom(physicsNode.geom);
            [sourceGeometryNode, selectionTag] = geometry.CreatePointWithSelection(pointTag, source.position);
            
            if source.sensitivityType == SensitivityType.UserDefined
                [realInterpolationNode, imagInterpolationNode, funcExpression] = ...
                    itaComsolSource.createVolumeFlowInterpolation(comsolModel, interpolationBaseTag, source.volumeFlowTf.freqVector, source.volumeFlowTf.freqData);
            else
                funcExpression = ['2[Pa*m] / (i* freq * ' char(physicsNode.tag) '.rho)'];
                realInterpolationNode = []; imagInterpolationNode = [];
            end
            pointSourceNode = comsolModel.physics.CreateMonopolePointSource(sourceTag, selectionTag, funcExpression);
        
            obj = itaComsolSource(comsolModel, sourceGeometryNode, pointSourceNode, realInterpolationNode, imagInterpolationNode);
            obj.Enable();
        end
    end
    
    %% Enable / Disable
    methods
        function Disable(obj)
            obj.setActive(false);
        end
        function Enable(obj)
            obj.setActive(true);
        end
    end
    methods(Access = private)
        function setActive(obj, bool)
            if ~isempty(obj.mGeometryNode)
                obj.mGeometryNode.active(bool);
            end
            if ~isempty(obj.mPhysicsNode)
                obj.mPhysicsNode.active(bool);
            end
            if ~isempty(obj.mRealDataNode)
                obj.mRealDataNode.active(bool);
            end
            if ~isempty(obj.mImagDataNode)
                obj.mImagDataNode.active(bool);
            end
            if ~isempty(obj.mBoundaryImpedanceNode)
                obj.mBoundaryImpedanceNode.active(bool);
            end
        end
    end
    
    %% Helpers
    methods(Access = private, Static = true)
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createVelocityInterpolation(comsolModel, interpolationBaseName, freqVector, complexDataVector)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = comsolModel.func.CreateComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'm / s');
        end
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createVolumeFlowInterpolation(comsolModel, interpolationBaseName, freqVector, complexDataVector)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = comsolModel.func.CreateComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'm^3 / s');
        end
        
        function checkInputForValidItaSource(source, geometryOnly)
            if nargin == 1; geometryOnly = false; end
            
            assert(isa(source, 'itaSource') && isscalar(source),'Input must be a single itaSource object')
            assert(isvarname( strrep(source.name, ' ', '_') ),...
                'Name of given source must be valid variable name (whitespace allowed)')
            if geometryOnly
                assert(source.HasSpatialInformation(), 'Geometric information not fully specified for itaSource')
            else
                assert(source.HasWaveData(), 'Data for wave based simulation not fully specified for itaSource')
            end
        end
    end
end