classdef itaComsolResult < handle
    %itaComsolResult Interface to access simulation results of an
    %itaComsolModel object
    %   Detailed explanation goes here
    
    properties(Access = private)
        mModel;
        mResultDomain = 'freq'; %'freq' | 'time'
    end
    
    methods
        function obj = itaComsolResult(comsolModel)
            assert(isa(comsolModel, 'itaComsolModel'),...
                'Input must be an itaComsolModel')
            obj.mModel = comsolModel;
        end
    end
    
    %% Results
    methods
        function p = Pressure(obj, itaCoords)
            %Evaluates the pressure at the mesh nodes or the given
            %itaCoordinates
            %   Optitional input:   itaCoordinates with coordinates for evaluation
            if nargin == 1
                p = obj.ByExpression('p');
            else
                assert(isa(itaCoords, 'itaCoordinates'), 'Input must be of type itaCoordinates')
                p = obj.ByExpression('p', itaCoords);
            end
        end
        function res = ByExpression(obj, expression, itaCoords)
            %Evaluates the given expression either at the mesh nodes or at
            %the given itaCoordinates
            %   Inputs:
            %   First input:        char row-vector with expression to be evaluated
            %   Optitional input:   itaCoordinates with coordinates for evaluation
            assert(ischar(expression) && isrow(expression), 'First input must be char row vector with the expression of the result')
            if nargin == 2
                res = obj.getResultAtMeshNodes(expression);
            else
                assert(isa(itaCoords, 'itaCoordinates'), 'Second input must be of type itaCoordinates')
                res = obj.getResultAtCoords(expression, itaCoords);
            end
        end
    end
    methods(Access = private)
        function res = getResultAtMeshNodes(obj, expression, dim, selection)
            if nargin == 2
                data = mpheval(obj.mModel.modelNode, expression);
            elseif nargin > 2
                if nargin == 3; selection = 'all'; end
                data = mpheval(obj.mModel.modelNode, expression, 'edim', dim, 'selection', selection);
            end
            itaCoords = itaCoordinates(data.p.');
            freqData = data.d1;
            
            res = obj.createItaResult(freqData, itaCoords);
        end
        function res = getResultAtCoords(obj, expression, itaCoords, dim, selection)
            if nargin == 3
                freqData = mphinterp(obj.mModel.modelNode, expression, 'coord', itaCoords.cart.');
            elseif nargin > 3
                if nargin == 4; selection = 'all'; end
                freqData = mphinterp(obj.mModel.modelNode, expression, 'coord', itaCoords.cart.', 'edim', dim, 'selection', selection);
            end
            res = obj.createItaResult(freqData, itaCoords);
        end
        function res = createItaResult(obj, freqData, itaCoords)
            info = mphsolinfo(obj.mModel.modelNode);
            freqVector = info.solvals;
            res = itaResult(freqData, freqVector, 'freq');
            res.channelCoordinates = itaCoords;
        end
    end
end

