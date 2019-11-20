classdef itaComsolPhysics < itaComsolNode
    %itaComsolPhysics Interface to the physics node of an itaComsolModel
    %   Allows to adjust parameters of a comsol physics node. Also allows
    %   to create new nodes that represent certain acoustic properties
    %   (e.g. for sources or boundaries).
    %   This is done using the Create...-functions of this class. These
    %   functions are given a unique tag. Existing physic nodes can be
    %   adjusted by the same function that created them using the same tag.
    %   
    %   See also itaComsolModel, itaComsolNode, itaComsolSource,
    %   itaComsolImpedance
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolPhysics">doc itaComsolPhysics</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
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
        function SetRelativeHumidity(obj, humidity)
            %Sets the relative humidity for the acoustic simulation.
            %Expects a single numeric value between 0 and 1
            assert(isnumeric(humidity) && isscalar(humidity) && humidity >= 0  && humidity <= 1,...
                'Input must be a numeric scalar between 0 and 1')
            acousticModelNode = obj.getAcousticModelNode();
            assert(~isempty(acousticModelNode), 'No Comsol node for acoustic model found')
            
            acousticModelNode.set('minput_relativehumidity', humidity);
        end
    end
    methods(Access = private)
        function acousticModelNode = getAcousticModelNode(obj)
            %Note: This assumes that the first child of the physics node is
            %always the acoustic model node
            physics = obj.activeNode;
            physicsFeatures = obj.getFeatureNodes(physics);
            
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
            impedanceNodes = obj.getFeatureNodesByType(obj.mActiveNode, 'Impedance');
        end
        function impedanceNodeOfBoundary = ImpedanceNodeByBoundaryGroupName(obj, boundaryGroupName)
            %Returns the first impedance node of the active physics node that
            %is connected to given boundary group (= Comsol selection). Returns
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
        
        function soundHardNode = CreateSoundHardBoundary(obj, soundHardTag, selectionTag)
            %Creates a sound hard boundary node for the active physics node
            %   Inputs:
            %   soundHardTag            Tag for sound hard node [char row vector]
            %   selectionTag            Tag of the selection the impedance is linked to [char row vector]
            assert(ischar(soundHardTag) && isrow(soundHardTag), 'First input must be a char row vector')
            assert(ischar(selectionTag) && isrow(selectionTag), 'Second input must be a char row vector')
            
            physics = obj.activeNode;
            if ~obj.hasFeatureNode(physics, soundHardTag)
                physics.create(soundHardTag, 'SoundHard', 2);
            end
            soundHardNode = physics.feature(soundHardTag);
            soundHardNode.selection.named(selectionTag);
        end
    end
    
    %% Poroacoustics
    methods
        function poroacousticsNodes = PoroacousticsNodes(obj)
            %Returns the poroacoustics nodes of the active physics node.
            poroacousticsNodes = obj.getFeatureNodesByType(obj.mActiveNode, 'PoroacousticsModel');
        end
        function poroacousticsNodeOfDomain = PoroacousticsNodeByVolumeGroupName(obj, volumeGroupName)
            %Returns the first poroacoustics node of the active physics node
            %that is connected to given volume group (= Comsol domain selection).
            %Returns an empty object if no poroacoustics model is connected
            %to the given selection.
            assert(ischar(volumeGroupName) && isrow(volumeGroupName), 'Input must be a char row vector')
            poroacousticsNodeOfDomain = [];
            
            volumeGroup = obj.mModel.selection.VolumeGroup(volumeGroupName);
            if isempty(volumeGroup); return; end
            
            poroacousticsNodes = obj.PoroacousticsNodes();
            for idxPoroacoustics = 1:numel(poroacousticsNodes)
                selectionTag = poroacousticsNodes{idxPoroacoustics}.selection.named;
                if strcmp(selectionTag, volumeGroup.tag)
                    poroacousticsNodeOfDomain = poroacousticsNodes{idxPoroacoustics};
                    return
                end
            end
        end
        
        function poroacousticsNode = CreatePoroacoustics(obj, poroacousticsTag, selectionTag)
            %Creates a poroacoustics model for the active physics node
            %   Inputs:
            %   poroacousticsTag        Tag for poroacoustics node [char row vector]
            %   selectionTag            Tag of the selection the poroacoustics model is linked to [char row vector]
            assert(ischar(poroacousticsTag) && isrow(poroacousticsTag), 'First input must be a char row vector')
            assert(ischar(selectionTag) && isrow(selectionTag), 'Second input must be a char row vector')
            
            physics = obj.activeNode;
            if ~obj.hasFeatureNode(physics, poroacousticsTag)
                physics.create(poroacousticsTag, 'PoroacousticsModel', 3);
            end
            poroacousticsNode = physics.feature(poroacousticsTag);
            poroacousticsNode.selection.named(selectionTag);
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