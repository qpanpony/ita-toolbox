function out = ita_plottools_zoom(currentValues, axisNames)
%ITA_PLOTTOOLS_ZOOM - GUI for zoom in itaPlots
%  GUI to zoom in ita plots. Apply Values by hitting Enter, Cancel with ESC. 
%  %
%  Syntax:
%   axisLimits = ita_plottools_zoom(axis)
%
%  See also:
%   ita_plottools_figure(), ita_str2num()
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_zoom">doc ita_plottools_zoom</a>

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  01-Mar-2011

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

if numel(currentValues) == 4
    twoYaxis = false;
elseif numel(currentValues) == 6
    twoYaxis = true;
else
    error('ita_plottools_zoom: wrong input')
end

if nargin < 2
    axisNames = {'x-axis : ', 'y-axis : ' , 'y-axis 2: '};
end

%% gui layout
edWidth             = 80;
edHeight            = 20;
horizontalSpace     = 10;
verticalSpace       = 10;
fontSize            = 11;
labelWidth          = 70;

%% calculate positions of elements in gui

figHeight   = edHeight*(4+ twoYaxis) + 6*verticalSpace;
figWidth    = edWidth*3  + 7*horizontalSpace + labelWidth ;

xPosInGUI =(0:2) .* edWidth + (1:3) .* horizontalSpace + labelWidth + horizontalSpace ;
yPosInGUI = figHeight  -((1:(4+ twoYaxis)) .* edHeight + (1:(4+ twoYaxis)) .* verticalSpace);

%% create gui
h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[370,100,figWidth,figHeight],  'WindowStyle', 'modal', 'Name','zoom' ,'MenuBar', 'none', 'nextPlot', 'new');
movegui(h.f,'center')

h.txt_xText     = uicontrol('Style','text' ,'String', axisNames{1},  'Position',    [horizontalSpace, yPosInGUI(2) , labelWidth,edHeight]);
h.txt_yText     = uicontrol('Style','text' ,'String', axisNames{2},  'Position',    [horizontalSpace, yPosInGUI(3) , labelWidth,edHeight]);

h.txt_start = uicontrol('Style','text' ,'String', 'Start:',  'Position',    [xPosInGUI(1), yPosInGUI(1) , edWidth,edHeight]);
h.txt_stop  = uicontrol('Style','text' ,'String', 'Stop:',   'Position',    [xPosInGUI(2), yPosInGUI(1) , edWidth,edHeight]);
h.txt_delta = uicontrol('Style','text' ,'String', 'Delta:',  'Position',    [xPosInGUI(3), yPosInGUI(1) , edWidth,edHeight]);

% x Values
h.ed_xStart     = uicontrol('Style','edit', 'String',num2str(currentValues(1)),              'Position',[xPosInGUI(1), yPosInGUI(2), edWidth,edHeight ],'Callback', {@GUI_update});
h.ed_xStop      = uicontrol('Style','edit', 'String',num2str(currentValues(2)),              'Position',[xPosInGUI(2), yPosInGUI(2), edWidth,edHeight ],'Callback', {@GUI_update});
h.ed_xDelta     = uicontrol('Style','edit', 'String',num2str(diff(currentValues(1:2))),      'Position',[xPosInGUI(3), yPosInGUI(2), edWidth,edHeight ],'Callback', {@GUI_update});

% y Values
h.ed_yStart     = uicontrol('Style','edit', 'String',currentValues(3),          'Position',[xPosInGUI(1), yPosInGUI(3), edWidth,edHeight ],'Callback', {@GUI_update});
h.ed_yStop      = uicontrol('Style','edit', 'String',currentValues(4),          'Position',[xPosInGUI(2), yPosInGUI(3), edWidth,edHeight ],'Callback', {@GUI_update});
h.ed_yDelta     = uicontrol('Style','edit', 'String',diff(currentValues(3:4)),  'Position',[xPosInGUI(3), yPosInGUI(3), edWidth,edHeight ],'Callback', {@GUI_update});

h.allEditHandles    = [h.ed_xStart h.ed_xStop h.ed_xDelta ; h.ed_yStart h.ed_yStop h.ed_yDelta];

