classdef (Abstract)itaComsolNode < handle
    %itaComsolRootNode Abstract class that represents a node of a Comsol
    %model tree (usually at first level). These elements again can hold
    %multiple Comsol nodes.
    %   Also provides basic methods to work on Comsol nodes
    %
    %   First level model tree elements include:
    %   -Functions
    %   -Geometry
    %   -Selections
    %   -Materials
    %   -Physics
    %   -Mesh
    %   -Study
    %   -Batch
    %   -Results
    %   Use mphnavigator() on a comsol model for more information
    %   
    %   See also itaComsolModel
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolNode">doc itaComsolNode</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = protected)
        mModel;             %itaComsolModel object
        mActiveNode;        %Active comsol node
        mParentNode;        %Corresponding parent node. For first level nodes this equals modelNode
    end
    properties(Access = private)
        mListNodeTag;
        mNodeClassName;
    end
    properties(Dependent = true, Access = private)
        rootNode;           %Node containing the children (=obj.mParentNode.(obj.mListNodeTag))
    end
    properties(Dependent = true, Access = protected)
        modelNode;          %Comsol model node (= mModel.modelNode)
    end
    properties(Dependent = true)
        activeNode;         %The active child node
    end
    
    %% Constructor
    methods
        function obj = itaComsolNode(comsolModel, listTag, nodeClassName, parentNode)
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel),...
                'First input must be an itaComsolModel')
            assert(ischar(listTag) && isrow(listTag), 'Second input must be a char row vector')
            assert(ischar(nodeClassName) && isrow(nodeClassName), 'Third input must be a char row vector')
            if nargin == 3; parentNode = comsolModel.modelNode; end
            assert(isempty(parentNode) || contains(class(parentNode), 'com.comsol.clientapi.impl.'), 'Fourth input must be a comsol node')
            
            obj.mModel = comsolModel;
            obj.mListNodeTag = listTag;
            obj.mNodeClassName = nodeClassName;
            obj.mParentNode = parentNode;
            
            obj.mActiveNode = obj.First();
        end
    end
    
    %% Dependent nodes
    methods
        function modelNode = get.modelNode(obj)
            modelNode = obj.mModel.modelNode;
        end
        function rootNode = get.rootNode(obj)
            rootNode = obj.mParentNode.(obj.mListNodeTag);
        end
    end
    
    %% Accessing Children
    methods
        function comsolNode = get.activeNode(obj)
            comsolNode = obj.mActiveNode;
        end
        function set.activeNode(obj, comsolNode)
            assert(isa(comsolNode, obj.mNodeClassName), ['Can only assign a Comsol node of type ' obj.mNodeClassName])
            obj.mActiveNode = comsolNode;
        end
        
        function comsolNode = First(obj)
            %Returns the first child node
            %   Returns [] if no child exists
            comsolNode = [];
            tags = obj.getRootTags();
            if isempty(tags); return; end
            comsolNode = obj.getRootChildByTag(tags(1));
        end
        function comsolNodeCellArray = All(obj)
            %Returns all child nodes as cell array
            tags = obj.getRootTags();
            comsolNodeCellArray = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                comsolNodeCellArray{idxNode} = obj.getRootChildByTag(tags(idxNode));
            end
        end
        function comsolNode = Child(obj, tag)
            %Returns a specific child giving its tag
            %   Returns [] if child does not exist
            assert(ischar(tag) && isrow(tag), 'Input must be a char row vector')
            comsolNode = [];
            if obj.hasChildNode(obj.rootNode, tag)
                comsolNode = obj.getRootChildByTag(tag);
            end
        end
        function comsolNode = ChildByName(obj, name)
            %Returns a specific child giving its name/label
            %   Returns [] if child does not exist
            assert(ischar(name) && isrow(name), 'Input must be a char row vector')
            comsolNode = [];
            childNodes = obj.All();
            for idxNode = 1:numel(childNodes)
                currentNode = childNodes{idxNode};
                if strcmp(currentNode.name(), name)
                    comsolNode = currentNode;
                    return;
                end
            end
        end
        function comsolNode = ChildByIndex(obj, idx)
            %Returns a specific child giving its index
            %   Throws an error if index exceeds boundaries
            assert(isnumeric(idx) && isscalar(idx) && mod(idx,1)==0 && idx > 0,...
                'Input must be a single integer')
            childNodes = obj.All();
            assert( idx <= numel(childNodes), 'Index exceeds number of children')
            comsolNode = childNodes{idx};
        end
        
        function names = ChildNames(obj)
            %Returns the names/labels of all child nodes as cell array
            childNodes = obj.All();
            names = cell(size(childNodes));
            for idxNode = 1:numel(childNodes)
                names{idxNode} = char( childNodes{idxNode}.name );
            end
        end
    end
    methods(Access = private)
        function tags = getRootTags(obj)
            tags = obj.getChildNodeTags(obj.rootNode);
        end
        function comsolNode = getRootChildByTag(obj, tag)
            comsolNode = obj.mParentNode.(obj.mListNodeTag)(tag);
        end
    end
    
    %% Accessing Features (of active node)
    methods
        function SetPositionOfFeature(obj, featureTag, positionIndex)
            %If the feature of given tag exist in the active node, it is
            %moved to the given position within the sequence
            assert(ischar(featureTag) && isrow(featureTag), 'featureTag must be a char row vector')
            assert(isnumeric(positionIndex) && positionIndex >= 1 && mod(positionIndex,1)==0, 'positionIndex must be an integer >= 1')
            
            if isempty(obj.activeNode); return; end
            if ~obj.hasFeatureNode(obj.activeNode, featureTag); return; end
            
            obj.activeNode.feature.move(featureTag, positionIndex);
        end
    end
    
    %% -----------Helper Function Section------------------------------- %%    
    %% Static functions applying directly to model nodes
    methods(Access = protected, Static = true)
        %% Children
        function out = getChildNodeTags(comsolNode)
            
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            if ismethod( comsolNode, 'tags' )
                out = comsolNode.tags();
            elseif ismethod( comsolNode, 'objectNames' )
                out = comsolNode.objectNames();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolNode.getChildNodeTags( comsolNode.feature() );
            elseif ismethod( comsolNode, 'group' )
                out = itaComsolNode.getChildNodeTags( comsolNode.group() );
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return children'])
            end
        end
        
        function [bool] = hasChildNode(comsolNode, childTag)
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            bool = false;
            if ~ismethod(comsolNode, 'tags'); return; end
            
            tags = cell(comsolNode.tags);
            idxTag = strcmp(tags, childTag);
            if sum(idxTag) ~=1; return; end
            
            bool = true;
        end
        
        %% Nodes with features
        function childNodes = getFeatureNodes(comsolNode)
            assert(ismethod(comsolNode, 'feature'), 'Given Comsol node does not have features')
            tags = itaComsolNode.getChildNodeTags(comsolNode);
            childNodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                childNodes{idxNode} = comsolNode.feature(tags(idxNode));
            end
        end
        function childNodes = getFeatureNodesByType(comsolNode, type)
            assert(ismethod(comsolNode, 'feature'), 'Given Comsol node does not have features')
            tags = itaComsolNode.getChildNodeTags(comsolNode);
            childNodes = {};
            for idxTag = 1:numel(tags)
                node = comsolNode.feature(tags(idxTag));
                if strcmp(node.getType, type)
                    childNodes{end+1} = node;
                end
            end
        end
        
        function [bool, featureNode] = hasFeatureNode(comsolNode, featureTag)
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            featureNode = [];
            bool = false;
            if ~ismethod(comsolNode, 'feature'); return; end
            if ~ismethod(comsolNode.feature, 'tags'); return; end
            
            tags = cell(comsolNode.feature.tags);
            idxTag = strcmp(tags, featureTag);
            if sum(idxTag) ~=1; return; end
            
            featureNode = comsolNode.feature( tags(idxTag) );
            bool = true;
        end
        
        %% Properties
        function setNodeProperties(comsolNode, propertyStruct)
            
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            propertyNames = fieldnames(propertyStruct);
            for idxProperty = 1:numel(propertyNames)
                currentProperty = propertyNames{idxProperty};
                comsolNode.set(currentProperty, propertyStruct.(currentProperty));
            end
        end
    end
    
    %% Check input
    methods(Access = protected, Static = true)
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

