function varargout = ita_revchamber_aborptionmeasurement_GUI(varargin)
% ITA_REVCHAMBER_ABSORPTIONMEASUREMENT_GUI - should help with measurements of absorption coefficients in the
% reverberation chamber.
%
% Syntax:   ita_revchamber_aborptionmeasurement_GUI(MS)
%       or  ita_revchamber_aborptionmeasurement_GUI(MS, refMeasName, objMeasName)
%
% with: MS = ita measurement setup transferfunction
%       refMeasName, objMeasName = strings that specify names for
%       outputfiles to be written

% <ITA-Toolbox>
% This file is part of the application RevChamberAbsMeas for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ita_revchamber_aborptionmeasurement_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ita_revchamber_aborptionmeasurement_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

end %function

function ita_revchamber_aborptionmeasurement_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

if numel(varargin)~=1 && numel(varargin)~=3
    delete(hObject);
    error('Error: No input argument! Specify ita_measurement_setup_transferfunction as input argument.');
elseif numel(varargin)==1     
    handles.output = hObject;
    handles.MS   = varargin{1};
    handles.data = {'object', 123.4, 178, 0, 0, 20, 0.5, 1013};
    handles = get_parametric_gui_roomData(handles);
    handles.refNum = 1;
    handles.objNum = 1;
    handles.refMeasDone = 0;
    handles.objMeasDone = 0;
    handles.refMeasName = [];
    handles.objMeasName = [];
elseif numel(varargin)==3     
    handles.output = hObject;
    handles.MS   = varargin{1};
    handles.data = {'object', 123.4, 178, 0, 0, 20, 0.5, 1013};
    handles = get_parametric_gui_roomData(handles);
    handles.refNum = 1;
    handles.objNum = 1;
    handles.refMeasDone = 0;
    handles.objMeasDone = 0;
    handles.refMeasName = varargin{2};
    handles.objMeasName = varargin{3};    
end
guidata(hObject, handles);

end %function

function figure1_CloseRequestFcn(hObject, eventdata, handles)

