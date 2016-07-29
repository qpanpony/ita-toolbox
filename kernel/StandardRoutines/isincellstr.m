function varargout = isincellstr( varargin )
% This function compares two cell-arrays of strings
% It will also work with char inputs
%
%
% Syntax: isincellstr(reference, comparecell, Options)
%
% It returns a false if the elements of reference are not in comparecell.
% When using Option 'any' it will check if any element of reference is in comparecell
% You can choose if you prefer case sensitive compare or not with the Option 'casesensitive'
% You can also allow substring search with the Option 'substring'
%
%
%
%  Options, default: 'any',false,         - checks for any matches if reference is a cell array. otherwise all fields from reference must be in comparecell
%                    'substring',false,   - checks also for partial matches, like 'mic' in 'mic1'
%                    'casesensitive',false - if you want a case sensitive search
%                    'allow_wrong_type', true - returns false if one of both is no cellstr or empty
%
% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  15-Jan-2009

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Argument checking, parsing and conversion
narginchk(2,10);
verboseMode  = ita_preferences('verboseMode');

sArgs = struct('any',false,'substring',false,'casesensitive',false,'allow_wrong_type',true);
if nargin > 2
    sArgs = ita_parse_arguments(sArgs,varargin,3);
end

refcell = varargin{1}; %Much faster without ita_parse_arguments with fixed position fields
ccell = varargin{2};

if ischar(refcell)
    refcell = {refcell};
end
if ischar(ccell)
    ccell = {ccell};
end

if (~iscellstr(refcell) || ~iscellstr(ccell)) && ~sArgs.allow_wrong_type
   error('ISINCELLSTR: Oh Lord, I can only handle chars and cell arrays of strings, nothing else please! You can use the Option ''allow_wring_type'' if you really have to'); 
end

if ~iscellstr(refcell) || ~iscellstr(ccell)
    if ~sArgs.allow_wrong_type %If wrong type is allowed return false and throw a warning
        error('isincellstr: I can only handle cell arrays of strings');
    else
        if verboseMode
            warning('ISINCELLSTR: Wrong type!');
        end
        varargout{1} = false;
        return;
    end
end

if isempty(refcell) || isempty(ccell)
    if ~sArgs.allow_wrong_type %If wrong type is allowed return false and throw a warning
        error('isincellstr: Cells must not be empty');
    else
        if verboseMode
            warning('ISINCELLSTR: One element is empty!');
        end
        varargout{1} = false;
        return;
    end
    
    
end

%Main Part
if ~sArgs.casesensitive % if we are searching caseINsensitive, we will just make everything small
    refcell = lower(refcell);
    ccell = lower(ccell);
end


if length(refcell) > 1 %If we have more than one field in reference cell, we will recursively check all
    result = ~sArgs.any;
    
    for ref_index = 1:length(refcell)
        argcell = [fields(sArgs) struct2cell(sArgs)]; %We need to pass Options to the next iteration
        argcell = reshape(argcell.',numel(argcell),1);
        
        tmp_result = isincellstr(refcell(ref_index),ccell,argcell{:});
        
        if sArgs.any
            result = any([result tmp_result]);
        else
            result = all([result tmp_result]);
        end
    end
else
    result = false;
    for ccell_index = 1:length(ccell);
        if sArgs.substring
            tmp_result = any(strfind(ccell{ccell_index},refcell{1}));
        else
            tmp_result = any(strcmp(ccell{ccell_index},refcell{1}));
        end
        result = any([result tmp_result]);
    end
    
end


varargout{1} = result;


end