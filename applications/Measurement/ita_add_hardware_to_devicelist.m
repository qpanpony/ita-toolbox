function ita_add_hardware_to_devicelist(varargin)
%ITA_ADD_HARDWARE_TO_DEVICELIST - add something to the device list
%  This function adds an entry to the ita_device_list.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%          PLEASE BE VERY CAREFUL WITH THIS ONE
%          CONSULT MMT OR PDI BEFORE MAKING ANY CHANGES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Syntax:
%   ita_add_hardware_to_devicelist(itaMeasurementChainElements)
%
%  Options (default):
%           shortDescription ('') : enter the short description to bypass
%                                   the GUI
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_add_hardware_to_devicelist">doc ita_add_hardware_to_devicelist</a>

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  07-Dec-2010 


%% Get Function String
thisFuncStr  = [upper(mfilename) ':'];     %Use to show warnings or infos in this functions

%% Show GUI if nothing is given as input
if ~nargin
    varargin{1} = itaMeasurementChainElements();
end
    
%% Initialization and Input Parsing
% all fixed inputs get fieldnames with posX_* and dataTyp
% optonal inputs get a default value ('comment','test', 'opt1', true)
% please see the documentation for more details
sArgs        = struct('pos1_input','itaMeasurementChainElements','shortDescription','');
[input,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% do some checks first
% we do not want to enter variable elements
if ~isempty(strfind(input.type,'var'))
    ita_verbose_info([thisFuncStr 'this is a "var" element, it does not belong in the device list'],0);
    return;
    % for the fix part just adjust the type
elseif ~isempty(strfind(input.type,'fix'))
    if ~isempty(strfind(input.type,'preamp'))
        input.type = 'preamp';
    elseif ~isempty(strfind(input.type,'amp'))
        input.type = 'amp';
    end
end

% is this element already in the list?
devListHandle = ita_device_list_handle;
if double(devListHandle(input.type,input.name)) >= 0
    error([thisFuncStr 'this element is already in the device list: ' input.name]);
end

%% the "joe" mode, bypass the GUI to enter the short description as an option
if ~isempty(sArgs.shortDescription)
    input = struct('type',input.type,'name',input.name,...
        'sensitivity',input.sensitivity,'category',sArgs.shortDescription,...
        'calibratable',logical(input.calibrated > -1));
else
    short_descriptions = devListHandle();
    short_descriptions = unique(short_descriptions(:,3));
    short_description_str = short_descriptions{1};
    for i = 2:numel(short_descriptions)
        short_description_str = [short_description_str '|' short_descriptions{i}]; %#ok<AGROW>
    end
    
    pList = [];
    
    ele = numel(pList) + 1;
    pList{ele}.description = 'Type of the device';
    pList{ele}.helptext    = 'Choose a type';
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.list        = 'ad|preamp|sensor|da|amp|actuator';
    pList{ele}.default     = input.type;
    
    ele = numel(pList) + 1;
    pList{ele}.description = 'Name of the device';
    pList{ele}.helptext    = 'Type in a name';
    pList{ele}.datatype    = 'char_long';
    pList{ele}.default     = input.name;
    
    ele = numel(pList) + 1;
    pList{ele}.description = 'Sensitivity (enter with unit)';
    pList{ele}.helptext    = 'Type in as a number followed by a space and then the unit';
    pList{ele}.datatype    = 'char';
    pList{ele}.default     = num2str(input.sensitivity);
    
    ele = numel(pList) + 1;
    pList{ele}.description = 'Short description';
    pList{ele}.helptext    = 'Does it belong to a category, e.g. multiface';
    pList{ele}.datatype    = 'char_popup';
    pList{ele}.list        = short_description_str;
    pList{ele}.default     = 'none';
    
    ele = numel(pList) + 1;
    pList{ele}.description = 'Calibratable';
    pList{ele}.helptext    = 'Can the device be calibrated';
    pList{ele}.datatype    = 'bool';
    pList{ele}.default     = (input.calibrated > -1);
    
    pList = ita_parametric_GUI(pList,'Add to Device List GUI');
    if ~isempty(pList)
        input = struct('type',pList{1},'name',pList{2},...
            'sensitivity',itaValue(pList{3}),'category',pList{4},...
            'calibratable',pList{5});
    else
        ita_verbose_info([thisFuncStr 'operation cancelled by user'],0);
        return;
    end
    
end

if double(input.sensitivity) < 0
    ita_verbose_info('The sensitivity is negative, this does not make sense, please calibrate the device. I will take care of this for now',0);
    input.sensitivity.value = 1;
end

%% make a backup of the device file, just in case
fileName = [func2str(devListHandle) '.m'];
folder = fileparts(which(fileName));
filename = [folder filesep fileName];
copyfile(filename,[folder filesep fileName(1:end-1) 'bak']);
ita_verbose_info([thisFuncStr 'a backup of the device file was saved to: ' folder filesep fileName(1:end-1) 'bak'],1);

%% read in the device list m-file and get some file marks
fid = fopen(filename);
if fid < 3
    error([thisFuncStr 'problem opening ' fileName '!']);
end

str = fgetl(fid);
lines{1} = str;
idx = 1; 
while (ischar(str))
    lines{idx} = str; %#ok<AGROW>
    str = fgetl(fid);
    idx = idx+1;
end
oldLines = lines.';
% find the start of the subfunctions, calls to the subfunctions might occur
% earlier in the file
subfunctionStart = strfind(lines,'subfunction');
subFunIdx = 1;
while isempty(subfunctionStart{subFunIdx})
    subFunIdx = subFunIdx + 1;
end
lines = lines(subFunIdx+1:end).';

% now find the section of elements we are looking for
switch lower(input.type)
    case {'ad','preamp','sensor','da','amp','actuator'}
        token = strfind(lines,['ita_device_list_' lower(input.type)]);
    otherwise
        error([thisFuncStr 'incorrect element type']);
end

tokenIdx = 1;
while isempty(token{tokenIdx})
    tokenIdx = tokenIdx + 1;
end
lines = lines(tokenIdx+1:end);

% find the end of that section
sectionEnd = find(strcmpi(lines,'end'),1,'first');
sectionStartAbs = subFunIdx + tokenIdx;
insertPoint = sectionStartAbs + sectionEnd;

% close the file
fclose(fid);

%% write the new line into the file, assemble everything together
linesBefore = oldLines(1:insertPoint-1);
linesAfter  = oldLines(insertPoint+1:end);
line = ['device(end+1,:) = {''' input.name ''',''' num2str(input.sensitivity) ''',''' input.category  ''',' num2str(input.calibratable) '};'];
newLines = [linesBefore; {line}; {'end'}; linesAfter];

try
    fid =fopen(filename,'wt');
    for i = 1:numel(newLines)
        fprintf(fid,'%s\n',newLines{i});
    end
    fclose(fid);
catch %#ok<CTCH>
    copyfile([folder filesep fileName(1:end-1) 'bak'],filename);
    ita_verbose_info([thisFuncStr 'error ocurred at writing, restored file from backup!'],0);
end
delete([folder filesep fileName(1:end-1) 'bak']);
ita_verbose_info([thisFuncStr 'backup file deleted!'],1);

%end function
end