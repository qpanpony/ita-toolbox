function varargout = ita_parse_arguments_gui(varargin)
%ITA_PARSE_ARGUMENTS_GUI - Parse argument list and create an automated gui
%  This function will create a dialog gui, including all elements in the
%  input struct, as would be used for ita_parse_arguments. It returns the
%  same data struct as ita_parse_arguments.
%
%  An additional button will be displayed that will export the gui creation code 
%  Using this code it should be simple to create nice and individual guis for almost all functions
%
%  Syntax:
%   sArgs = ita_parse_arguments_gui(sArgs,varargin)
%
%   See also: ita_parse_arguments, ita_parametric_GUI, ita_main_window
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_parse_arguments_gui">doc ita_parse_arguments_gui</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%% Initialization and Input Parsing
%narginchk(1,1);
sArgs        = struct('pos1_input','struct','title','Automatically generated gui');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Determine class of input arguments
allfields = fields(input);
fixedposarguments = {};
for idx = 1:numel(allfields)
    currentfield = allfields{idx};
    if numel(currentfield) > 5 && strcmpi(currentfield(1:3),'pos') && strcmpi(currentfield(5),'_') % Fixed position argument
        fieldclass{idx} = input.(currentfield); 
        fixedposarguments{end+1} = currentfield(6:end);
    else % Optional field
        fieldclass{idx} = class(input.(currentfield)); 
    end
end

%% Wrap class to datatype
for idx = 1:numel(fieldclass)
    switch fieldclass{idx}
        case {'itaAudio','itaAudioTime','itaAudioFreq'}
            fieldclass{idx} = 'itaAudio';
        case {'logical'}
            fieldclass{idx} = 'bool';
        case {'char'}
            if strcmpi(input.(allfields{idx}) , 'outputVariableName')
                fieldclass{idx} = 'itaAudioResult';
            end
    end
    
end

%% Build pList
for idx = 1:numel(fieldclass)
    pList{idx}.datatype = fieldclass{idx};
    pList{idx}.description = allfields{idx};
    pList{idx}.default = input.(allfields{idx});
    pList{idx}.helptext = '';
end

pList{end+1}.datatype = 'bool';
pList{end}.description = 'Copy gui-code to template';
pList{end}.helptext = 'The code used to create this dialog including all set defaults will be store in the file ita_template_guicode.';
pList{end}.default = false;

%% Gui
[pList, pCreateList] = ita_parametric_GUI(pList,sArgs.title);

if isempty(pList)
    varargout(1:nargout) = {[]};
    return;
end

%% Set arglist
arguments = {};
for idx = 1:numel(allfields)
    currentfield = allfields{idx};
    if numel(currentfield) > 5 && strcmpi(currentfield(1:3),'pos') && strcmpi(currentfield(5),'_') % Fixed position argument
        % No Entry
    else % Optional field
        arguments{end+1} = currentfield; %#ok<*AGROW>
    end 
    arguments{end+1} = pList{idx};
end

%% Run through parser
result = ita_parse_arguments(input,arguments);

for idx = 1:(nargout-1)
    varargout{idx} = result.(fixedposarguments{idx});
end
varargout{nargout} = result;

%end function
end