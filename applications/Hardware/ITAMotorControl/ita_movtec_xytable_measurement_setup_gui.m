function varargout = ita_movtec_xytable_measurement_setup_gui(varargin)
%ITA_MOVTEC_XYTABLE_MEASSUREMENT_SETUP_GUI - this gui is used to
%   fine-calibrate the measurement middle point.
%   with a hit of one of the buttons the xy-table moves about 1mm in this
%   direction.

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Gregor Powarzynski -- Email: gregor.powarzynski@rwth-aachen.de
% Created:  02-Feb-2010
thisFuncStr  = [upper(mfilename) ':'];


%% building the figure
vs = 30;        % Versatz zu Rändern und anderen Bereichen
vsKl= 10;       % Abstand zwischen Nachbarelementen
pbH=50;         % PushButton Höhe
pbW=100;        % PushButton Breite
midH=100;       % heigth of middle
midW=100;       % weidth of middle

% figure Höhe ist AnzahlButton vertikal+ (AnzahlButton-1)*versatzkl+
% 3*versatz + midH + versatzkl;
fH= 5 * pbH + 4 * vsKl + 3*vs + midH + vsKl;
% figure Breite ist Anzahl PB horiz +
% (AnzahlButton-1)*versatzkl+midW+versatzkl +2*versatz;
fW= 4 * pbW + 3*vsKl + midW+vsKl + 2*vs;

mW = 1920;      % Monitor weidth
mH = 1280;      % Monitor heigth
f = figure('Visible','off','Position',[(mW-fW)/2,(mH-fH)/2,fW,fH]);

