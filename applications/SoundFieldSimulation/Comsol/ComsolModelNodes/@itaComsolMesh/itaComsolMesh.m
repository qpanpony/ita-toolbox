classdef itaComsolMesh < itaComsolNode
    %itaComsolMesh Interface to the mesh nodes of an itaComsolModel
    %   Can be used to access and adjust the size nodes of a mesh.
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolMesh">doc itaComsolMesh</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    %% Constructor
    methods
        function obj = itaComsolMesh(comsolModel)
            obj@itaComsolNode(comsolModel, 'mesh', 'com.comsol.clientapi.impl.MeshSequenceClient')
        end
    end
    
    properties(Constant = true)
        supportedSizeNodeProperties = {'hmax', 'hmin', 'hgrad', 'hcurve', 'hnarrow'};
    end
    
    %% Properties
    methods
        function nNodes = GetNumberOfNodes(obj)
            %Runs active mesh and returns number of nodes
            meshNode = obj.activeNode;
            assert(~isempty(meshNode), 'No mesh found.')
            
            meshNode.run();
            nNodes = meshNode.getNumVertex();
        end
        
        function coords = GetNodeCoordinates(obj)
            %Runs active mesh and returns coordinates of its nodes
            meshNode = obj.activeNode;
            assert(~isempty(meshNode), 'No mesh found.')
            
            meshNode.run();
            coords = itaCoordinates( meshNode.getVertex()' );
        end
    end
    
    %% Size Nodes
    methods
        function sizeNode = GetMainSizeNode(obj)
            %Returns the default size node of the active mesh node which
            %sits at the very top of the mesh sequence.
            sizeNode = [];
            meshNode = obj.activeNode;
            if ~isempty(meshNode) && obj.hasFeatureNode(meshNode, 'size')
                sizeNode = meshNode.feature('size');
            end
        end
        
        function sizeNode = CreateSize(obj, sizeTag, selectionTag)
            %Creates a size node for the active mesh node using a given
            %tag.
            %   Optionally, a selection tag can be provided to the
            %   function. Otherwise the whole active geometry is selected.
            assert(ischar(sizeTag) && isrow(sizeTag), 'sizeTag must be a char row vector')
            if nargin == 2
                selectionTag = '';
            end
            assert(ischar(selectionTag) && (isrow(selectionTag) || isempty(selectionTag)),...
                'selectionTag must be a char row vector');
            
            meshNode = obj.mActiveNode;
            if ~obj.hasFeatureNode(meshNode, sizeTag)
                meshNode.create(sizeTag, 'Size');
                meshNode.feature(sizeTag).label(sizeTag);
            end
            sizeNode = meshNode.feature(sizeTag);
            if ~isempty(selectionTag)
                sizeNode.selection.named(selectionTag);
            else
                sizeNode.selection.geom( char(obj.mModel.geometry.activeNode.tag) );
            end
        end
        
        function SetMinimumSizeProperties(obj, sizeNode, varargin)
            %For the given size node, this sets the minimum values between
            %the given parameters and the parameters of the default size node.
            %   Note, that minimum refers to properties that allow a finer
            %   mesh. For some properties this may actually be the higher
            %   value (e.g. "Resolution of narrow regions")
            %
            %   First input must be a size node. Further input must be
            %   pairs of property names and values.
            %   Example:
            %   SetSizeProperties(mySizeNode, 'hmax', 0.3, 'hmin', '0.3')
            
            assert(isa(sizeNode, 'com.comsol.clientapi.impl.MeshFeatureClient'), 'First input must be a mesh size node')
            assert(mod(numel(varargin), 2) == 0, 'There must be an even number of property names and values')
            assert(iscellstr(varargin(1:2:end)), 'Property names must be char row vectors')
            for idxProperty = 1:numel(varargin)/2
                propertyName = varargin{2*idxProperty-1};
                propertyValue = varargin{2*idxProperty};
                assert(any(strcmp(propertyName, obj.supportedSizeNodeProperties)),...
                    'A property name does not refer to a supported property. Supported properties:\n%s',...
                    strjoin(obj.supportedSizeNodeProperties, ' , '))
                assert( (ischar(propertyValue) && isrow(propertyValue)) ||...
                (isnumeric(propertyValue) && isscalar(propertyValue)),...
                'All property values must be either char row vectors or numeric scalars')
            end
            
            for idxProperty = 1:numel(varargin)/2
                propertyName = varargin{2*idxProperty-1};
                propertyValue = varargin{2*idxProperty};
                obj.setMinimumSizeProperty(sizeNode, propertyName, propertyValue);
            end
        end
    end
    methods(Access = private)
        function setMinimumSizeProperty(obj, sizeNode, propertyTag, propertyValue)
            %Worker function for SetMinimumSizeProperties()
            
            assert(isa(sizeNode, 'com.comsol.clientapi.impl.MeshFeatureClient'), 'Input must be a mesh size node')
            defaultSizeNode = obj.GetMainSizeNode;
            if sizeNode == defaultSizeNode; error('Given size node is the default size node.'); end
            if isnumeric(propertyValue); propertyValue = num2str(propertyValue); end
            
            if ~isempty(defaultSizeNode)
                if strcmp(propertyTag, 'hnarrow')
                    funcStr = 'max';
                else
                    funcStr = 'min';
                end
                defaultValue = char(defaultSizeNode.getString(propertyTag));
                propertyValue = [funcStr '(' propertyValue ', ' defaultValue ')'];
            end
            sizeNode.set(propertyTag, propertyValue);
        end
    end
    methods(Static = true)
        function SetSizeProperties(sizeNode, varargin)
            %Set the size properties for the given size node.
            %   First input must be a size node. Further input must be
            %   pairs of property names and values.
            %   Example:
            %   SetSizeProperties(mySizeNode, 'hmax', 0.3, 'hmin', '0.3')
            assert(isa(sizeNode, 'com.comsol.clientapi.impl.MeshFeatureClient'), 'First input must be a mesh size node')
            assert(mod(numel(varargin), 2) == 0, 'There must be an even number of property names and values')
            assert(iscellstr(varargin(1:2:end)), 'Property names must be char row vectors')
            
            for idxProp = 1:numel(varargin)/2
                propertyName = varargin{2*idxProp-1};
                propertyValue = varargin{2*idxProp};
                sizeNode.set(propertyName, propertyValue);
            end
        end
    end
end