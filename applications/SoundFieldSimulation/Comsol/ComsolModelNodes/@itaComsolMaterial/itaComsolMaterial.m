classdef itaComsolMaterial < itaComsolNode
    %itaComsolMaterial Interface to the material nodes of an itaComsolModel
    %   This class is just a place-holder so far and has no functionality.
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolMaterial">doc itaComsolMaterial</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    %% Constructor
    methods
        function obj = itaComsolMaterial(comsolModel)
            obj@itaComsolNode(comsolModel, 'material', 'com.comsol.clientapi.impl.MaterialClient')
        end
    end
end