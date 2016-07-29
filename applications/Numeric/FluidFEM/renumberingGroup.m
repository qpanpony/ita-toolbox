function renumGroup = renumberingGroup(varargin)
% This function renumbers nodes in groups to have a constant numberation.
% An object from type itaMeshGroup and another from type itaMeshNode is
% needed. At the end the function gives a renumbered group (renumGroup)
% back

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargin==2
    if isa(varargin{1},'itaMeshGroup') && isa(varargin{2},'itaMeshNodes')
        group = varargin{1}; nodes = varargin{2};
    else error('renumberingGroup:: No valid input')
    end
end

renumGroup = group;
if nodes.nPoints ~= nodes.ID(end)
    if length(group.ID)==1
        pos = find(group.ID == nodes.ID);
        renumGroup.ID = pos;
    end
end

