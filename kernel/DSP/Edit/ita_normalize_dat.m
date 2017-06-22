function varargout = ita_normalize_dat(varargin)
%ITA_NORMALIZE_DAT - Normalize time signal to maximum 0 dBFS
% 
% This function normalizes to the maximum of all channels. Relative levels
% therefore remain the same.
%
% Syntax: itaAudio = ita_normalize_dat(itaAudio, options)
%
% Options (default): 
%  'allchannels' (false):           This normalizes each channel to its maximum
%    
% See also ita_amplify, ita_multiply_spk.
%
% Reference page in Help browser 
%        <a href="matlab:doc ita_normalize_dat">doc ita_normalize_dat</a>
%
% Autor: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  29 May 2008

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



%% 
if nargin == 0 % generate GUI
    ele = 1;
    pList{ele}.description = 'itaAudio';
    pList{ele}.helptext    = 'This is the itaAudio Object for amplification or attenuation';
    pList{ele}.datatype    = 'itaAudio';
    pList{ele}.default     = '';
    
   ele = 2;
    pList{ele}.description = 'allchannels';
    pList{ele}.helptext    = 'Normalize all channels independently';
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = false;
    
    ele = 3;
    pList{ele}.datatype    = 'line';
    
    ele = 4;
    pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
    pList{ele}.datatype    = 'itaAudioResult'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ['result_' mfilename];
    
    %call gui
    pList = ita_parametric_GUI(pList,[mfilename ' - Normalize an itaAudio object']);
    if ~isempty(pList)
        result = ita_normalize_dat(pList{1}, 'allchannels', pList{2});
        if nargout == 1
            varargout{1} = result;
        end
        ita_setinbase(pList{3}, result);
    end
    return;
end

%% Initialization and Input Parsing
narginchk(1,3);
sArgs           = struct('pos1_a','itaAudioTime','allchannels',false);
[result, sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Check for integer data
if ~isa(result.timeData,'double')
    result.timeData = double(result.timeData);
end

%% Normalize
if sArgs.allchannels
    gainApplied = nan(1, result.nChannels);
    for ch_idx = 1:result.nChannels
        gainApplied(1, ch_idx) = max(abs(result.dat(ch_idx,:)));
        result.dat(ch_idx,:)   = result.dat(ch_idx,:) ./ gainApplied(1, ch_idx);
    end
else
    gainApplied     = max(max(abs(result.timeData)));
    result.timeData = result.timeData ./ gainApplied;
end

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find Output parameter
varargout(1) = {result};
varargout(2) = {gainApplied};