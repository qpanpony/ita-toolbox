function ita_plot_rectangular(coord1,coord2)

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

coord1 = coord1.cart;
coord2 = coord2.cart;

lx1 = coord1(1);
ly1 = coord1(2);

lx2 = coord2(1);
ly2 = coord2(2);

line([lx1 lx2],[ly1 ly1],[0 0])
line([lx1 lx2],[ly2 ly2],[0 0])
line([lx1 lx1],[ly1 ly2],[0 0])
line([lx2 lx2],[ly1 ly2],[0 0])