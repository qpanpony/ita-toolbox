function  output = ita_airflowResistance_measurementGUI(varargin)
%ITA_AIRFLOWRESISTANCE_MEASUREMENTGUI - GUI Frontend for airflowresistance measurements 
%  This function opens a GUI for airflow resistance measurements. The
%  function should be called with a calibrated measurement setup as input
%  parameter. If no input parameter is specified, a standard setup is
%  created, which is only valid for the following input measurement chain.
%  Measurement results are written to the workspace as itaValues, when the
%  GUI is closed.
%  
%  AD:      PreSonus Firerobo 2 hwch1-PotiLeft, Sens. @ 2Hz = 0.09 [1/V]
%  PreAmp:  B&K 2610, SN:1501530, InputGain +40 dB, Sens. @2Hz = 30 [V/V]
%  Sensor:  B&K mic 1" Type 4146 SN:256882, Sens. @ 2 Hz = 4.3e-3 [V/Pa]
%
%  An extensive documentation of the airflow resistance measurement
%  equipment can be found on \\Verdi\share\Messplaetze\Stroemungswiderstand
%
%  Syntax:
%   MS = ita_airflowResistance_makeMeasurementSetup()
%

% <ITA-Toolbox>
% This file is part of the application AirflowResistance for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%
%  Example:
%   MS = ita_airflowResistance_makeMeasurementSetup()
%   ita_airflowResistance_measurementGUI(MS)
%
%  See also:
%   ita_airflowResistance, ita_airflowResistance_makeMeasurementSetup
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_airflowResistance_makeMeasurementSetup">doc ita_airflowResistance_makeMeasurementSetup</a>

% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  12-Jan-2011 



%% getting Measurement Setup
if nargin == 1
    if ~isa(varargin{1}, 'itaMeasurementSetupSignals')
        error('Input is no MeasurementSetup')
    end
    MS2Hz = varargin{1};
else
    ita_verbose_info('No MeasurementSetup specified. Creating standard setup...', 1)
    MS2Hz = ita_airflowResistance_makeMeasurementSetup();
end


%% daten die wir später brauchen in handels speichern

itaAirFlowMachine.S_piston      =   itaValue(0.01^2 * pi, 'm^2'); % surface of piston
itaAirFlowMachine.S_probe       =   itaValue(0.05^2 * pi, 'm^2'); % surface of probe
itaAirFlowMachine.frequency     =   itaValue(2, 'Hz');            % frequency of piston
itaAirFlowMachine.x_hat         =   itaValue(1.4e-3 / 2, 'm');    % piston stroke length (peak length - NOT peak-to-peak)


h.data.Messdaten            = struct('dicke', {}, 'dichte', {}, 'R', {}, 'R_S', {}, 'r', {} , 'x_hat', {} );
h.data.aktMessung           = struct('dicke', {}, 'dichte', {}, 'R', {}, 'R_S', {}, 'r', {} , 'x_hat', {});
h.data.itaAirFlowMachine    = itaAirFlowMachine;
h.data.MS                   = MS2Hz;


%% GUI BAUEN
edWidth     = 170;  % breite edit fenster
txtWidth    = 175;  % breite text feld
s.f_h       = 600;  % höhe des fensterns
s.f_w       = 600;  % breite des fensters
s.up_mr     = 140;  % 
s.up_ak     = 150;  % 
s.up_vor    = 280;  % 


h.f = figure('Visible','off','NumberTitle', 'off', 'Position',[370,100,s.f_w,s.f_h]);
set(h.f,'Name','Airflow Resistance GUI','MenuBar', 'none')
movegui(h.f,'center')

