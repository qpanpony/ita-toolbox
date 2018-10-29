classdef itaComsolMesh < itaComsolNode
    %itaComsolMesh Interface to the mesh nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolMesh(comsolModel)
            obj@itaComsolNode(comsolModel, 'mesh', 'com.comsol.clientapi.impl.MeshSequenceClient')
        end
    end
end