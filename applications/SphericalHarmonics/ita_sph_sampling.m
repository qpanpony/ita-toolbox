function ita_sph_sampling

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


[pathstr, name] = fileparts(mfilename('fullpath'));

% samplingMap = ita_io_get_daughter(pathstr, name);

fileNameList = dir(fullfile(pathstr, name, [name '_*.m']));
nFiles = numel(fileNameList);
samplingList = '';
for ind = 1:nFiles
    % add a | and the name of the file without .m
    samplingList = [samplingList '|' fileNameList(ind).name(1:end-2)];
end

% TODO: use persisitent variable to make list faster


pList = [];

% GUI type of sampling
ele = length(pList) + 1;
pList{ele}.description = 'Spherical Sampling';
pList{ele}.helptext    = 'How you sample the sphere today?' ;
pList{ele}.datatype    = 'char_popup';
pList{ele}.default     = '@';
pList{ele}.list        = samplingList;

% GUI maximum order
ele = length(pList) + 1;
pList{ele}.description = 'maximum Order';
pList{ele}.helptext    = '...' ;
pList{ele}.datatype    = 'int';
pList{ele}.default     = 0;

ele = length(pList) + 1;
pList{ele}.datatype    = 'line';

% % GUI name of result
% ele = length(pList) + 1;
% pList{ele}.description = 'Name of Result'; %this text will be shown in the GUI
% pList{ele}.helptext    = 'The result will be exported to your workspace with the variable name specified here';
% pList{ele}.datatype    = 'text';
% pList{ele}.default     = ['result_' mfilename];

%call gui
parameterList = ita_parametric_GUI(pList,[mfilename ' - How you sample the sphere today?']);

if ~isempty(parameterList)
    s = eval([parameterList{1} '(' num2str(parameterList{2}) ')']);
    ita_setinbase('sampling', s);
    scatter(s,'SizeData', s.weights ./ mean(s.weights) * 10);
end