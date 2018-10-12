classdef (Abstract)Abstract3DModelVisualizer < handle
    %Abstract3DModelVisualizer A base class for 3D visualization tools for
    %3D data
    %   Parameters for the plot are defined using class properties.
    %   Adjusting these leads to a real-time update the plot (if
    %   autoRefresh is set to true).
    
    properties(Access = protected)
        mModel;                 %Stores the AC3D model
        
        mAxes;                  %Handle to axes for plotting
        mBoundaryPlotHandles;   %Handles to patches of boundary surfaces ( mBoundaryPlotHandles{idxBoundaryGroup}(idxPolygon) )
        mWireframePlotHandles;  %Handles to line plots for the wireframe ( mWireframePlotHandles(idxPolygon) )
        
        mShowWireframe = true;
        mShowBoundarySurfaces = true;
        
        mBoundaryGroupVisibility;
        mTransparency = 0.3;
        mWireframeColor = [.6 .6 .6];
    end
    properties(Hidden = true)
        axesMapping = [1 1 1];  %Maps data from .ac3d file to fit to the plot (default is OpenGL to Matlab)
    end
    
    properties
        autoRefresh = true;     %If set to true, the Plot will refresh automatically when changing plot settings
    end
    properties(Dependent = true)
        showBoundarySurfaces;   %Visibility for all boundary surfaces
        showWireframe;          %Visibility for wireframe
        
        boundaryGroupVisibility;%Visibility for distinct boundary groups (logical vector)
        transparency;           %Transparency of boundary surfaces (0 <= t <= 1)
        wireframeColor;         %Color for wireframe ([r g b], 0 <= r <= 1)
    end
    
    %% Loading model
    methods(Abstract = true)
        SetModel(obj, input);
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
        function out = get.showBoundarySurfaces(this)
            out = this.mShowBoundarySurfaces;
        end
        function out = get.showWireframe(this)
            out = this.mShowWireframe;
        end
        
        function out = get.boundaryGroupVisibility(this)
            out = this.mBoundaryGroupVisibility;
        end
        function out = get.transparency(this)
            out = this.mTransparency;
        end
        function out = get.wireframeColor(this)
            out = this.mWireframeColor;
        end
    end
    
    %----------Set---------------------------------------------------------
    methods
        function set.autoRefresh(this, bool)
            assert( islogical(bool) && isscalar(bool), 'autoRefresh must be a single boolean')
            this.autoRefresh = bool;
        end
        function set.showBoundarySurfaces(this, bool)
            assert( islogical(bool) && isscalar(bool), 'showBoundarySurfaces must be a single boolean')
            if this.mShowBoundarySurfaces == bool; return; end
            
            this.mShowBoundarySurfaces = bool;
            if this.autoRefresh
                this.applyBoundaryGroupVisibility();
            end
        end
        function set.showWireframe(this, bool)
            assert( islogical(bool) && isscalar(bool), 'showWireframe must be a single boolean')
            if this.mShowWireframe == bool; return; end
            
            this.mShowWireframe = bool;
            if this.autoRefresh
                this.applyWireframeVisibility();
            end
        end
        
        function set.boundaryGroupVisibility(this, visible)
            if isnumeric(visible); visible = logical(visible); end
            assert( islogical(visible) && numel(visible) == numel(this.mModel.bcGroups), 'boundaryGroupVisibility must be a logical vector with one entry per boundary' )
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
        function set.wireframeColor(this, color)
            assert( isnumeric(color) && isequal(size(color), [1 3]) && all(color >= 0) && all(color <= 1), 'wireframeColor must be a color vector')
            if isequal(this.mWireframeColor, color); return; end
            
            this.mWireframeColor = color;
            if this.autoRefresh
                this.applyWireframeColor();
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
    methods(Access = protected, Abstract = true)
        %-----------Create-------------------------------------------------
        
        plotBoundaryGroups(this)
        plotWireframe(this)
    end
    methods(Access = protected)
        %-----------Remove-------------------------------------------------
        
        function resetPlotHandles(this)
            %Resets all handles to plot items
            this.mBoundaryPlotHandles = [];
            this.mWireframePlotHandles = [];
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
            for idxLine = 1:numel(this.mWireframePlotHandles)
                if isvalid( this.mWireframePlotHandles(idxLine) )
                    delete( this.mWireframePlotHandles(idxLine) );
                end
            end
            this.resetPlotHandles();
        end
    end
    
    %% Applying Plot Settings
    methods(Access = protected)
        function applyAllSettings(this)
            this.applyBoundaryGroupVisibility();
            this.applyPlotTransparency();
            this.applyWireframeVisibility();
            this.applyWireframeColor();
        end
        
        %-------Boundary Surfaces------------------------------------------
        function applyBoundaryGroupVisibility(this)
            if isempty(this.mBoundaryPlotHandles); return; end
            if numel(this.mBoundaryPlotHandles) ~= numel(this.mBoundaryGroupVisibility)
                warning('Number of boundaries does not match boundary visibility settings')
                return
            end
            for idxBoundary = 1:numel(this.mBoundaryPlotHandles)
                for idxPolygon = 1:numel(this.mBoundaryPlotHandles{idxBoundary})
                    if isvalid(this.mBoundaryPlotHandles{idxBoundary}(idxPolygon))
                        set(this.mBoundaryPlotHandles{idxBoundary}(idxPolygon), 'Visible',...
                            this.mBoundaryGroupVisibility(idxBoundary) & this.mShowBoundarySurfaces)
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
        
        %-------Wireframe--------------------------------------------------
        function applyWireframeVisibility(this)
            for idxLine = 1:numel(this.mWireframePlotHandles)
                if isvalid( this.mWireframePlotHandles(idxLine) )
                    set(this.mWireframePlotHandles(idxLine),'Visible', this.mShowWireframe);
                end
            end
        end
        function applyWireframeColor(this)
            for idxLine = 1:numel(this.mWireframePlotHandles)
                if isvalid( this.mWireframePlotHandles(idxLine) )
                    set(this.mWireframePlotHandles(idxLine),'Color', this.mWireframeColor);
                end
            end
        end
    end
end

