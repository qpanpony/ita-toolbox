function [this,ind] = reduce_equiangular_grid(this,resolution)
% Reduce corrdinates, to an equiangular grid, with only that are dividable by resultion
% [grid, ind] returns indexes of remaining points

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


ind = (mod(this.elevation,resolution) < 0.1 | mod(this.elevation,resolution) > (resolution - 0.1)) & (mod(this.azimuth,resolution) < 0.1 | mod(this.azimuth,resolution) > (resolution - 0.1));

this.(this.coordSystem)(~ind,:) = [];

end