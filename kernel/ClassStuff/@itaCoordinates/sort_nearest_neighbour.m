function this = sort_nearest_neighbour(this,varargin)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


sArgs = struct('remove_doubles',false,'critical_distance',2e-16);
sArgs = ita_parse_arguments(sArgs,varargin);
    
% Start with first Point in the list
sorted_list = this.sph(1,:);
this.sph(1,:) = [];

while size(this.sph,1) > 1 
    this = this.build_search_database;
    [nextind, distance] = this.findnearest(sorted_list(end,:),'sph'); % Find closest point to last one
    if ~(sArgs.remove_doubles && distance < sArgs.critical_distance)
        sorted_list(end+1,:) = this.sph(nextind,:); %#ok<AGROW>
    end
    this.sph(nextind,:) = [];
end

sorted_list(end+1,:) = this.sph(1,:); %#ok<AGROW>

this.sph = sorted_list;

end