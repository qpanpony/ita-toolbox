function varargout = ita_parse_arguments(varargin)
%ITA_PARSE_ARGUMENTS - Parser for variable input arguments
%  This function is used to parse all possible input arguments by providing
%  a struct where you can put all your desired arguments.
%
%  Syntax: sOut = ita_parse_arguments(sIn, argumentcell)
%  Syntax: sOut = ita_parse_arguments(sIn, varargin)
%  Syntax: [sOut,notFound] = ita_parse_arguments(sIn, varargin)
%           Returns arguments that are not found in the struct
%  Syntax: sOut = ita_parse_arguments(sIn, varargin, startidx) - start at
%                   this index to parse varargin
%  Syntax: sOut = ita_parse_arguments(sIn) - Only checking default settings
%
%  sIn is the input struct, sOut the output struct.
%
%  DO NOT USE CAPITAL LETTERS FOR THE INPUT STRUCT !!!
%
%  Example:
%  The input struct contains all arguments as struct field followed by your
%  default settings. The ita_parse_arguments compares the argument list
%  with the struct fields and sets the value to the specified value in
%  argumentcell. The type of the input is compared to the type of the default
%  value and a warning is shown verbose mode if both types do not match.
%
%    sIn.verbose  = 'off'; %this is a bool variable
%    sIn.plotmode = 'frequency'; %user specified this
%    sIn.value    = 100;
%    sOut = ita_parse_arguments(sIn,{'verboseMode','2','value',200})
%
%    inside a function the parser will be used like this:
%    sOut = ita_parse_arguments(sIn,varargin)
%
%   If you have variables at fixed positions in your Argument list you can
%   specify this in the struct with a prefix "posX_" and X is the index in
%   your argument list. This struct name is than followed by the desired name
%   of the variable. As string for this field you can put 'itaAudio' or
%   'numeric' or 'vector'. The type is automatically checked.
%   The syntax is different for argument-value pairs! A default value has to
%   be specified instead of a type
%
%   sIn.pos1_as  = 'itaAudio';
%   sIn.pos2_num = 'integer';
%   a = ita_generate('sine',1,1000,44100,15);
%   sOut = ita_parse_arguments(sIn,{a,200});
%   [as num sOut] = ita_parse_arguments(sIn,{a,200})
%
%   You can specify directly the domain of your audio data with
%   'itaAudioTime' and 'itaAudioFrequency' for the data type. The
%   transformation will be done automatically.
%
%   To get everything to one domain append an '*': 'itaAudio*'
%
%   one more example:
%   sInit.fraction = 3;
%   sInit.peaks = [];
%   sInit.range = [];
%   sInit.figures = [1:max(findobj(0,'type','figure'))];
%   sArgs        = struct('fraction',sInit.fraction,'peaks',sInit.peaks,'range',sInit.range,'figures',sInit.figures);
%   [sArgs] = ita_parse_arguments(sArgs,varargin);
%
%   See also ita_metainfo_add_historyline.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_parse_arguments">doc ita_parse_arguments</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  25-Nov-2008

% TODO % return fixed positions in varargout if required, better memory usage!

%% Get ITA Toolbox preferences
thisFuncStr  = [upper(mfilename) ':'];

%% Get name and info of calling function
ST = dbstack;
if length(ST) > 1
    callFuncStr = [upper(ST(2).name) ':'];
else
    callFuncStr = '';
end

%% Initialization
% Number of Input Arguments
narginchk(1,3);
% Find Audio Data
if ~isstruct(varargin{1})
    error([thisFuncStr 'Input struct is missing or erroneous.'])
else
    inStruct = varargin{1};
end
if nargin >= 2 %argument list is given
    if ~iscell(varargin{2})
        error([thisFuncStr 'ArgumentCell is not a cell.'])
    elseif nargin >= 3
        Arguments = varargin{2}(varargin{3}:end);
    else
        Arguments = varargin{2};
    end
else
    Arguments = [];
end
varargout = {};
pos_num   = 0;  % needed for meaningful error messages
notFoundCell = {};

