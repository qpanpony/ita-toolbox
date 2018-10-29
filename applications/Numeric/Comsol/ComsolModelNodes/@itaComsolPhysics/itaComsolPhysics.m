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
    
    %% Source related
    methods
        function normalVelocityNode = CreateNormalVelocity(obj, sourceTag, selectionTag, normalVelocityExpression)
            %Creates a normal velocity node for the active physics node
            %   Inputs:
            %   sourceTag                   Tag for source node [char row vector]
            %   selectionTag                Tag of the selection the point source is linked to [char row vector]
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