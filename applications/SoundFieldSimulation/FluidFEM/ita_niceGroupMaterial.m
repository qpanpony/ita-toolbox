function [groupMaterial]= ita_niceGroupMaterial(coord, volElem, surfElem, groups,gID)
% This function creates groupMaterial cells whose contain a itaMeshGroup
% and a itaMeshBoundaryC object with shell elements.

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


property = itaMeshBoundaryC;

l_nodes = length(surfElem.nodes(1,:));

% set node ids in groups
if strcmp(groups.type,'nodes') && groups.nNodes~=1
    % renummerieren der gruppen ids
    if coord.ID(end) ~= length(coord.ID)
        for i1=1:size(groups.ID)
            pos(i1) = find(groups.ID(i1) == coord.ID);
        end
        groups.ID = pos;
    end
    
    % suchen der gruppen
    ids = [];
    for i2=1:length(surfElem.nodes(:,1))
        if sum(ismember(surfElem.nodes(i2,:),groups.ID))==l_nodes
            ids = [ids,i2];
        end
    end
    
    groupsTmp = itaMeshGroup(length(ids),groups.groupName,'shell elements');
    groupsTmp.ID = ids;
    groupsTmp.groupID = gID;
else % point source
    groupsTmp = groups;
    groupsTmp.groupID = gID;
end

property.Name =  groupsTmp.groupName;
groupMaterial = {groupsTmp,property};
groupMaterial{1} = renumberingGroup(groupMaterial{1},coord);



