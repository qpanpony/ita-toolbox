classdef itaComsolSelection < itaComsolNode
    %itaComsolSelection Interface to the selection nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolSelection(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'selection', 'com.comsol.clientapi.impl.SelectionFeatureClient')
        end
    end
    
    %% Get Selections of distinct dimension
    methods
        function boundaryGroups = BoundaryGroups(obj)
            %Returns all boundary groups (2D selections) as cell array
            boundaryGroups = obj.selectionsOfDimension(2);
        end
        function volumeGroups = VolumeGroups(obj)
            %Returns all volume groups (3D selections) as cell array
            volumeGroups = obj.selectionsOfDimension(3);
        end
        
        function boundaryGroupNames = BoundaryGroupNames(obj)
            %Returns the names of all boundary groups (2D selections) as cell array
            boundaryGroupNames = obj.selectionNames(obj.BoundaryGroups());
        end
        function boundaryGroupNames = VolumeGroupNames(obj)
            %Returns the names of all volume groups (3D selections) as cell array
            boundaryGroupNames = obj.selectionNames(obj.VolumeGroups());
        end
    end
    methods(Access = private)
        function selections = selectionsOfDimension(obj, dimension)
            selections = obj.All();
            if isempty(selections); return; end
            
            removeSelections = false(size(selections));
            for idxSelection = 1:numel(selections)
                if ~isequal(selections{idxSelection}.dimension, dimension)
                    removeSelections(idxSelection) = true;
                end
            end
            selections(removeSelections) = [];
        end
        function selNames = selectionNames(~, selections)
            selNames = cell(size(selections));
            for idxSelection = 1:numel(selections)
                selNames{idxSelection} = char( selections{idxSelection}.name );
            end
        end
    end
    
    %% Coordinates
    %NOTE:
    %The following functions are hidden because they return the coords of
    %geometry entities, without giving information about their shape.
    %For example a circle has 4 points in Comsol. Plotting these in Matlab
    %via Patch creates a rectangle
    methods(Hidden = true)
        function boundaryGroupCoords = BoundaryGroupCoords(obj)
            %Returns the coordinates of all boundary groups (2D selections)
            %as cell array ( cell{idxGroup}{idxPolygon} )
            boundaryGroupCoords = obj.selectionsCoords(obj.BoundaryGroups());
        end
        function volumeGroupCoords = VolumeGroupCoords(obj)
            %Returns the coordinates of all volume groups (3D selections)
            %as cell array ( cell{idxGroup}{idxPolygon} )
            volumeGroupCoords = obj.selectionsCoords(obj.VolumeGroups());
        end
    end
    
    methods(Access = private)
        function coords = selectionsCoords(obj, selections)
            coords = cell(size(selections));
            for idxSelection = 1:numel(selections)
                coords{idxSelection} = obj.selectionCoords(selections{idxSelection});
            end
        end
        function coords = selectionCoords(obj, selectionNode)
            entityIDs = selectionNode.inputEntities();
            coords = cell(size(entityIDs));
            switch (selectionNode.dimension)
                case 0
                    entityType = 'point';
                case 1
                    entityType = 'edge';
                case 2
                    entityType = 'boundary';
                case 3
                    entityType = 'domain';
                otherwise
                    return;
            end
            for idxEntity = 1:numel(entityIDs)
                coords{idxEntity} = mphgetcoords(obj.modelNode, selectionNode.geom, entityType, entityIDs(idxEntity));
            end
        end
    end
    
    %% How to get IDs of objects belonging to a certain selection
    methods(Access = private, Static = true)
        function id = selectionEntities(selectionNode)
            id = selectionNode.inputEntities();
        end
    end
end