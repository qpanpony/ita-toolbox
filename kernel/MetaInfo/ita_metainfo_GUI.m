function varargout = ita_metainfo_GUI(varargin)
%ITA_HEADER_GUI - Tweak Settings in itaAudio Header
%  This function gives a GUI to tweak settings in an itaAudio Object. E.g.
%   samplingrate, FFTnorm, etc.
%
%  Syntax:
%   audioObj = ita_header_GUI()
%   audioObj = ita_header_GUI(audioObj)
%
%  Example:
%   audioObj = ita_header_GUI(audioObj)
%
%   See also: mf, ita_resample.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_header_GUI">doc ita_header_GUI</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  22-Jun-2009


%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_data','itaAudio');
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 

%%
if nargin == 1
    
    pList = [];
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Samplerate in Hertz';
    pList{ele}.helptext    = 'Type in your new samplerate e.g. ''44100''. NO RESAMPLING!';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = data.samplingRate;
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'FFT Normalization';
    pList{ele}.helptext    = '''energy'' for impulse responses, ''power'' for signals';
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.default     = data.signalType;
    pList{ele}.list        = 'energy|power';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Date Created';
    pList{ele}.helptext    = 'year month day hour min sec subsec';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = data.dateCreated;
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Date Modified';
    pList{ele}.helptext    = 'year month day hour min sec subsec';
    pList{ele}.datatype    = 'int';
    pList{ele}.default     = data.dateModified;
    
    ele = length(pList) + 1;
    pList{ele}.datatype    = 'line';
    
    ele = length(pList) + 1;
    pList{ele}.description = 'Filename';
    pList{ele}.helptext    = 'Specify a filename associated with the variable. This will be used in the ita_write GUI';
    pList{ele}.datatype    = 'char';
    pList{ele}.default     = data.fileName;
    
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Tweak Header Settings of an itaAudio Object']);
    if ~isempty(pList)
        data.samplingRate = pList{1};
        data.signalType   = pList{2};
        data.dateCreated  = pList{3};
        data.dateModified = pList{4};
        data.fileName     = pList{5};
        
        %         ita_setinbase(pList{3}, data); %rsc???
    end
end


%% Add history line
data = ita_metainfo_add_historyline(data,mfilename,varargin);


%% Find output parameters
varargout(1) = {data};

%end function
end