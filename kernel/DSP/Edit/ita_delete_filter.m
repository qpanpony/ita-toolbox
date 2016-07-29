function ita_delete_filter()
%ITA_delete_filter -  removes all filters from the hard drive and from global workspace
% This function removes all filters on hard drive and in workspace
% 
% Syntax: ita_delete_filter()
% 
% 
% Author: Martin Guski - 2011

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


ita_verbose_info('ita_delete_filter::Deleting all old filter objects from disk and RAM.',2)

    % global filter
    filterVar = whos('RWTH_ITA_Filter_*', 'global');
    for iVar = 1:length(filterVar)
        clear('global',filterVar(iVar).name )
    end

    % filter on HDD
    pathstr    = fileparts(mfilename('fullpath'));
    filterpath = [pathstr filesep 'Filters'];
      
    fileList   = dir([filterpath filesep '*.mat']);
       
    for iFile = 1:length(fileList)
        delete(fullfile(filterpath, fileList(iFile).name))
    end
    
end
