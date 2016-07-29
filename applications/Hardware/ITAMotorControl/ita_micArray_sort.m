function [varargout] = ita_micArray_sort(varargin)
% ITA_MICARRAY_SORT -

% <ITA-Toolbox>
% This file is part of the application Movtec for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


sArgs=struct('pos1_micArray', 'itaMicArray');
[micArray sArgs] = ita_parse_arguments(sArgs, varargin);

idx_start=1;
idx_done=1;
num_coords= length(micArray.cart);
newCoords = NaN(num_coords,3);


%coords = itaCoordinates();
%coords.cart=micArray.cart;
coords=micArray;

% bevorzugte Richtung= x-Richtung -> y-Strecken und anschließend wieder
% stauchen.
coords.y=coords.y.*2;

newCoords(1,:)= coords.cart(idx_start,:);
coords=build_search_database(coords);
for i=1:num_coords-1
    z=4;
    nextList=[];
    while isempty(nextList)
    [nextList,dists]=findnearest(coords,coords.n(idx_done(end)),'cart',z);    % für grid=4; quincunx=6 
    for j=1:length(idx_done) 
        idx=find(nextList~=idx_done(j));
        nextList = nextList(idx);
        dists = dists(idx);
    end
    z=z+z;  % maximal Anzahl der Punkte... überprüfen?
    end
    
    % nextList nach den wirklich nächsten sortieren...
    [dists,id]=sort(dists);
    nextList=nextList(id);
    newCoords(i+1,:) = coords.cart(nextList(1),:);
    idx_done = [idx_done nextList(1)];
end

newCoords(:,2)=newCoords(:,2)./2;
newArray = itaMicArray(newCoords,'cart');
%newArray.w = micArray.w;
varargout= {newArray};

end