%% check field names for fixed position tokens
field_token    = fieldnames(inStruct);
killList       = [];
firstDomain    = [];
equalizeDomain = 0;
for idx = 1:length(field_token)
    token = field_token{idx};
    if numel(token) >= 5 % RSC - support for arguments shorter than 5 elements
        if strcmpi(token(1:3),'pos') && strcmpi(token(5),'_')
            pos_num      = sscanf(token(4),'%d'); %this is the fixed position number in the argument list            
            token_new    = token(6:end); %get rid off prefix
            if pos_num <= numel(Arguments) % rsc - check if enough arguments are given
                value        = Arguments{pos_num}; %get value/object
            else
                error([callFuncStr ' Not enough input arguments! (' upper(token_new) ' expected at position ' num2str(pos_num) ')']);
            end
            %check for type conformance
            if ~isempty(inStruct.(token)) %RSC - We need to make that sure first!
                compare_string = inStruct.(token);
%                 equalizeDomain = ~isequal(strfind(compare_string,'*'),0) || ~isequal(equalizeDomain,0);
                equalizeDomain = isempty(strfind(compare_string, '*')) || equalizeDomain ;
                % mpo: only remove the star if there is more than a star
                if compare_string(1)~='*'
                    compare_string = compare_string(compare_string~='*');
                end
                switch compare_string
                    case {'itaAudio'}
                        if ~isa(value,'itaAudio')
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),'itaAudio' )])
                        end
                        if equalizeDomain
                            if isempty(firstDomain)
                                if value.isFreq
                                    firstDomain = 'spk';
                                else
                                    firstDomain = 'dat';
                                end
                            elseif strcmpi(firstDomain,'dat')
                                value = ita_ifft(value);
                            else
                                value = ita_fft(value);
                            end
                        end
                    case {'itaValue'}
                        if ~isa(value,'itaValue')
                            try
                                value = itaValue(value);
                            catch
                                error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),'itaValue' )])
                            end
                        end

                    case {'itaAudioAnything'} % 
                        if ~isa(value,'itaAudio')
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),'itaAudio' )])
                        end
                        
                    case {'itaAnything'} %pdi added.
                        if isa(value,'itaSuper') || isa(value,'itaValue')
                            % everything is fine
                        else
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),'itaSuper or itaValue' )])
                        end
                        
                    case {'itaAudioTime'}
                        if ~isa(value,'itaAudio')
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),'itaAudio' )])
                        end
                        value = value.';
                        
                    case {'itaAudioFrequency'}
                        if ~isa(value,'itaAudio')
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),'itaAudio' )])
                        end
                        value = value';
                        
                        
                        
                    case {'numeric','integer','double','int'}
                        if ~isnumeric(value)
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value), 'numeric, integer, double or int' )])
                        end
                        
                    case {'vector'}
                        if ~isvector(value)
                            error([thisFuncStr callFuncStr 'Type does not match requirements, should be a vector but is:', class(value)])
                        end
                    case {'char','string'} % pdi - I need this case
                        if ~ischar(value)
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value), 'char or string' )])
                        end
                    case {'anything','*'} % rsc - I think an Option that would pass everything through would be good
                        %Just do nothing
                        
                    case {'handle'}
                        if ~ishandle(value)
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value), 'handle' )])
                        end
                    otherwise
                        if ~isa(value,compare_string)
                            error([thisFuncStr callFuncStr sprintf('Wrong input parameter at position %i (%s instead of %s) ', pos_num, class(value),compare_string )])
                        end
                end
            end
            %inStruct     = rmfield(inStruct,token); %ToDo - rsc - this takes really long. We should find a faster way!
            %% finally set type and delete from argument list
            % in struct or varargout ???
            if nargout > 1 %everything with fixed position will be put in varargout
                varargout = [varargout {value}]; %#ok<VARARG,AGROW>
            else
                inStruct.(token_new) = value;
            end
            killList = [killList pos_num]; %#ok<AGROW>
        end
    end
end

%% Delete fixed position arguments, if any
newArguments = {};
for idx = 1:length(Arguments)
    if ~any(idx == killList) %RSC - faster than ismember
        newArguments = [newArguments Arguments(idx)]; %#ok<AGROW> %append
    end
end
Arguments = newArguments;

%% parse arguments to struct
nArguments = length(Arguments);
fieldNamesInStruct = fieldnames(inStruct);
idx = 1;
notFoundArguments = 0;

