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
            %Expects an itaComsolModel as input
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel),...
                'Input must be an itaComsolModel')
            obj.mModel = comsolModel;
        end
    end
    
    %% Results
    methods
        function p = Pressure(obj, evalPos)
            %Evaluates the pressure at the mesh nodes (no input) or for the
            %given itaCoordinates / itaReceiver
            %   evalPos (optional): itaCoordinates with coordinates for evaluation
            %                       or itaReceiver
            if nargin == 1
                p = obj.ByExpression('p');
            else
                assert(isa(evalPos, 'itaCoordinates') || isa(evalPos, 'itaReceiver'), 'Input must be of type itaCoordinates or itaReceiver')
                p = obj.ByExpression('p', evalPos);
            end
        end
        function res = ByExpression(obj, expression, evalPos)
            %Evaluates the given expression either at the mesh nodes or at
            %the given itaCoordinates
            %   Inputs:
            %   expression:             char row-vector with expression to be evaluated
            %   evalPos (optional):     itaCoordinates with coordinates for evaluation
            %                           or itaReceiver
            assert(ischar(expression) && isrow(expression), 'First input must be char row vector with the expression of the result')
            if nargin == 2
                res = obj.getResultAtMeshNodes(expression);
            else
                if isa(evalPos, 'itaReceiver')
                    evalPos = obj.extractCoordsFromReceiver(evalPos);
                end
                assert(isa(evalPos, 'itaCoordinates'), 'Second input must be of type itaCoordinates or itaReceiver')
                res = obj.getResultAtCoords(expression, evalPos);
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
    methods(Access = private, Static = true)
        function coords = extractCoordsFromReceiver(receiver)
            numCoords = numel(receiver) * (receiver.type.IsBinaural() + 1);
            coords = itaCoordinates(numCoords);
            for idxReceiver = 1:numel(receiver)
                currentReceiver = receiver(idxReceiver);
                if receiver.type.IsMonaural()
                    coords.cart(idxReceiver, :) = currentReceiver.position.cart;
                else
                    coords.cart([2*idxReceiver-1, 2*idxReceiver], :) =...
                        [currentReceiver.leftEarMicPosition.cart;...
                         currentReceiver.rightEarMicPosition.cart];
                end
            end
        end
    end
end

