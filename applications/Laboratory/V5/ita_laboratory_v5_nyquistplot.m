function ita_laboratory_v5_nyquistplot(varargin)
% Erstellt einen Nyquistplot in dem die Frequenz für die Lausprecherkurve
% (varargin) variiert werden kann. Messung erfolgt über die ita_toolbox_gui
% unter V5-> Ortskurvenschreiber. Funktion erhält die gemessene Impedanz im
% itaAudio-Format.

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% input
if nargin ==1 && isa(varargin{1},'itaAudio')
    impLabLS = varargin{1};
    figHeadline = 'Ortskurve Festgebremst';
elseif nargin ==2 && isa(varargin{1}, 'itaAudio') && isa(varargin{2}, 'char')
    impLabLS = varargin{1};
    figHeadline = varargin{2};
else
    error('rbo_nyquistplot:Input','Please use your measured Impedance!')
end
%.......................................................................
%% DATA

h.Z_real = real(impLabLS.freqData);
h.Z_imag = imag(impLabLS.freqData);
idx = find(impLabLS.freqVector>0,1,'first');
h.minFreq = impLabLS.freqVector(idx);
h.maxFreq = max(impLabLS.freqVector);
h.Freq = impLabLS.freqVector;
h.impLabLS = impLabLS;
h.idxU = 1;

%.......................................................................
%% GUI
scrennSize = get(0,'ScreenSize');
centerOfGUI = scrennSize(3:4)/2;        %central point of screen
pointH = 700;pointW = 700;
layout.figSize          = [ pointW pointH];    %size of figure
layout.defaultSpace     = 20;
layout.compTxtHeight    = 12;           %standart text height
layout.compBTxtHeight   = 10;           %standart button text height
layout.bSize           = [120 20];      %standart button size
%layout.bPosition       = [layout.figSize(1)/2-170 layout.figSize(2) - 2*layout.defaultSpace-layout.compTxtHeight-layout.bSize(2) layout.bSize; layout.figSize(1)/2+170-120 layout.figSize(2)-2*layout.defaultSpace-layout.compTxtHeight-layout.bSize(2) layout.bSize];
layout.bgColor=[0.8 0.8 0.8];       %standart background color
layout.bgColor2=[1 1 1];       %standart background color 2
layout.fontColor='blue';            %standart text color

%.......................................................................
%figure
h.f = figure('Visible','on',...
    'NumberTitle', 'off',...
    'Position',[centerOfGUI(1)-layout.figSize(1)/2,...
    centerOfGUI(2)-layout.figSize(2)/2,...
    layout.figSize],...
    'Name', figHeadline,...
    'MenuBar', 'none',...
    'Color', layout.bgColor);

%.......................................................................
spaceBottom = pointW -50;
h.txtHeadline = uicontrol('Style','text',...
    'String', figHeadline ,...
    'FontWeight','bold',...
    'ForegroundColor','black',...
    'FontSize',15,...
    'Position',[0,...%left
    spaceBottom,...%bottom
    layout.figSize(1),...%weight
    2*layout.compTxtHeight],...%height
    'horizontalAlignment','center',...
    'BackgroundColor',layout.bgColor);
%.......................................................................
spaceBottom = pointW -120;linkerBund = 70;
h.Z_imag = imag(impLabLS.freqData);
str = {['f = ' num2str(h.minFreq) ' Hz'], ['real(Z) = ' num2str(round(h.Z_real(1)*10)/10) ' Ohm'],...
    ['imag(Z) = ' num2str(round(h.Z_imag(1)*10)/10) ' Ohm']};
h.txtInfo = uicontrol('Style','text',...
    'String',str,...
    'FontWeight','bold',...
    'ForegroundColor','black',...
    'FontSize',10,...
    'Position',[linkerBund ,...%left
    spaceBottom,...%bottom
    layout.figSize(1)/3,...%weight
    4*layout.compTxtHeight],...%height
    'horizontalAlignment','left',...
    'BackgroundColor',layout.bgColor);
%.......................................................................
h.plotarea = axes('Units','points','position',[linkerBund-15   50  450  350]);
xlim(h.plotarea ,[min(h.Z_real)*1.1, max(h.Z_real)*1.1]);
ylim(h.plotarea ,[min(h.Z_imag)*1.1, max(h.Z_imag)*1.1]);
%xlim(h.plotarea ,[-5 100]);ylim(h.plotarea ,[-50, 50]);

