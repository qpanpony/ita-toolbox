function varargout = ita_questiondlg(question, title, allButtons)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Josefa Oberem -- Email: josefa.oberem@rwth-aachen.de
% Created:  06-Mar-2012




%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
% sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
% [input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

%% read input sounds and check correctness
if nargin<3
    error('MATLAB:ita_questdlg:TooFewArguments', 'Too few arguments for ITA_QUESTDLG');
end
if nargin>4
    error('MATLAB:ita_questdlg:TooManyInputs', 'Too many input arguments');
end
if ischar(question) == 0
    error('MATLAB:ita_questdlg:WrongInputArguments', 'Undefined function for input arguments of type char.');
end
if ischar(title) == 0
    error('MATLAB:ita_questdlg:TooManyInputs', 'Undefined function for input arguments of type char.');
end
if iscell(allButtons) == 0
    error('MATLAB:ita_questdlg:TooManyInputs', 'Undefined function for input arguments of type cell.');
end

%% anzahl und anordung der knöpfe
nButtons = numel(allButtons);

buttonsPerColumn = 5;
nColumns = min(nButtons, buttonsPerColumn);
nRows    = ceil(nButtons/buttonsPerColumn);

% Damit keine Spalte mit nur einem Eintrag vorkommt
if nRows*buttonsPerColumn-nButtons == buttonsPerColumn-1
    buttonsPerColumn = buttonsPerColumn + 1;
    nColumns = min(nButtons, buttonsPerColumn);
    nRows    = ceil(nButtons/buttonsPerColumn);
end

%Bei großer Anzahl mehr Buttons in eine Spalte
if nButtons >= 30
    buttonsPerColumn = 10;
    nColumns = min(nButtons, buttonsPerColumn);
    nRows    = ceil(nButtons/buttonsPerColumn);
end


%% generate GUI

buttonSize      = [200 35];
defaultSpace    = 10;


figSize =  [defaultSpace + [nRows nColumns+2] .*(defaultSpace+ buttonSize)];


h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[0 0 figSize], 'Name', title, 'MenuBar', 'none');
movegui(h.f,'center')

% Platzierung der Frage
if nButtons > 10
    h.question =  uicontrol('Style','text', 'String', question, 'Fontsize', 14, 'Backgroundcolor', get(h.f, 'color'), 'Position', [defaultSpace + ([0 nColumns]) .* (buttonSize+defaultSpace) buttonSize(1)*2 buttonSize(2)*2  ] );
else
    h.question =  uicontrol('Style','text', 'String', question, 'Fontsize', 14, 'Backgroundcolor', get(h.f, 'color'), 'Position', [defaultSpace + ([0 nColumns]) .* (buttonSize+defaultSpace) buttonSize(1) buttonSize(2)*2  ] );
end

%Platzierung der Buttons
h.pbArray = zeros(nButtons,1);
for iRow = 1:nRows
    for iColumn = 1:nColumns
        linIndex =  (iRow-1)*buttonsPerColumn +iColumn;
        if linIndex > nButtons
            break
        end
        h.pbArray(linIndex) =  uicontrol('Style','pushbutton', 'String', allButtons{linIndex} ,'Position', [defaultSpace + ([iRow-1 nColumns-iColumn]) .* (buttonSize+defaultSpace), buttonSize  ] , 'Callback', {@btnCallback});
    end
end

h.data.allButtons = allButtons;

guidata(h.f, h)
set(h.f,'Visible','on')

uiwait()
if ishandle(h.f)
    h = guidata(h.f);
    varargout = {h.outputNr};
    close(h.f)
else % user closed window
    varargout = {0};
end
end

function btnCallback(s, e)
h = guidata(s);

iAudio = find(h.pbArray == s);

h.outputNr = iAudio;
guidata(h.f, h);

uiresume()
end