while (idx <= nArguments) % go through all arguments
%     if ~ischar(Arguments{idx}), error([thisFuncStr 'The arguments specified to call "' callFuncStr '" are not correct. Check the arguments, the corresponding values and the order.']); end;
    if ~ischar(Arguments{idx})
        error([callFuncStr  thisFuncStr ' Incorrect data type at position ' num2str(idx+pos_num) ': ' upper(class(Arguments{idx})) ('. Parametername of type CHAR expected.')]); 
    end;
    idxArgumentInStruct = strcmpi(fieldNamesInStruct, Arguments{idx}); % || Arguments{idx}(2:end)
    if  any(idxArgumentInStruct) 
        if sum(idxArgumentInStruct) > 2
            error('Case Sensitivity in Struct used => not supported by ita_parse_arguments ')
        end
        fieldname = fieldNamesInStruct{idxArgumentInStruct};
        
        %is it a boolean type?
        token = inStruct.(fieldname);
        if islogical(token) || all(strcmpi(token,'on')) || all(strcmpi(token,'off')) || all(strcmpi(token,'false')) || all(strcmpi(token,'true'))
            if strcmpi(Arguments{idx}(1),'~') || strcmpi(Arguments{idx}(1),'!')
                inStruct.(fieldname) = false;
            else
                inStruct.(fieldname) = true;
            end
            if idx + 1 <= nArguments
                if strcmpi(Arguments{idx+1},'on') || strcmpi(Arguments{idx+1},'true') || islogical(Arguments{idx+1}) || (isnumeric(Arguments{idx+1}) && Arguments{idx+1} == 1)
                    if islogical(Arguments{idx+1}) %Lets check if its logical and use that argument directly
                        inStruct.(fieldname) = Arguments{idx+1};
                    end
                    idx = idx + 2; %we already switch to true
                elseif strcmpi(Arguments{idx+1},'off') || strcmpi(Arguments{idx+1},'false') || (isnumeric(Arguments{idx+1}) && Arguments{idx+1} == 0)
                    inStruct.(Arguments{idx}) = false;
                    idx = idx + 2;
                else
                    idx = idx + 1; %just go on with the next one
                end
            else
                idx = idx + 1; %rsc just go on with the next one, otherwise we will be stuck here forever
            end
        else %it is not, so it must be a pair [argument, value]
            if idx + 1 <= nArguments  %are there still enough arguments
                % check whether the incoming data is of the same type as the default value  - mli
                if ~isa(Arguments{idx+1},class(inStruct.(fieldname))) && ~any(isempty(Arguments{idx+1})) % use 'any' for multi-results
                    ita_verbose_info([thisFuncStr ,'The value specified for the argument ---',fieldname,'--- has to be of this type : ', class(inStruct.(fieldname))],2);
                end
                inStruct.(fieldname) = Arguments{idx+1};
                idx = idx + 2;
            else
                error([thisFuncStr callFuncStr 'There are not enough arguments left (for %s)'], Arguments{idx})
            end
        end
    else
        notFoundArguments = 1;
        % this handles the case that some arguments are not found
        notFoundCell{end+1} =  Arguments{idx};%#ok<AGROW>
        idx = idx + 1;
        if idx <= nArguments
            notFoundCell{end+1} =  Arguments{idx};%#ok<AGROW>
            idx = idx + 1;
        end
        
    end
end

if notFoundArguments == 1
    if nargout < 2
        error([thisFuncStr callFuncStr 'Some arguments could not be found in the struct.'],0);
    end
end


%% search for pseudo boolean - also done when no arguments specified
cFieldNames = fieldnames(inStruct);
for idx = 1:length(cFieldNames)
    if ischar(inStruct.(cFieldNames{idx}))
        if sum(strcmpi(inStruct.(cFieldNames{idx}),{'on','true'}))
            inStruct.(cFieldNames{idx}) = true;
        elseif sum(strcmpi(inStruct.(cFieldNames{idx}),{'off','false'}))
            inStruct.(cFieldNames{idx}) = false;
        end
    end
end

%% Output parameters
varargout = [varargout {inStruct} {notFoundCell}]; %#ok<VARARG>

end
