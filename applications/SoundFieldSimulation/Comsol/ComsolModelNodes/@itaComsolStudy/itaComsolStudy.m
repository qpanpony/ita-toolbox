classdef itaComsolStudy < itaComsolNode
    %itaComsolStudy Interface to the study nodes of an itaComsolModel
    %   Allows to run simulations from Matlab and adjust certain study
    %   parameters such as the frequency vector.
    %   
    %   Furthermore it is possible to run a parametric sweep from Matlab:
    %   Therefore, a series of simulations where a Comsol parameter is a
    %   changed for each simulation is executed independently. The results
    %   are stored in different files. This reduces the amount of memory
    %   compared to running a parametric sweep from Comsol.
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolStudy">doc itaComsolStudy</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>
    
    %% Constructor
    methods
        function obj = itaComsolStudy(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'study', 'com.comsol.clientapi.impl.StudyClient')
        end
    end
    
    %% Run Simulation
    methods
        function Run(obj, showProgress)
            %Runs the active Study. Optionally a bool can be passed that
            %to activate a progress window
            if nargin == 1; showProgress = false; end
            
            study = obj.activeNode;
            assert(~isempty(study), 'No active study is set yet')
            
            com.comsol.model.util.ModelUtil.showProgress(showProgress);
            study.run();
        end
    end
    
    %% Parametric Sweep from Matlab
    methods
        function varargout = RunParametricSweep(obj, parameterName, parameterValues, varargin)
            %Runs multiple simulation from Matlab varying one Comsol
            %paramter and storing the results in .mph files
            %   Mendatory inputs:
            %   parameterName: Identifyer of the parameter [char row vector]
            %   parameterValues: Array of values for the paramter [Numeric vector or cellstring]
            %   
            %   Options(default):
            %   parameterUnit (''): Unit used for all parameter values [char row vector]
            %   resultFolder (same as original model): Folder where results are to be stored [char row vector]
            %   showProgress (false): Enable/disable Comsol UI that shows simulation progress [boolean]
            %   
            %   Output:
            %   resultPath: Folder where result files are stored
            %   
            %   The simulation results are stored in .mph files with
            %   filenames based on the original filename and the parameter
            %   values (e.g. C:\modelPath\modelName_parameterName_-3[s]_result.mph).
            
            %---Parse Options---
            sArgs = struct('parameterUnit','','resultFolder',[],'showProgress', false);
            sArgs = ita_parse_arguments(sArgs,varargin);
            parameterUnit = sArgs.parameterUnit;
            resultFolder = sArgs.resultFolder;
            showProgress = sArgs.showProgress;
            
            %---Check data types---
            if (ischar(parameterValues) && isrow(parameterValues))
                parameterValues = {parameterValues};
            elseif (isnumeric(parameterValues) && isvector(parameterValues))
                parameterValues = sprintfc('%d',parameterValues); %Conversion to cell-string
            end
            assert(ischar(parameterName) && isrow(parameterName), 'parameterName must be a char row vector');
            assert(iscellstr(parameterValues), 'parameterValues must be a numeric array or a cell string');
            assert(isempty(parameterUnit)|| ( ischar(parameterUnit) && isrow(parameterUnit) ),...
                'parameterUnit must be a char row vector');
            
            %---Check other stuff---
            study = obj.activeNode;
            assert(~isempty(study), 'No active study is set yet')
            assert(obj.mModel.parameter.Exists(parameterName), 'Given parameter is not part of the Comsol model')
            assert(~isempty(obj.modelNode.getFilePath), 'No filepath associated with this model. Save it first.')
            
            com.comsol.model.util.ModelUtil.showProgress(showProgress);
            
            unitParameterExt = '';
            if ~isempty(parameterUnit); unitParameterExt = [ '[' parameterUnit ']']; end
            
            %---init folder and filenames---
            [folder, name] = fileparts(char(obj.modelNode.getFilePath));
            if isempty(resultFolder); resultFolder = folder; end
            baseModelName = [name '_' parameterName '_'];
            baseModelPath = fullfile(resultFolder, baseModelName);
            
            disp('Comsol - Parametric Sweep: Start!')
            disp('---------------------------------')
            for idxValue = 1:numel(parameterValues)
                parameterValue = [parameterValues{idxValue} unitParameterExt];
                obj.mModel.parameter.Set(parameterName, parameterValue);
                
                disp(['Comsol - Parametric Sweep: Starting simulation ' num2str(idxValue) ' of ' num2str(numel(parameterValues)) '.'])
                obj.Run(showProgress);
                disp(['Comsol - Parametric Sweep: Finished simulation ' num2str(idxValue) '.'])
                
                resultFilename = [baseModelPath parameterValue '_result.mph'];
                mphsave(obj.modelNode, resultFilename);
                
                %TODO: Clean up results to free memory?
            end
            disp('---------------------------------')
            disp('Comsol - Parametric Sweep: Done!')
            disp('The results can be found in the following folder:')
            disp(resultFolder)
            
            if nargout; varargout{1} = resultFolder; end
        end
    end
    
    %% Frequency Vector
    methods
        function SetAllFrequencyVectors(obj, freqVector)
            %Sets the frequency vector for all frequency domain studies.
            assert(isnumeric(freqVector) && isrow(freqVector), 'Input must be a numeric row vector')
            
            studies = obj.All();
            idxFreqStudies = false(size(studies));
            for idxStudy = 1:numel(studies)
                idxFreqStudies(idxStudy) = obj.isFreqStudy(studies{idxStudy});
            end
            
            freqStudies = studies(idxFreqStudies);
            if isempty(freqStudies); warning([class(obj) ': No frequency domain study found']); end
            for idxFreqStudy = 1:numel(freqStudies)
                obj.setFrequencyVectorOfGivenStudy(freqStudies{idxFreqStudy}, freqVector)
            end
        end
        function SetFrequencyVector(obj, freqVector)
            %Sets the frequency vector for the active study. Throws an error
            %if this is not a frequency domain study.
            assert(~isempty(obj.activeNode), 'No active study found')
            obj.setFrequencyVectorOfGivenStudy(obj.activeNode, freqVector);
        end
    end
    methods(Static = true, Access = private)
        function setFrequencyVectorOfGivenStudy(study, freqVector)
            %Sets the frequency vector for the given study. Throws an error
            %if this is not a frequency domain study.
            assert(isa(study, 'com.comsol.clientapi.impl.StudyClient'), 'First input must be a Comsol Study node')
            assert(isnumeric(freqVector) && isrow(freqVector), 'Second input must be a numeric row vector')
            
            [freqNodeDefined, freqNode] = itaComsolStudy.hasFeatureNode( study, 'freq' );
            if ~freqNodeDefined; error('Given Comsol study is no frequency study'); end
            
            freqNode.set('plist', num2str(freqVector));
        end
    end
    
    %% Booleans
    methods(Static = true, Access = private)
        function bool = isFreqStudy(study)
            [bool, ~] = itaComsolStudy.hasFeatureNode( study, 'freq' );
        end
    end
end