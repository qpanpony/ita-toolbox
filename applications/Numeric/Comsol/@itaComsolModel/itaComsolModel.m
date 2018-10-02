classdef itaComsolModel < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        mModel;
    end
    
    methods
        function obj = itaComsolModel(comsolModel)
            if ~isa(comsolModel, 'com.comsol.clientapi.impl.ModelClient')
                error('Input must be a comsol model (com.comsol.clientapi.impl.ModelClient)')
            end
            obj.mModel = comsolModel;
        end
    end
    
    %% Geometry
    methods
        function geom = Geometry(obj)
            %Returns all geometry nodes as cell array
            geom = obj.getRootElementChildren('geom');
        end
        function geom = FirstGeometry(obj)
            %Returns the first geometry node if atleast one geometry exists
            geom = obj.getFirstRootElementChild('geom');
        end
    end
    
    %% Selections == Groups
    methods
        function select = Selection(obj)
            %Returns all selection nodes as cell array
            select = obj.getRootElementChildren('selection');
        end
        function boundaryGroups = BoundaryGroups(obj)
            %Returns all boundary groups (2D selections) as cell array
            boundaryGroups = obj.groupsOfDimension(2);
        end
        function volumeGroups = VolumeGroups(obj)
            %Returns all volume groups (3D selections) as cell array
            volumeGroups = obj.groupsOfDimension(3);
        end
        
        function boundaryGroupNames = BoundaryGroupNames(obj)
            %Returns the names of all boundary groups (2D selections) as cell array
            boundaryGroupNames = obj.groupNames(obj.BoundaryGroups());
        end
        function boundaryGroupNames = VolumeGroupNames(obj)
            %Returns the names of all volume groups (3D selections) as cell array
            boundaryGroupNames = obj.groupNames(obj.VolumeGroups());
        end
    end
    
    methods(Access = private)
        function groups = groupsOfDimension(obj, dimension)
            groups = obj.Selection();
            if isempty(groups); return; end
            
            removeSelections = false(size(groups));
            for idxSelection = 1:numel(groups)
                if ~isequal(groups{idxSelection}.dimension, dimension)
                    removeSelections(idxSelection) = true;
                end
            end
            groups(removeSelections) = [];
        end
        function groupNames = groupNames(~, groups)
            groupNames = cell(size(groups));
            for idxGroup = 1:numel(BoundaryGroups)
                groupNames{idxGroup} = groups{idxGroup}.name;
            end
        end
    end
    
    %% Materials
    methods
        function materials = Material(obj)
            materials = obj.getRootElementChildren('material');
        end
    end
    
    %% Physics
    methods
        function physics = Physics(obj)
            physics = obj.getRootElementChildren('physics');
        end
        function physics = FirstPhysics(obj)
            physics = obj.getFirstRootElementChild('physics');
        end
        
        %function impedance = CreateImpedance(obj, physics, boundaryGroupName)
        %    assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'First input must be a Comsol Physics node')
        %    assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Second input must be a char row vector')
        %    
        %    idxBoundaryGrp = strcmp(obj.BoundaryGroupNames(), boundaryGroupName);
        %    if sum(idxBoundaryGrp) ~= 1
        %        error('There must be exactly one matching boundary group for the given name')
        %    end
        %    selectionTag = obj.BoundaryGroups{idxBoundaryGrp}.tag;
        %    
        %    impedance = phyics.create('imp1', 'Impedance', 2);
        %    physics.feature('imp1').selection.named(selectionTag);
        %end
        
        function impedanceNodes = ImpedanceNodes(obj, physics)
            assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'Input must be a Comsol Physics node')
            impedanceNodes = obj.getChildNodesByType(physics, 'Impedance');
        end
        
        function impedanceOfBoundary = GetImpedanceByBoundaryGroupName(obj, physics, boundaryGroupName)
            assert(isa(physics, 'com.comsol.clientapi.physics.impl.PhysicsClient'), 'First input must be a Comsol Physics node')
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Second input must be a char row vector')
            impedanceOfBoundary = [];
            
            idxBoundary = strcmp(obj.BoundaryGroupNames, boundaryGroupName);
            if sum(idxBoundary) ~= 1; return; end
            boundaryGroup = obj.BoundaryGroups{idxBoundary};
            
            impedanceNodes = obj.ImpedanceNodes(physics);
            for idxImpedance = 1:numel(impedanceNodes)
                selectionTag = impedanceNodes{idxImpedance}.selection.named;
                if strcmp(selectionTag, boundaryGroup.tag)
                    impedanceOfBoundary = impedanceNodes{idxImpedance};
                    return
                end
            end
        end
    end
    
    %% Study
    methods
        function studies = Study(obj)
            studies = obj.getRootElementChildren('study');
        end
        function study = FirstStudy(obj)
            study = obj.getFirstRootElementChild('study');
        end
        
        function SetFrequencyVector(obj, freqVector, study)
            assert(isnumeric(freqVector) && isrow(freqVector), 'First input must be a numeric row vector')
            if nargin == 1
                study = obj.FirstStudy();
                errorStr = 'No default study could be found';
            else
                errorStr = 'Second input must be a Comsol Study node';
            end
            assert(isa(study, 'com.comsol.clientapi.impl.StudyClient'), errorStr)
            
            [freqNodeDefined, freqNode] = obj.hasFeatureNode( study, 'freq' );
            if ~freqNodeDefined; error('Given Comsol study is no frequency study'); end
            
            freqNode.set('plist', num2str(freqVector))
        end
    end
    
    %% General Helpers
    methods(Access = private)
        function nodes = getRootElementChildren(obj, rootName)
            tags = obj.getChildNodeTags(obj.mModel.(rootName));
            nodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                nodes{idxNode} = obj.mModel.(rootName)(tags(idxNode));
            end
        end
        function node = getFirstRootElementChild(obj, rootName)
            node = [];
            tags = obj.getChildNodeTags(obj.mModel.(rootName));
            if isempty(tags); return; end
            node = obj.mModel.(rootName)(tags(1));
        end
    end
    
    %% Static functions for model nodes
    methods(Access = private, Static = true)
        function childNodes = getChildNodes(comsolNode)
            tags = itaComsolModel.getChildNodeTags(comsolNode);
            childNodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                if ismethod(comsolNode, 'feature')
                    childNodes{idxNode} = comsolNode.feature(tags(idxTag));
                else
                    childNodes{idxNode} = comsolNode(tags(idxTag));
                end
            end
        end
        function childNodes = getChildNodesByType(comsolNode, type)
            tags = itaComsolModel.getChildNodeTags(comsolNode);
            childNodes = {};
            for idxTag = 1:numel(tags)
                if ismethod(comsolNode, 'feature')
                    node = comsolNode.feature(tags(idxTag));
                else
                    node = comsolNode(tags(idxTag));
                end
                if strcmp(node.getType, type)
                    childNodes{end+1} = node;
                end
            end
        end
        
        function out = getChildNodeTags(comsolNode)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            if ismethod( comsolNode, 'tags' )
                out = comsolNode.tags();
            elseif ismethod( comsolNode, 'objectNames' )
                out = comsolNode.objectNames();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolModel.getChildNodeTags( comsolNode.feature() );
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return children'])
            end
        end
        
        function out = getNodeType(comsolNode)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            if strcmp(comsolNode.scope(), 'root')
                warning('Root objects do not have a type. Returning name instead.')
                out = comsolNode.name();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolModel.getNodeType( comsolNode.feature() );
            elseif ismethod( comsolNode, 'getType' )
                out = comsolNode.getType();
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return a type'])
            end
        end
        
        function [bool, childNode] = hasFeatureNode(comsolNode, featureTag)
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            childNode = [];
            bool = false;            
            if ~ismethod(comsolNode, 'feature'); return; end
            if ~ismethod(comsolNode.feature, 'tags'); return; end
            
            tags = comsolNode.feature.tags;
            idxTag = strcmp(tags, featureTag);
            if sum(idxTag) ~=1; return; end
            
            childNode = comsolNode.feature( tags(idxTag) );
            bool = true;
        end
        
        function setNodeProperties(comsolNode, propertyStruct)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            propertyNames = fieldnames(propertyStruct);
            for idxProperty = 1:numel(propertyNames)
                currentProperty = propertyNames{idxProperty};
                comsolNode.set(currentProperty, propertyStruct.(currentProperty));
            end
        end
    end
    
    %% Check input
    methods(Access = private, Static = true)
        function checkInputForComsolNode(input)
            if ~contains(class(input), 'com.comsol') || ~contains(class(input), '.impl.')
                error('Input must be a Comsol Node');
            end
            if isa(input, 'com.comsol.clientapi.impl.ModelClient')
                error('Input must not be an Comsol model but one of its child nodes')
            end
        end
    end
end

