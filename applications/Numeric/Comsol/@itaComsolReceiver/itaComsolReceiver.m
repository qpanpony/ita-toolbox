classdef itaComsolReceiver < handle
    %itaComsolReceiver Represents an itaReceiver in an itaComsolModel
    %   Provides static create functions that generate an itaComsolReceiver
    %   for a given itaComsolModel using an itaReceiver. Therefore depending
    %   on the receiver type, suitable geometry nodes are created. All comsol
    %   nodes representing this receiver are stored for later modification.
    
    properties(Access = private)
        mModel;
        mGeometryNodes;
        mSelectionTags = {};
    end
    
    properties(Dependent = true, SetAccess = private)
        selectionTags;      %Includes tags to the geometry nodes representing this receiver
    end
    
    properties(Constant = true)
        dummyHeadGeometryTagSuffix = '_dummyHeadGeometry';
        geometryTagSuffixes = {itaComsolReceiver.dummyHeadGeometryTagSuffix};
    end
    
    %% Constructor
    methods
        function obj = itaComsolReceiver(comsolModel, receiverGeometryNode, selectionTags)
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
            
            obj.mModel = comsolModel;
            obj.mGeometryNodes = receiverGeometryNode;
            obj.mSelectionTags = selectionTags;
        end
    end
    
    %----------Static Creators------------
    methods(Static = true)
        function obj = Create(comsolModel, receiver)
            %Creates an acoustic receiver for the given comsol model using
            %an itaReceiver. Geometry of the receiver depends on the
            %ReceiverType.
            %   Inputs:
            %   comsolModel     Comsol model, the source is created for [itaComsolModel]
            %   receiver        Object with source data [single itaReceiver]
            %
            %   Supported receiver types: Monaural, DummyHead
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolReceiver.checkInputForValidItaReceiver(receiver);
            switch receiver.type
                case ReceiverType.Monaural
                    obj = itaComsolReceiver();
                case ReceiverType.DummyHead
                    obj = itaComsolReceiver.CreateDummyHead(comsolModel, receiver);
                otherwise
                    error('Unknown receiver type. No receiver was created')
            end
        end
        
        function obj = CreateDummyHead(comsolModel, receiver)
            %Creates a dummy head geometry given an itaSource for the given
            %comsol model
            %   In Comsol internally, ...
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel), 'First input must be a single itaComsolModel')
            itaComsolReceiver.checkInputForValidItaReceiver(receiver);
            assert(receiver.type == ReceiverType.DummyHead,'ReceiverType of given source must be DummyHead')
            
            baseTag = strrep(receiver.name, ' ', '_');
            receiverGeometryBaseTag = [baseTag itaComsolReceiver.dummyHeadGeometryTagSuffix];
            %soundHardTag = [baseTag '_pistonSourceSoundHardBoundary'];
            
            %physicsNode = comsolModel.physics.activeNode;
            geometry = comsolModel.geometry;
            [dummyHeadGeometryNodes, selectionTag] = geometry.CreateDummyHeadGeometry(receiverGeometryBaseTag, receiver);
            
            %soundHardBoundaryNode = comsolModel.physics.CreateSoundHardBoundary(soundHardTag, selectionTag);
                        
            obj = itaComsolReceiver(comsolModel, dummyHeadGeometryNodes, selectionTag);
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
    end
    methods(Access = private)
        function setActive(obj, bool)
            for idxGeom=1:numel(obj.mGeometryNodes)
                obj.mGeometryNodes(idxGeom).active(bool);
            end
        end
    end
    
    %% Helpers
    methods(Access = private, Static = true)
        
        function checkInputForValidItaReceiver(receiver)
            
            assert(isa(receiver, 'itaReceiver') && isscalar(receiver),'Input must be a single itaReceiver object')
            assert(isvarname( strrep(receiver.name, ' ', '_') ),...
                'Name of given source must be valid variable name (whitespace allowed)')
            assert(receiver.HasSpatialInformation(), 'Geometric information not fully specified for itaReceiver')
        end
    end
end