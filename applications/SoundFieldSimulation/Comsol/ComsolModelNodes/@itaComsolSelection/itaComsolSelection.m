classdef itaComsolSelection < itaComsolNode
    %itaComsolSelection Interface to the selection nodes of an itaComsolModel
    %   Can be used to quickly access all Comsol selection nodes of certain
    %   dimension (0D, 1D, ..., 3D). Furthermore, it allows to use filters
    %   to further specify which selections are to be returned (see
    %   itaComsolSelection.filters). Also allows to access a selection node
    %   using its name.
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolSelection">doc itaComsolSelection</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    %% Constructor
    methods
        function obj = itaComsolSelection(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'selection', 'com.comsol.clientapi.impl.SelectionFeatureClient')
        end
    end
    
    properties(Access = private, Constant = true)
        tagSuffix0D = '_pnt';
        tagSuffix1D = '_edg';
        tagSuffix2D = '_bnd';
        tagSuffix3D = '_dom';
        tagSuffixes = ...
            {itaComsolSelection.tagSuffix0D, itaComsolSelection.tagSuffix1D,...
            itaComsolSelection.tagSuffix2D, itaComsolSelection.tagSuffix3D};
    end
    
    properties(Constant = true)
        %Contains all valid options to filter selections:
        %'all' - no filtering, contains all selections
        %'user' - selections that are created by the user (explicit selection)
        %'comsol' - selections that are created by comsol using the "Resulting objects selection" option for geometry elements
        %'sources' - selections of geometry elements that were created using itaComsolSource
        %'noSources' - all selections except for selections of type 'sources'
        filters = {'all', 'user', 'comsol', 'sources', 'noSources'};
    end
    
    %% Get Selections of distinct dimension
    methods
        function pointSelections = PointSelections(obj, filter)
            %Returns all point selections (0D selections) as cell array
            %   Optionally, a filter can be applied. See filters property
            %   for more information.
            if nargin == 1; filter = 'all'; end
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            pointSelections = obj.selectionsOfDimension(0, filter);
        end
        function boundaryGroups = BoundaryGroups(obj, filter)
            %Returns all boundary groups (2D selections) as cell array
            %   Optionally, a filter can be applied. See filters property
            %   for more information.
            if nargin == 1; filter = 'all'; end
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            boundaryGroups = obj.selectionsOfDimension(2, filter);
        end
        function volumeGroups = VolumeGroups(obj, filter)
            %Returns all volume groups (3D selections) as cell array
            %   Optionally, a filter can be applied. See filters property
            %   for more information.
            if nargin == 1; filter = 'all'; end
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            volumeGroups = obj.selectionsOfDimension(3, filter);
        end
        
        function boundaryGroup = BoundaryGroup(obj, boundaryGroupName)
            %Returns a boundary group (2D selection) given its name.
            %Returns [] if group is not found.
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Input must be a char row vector')
            boundaryGroup = obj.selectionOfDimensionByName(boundaryGroupName, 2, 'all');
        end
        function volumeGroup = VolumeGroup(obj, volumeGroupName)
            %Returns a volume group (3D selection) given its name.
            %Returns [] if group is not found.
            assert(ischar(volumeGroupName) && isrow(volumeGroupName), 'Input must be a char row vector')
            volumeGroup = obj.selectionOfDimensionByName(volumeGroupName, 3, 'all');
        end
        
        function pointSelectionNames = PointSelectionNames(obj, filter)
            %Returns the names of all point selections (0D selections) as cell array
            %   Optionally, a filter can be applied. See filters property
            %   for more information.
            if nargin == 1; filter = 'all'; end
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            pointSelectionNames = obj.selectionNames(obj.PointSelections(filter));
        end
        function boundaryGroupNames = BoundaryGroupNames(obj, filter)
            %Returns the names of all boundary groups (2D selections) as cell array
            %   Optionally, a filter can be applied. See filters property
            %   for more information.
            if nargin == 1; filter = 'all'; end
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            boundaryGroupNames = obj.selectionNames(obj.BoundaryGroups(filter));
        end
        function boundaryGroupNames = VolumeGroupNames(obj, filter)
            %Returns the names of all volume groups (3D selections) as cell array
            %   Optionally, a filter can be applied. See filters property
            %   for more information.
            if nargin == 1; filter = 'all'; end
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            boundaryGroupNames = obj.selectionNames(obj.VolumeGroups(filter));
        end
    end
    methods(Access = private)
        function selections = selectionsOfDimension(obj, dimension, filter)
            selections = obj.All();
            if isempty(selections); return; end
            
            %Dimension
            removeSelections = false(size(selections));
            for idxSelection = 1:numel(selections)
                if ~isequal(selections{idxSelection}.dimension, dimension)
                    removeSelections(idxSelection) = true;
                end
            end
            selections(removeSelections) = [];
            
            %Filter
            selections = obj.filterSelections(selections, filter);
        end
        function out = selectionOfDimensionByName(obj, name, dimension, filter)
            selections = obj.selectionsOfDimension(dimension, filter);
            selectionNames = obj.selectionNames(selections);
            idxSel = strcmp(selectionNames, name);
            if sum(idxSel) ~= 1
                out = [];
            else
                out = selections{idxSel};
            end
        end
        function selNames = selectionNames(~, selections)
            selNames = cell(size(selections));
            for idxSelection = 1:numel(selections)
                selNames{idxSelection} = char( selections{idxSelection}.name );
            end
        end
    end
    
    %% Selection filtering
    methods(Access = private, Static = true)
        function selections = filterSelections(selections, filterType)
            [mustContainKeywords, mustNotContainKeywords] = itaComsolSelection.getFilterKeywords(filterType);
            selections = itaComsolSelection.selectionsContainingKeywords(selections, mustContainKeywords);
            selections = itaComsolSelection.selectionsNotContainingKeywords(selections, mustNotContainKeywords);
        end
        function [mustContainKeywords, mustNotContainKeywords] = getFilterKeywords(filterType)
            mustContainKeywords = {};
            mustNotContainKeywords = {};
            switch filterType
                case 'all'
                    return;
                case 'user'
                    mustNotContainKeywords = itaComsolSelection.tagSuffixes;
                case 'comsol'
                    mustContainKeywords = itaComsolSelection.tagSuffixes;
                case 'sources'
                    mustContainKeywords = itaComsolSource.geometryTagSuffixes;
                case 'noSources'
                    mustNotContainKeywords = itaComsolSource.geometryTagSuffixes;
                otherwise
                    error(['Invalid filter option. Valid options are: ' strjoin(itaComsolSelection.filters, ' , ') ])
            end
        end
        function selections = selectionsContainingKeywords(selections, keywords)
            selections = itaComsolSelection.filterByTags(selections, keywords, false);
        end
        function selections = selectionsNotContainingKeywords(selections, keywords)
            selections = itaComsolSelection.filterByTags(selections, keywords, true);
        end
        function selections = filterByTags(selections, keywords, removeSelectionsWithTags)
            if isempty(keywords); return; end
            removeSelections = false(size(selections));
            for idxSelection = 1:numel(selections)
                if contains(char(selections{idxSelection}.tag), keywords)
                    removeSelections(idxSelection) = true;
                end
            end
            if ~removeSelectionsWithTags; removeSelections = ~removeSelections; end
            selections(removeSelections) = [];
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