if (handles.objMeasDone == 1) && (numel(handles.objMeas)>=1)
    objMeasurements = handles.objMeas(1);
    if numel(handles.objMeas)>1;
        for m=2:numel(handles.objMeas)
            objMeasurements = merge(objMeasurements, handles.objMeas(m));
        end
    end
    objMeasurements.userData = {handles.data{1}, handles.data{2}, handles.data{3}, handles.data{4}, handles.data{5}};
    
    disp('Saving measurements with absorption object in room.');
    if isempty(handles.objMeasName)
        ita_write(objMeasurements , ['.\' handles.data{1} '_measurements_w_absorption_object.ita']);
    else
        ita_write(objMeasurements , ['.\' handles.objMeasName]);
    end
end

if (handles.refMeasDone == 1) && (numel(handles.refMeas)>=1)

    refMeasurements = handles.refMeas(1);
    if numel(handles.refMeas)>1;
        for m=2:numel(handles.refMeas)
            refMeasurements = merge(refMeasurements, handles.refMeas(m));
        end
    end
    refMeasurements.userData = {handles.data{1}, handles.data{2}, handles.data{3}, handles.data{4}, handles.data{5}};

    disp('Saving measurements without absorption object in room.');
    if isempty(handles.refMeasName)
        ita_write(refMeasurements , ['.\' handles.data{1} '_measurements_without_absorption_object.ita']);
    else
        ita_write(refMeasurements , ['.\' handles.refMeasName]);
    end
else
    % Do nothing, no measurements to save
end

delete(hObject);

end %function

function varargout = ita_revchamber_aborptionmeasurement_GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
end %function

function refMeas_button_Callback(hObject, eventdata, handles)
disableButtons(handles)

handles = get_parametric_gui_otherData(handles);
    
handles.refMeas(handles.refNum) = handles.MS.run;
for m=1:handles.refMeas(handles.refNum).nChannels
    handles.refMeas(handles.refNum).channelUserData{m} = [handles.data{6}, handles.data{7}, handles.data{8}];
end
handles.refMeasDone = 1;

write_to_workspace(handles,'ref');
handles.refNum = handles.refNum+1;
set(handles.refNum_text,'String',num2str(handles.refNum));
enableButtons(handles)
guidata(hObject, handles);

end %function

function objMeas_button_Callback(hObject, eventdata, handles)
disableButtons(handles)

handles = get_parametric_gui_otherData(handles);

handles.objMeas(handles.objNum) = handles.MS.run;
for m=1:handles.objMeas(handles.objNum).nChannels
    handles.objMeas(handles.objNum).channelUserData{m} = [handles.data{6}, handles.data{7}, handles.data{8}];
end
handles.objMeasDone = 1;

write_to_workspace(handles,'obj');
handles.objNum = handles.objNum+1;
set(handles.objNum_text,'String',num2str(handles.objNum));
enableButtons(handles)
guidata(hObject, handles);

end %function

function write_to_workspace(handles,ref_obj)
switch ref_obj
    case 'ref'
        assignin('base',[strrep(handles.data{1},' ','_') '_ref_' int2str(handles.refNum)],handles.refMeas(handles.refNum));
    case 'obj'
        assignin('base',[strrep(handles.data{1},' ','_') '_obj_' int2str(handles.objNum)],handles.objMeas(handles.objNum));
end

end %function

function handles = get_parametric_gui_roomData(handles)
pList = [];

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = 'Measurement data';
pList{ele}.color = 'black';

ele = numel(pList)+1;
pList{ele}.description = 'Object name';
pList{ele}.helptext    = 'Please don''t use any special characters';
pList{ele}.datatype    = 'char';
pList{ele}.default     = handles.data{1};

ele = numel(pList)+1;
pList{ele}.description = ['Empty Room volume in m' char(179)];
pList{ele}.helptext    = 'Volume of the reverberation chamber in m^3';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{2});

ele = numel(pList)+1;
pList{ele}.description = ['Empty Room surface in m' char(178)];
pList{ele}.helptext    = 'Surface of the reverberation chamber in m^2';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{3});

ele = numel(pList)+1;
pList{ele}.description = ['Object volume in m' char(179)];
pList{ele}.helptext    = 'Volume of the object whose absorption coefficient shall be measured in m^3';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{4});

ele = numel(pList)+1;
pList{ele}.description = ['Object surface in m' char(178)];
pList{ele}.helptext    = 'Surface of the object whose absorption coefficient shall be measured in m^2';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{5});

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

dataFromGUI = ita_parametric_GUI(pList,'');
handles.data{1} = dataFromGUI{1};
handles.data{2} = dataFromGUI{2}; 
handles.data{3} = dataFromGUI{3}; 
handles.data{4} = dataFromGUI{4}; 
handles.data{5} = dataFromGUI{5}; 

set(handles.objMeas_button,'String',handles.data{1});
set(handles.objMeas_button,'TooltipString',['Measure roomacoustic transfer function with ' handles.data{1} ' in the reverberation chamber']);

end %function

function handles = get_parametric_gui_otherData(handles)
pList = [];

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = 'Measurement data';
pList{ele}.color = 'black';

ele = numel(pList)+1;
pList{ele}.description = 'Room temperature in °C';
pList{ele}.helptext    = 'Room temperature in °C';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{6});

ele = numel(pList)+1;
pList{ele}.description = 'Relative humidity (0-1)';
pList{ele}.helptext    = 'Relative humidity between 0 and 1 (NOT IN %)';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{7});

ele = numel(pList)+1;
pList{ele}.description = 'Adiabatic Pressure in mBar';
pList{ele}.helptext    = 'Adiabatic Pressure in mBar';
pList{ele}.datatype    = 'double';
pList{ele}.default     = num2str(handles.data{8});

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

dataFromGUI = ita_parametric_GUI(pList,'');
handles.data{6} = dataFromGUI{1};
handles.data{7} = dataFromGUI{2}; 
handles.data{8} = dataFromGUI{3}; 

end %function

function disableButtons(handles)
set(handles.objMeas_button,'Enable','off');
set(handles.refMeas_button,'Enable','off');

end %function
 
function enableButtons(handles)
set(handles.objMeas_button,'Enable','on');
set(handles.refMeas_button,'Enable','on');

end %function
