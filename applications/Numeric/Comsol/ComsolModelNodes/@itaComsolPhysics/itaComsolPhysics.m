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
    
    %% Acoustic model
    methods
        function SetAmbientTemperature(obj, temperature)
            %Sets the ambient temperature for the acoustic simulation.
            %Expects a single numeric value in °C
            assert(isnumeric(temperature) && isscalar(temperature) && temperature >= -273.15,...
                'Input must be a numeric scalar >= -273.15')
            acousticModelNode = obj.getAcousticModelNode();
            assert(~isempty(acousticModelNode), 'No Comsol node for acoustic model found')
            
            acousticModelNode.set('minput_temperature', temperature + 273.15);
        end
        function SetHydrostaticPressure(obj, pressure)
            %Sets the hydrostatic pressure for the acoustic simulation.
            %Expects a single numeric value in Pa
            assert(isnumeric(pressure) && isscalar(pressure) && pressure >= 0,...
                'Input must be a numeric scalar >= 0')
            acousticModelNode = obj.getAcousticModelNode();
            assert(~isempty(acousticModelNode), 'No Comsol node for acoustic model found')
            
            acousticModelNode.set('minput_pressure', pressure);
        end
    end
    methods(Access = private)
        function acousticModelNode = getAcousticModelNode(obj)
            %Note: This assumes that the first child of the physics node is
            %always the acoustic model node
            physics = obj.activeNode;
            physicsFeatures = obj.getChildNodes(physics);
            
            acousticModelNode = [];
            if ~isempty(physicsFeatures)
                acousticModelNode = physicsFeatures{1};
            end
        end
    end
    
    %% Impedance
    methods
        function impedanceNodes = ImpedanceNodes(obj)
            %Returns the impedance nodes of the active physics node.
            impedanceNodes = obj.getChildNodesByType(obj.mActiveNode, 'Impedance');
        end
        function impedanceNodeOfBoundary = ImpedanceNodeByBoundaryGroupName(obj, boundaryGroupName)
            %Returns the impedance node of the active physics node that is
            %connected to given boundary group (= Comsol selection). Returns
            %an empty object if no impedance is connected to the given selection.
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Input must be a char row vector')
            impedanceNodeOfBoundary = [];
            
            boundaryGroup = obj.mModel.selection.BoundaryGroup(boundaryGroupName);
            if isempty(boundaryGroup); return; end
            
            impedanceNodes = obj.ImpedanceNodes();
            for idxImpedance = 1:numel(impedanceNodes)
                selectionTag = impedanceNodes{idxImpedance}.selection.named;
                if strcmp(selectionTag, boundaryGroup.tag)
                    impedanceNodeOfBoundary = impedanceNodes{idxImpedance};
                    return
                end
            end
        end
        
        function impedanceNode = CreateImpedance(obj, impedanceTag, selectionTag, impedanceExpression)
            %Creates a boundary impedance node for the active physics node
            %   Inputs:
            %   impedanceTag            Tag for impedance node [char row vector]
            %   selectionTag            Tag of the selection the impedance is linked to [char row vector]
            %   impedanceExpression     Expression for the impedance value [char row vector || double scalar]
            assert(ischar(impedanceTag) && isrow(impedanceTag), 'First input must be a char row vector')
            assert(ischar(selectionTag) && isrow(selectionTag), 'Second input must be a char row vector')
            assert( (ischar(impedanceExpression) && isrow(impedanceExpression)) ||...
                (isnumeric(impedanceExpression) && isscalar(impedanceExpression)),...
                'Third input must be a char row vector or a double scalar')
            
            physics = obj.activeNode;
            if ~obj.hasFeatureNode(physics, impedanceTag)
                physics.create(impedanceTag, 'Impedance', 2);
            end
            impedanceNode = physics.feature(impedanceTag);
            impedanceNode.selection.named(selectionTag);
            impedanceNode.set('ImpedanceModel', 'UserDefined');
            impedanceNode.set('Zi', impedanceExpression);
        end
    end
    
    %% Source related
    methods
        function normalVelocityNode = CreateNormalVelocity(obj, sourceTag, selectionTag, normalVelocityExpression)
            %Creates a normal velocity node for the active physics node
            %   Inputs:
            %   sourceTag                   Tag for source node [char row vector]
            %   selectionTag                Tag of the selection the normal velocity source is linked to [char row vector]
            %   normalVelocityExpression    Expression for normal velocity [char row vector || double scalar]
            assert(ischar(sourceTag) && isrow(sourceTag), 'First input must be a char row vector')
            assert(ischar(selectionTag) && isrow(selectionTag), 'Second input must be a char row vector')
            assert( (ischar(normalVelocityExpression) && isrow(normalVelocityExpression)) ||...
                (isnumeric(normalVelocityExpression) && isscalar(normalVelocityExpression)),...
                'Third input must be a char row vector or a double scalar')
            
            physics = obj.activeNode;
            if ~obj.hasFeatureNode(physics, sourceTag)
                physics.create(sourceTag, 'NormalVelocity', 2);
            end
            normalVelocityNode = physics.feature(sourceTag);
            normalVelocityNode.selection.named(selectionTag);
            
            normalVelocityNode.set('nvel', normalVelocityExpression);
        end
        
        function pointSourceNode = CreateMonopolePointSource(obj, sourceTag, selectionTag, volumeFlowExpression)
            %Creates a monopole point source node for the active physics
            %node
            %   Inputs:
            %   sourceTag               Tag for source node [char row vector]
            %   selectionTag            Tag of the selection the point source is linked to [char row vector]
            %   volumeFlowExpression    Expression for volume flow of point source [char row vector || double scalar]
            assert(ischar(sourceTag) && isrow(sourceTag), 'First input must be a char row vector')
            assert(ischar(selectionTag) && isrow(selectionTag), 'Second input must be a char row vector')
            assert( (ischar(volumeFlowExpression) && isrow(volumeFlowExpression)) ||...
                (isnumeric(volumeFlowExpression) && isscalar(volumeFlowExpression)),...
                'Third input must be a char row vector or a double scalar')
            
            physics = obj.activeNode;
            if ~obj.hasFeatureNode(physics, sourceTag)
                physics.create(sourceTag, 'FrequencyMonopolePointSource', 0);
            end
            pointSourceNode = physics.feature(sourceTag);
            pointSourceNode.selection.named(selectionTag);
            pointSourceNode.set('Type', 'Flow');
            pointSourceNode.set('Qs', volumeFlowExpression);
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