% Messreihe
h.up_messreihe  = uipanel('Title','Messreihe','units', 'pixels', 'Position',[10  s.f_h-10-s.up_mr  s.f_w-20  s.up_mr]);
h.t_datum       = uicontrol('Style','text','parent', h.up_messreihe  ,'HorizontalAlignment', 'left','String','Datum der Messung:', 'Position',[5,s.up_mr-40 ,150,15]);
h.e_datum       = uicontrol('Style','edit','parent', h.up_messreihe ,'HorizontalAlignment', 'center','String',datestr(clock, 'dd.mm.yyyy'), 'Position',[5+txtWidth+5,s.up_mr-40,edWidth,15]);
h.t_pruefer     = uicontrol('Style','text','parent', h.up_messreihe  ,'HorizontalAlignment', 'left','String','Prüfer:', 'Position',[5,s.up_mr-60 ,150,15]);
h.e_pruefer     = uicontrol('Style','edit','parent', h.up_messreihe ,'HorizontalAlignment', 'center','String',ita_preferences('AuthorStr'), 'Position',[5+txtWidth+5,s.up_mr-60,edWidth,15]);
h.t_probenName  = uicontrol('Style','text','parent', h.up_messreihe  ,'HorizontalAlignment', 'left','String','Bezeichnung der Probe:', 'Position',[5,s.up_mr-80 ,150,15]);
h.e_probenName  = uicontrol('Style','edit','parent', h.up_messreihe ,'HorizontalAlignment', 'center','String','RPI', 'Position',[5+txtWidth+5,s.up_mr-80,edWidth,15]);
h.t_hub         = uicontrol('Style','text','parent', h.up_messreihe  ,'HorizontalAlignment', 'left','String','Kolbenamplitude [x_hat im mm]:', 'Position',[5,s.up_mr-100 ,150,15]);
h.e_hub         = uicontrol('Style','edit','parent', h.up_messreihe ,'HorizontalAlignment', 'center','String','1.4', 'Position',[5+txtWidth+5,s.up_mr-100,edWidth,15]);
% h.t_saveM     = uicontrol('Style','text','parent', h.up_messreihe  ,'HorizontalAlignment', 'left','String','Hub [Spitzenwert im mm]:', 'Position',[5,s.up_mr-100 ,150,15]);
h.c_saveM       = uicontrol('Style','checkbox','parent', h.up_messreihe ,'HorizontalAlignment', 'center','String','Jede Messung als *.mat speichern', 'Position',[10,s.up_mr-120,edWidth+150,15], 'value', 1);


% aktuelle Messung
h.up_aktuell    = uipanel('Title','Aktuelle Messung','units', 'pixels', 'Position',[10  s.f_h-10-s.up_ak-s.up_mr  s.f_w-20  s.up_ak]);
h.t_dicke       = uicontrol('Style','text','parent', h.up_aktuell  ,'HorizontalAlignment', 'left','String','Dicke des Materials [mm]:', 'Position',[5,s.up_ak-40 ,150,15]);
h.e_dicke       = uicontrol('Style','edit','parent', h.up_aktuell ,'HorizontalAlignment', 'center','String', '', 'Position',[5+txtWidth+5,s.up_ak-40,edWidth,15],'callback', {@checkDickeUndDichte} );
h.t_dichte     = uicontrol('Style','text','parent', h.up_aktuell  ,'HorizontalAlignment', 'left','String','Dichte des Materials [kg/m³]', 'Position',[5,s.up_ak-60 ,150,15]);
h.e_dichte     = uicontrol('Style','edit','parent', h.up_aktuell ,'HorizontalAlignment', 'center','String','', 'Position',[5+txtWidth+5,s.up_ak-60,edWidth,15],'callback', {@checkDickeUndDichte});

h.t_messErgLabel    = uicontrol('Style','text','parent', h.up_aktuell  ,'HorizontalAlignment', 'left','String','Strömungswiderstand R', 'FontSize', 10, 'Position',[5,s.up_ak-90 ,150,15]);
h.t_messErg         = uicontrol('Style','text','parent', h.up_aktuell ,'HorizontalAlignment', 'center','String','', 'FontSize', 15, 'Position',[5+txtWidth+5,s.up_ak-100,edWidth+50,35]);

