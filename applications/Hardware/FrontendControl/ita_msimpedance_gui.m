function varargout = ita_msimpedance_gui(varargin)
%ITA_MSIMPEDANCE_GUI - Edit a measurement setup for impedance measurement

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  21-Nov-2011

pList = [];

if nargin == 1
    MS = varargin{1};
    if ~isa(MS,'itaMSImpedance')
        error('This function has to be called with an itaMSImpedance object as input parameter!');
    end
else
    MS = itaMSImpedance;
end


ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = 'Measurement Settings';

pList{ele}.description = 'Device'; %this text will be shown in the GUI
pList{ele}.helptext    = 'Select Measurement Device'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.list        = 'modulITA|Robo|Aurelio';
pList{ele}.default     = 'Robo'; %default value, could also be empty, otherwise it has to be of the datatype specified above

ele = numel(pList)+1;
pList{ele}.description = 'Shunt Resistance (Ohm)'; %this text will be shown in the GUI
pList{ele}.helptext    = 'shunt'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = double(MS.shunt_resistance);

ele = numel(pList)+1;
pList{ele}.description = 'Calibration Resistance (Ohm)'; %this text will be shown in the GUI
pList{ele}.helptext    = 'calibration'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = double(MS.calibration_resistance);

ele = numel(pList)+1;
pList{ele}.datatype    = 'line';

ele = numel(pList)+1;
pList{ele}.datatype    = 'text';
pList{ele}.description = 'Post Processing';

ele = numel(pList)+1;
pList{ele}.description = 'Window start (s)'; %this text will be shown in the GUI
pList{ele}.helptext    = 'start'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = MS.time_window(1);

ele = numel(pList)+1;
pList{ele}.description = 'Window end (s)'; %this text will be shown in the GUI
pList{ele}.helptext    = 'start'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'int'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = MS.time_window(2);

%% call GUI
pList = ita_parametric_GUI(pList,'Impedance Setup');
MS.device = pList{1};
MS.shunt_resistance = itaValue(pList{2},'Ohm');
MS.calibration_resistance = itaValue(pList{3},'Ohm');
MS.time_window = [pList{4} pList{5}];

varargout{1} = MS;