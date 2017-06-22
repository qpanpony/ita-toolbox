function ita_generate_documentation(varargin)
%ITA_GENERATE_DOCUMENTATION - Generate Toolbox Help
%  This function automatically generated the html help used for the Toolbox
%
%   See also help, doc, helpdesk, ita_toolbox_setup.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_generate_documentation">doc ita_generate_documentation</a>

% <ITA-Toolbox>
% This file is part of the application HTMLhelp for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%
% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  17-Apr-2009
% Edited: 18-May-2012 Tumbr�gel


% pdi not for preferences
sArgs = struct('rootpath',ita_toolbox_path);
sArgs = ita_parse_arguments(sArgs,varargin);

currentDir = pwd;

%generate helpbrowser html files - Tumbr�gel 05/2012:
ita_generate_helpOverview(sArgs.rootpath); 

cd(sArgs.rootpath)
%% Get folders for m2html
ignoreList  = {'.svn', ...
               '.git', ...
               'private', ...
               'tmp', ...
               'prop-base', ...
               'props', ...
               'text-base', ...
               'template', ...
               'doc', ...
               'GuiCallbacks', ...
               'external_packages', ...
               'ExternalPackages', ...
               'helpers'};
pathStr = genpath(sArgs.rootpath);
prefixToolbox = fliplr(strtok(fliplr(sArgs.rootpath),filesep)); %get Toolbox folder name

outpathStr  = [];
outpathList = [];
tokenIdx    = [0 strfind(pathStr,pathsep)];

for idx=1:(length(tokenIdx)-1)
   tokenCell{idx} = pathStr(tokenIdx(idx)+1:tokenIdx(idx+1)-1); %get single folder name
   isIgnore = false;
   for ignIdx = 1:length(ignoreList)
       foundIdx     = strfind(tokenCell{idx},ignoreList{ignIdx}); %folder in ignore list?
       isIgnore     = ~isempty(foundIdx) || isIgnore;
    end
   if ~isIgnore %add string token
       outpathStr   = [outpathStr,pathsep,tokenCell{idx}]; %#ok<*AGROW>
       idxITA = strfind(tokenCell{idx},prefixToolbox); %pdi
       outpathList  = [outpathList; {tokenCell{idx}(idxITA:end)}]; % make path relative
   end  
end

% delete old one first
graphInst = ita_preferences('isGraphVizInstalled');

if ischar(graphInst), graphInst = str2double(graphInst); end;

%% ignorelist -- doc - guicallbacks - externalpackages
if graphInst
    graphState = 'on';
    disp('Generating with GraphViz')
else
    graphState = 'off';
end
htmlFolder = fullfile(sArgs.rootpath, 'HTML');
docFolder = fullfile(htmlFolder, 'doc');
% cd required for m2html
cd ..
tic
m2html('mfiles',outpathList, 'htmldir',docFolder, 'recursive','off', 'source','off', 'syntaxHighlighting','on', ...
    'global','on', 'globalHypertextLinks','on', 'todo','on', ...
    'verbose','on','template','blue', 'indexFile','index', 'graph',graphState);
toc

%% Build search database for helpdesk
% switching to basic rendering to fix bug with builddocsearchdb
webutils.htmlrenderer('basic');
% MATLAB requires the html files to be in its search path
addpath(htmlFolder, docFolder);
savepath;
% switching seems to take a while sometimes
pause(1);
if nargin == 0
    builddocsearchdb(htmlFolder); %generate help search
    rehash toolboxcache
end
% switch back to standard renderer
webutils.htmlrenderer('default');

ita_verbose_info('Please restart MATLAB if the MATLAB ITA Toolbox entry does not show in the documentation browser.',0);
%% Go back to the last working directory
cd(currentDir)
