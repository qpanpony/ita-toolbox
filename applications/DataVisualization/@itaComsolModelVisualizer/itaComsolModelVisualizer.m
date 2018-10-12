classdef itaComsolModelVisualizer < handle
    %itaComsolModelVisualizer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        mModel;         %Stores the itaComsolModel
        
        mBoundaryPlotHandles;   %Handles to patches of boundary surfaces ( mBoundaryPlotHandles{idxBoundaryGroup}(idxPolygon) )
        mWireframePlotHandles;  %Handles to line plots for the wireframe ( mWireframePlotHandles(idxPolygon) )
        
        mShowWireframe = true;
        mShowBoundarySurfaces = true;
        mShowMesh = false;
        
        mBoundaryGroupVisibility;
        mTransparency = 0.3;
        mWireframeColor = [.6 .6 .6];
    end
    
    properties(Dependent = true)
        showBoundarySurfaces;   %Visibility for all geometry boundary surfaces
        showWireframe;          %Visibility for wireframe
        showMesh;               %Visibility for mesh
        
        boundaryGroupVisibility;%Visibility for distinct boundary groups (logical vector)
        transparency;           %Transparency of boundary surfaces (0 <= t <= 1)
        wireframeColor;         %Color for wireframe ([r g b], 0 <= r <= 1)
    end
    
    %% Constructing / Loading model
    methods
        function obj = itaComsolModelVisualizer(comsolModel)
            %Expects a single input of type itaComsolModel
            obj.SetModel(comsolModel);
        end
        function SetModel(obj, comsolModel)
            %Sets the itaComsolModel object for the plot
            assert(isa(comsolModel, 'itaComsolModel'), 'Input must be a single itaComsolModel object')
            
            obj.clearPlotItems();
            obj.mBoundaryGroupVisibility = true(1, numel(obj.mModel.bcGroups));
            
            if obj.autoRefresh && obj.axesSpecified()
                obj.RefreshPlot();
            end
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
end

