function varargout = ita_metainfo_add_historyline(varargin)
%ITA_METAINFO_ADD_HISTORYLINE - Add infos in the history line
%  This function puts the input arguments into the history line in the
%  audioObj to give a protocol of changes and data processing.
%
%  Syntax: audioObj = ita_metainfo_add_historyline(audioObj, 'historyline')
%  Syntax: audioObj = ita_metainfo_add_historyline(audioObj, 'historyline',<argumentlist of the calling function>)
%
%  Some functions deal with two or more audioObjs. In order to not lose
%  the history, you can specify the option 'withSubs' to allow subhistory
%  entries. All former audioObj histories will be saved as sub history
%  in the new history of the new variable.
%
%  Call: audioObj = ita_metainfo_add_historyline(audioObj, 'historyline',varargin,'withSubs')
%
%   See also ita_make_header
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_metainfo_add_historyline">doc ita_metainfo_add_historyline</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Sep-2008


%% 
thisFuncStr  = [upper(mfilename) ':'];     

%% Initialization
withSubs     = false; %true for subhistory entries
% Number of Input Arguments
narginchk(1,4);
if ischar(varargin{end}) && strcmpi(varargin{end},'withsubs')
    withSubs = true;
end
% Find Audio Data
if isa(varargin{1},'itaSuper')
    audioObj = varargin{1};
else
    error([thisFuncStr 'Where is my audio object.'])
end
% this is the function name:
historyline = varargin{2};
sub_historylines = {};
if nargin >= 3 % the function had some input arguments
    arguments = varargin{3};
    argumentStr = '('; %
    if iscell(arguments)
        for idx = 1:length(arguments)
            if isa(arguments{idx},'itaSuper') && withSubs % struct (Placeholder)
                token = 'audioObj';
                sub_historylines{length(sub_historylines)+1} = arguments{idx}.history; %#ok<AGROW>
            elseif isa(arguments{idx},'itaSuper') 
                token = 'audioObj';
            elseif isa(arguments{idx},'itaCoordinates')
                token = 'itaCoordinates';
            elseif iscell(arguments{idx}) % cell (Placeholder)
                token = 'cellVAR';
            elseif isa(arguments{idx},'itaValue')
                token = num2str(arguments{idx});
                if numel(arguments{idx}.value) > 1
                    token = token(1,:);
                end
            elseif ischar(arguments{idx})
                token = ['''' arguments{idx} ''''];
            elseif isstruct(arguments{idx}) % cell (Placeholder)
                token = 'structVAR';
            elseif length(arguments{idx}) >= 2 % multiple numerical values with []
                token = '[';
                for j = 1:length(arguments{idx})
                    token = [token num2str(arguments{idx}(j)) ' '];
                end
                token = [token(1:end-1) ']'];
            elseif isnatural(arguments{idx})
                token = num2str(arguments{idx});
            elseif ishandle(arguments{idx})
                token = ['@' 'handle']; % function handle as a string
            elseif isa(arguments{idx},'function_handle')
                token = ['@' func2str(arguments{idx})]; % function handle as a string
            elseif isnumeric(arguments{idx})
                token = num2str(arguments{idx}); % single numbers as they are
            else
                token = '';
            end
            argumentStr = [argumentStr token  ',']; %#ok<AGROW>
        end
        argumentStr(max(2,length(argumentStr))) = ')';
    elseif ischar (arguments) %argument is a string
        if ischar(arguments)
            argumentStr = ['(' arguments ')'];
        end
    elseif isa(arguments,'itaSuper')
        argumentStr = '(audioObj)';
       
        if withSubs
            sub_historylines{length(sub_historylines)+1} = arguments.history; %#ok<AGROW>
        end
    end
    
    dateLine = '';
    
    try 
       dateLine = datestr(now); 
       dateLine  = [dateLine ' - '];
    catch e
        
    end
    
    historyline = [dateLine historyline argumentStr];
end

%% Add the history line ?�pdi:faster
if withSubs %pdi - when subs are added, get rid of the old history first, everything goes to the subs!
    for idx = 1:length(audioObj)
        audioObj(idx).history = [];
        audioObj(idx).history{1} = historyline;
    end
else
    for idx = 1:length(audioObj)
        audioObj(idx).history{end+1} = historyline;
    end
end

%% Add sublines
for idx = 1:length(sub_historylines)
    for jdx = 1:length(audioObj)
        audioObj(jdx).history{end+1} = sub_historylines{idx};
    end
end

%% Find output parameters
varargout(1) = {audioObj};

%end function
end