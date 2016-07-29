function ita_menucallback_CombineNearfieldAndFarfieldMeasurements(varargin)

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ele = 1;
pList{ele}.description = 'Farfield Result';
pList{ele}.helptext    = 'This is the farfield measurement';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = ele+1;
pList{ele}.description = 'Nearfield Result';
pList{ele}.helptext    = 'This is the nearfield measurement';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Port Result (optional)';
pList{ele}.helptext    = 'This is the port measurement';
pList{ele}.datatype    = 'itaAudio';
pList{ele}.default     = '';


ele = ele+1;
pList{ele}.description = 'Crossover Frequency';
pList{ele}.helptext    = 'Frequency where crossfade between nearfield and farfield will be made.' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = 100;

ele = ele+1;
pList{ele}.datatype    = 'line';

ele = ele+1;
pList{ele}.description = 'Result will be plotted and saved in current GUI figure'; %this text will be shown in the GUI
pList{ele}.helptext    = 'The result will be plotted and exported to your current GUI.';
pList{ele}.datatype    = 'text'; %based on this type a different row of elements has to drawn in the GUI


%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Combine Nearfield and Farfield Measurements']);
if ~isempty(pList)
    if isempty(pList{3})
        pList{3} = itaAudio();
    end
    result = ita_add_nearfield_farfield_measurements(pList{1},pList{2},'portMeasurement',pList{3},'crossoverFrequency',pList{4});
    result.pf
%     setappdata(fgh, 'audioObj', result);
%     ita_guisupport_updateGUI(fgh);

end
end