function shellElements = makeShellElements(varargin)
%MAKESHELLELEMENTS Summary of this function goes here
%   Detailed explanation goes here

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

narginchk(1,2);
if isa(varargin{1},'itaMesh')
    mesh = varargin{1};
else
    error('itaMesh.makeShellElements:I need a mesh object');
end

if nargin == 2
    if isa(varargin{2},'itaMeshElements') && strfind(varargin{2}.type,'volume')
        volumeElements = varargin{2};
    elseif isa(varargin{2},'itaMeshGroup') && strcmpi(varargin{2}.type,'elements')
        volumeElements = mesh.elementsForGroup(varargin{2});
    else
        error('itaMesh.makeShellElements:wrong second input argument');
    end
else
    volumeElements = mesh.volumeElements;
end

%% create surface elements...
shellElements = itaMeshElements;
switch length(volumeElements.nodes(1,:))
    case 20 % parabolic quad
        shellElements.shape = 'quad';
        shellElements.type  = 'shell';
        shellElements.order = 'parabolic';
        n_surf=6; % no of surfaces
        n_nodes=8; % no of nodes for shell elements
        Surf=[1:8;...
            5 11 17 18 19 12 7 6;...
            3 10 ,15:17, 11 5 4 ;...
            13 9 1 8 7 12 19 20 ;...
            15 14 13 20:-1:16;...
            13:15, 10 3 2 1 9];
    case 10 % parabolic tetra
        shellElements.shape = 'tetra';
        shellElements.type  = 'shell';
        shellElements.order = 'parabolic';
        n_surf=4; % no of surfaces
        n_nodes = 6; % no of nodes for shell elements
        Surf=[1:6;...
            1 6 5 9 10 7;...
            1 7 10 8 3 2;...
            3 8 10 9 5 4];
    case 8 % linear quad
        shellElements.shape = 'quad';
        shellElements.type  = 'shell';
        shellElements.order = 'linear';
        n_surf=6; % no of surfaces
        n_nodes=4; % no of nodes for shell elements
        Surf=[1:4;...
            5 1 4 8;...
            6 2 1 5;...
            7 3 2 6;...
            8 4 3 7;...
            8 7 6 5];
    case 4 % linear tetra
        shellElements.shape = 'tetra';
        shellElements.type  = 'shell';
        shellElements.order = 'linear';
        n_surf=4; % no of surfaces
        n_nodes=3; % no of nodes for shell elements
        Surf=[1 2 3;...
              4 2 1;...
              3 2 4;...
              1 3 4];
end

list = zeros(n_surf*volumeElements.nElements,n_nodes);
surfElements =[];
volumeNodes = volumeElements.nodes;
for i1=1:volumeElements.nElements
    nodes_temp = volumeNodes(i1,:);
    list((i1-1)*n_surf+(1:n_surf),:) = nodes_temp(Surf);
end

list_sort = sort(list,2);
% sort out elements
while ~isempty(list)
    elem_temp =list_sort(1,:);
    pos = find(sum(abs(elem_temp-list_sort),2)==0);
    if length(pos)==1
        surfElements = [surfElements;list(1,:)]; %#ok<AGROW>
        list_sort(1,:)=[];
        list(1,:)=[];
    else
        list_sort(pos,:)=[];
        list(pos,:)=[];
    end
end

shellElements.nodes = surfElements;

end