h.p_wdh    = uicontrol('Style','pushbutton','parent', h.up_aktuell,  'String','Messung starten', 'Position',[5,s.up_ak-140 ,150,35], 'enable', 'off', 'callback', {@measure_callback});
h.p_save   = uicontrol('Style','pushbutton','parent', h.up_aktuell ,  'String','Speichern ', 'Position',[5+txtWidth+5,s.up_ak-140,edWidth,35],'enable', 'off', 'callback', {@save_callback});
h.p_cont   = uicontrol('Style','pushbutton','parent', h.up_aktuell ,  'String','on & on ', 'Position',[5+2*txtWidth+15,s.up_ak-140,edWidth,35],'enable', 'off', 'callback', {@measure_cont});

h.up_aktuell = uipanel('Title','Aktuelle Messung','units', 'pixels', 'Position',[10  s.f_h-10-s.up_ak-s.up_mr  s.f_w-20  s.up_ak]);
h.t_dicke    = uicontrol('Style','text','parent', h.up_aktuell  ,'HorizontalAlignment', 'left','String','Dicke des Materials [mm]:', 'Position',[5,s.up_ak-40 ,150,15]);

% alte messungen
h.up_vorherige = uipanel('Title','Vorherige Messung','units', 'pixels', 'Position',[10  s.f_h-10-s.up_ak-s.up_mr-s.up_vor  s.f_w-20  s.up_vor]);

header = sprintf('       R [Pa s/m^3]   R_S [Pa s/m]    r [Pa s/m^2]    Dicke [mm]   Dichte [kg/m³] ');
h.t_head   = uicontrol('Style','text','parent', h.up_vorherige  , 'FontName', 'Courier', 'HorizontalAlignment', 'left','String',header, 'Position',[5, s.up_vor-40 ,s.f_w-30,15]);
h.t_body   = uicontrol('Style','text','parent', h.up_vorherige  , 'FontName', 'Courier', 'HorizontalAlignment', 'left','String','',        'Position',[5, s.up_vor-s.up_vor+20 ,s.f_w-30,s.up_vor-60]);


guidata(h.f, h)
set(h.f, 'CloseRequestFcn', {@CloseRequestFcn})
set(h.f, 'Visible','on')

 
uiwait(h.f)   % warten bis GUI geschlossen wird


h = guidata(h.f);
% daten aus handes holen und formatieren
if ~isempty(h.data.Messdaten)
    output.d_Probe   =  itaValue([h.data.Messdaten.dicke]/1000,   'm');
    output.rho_Probe =  itaValue([h.data.Messdaten.dichte],       'kg/m^3');
    output.R         =  itaValue([h.data.Messdaten.R],            'Pa s / m^3');
    output.R_S       =  itaValue([h.data.Messdaten.R_S],          'Pa s / m');
    output.r         =  itaValue([h.data.Messdaten.r],            'Pa s / m^2');
    output.x_hat     =  itaValue([h.data.Messdaten.x_hat ]/ 1000, 'm');
else
    output = [];
end

delete(h.f)
end




function measure_cont(o,e)
    h = guidata(o);
    d = itaValue(ita_str2num(get(h.e_dicke,'string'))/1000, 'm' );
    m = itaValue(ita_str2num(get(h.e_dichte,'string')), 'kg/m^3');

    try
        while 1
            h = guidata(h.f);
            h.data.aktMessung = machMessung(h,d,m);
            guidata(o,h);
            save_callback(h.f,e)
        end
    catch

    end


end



function measure_callback(o,e)
    h = guidata(o);
    d = itaValue(ita_str2num(get(h.e_dicke,'string'))/1000, 'm' );
    m = itaValue(ita_str2num(get(h.e_dichte,'string')), 'kg/m^3');
    h.data.aktMessung = machMessung(h,d,m);

    aktMessString = sprintf('%5.2f   Pa s /m^2',h.data.aktMessung.r);
    set(h.t_messErg, 'string',aktMessString);
    set(h.p_wdh, 'String', 'Messung wiederholen');
    set(h.p_save, 'enable', 'on');
    guidata(o,h);
