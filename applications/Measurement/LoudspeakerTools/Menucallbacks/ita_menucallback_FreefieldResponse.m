function ita_menucallback_FreefieldResponse(varargin)

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

MS = ita_guisupport_measurement_get_global_MS;
uiwait(msgbox('Measurement will now be performed','Start Measurement'));
result = MS.run;

answer = questdlg('Determine the measurement distance automatically?','Measurement Distance');

if ~isempty(answer) && strcmpi(answer,'yes')
    [dummy, shiftTime] = ita_time_shift(result); %#ok<ASGLU>
    defaultDistance      = -shiftTime*double(ita_constants('c'));
else
    defaultDistance = 1;
end

ele = 1;
pList{ele}.description = 'Measurement Distance';
pList{ele}.helptext    = 'Distance in meters between loudspeaker and microphone';
pList{ele}.datatype    = 'double';
pList{ele}.default     = defaultDistance;


ele = ele+1;
pList{ele}.description = 'Measured on ground';
pList{ele}.helptext    = 'Was the microphone placed on the ground? Correct with -6.02 dB';
pList{ele}.datatype    = 'bool';
pList{ele}.default     = true;

ele = ele+1;
pList{ele}.description = 'Loudspeaker Impedance';
pList{ele}.helptext    = 'Nominal impedance of the loudspeaker in Ohm';
pList{ele}.list        = [2,4,6,8];
pList{ele}.datatype    = 'int_popup';
pList{ele}.default     = 8;


ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI


%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Freefield Response']);
if ~isempty(pList)
    if pList{2}
        amp = 0.5;
    else
        amp = 1;
    end
    VoltPerWatt = itaValue(sqrt(pList{3}),'V');
    result = result*amp*pList{1}*VoltPerWatt;
    result.pf
%     fgh        = ita_guisupport_getParentFigure(hObject);
%     setappdata(fgh, 'audioObj', result);
%     ita_guisupport_updateGUI(fgh);
else
    error('Operation cancelled by user');
end
end