function groups = ita_createSurfGroups(coord,surfElem,maxGroups)
% This function is called from ita_GUIModeSolve and generates some groups
% (maxGroups, groups) for the given coordinates (coord) and surfElements
% (surfElem)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
if maxGroups<0 && isnan(maxGroups) && imag(maxGroups)~=0
    maxGroups=6;
end
if ~isa(coord,'itaMeshNodes')
    error('First argument must be a itaMeshNodes')
end
if ~isa(surfElem,'itaMeshElements')
    error('Second argument must be a itaMeshElements')
end

%main
normal0 = zeros(size(surfElem.nodes,1),3);
for i1=1:size(surfElem.nodes,1)
    if size(surfElem.nodes,2)==10
        pos1 = coord.cart(surfElem.nodes(i1,1),:);
        pos2 = coord.cart(surfElem.nodes(i1,3),:);
        pos3 = coord.cart(surfElem.nodes(i1,7),:);
    elseif size(surfElem.nodes,2)==6
        pos1 = coord.cart(surfElem.nodes(i1,1),:);
        pos2 = coord.cart(surfElem.nodes(i1,3),:);
        pos3 = coord.cart(surfElem.nodes(i1,5),:);
    elseif size(surfElem.nodes,2)==3
        pos1 = coord.cart(surfElem.nodes(i1,1),:);
        pos2 = coord.cart(surfElem.nodes(i1,2),:);
        pos3 = coord.cart(surfElem.nodes(i1,3),:);
    end
    vec1 = pos2'-pos1';
    vec2 = pos3'-pos1';
    normal = cross(vec1,vec2);
    normal0(i1,:) = normal'/norm(normal);
end

normalTmp = normal0;
i1 =1;
while ~isempty(normalTmp)
    refNormal = normalTmp(1,:);
    posNorm = find(abs(normal0*refNormal.' - 1) < 1e-6);
    normalTmp(abs(normalTmp*refNormal.' - 1) < 1e-6,:)=[];
    groupNode{i1}=posNorm; %#ok<AGROW>
    l_groups(i1) = length(posNorm); %#ok<AGROW>
    i1=i1+1;
end
[l_sort, sortPos] = sort(l_groups);

groups = cell(min(numel(l_sort),maxGroups),1);
for i1 =1:min(numel(l_sort),maxGroups-1)
    ids = groupNode{sortPos(end-i1+1)};
    groups{i1} = itaMeshGroup(length(ids),['surfGroup' num2str(i1)],'shell elements');
    groups{i1}.ID = ids;
    groups{i1}.groupID = i1;
end

% all others, but only if more groups than maxGroups (avoid empty groups)
if numel(l_sort) > maxGroups-1
    ids = [];
    for i1= 1:(numel(l_sort)-maxGroups+1)
        ids = [ids; groupNode{sortPos(i1)}];
    end
    groups{maxGroups} = itaMeshGroup(length(ids),['surfGroup' num2str(maxGroups)],'shell elements');
    groups{maxGroups}.ID = ids;
    groups{maxGroups}.groupID = maxGroups;
end