if twoYaxis
    h.txt_y2Text     = uicontrol('Style','text' ,'String',axisNames{3},  'Position',    [horizontalSpace, yPosInGUI(4) , labelWidth,edHeight],  'Fontsize', fontSize, 'HorizontalAlignment', 'center');

    % y2 Values
    h.ed_y2Start     = uicontrol('Style','edit', 'String',currentValues(5),          'Position',[xPosInGUI(1), yPosInGUI(4), edWidth,edHeight ],'Callback', {@GUI_update});
    h.ed_y2Stop      = uicontrol('Style','edit', 'String',currentValues(6),          'Position',[xPosInGUI(2), yPosInGUI(4), edWidth,edHeight ],'Callback', {@GUI_update});
    h.ed_y2Delta     = uicontrol('Style','edit', 'String',diff(currentValues(5:6)),  'Position',[xPosInGUI(3), yPosInGUI(4), edWidth,edHeight ],'Callback', {@GUI_update});
    h.allEditHandles = [h.allEditHandles ; h.ed_y2Start h.ed_y2Stop h.ed_y2Delta];
end

h.pb_okay        = uicontrol('Style','pushbutton', 'String','Okay',          'Position',[figWidth/2 - edWidth - horizontalSpace,    yPosInGUI(end), edWidth,edHeight ],  'Callback', {@GUI_okay});
h.pb_cancel      = uicontrol('Style','pushbutton', 'String','Cancel',        'Position',[figWidth/2 + horizontalSpace,              yPosInGUI(end), edWidth,edHeight ],  'Callback', {@GUI_cancel});

h.lastEditedValue        = ones(1,2+twoYaxis);  % value that is constant if delta is changed

set([h.txt_xText h.txt_yText h.txt_start h.txt_stop h.txt_delta h.allEditHandles(:)'], 'Fontsize', fontSize, 'HorizontalAlignment', 'center')

set([h.f h.allEditHandles(:)'  h.pb_okay ],'KeyPressFcn',@buttonCallback)
set( h.pb_cancel, 'KeyPressFcn', @GUI_cancel)           


set(h.f  , 'CloseRequestFcn', {@GUI_CloseRequestFcn})
h.output = [];


guidata(h.f, h)
set(h.f,'Visible','on')


uiwait()

h = guidata(h.f);
out = h.output;
delete(h.f)
end


%% update values in gui
function GUI_update(s,e)
% fprintf('gui upadate callback \n');
h = guidata(s);

    [XorY  STARTorSTOPorDELTA ] = find(h.allEditHandles == s);
    try
        newValue = ita_str2num( get(s,'String'));
        set(s, 'String', num2str(newValue));
        
    catch errMSG
        set(s, 'String', '');
        ita_verbose_info(['ita_str2num: ' errMSG.message],0)
    end
    
    
    % calc new delta
    if STARTorSTOPorDELTA ~= 3
        delta = ita_str2num(get(h.allEditHandles(XorY,2),'string')  ) - ita_str2num(get(h.allEditHandles(XorY,1),'string')  );
        set(h.allEditHandles(XorY, 3), 'string', num2str(delta))
        h.lastEditedValue(XorY) = STARTorSTOPorDELTA;          % last Input value is fixed if delta is changed later
    else  % delta has been chnaged
        
        idxNewCalc = 3 - h.lastEditedValue(XorY);
        %        start = 1, stop = 2, delta = 3
        %  lastChanged  |  new2calc
        %       1       |   2 = 1 + 3    ( stop = start + delta)
        %       2       |   1 = 2 - 3
        newValue = ita_str2num(get(h.allEditHandles(XorY,h.lastEditedValue(XorY)),'string')  ) + (-1)^idxNewCalc * ita_str2num(get(h.allEditHandles(XorY,3),'string')  );
        set(h.allEditHandles(XorY, idxNewCalc), 'string', num2str(newValue))
        
    end
   
    guidata(h.f, h);
end


%% apply values
function GUI_okay(s,e)
% fprintf('okay callback \n');
    h = guidata(s);

    pause(0.01)  % time to update edit window
    alLVaues = reshape(ita_str2num(get(h.allEditHandles, 'string')), [],3);
    
    h.output = alLVaues(:,1:2);
    guidata(h.f, h);
    close(h.f)
end

%% cancel 
function GUI_cancel(s,e)
    h = guidata(s);
    close(h.f);
end


function GUI_CloseRequestFcn(s,e)
    uiresume()
%     h= guidata(s); delete(h.f);
end

function buttonCallback(s,e)
% fprintf('Button callback: %s \n', e.Key);
switch(e.Key)
    case 'return'
        h = guidata(s);
        if any(h.allEditHandles(:) == s)
            GUI_update(s,e)
        end
        GUI_okay(s,[])
    case 'escape'
        GUI_cancel(s,[])
       
end
end




