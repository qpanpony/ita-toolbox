function varargout = ita_readunvgroups(varargin)
%ITA_READUNVGROUPS - read groups from unv-files
%  This function uses a modified readuff version to read the group
%  information in a unv-file and returns an itaMeshGroup object.
%
%  Syntax:
%   itaMeshGroup = ita_readunvgroups(String)
%
%  Example:
%   group = ita_readunvgroups('groupfilename.unv')
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_readunvgroups">doc ita_readunvgroups</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  04-Jan-2010 

%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];

%% Initialization and Input Parsing
sArgs        = struct('pos1_unvFilename','string');
[unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%%  'result' is an itaAudio object and is given back 
ita_verbose_info('ITA_READUNVGROUPS:reading ...',2);
[DataSet,Info,errmsg] = readuff_groups(unvFilename); % use a special readuff to get group datasets
err2435 = 0;
err2452 = 0;
err2467 = 0;
err2477 = 0;
if ~isempty(find(Info.dsTypes==2435, 1))
    err2435 = Info.errcode(Info.dsTypes==2435);
elseif ~isempty(find(Info.dsTypes==2452, 1))
    err2452 = Info.errcode(Info.dsTypes==2452); 
elseif ~isempty(find(Info.dsTypes==2467, 1))
    err2467 = Info.errcode(Info.dsTypes==2467); 
elseif ~isempty(find(Info.dsTypes==2477, 1))
    err2477 = Info.errcode(Info.dsTypes==2477); 
end

allIsWell = (err2435 < 1) && (err2452 < 1) && (err2467 < 1) && (err2477 < 1);

if allIsWell
    i = 1;
    while (DataSet{i}.dsType ~= 2435) && (DataSet{i}.dsType ~= 2452) && (DataSet{i}.dsType ~= 2467) && (DataSet{i}.dsType ~= 2477) % only process group datasets
        if i == numel(DataSet)
            error([thisFuncStr 'found no valid DataSet']);
        end
        i = i+1;
    end
    DataSet = DataSet{i};
    offset = 1;
    result = cell(1,numel(DataSet.IDGroup));
    for i=1:numel(DataSet.IDGroup)
        result{i} = itaMeshGroup(DataSet.NumElements(i),DataSet.GroupName{i});
        result{i}.groupID = DataSet.IDGroup(i);
        result{i}.ID = DataSet.Tag(offset:offset+DataSet.NumElements(i)-1);
        switch DataSet.TypeCode(offset)
            case 7
                result{i}.type = 'nodes';
            case 8
                result{i}.type = 'shell elements';
            otherwise
        end
        offset = offset + DataSet.NumElements(i);
    end
    
    if numel(result) == 1
        result = result{1};
    end
else
    error(['ita_readunvgroups::error ' errmsg{:}]);
end

%% Set Output
varargout(1) = {result}; 

%end function
end