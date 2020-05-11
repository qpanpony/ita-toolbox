classdef (Abstract)itaAbstract3DModelVisualizer < handle
    %itaAbstract3DModelVisualizer A base class for 3D visualization tools for
    %3D data
    %   Parameters for the plot are defined using class properties.
    %   Adjusting these leads to a real-time update the plot (if
    %   autoRefresh is set to true).
    %   
    %   See also itaAc3dVisualizer, itaComsolModelVisualizer
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaAbstract3DModelVisualizer">doc itaAbstract3DModelVisualizer</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = protected)
        mModel;                 %Stores the model which is to be visualized
        
        mAxes;                  %Handle to axes for plotting
        mBoundaryPlotHandles;   %Handles to patches of boundary surfaces ( mBoundaryPlotHandles{idxBoundaryGroup}(idxPolygon) )
        mEdgePlotHandles;       %Handles to line plots for the edges ( mEdgePlotHandles(idxPolygon) )
        
        mVisible = true;
        mShowEdges = true;
        mShowBoundarySurfaces = true;
        
        mBoundaryGroupNames;
        mBoundaryGroupVisibility;
        mTransparency = 0.3;
        mEdgeColor = [0 0 0];
    end
    
    properties
        autoRefresh = true;     %If set to true, the Plot will refresh automatically when changing plot settings
    end
    properties(Dependent = true)
        visible;                %Visibility of the whole model
        showBoundarySurfaces;   %Visibility for all boundary surfaces
        showEdges;              %Visibility for edges
        
        boundaryGroupVisibility;%Visibility for distinct boundary groups (logical vector)
        transparency;           %Transparency of boundary surfaces (0 <= t <= 1)
        edgeColor;              %Color for edges ([r g b], 0 <= r <= 1)
    end
    properties(Dependent = true, SetAccess = private)
        boundaryGroupNames;     %Names of boundary groups of current model
    end
    
    %% Model related
    methods(Abstract = true)
        SetModel(obj, input);
    end
    methods(Abstract = true, Access = protected)
        out = numberOfBoundaryGroups(this);
    end
    
    %% Axes / Plot Items
    methods
        function SetAxes(obj, ax)
            if ~isa(ax, 'matlab.graphics.axis.Axes') && ~ax.isvalid()
                error('Input must be a valid axes handle')
            end
            if obj.mAxes == ax; return; end
            
            obj.mAxes = ax;
            obj.resetPlotHandles();
        end
    end
    methods(Access = protected)
        function bool = axesSpecified(this)
            bool = ~isempty(this.mAxes) && this.mAxes.isvalid();
        end
    end
    
    %% Plot Settings
    %----------Get---------------------------------------------------------
    methods
        function out = get.visible(this)
            out = this.mVisible;
        end
        function out = get.showBoundarySurfaces(this)
            out = this.mShowBoundarySurfaces;
        end
        function out = get.showEdges(this)
            out = this.mShowEdges;
        end
        
        function out = get.boundaryGroupVisibility(this)
            out = this.mBoundaryGroupVisibility;
        end
        function out = get.transparency(this)
            out = this.mTransparency;
        end
        function out = get.edgeColor(this)
            out = this.mEdgeColor;
        end
        
        function out = get.boundaryGroupNames(this)
            out = this.mBoundaryGroupNames;
        end
    end
    
    %----------Set---------------------------------------------------------
    methods
        function set.autoRefresh(this, bool)
            assert( islogical(bool) && isscalar(bool), 'autoRefresh must be a single boolean')
            this.autoRefresh = bool;
        end
        function set.visible(this, bool)
            if isnumeric(bool); bool = logical(bool); end
            assert(islogical(bool) && isscalar(bool), 'visible must be a logical scalar')
            if this.mVisible == bool; return; end
            
            this.mVisible = bool;
            if this.autoRefresh
                this.applyVisibility();
            end
        end
        function set.showBoundarySurfaces(this, bool)
            assert( islogical(bool) && isscalar(bool), 'showBoundarySurfaces must be a single boolean')
            if this.mShowBoundarySurfaces == bool; return; end
            
            this.mShowBoundarySurfaces = bool;
            if this.autoRefresh
                this.applyBoundaryGroupVisibility();
            end
        end
        function set.showEdges(this, bool)
            assert( islogical(bool) && isscalar(bool), 'showEdges must be a single boolean')
            if this.mShowEdges == bool; return; end
            
            this.mShowEdges = bool;
            if this.autoRefresh
                this.applyEdgeVisibility();
            end
        end
        
        function set.boundaryGroupVisibility(this, visible)
            if isnumeric(visible); visible = logical(visible); end
            assert( islogical(visible) && numel(visible) == this.numberOfBoundaryGroups(), 'boundaryGroupVisibility must be a logical vector with one entry per boundary' )
            if isequal(visible, this.mBoundaryGroupVisibility); return; end
            
            this.mBoundaryGroupVisibility = visible;
            if this.autoRefresh
                this.applyBoundaryGroupVisibility();
            end
        end
        function set.transparency(this, transparency)
            assert( isnumeric(transparency) && isscalar(transparency) && transparency >= 0 && transparency <= 1, 'transparency must be a single numeric value between 0 and 1')
            if this.transparency == transparency; return; end
            
            this.mTransparency = transparency;
            if this.autoRefresh
                this.applyPlotTransparency()
            end
        end
        function set.edgeColor(this, color)
            assert( isnumeric(color) && isequal(size(color), [1 3]) && all(color >= 0) && all(color <= 1), 'edgeColor must be a color vector')
            if isequal(this.mEdgeColor, color); return; end
            
            this.mEdgeColor = color;
            if this.autoRefresh
                this.applyEdgeColor();
            end
        end
    end
    
    %% Plotting
    %-----------Public Access----------------------------------------------
    methods
        function varargout = Plot(this, ax)
            %Creates a new plot in the given axes. If no axes are given, a
            %new figure will be created
            if nargin == 1
                f = figure;
                ax = axes(f);
            end
            this.SetAxes(ax);
            this.RefreshPlot();
            if nargout
                varargout{1} = ax;
            end
        end
        
        function RefreshPlot(this, forceReplot)
            %Re-applies all plot settings. Replots everything if necessary.
            %   Optionally, replotting can be forced by handing a boolean
            %   that is set to true to this function.
            if ~this.axesSpecified()
                error('No valid axes are specified yet')
            end
            
            if nargin == 1; forceReplot = false; end
            if forceReplot; this.clearPlotItems(); end
            
            hold(this.mAxes, 'on')
            if isempty(this.mBoundaryPlotHandles)
                this.plotBoundaryGroups();
            end
            if isempty(this.mEdgePlotHandles)
                this.plotEdges();
            end
            
            this.applyAllSettings();
            axis(this.mAxes, 'off');
            axis(this.mAxes, 'equal');
        end
        
        function ClearPlot(this)
            %Clears all plot items
            this.clearPlotItems();
        end
    end
    
    
    %% Plot Items
    methods(Access = protected, Abstract = true)
        %-----------Create-------------------------------------------------
        
        plotBoundaryGroups(this)
        plotEdges(this)
    end
    methods(Access = protected)
        %-----------Remove-------------------------------------------------
        
        function resetPlotHandles(this)
            %Resets all handles to plot items
            this.mBoundaryPlotHandles = [];
            this.mEdgePlotHandles = [];
        end
        function clearPlotItems(this)
            %Clears all plot items and resets the variables which stored
            %them
            for idxBoundary = 1:numel(this.mBoundaryPlotHandles)
                for idxPolygon = 1:numel(this.mBoundaryPlotHandles{idxBoundary})
                    if isvalid( this.mBoundaryPlotHandles{idxBoundary}(idxPolygon) )
                        delete( this.mBoundaryPlotHandles{idxBoundary}(idxPolygon) );
                    end
                end
            end
            for idxLine = 1:numel(this.mEdgePlotHandles)
                if isvalid( this.mEdgePlotHandles(idxLine) )
                    delete( this.mEdgePlotHandles(idxLine) );
                end
            end
            this.resetPlotHandles();
        end
    end
    
    %% Applying Plot Settings
    methods(Access = protected)
        function applyAllSettings(this)
            this.applyVisibility();
            this.applyPlotTransparency();
            this.applyEdgeColor();
        end
        
        function applyVisibility(this)
            this.applyBoundaryGroupVisibility();
            this.applyEdgeVisibility();
        end
        
        %-------Boundary Surfaces------------------------------------------
        function applyBoundaryGroupVisibility(this)
            if isempty(this.mBoundaryPlotHandles); return; end
            if numel(this.mBoundaryPlotHandles) ~= numel(this.mBoundaryGroupVisibility)
                warning('Number of boundaries does not match boundary visibility settings')
                return
            end
            for idxBoundary = 1:numel(this.mBoundaryPlotHandles)
                visibleStr = this.getOnOffSwitchString(...
                    this.mVisible && this.mShowBoundarySurfaces &&...
                    this.mBoundaryGroupVisibility(idxBoundary));
                for idxPolygon = 1:numel(this.mBoundaryPlotHandles{idxBoundary})
                    if isvalid(this.mBoundaryPlotHandles{idxBoundary}(idxPolygon))
                        set(this.mBoundaryPlotHandles{idxBoundary}(idxPolygon), 'Visible',visibleStr)
                    end
                end
            end
        end
        
        function applyPlotTransparency(this)
            for idxBoundary = 1:numel(this.mBoundaryPlotHandles)
                for idxPolygon = 1:numel(this.mBoundaryPlotHandles{idxBoundary})
                    if isvalid(this.mBoundaryPlotHandles{idxBoundary}(idxPolygon))
                        set(this.mBoundaryPlotHandles{idxBoundary}(idxPolygon), 'FaceAlpha', this.transparency)
                    end
                end
            end
        end
        
        %-------Edges------------------------------------------------------
        function applyEdgeVisibility(this)
            visibleStr = this.getOnOffSwitchString(this.mVisible && this.mShowEdges);
            for idxLine = 1:numel(this.mEdgePlotHandles)
                if isvalid( this.mEdgePlotHandles(idxLine) )
                    set(this.mEdgePlotHandles(idxLine),'Visible', visibleStr);
                end
            end
        end
        function applyEdgeColor(this)
            for idxLine = 1:numel(this.mEdgePlotHandles)
                if isvalid( this.mEdgePlotHandles(idxLine) )
                    if isprop( this.mEdgePlotHandles(idxLine), 'EdgeColor')
                        set(this.mEdgePlotHandles(idxLine),'EdgeColor', this.mEdgeColor);
                    elseif isprop( this.mEdgePlotHandles(idxLine), 'Color')
                        set(this.mEdgePlotHandles(idxLine),'Color', this.mEdgeColor);
                    end
                end
            end
        end
    end
    
    %% Helper
    methods(Access = protected, Static = true)
        function switchStr = getOnOffSwitchString(boolean)
            if boolean
                switchStr = 'on';
            else
                switchStr = 'off';
            end
        end
    end
end

