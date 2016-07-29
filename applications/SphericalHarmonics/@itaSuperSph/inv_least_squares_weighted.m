function this = inv_least_squares_weighted(this)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

weights = this.spatialSampling.weights;
nSH = size(this.spatialSampling.Y,2);
data = zeros(size(this.data,1),nSH);
for ind = 1:size(this.data,1)
    ind
    data(ind,:) = lscov(this.spatialSampling.Y, this.data(ind,:).', weights);
end
this.data = data;