end


function save_callback(o,e)

    h = guidata(o);

    h.data.Messdaten(end+1) = h.data.aktMessung;
    h.data.aktMessung  = struct('dicke', {}, 'dichte', {}, 'R', {}, 'R_S', {}, 'r', {} , 'x_hat', {});

    set(h.p_wdh, 'String', 'Messung starten', 'enable', 'on');
    set(h.p_save, 'enable', 'off');

    d = h.data.Messdaten;

    idx = max(1, length(d) - 12); % gui kannnur letzten 12 messungen anzeigen

    meanAndStd = sprintf('\nMean: %12.3f %14.3f %15.3f %13.2f %13.1f\nStd:  %12.3f %14.3f %15.3f %13.2f %13.1f\n', mean([d.R]), mean([d.R_S]), mean([d.r]), mean([d.dicke]), mean([d.dichte]) , std([d.R]), std([d.R_S]), std([d.r]), std([d.dicke]), std([d.dichte]) )  ;
    body = sprintf('M %2i: %12.3f %14.3f %15.3f %13.2f %13.1f\n', [idx:length(d); d(idx:end).R; d(idx:end).R_S; d(idx:end).r; d(idx:end).dicke; d(idx:end).dichte]);
    set(h.t_body, 'string' , [body meanAndStd]);

    guidata(o,h);

end


function aktMessung = machMessung(h,d,m)
    p2Hz = h.data.MS.run;
    freqStart = itaValue(h.data.itaAirFlowMachine.frequency.value * 2^(-1/12), 'Hz');
    freqStop  = itaValue(h.data.itaAirFlowMachine.frequency.value * 2^(+1/12), 'Hz');
    
    % MAR: Consider all Frequency Bins in the intervall 2Hz+/-100Cent for RMS Calculation
    relevantFreqBinValues = (freq2value(p2Hz,freqStart.value, freqStop.value)).'; % make row vector
    RMS = sqrt(relevantFreqBinValues * relevantFreqBinValues');
    pGemessen = itaValue(RMS,'Pa');
            
    % pGemessen = itaValue(abs(p2Hz.freq2value(h.data.itaAirFlowMachine.frequency.value)), 'Pa');

    x_hat = ita_str2num(get(h.e_hub,'string'));
    h.data.itaAirFlowMachine.x_hat = itaValue(x_hat /1000 , 'm');

    [R R_S r] = ita_airflowResistance(h.data.itaAirFlowMachine, d,pGemessen);

    if get(h.c_saveM , 'value')
        try
            fileName = [get(h.e_probenName ,'String') datestr(clock, '__yyyymmdd_HHMMSS') '.mat'];
            save(fileName, 'p2Hz');
            fprintf('Messung gespeichert als %s\n', fileName)
        catch
            fprintf('Fehler beim Speichern. \n')
        end
    end

    aktMessung.dicke    = d.value *1000;
    aktMessung.dichte   = m.value;
    aktMessung.R        = R.value;
    aktMessung.R_S      = R_S.value;
    aktMessung.r        = r.value;
    aktMessung.x_hat    = x_hat;


    guidata(h.f, h)
end


% nur wenn dicke und dichte eingegeben sind, dann kann man die schalter drücken
function checkDickeUndDichte(o,e)
    h = guidata(o);
    if  ~isempty(get(h.e_dicke,'string')) &&  ~isempty(get(h.e_dichte,'string'))
        set([h.p_wdh h.p_cont], 'enable', 'on')
    else
        set([h.p_wdh h.p_cont], 'enable', 'off')
    end
end


function varargout = outputFcn(hObject, eventdata, h)
    varargout{1} = 11;
    delete(h.figure1)
end


function CloseRequestFcn(o, e)
% 	 h = guidata(o);delete(h.f)
    uiresume();
end

