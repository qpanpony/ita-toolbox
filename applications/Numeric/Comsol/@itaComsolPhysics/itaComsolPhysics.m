classdef itaComsolPhysics < itaComsolNode
    %itaComsolPhysics Interface to the physics node of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolPhysics(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'physics', 'com.comsol.clientapi.physics.impl.PhysicsClient')
        end
    end
    
    %% Impedance
    methods
        function impedanceNodes = ImpedanceNodes(obj)
            %Returns the impedance nodes of the active physics node.
            impedanceNodes = obj.getChildNodesByType(obj.mActiveNode, 'Impedance');
        end
        
        function SetBoundaryGroupImpedance(obj, boundaryGroupName, data)
            %Sets the data of the impedance node for the given boundary group
            %(=label of a 2D selection in Comsol). The data can either be
            %passed using an itaMaterial or an itaResult/itaAudio.
            
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'First input must be a char row vector')
            assert(isvarname(strrep(boundaryGroupName, ' ', '_')), 'Given boundary group name must be valid variable name (whitespace allowed)')
            if isa(data, 'itaMaterial'); data = data.impedance; end
            assert(isa(data, 'itaSuper') && numel(data) == 1 && data.nChannels == 1,...
                'Second input must either be an itaMaterial with a valid impedance or a single itaSuper')
            
            freqVector = data.freqVector;
            freqData = data.freqData;
            
            impedanceNodeOfBoundary = obj.impedanceNodeByBoundaryGroupName(boundaryGroupName);
            if isempty(impedanceNodeOfBoundary); error('A Comsol impedance node for the given boundary group does not exist'); end
            
            interpolationBaseName = [strrep(boundaryGroupName, ' ', '_') '_impedance'];
            obj.setImpedanceViaInterpolation(impedanceNodeOfBoundary, interpolationBaseName, freqVector, freqData);
        end
    end
    methods(Access = private)
        function impedanceNodeOfBoundary = impedanceNodeByBoundaryGroupName(obj, boundaryGroupName)
            %Returns the impedance node of the active physics node that is
            %connected to given boundary group (= Comsol selection). Returns
            %an empty object if no impedance is connected to the given selection.
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'First input must be a char row vector')
            impedanceNodeOfBoundary = [];
            
            idxBoundary = strcmp(obj.mModel.selection.BoundaryGroupNames(), boundaryGroupName);
            if sum(idxBoundary) ~= 1; return; end
            boundaryGroup = obj.mModel.selection.BoundaryGroups{idxBoundary};
            
            impedanceNodes = obj.ImpedanceNodes();
            for idxImpedance = 1:numel(impedanceNodes)
                selectionTag = impedanceNodes{idxImpedance}.selection.named;
                if strcmp(selectionTag, boundaryGroup.tag)
                    impedanceNodeOfBoundary = impedanceNodes{idxImpedance};
                    return
                end
            end
        end
        function setImpedanceViaInterpolation(obj, impedanceNode, interpolationBaseName, freqVector, complexDataVector)
            [~, ~, funcExpression] = obj.createImpedanceInterpolation(...
                interpolationBaseName, freqVector, complexDataVector);
            
            impedanceNode.set('ImpedanceModel', 'UserDefined');
            impedanceNode.set('Zi', funcExpression);
        end
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createImpedanceInterpolation(obj, interpolationBaseName, freqVector, complexDataVector)
            %Creates or adjusts two Comsol Interpolation nodes, one for the
            %real and one for the imaginary impedance data and returns the
            %two interpolation nodes.
            [realInterpolationNode, imagInterpolationNode, funcExpression] = obj.mModel.func.CreateComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'Pa / m * s');
        end
    end
    
    %% Sources
    methods
        function CreateSource(obj, source)
            %Creates an acoustic source for the active physics node given
            %an itaSource. Geometry and physics of the source depends on
            %the SourceType.
            %   Input: Single itaSource
            %
            %   Supported source types: PointSource, Piston
            obj.checkInputForValidItaSource(source);
            switch source.type
                case SourceType.PointSource
                    obj.CreatePointSource(source);
                case SourceType.Piston
                    obj.CreatePistonSource(source);
                otherwise
                    error('Unknown source type. No source was created')
            end
        end
        function CreatePistonSource(obj, source)
            %Creates a piston source for the active physics node given an itaSource
            %   In Comsol internally, a workplane with a circle in its center
            %   is created using the source position and the view and up
            %   vectors. Then this circle is linked to a normal velocity
            %   that is created for the physics node.
            physics = obj.activeNode;
            obj.checkInputForValidItaSource(source);
            assert(source.type == SourceType.Piston,'SourceType of given source must be Piston')
            
            baseTag = strrep(source.name, ' ', '_');
            sourceGeometryBaseTag = [baseTag '_pistonSourceGeometry'];
            sourceTag = [baseTag '_pistonSource'];
            interpolationBaseTag = [baseTag '_pistonSourceVelocity'];
            
            geometry = itaComsolGeometry(obj.mModel);
            geometry.activeNode = obj.modelNode.geom(physics.geom);
            [~, selectionTag] = geometry.CreatePistonGeometry(sourceGeometryBaseTag, source);
            
            if ~obj.hasFeatureNode(physics, sourceTag)
                physics.create(sourceTag, 'NormalVelocity', 2);
            end
            sourceNode = physics.feature(sourceTag);
            sourceNode.selection.named(selectionTag);
            obj.setNormalVelocityViaInterpolation(sourceNode, interpolationBaseTag, source.velocityTf.freqVector, source.velocityTf.freqData)
        end
        function CreatePointSource(obj, source)
            %Creates a point source in active physics given an itaSource
            %   In Comsol internally, a point is created for the physics
            %   geometry and then linked to the point source that is
            %   created for the physics
            physics = obj.activeNode;
            obj.checkInputForValidItaSource(source);
            assert( ~obj.IsBoundaryMethod(), 'Point sources are not allowed for physics with boundary methods')
            assert(source.type == SourceType.PointSource,'SourceType of given source must be PointSource')
            
            baseTag = strrep(source.name, ' ', '_');
            pointTag = [baseTag '_pointSourcePosition'];
            sourceTag = [baseTag '_pointSource'];
            interpolationBaseTag = [baseTag '_pointSourceVolumeFlow'];
            
            geometry = itaComsolGeometry(obj.mModel);
            geometry.activeNode = obj.modelNode.geom(physics.geom);
            [~, selectionTag] = geometry.CreatePointWithSelection(pointTag, source.position);
            
            if ~obj.hasFeatureNode(physics, sourceTag)
                physics.create(sourceTag, 'FrequencyMonopolePointSource', 0);
            end
            sourceNode = physics.feature(sourceTag);
            sourceNode.selection.named(selectionTag);
            %sourceNode.set('Type', 'UserDefined');
            %sourceNode.set('S', 1);
            %sourceNode.set('Type', 'Power');
            %sourceNode.set('P_rms', 3);
            sourceNode.set('Type', 'Flow');
            obj.setVolumeFlowViaInterpolation(sourceNode, interpolationBaseTag, source.volumeFlowTf.freqVector, source.volumeFlowTf.freqData);
        end
    end
    methods(Access = private)
        function setNormalVelocityViaInterpolation(obj, normalVelocityNode, interpolationBaseName, freqVector, complexDataVector)
            [~, ~, funcExpression] = obj.createVelocityInterpolation(...
                interpolationBaseName, freqVector, complexDataVector);
            
            normalVelocityNode.set('nvel', funcExpression);
        end
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createVelocityInterpolation(obj, interpolationBaseName, freqVector, complexDataVector)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = obj.mModel.func.CreateComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'm / s');
        end
        function setVolumeFlowViaInterpolation(obj, pointSourceNode, interpolationBaseName, freqVector, complexDataVector)
            [~, ~, funcExpression] = obj.createVolumeFlowInterpolation(...
                interpolationBaseName, freqVector, complexDataVector);
            
            pointSourceNode.set('Qs', funcExpression);
        end
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createVolumeFlowInterpolation(obj, interpolationBaseName, freqVector, complexDataVector)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = obj.mModel.func.CreateComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'm^3 / s');
        end
    end
    methods(Access = private, Static = true)
        function checkInputForValidItaSource(source)
            assert(isa(source, 'itaSource') && isscalar(source),'Input must be a single itaSource object')
            assert(source.HasWaveData(), 'Data for wave based simulation not defined for itaSource')
            assert(isvarname( strrep(source.name, ' ', '_') ),...
                'Name of given source must be valid variable name (whitespace allowed)')
        end
    end
    
    %% Booleans
    methods
        function bool = IsBoundaryMethod(obj)
            %Returns true if the active physics node refers to a boundary
            %method
            physics = obj.mActiveNode;
            bool = strcmp(physics.getType, 'PressureAcousticsBoundaryElements') ||...
                strcmp(physics.getType, 'BoundaryModeAcoustics');
        end
    end
end