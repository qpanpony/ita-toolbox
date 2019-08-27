classdef itaComsolDataset < itaComsolNode
    %itaComsolDataset Interface to the result.dataset nodes of an itaComsolModel
    %   Allows to access the dataset nodes of the Comsol model. Also provides
    %   functions to filter datasets with a specific source (=solver or
    %   other dataset) and datasets of a specific type.
    %   
    %   See also itaComsolModel, itaComsolNode, itaComsolResult
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolDataset">doc itaComsolDataset</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    %% Constructor
    methods
        function obj = itaComsolDataset(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'dataset',...
                'com.comsol.clientapi.impl.ExportFeatureClient', comsolModel.modelNode.result)
        end
    end
    
    %% Filter datasets
    methods
        function datasets = Filter(obj, sourceDataTag, type)
            %Returns all dataset nodes matching the filter settings
            %   Inputs (default):
            %   sourceDataTag:      Tag of the source for this set (either solution or other dataset) 
            %   type (''):          Dataset type (e.g. dset, grid, ...)
            if nargin == 2; type = ''; end
            assert(isempty(sourceDataTag) || ( ischar(sourceDataTag) && isrow(sourceDataTag) ),...
                'Inputs must either be empty or a char row vector')
            assert(isempty(type) || ( ischar(type) && isrow(type) ),...
                'Inputs must either be empty or a char row vector')
            
            datasets = obj.All();
            if ~isempty(sourceDataTag)
                datasets = obj.filterSource(datasets, sourceDataTag);
            end
            if ~isempty(type)
                datasets = obj.filterType(datasets, type);
            end
        end
        function gridDatasets = Grids(obj, sourceDataTag)
            %Returns all grid dataset nodes. Alternatively, the tag of the
            %source data can be given as a filter.
            %   Inputs (default):
            %   sourceDataTag (''): Tag of the source for this set (either solution or other dataset) 
            gridDatasets = obj.Filter(sourceDataTag, 'grid');
        end
    end
    methods(Access = private, Static = true)
        function filteredDsets = filterType(datasets, type)
            filteredDsets = {};
            for idxDset = 1:numel(datasets)
                dset = datasets{idxDset};
                if contains(char(dset.tag), type)
                    filteredDsets{end+1} = dset; %#ok<AGROW>
                end
            end
        end
        function filteredDsets = filterSource(datasets, sourceDataTag)
            filteredDsets = {};
            for idxDset = 1:numel(datasets)
                dset = datasets{idxDset};
                if dset.hasProperty('data')
                    compareString = char(dset.getString('data'));
                elseif dset.hasProperty('solution')
                    compareString = char(dset.getString('solution'));
                else
                    continue;
                end
                
                if strcmp(compareString, sourceDataTag)
                    filteredDsets{end+1} = dset; %#ok<AGROW>
                end
            end
        end
    end
end