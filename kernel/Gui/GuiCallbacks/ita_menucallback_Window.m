function ita_menucallback_Window(hObject, event)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>
fgh        = ita_guisupport_getParentFigure(hObject);
audioObj = getappdata(fgh, 'audioObj');

defaultWinTime = [0 0.1];
try %#ok<TRYNC>
    aux = ita_plottools_cursors();
    if max(aux < 10) %probable time domain
        defaultWinTime = aux;
    end
end

ele = 1;

pList{ele}.description = 'Selected audio object';
pList{ele}.helptext    = 'Current Object in GUI figure';
pList{ele}.datatype    = 'itaAudioFix';
pList{ele}.default     = audioObj;

%
% ele = 2;
% pList{ele}.datatype    = 'line';
%
ele = length(pList) + 1;
pList{ele}.description = 'Time Window Start';
pList{ele}.helptext    = 'start at this time/sample to apply a window. If start time is greater than end time, a left sided window is applied.' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = defaultWinTime(1);

ele = length(pList) + 1;
pList{ele}.description = 'Time Window End';
pList{ele}.helptext    = 'end at this time/sample to apply a window' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = defaultWinTime(2);

ele = length(pList) + 1;
pList{ele}.description = 'Limit Units';
pList{ele}.helptext    = 'Are your limits given as samples or in seconds as time?' ;
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = 'time';
pList{ele}.list       = 'time|samples';

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';

ele = length(pList) + 1;
pList{ele}.datatype    = 'text';
pList{ele}.description    = 'Advanced Settings';

ele = length(pList) + 1;
pList{ele}.description = 'Window Type';
pList{ele}.helptext    = 'Type of window function' ;
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = '@hann';
pList{ele}.list        = ['hann|hamming|bartlett|barthannwin|blackman|' ...
    'blackmanharris|bohmanwin|chebwin|gausswin|kaiser|rectwin|taylorwin|triang|expo'];

%     @bartlett       - Bartlett window.
%     @barthannwin    - Modified Bartlett-Hanning window.
%     @blackman       - Blackman window.
%     @blackmanharris - Minimum 4-term Blackman-Harris window.
%     @bohmanwin      - Bohman window.
%     @chebwin        - Chebyshev window.
%     @flattopwin     - Flat Top window.
%     @gausswin       - Gaussian window.
%     @hamming        - Hamming window.
%     @hann           - Hann window.
%     @kaiser         - Kaiser window.
%     @nuttallwin     - Nuttall defined minimum 4-term Blackman-Harris window.
%     @parzenwin      - Parzen (de la Valle-Poussin) window.
%     @rectwin        - Rectangular window.
%     @taylorwin      - Taylor window.
%     @tukeywin       - Tukey window.
%     @triang
%
ele = length(pList) + 1;
pList{ele}.description = 'Symmetric Window';
pList{ele}.helptext    = 'Useful for acausal impulse responses. Symmetric around zero.' ;
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;

ele = length(pList) + 1;
pList{ele}.description = 'Time Crop';
pList{ele}.helptext    = 'Crop result to windowed ranged' ;
pList{ele}.datatype    = 'bool';
pList{ele}.default     = false;

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';



ele = length(pList) + 1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Time Windowing for itaAudio objects']);
if ~isempty(pList)
    result = ita_time_window(pList{1},[pList{2} pList{3}],pList{4},'windowtype',pList{5},'symmetric',pList{6},'crop',pList{7});
    setappdata(fgh, 'audioObj', result);
    
    % change to time domain
    if isempty(strfind(getappdata(fgh, 'ita_domain'), 'time'))
        setappdata(fgh, 'ita_domain', 'time in db')
    end
    
    ita_guisupport_updateGUI(fgh);
end

end