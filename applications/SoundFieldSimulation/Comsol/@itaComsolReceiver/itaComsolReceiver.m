classdef itaComsolReceiver < handle
    %itaComsolReceiver Represents an itaReceiver in an itaComsolModel
    %   Provides static create functions that generate an itaComsolReceiver
    %   for a given itaComsolModel using an itaReceiver. Therefore depending
    %   on the receiver type, suitable geometry nodes are created. All comsol
    %   nodes representing this receiver are stored for later modification.
    %   
    %   See also itaComsolModel, itaComsolServer, itaComsolSource,
    %   itaComsolImpedance
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolReceiver">doc itaComsolReceiver</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mModel;
        mGeometryNodes;
        mSelectionTags = {};
        mMeshNodes;
        mActive = true;
    end
    
    properties(Dependent = true, SetAccess = private)
        selectionTags;      %Includes tags to the geometry nodes representing this receiver
    end
    
    properties(Constant = true)
        dummyHeadGeometryTagSuffix = '_dummyHeadGeometry';
        dummyHeadMeshTagSuffix = '_dummyHeadMeshSize';
        geometryTagSuffixes = {itaComsolReceiver.dummyHeadGeometryTagSuffix};
    end
    
    %% Constructor
    methods
        function obj = itaComsolReceiver(comsolModel, receiverGeometryNode, selectionTags, meshNodes)
            %Constructor should only be used to create empty object (no
            %input). To create a non-empty object, use static Create functions!
            
            %To create empty object
            if nargin == 0; return; end
            
            %Geometry only
            assert(isa(comsolModel, 'itaComsolModel'), 'First input must be a single itaComsolModel');
            assert(isa(receiverGeometryNode, 'com.comsol.clientapi.impl.GeomFeatureClient') ||...
                isa(receiverGeometryNode, 'com.comsol.clientapi.impl.GeomFeatureClient[]'),...
                'Second input must be a comsol geometry feature node');
            if ischar(selectionTags) && isrow(selectionTags); selectionTags = {selectionTags}; end
            assert(~isempty(selectionTags) && iscellstr(selectionTags),...
                'Third input must be a cell of char vectors');
            
            if nargin == 4
                assert(isa(meshNodes, 'com.comsol.clientapi.impl.MeshFeatureClient') ||...
                isa(meshNodes, 'com.comsol.clientapi.impl.MeshFeatureClient[]'),...
                    'Fourth input must be a comsol mesh feature node')
            else
                meshNodes = [];
            end
            
            obj.mModel = comsolModel;
            obj.mGeometryNodes = receiverGeometryNode;
            obj.mSelectionTags = selectionTags;
            obj.mMeshNodes = meshNodes;
        end
    end
    
    %----------Static Creators------------
    methods(Static = true)
        function obj = Create(comsolModel, receiver)
            %Creates an acoustic receiver for the given comsol model using
            %an itaReceiver. Geometry of the receiver depends on the
            %ReceiverType.
            %   Inputs:
            %   comsolModel     Comsol model, the receiver is created for [itaComsolModel]
            %   receiver        Object with receiver data [single itaReceiver]
            %
            %   Supported receiver types: Monaural, ITADummyHead
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolReceiver.checkInputForValidItaReceiver(receiver);
            switch receiver.type
                case ReceiverType.Monaural
                    obj = itaComsolReceiver();
                case ReceiverType.ITADummyHead
                    obj = itaComsolReceiver.CreateDummyHead(comsolModel, receiver);
                otherwise
                    error('Unknown receiver type. No receiver was created')
            end
        end
        
        function obj = CreateDummyHead(comsolModel, receiver)
            %Creates a dummy head geometry given an itaSource for the given
            %comsol model
            %   In Comsol internally, ...
            %
            %   Inputs:
            %   comsolModel     Comsol model, the receiver is created for [itaComsolModel]
            %   receiver        Object with receiver data [single itaReceiver]
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolReceiver.checkInputForValidItaReceiver(receiver);
            assert(receiver.type == ReceiverType.ITADummyHead, 'ReceiverType of given source must be DummyHead')
            
            baseTag = strrep(receiver.name, ' ', '_');
            receiverGeometryBaseTag = [baseTag itaComsolReceiver.dummyHeadGeometryTagSuffix];
            meshSizeTag = [baseTag itaComsolReceiver.dummyHeadMeshTagSuffix];
            
            geometry = comsolModel.geometry;
            [dummyHeadGeometryNodes, selectionTag] = geometry.ImportReceiverGeometry(receiverGeometryBaseTag, receiver);
            
            meshNode = comsolModel.mesh;
            sizeNode = meshNode.CreateSize(meshSizeTag, selectionTag);
            meshNode.SetPositionOfFeature(meshSizeTag, 1);
            meshNode.SetMinimumSizeProperties(sizeNode, ...
                'hmax', 0.04, 'hmin', 0.004, 'hgrad', 1.3, 'hcurve', 0.2, 'hnarrow', 1)
                        
            obj = itaComsolReceiver(comsolModel, dummyHeadGeometryNodes, selectionTag, sizeNode);
            obj.Enable();
        end
    end
    
    %% Get
    methods
        function out = get.selectionTags(this)
            out = this.mSelectionTags;
        end
    end
    
    %% Enable / Disable
    methods
        function Disable(obj)
            obj.setActive(false);
        end
        function Enable(obj)
            obj.setActive(true);
        end
        
        function out = IsActive(obj)
            out = obj.mActive;
        end
    end
    methods(Access = private)
        function setActive(obj, bool)
            for idxGeom=1:numel(obj.mGeometryNodes)
                obj.mGeometryNodes(idxGeom).active(bool);
            end
            for idxNode=1:numel(obj.mMeshNodes)
                obj.mMeshNodes(idxNode).active(bool);
            end
            obj.mActive = bool;
        end
    end
    
    %% Helpers
    methods(Access = private, Static = true)
        
        function checkInputForValidItaReceiver(receiver)
            
            assert(isa(receiver, 'itaReceiver') && isscalar(receiver),'Input must be a single itaReceiver object')
            assert(isvarname( strrep(receiver.name, ' ', '_') ),...
                'Name of given receiver must be valid variable name (whitespace allowed)')
            assert(receiver.HasSpatialInformation(), 'Geometric information not fully specified for itaReceiver')
        end
    end
end