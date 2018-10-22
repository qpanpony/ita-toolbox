classdef itaComsolMaterial < itaComsolModelTreeElement
    %itaComsolMaterial Interface to the material nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolMaterial(comsolModel)
            obj@itaComsolModelTreeElement(comsolModel, 'material', 'com.comsol.clientapi.impl.MaterialClient')
        end
    end
end