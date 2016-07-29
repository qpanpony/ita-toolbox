function [ind,dist,res] = findnearest(varargin)

% <ITA-Toolbox>
% This file is part of the application Meshing for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

narginchk(2,4);
input = varargin{1};
coords = varargin{2};
if nargin < 3 || isempty(varargin{3})
    system = 'cart';
else
    system = varargin{3};
end
if nargin < 4 || isempty(varargin{4})
    num = 1;
else
    num = varargin{4};
end
% if input is a mesh node, do not return the same node
skipID = -Inf;
if isa(coords,'itaMeshNodes') || isa(coords,'itaMicArray')
    skipID = coords.ID;
    coords = coords.cart;
    num = num + 1;
end
% find the next nodes and return them
[ind,dist] = findnearest@itaCoordinates(input,coords,system,num);
res = input.n(ind);
ind  = ind(res.ID~=skipID);
dist = dist(res.ID~=skipID);
res  = res.n(res.ID~=skipID);
end

