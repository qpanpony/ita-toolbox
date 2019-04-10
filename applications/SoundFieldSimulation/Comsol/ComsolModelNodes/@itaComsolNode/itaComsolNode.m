classdef (Abstract)itaComsolNode < handle
    %itaComsolRootNode Abstract class that represents a first level
    %node of a Comsol model tree. These elements again can hold
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
    
    properties(Access = protected)
        mModel;             %itaComsolModel object
        mActiveNode;        %Active comsol node
    end
    properties(Access = private)
        mListNodeTag;
        mNodeClassName;
    end
    properties(Dependent = true, Access = protected)
        modelNode;          %Comsol model node (=mModel.modelNode)
    end
    properties(Dependent = true)
        activeNode;         %The active child node
    end
    
    %% Constructor
    methods
        function obj = itaComsolNode(comsolModel, listTag, nodeClassName)
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel),...
                'First input must be an itaComsolModel')
            assert(ischar(listTag) && isrow(listTag), 'Second input must be a char row vector')
            assert(ischar(nodeClassName) && isrow(nodeClassName), 'Third input must be a char row vector')
            
            obj.mModel = comsolModel;
            obj.mListNodeTag = listTag;
            obj.mNodeClassName = nodeClassName;
            
            obj.mActiveNode = obj.First();
        end
    end
    
    %% Accessing comsol nodes
    methods
        function modelNode = get.modelNode(obj)
            modelNode = obj.mModel.modelNode;
        end
        
        function comsolNode = get.activeNode(obj)
            comsolNode = obj.mActiveNode;
        end
        function set.activeNode(obj, comsolNode)
            assert(isa(comsolNode, obj.mNodeClassName), ['Can only assign a Comsol node of type ' obj.mNodeClassName])
            obj.mActiveNode = comsolNode;
        end
        
        function comsolNode = First(obj)
            %Returns the first child node
            comsolNode = obj.getFirstRootElementChild(obj.mListNodeTag);
        end
        function comsolNodeCellArray = All(obj)
            %Returns all child nodes as cell array
            comsolNodeCellArray = obj.getRootElementChildren(obj.mListNodeTag);
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
    %% Root node functions
    methods(Access = private)
        function nodes = getRootElementChildren(obj, rootName)
            tags = obj.getChildNodeTags(obj.modelNode.(rootName));
            nodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                nodes{idxNode} = obj.modelNode.(rootName)(tags(idxNode));
            end
        end
        function node = getFirstRootElementChild(obj, rootName)
            node = [];
            tags = obj.getChildNodeTags(obj.modelNode.(rootName));
            if isempty(tags); return; end
            node = obj.modelNode.(rootName)(tags(1));
        end
    end
    
    %% Functions applying directly to model nodes
    methods(Access = protected, Static = true)
        function childNodes = getChildNodes(comsolNode)
            tags = itaComsolNode.getChildNodeTags(comsolNode);
            childNodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                if ismethod(comsolNode, 'feature')
                    childNodes{idxNode} = comsolNode.feature(tags(idxNode));
                else
                    childNodes{idxNode} = comsolNode(tags(idxNode));
                end
            end
        end
        function childNodes = getChildNodesByType(comsolNode, type)
            tags = itaComsolNode.getChildNodeTags(comsolNode);
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
            
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            if ismethod( comsolNode, 'tags' )
                out = comsolNode.tags();
            elseif ismethod( comsolNode, 'objectNames' )
                out = comsolNode.objectNames();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolNode.getChildNodeTags( comsolNode.feature() );
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return children'])
            end
        end
        
        function out = getNodeType(comsolNode)
            
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            if strcmp(comsolNode.scope(), 'root')
                warning('Root objects do not have a type. Returning name instead.')
                out = comsolNode.name();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolNode.getNodeType( comsolNode.feature() );
            elseif ismethod( comsolNode, 'getType' )
                out = comsolNode.getType();
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return a type'])
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
        
        function [bool] = hasChildNode(comsolNode, childTag)
            itaComsolNode.checkInputForComsolNode(comsolNode);
            
            bool = false;
            if ~ismethod(comsolNode, 'tags'); return; end
            
            tags = cell(comsolNode.tags);
            idxTag = strcmp(tags, childTag);
            if sum(idxTag) ~=1; return; end
            
            bool = true;
        end
        
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

