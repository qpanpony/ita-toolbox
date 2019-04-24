classdef itaComsolBatch < itaComsolNode
    %itaComsolBatch Interface to the batch nodes of an itaComsolModel and
    %to run models in batch mode
    %   Note, that this class also provides static functions to create and
    %   execute windows command lines to simulate Comsol models from batch.
    %   
    %   See also itaComsolModel, itaComsolNode
    %   
    %   Reference page in Help browser
    %       <a href="matlab:doc itaComsolBatch">doc itaComsolBatch</a>
    
    % <ITA-Toolbox>
    % This file is part of the ITA-Toolbox. Some rights reserved.
    % You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
    % </ITA-Toolbox>

        %% Constructor
    methods
        function obj = itaComsolBatch(comsolModel)
            %Expects an itaComsolModel as input
            obj@itaComsolNode(comsolModel, 'batch', 'com.comsol.clientapi.impl.BatchListClient')
        end
    end
    
    %% Batch Commands
    methods
        function Run(obj, outputFolder, waitForResult)
            %Runs this model as batch using the system command
            %   The user has to specify an outputFolder where the model
            %   with the result is stored. Optionally, it can be specified
            %   to wait for the simulation to finish.
            %   
            %   Inputs (default):
            %   outputFolder            Folder that stores simulation result and logfile [char row vector]
            %   waitForResult (false)   Indicates whether Matlab waits for the simulation to finish or not
            assert(ischar(outputFolder) && isrow(outputFolder), 'First input must be a char row vector')
            if nargin == 2; waitForResult = false; end
            if isnumeric(waitForResult); waitForResult = logical(waitForResult); end
            assert(islogical(waitForResult) && isscalar(waitForResult), 'Second input must be a logical scalar')
            
            batchCmd = obj.GetCommandLine(outputFolder, waitForResult);
            system(batchCmd);
        end
        function batchCmd = GetCommandLine(obj, outputFolder, waitForResult)
            %Returns the command sequence for the windows command line to
            %execute the simulation of this model as batch
            %   The user has to specify an outputFolder where the model
            %   with the result is stored. Optionally, it can be specified
            %   to wait for the simulation to finish.
            %   
            %   Inputs (default):
            %   outputFolder            Folder that stores simulation result and logfile [char row vector]
            %   waitForResult (false)   Indicates whether the system waits for the simulation to finish or not [boolean]
            assert(ischar(outputFolder) && isrow(outputFolder), 'First input must be a char row vector')
            if nargin == 2; waitForResult = false; end
            if isnumeric(waitForResult); waitForResult = logical(waitForResult); end
            assert(islogical(waitForResult) && isscalar(waitForResult), 'Second input must be a logical scalar')
            
            activeStudy = obj.mModel.study.activeNode;
            inputfile = char(obj.modelNode.getFilePath());
            assert(~isempty(inputfile), 'No file corresponding to this model found.')
            assert(~isempty(activeStudy), 'No active study node found.')
            studyTag = char(activeStudy.tag);
            
            batchCmd = obj.CreateBatchCommand(inputfile, outputFolder, studyTag, waitForResult);
        end
    end
    
    methods(Static = true)
        function status = CreateAndExecuteBatchCommand(modelFile, outputFolder, studyTag, waitForResult)
            %Creates a comsol batch command given the input file, an
            %output folder and the tag of the study to be simulated and
            %executes it.
            %   Optionally, it can be specified whether the system waits
            %   for the simulation to finish or not.
            if nargin == 3; waitForResult = false; end
            batchCmd = itaComsolBatch.CreateBatchCommand(modelFile, outputFolder, studyTag, waitForResult);
            status = system(batchCmd);
        end
        function batchCmd = CreateBatchCommand(modelFile, outputFolder, studyTag, waitForResult)
            %Creates a comsol batch command given the input file, an
            %output folder and the tag of the study to be simulated.
            %   Optionally, it can be specified whether the system waits
            %   for the simulation to finish or not.
            assert(ischar(modelFile) && isrow(modelFile), 'modelFile must be a char row vector')
            [~, name, extension] = fileparts(modelFile);
            assert(strcmp(extension, '.mph'), 'Given file must be an .mph file')
            assert(logical(exist(modelFile, 'file')), 'Given model file does not exist.')
            
            assert(ischar(outputFolder) && isrow(outputFolder), 'studyTag must be a char row vector.')
            assert(logical(exist(outputFolder, 'dir')), 'Directory for data output does not exist')
            
            assert(ischar(studyTag) && isrow(studyTag), 'studyTag must be a char row vector.')
            
            if nargin == 3; waitForResult = false; end
            if isnumeric(waitForResult); waitForResult = logical(waitForResult); end
            assert(islogical(waitForResult) && isscalar(waitForResult), 'waitForResult input must be a logical scalar')
            
            outputfile = fullfile(outputFolder, [name '_solved' extension]);
            logfile = fullfile(outputFolder, 'batch.log');
            
            batchCmd = itaComsolBatch.createBatchCmd(modelFile, outputfile, studyTag, logfile, waitForResult);
        end
    end
    
    methods(Access = private, Static = true)
        function batchCmd = createBatchCmd(inputfile, outputfile, studyTag, logfile, waitForResult)
            batchCmd = 'comsolbatch';
            batchCmd = itaComsolBatch.addCmdProperty(batchCmd, 'inputfile', inputfile);
            batchCmd = itaComsolBatch.addCmdProperty(batchCmd, 'outputfile', outputfile);
            batchCmd = itaComsolBatch.addCmdProperty(batchCmd, 'study', studyTag);
            batchCmd = itaComsolBatch.addCmdProperty(batchCmd, 'batchlog', logfile);
            %Note:
            %"&" at the end of the cmd lets the batch cmd be called in a different thread.
            %"exit" is called to close the cmd window after the simulation has finished
            if ~waitForResult; batchCmd = [batchCmd ' && exit &'] ;end
        end
        
        function batchCmd = addCmdProperty(batchCmd, property, value)
            if isempty(value) || isempty(property); return; end
            property = strrep(property, '-', '');
            batchCmd = [batchCmd ' -' property ' ' value];
        end
    end
end

