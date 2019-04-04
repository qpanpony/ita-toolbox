function [coord, elements, groups] = get_object(varargin)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% get coordinates (coord), elements (elements) and groups (groups) from a unv file as objects
classes = ita_read_unv(varargin{1});
coord = classes{1};

if length(classes)<3
    elements = classes{2};
elseif isa(classes{3},'itaMeshElements')
    if classes{2}.nElements<10
        elements = {classes{3},classes{2}};
    else
        elements = {classes{2},classes{3}};
    end
    groups ={classes{4:end}};
else
    elements = {classes{2}};
    groups ={classes{3:end}};
end