classdef itaComsolMesh < itaComsolNode
    %itaComsolMesh Interface to the mesh nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolMesh(comsolModel)
            obj@itaComsolNode(comsolModel, 'mesh', 'com.comsol.clientapi.impl.MeshSequenceClient')
        end
    end
    
    %% Size Nodes
    methods
        function sizeNode = GetMainSizeNode(obj)
            %Returns the default size node of the active mesh node which
            %sits at the very top of the mesh sequence.
            sizeNode = [];
            meshNode = obj.activeNode;
            if ~isempty(meshNode) && obj.hasFeatureNode('size')
                sizeNode = meshNode.feature('size');
            end
        end
        
        function sizeNode = CreateSize(obj, sizeTag, selectionTag)
            assert(ischar(sizeTag) && isrow(sizeTag), 'sizeTag must be a char row vector')
            if nargin == 2
                selectionTag = '';
            end
            assert(ischar(selectionTag) && (isrow(selectionTag) || isempty(selectionTag)),...
                'selectionTag must be a char row vector');
            
            meshNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(meshNode, sizeTag)
                meshNode.create(sizeTag, 'Size');
                meshNode.feature(sizeTag).label(sizeTag);
            end
            sizeNode = meshNode.feature(sizeTag);
            if ~isempty(selectionTag)
                sizeNode.selection.named(selectionTag);
            else
                sizeNode.selection.geom( char(obj.mModel.geometry.activeNode.tag) );
            end
        end
    end
    methods(Static = true)
        %TODO: Implement
        %function SetSizeParameters(sizeNode, params)
        %end
    end
end