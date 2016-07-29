function test_ita_coordinates()

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


a = ita_generate('noise',1,44100,15);
a = ita_split(a,[1 1 1 1]);
a.channelCoordinates = itaCoordinates([1 5 9; 2 6 10; 3 7 11; 4 8 12],'cart');
%a.channelCoordinates = build_search_database(a.channelCoordinates);

[ind, dist] = findnearest(a.channelCoordinates,[2 2 2; 3 3 3],'cart',1); %Check matlab search (few elements)
if ~ind == [2; 3] %#ok<BDSCA>
    error('findnearest@itaCoordinates does not work');
end

[ind, dist] = findnearest([a.channelCoordinates a.channelCoordinates a.channelCoordinates],[2 2 2; 3 3 3],'cart',1); % Check mex-search (lots of elements)



coords = a.channelCoordinates;
tmp = coords.makeSph;
coords_new = tmp.makeCart;
coords_new.cart - coords.cart


tmp = coords.makePol;
coords_new = tmp.makeCart;
coords_new.cart - coords.cart

coords = coords.makeSph;
tmp = coords.makePol;
coords_new = tmp.makeSph;
coords_new.sph - coords.sph

end