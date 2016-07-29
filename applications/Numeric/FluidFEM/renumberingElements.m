function renumElem = renumberingElements(varargin)
% This function renumbers nodes in elements to have a constant numberation.
% An object from type itaMeshElements and another from type itaMeshNodes is
% needed. At the end the function gives a renumbered elements (renumElem)
% back.

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargin==2
    if isa(varargin{1},'itaMeshElements') && isa(varargin{2},'itaMeshNodes')
        element = varargin{1}; nodes = varargin{2};
    end
end

renumElem = element;
if nodes.nPoints ~= nodes.ID(end)
    %renumElem  = zeros(nodes.nElements,length(element.nodes(1,:)));
    nodesTmp  = zeros(size(element.nodes));
    for i1=1:size(element.nodes,1)
        for i2=1:size(element.nodes,2)
            pos = find(element.nodes(i1,i2)== nodes.ID);
            try
            nodesTmp(i1,i2) =pos;
            catch
               disp('')
            end
        end    
    end
    renumElem.nodes = nodesTmp;
end
