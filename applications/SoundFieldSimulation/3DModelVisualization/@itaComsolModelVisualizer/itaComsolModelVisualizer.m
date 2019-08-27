classdef itaComsolModelVisualizer < itaAbstract3DModelVisualizer
    %itaComsolModelVisualizer This class is used to visualize an itaComsolModel.
    %   Parameters for the plot are defined using class properties.
    %   Adjusting these leads to a real-time update the plot (if
    %   autoRefresh is set to true).
    %
    %   
    %   See also itaAc3dVisualizer, itaComsolModel, itaComsolServer
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolModelVisualizer">doc itaComsolModelVisualizer</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mMeshPlotHandles;
        
        mShowMesh = false;
        mMeshColor = [0 0 0];
        
        mBoundaryGroupFilter = 'all';
    end
    
    properties(Dependent = true)
        showMesh;               %Visibility for mesh
        meshColor;              %Color of the mesh lines
    end
    
    properties(Dependent = true, Hidden = true)
        boundaryGroupFilter;    %Used to filter boundary groups. See itaComsolSelection.filters for more information
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
                itaComsolServer.Instance().Connect();
                modelTag = 'ModelForComsolVisualizer'; %TODO: Is it possible to have a unique name here?
                obj.mModel = itaComsolModel( mphload(input), modelTag );
            elseif isa(input, 'itaComsolModel') && isscalar(input)
                obj.mModel = input;
            else
                error('Input must be either a valid .mph filename or an itaComsolModel object.')
            end
            
            obj.clearPlotItems();
            obj.mBoundaryGroupNames = obj.mModel.selection.BoundaryGroupNames(obj.mBoundaryGroupFilter);
            obj.mBoundaryGroupVisibility = true( 1, obj.numberOfBoundaryGroups() );
            
            if obj.autoRefresh && obj.axesSpecified()
                obj.RefreshPlot();
            end
        end
    end
    methods(Access = protected)
        function out = numberOfBoundaryGroups(this)
            out = numel(this.mModel.selection.BoundaryGroups(this.mBoundaryGroupFilter));
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
        function out = get.boundaryGroupFilter(this)
            out = this.mBoundaryGroupFilter;
        end
    end
    
    %----------Set---------------------------------------------------------
    methods
        function set.showMesh(this, bool)
            assert( islogical(bool) && isscalar(bool), 'showMesh must be a single boolean')
            if this.mShowMesh == bool; return; end
            
            this.mShowMesh = bool;
            if this.autoRefresh
                if this.mShowMesh
                    this.plotMesh();
                    this.applyMeshColor();
                end
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
        function set.boundaryGroupFilter(this, filter)
            assert(ischar(filter) && isrow(filter), 'Input must be a char row vector')
            assert( any( strcmpi(itaComsolSelection.filters(:), filter) ), ...
                'Invalid filter option. Valid options are:\n%s', strjoin(itaComsolSelection.filters, ' , '))
            if isequal(this.mBoundaryGroupFilter, filter); return; end
            
            this.mBoundaryGroupFilter = filter;
            if this.autoRefresh && this.axesSpecified()
                this.RefreshPlot(true);
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
            if isempty(this.mMeshPlotHandles) && this.mShowMesh
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
            if ~isempty(this.mModel.geometry.activeNode)
                this.mModel.geometry.activeNode.run;
            end
            [az, el] = view(this.mAxes); %NOTE: Comsol plot functions overwrite view, so we have to restore it later
            
            boundaryGroups = this.mModel.selection.BoundaryGroups(this.mBoundaryGroupFilter);
            this.mBoundaryPlotHandles = cell(1, numel(boundaryGroups));
            colors = get(groot,'DefaultAxesColorOrder');
            for groupID = 1:numel(boundaryGroups)
                idxColor = mod(groupID-1, size(colors, 1))+1;
                mphviewselection(this.mModel.modelNode, char(boundaryGroups{groupID}.tag),...
                    'Parent', this.mAxes, 'geommode', 'off', 'edgemode', 'off',...
                    'facecolorselected', colors(idxColor, :))
                
                this.mBoundaryPlotHandles{groupID} = this.mAxes.Children(1);
            end
            
            title(this.mAxes, '')
            view(az, el);
        end
        function plotEdges(this)
            [az, el] = view(this.mAxes); %NOTE: Comsol plot functions overwrite view, so we have to restore it later
            
            mphgeom(this.mModel.modelNode, this.mModel.geometry.activeNode.tag, 'Parent', this.mAxes, 'facemode', 'off')
            this.mEdgePlotHandles = this.mAxes.Children(1);
            
            title(this.mAxes, '')
            view(az, el);
        end
        
        function plotMesh(this)
            if isempty(this.mModel.mesh.activeNode); return; end
            [az, el] = view(this.mAxes); %NOTE: Comsol plot functions overwrite view, so we have to restore it later
            
            %NOTE: An error during building the mesh can occur, if
            %including a dummy head geometry while the mesh size is to big.
            %Setting mesh size to "finer" or smaller should fix this.
            try
                this.mModel.mesh.activeNode.run;
                mphmesh(this.mModel.modelNode, this.mModel.mesh.activeNode.tag, 'Parent', this.mAxes, 'edgemode', 'off')
                this.mMeshPlotHandles = this.mAxes.Children(1);
                delete(this.mAxes.Children(2));
            catch err
                warning(err.identifier, 'Error during Comsol mesh building:\n%s', err.message) %TODO: Display the warning somehow?
            end
            
            title(this.mAxes, '')
            view(az, el);
        end

        %-----------Remove-------------------------------------------------
        
        function resetPlotHandles(this)
            %Resets all handles to plot items
            resetPlotHandles@itaAbstract3DModelVisualizer(this);
            this.mMeshPlotHandles = [];
        end
        function clearPlotItems(this)
            %Clears all plot items and resets the variables which stored
            %them
            if ~isempty(this.mMeshPlotHandles) && isvalid(this.mMeshPlotHandles)
                delete(this.mMeshPlotHandles)
            end
            clearPlotItems@itaAbstract3DModelVisualizer(this);
        end
    end
    
    %% Applying Plot Settings
    methods(Access = protected)
        function applyAllSettings(this)
            applyAllSettings@itaAbstract3DModelVisualizer(this);
            this.applyMeshColor();
        end
        
        function applyVisibility(this)
            applyVisibility@itaAbstract3DModelVisualizer(this);
            this.applyMeshVisibility();
        end
    end
    
    methods(Access = private)
        function applyMeshVisibility(this)
            visibleStr = this.getOnOffSwitchString(this.mVisible && this.mShowMesh);
            if ~isempty(this.mMeshPlotHandles) && isvalid(this.mMeshPlotHandles)
                set(this.mMeshPlotHandles, 'Visible', visibleStr);
            end
        end
        function applyMeshColor(this)
            if ~isempty(this.mMeshPlotHandles) && isvalid(this.mMeshPlotHandles)
                set(this.mMeshPlotHandles, 'EdgeColor', this.mMeshColor);
            end
        end
    end
end

