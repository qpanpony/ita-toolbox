% ITA_DISTORTIONS_GUI - gui for ita_distortions
%%

% <ITA-Toolbox>
% This file is part of the application Nonlinear for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

pList = [];
ele = 1;
pList{ele}.description = 'Measurement Type';
pList{ele}.helptext    = 'xxx';
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = 'steppedsine';
pList{ele}.list        = 'expsweep|steppedsine';

ele = numel(pList)+1;
pList{ele}.datatype    = 'line'; %just draw a simple line

ele = numel(pList)+1;
pList{ele}.description = 'Just a simple text'; %this text will be shown in the GUI
pList{ele}.datatype    = 'text'; %only show text
pList{ele}.color       = [0 0.5 1];

ele = numel(pList)+1;
pList{ele}.description = 'Low Frequency [Hz]';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'int';
pList{ele}.default     = [100 20000];

ele = numel(pList)+1;
pList{ele}.description = 'Increment [1/frac oct]';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = '12';
pList{ele}.list        = '12|5|3|1';

ele = numel(pList)+1;
pList{ele}.datatype    = 'line'; %just draw a simple line

ele = numel(pList)+1;
pList{ele}.description = 'Power Settings'; %this text will be shown in the GUI
pList{ele}.datatype    = 'text'; %only show text
pList{ele}.color       = [0 0.5 1];

ele = numel(pList)+1;
pList{ele}.description = 'Power Range [W]';
pList{ele}.helptext    = 'xxx';
pList{ele}.datatype    = 'int';
pList{ele}.default     = [0.1 10];

ele = numel(pList)+1;
pList{ele}.description = 'Level Inc [dB]';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'int';
pList{ele}.default     = '1';

ele = numel(pList)+1;
pList{ele}.description = 'max THD [%]';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = '1';
pList{ele}.list        = '1|3|10';

ele = numel(pList)+1;
pList{ele}.description = 'Impedance [Ohm]';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = '4';
pList{ele}.list        = '2|4|6|8|10|16';

ele = numel(pList)+1;
pList{ele}.datatype    = 'line'; %just draw a simple line

ele = numel(pList)+1;
pList{ele}.description = 'Advanced Options'; %this text will be shown in the GUI
pList{ele}.datatype    = 'text'; %only show text
pList{ele}.color       = [0 0.5 1];

ele = numel(pList)+1;
pList{ele}.description = 'harmonic order []';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'int';
pList{ele}.default     = '5';

ele = numel(pList)+1;
pList{ele}.description = 'FFT degree []';
pList{ele}.helptext    = 'The sweep will start at this frequency';
pList{ele}.datatype    = 'int';
pList{ele}.default     = '16';


%% call gui
name = 'ita distortions gui';
pOutList = ita_parametric_GUI(pList,name,'wait','on');
method      = pOutList{1};

f_range     = pOutList{2};
f_inc       = str2num(pOutList{3});

power_range = pOutList{4};
level_inc   = pOutList{5};

maxTHD          = str2num(pOutList{6});
imp             = str2num(pOutList{7});
order           = pOutList{8};
fftdeg          = pOutList{9};


%%
power_vec   = [power_range(1) level_inc power_range(2)];

switch lower(method)
    case 'expsweep'
        [Max_spl THD THDN HD] = ita_distortions(method,f_range,power_vec, maxTHD, order,fftdeg,imp)

    case 'steppedsine'
        f_range = [f_range(1) f_inc f_range(2)];
        [Max_spl THD THDN HD] = ita_distortions(method,f_range,power_vec, maxTHD, order,fftdeg,imp)
        
end