grid on;hold on;
plot(h.plotarea,h.Z_real(1),h.Z_imag(1),...
    'LineStyle','none','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);
hold off
xlabel('\Re\{Z\}');ylabel('\Im\{Z\}')
%.......................................................................
str = 'Frequency manipulator: ';
linkerBund = linkerBund+170;
spaceBottom = spaceBottom+25;
h.txtSlider = uicontrol('Style','text',...
    'String',str,...
    'FontWeight','bold',...
    'ForegroundColor','black',...
    'FontSize',10,...
    'Position',[linkerBund ,...%left
    spaceBottom,...%bottom
    layout.figSize(1)/3,...%weight
    2*layout.compTxtHeight],...%height
    'horizontalAlignment','left',...
    'BackgroundColor',layout.bgColor);
%.......................................................................
spaceBottom = spaceBottom-20;
h.freqSlide = uicontrol('Style', 'slider',...
    'Value',h.minFreq,...
    'Position', [linkerBund  spaceBottom 400 20],...
    'min', h.minFreq,...
    'max', h.maxFreq,...
    'SliderStep', [1/h.maxFreq,0.1],...
    'Callback', @freq_slider);
%.......................................................................
set(h.f,'Visible','on');
set(h.f,'MenuBar','figure')
set(h.f,'ToolBar','figure')
set(h.f,'NumberTitle','on')
%.......................................................................
uimenu(h.f, 'Label', 'Save Nyquist', 'Callback', @saveNyquist); 
guidata(h.f, h);

%% Initialization Plot
freq_slider_init(h.freqSlide,h)

end

%==========================================================================
function saveNyquist (hObject, event)

h = guidata(hObject);
hfig = h.f;

[filename, pathname] = uiputfile('Image File *.jpg', 'Save Nyquist as', 'C:\Users\praktikum\Desktop\Ortskurve');
if isempty(filename) || isempty(pathname)
    return
end

style = getappdata(hfig,'Exportsetup');
if isempty(style)
  try
    style = hgexport('readstyle','Default');
  catch
    style = hgexport('factorystyle');
  end
end

hgexport(h.f, [pathname, filename], style, 'Format', 'jpeg');


end

function freq_slider_init(hObj, h)

freqTmp = get(hObj,'Value');
freqOld = get(hObj,'UserData');
if  isempty(freqOld) 
    set(hObj,'UserData',round(freqTmp));   
else
    if freqOld< freqTmp
        freqTmp =ceil(freqTmp);
    else
        freqTmp =fix(freqTmp);
    end
    if freqTmp ==0, freqTmp = 1; end
    if freqTmp >= h.impLabLS.freqVector(end)
        freqTmp = h.impLabLS.freqVector(end);
    end
    set(hObj,'Value',freqTmp);
    set(hObj,'UserData',round(freqTmp));
end
idxCurrent = find(h.impLabLS.freqVector> freqTmp,1,'first');

freqL = 0;
freqU = 500;
[~,idxL] = min(abs(h.Freq-freqL));
[~,idxU] = min(abs(h.Freq-freqU));

cla;
hold on;
plot(h.plotarea,h.Z_real(idxL:idxU),h.Z_imag(idxL:idxU),...
'o','MarkerEdgeColor','g', 'MarkerFaceColor',[.49 1 .63],'MarkerSize',5);
plot(h.plotarea,h.Z_real(idxCurrent),h.Z_imag(idxCurrent),...
    'LineStyle','none','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);
axis equal
hold off

ue = {['f = ' num2str(round(freqTmp)) ' Hz'], ['real(Z) = ' num2str(round(h.Z_real(idxU)*10)/10) ' Ohm'],...
    ['imag(Z) = ' num2str(round(h.Z_imag(idxU)*10)/10) ' Ohm']};
set(h.txtInfo,'String',ue);

%Change Maximum of FreqSlider
h.maxFreq = h.impLabLS.freqVector(idxU)+1;
set(h.freqSlide, 'max', h.maxFreq)

h.idxU = idxU;
guidata(hObj, h);

end

function freq_slider(hObj,event) 

h = guidata(hObj);

freqTmp = get(hObj,'Value');
freqOld = get(hObj,'UserData');
if  isempty(freqOld) 
    set(hObj,'UserData',round(freqTmp));   
else
    if freqOld< freqTmp
        freqTmp =ceil(freqTmp);
    else
        freqTmp =fix(freqTmp);
    end
    if freqTmp ==0, freqTmp = 1; end
    if freqTmp >= h.maxFreq
        freqTmp = h.maxFreq;
    end
    set(hObj,'Value',freqTmp);
    set(hObj,'UserData',round(freqTmp));
end
idxCurrent = find(h.impLabLS.freqVector> freqTmp,1,'first');



idxU = h.idxU;
idxL = 1;

cla;
hold on;
plot(h.plotarea,h.Z_real(idxL:idxU),h.Z_imag(idxL:idxU),...
'o','MarkerEdgeColor','g', 'MarkerFaceColor',[.49 1 .63],'MarkerSize',5);
plot(h.plotarea,h.Z_real(idxCurrent),h.Z_imag(idxCurrent),...
    'LineStyle','none','Marker','o','MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);
axis equal
hold off

ue = {['f = ' num2str(round(freqTmp)) ' Hz'], ['real(Z) = ' num2str(round(h.Z_real(idxCurrent)*10)/10) ' Ohm'],...
    ['imag(Z) = ' num2str(round(h.Z_imag(idxCurrent)*10)/10) ' Ohm']};
set(h.txtInfo,'String',ue);

guidata(hObj, h);
end
