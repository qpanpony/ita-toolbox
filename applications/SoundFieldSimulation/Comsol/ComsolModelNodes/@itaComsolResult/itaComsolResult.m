classdef itaComsolResult < handle
    %itaComsolResult Interface to access simulation results of an
    %itaComsolModel object
    %   Allows to evaluate the results of a study at the mesh nodes or
    %   given coordintas. The result are then returned as an itaResult
    %   object with one channel per given coordinate.
    %
    %   Note:
    %   The direct data import only works for FEM simulation. For BEM,
    %   simulations data has to be exported to .csv files and before being
    %   imported into Matlab (see itaComsolExport & ita_read_comsol_csv).
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolResult">doc itaComsolResult</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    properties(Access = private)
        mModel;
        mResultDomain = 'freq'; %'freq' | 'time'
        
        mExport;
        mDataset;
    end
    properties(Dependent = true)
        export;     %Grants access to result data export (see itaComsolExport)
        dataset;    %Grants access to dataset nodes (see itaComsolDataset)
    end
    
    %% Constructor
    methods
        function obj = itaComsolResult(comsolModel)
            %Expects an itaComsolModel as input
            assert(isa(comsolModel, 'itaComsolModel') && isscalar(comsolModel),...
                'Input must be an itaComsolModel')
            obj.mModel = comsolModel;
            
            obj.mExport = itaComsolExport(comsolModel);
            obj.mDataset = itaComsolDataset(comsolModel);
        end
    end
    
    %% Export node
    methods
        function out = get.export(obj)
            out = obj.mExport;
        end
        function out = get.dataset(obj)
            out = obj.mDataset;
        end
    end
    
    %% Public result getters
    methods
        function [p, metaData] = Pressure(obj, evalPos)
            %For the active study, evaluates for the pressure at the mesh
            %nodes (no input) or for the given itaCoordinates / itaReceiver.
            %Also returns a metadata struct that contains information for
            %parametric sweeps.
            %   Inputs:
            %   evalPos (optional): itaCoordinates with coordinates for evaluation
            %                       or itaReceiver
            %   
            %   Outputs:
            %   p:          itaResult with one entry per simulation
            %   metaData:   Struct with info on parametric sweep
            
            %use active physics
            pressureExpression = obj.getPressureExpression();
            if nargin == 1
                [p, metaData] = obj.ByExpression(pressureExpression);
            else
                assert(isa(evalPos, 'itaCoordinates') || isa(evalPos, 'itaReceiver'), 'Input must be of type itaCoordinates or itaReceiver')
                [p,metaData] = obj.ByExpression(pressureExpression, evalPos);
            end
        end
        function [res, metaData] = ByExpression(obj, expression, evalPos)
            %For the active study, evaluates the given expression either at
            %the mesh nodes (FEM only) or at the given itaCoordinates. Also
            %returns a metadata struct that contains information for#
            %parametric sweeps.
            %   Inputs:
            %   expression:             char row-vector with expression to be evaluated
            %   evalPos (optional):     itaCoordinates with coordinates for evaluation
            %                           or itaReceiver
            %   
            %   Outputs:
            %   p:          itaResult with one entry per simulation
            %   metaData:   struct with info on parametric sweep
            assert(ischar(expression) && isrow(expression), 'First input must be char row vector with the expression of the result')
            
            if nargin == 2
                %NOTE - PSC:
                %Since the Comsol function mpheval seems to have a bug if
                %using the pabe physics, getting pabe results at the mesh
                %nodes is disabled.
                assert( ~contains(expression, 'pabe'), 'You have to specify coordinates if evaluating a BEM (pabe) result' )
                [res, metaData] = obj.getResultAtMeshNodes(expression);
            else
                if isa(evalPos, 'itaReceiver')
                    evalPos = obj.extractCoordsFromReceiver(evalPos);
                end
                assert(isa(evalPos, 'itaCoordinates'), 'Second input must be of type itaCoordinates or itaReceiver')
                [res, metaData] = obj.getResultAtCoords(expression, evalPos);
            end
        end
    end
    
    %% Extract results
    methods(Access = private)
        function [res, metaData] = getResultAtMeshNodes(obj, expression)
            datasetTag = obj.getDirectDatasetTag();
            metaData = obj.createMetaDataStruct(datasetTag);
            if ~isempty(metaData.parameterValues) %Param sweep
                res = itaResult([1 metaData.nSimulations]);
                for idxParam = 1:metaData.nSimulations
                    %NOTE - PSC:
                    %'outersolnum' = 'all' does not work if the mesh is
                    %parameter-dependent since then the number of data
                    %points differs between parametric solutions.
                    %Thus, we have to get the results one by one.
                    data = mpheval(obj.mModel.modelNode, expression, 'dataset',datasetTag,'outersolnum',idxParam);
                    itaCoords = itaCoordinates(data.p.');
                    freqData = data.d1;
                    freqVector = mphglobal(obj.mModel.modelNode,'freq','dataset',datasetTag,'outersolnum',idxParam);
                    res(idxParam) = obj.createItaResult(freqData, freqVector, itaCoords);
                end
            else
                data = mpheval(obj.mModel.modelNode, expression, 'dataset',datasetTag,'outersolnum','all');
                itaCoords = itaCoordinates(data.p.');
                freqData = data.d1;
                freqVector = mphglobal(obj.mModel.modelNode,'freq','dataset',datasetTag,'outersolnum','all');
                res = obj.createItaResult(freqData, freqVector, itaCoords);
            end
        end
        function [res, metaData] = getResultAtCoords(obj, expression, itaCoords)
            freqDatasetTag = obj.getResultAtCoordsDatasetTag(expression);
            directDatasetTag = obj.getDirectDatasetTag();
            metaData = obj.createMetaDataStruct(directDatasetTag);
            
            if contains(expression, 'pabe')
                disp('**ITA-COMSOL** Starting evaluating BEM result at user-defined coordinates.')
                disp('               This might take a while...')
            end
            %NOTE - PSC:
            %Appearently, 'outersolnum' = 'all' does not work for pabe at
            %the moment due to a bug. Thus, the solver range is set
            %manually using the metaData struct.
            freqData = mphinterp(obj.mModel.modelNode, expression, 'coord', itaCoords.cart.', 'dataset', freqDatasetTag,'outersolnum',1:metaData.nSimulations);
            freqVector = mphglobal(obj.mModel.modelNode,'freq','dataset',directDatasetTag,'outersolnum',1:metaData.nSimulations);            
            if contains(expression, 'pabe')
                disp('**ITA-COMSOL** Done!')
            end
            
            if numel(size(freqData))==3 %Param sweep
                res = obj.createParametricItaResult(freqData, freqVector, itaCoords);
            else
                res = obj.createItaResult(freqData, freqVector, itaCoords);
            end
        end
        function metaData = createMetaDataStruct(obj, datasetTag)
            [parameterNames, parameterValues, parameterUnits] = obj.getParametricSweepData(datasetTag);
            metaData.nSimulations = 1;
            if ~isempty(parameterValues)
                metaData.nSimulations = numel(parameterValues{1});
            end
            metaData.nParameters = numel(parameterNames);
            metaData.parameterNames = parameterNames;
            metaData.parameterValues = parameterValues;
            metaData.parameterUnits = parameterUnits;
        end
        function [parameterNames, parameterValues, parameterUnits] = getParametricSweepData(obj, datasetTag)
            [parameterNames, parameterUnits] = obj.mModel.study.GetParametricSweepParameters();
            parameterValues = cell(size(parameterNames));
            for idxParam = 1:numel(parameterNames)
                paramValues = mphglobal(obj.mModel.modelNode,...
                    parameterNames{idxParam}, 'dataset', datasetTag,'outersolnum','all');
                %In case of a frequency study, param values contains one
                %row per frequency bin but with the same values, so we only
                %take the first row.
                parameterValues{idxParam} = paramValues(1,:);
            end
        end
    end
    methods(Access = private, Static = true)
        function res = createParametricItaResult(freqData, freqVector, itaCoords)
            nParams = size(freqData, 3);
            res = itaResult([1 nParams]);
            for idxParam = 1:nParams
                res(idxParam) = itaComsolResult.createItaResult(freqData(:,:,idxParam), freqVector(:, idxParam), itaCoords);
            end
        end
        function res = createItaResult(freqData, freqVector, itaCoords)
            res = itaResult(freqData, freqVector, 'freq');
            res.channelCoordinates = itaCoords;
        end
    end
    
    %% Getting expression from physics
    methods(Access = private)
        function tag = getActivePhysicsTag(obj)
            assert(~isempty(obj.mModel.physics.activeNode), 'No active physics detected')
            tag = char(obj.mModel.physics.activeNode.tag);
        end
        function pressureExpression = getPressureExpression(obj)
            pressureExpression = [obj.getActivePhysicsTag() '.p_t'];
        end
    end
    
    %% Getting dataset from study
    methods(Access = private)
        function datasetTag = getResultAtCoordsDatasetTag(obj, expression)
            %Returns the dataset used to extract results at user-defined
            %coordinates
            %   In case of acpr, datasetTag is the same as for
            %   getDirectDatasetTag() but in case of pabe, datasetTag
            %   refers to a grid dataset.
            if contains(expression, 'pabe')
                datasetTag = obj.getBemDatasetTag();
            else
                if ~contains(expression, 'acpr')
                    warning('Expression does not contain a known physics-tag. Assuming acpr physics.')
                end
                datasetTag = obj.getDirectDatasetTag();
            end
        end
        function datasetTag = getDirectDatasetTag(obj)
            solTag = obj.getMainSolverTag();
            info = mphsolinfo(obj.mModel.modelNode, 'soltag', solTag);
            datasetTag = info.dataset;
            if iscell(datasetTag)
                datasetTag = datasetTag{1};
            end
        end
        function datasetTag = getBemDatasetTag(obj)
            %Uses the first grid dataset that is derived from the main
            %solution of this study
            directDataset = obj.getDirectDatasetTag();
            gridDatasets = obj.dataset.Grids(directDataset);
            datasetTag = '';
            if isempty(gridDatasets); return; end
            datasetTag = char(gridDatasets{1}.tag);
        end
        function solTag = getMainSolverTag(obj)
            study = obj.mModel.study.activeNode;
            allSolvers = study.getSolverSequences('all');
            solTag = '';
            if isempty(allSolvers); return; end
            if obj.mModel.study.IsParametric && numel(allSolvers)>= 2
                %For a parametric sweep, the first solver is the one for a
                %single simulation, while the second contains all simulations.
                solTag = char(allSolvers(2));
            else
                solTag = char(allSolvers(1));
            end
        end
    end
    
    %% Preprocessing of coordinates
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

