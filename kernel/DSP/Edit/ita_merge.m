function varargout = ita_merge(varargin)
%ITA_MERGE - Merge audio data sets to a single struct of audio data.
%
%  This function merges several audio data (cells or structs) to a single
%  struct.
%  The sampling rate and number of samples is set to the highest values given.
%
%  Syntax: audioData = ita_merge( audioData )
%  Syntax: audioData = ita_merge( audioData1, audioData2,...,audioDataN )
%
%  See also ita_split
%
%  Reference page in Help browser <a href="matlab:doc ita_cell2struct">doc ita_cell2struct</a>
%
%  Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
%  Created:  12-Sep-2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



if nargin == 0
    ele = 1;
    pList{ele}.description = 'First itaAudio';
    pList{ele}.helptext    = 'This is the first itaAudio for merge';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 2;
    pList{ele}.description = 'Second itaAudio';
    pList{ele}.helptext    = 'This is the second itaAudio for merge';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
    ele = 3;
    pList{ele}.datatype    = 'line';
    
    ele = 4;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Merge two itaAudio objects']);
    if ~isempty(pList)
        result = merge(pList{1},pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    
    return;

elseif isempty(varargin{1})
    varargout{1} = varargin{2};
    return
end
varargout{1} = merge(varargin{:});

