classdef itaComsolStudy < itaComsolNode
    %itaComsolStudy Interface to the study nodes of an itaComsolModel
    %   ...
    
    %% Constructor
    methods
        function obj = itaComsolStudy(comsolModel)
            obj@itaComsolNode(comsolModel, 'study', 'com.comsol.clientapi.impl.StudyClient')
        end
    end
    
    %% Study
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
            
            freqNode.set('plist', num2str(freqVector))
        end
    end
    
    %% Booleans
    methods(Static = true, Access = private)
        function bool = isFreqStudy(study)
            [bool, ~] = itaComsolStudy.hasFeatureNode( study, 'freq' );
        end
    end
end