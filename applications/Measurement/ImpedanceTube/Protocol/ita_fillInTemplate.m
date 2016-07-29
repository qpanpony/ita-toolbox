function ita_fillInTemplate(varargin)
%ITA_FILLINTEMPLATE - replaces keyword in *.tex file by given strings
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_fillInTemplate(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_fillInTemplate(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_fillInTemplate">doc ita_fillInTemplate</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: martin.guski@akustik.rwth-aachen.de
% Created:  13-Oct-2010

% TODO:
% - sonderzeichen ersetzten: ßÄäÜüÖö\/

%% Get Function String
% thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_template','string', 'pos2_keyValueCell', 'cell', 'pos3_outputFileName','string');
[templateFileName keyValueCell outputFileName sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% +++Body - Your Code here+++ 'input' is an audioObj and is given back

inID = fopen(templateFileName,'r');
outID = fopen(outputFileName,'w');

texTranslationCell = {'Ä' ,  '\"A'; ...
    'Ü' ,  '\"U'; ...
    'Ö' ,  '\"O'; ...
    'ä' ,  '\"a'; ...
    'ö' ,  '\"o'; ...
    'ü' ,  '\"u'; ...
    'ß ' , '\ss \'; ...
    'ß' ,  '\ss '; ...
    };

for iEntry = 1:size(keyValueCell,1)
    
    
    if isnumeric(keyValueCell{iEntry,2})
        keyValueCell{iEntry,2} = strrep(num2str(keyValueCell{iEntry,2}), '.', ',');
    else % if is string
        for iTranlation = 1:size(texTranslationCell,1)
            keyValueCell{iEntry,2} = strrep(keyValueCell{iEntry,2}, texTranslationCell{iTranlation, 1}, texTranslationCell{iTranlation, 2});
        end
        
%         idxScharfesS_vec = strfind(keyValueCell{iEntry,2}, 'ß');
%         for idxScharfesS =  idxScharfesS_vec % for every occuring ß
%            if strcmp(keyValueCell{iEntry,2}(idxScharfesS+1), ' ')
%                keyValueCell{iEntry,2} = strrep(keyValueCell{iEntry,2}, 'ß', '\ss \');
%            else
%                keyValueCell{iEntry,2} = strrep(keyValueCell{iEntry,2}, 'ß', '\ss ');
%            end
%         end
    end
end


% schneller:
% - mehere Zeilen auf einmal in strrep rein
% - wenn keyVale.. gefunden dann löschen
% - strfind statt strrep??
% - cLine isempty abfangen
%
cLine = fgetl(inID);
while ischar(cLine)
    %      disp(cLine)
    if  ~isempty(keyValueCell)
        for iKey = 1:size(keyValueCell,1)
            findIDX = strfind(cLine, keyValueCell{iKey,1} );
            if ~isempty(findIDX)
                
                currentValue = keyValueCell{iKey,2};
                
                
                
                cLine = [cLine(1:findIDX-1)  currentValue cLine(findIDX+length(keyValueCell{iKey,1}):end)];
                
                %                 keyValueCell(iKey,:) = [];
                %                 break;
            end
            
        end
    end
    fprintf(outID,'%s\n', cLine);
    cLine = fgetl(inID);
    %     disp(cLine)
end

fclose(inID);
fclose(outID);

% sample use of the ita warning/ informing function
% ita_verbose_info([thisFuncStr 'Testwarning'],0);


%% Add history line
% input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
% varargout(1) = {input};

%end function
end