function result = ita_read_unv(varargin)
%ITA_READ_UNV - returns the data of unv-files
%  This function is the superfunction for all ita_readunv... functions and
%  accepts the name of a unv-file as an input argument.
%  The result is a cell array with the result for each unv type.
%
%  Syntax:
%   audioObjOut = ita_read_unv(string)
%
%  Example:
%   result = ita_read_unv(unvFilename)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_readunv">doc ita_read_unv</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  29-Sep-2009

if nargin == 0
    result{1}.extension = '.unv';
    result{1}.comment = 'Universal files (*.unv)';
    result{2}.extension = '.uff';
    result{2}.comment = 'Universal files (*.uff)';
    return
end

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,9);
sArgs = struct('pos1_unvFilename','string','interval',[],'isTime',false,'channels',[],'metadata',false);
[unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin);  

%%
[UffDataSets, Info] = readuff(unvFilename, 'InfoOnly'); %#ok<ASGLU>
dsTypes = unique(Info.dsTypes);
dsTypesShort = setdiff(dsTypes,[151 164]); % will be read with 15 and 2411

if numel(dsTypesShort) > 0
    if numel(dsTypesShort > 1) && all(ismember([2411 2412],dsTypesShort))
        result = itaMesh(unvFilename);
    else
        lastDSType = -1;
        result = [];
        prefix = [thisFuncStr 'data type is '];
        % for each dataset get the corresponding result
        for i = 1:numel(dsTypesShort)
            currentDSType = dsTypesShort(i);
            if currentDSType ~= lastDSType
                switch currentDSType
                    case {15,2411}
                        comment = 'Mesh Coordinates';
                        ita_verbose_info([prefix comment ', calling ITA_READUNV2411'],2);
                        tmpResult = ita_readunv2411(unvFilename);
                    case 2412
                        comment = 'Mesh Elements';
                        ita_verbose_info([prefix comment ', calling ITA_READUNV2412'],2);
                        tmpResult = ita_readunv2412(unvFilename);
                    case 2414
                        comment = 'Response For All Mesh Nodes Per Frequency';
                        ita_verbose_info([prefix comment ', calling ITA_READUNV2414'],2);
                        tmpResult = ita_readunv2414(unvFilename);
                    case {2435,2452,2467,2477}
                        comment = 'Mesh Group';
                        ita_verbose_info([prefix comment ', calling ITA_READUNVGROUPS'],2);
                        tmpResult = ita_readunvgroups(unvFilename);
                    case 58
                        comment = 'Frequency Response Per Mesh Node';
                        ita_verbose_info([prefix comment ', calling ITA_READUNV58'],2);
                        tmpResult = ita_readunv58(unvFilename);
                    otherwise
                        ita_verbose_info([thisFuncStr 'sorry, this type (' num2str(currentDSType) ') has not been implemented yet!'],1);
                        tmpResult = [];
                end
                if ~isempty(tmpResult)
                    if iscell(tmpResult)
                        for r=1:numel(tmpResult)
                            tmpResult{r}.fileName = unvFilename;
                            tmpResult{r}.comment = comment;
                        end
                        result = [result,tmpResult]; %#ok<AGROW>
                    else
                        tmpResult.fileName = unvFilename;
                        tmpResult.comment = comment;
                        result = [result,{tmpResult}]; %#ok<AGROW>
                    end
                end
                lastDSType = currentDSType;
            end
        end
        
        if numel(result) == 1
            result = result{1};
        end
    end
else
    error([thisFuncStr 'no valid dataset found!']);
end

%end function
end