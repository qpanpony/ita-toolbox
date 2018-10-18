classdef (Abstract)itaComsolModelTreeElement < handle
    %itaComsolRootNode Abstract class that represents a first level
    %element of a Comsol model tree. These elements again can hold
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
    %   -Results
    %   Use mphnavigator() on a comsol model for more information
    
    properties(Access = protected)
        mModel;             %Comsol model node
        mActiveNode;        %Active comsol node
    end
    properties(Access = private)
        mListNodeTag;
        mNodeClassName;
    end
    properties(Dependent = true)
        activeNode;
    end
    properties(Dependent = true, SetAccess = private)
        firstNode;
        nodes;
    end
    
    %% Constructor
    methods
        function obj = itaComsolModelTreeElement(comsolModel, listTag, nodeClassName)
            assert(isa(comsolModel, 'com.comsol.clientapi.impl.ModelClient'),...
                'First input must be a comsol model (com.comsol.clientapi.impl.ModelClient)')
            assert(ischar(listTag) && isrow(listTag), 'Second input must be a char row vector')
            assert(ischar(nodeClassName) && isrow(nodeClassName), 'Third input must be a char row vector')
            
            obj.mModel = comsolModel;
            obj.mListNodeTag = listTag;
            obj.mNodeClassName = nodeClassName;
            
            obj.mActiveNode = obj.firstNode;
        end
    end
    
    %% Accessing comsol nodes
    methods
        function comsolNode = get.activeNode(obj)
            comsolNode = obj.mActiveNode;
        end
        function set.activeNode(obj, comsolNode)
            assert(isa(comsolNode, obj.mNodeClassName), ['Can only assign a Comsol node of type ' obj.mNodeClassName])
            obj.activeNode = comsolNode;
        end
        
        function comsolNode = get.firstNode(obj)
            comsolNode = obj.getFirstRootElementChild(obj.mListNodeTag);
        end
        function comsolNodeCellArray = get.nodes(obj)
            comsolNodeCellArray = obj.getRootElementChildren(obj.mListNodeTag);
        end
    end
    
    %% -----------Helper Function Section------------------------------- %%
    %% Root node functions
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
    
    %% Functions applying directly to model nodes
    methods(Access = protected, Static = true)
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
        
        function [bool, featureNode] = hasFeatureNode(comsolNode, featureTag)
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
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
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            bool = false;
            if ~ismethod(comsolNode, 'tags'); return; end
            
            tags = cell(comsolNode.tags);
            idxTag = strcmp(tags, childTag);
            if sum(idxTag) ~=1; return; end
            
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