%% PushButtons
move10nx = uicontrol('Style','pushbutton', 'String','x -10mm',...
    'Position',[vs,(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
    'Callback',{@move10nxbutton_Callback} );
move1nx = uicontrol('Style','pushbutton', 'String','x -1mm',...
    'Position',[(vs+vsKl+pbW),(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
    'Callback',{@move1nxbutton_Callback} );
move1px = uicontrol('Style','pushbutton', 'String','x +1mm',...
    'Position',[(vs+3*vsKl+2*pbW+midW),(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
    'Callback',{@move1pxbutton_Callback} );
move10px = uicontrol('Style','pushbutton', 'String','x +10mm',...
    'Position',[(vs+4*vsKl+3*pbW+midW),(2*vs+2*vsKl+3*pbH+(midH-pbH)/2),pbW,pbH],...
    'Callback',{@move10pxbutton_Callback} );

move10ny = uicontrol('Style','pushbutton', 'String','y -10mm',...
    'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+pbH),pbW,pbH],...
    'Callback',{@move10nybutton_Callback} );
move1ny = uicontrol('Style','pushbutton', 'String','y -1mm',...
    'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+2*pbH+vsKl),pbW,pbH],...
    'Callback',{@move1nybutton_Callback} );
move1py = uicontrol('Style','pushbutton', 'String','y +1mm',...
    'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+3*pbH+3*vsKl+midH),pbW,pbH],...
    'Callback',{@move1pybutton_Callback} );
move10py = uicontrol('Style','pushbutton', 'String','y +10mm',...
    'Position',[(vs+2*pbW+2*vsKl+(midW-pbW)/2),(2*vs+4*pbH+4*vsKl+midH),pbW,pbH],...
    'Callback',{@move10pybutton_Callback} );

calibrate = uicontrol('Style','pushbutton', 'String','calibrate',...
    'Position',[(vs+2*pbW+2*vsKl),(2*vs+3*pbH+3*vsKl+midH/2-vsKl/2),midW,midH/2-vsKl/2],...
    'Callback',{@calibratebutton_Callback});
goMid = uicontrol('Style','pushbutton', 'String','Go to middle',...
    'Position',[(vs+2*pbW+2*vsKl),(2*vs+3*pbH+2*vsKl),midW,midH/2-vsKl/2],...
    'Callback',{@gotomidbutton_Callback});
goMidLaser = uicontrol('Style','pushbutton', 'String','Go to lasermiddle',...
    'Position',[vs,(2*vs+2*pbH+vsKl),pbW,pbH],...
    'Callback',{@gotomidlaserbutton_Callback});

%% left corner
cW = 2*pbW+vsKl;
cH = 2*pbH+vsKl;
rtext = uicontrol('Style','text','String','mm away from reference:',...
    'Position',[(vs+pbW+vsKl/2-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+2*cH/3),cW,cH/3]);
xrtext = uicontrol('Style','text','String','X: ',...
    'Position',[(vs+pbW+vsKl/2-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+cH/3),cW,cH/3]);
yrtext = uicontrol('Style','text','String','Y: ',...
    'Position',[(vs+pbW+vsKl/2-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2),cW,cH/3]);

%% right corner
cW = 2*pbW+vsKl;
cH = 2*pbH+vsKl;
ctext = uicontrol('Style','text','String','mm away from calibration point:',...
    'Position',[(vs+3*pbW+3.5*vsKl+midW-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+2*cH/3),cW,cH/3]);
xctext = uicontrol('Style','text','String','X: ',...
    'Position',[(vs+3*pbW+3.5*vsKl+midW-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2+cH/3),cW,cH/3]);
yctext = uicontrol('Style','text','String','Y: ',...
    'Position',[(vs+3*pbW+3.5*vsKl+midW-cW/2), (2*vs+4*pbH+3.5*vsKl+midH-cH/2),cW,cH/3]);

%% bottom
xvs = uicontrol('Style','edit','String','x-versatz...',...
    'Position',[vs,vs,pbW,pbH]);
yvs = uicontrol('Style','edit','String','y-versatz...',...
    'Position',[(vs+vsKl+pbW),vs,pbW,pbH]);
xvs = uicontrol('Style','edit','String','x-versatz...',...
    'Position',[vs,vs,pbW,pbH]);
startVs = uicontrol('Style','pushButton','String','Go for it!',...
    'Position',[(vs+2*vsKl+2*pbW),vs,pbW,pbH],...
    'Callback',{@gobutton_Callback});

%% ita toolbox logo with grey bg
a_im = importdata(which('ita_toolbox_logo.png'));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [fW-vs-180+10 vs-10 180 42]);

%% initialize gui
set(f,'Name','fine calibrating the xy-table!')
global ita_xytable_calibrated;
% set the text-fields
global ita_xytable_calibrated_x;
global ita_xytable_calibrated_y;
global ita_xytable_reference_x;
global ita_xytable_reference_y;
set(xrtext,'String', ['X: ' num2str(ita_movtec_xytable_steps2mm('x',...
    ita_xytable_reference_x))]);
set(yrtext,'String', ['Y: ' num2str(ita_movtec_xytable_steps2mm('y',...
    ita_xytable_reference_y))]);
set(xctext,'String', ['X: ' num2str(ita_movtec_xytable_steps2mm('x',...
    ita_xytable_reference_x-ita_xytable_calibrated_x))]);
set(yctext,'String', ['X: ' num2str(ita_movtec_xytable_steps2mm('x',...
    ita_xytable_reference_y-ita_xytable_calibrated_y))]);

%% edit Callbacks
    function gobutton_Callback(source,eventdata)
        xvsMm=str2num(get(xvs, 'String'));
        yvsMm=str2num(get(yvs, 'String'));
        if ~isempty(xvsMm)
            ita_movtec_xytable_move('x', xvsMm);
            wait4motor();
        end
        if ~isempty(yvsMm)
            ita_movtec_xytable_move('y', yvsMm);
            wait4motor();
        end
        
    end


%%  pushButton Callbacks
    function move10nxbutton_Callback(source,eventdata)
        ita_movtec_xytable_move('x',-10);
        wait4motor();
    end
    function move1nxbutton_Callback(source,eventdata)
        ita_movtec_xytable_move('x',-1);
        wait4motor();
    end
    function move1pxbutton_Callback(source,eventdata)
        ita_movtec_xytable_move('x',1);
        wait4motor();
    end
    function move10pxbutton_Callback(source,eventdata)
        ita_movtec_xytable_move('x',10);
        wait4motor();
    end
    function move10nybutton_Callback(source,eventdata)
        ita_movtec_xytable_move('y',-10);
        wait4motor();
    end
    function move1nybutton_Callback(source,eventdata)
        ita_movtec_xytable_move('y',-1);
        wait4motor();
    end
    function move1pybutton_Callback(source,eventdata)
        ita_movtec_xytable_move('y',1);
        wait4motor();
    end
    function move10pybutton_Callback(source,eventdata)
        ita_movtec_xytable_move('y',10);
        wait4motor();
    end
    function calibratebutton_Callback(source,eventdata)
        ita_xytable_calibrated_x=ita_xytable_reference_x;
        ita_xytable_calibrated_y=ita_xytable_reference_y;
        ita_xytable_calibrated=true;
        wait4motor();
    end

    function gotomidbutton_Callback(source,eventdata)
        ita_movtec_xytable_move('x',ceil(112-ita_movtec_xytable_steps2mm('x',ita_xytable_reference_x)), 'speed', 75);
        % wait4motor();
        ita_movtec_xytable_move('y',ceil(321-ita_movtec_xytable_steps2mm('y',ita_xytable_reference_y)), 'speed', 75);
        wait4motor();
    end

    function gotomidlaserbutton_Callback(source,eventdata)
        ita_movtec_xytable_move('x',ceil(101-ita_movtec_xytable_steps2mm('x',ita_xytable_reference_x)), 'speed', 75);
        % wait4motor();
        ita_movtec_xytable_move('y',ceil(335-ita_movtec_xytable_steps2mm('y',ita_xytable_reference_y)), 'speed', 75);
        wait4motor();
    end

    function wait4motor(source,eventdata)
        ita_movtec_xytable_wait();
        % update position
        set(xrtext,'String', ['X: ' num2str(ita_movtec_xytable_steps2mm('x',...
            ita_xytable_reference_x))]);
        set(yrtext,'String', ['Y: ' num2str(ita_movtec_xytable_steps2mm('y',...
            ita_xytable_reference_y))]);
        set(xctext,'String', ['X: ' num2str(ita_movtec_xytable_steps2mm('x',...
            ita_xytable_reference_x-ita_xytable_calibrated_x))]);
        set(yctext,'String', ['Y: ' num2str(ita_movtec_xytable_steps2mm('y',...
            ita_xytable_reference_y-ita_xytable_calibrated_y))]);
    end

set(f,'Visible','on')
%EOF
end
