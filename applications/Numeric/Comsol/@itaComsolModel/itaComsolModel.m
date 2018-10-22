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
        mMaterialNode;
        mPhysicsNode;
        mMeshNode;
        mStudyNode;
        mResultNode;
    end
    properties(Dependent = true, SetAccess = private)
        modelNode;      %The comsol model node
        
        selection;      %Interface to access Comsol selection clients (itaComsolSelection)
        func;           %Interface to access Comsol function clients (itaComsolFunction)
        geometry;       %Interface to access Comsol geometry sequences (itaComsolMaterial)
        material;       %Interface to access Comsol material clients (itaComsolGeometry)
        physics;        %Interface to access Comsol physics sequences (itaComsolPhysics)
        mesh;           %Interface to access Comsol mesh sequences (itaComsolMesh)
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
        function out = get.material(obj)
            out = obj.mMaterialNode;
        end
        function out = get.physics(obj)
            out = obj.mPhysicsNode;
        end
        function out = get.mesh(obj)
            out = obj.mMeshNode;
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
            obj.mMaterialNode = itaComsolMaterial(obj);
            obj.mPhysicsNode = itaComsolPhysics(obj);
            obj.mMeshNode = itaComsolMesh(obj);
            obj.mStudyNode = itaComsolStudy(obj);
            obj.mResultNode = itaComsolResult(obj);
            
            assert(~isempty(obj.mGeometryNode.activeNode), 'No Comsol geometry node found')
            assert(~isempty(obj.mPhysicsNode.activeNode), 'No Comsol physics node found')
            assert(~isempty(obj.mMeshNode.activeNode), 'No Comsol mesh node found')
            assert(~isempty(obj.mStudyNode.activeNode), 'No Comsol study node found')
        end
    end
end

