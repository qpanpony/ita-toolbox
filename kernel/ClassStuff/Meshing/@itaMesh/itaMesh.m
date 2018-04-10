classdef itaMesh

    %ITAMESH Represents a mesh used in simulations like FEM/BEM
    %   A mesh consists of a list of nodes (see itaMeshNodes) which form
    %   shell and/or volume elements (see itaMeshElements). Additionally,
    %   the nodes can be grouped using itaMeshGroup.
    %
    %   Supported element shapes are tetraheadron/triangle (tetra) and
    %   quadrilateral (quad) with linear or parabolic order.
    %   For more information see itaMeshElements.
    
    % <ITA-Toolbox>
    % This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
    % You can find the license for this m-file in the application folder. 
    % </ITA-Toolbox>
    
    %Author: mmt
    %Created: 2009?
    
    properties(Access = protected)
        mNodes = itaMeshNodes;
        mShellElements = itaMeshElements(0,'shell','tetra','linear');
        mVolumeElements = itaMeshElements(0,'volume','tetra','linear');
        mGroups = {};
    end
    
    properties(Dependent)
        nodes;              %The nodes of this mesh (see itaMeshNodes)
        shellElements;      %Elements that define the shell of this mesh (see itaMeshElements)
        volumeElements;     %Elements that define the volume of this mesh (see itaMeshElements)
        groups;             %Cell-array of groups used in the mesh(see itaMeshGroup)
        nNodes;             %Number of nodes in this mesh
        nElements;          %Total number of elements in this mesh
        nShellElements;     %Number of shell elements in this mesh
        nVolumeElements;    %Number of volume elements in this mesh
        nGroups;            %Number of groups in this mesh
    end
    
    methods
        function this = itaMesh(varargin)
            %There are four ways of using the constructor.
            %Valid inputs are:
            %1) single itaMesh (copy constructor)
            %2) a unv-filename
            %3) a struct with input properties (nodes/shellElements/volumeElements/groups)
            %4) itaMeshNodes, itaMeshElements, itaMeshGroup
            %   (e.g. itaMesh(nodes, elements, group1, group2,...)
            
            if nargin
                if isa(varargin{1},'itaMesh') % copy consructor
                    this = varargin{1};
                    
                elseif ischar(varargin{1})  % unv import
                    foundStuff = 0;
                    try
                        try %#ok<TRYNC>
                            this.mNodes = ita_readunv2411(varargin{1});
                            foundStuff = 1;
                        end
                        try %#ok<TRYNC>
                            tmp = ita_readunv2412(varargin{1});
                            if iscell(tmp)
                                for i = 1:numel(tmp)
                                    if isShell(tmp{i})
                                        this.mShellElements = tmp{i};
                                    elseif isVolume(tmp{i})
                                        this.mVolumeElements = tmp{i};
                                    end
                                end
                            else
                                if tmp.isShell
                                    this.mShellElements = tmp;
                                elseif tmp.isVolume
                                    this.mVolumeElements = tmp;
                                end
                            end
                            foundStuff = foundStuff + 1;
                        end
                        try %#ok<TRYNC>
                            tmp = ita_readunvgroups(varargin{1});
                            if ~iscell(tmp)
                                tmp = {tmp};
                            end
                            this.mGroups = tmp;
                            foundStuff = foundStuff + 1;
                        end
                        if ~foundStuff
                            error('itaMesh:file does not contain the correct DataSets');
                        end
                    catch %#ok<CTCH>
                        error('itaMesh:I cannot read the specified file');
                    end
                    
                elseif isstruct(varargin{1}) % Struct input/convert
                    fieldName = fieldnames(varargin{1});
                    for ind = 1:numel(fieldName)
                        try
                            this.(fieldName{ind}) = varargin{1}.(fieldName{ind});
                        catch errmsg
                            disp(errmsg);
                        end
                    end
                else
                    while ~isempty(varargin)
                        switch class(varargin{1})
                            case 'itaMeshNodes'
                                this.mNodes = varargin{1};
                            case 'itaMeshElements'
                                if isShell(varargin{1})
                                    this.mShellElements = varargin{1};
                                elseif isVolume(varargin{1})
                                    this.mVolumeElements = varargin{1};
                                end
                            case 'itaMeshGroup'
                                if isempty(this.mGroups) || this.mGroups.nNodes == 0
                                    this.mGroups = varargin(1);
                                else % add it to the other goups
                                    this.mGroups = [this.mGroups, varargin(1)];
                                end
                            otherwise
                                error('itaMesh:this object is not supported');
                        end
                        varargin(1) = [];
                    end
                end
            end
            
            if this.nShellElements == 0 && this.nVolumeElements > 0
                this.shellElements = this.makeShellElements;
            end
        end
        
        function display(this) %#ok<DISPLAY>
            %   DISPLAY(X) is called for the object X when the semicolon is not used
            %   to terminate a statement. [overloaded function]
            disp('==|itaMesh|============================================================');
            if this.nNodes > 0
                disp('   Nodes');
                disp(['      # Nodes                 = ' num2str(this.nNodes)]);
            end
            if this.nElements > 0
                disp('   Elements');
                if this.nShellElements > 0
                    disp(['      # Shell Elements        = ' num2str(this.nShellElements) '     [' this.mShellElements.order ' ' this.mShellElements.shape ']']);
                end
                if this.nVolumeElements > 0
                    disp(['      # Volume Elements       = ' num2str(this.nVolumeElements) '     [' this.mVolumeElements.order ' ' this.mVolumeElements.shape ']']);
                end
            end
            if this.nGroups > 0
                disp(['   Groups (' num2str(this.nGroups) ')']);
                for i = 1:numel(this.mGroups)
                    if max(this.mGroups{i}.nNodes,this.mGroups{i}.nElements) > 0
                        disp(['      Group ' num2str(i) ' (ID ' num2str(this.mGroups{i}.groupID) ')          = ' this.mGroups{i}.groupName ' (type: ' this.mGroups{i}.type ')']);
                    end
                end
            end
            disp('=======================================================================');
        end
        
        
        %% get/set stuff
        function this = set.nodes(this,value)
            if isa(value,'itaMeshNodes')
                this.mNodes = value;
            else
                error('itaMesh.set.nodes:wrong class type');
            end
        end
        
        function this = set.shellElements(this,value)
            if isa(value,'itaMeshElements')
                if isShell(value)
                    this.mShellElements = value;
                else
                    error('itaMesh.set.shellElements:wrong element type');
                end
            else
                error('itaMesh.set.shellElements:wrong class type');
            end
        end
        
        function this = set.volumeElements(this,value)
            if isa(value,'itaMeshElements')
                if isVolume(value)
                    this.mVolumeElements = value;
                else
                    error('itaMesh.set.volumeElements:wrong element type');
                end
            else
                error('itaMesh.set.volumeElements:wrong class type');
            end
        end
        
        function this = set.groups(this,value)
            if isempty(value) || isa(value,'itaMeshGroup')
                if isempty(this.mGroups)
                    this.mGroups = value;
                else
                    if ismember(value.groupID,this.getGroupIDs)
                        error('itaMesh.set.groups:group with this ID already exists');
                    else
                        this.mGroups = [this.mGroups, {value}];
                    end
                end
            else
                error('itaMesh.set.groups:wrong class type');
            end
        end
        
        function value = get.nodes(this), value = this.mNodes; end
        function value = get.shellElements(this), value = this.mShellElements; end
        function value = get.volumeElements(this), value = this.mVolumeElements; end
        function value = get.groups(this), value = this.mGroups; end
        
        function value = get.nNodes(this), value = this.nodes.nPoints; end
        function value = get.nShellElements(this), value = this.shellElements.nElements; end
        function value = get.nVolumeElements(this), value = this.volumeElements.nElements; end
        function value = get.nElements(this)
            value = this.nShellElements + this.nVolumeElements;
        end
        function value = get.nGroups(this), value = numel(this.groups); end
        
        %% node functions
        function nodes = nodeForID(this,ID)
            %Returns the itaMeshNodes with the given IDs
            if ~all(ismember(ID,this.nodes.ID))
                error('itaMesh.nodeForID:some (or all) of the IDs are not in the list');
            else
                idx = zeros(numel(ID),1);
                for i = 1:numel(ID)
                    idx(i) = find(this.nodes.ID == ID(i));
                end
                nodes = this.nodes.n(idx);
            end
        end
        
        function nodes = nodesForElement(this,element)
            %Returns the itaMeshNodes of the given itaMeshElements
            if nargin < 2 || ~isa(element,'itaMeshElements')
                error('itaMesh.nodesForElement:I need a meshElements object');
            end
            if element.nElements > 1
                elemNodeIDs = unique(element.nodes(:));
            else
                elemNodeIDs = element.nodes;
            end
            
            nodes = this.nodeForID(elemNodeIDs);
        end
        
        function nodes = nodesForGroup(this,group)
            %Returns the itaMeshNodes of the given itaMeshGroup
            if nargin < 2 || ~isa(group,'itaMeshGroup')
                error('itaMesh.nodesForGroup:I need a meshGroup object');
            end
            
            tmpID = group.ID;
            switch group.mType
                case 'nodes'
                    nodes = this.nodesForID(tmpID);
                case 'shell elements'
                    tmpElements = this.shellElementForID(tmpID);
                    nodes = this.nodesForElement(tmpElements);
                case 'volume elements'
                    tmpElements = this.volumeElementForID(tmpID);
                    nodes = this.nodesForElement(tmpElements);
                otherwise
                    error('itaMesh.nodesForGroup:unknown group type');
            end
        end
        
        %% element functions
        function elements = shellElementForID(this,ID)
            %Returns the shell elements (itaMeshElements) of the given IDs
            shellElementID  = this.mShellElements.ID;
            tmpShellID  = ID(ismember(ID,shellElementID));
            
            if isempty(tmpShellID)
                error('itaMesh.shellElementForID:some (or all) of the IDs are not in the list');
            else
                shellIdx  = zeros(numel(tmpShellID),1);
                for i = 1:numel(tmpShellID)
                    shellIdx(i) = find(this.mShellElements.ID == ID(i));
                end
                elements = this.mShellElements.n(shellIdx);
            end
        end
        
        
        function elements = volumeElementForID(this,ID)
            %Returns the volume elements (itaMeshElements) of the given IDs
            volumeElementID = this.mVolumeElements.ID;
            tmpVolumeID = ID(ismember(ID,volumeElementID));
            
            if isempty(tmpVolumeID)
                error('itaMesh.volumeElementForID:some (or all) of the IDs are not in the list');
            else
                volumeIdx = zeros(numel(tmpVolumeID),1);
                for i = 1:numel(tmpVolumeID)
                    volumeIdx(i) = find(this.mVolumeElements.ID == ID(i));
                end
                elements = this.mVolumeElements.n(volumeIdx);
            end
        end
        
        
        function elements = elementsForGroup(this,group)
            %Returns the itaMeshElements of the given itaMeshGroup
            if nargin < 2 || ~isa(group,'itaMeshGroup')
                error('itaMesh.elementsForGroup:I need a meshGroup object');
            elseif strcmpi(group.type,'nodes')
                error('itaMesh.elementsForGroup:group contains no elements');
            end
            
            switch group.type
                case 'shell elements'
                    tmpID = group.ID;
                    shellElementID  = this.mShellElements.ID;
                    tmpShellID  = tmpID(ismember(tmpID,shellElementID));
                    elements = this.shellElementForID(tmpShellID(:));
                case 'volume elements'
                    tmpID = group.ID;
                    volumeElementID = this.mVolumeElements.ID;
                    tmpVolumeID = tmpID(ismember(tmpID,volumeElementID));
                    elements = this.volumeElementForID(tmpVolumeID);
            end
        end
        
        %% group functions
        function value = getGroupIDs(this)
            %Returns the IDs of the groups of this mesh
            value = [];
            if ~isempty(this.mGroups)
                for i= 1:numel(this.mGroups)
                    value = [value, this.mGroups{i}.groupID]; %#ok<AGROW>
                end
            end
        end
        
        %% plot
        function h = plot(this,varargin)
            %See ita_plot_mesh
            if nargin < 2
                h = ita_plot_mesh(this);
            else
                h = ita_plot_mesh(this,varargin{:});
            end
        end
        
        %% Overloaded functions
        function sObj = saveobj(this)
            % Called whenever an object is saved
            % Store class name and class revision
            sObj.classname = class(this);
            sObj.classrevision = this.classrevision;
            
            % Copy all properties that were defined to be saved
            propertylist = itaMesh.propertiesSaved;
            
            for idx = 1:numel(propertylist)
                sObj.(propertylist{idx}) = this.(propertylist{idx});
            end
        end
    end
    
    methods(Static)
        function this = loadobj(sObj)
            % Called when an object is loaded
            sObj = rmfield(sObj,{'classrevision', 'classname'}); % Remove these fields cause no more needed, but we could use them for special case handling (e.g. old versions)
            this = itaMesh(sObj); % Just call constructor, he will take care
        end
        
        function revision = classrevision
            % Return last revision on which the class definition has been changed (will be set automatic by svn)
            rev_str = '$Revision: 2804 $'; % Please dont change this, will be set by svn
            revision = str2double(rev_str(isstrprop(rev_str,'digit')));
        end
        
        function result = propertiesSaved
            %Returns the names of the properties that are saved
            result = {'nodes','shellElements','volumeElements','groups'};
        end
    end
end