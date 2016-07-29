function MS = ita_measurement_run2file(MS,varargin)
% ITA_MEASUREMENT_RUN2FILE - run a measurement setup and directly save to disk

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if isa(MS,'itaMSRecord') && ~isa(MS,'itaMSPlaybackRecord')
    outputOption = false;
else
    outputOption = true;
end

if nargin == 1
    %% call GUI
    pList = [];

    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';

    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Save options';

    ele = numel(pList)+1;
    pList{ele}.description = 'Save folder'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Select your special path'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'path'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.filter      = ''; %Filter
    pList{ele}.default     = pwd; %default value, could also be empty, otherwise it has to be of the datatype specified above

    ele = numel(pList)+1;
    pList{ele}.description = 'Filename (.ita)'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Select Measurement Device'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = 'test_measurement'; %default value, could also be empty, otherwise it has to be of the datatype specified above

    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';

    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Hardware Settings';

    ele = numel(pList)+1;
    pList{ele}.description = 'Robo'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Call ita_robocontrol'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'simple_button'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{ele}.callback    = 'ita_robocontrol';

    ele = numel(pList)+1;
    pList{ele}.description = 'ModulIta'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Call ita_modulita_cotrol'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'simple_button'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
    pList{ele}.callback    = 'ita_modulita_control';
    
    ele = numel(pList)+1;
    pList{ele}.description  = 'Aurelio';
    pList{ele}.helptext     = 'Call ita_aurelio_control GUI';
    pList{ele}.datatype     = 'simple_button';
    pList{ele}.default      = '';
    pList{ele}.callback     = 'ita_aurelio_control();';

    ele = numel(pList)+1;
    pList{ele}.datatype    = 'line';

    ele = numel(pList)+1;
    pList{ele}.datatype    = 'text';
    pList{ele}.description = 'Mode';

    ele = numel(pList)+1;
    pList{ele}.description = 'repeat'; %this text will be shown in the GUI
    pList{ele}.helptext    = 'Show some verbose Info'; %this text should be shown when the mouse moves over the textfield for the description
    pList{ele}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
    pList{ele}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above

    if outputOption
        ele = numel(pList)+1;
        pList{ele}.description = 'output amplification [dBFS]'; %this text will be shown in the GUI
        pList{ele}.helptext    = 'Show some verbose Info'; %this text should be shown when the mouse moves over the textfield for the description
        pList{ele}.datatype    = 'char'; %based on this type a different row of elements has to drawn in the GUI
        amp = MS.outputamplification;
        pList{ele}.default     = amp; %default value, could also be empty, otherwise it has to be of the datatype specified above
    end
    
    pList = ita_parametric_GUI(pList,'Measurement run2file');
else
    pList = varargin;
end
    
if isempty(pList)
    return;
end

folder = pList{1};
filename = pList{2};
repeat = pList{3};
if outputOption
    MS.outputamplification = pList{4};
end

cd (folder)

if repeat
    maxidx = 100;
else
    maxidx = 1;
end

for idx=1:maxidx
    if repeat
        current_filename = [filename ita_angle2str(idx,3)];
    else
        current_filename = filename;
    end
    answer = questdlg('Measure now?','Measurement','YES','Cancel','Cancel');
    
    if strcmpi(answer,'Cancel')
        return
    end
    
    x = MS.run;
    a = ita_channel_settings(x(1));
    if numel(x) == 2 % raw results
        a(2) = x(2);
    end
    
    ita_write(a,current_filename);
end

end