classdef itaComsolParameters < itaComsolNode
    %itaComsolParameters Interface to the param (=parameter) nodes of an itaComsolModel
    %   Allows to list the parameters of the Comsol model and adjust their
    %   values.
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolParameters">doc itaComsolParameters</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    
    %% Constructor
    methods
        function obj = itaComsolParameters(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'param', 'com.comsol.clientapi.impl.ModelParamClient')
        end
    end
    
    %% Set & Get
    methods
        function Set(obj, parameterName, value)
            %Sets a comsol parameter given its name and a new value
            %   Both input are expected to be char row vectors. This also
            %   makes sense for the value since usually a unit should be
            %   specified
            assert(ischar(parameterName) && isrow(parameterName), 'parameterName must be a char row vector')
            assert(ischar(value) && isrow(value), 'value must be a char row vector')
            
            parameterNodeNames = obj.All;
            for idxNode = 1:numel(parameterNodeNames)
                paramNode = parameterNodeNames{idxNode};
                if ~any(strcmp(cell(paramNode.varnames), parameterName)); continue; end
                
                paramNode.set(parameterName, value);
                return;
            end
            error('Parameter of with given name is not defined')
        end
        function out = List(obj)
            %Returns a list of all parameters and their values as Nx2 cell
            %array
            out = cell(0);
            parameterNodeNames = obj.All;
            for idxNode = 1:numel(parameterNodeNames)
                paramNode = parameterNodeNames{idxNode};
                parameterNames = paramNode.varnames;
                for idxParam = 1:numel(parameterNames)
                   paramName = char(parameterNames(idxParam));
                   paramValue = paramNode.get(paramName);
                   if isa(paramValue, 'java.lang.String'); paramValue = char(paramValue); end
                   out(end+1, :) = {paramName, paramValue};
                end
            end
        end
    end
    
    %% Bool
    methods
        function out = Exists(obj, parameterName)
            %Returns true if given parameter is part of the model
            assert(ischar(parameterName) && isrow(parameterName), 'parameterName must be a char row vector')
            list = obj.List;
            out = any(strcmp(list(:,1), parameterName));
        end
    end
end