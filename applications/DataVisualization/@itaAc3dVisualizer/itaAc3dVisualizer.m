classdef itaAc3dVisualizer < Abstract3DModelVisualizer
    %itaAc3dVisualizer This class is used to visualize an AC3D model.
    %   Parameters for the plot are defined using class properties.
    %   Adjusting these leads to a real-time update the plot (if
    %   autoRefresh is set to true).
    
    
    %% Constructing / Loading model
    methods
        function obj = itaAc3dVisualizer(input)
            %Expects a single input of one of the following options:
            %1) A .ac filename, pointing to a valid AC3D file
            %2) An AC3D object (see load_ac3d)
            obj.SetModel(input);
            obj.axesMapping = [1 -3 2];
        end
        
        function SetModel(obj, input)
            %Model can be set using either:
            %1) A .ac filename, pointing to a valid AC3D file
            %2) An AC3D object (see load_ac3d)
            if ischar(input) && isrow(input)
                if ~contains(input, '.ac')
                    error('Given filename does not point to an AC3D file')
                end
                obj.mModel = load_ac3d(input);
            elseif isa(input, 'load_ac3d') && isscalar(input)
                obj.mModel = input;
            else
                error('Input must be either a valid .ac filename, a AC3D object (load_ac3d) or a Waga Project.')
            end
            
            obj.clearPlotItems();
            obj.mBoundaryGroupVisibility = true(1, numel(obj.mModel.bcGroups));
            
            if obj.autoRefresh && obj.axesSpecified()
                obj.RefreshPlot();
            end
        end
    end
    
    %% Plotting
    %-----------Public Access----------------------------------------------
    methods    
        function RefreshPlot(this, forceReplot)
            %Re-applies all plot settings. Replots everything if necessary.
            %   Optionally, replotting can be forced by handing a boolean
            %   that is set to true to this function.
            if ~this.axesSpecified()
                error('No valid axes are specified yet')
            end
            
            if nargin == 1; forceReplot = false; end
            if forceReplot; this.clearPlotItems(); end
            
            if isempty(this.mBoundaryPlotHandles)
                this.plotWireframe();
            end
            if isempty(this.mBoundaryPlotHandles)
                this.plotBoundaryGroups();
            end
            
            this.applyAllSettings();
            axis(this.mAxes, 'off');
            axis(this.mAxes, 'equal');
        end
    end
    
    
    %% Plot Items
    methods(Access = private)
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
                        boundaryGroups{groupID}.color);
                end
            end
        end
        function plotWireframe(this)
            invertAxes = sign(this.axesMapping);
            swapAxes = abs(this.axesMapping);
            
            polygons = this.mModel.polygons;
            modelNodes = this.mModel.nodes;
            this.mWireframePlotHandles = gobjects(size(polygons));
            for polyID = 1:numel(polygons)
                polyNodes = polygons{polyID}(:,1);
                this.mWireframePlotHandles(polyID) = line(this.mAxes,...
                    modelNodes([polyNodes; polyNodes(1)],swapAxes(1)) * invertAxes(1), ...
                    modelNodes([polyNodes; polyNodes(1)],swapAxes(2)) * invertAxes(2), ...
                    modelNodes([polyNodes; polyNodes(1)],swapAxes(3)) * invertAxes(3));
            end
        end
    end
    
    %% Applying Plot Settings
    methods(Access = private)
        function applyAllSettings(this)
            this.applyBoundaryGroupVisibility();
            this.applyPlotTransparency();
            this.applyWireframeVisibility();
            this.applyWireframeColor();
        end
    end
end

