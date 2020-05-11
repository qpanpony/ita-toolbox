classdef itaAc3dVisualizer < itaAbstract3DModelVisualizer
    %itaAc3dVisualizer This class is used to visualize an itaAc3dModel.
    %   Parameters for the plot are defined using class properties.
    %   Adjusting these leads to a real-time update the plot (if
    %   autoRefresh is set to true).
    %   
    %   See also itaAc3dVisualizer, itaAc3dModel
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaAc3dVisualizer">doc itaAc3dVisualizer</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Hidden = true)
        axesMapping = [1 -3 2];  %Maps data from .ac3d file to fit to the plot (default is no transform)
    end
    
    %% Constructing / Model related
    methods
        function obj = itaAc3dVisualizer(input)
            %Expects a single input of one of the following options:
            %1) A .ac filename, pointing to a valid AC3D file
            %2) An AC3D object (see load_ac3d)
            obj.SetModel(input);
        end
        
        function SetModel(obj, input)
            %Model can be set using either:
            %1) An .ac filename, pointing to a valid AC3D file
            %2) An AC3D object (see load_ac3d)
            if ischar(input) && isrow(input)
                if ~contains(input, '.ac')
                    error('Given filename does not point to an AC3D file')
                end
                obj.mModel = itaAc3dModel(input);
            elseif isa(input, 'itaAc3dModel') && isscalar(input)
                obj.mModel = input;
            else
                error('Input must be either a valid .ac filename or an AC3D object (itaAc3dModel).')
            end
            
            obj.clearPlotItems();
            obj.mBoundaryGroupNames = obj.mModel.getMaterialNames;
            obj.mBoundaryGroupVisibility = true( 1, obj.numberOfBoundaryGroups() );
            
            if obj.autoRefresh && obj.axesSpecified()
                obj.RefreshPlot();
            end
        end
    end
    methods(Access = protected)
        function out = numberOfBoundaryGroups(this)
            out = numel(this.mModel.bcGroups);
        end
    end
    
    %% Plot Items
    methods(Access = protected)
        %-----------Create-------------------------------------------------
        
        function plotBoundaryGroups(this)
            invertAxes = sign(this.axesMapping);
            swapAxes = abs(this.axesMapping);
            
            boundaryGroups = this.mModel.bcGroups;
            modelNodes = this.mModel.nodes;
            this.mBoundaryPlotHandles = cell(1, numel(boundaryGroups));
            for groupID = 1:numel(boundaryGroups)
                groupPolygons = boundaryGroups{groupID}.polygons;
                this.mBoundaryPlotHandles{groupID} = gobjects(size(groupPolygons));
                for polyID = 1:length(groupPolygons)
                    this.mBoundaryPlotHandles{groupID}(polyID) = patch(this.mAxes,...
                        modelNodes(groupPolygons{polyID}(:,1),swapAxes(1)) * invertAxes(1), ...
                        modelNodes(groupPolygons{polyID}(:,1),swapAxes(2)) * invertAxes(2), ...
                        modelNodes(groupPolygons{polyID}(:,1),swapAxes(3)) * invertAxes(3), ...
                        boundaryGroups{groupID}.color, 'LineStyle', 'none');
                end
            end
        end
        function plotEdges(this)
            invertAxes = sign(this.axesMapping);
            swapAxes = abs(this.axesMapping);
            
            polygons = this.mModel.polygons;
            modelNodes = this.mModel.nodes;
            this.mEdgePlotHandles = gobjects(size(polygons));
            for polyID = 1:numel(polygons)
                polyNodes = polygons{polyID}(:,1);
                this.mEdgePlotHandles(polyID) = line(this.mAxes,...
                    modelNodes([polyNodes; polyNodes(1)],swapAxes(1)) * invertAxes(1), ...
                    modelNodes([polyNodes; polyNodes(1)],swapAxes(2)) * invertAxes(2), ...
                    modelNodes([polyNodes; polyNodes(1)],swapAxes(3)) * invertAxes(3));
            end
        end
    end
    
    %% Applying Plot Settings
    methods(Access = protected)
        function applyAllSettings(this)
            applyAllSettings@itaAbstract3DModelVisualizer(this);
        end
    end
end

