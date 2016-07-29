function hull = ita_sph_convexhull(this)
    % use unity radius to create triangularisation

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    this.r = 1;
    % do triangularisation and then use the old radius again
    dt = DelaunayTri(this.cart);
    % check for duplicate data points
    if size(dt.X,1) ~= size(this.cart,1)
        error('for now')
        ita_verbose_info('Duplicate data points detected, some points will be ignored.',0);
        % look for double points and use the first one
        indexOfUsedPoints = zeros(size(dt.X,1),1);
        for ind = 1:numel(indexOfUsedPoints)
            indexOfUsedPoints(ind) = find(all(bsxfun(@minus, this.cart, dt.X(ind,:)) == 0,2),1,'first');
        end
        this.cart = this.cart(indexOfUsedPoints,:);
        r = r(indexOfUsedPoints,:);
        color = color(indexOfUsedPoints,:);
    end
    hull = dt.convexHull;
end
