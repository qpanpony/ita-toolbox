function ita_play_gui(varargin)
%ITA_PLAY_GUI - playback GUI for itaAudios
%  This function creates a GUI for playback of itaAudios.
%
%  Syntax:
%    ita_play_gui(audioObjIn, audioObjIn, ....)
%    ita_play_gui(multiInstance)
%    ita_play_gui(..., buttonNamesCellString)
%
%
%  Examples:
%   ita_play_gui   % all itaAudios in workspace
%
%   demoLouder  = ita_demosound;
%   demoLoud    = ita_demosound/10;
%   demoNomal   = ita_demosound/100;
%   ita_play_gui(demoLouder, demoLoud, demoNomal)
%
%   multiInstanceVar = [demoLouder, demoLoud, demoNomal];
%   ita_play_gui(multiInstanceVar)
%
%    ita_play_gui(multiInstanceVar, ita_sprintf('demo button %i', 1:3))
%
%  See also:
%   ita_play
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_play_gui">doc test_mgu_compareSounds</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  28-Jul-2011

% For some more help read the wiki available at
% (https://www.akustik.rwth-aachen.de/ITA-Toolbox/wiki)


%% read input sounds

nInputs = nargin;


if  nInputs && iscellstr(varargin{end})
    buttonNames = varargin{end};
    varargin(end) = [];
    nInputs = nInputs -1;
else
    buttonNames = [];
end


if isempty(varargin)                % get all itaAudios from workspace
    % all itaAudios form Workspace
    whosOut = evalin('base', 'whos');
    allAudios = [];
    allNames  = [];
    for iVar = 1:numel(whosOut)
        if strcmp(whosOut(iVar).class, 'itaAudio')
            currAudio = reshape(evalin('base', whosOut(iVar).name),1,[]);
            
            allAudios = [allAudios currAudio];
            if numel(currAudio) == 1
                allNames  = [allNames {whosOut(iVar).name}];
            else
                allNames  = [allNames ita_sprintf('%s(%i)', whosOut(iVar).name, 1:numel(currAudio))'];
            end
        end
    end
elseif     numel(varargin) == 1 && isa(varargin{1}, 'itaAudio') && numel(varargin{1}) > 1   % calling with multi instance of itaAudio
    
    allAudios = varargin{1};
    displayName = inputname(1);
    if isempty(displayName)
        displayName = 'Input Audio';
    end
    allNames = ita_sprintf('%s(%i)',displayName, 1:numel(varargin{1}))';
    
else     % every input one audio
    allAudios = [];
    allNames  = [];
    for iInput = 1:nInputs
        allAudios = [allAudios varargin{iInput}];
        
        tmpInputName = {inputname(iInput)};
        if isempty(tmpInputName{1})
            tmpInputName = ita_sprintf('input audio %i',iInput );
        end
        allNames  = [allNames tmpInputName];
    end
    
end


% try to use button names form user
if ~isempty(buttonNames)
    if numel(allAudios) == numel(buttonNames)
        allNames = buttonNames;
    else
        ita_verbose_info(sprintf('size of input audios (%i) and size of button names (%i). using default names',numel(allAudios),  numel(buttonNames)),0)
    end
end



%% anzahl und anordung der knöpfe
nAudios = numel(allAudios);

if ~nAudios
    error('no itaAudios in workspace')
end


nColumns = ceil(sqrt(nAudios));
nRows    = round(sqrt(nAudios));

%% generate GUI

buttonSize      = [200 35];
defaultSpace    = 10;


figSize =  [defaultSpace + [nRows nColumns] .*(defaultSpace+ buttonSize)];



h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[0 0 figSize], 'Name','ita_play_gui: Compare itaAudios', 'MenuBar', 'none',  'nextPlot', 'new');
movegui(h.f,'center')

h.pbArray = zeros(nAudios,1);
for iRow = 1:nRows
    for iColumn = 1:nColumns
        linIndex =  (iRow-1)*nColumns +iColumn;
        if linIndex > nAudios
            break
        end
        h.pbArray(linIndex) =  uicontrol('Style','pushbutton', 'String', allNames{linIndex} ,'Position', [defaultSpace + ([iRow-1 nColumns-iColumn]) .* ([buttonSize]+defaultSpace) buttonSize  ] , 'Callback', {@btnCallback});
    end
end

h.data.allAudios = allAudios;
h.data.allNames = allNames;


set([h.f; h.pbArray], 'KeyPressFcn', @keyPressCallback)

guidata(h.f, h)
set(h.f,'Visible','on')



%end function
end


function btnCallback(s, e)
h = guidata(s);

iAudio = find(h.pbArray == s);
% h.data.allAudios(iAudio).play;
ita_portaudio(h.data.allAudios(iAudio), 'block', false)
end



function keyPressCallback(s,event)

idxPlay = str2num(event.Character);
h = guidata(s);

if ~ isempty(idxPlay) && idxPlay <= numel(h.data.allAudios) && isreal(idxPlay)
    oldColor = get(h.pbArray(idxPlay), 'backgroundColor');
    set(h.pbArray(idxPlay), 'backgroundColor', [0.9 .7 .7]);
    ita_portaudio(h.data.allAudios(idxPlay), 'block', false)
    set(h.pbArray(idxPlay), 'backgroundColor', oldColor);
else
    fprintf('\t invalid key: %s\n', event.Character)
end
%
end


function fadeButton(buttonHandle)
h = guidata(buttonHandle);




end


