classdef itaComsolModel < handle
    %itaComsolModel Interface to adjust work with comsol model
    %   This class takes an existing comsol model and provides interfaces
    %   to adjust certain parameters such as boundary conditions
    %   (impedances) and sources. Also provides the function to run a
    %   simulation and gather results in ita-formats.
    %
    %   Note, that it is crucial to define the basis of the comsol model in
    %   Comsol itself. This includes:
    %   -Geometry
    %   -Materials
    %   -Physics
    %       -especially, impedances at boundaries
    %   -Mesh
    %   -Study
    %
    %   This class is able to create/adjust:
    %   -Global Definitions
    %       -Interpolations
    %   -Geometry
    %       -for sources (points / boundary surfaces)
    %
    %   This class is able to adjust:
    %   -Materials
    %       -...(to be added in future)
    %   -Physics
    %       -frequency dependent values for boundary impedances
    %       -frequency dependent source parameters (velocity / pressure)
    %   -Mesh
    %       -... ()
    %   -Study
    %       -frequency vector
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mModel;         %Comsol model node (com.comsol.clientapi.impl.ModelClient)
        
        mSelectionNode;
        mFunctionNode;
        mGeometryNode;
        mPhysicsNode;
        mStudyNode;
        mResultNode;
    end
    properties(Dependent = true, SetAccess = private)
        modelNode;      %The comsol model node
        
        selection;      %Interface to access Comsol selections (itaComsolSelection)
        func;           %Interface to access Comsol functions (itaComsolFunction)
        geometry;       %Interface to access Comsol geometry sequences (itaComsolGeometry)
        physics;        %Interface to access Comsol physics sequences (itaComsolPhysics)
        study;          %Interface to access Comsol study clients (itaComsolStudy)
        result;         %Interface to evaluate results (itaComsolResult)
    end
    
    methods
        function out = get.modelNode(obj)
            out = obj.mModel;
        end

        function out = get.selection(obj)
            out = obj.mSelectionNode;
        end
        function out = get.func(obj)
            out = obj.mFunctionNode;
        end
        function out = get.geometry(obj)
            out = obj.mGeometryNode;
        end
        function out = get.physics(obj)
            out = obj.mPhysicsNode;
        end
        function out = get.study(obj)
            out = obj.mStudyNode;
        end
        
        function out = get.result(obj)
            out = obj.mResultNode;
        end
    end
    
    
    %% Constructor
    methods
        function obj = itaComsolModel(comsolModel)
            if ~isa(comsolModel, 'com.comsol.clientapi.impl.ModelClient')
                error('Input must be a comsol model (com.comsol.clientapi.impl.ModelClient)')
            end
            obj.mModel = comsolModel;
            obj.mSelectionNode = itaComsolSelection(obj);
            obj.mFunctionNode = itaComsolFunction(obj);
            obj.mGeometryNode = itaComsolGeometry(obj);
            obj.mPhysicsNode = itaComsolPhysics(obj);
            obj.mStudyNode = itaComsolStudy(obj);
            obj.mResultNode = itaComsolResult(obj);
            
            assert(~isempty(obj.mGeometryNode.activeNode), 'No Comsol geometry node found')
            assert(~isempty(obj.mPhysicsNode.activeNode), 'No Comsol physics node found')
            assert(~isempty(obj.mModel.mesh.tags), 'No Comsol mesh node found')
            assert(~isempty(obj.mStudyNode.activeNode), 'No Comsol study node found')
        end
    end
    
    %% Materials
    methods
        function materials = Material(obj)
            %Returns all material nodes as cell array
            materials = obj.getRootElementChildren('material');
        end
    end
    
    %% Mesh
    methods
        function meshes = Mesh(obj)
            %Returns all mesh nodes as cell array
            meshes = obj.getRootElementChildren('mesh');
        end
        function mesh = FirstMesh(obj)
            %Returns the first mesh node
            mesh = obj.getFirstRootElementChild('mesh');
        end
    end
    
    %% -----------Helper Function Section------------------------------- %%
    %% Root node functions
    methods(Access = private)
        function nodes = getRootElementChildren(obj, rootName)
            tags = obj.getChildNodeTags(obj.mModel.(rootName));
            nodes = cell(1, numel(tags));
            for idxNode = 1:numel(tags)
                nodes{idxNode} = obj.mModel.(rootName)(tags(idxNode));
            end
        end
        function node = getFirstRootElementChild(obj, rootName)
            node = [];
            tags = obj.getChildNodeTags(obj.mModel.(rootName));
            if isempty(tags); return; end
            node = obj.mModel.(rootName)(tags(1));
        end
    end
    
    %% Functions applying directly to model nodes
    methods(Access = private, Static = true)
        function out = getChildNodeTags(comsolNode)
            
            itaComsolModel.checkInputForComsolNode(comsolNode);
            
            if ismethod( comsolNode, 'tags' )
                out = comsolNode.tags();
            elseif ismethod( comsolNode, 'objectNames' )
                out = comsolNode.objectNames();
            elseif ismethod( comsolNode, 'feature' )
                out = itaComsolModel.getChildNodeTags( comsolNode.feature() );
            else
                error(['Comsol Node of type "' class(comsolNode) '" does not seem to have a function to return children'])
            end
        end
    end
    
    %% Check input
    methods(Access = private, Static = true)
        function checkInputForComsolNode(input)
            if ~contains(class(input), 'com.comsol') || ~contains(class(input), '.impl.')
                error('Input must be a Comsol Node');
            end
            if isa(input, 'com.comsol.clientapi.impl.ModelClient')
                error('Input must not be an Comsol model but one of its child nodes')
            end
        end
    end
end

