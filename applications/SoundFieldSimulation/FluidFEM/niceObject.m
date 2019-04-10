function [coord, elements, groupMaterial] = niceObject(meshFilename, propertyFilename)
% This function creates objects coord, elements and groupMaterial which
% contain coordinates of nodes, nodes of elements and nodes/elements of
% groups as well as boundary condition data. Data will be created from mesh
% file (meshFilename) and property file or property data from gui
% (propertyFilename).

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% gets coordinates, elements and groups from meshfile
[coord, elements, groups] = get_object(meshFilename);

% gets boundary condition from propertyfile
if isempty(propertyFilename)
    disp('No excitation!'); % no excitation
    property = []; propertyAdd=[];
elseif iscell(propertyFilename) % from gui data
    property=[]; iP = 0; propertyAdd=[]; iPAdd =0;
    for i1=1:length(propertyFilename)
        if strcmp(propertyFilename{i1}.Type,'Added point source')
            iPAdd=iPAdd+1;
            propertyFilename{i1}.Type = 'Point Source';
            IDps(iPAdd) = propertyFilename{i1}.Value;
            propertyFilename{i1}.Value=1;
            propertyAdd{iPAdd} = itaMeshBoundaryC(propertyFilename{i1});
        else
            iP=iP+1;
            property{iP} = itaMeshBoundaryC(propertyFilename{i1}); %#ok<AGROW>
        end
    end
else % from file
    propertyAdd=[];
    property = get_property_group(propertyFilename);
end

%% create surface elements
if length(elements)==1 % no existing surface elements
    volumeElements=elements{1};
    surfElem = makeShellElements(elements{1});

    l_nodes = length(surfElem.nodes(1,:));
    for i1=1:length(groups)
        % set node ids in groups
        if strcmp(groups{i1}.type,'nodes') && groups{i1}.nNodes~=1
            ids = [];
            nodesTemp = groups{i1}.ID;
            for i2=1:length(surfElem.nodes(:,1))
                if sum(ismember(surfElem.nodes(i2,:),nodesTemp))==l_nodes
                    ids = [ids,i2];
                end
            end
            groupsTmp{i1} = itaMeshGroup(length(ids),groups{i1}.groupName,'shell elements');
            groupsTmp{i1}.ID = ids;
            groupsTmp{i1}.groupID = i1;
        else % point source
             groupsTmp{i1} = groups{i1};
             groupsTmp{i1}.groupID = i1;
        end
        
        if ~isempty(property)
            % set property data in groups
            for i2=1:length(property)
                if length(property{i2}.Name)==length(groupsTmp{i1}.groupName)
                    if strcmp(property{i2}.Name, groupsTmp{i1}.groupName)
                        property{i2}.groupID = groupsTmp{i1}.groupID;
                        groupMaterial{i1} = {groupsTmp{i1} , property{i2}};
                    end
                end
            end
            groupMaterial{i1}{1} = renumberingGroup(groupMaterial{i1}{1},coord);
        else
            groupMaterial{i1} = {groupsTmp{i1} , cell(0,0)};
            groupMaterial{i1}{1} = renumberingGroup(groupMaterial{i1}{1},coord);
        end
    end

    % renumbering elements
    RvolElem  = renumberingElements(volumeElements,coord);
    RsurfElem = renumberingElements(surfElem,coord);
    elements ={RvolElem, RsurfElem};

elseif length(elements)==2 && ~isempty(property) % surface elements already exist
    for i1=1:length(groups)
        for i2=1:length(property)
            if length(property{i2}.Name)==length(groups{i1}.groupName)
                if strcmp(property{i2}.Name, groups{i1}.groupName)
                    property{i2}.groupID = groups{i1}.groupID;
                    groupMaterial{i1} = {groups{i1} , property{i2}};
                end
            end
        end
        groupMaterial{i1}{1} = renumberingGroup(groupMaterial{i1}{1},coord);
    end
elseif length(elements)==2 && isempty(property) && ~isempty(groups)
    for i1=1:length(groups)
        groupMaterial{i1} = {groups{i1} , cell(0,0)};
        groupMaterial{i1}{1} = renumberingGroup(groupMaterial{i1}{1},coord);
    end
else
    groupMaterial =cell(0,0);
end

%% Additional Point Sources
i1 = length(groupMaterial);
for i2 = 1:length(propertyAdd)
    groupAddTmp{i2} = itaMeshGroup(1,propertyAdd{i2}.Name,IDps(i2),'nodes');
    groupAddTmp{i2}.ID = IDps(i2);
    groupAddTmp{i2}.groupID = i1+i2;
    groupMaterial{i1+i2} = {groupAddTmp{i2}, propertyAdd{i2}};
    groupMaterial{i2}{1} = renumberingGroup(groupMaterial{i2}{1},coord);
end
