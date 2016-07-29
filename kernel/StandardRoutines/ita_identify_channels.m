function varargout = ita_identify_channels(varargin)
%ITA_IDENTIFY_CHANNELS - identify channels
%  This function searches for keywords in channel names to identify a channel.
%  First parameter has to be itaAudio, itaResult or a cell of strings. The
%  following parameters are the keywords. A cell of keywords is interpreted as
%  a group of keywords. Only one word of the group has to match to identify a
%  channel. The search is NOT case sensitive. 
%
%  Syntax:
%   idxOfChannels = ita_identify_channels(audioObjIn, keyWords)
%
%
%  Example:
%   idxOmni            = ita_identify_channels(measurement, 'omni')
%   [idxOmni idxEigth] = ita_identify_channels(measurement, 'omni', 'eight')
%   resCell            = ita_identify_channels(measurement, 'omni', 'eight')
%   ...                = ita_identify_channels(measurement, 'ke4', {'links' 'left' 'esquerda'}, {'right' 'rechts' 'direito'})
%   ...                = ita_identify_channels(measurement.channelNames, ... )
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_identify_channels">doc ita_identify_channels</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  09-Sep-2011


%% Initialization and Input Parsing

if isa(varargin{1}, 'itaSuper')
    chNameCell = varargin{1}.channelNames;
elseif iscell(varargin{1})
    chNameCell = varargin{1};
    if ~all(cellfun(@ischar, chNameCell))
        error('Cell must contain strings!')
    end
else
    error('First input variable has to be ITASUPER or CELL')
end


chNameCell = cellfun(@lower, chNameCell, 'UniformOutput', false);
nChannels  = numel(chNameCell);


keyWords = varargin(2:end);
nKeywordGroups = numel(keyWords);
result = cell(nKeywordGroups,1);

for iKgroup = 1:nKeywordGroups
    currKeyWords = keyWords{iKgroup};
    
    if ischar(currKeyWords)     % only one word in this group
        currKeyWords = {currKeyWords};
    else                        % a keyword group ( more than one keyword ) to identify one channel
        if ~all(cellfun(@ischar, currKeyWords))
            error('Keyword cell must contain strings!')
        end
        currKeyWords = cellfun(@lower,currKeyWords , 'UniformOutput', false);
    end
    
    nKeywords = numel(currKeyWords);
    foundKeyWord = false(nChannels, 1);
    for iCh =1:nChannels
        for iKeyWord = 1:nKeywords % for every keyword in keyword group
            foundKeyWord(iCh) = foundKeyWord(iCh) || ~isempty(strfind(chNameCell{iCh}, currKeyWords{iKeyWord})) ;
        end
    end
    result{iKgroup} = find(foundKeyWord);
    
end

%% Set Output
if nKeywordGroups == nargout 
    varargout = result;
elseif nargout == 1
    varargout(1) = {result};
else
    error('wrong number of output parameters! ')
end

%end function
end