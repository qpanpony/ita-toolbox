function [ind, dist] = findnearest(this,coords,system,num)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


if ~exist('system','var') || isempty(system)
    % assume cartesian coordinates if no system is given
    system = 'cart'; %this.mCoordSystem;
end

if ~exist('num','var')
    num = 1;
end


if isnumeric(coords)
    coords = itaCoordinates(coords,system);
end
coords = makeCart(coords);
this = makeCart(this);

if exist('KNNSearch','file') == 3 && ~isempty(this.mPtrtree) % Only if external mex file exists and there are a lot of elements
    %% Using external mex file
    [ind,dist] = KNNSearch(this.cart,coords.cart,this.mPtrtree,num);
else
    %% Old one, using Matlab code
    if ita_preferences('verboseMode') && size(this.cart,1) > 10
        disp('findnearest@itaCoordinates: You can speed this up by calling ''build_search_database'' prior to the search')
    end
    for idinput = 1:size(coords.cart,1)
        dists = sqrt(sum((this.cart-repmat(coords.cart(idinput,:),size(this.cart,1),1)).^2,2));
        for idx = 1:num
            [dist(idinput, idx), ind(idinput, idx)] = min(dists); %#ok<AGROW>
            dists(ind(idinput, idx)) = inf;
        end
    end
end
end