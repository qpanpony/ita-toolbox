function  ita_demoOverview(varargin)
%ITA_TUTORIALOVERVIEW - gives an overview of all tutorials
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%  ita_tutorialOverview
%
%
%  Example:
%     ita_tutorialOverview()
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_tutorialOverview">doc ita_tutorialOverview</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  15-Dec-2014 


%% search all ita_demo_* files and read description
allTutorialFiles = rdir([ita_toolbox_path filesep '**' filesep 'ita_demo*.m']);
nFiles = numel(allTutorialFiles);

fileNames            = cell(nFiles,1);
tutorialDescriptions = cell(nFiles,1);



for iFile = 1:nFiles
    [~,fileNames{iFile}] = fileparts(allTutorialFiles(iFile).name);
    fid = fopen(allTutorialFiles(iFile).name, 'r');
    firstLine = fgetl(fid);
    tutorialDescriptions{iFile} =  strrep(firstLine, '%% ', '');
    fclose(fid);
end
   
% add mian tutorial in front
idxDemosound = find(strcmp(fileNames, 'ita_demosound'));
idxOverView     = find(strcmp(fileNames, 'ita_demoOverview'));
sortOrder = [setdiff(1:nFiles, [idxDemosound idxOverView])];

fileNames = fileNames(sortOrder);
tutorialDescriptions = tutorialDescriptions(sortOrder);

%% display overview with links to tutorials
fprintf('\n\n*** List of tutorials in ITA-Toolbox:   %s\n', repmat('*',1,85))
columnWidth = max(cellfun(@length, fileNames));
for iFile = 1:numel(fileNames)
    linkText = ['<a href = " matlab: edit ' fileNames{iFile} '">'   fileNames{iFile}  '</a> ' ];
    fprintf('* %s %s : %s \n', linkText, repmat(' ', 1,columnWidth-numel(fileNames{iFile} )), tutorialDescriptions{iFile})
end
fprintf('%s\n', repmat('*',1,125))


%end function
end