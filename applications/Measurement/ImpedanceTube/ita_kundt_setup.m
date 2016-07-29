function varargout = ita_kundt_setup(varargin)
%ITA_KUNDT_SETUP - used by ita_kundt_gui

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

if nargin
    KundtSetup = varargin{1};
else
    KundtSetup = ita_getfrombase('Kundt_Kundt_Setup');
end

%% Get ITA Toolbox preferences and Function String

idpList = 1;

pList{idpList}.datatype = 'text';
pList{idpList}.description = 'Kundt Settings';

idpList = idpList + 1;
pList{idpList}.datatype = 'char_popup';
pList{idpList}.description = 'Which Tube';
if KundtSetup.nMics == 4
     pList{idpList}.list = '|Small Kundt''s Tube at ITA Mics1234|Big Kundt''s Tube at ITA|Rohr mit Ohr|Small Kundt''s Tube at ITA Mics1236';
else
    pList{idpList}.list = '|Small Kundt''s Tube at ITA Mics123|Big Kundt''s Tube at ITA|Rohr mit Ohr';
end
pList{idpList}.helptext = 'Specification of of the tube distances has priority over the tube selection.';
pList{idpList}.default     = 'Small Kundt''s Tube at ITA'; 

idpList = idpList + 1;
pList{idpList}.datatype = 'int';
pList{idpList}.description = 'Tube distances';
pList{idpList}.helptext = 'Specification of of the tube distances has priority over the tube selection.';
pList{idpList}.default     = []; 


% idpList = idpList + 1;
% pList{idpList}.description = 'select mode'; %this text will be shown in the GUI
% pList{idpList}.helptext    = 'Select Rohrbert Output'; %this text should be shown when the mouse moves over the textfield for the description
% pList{idpList}.datatype    = 'char_popup'; %based on this type a different row of elements has to drawn in the GUI
% pList{idpList}.list        = 'Abs|Ref|Imp|Adm|Tau|SI|Allrefl|All';
% pList{idpList}.default     = 'Allrefl'; %default value, could also be empty, otherwise it has to be of the datatype specified above

idpList = idpList + 1;
pList{idpList}.datatype = 'line';

idpList = idpList + 1;
pList{idpList}.datatype = 'text';
pList{idpList}.description = 'Pre-Processing';

idpList = idpList + 1;
pList{idpList}.datatype = 'bool';
pList{idpList}.description = 'Apply Time Window';
pList{idpList}.helptext = 'Apply a time window to the impulse responses to ged rid of noise and non-linearities';
pList{idpList}.default = true;

idpList = idpList + 1;
pList{idpList}.datatype = 'double';
pList{idpList}.description = 'Window Limits';
pList{idpList}.helptext = 'Please enter the limits of the time window (start and end of window)';
pList{idpList}.default = [0.075 0.15];

idpList = idpList + 1;
pList{idpList}.datatype = 'line';

idpList = idpList + 1;
pList{idpList}.datatype = 'text';
pList{idpList}.description = 'Result handling';

idpList = idpList + 1;
pList{idpList}.datatype = 'bool';
pList{idpList}.description = 'Save Raw-Data';
pList{idpList}.helptext = 'Save measured data, prior to pre-processing';
pList{idpList}.default = true;

idpList = idpList + 1;
pList{idpList}.datatype = 'bool';
pList{idpList}.description = 'Save Result';
pList{idpList}.helptext = 'Save results';
pList{idpList}.default = true;

idpList = idpList + 1;
pList{idpList}.datatype = 'bool';
pList{idpList}.description = 'Keep Result';
pList{idpList}.helptext = 'Keep results in memory';
pList{idpList}.default = true;

idpList = idpList + 1;
pList{idpList}.datatype = 'bool';
pList{idpList}.description = 'Save Setup';
pList{idpList}.helptext = 'Save Setup (This one and the measurement setup) with results, this way all settings can be reconstructed ';
pList{idpList}.default = true;


if ~isempty(KundtSetup)
    pList{2}.default = KundtSetup.tube;
    pList{3}.default = KundtSetup.dist;
%     pList{4}.default = KundtSetup.what;
%     pList{7}.default = KundtSetup.timewindow;
%     pList{8}.default = KundtSetup.timeframe;
%     pList{11}.default = KundtSetup.saverawdata;
%     pList{12}.default = KundtSetup.saveresult;
%     pList{13}.default = KundtSetup.keepresult;
%     pList{14}.default = KundtSetup.savesetup;
    pList{6}.default = KundtSetup.timewindow;
    pList{7}.default = KundtSetup.timeframe;
    pList{10}.default = KundtSetup.saverawdata;
    pList{11}.default = KundtSetup.saveresult;
    pList{12}.default = KundtSetup.keepresult;
    pList{13}.default = KundtSetup.savesetup;
end

pList = ita_parametric_GUI(pList,'Kundt Settings');

% ToDo: Dialog


if ~isempty(pList)
    KundtSetup.tube = pList{1};
    KundtSetup.dist = pList{2};
    
    if ~isempty(KundtSetup.dist) && ~isempty(KundtSetup.tube)
        warndlg('Specification of of the tube distances has priority over the tube selection.')
        KundtSetup.tube = '';
    end
    
%     KundtSetup.what = pList{3};
    KundtSetup.timewindow = pList{3};
    KundtSetup.timeframe = pList{4};
    KundtSetup.saverawdata = pList{5};
    KundtSetup.saveresult = pList{6};
    KundtSetup.keepresult = pList{7};
    KundtSetup.savesetup = pList{8};
end

%KundtSetup = ita_parse_arguments_gui(KundtSetup,'title','Kundt Setup'); %ToDo - replace by better gui!

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_setinbase('Kundt_Kundt_Setup',KundtSetup);
else
    % Write Data
    varargout(1) = {KundtSetup}; 
end

%end function
end