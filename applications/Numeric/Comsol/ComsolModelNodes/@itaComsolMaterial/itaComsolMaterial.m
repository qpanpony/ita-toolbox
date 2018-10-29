classdef itaComsolMaterial < itaComsolNode
    %itaComsolMaterial Interface to the material nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolMaterial(comsolModel)
            obj@itaComsolNode(comsolModel, 'material', 'com.comsol.clientapi.impl.MaterialClient')
        end
    end
end