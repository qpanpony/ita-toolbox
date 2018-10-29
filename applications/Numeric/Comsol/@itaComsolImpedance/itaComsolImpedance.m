classdef itaComsolImpedance < handle
    %itaComsolImpedance Represents an impedance boundary condition in an
    %itaComsolModel
    %   Provides static create functions that generate an itaComsolImpedance
    %   for a given itaComsolModel using a boundary group name and an
    %   itaMaterial or itaSuper.Therefore. suitable physics and interpolation
    %   nodes are created and linked apropriately. All comsol nodes
    %   representing this impedance are stored for later modification.
 
    properties(Access = private)
        mModel;
        mImpedancePhysicsNode;
        mImpedanceRealDataNode;
        mImpedanceImagDataNode;
    end
    
    %% Constructor
    methods
        function obj = itaComsolImpedance(comsolModel, impedancePhysicsNode, realInterpolationNode, imagInterpolationNode)
            %Constuctor should not be used manually. Use static Create
            %functions instead!
            assert(isa(comsolModel, 'itaComsolModel'), 'First input must be a single itaComsolModel')
            assert(isa(impedancePhysicsNode, 'com.comsol.clientapi.physics.impl.PhysicsFeatureClient'), 'Second input must be a comsol physics feature node')
            assert(isa(realInterpolationNode, 'com.comsol.clientapi.impl.FunctionFeatureClient'), 'Third input must be a comsol function feature node')
            assert(isa(imagInterpolationNode, 'com.comsol.clientapi.impl.FunctionFeatureClient'), 'Fourth input must be a comsol function feature node')
            
            obj.mModel = comsolModel;
            obj.mImpedancePhysicsNode = impedancePhysicsNode;
            obj.mImpedanceRealDataNode = realInterpolationNode;
            obj.mImpedanceImagDataNode = imagInterpolationNode;
        end
    end
    
    %----------Static Creators------------
    methods(Static = true)
        function obj = Create(comsolModel, boundaryGroupName, data)
            assert(isa(comsolModel, 'itaComsolModel'), 'First input must be a single itaComsolModel')
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Second input must be a char row vector')
            assert(isvarname(strrep(boundaryGroupName, ' ', '_')), 'Given boundary group name must be valid variable name (whitespace allowed)')
            if isa(data, 'itaMaterial'); data = data.impedance; end
            assert(isa(data, 'itaSuper') && numel(data) == 1 && data.nChannels == 1,...
                'Third input must either be an itaMaterial with a valid impedance or a single itaSuper')
            
            boundaryGroupNode = comsolModel.selection.BoundaryGroup(boundaryGroupName);
            assert(~isempty(boundaryGroupNode), 'No boundary group with given name found!')
            
            baseTag = strrep(boundaryGroupName, ' ', '_');
            interpolationBaseTag = [baseTag '_impedance'];
            impedanceTag = [baseTag '_impedance'];
            selectionTag = char(boundaryGroupNode.tag);
            
            [realInterpolationNode, imagInterpolationNode, funcExpression] = ...
                itaComsolImpedance.createImpedanceInterpolation(comsolModel, interpolationBaseTag, data.freqVector, data.freqData);
            
            impedanceNode = comsolModel.physics.CreateImpedance(impedanceTag, selectionTag, funcExpression);
            
            obj = itaComsolImpedance(comsolModel, impedanceNode, realInterpolationNode, imagInterpolationNode);
            obj.Enable();
        end
    end
    
    %% Enable / Disable
    methods
        function Disable(obj)
            obj.mImpedancePhysicsNode.active(false);
            obj.mImpedanceRealDataNode.active(false);
            obj.mImpedanceImagDataNode.active(false);
        end
        function Enable(obj)
            obj.mImpedancePhysicsNode.active(true);
            obj.mImpedanceRealDataNode.active(true);
            obj.mImpedanceImagDataNode.active(true);
        end
    end
    
    %% Helpers
    methods(Access = private, Static = true)
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createImpedanceInterpolation(comsolModel, interpolationBaseName, freqVector, complexDataVector)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = comsolModel.func.CreateComplexInterpolation(interpolationBaseName, freqVector, complexDataVector, 'Pa / m * s');
        end
    end
end