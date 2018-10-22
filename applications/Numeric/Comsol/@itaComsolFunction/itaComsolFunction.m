classdef itaComsolFunction < itaComsolNode
    %itaComsolFunction Interface to the func (=function) nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolFunction(comsolModel)
            obj@itaComsolNode(comsolModel, 'func', 'com.comsol.clientapi.impl.FunctionFeatureClient')
        end
    end
    
    %% Interpolation
    methods
        function interpolationNode = CreateInterpolation(obj, functionName, propertyStruct)
            %Creates an Interpolation with the given function name (if not
            %already existing) and returns it. Optionally, the function
            %properties can be set using a property struct.
            %   The function name must be a valid Matlab variable name (no
            %   whitespace, not starting with a number and so on...).
            %   The property struct has the property names as field names
            %   and the respective property values as the field values
            assert(ischar(functionName) && isrow(functionName), 'First input must be a char row vector')
            assert(isvarname(functionName), 'First input must be a valid variable name')
            if nargin > 2; assert(isstruct(propertyStruct), 'Second input must be a struct with function properties'); end
            
            if ~obj.hasChildNode(obj.modelNode.func, functionName)
                obj.modelNode.func.create(functionName, 'Interpolation');
            end
            
            interpolationNode = obj.modelNode.func(functionName);
            interpolationNode.label(functionName);
            
            if nargin == 2; return; end
            obj.setNodeProperties( interpolationNode, propertyStruct );
        end
        
        function [realInterpolationNode, imagInterpolationNode, funcExpression] = CreateComplexInterpolation(obj, interpolationBaseName, freqVector, complexDataVector, functionUnits)
            %Creates or adjusts two Comsol Interpolation nodes, one for the
            %real and one for the imaginary data and returns the two
            %interpolation nodes.
            %   The interpolation tags are interpolationBaseName_real and
            %   interpolationBaseName_imag. The argument units are set to
            %   Hz whereas the function units are specified by the user.
            %   Default methods are "piecewise cubic" interpolation and
            %   "linear" extrapolation.
            assert(ischar(interpolationBaseName) && isrow(interpolationBaseName), 'First input must be a char row vector')
            assert(isnumeric(freqVector) && isvector(freqVector) && isreal(freqVector), 'Second input must be a real-valued double vector')
            assert(isnumeric(complexDataVector) && isvector(complexDataVector), 'Third input must be a complex-valued double vector')
            assert(ischar(functionUnits) && isrow(functionUnits), 'Fourth input must be a char row vector')
            
            interpolationNameReal = [interpolationBaseName '_real'];
            interpolationNameImag = [interpolationBaseName '_imag'];
            
            realInterpolationNode = obj.CreateInterpolation(interpolationNameReal);
            imagInterpolationNode = obj.CreateInterpolation(interpolationNameImag);
            
            propertyStruct.source = 'table';
            propertyStruct.argunit = 'Hz';
            propertyStruct.fununit = functionUnits;
            propertyStruct.extrap = 'linear';
            propertyStruct.interp = 'piecewisecubic';
            
            obj.setNodeProperties(realInterpolationNode, propertyStruct);
            obj.setNodeProperties(imagInterpolationNode, propertyStruct);
            
            obj.setInterpolationTableData(realInterpolationNode, freqVector, real(complexDataVector));
            obj.setInterpolationTableData(imagInterpolationNode, freqVector, imag(complexDataVector));
            
            funcExpression = obj.GetComplexFunctionExpression(realInterpolationNode, imagInterpolationNode);
        end
    end
    methods(Static = true)
        function expression = GetComplexFunctionExpression(realInterpolationNode, imagInterpolationNode)
            realFuncName = char(realInterpolationNode.tag);
            imagFuncName = char(imagInterpolationNode.tag);
            expression = [realFuncName '(freq) + i*' imagFuncName '(freq)'];
        end
    end
    methods(Access = private, Static = true)
        function setInterpolationTableData(interpolationNode, argumentVector, functionVector)
            assert(isreal(argumentVector) && isreal(functionVector), 'Data vectors for Comsol interpolation must be real valued')
            if isrow(argumentVector); argumentVector = argumentVector.'; end
            if isrow(functionVector); functionVector = functionVector.'; end
            
            %Note: Comsol expects a Nx2 cell string array for the table data
            comsolTableData = [ cellstr( num2str(argumentVector) ) cellstr( num2str(functionVector) )];
            interpolationNode.set('table', comsolTableData);
        end
    end
end