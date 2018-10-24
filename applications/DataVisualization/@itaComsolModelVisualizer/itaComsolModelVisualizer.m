classdef itaComsolModelVisualizer < Abstract3DModelVisualizer
    %itaComsolModelVisualizer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        mMeshPlotHandles;
        
        mShowMesh = false;
        mMeshColor = [0 0 0];
    end
    
    properties(Dependent = true)
        showMesh;               %Visibility for mesh
        meshColor;              %Color of the mesh lines
    end
    
    %% Constructing / Model related
    methods
        function obj = itaComsolModelVisualizer(comsolModel)
            %Expects a single input of one of the following options:
            %1) An .mph filename, pointing to a valid Comsol file
            %2) An itaComsolModel object
            obj.SetModel(comsolModel);
        end
        function SetModel(obj, input)
            %Sets the itaComsolModel object for the plot using either:
            %1) An .mph filename, pointing to a valid Comsol file
            %2) An itaComsolModel object
            if ischar(input) && isrow(input)
                if ~contains(input, '.mph')
                    error('Given filename does not point to a Comsol (.mph) file')
                end
                obj.mModel = itaComsolModel( mphload(input) );
            elseif isa(input, 'itaComsolModel') && isscalar(input)
                obj.mModel = input;
            else
                error('Input must be either a valid .mph filename or an itaComsolModel object.')
            end
            
            obj.clearPlotItems();
            obj.mBoundaryGroupVisibility = true( 1, obj.numberOfBoundaryGroups() );
            
            if obj.autoRefresh && obj.axesSpecified()
                obj.RefreshPlot();
            end
        end
    end
    methods(Access = protected)
        function out = numberOfBoundaryGroups(this)
            out = numel(this.mModel.selection.BoundaryGroups());
        end
    end
    
    %% Plot Settings
    %----------Get---------------------------------------------------------
    methods
        function out = get.showMesh(this)
            out = this.mShowMesh;
        end
        function out = get.meshColor(this)
            out = this.mMeshColor;
        end
    end
    
    %----------Set---------------------------------------------------------
    methods
        function set.showMesh(this, bool)
            assert( islogical(bool) && isscalar(bool), 'showMesh must be a single boolean')
            if this.mShowMesh == bool; return; end
            
            this.mShowMesh = bool;
            if this.autoRefresh
                this.applyMeshVisibility();
            end
        end
        function set.meshColor(this, color)
            assert( isnumeric(color) && isequal(size(color), [1 3]) && all(color >= 0) && all(color <= 1), 'meshColor must be a color vector')
            if isequal(this.meshColor, color); return; end
            
            this.mMeshColor = color;
            if this.autoRefresh
                this.applyMeshColor();
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
            
            hold(this.mAxes, 'on')
            if isempty(this.mBoundaryPlotHandles)
                this.plotBoundaryGroups();
            end
            if isempty(this.mMeshPlotHandles)
                this.plotMesh();
            end
            if isempty(this.mEdgePlotHandles)
                this.plotEdges();
            end
            
            this.applyAllSettings();
            axis(this.mAxes, 'off');
            axis(this.mAxes, 'equal');
        end
    end
    
    %% Plot Items
    methods(Access = protected)
        %-----------Create-------------------------------------------------
        
        function plotBoundaryGroups(this)
            
            boundaryGroups = this.mModel.selection.BoundaryGroups();
            this.mBoundaryPlotHandles = cell(1, numel(boundaryGroups));
            colors = get(groot,'DefaultAxesColorOrder');
            for groupID = 1:numel(boundaryGroups)
                mphviewselection(this.mModel.modelNode, char(boundaryGroups{groupID}.tag),...
                    'Parent', this.mAxes, 'geommode', 'off', ...
                    'facecolorselected', colors(mod(groupID-1, numel(colors))+1, :))
                
                this.mBoundaryPlotHandles{groupID} = this.mAxes.Children(1);
            end
            title(this.mAxes, '')
        end
        function plotEdges(this)
            mphgeom(this.mModel.modelNode, this.mModel.geometry.activeNode.tag, 'Parent', this.mAxes, 'facemode', 'off')
            this.mEdgePlotHandles = this.mAxes.Children(1);
            title(this.mAxes, '')
        end
        
        function plotMesh(this)
            mphmesh(this.mModel.modelNode, this.mModel.mesh.activeNode.tag, 'Parent', this.mAxes, 'edgemode', 'off')
            this.mMeshPlotHandles = this.mAxes.Children(1);
            delete(this.mAxes.Children(2));
            title(this.mAxes, '')
        end

        %-----------Remove-------------------------------------------------
        
        function resetPlotHandles(this)
            %Resets all handles to plot items
            resetPlotHandles@Abstract3DModelVisualizer(this);
            this.mMeshPlotHandles = [];
        end
        function clearPlotItems(this)
            %Clears all plot items and resets the variables which stored
            %them
            if ~isempty(this.mMeshPlotHandles) && isvalid(this.mMeshPlotHandles)
                delete(this.mMeshPlotHandles)
            end
            clearPlotItems@Abstract3DModelVisualizer(this);
        end
    end
    
    %% Applying Plot Settings
    methods(Access = protected)
        function applyAllSettings(this)
            applyAllSettings@Abstract3DModelVisualizer(this);
            this.applyMeshVisibility();
            this.applyMeshColor();
        end
    end
    
    methods(Access = private)
        function applyMeshVisibility(this)
            if ~isempty(this.mMeshPlotHandles) && isvalid(this.mMeshPlotHandles)
                this.mMeshPlotHandles.Visible = this.mShowMesh;
            end
        end
        function applyMeshColor(this)
            if ~isempty(this.mMeshPlotHandles) && isvalid(this.mMeshPlotHandles)
                this.mMeshPlotHandles.EdgeColor = this.mMeshColor;
            end
        end
    end
end

