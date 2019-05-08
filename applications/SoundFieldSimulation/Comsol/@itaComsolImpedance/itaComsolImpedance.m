classdef itaComsolImpedance < handle
    %itaComsolImpedance Represents an impedance boundary condition in an
    %itaComsolModel
    %   Provides static create functions that generate an itaComsolImpedance
    %   for a given itaComsolModel using a boundary group name and an
    %   itaMaterial or itaSuper.Therefore. suitable physics and interpolation
    %   nodes are created and linked apropriately. All comsol nodes
    %   representing this impedance are stored for later modification.
    %   
    %   See also itaComsolModel, itaComsolServer, itaComsolSource,
    %   itaComsolReceiver
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolImpedance">doc itaComsolImpedance</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
 
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
            if nargin > 2
                assert(isa(realInterpolationNode, 'com.comsol.clientapi.impl.FunctionFeatureClient'), 'Third input must be a comsol function feature node')
                assert(isa(imagInterpolationNode, 'com.comsol.clientapi.impl.FunctionFeatureClient'), 'Fourth input must be a comsol function feature node')
            else
                realInterpolationNode = [];
                imagInterpolationNode = [];
            end
            
            obj.mModel = comsolModel;
            obj.mImpedancePhysicsNode = impedancePhysicsNode;
            obj.mImpedanceRealDataNode = realInterpolationNode;
            obj.mImpedanceImagDataNode = imagInterpolationNode;
        end
    end
    
    %----------Static Creators------------
    methods(Static = true)
        function obj = Create(comsolModel, boundaryGroupName, data)
            %Creates an impedance boundary condition for the given comsol
            %model using either an itaResult or itaMaterial. The impedance
            %is applied to the boundary group (2D Comsol selection) with
            %the specified name.
            %   Inputs:
            %   comsolModel         Comsol model, the impedance is created for [itaComsolModel]
            %   boundaryGroupName   Name of the boundary group the impedance is created for [char row vector]
            %   data                Object with impedance data [itaResult / itaMaterial]
            
            assert(isa(comsolModel, 'itaComsolModel'), 'First input must be a single itaComsolModel')
            assert(ischar(boundaryGroupName) && isrow(boundaryGroupName), 'Second input must be a char row vector')
            assert(isvarname(strrep(boundaryGroupName, ' ', '_')), 'Given boundary group name must be valid variable name (whitespace allowed)')
            
            dataAssertStr = 'Third input must either be an itaMaterial with a valid impedance or a single itaSuper';
            assert(isa(data, 'itaMaterial') || isa(data, 'itaSuper'), dataAssertStr)
            if isa(data, 'itaSuper')
                assert(numel(data) == 1 && data.nChannels == 1, dataAssertStr)
                material = itaMaterial;
                material.impedance = data;
            else
                material = data;
            end
            assert(material.HasImpedance(), dataAssertStr)
            
            boundaryGroupNode = comsolModel.selection.BoundaryGroup(boundaryGroupName);
            assert(~isempty(boundaryGroupNode), 'No boundary group with given name found!')
            
            baseTag = strrep(boundaryGroupName, ' ', '_');
            interpolationBaseTag = [baseTag '_impedance'];
            impedanceTag = [baseTag '_impedance'];
            selectionTag = char(boundaryGroupNode.tag);
            
            switch material.impedanceType
                case ImpedanceType.SoundHard
                    obj = itaComsolImpedance.createSoundHard(comsolModel, impedanceTag, selectionTag);
                case ImpedanceType.UserDefined
                    obj = itaComsolImpedance.createUserDefinedImpedance(...
                        comsolModel, material, interpolationBaseTag, impedanceTag, selectionTag);
                otherwise
                    error('Unsupported ImpedanceType')
            end
            obj.Enable;
        end
    end
    methods(Static = true, Access = private)
        function obj = createSoundHard(comsolModel, impedanceTag, selectionTag)
            impedanceNode = comsolModel.physics.CreateImpedance(impedanceTag, selectionTag, 'inf');
            
            obj = itaComsolImpedance(comsolModel, impedanceNode);
        end
        function obj = createUserDefinedImpedance(comsolModel, material, interpolationBaseTag, impedanceTag, selectionTag)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = ...
                itaComsolImpedance.createImpedanceInterpolation(comsolModel, interpolationBaseTag, material.impedance.freqVector, material.impedance.freqData);
            
            impedanceNode = comsolModel.physics.CreateImpedance(impedanceTag, selectionTag, funcExpression);
            
            obj = itaComsolImpedance(comsolModel, impedanceNode, realInterpolationNode, imagInterpolationNode);
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
            if ~isempty(obj.mImpedancePhysicsNode)
                obj.mImpedancePhysicsNode.active(bool);
            end
            if ~isempty(obj.mImpedanceRealDataNode)
                obj.mImpedanceRealDataNode.active(bool);
            end
            if ~isempty(obj.mImpedanceImagDataNode)
                obj.mImpedanceImagDataNode.active(bool);
            end
        end
    end
    
    %% Helpers
    methods(Access = private, Static = true)
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = createImpedanceInterpolation(comsolModel, interpolationBaseTag, freqVector, complexDataVector)
            [realInterpolationNode, imagInterpolationNode, funcExpression] = comsolModel.func.CreateComplexInterpolation(interpolationBaseTag, freqVector, complexDataVector, 'Pa / m * s');
        end
    end
end