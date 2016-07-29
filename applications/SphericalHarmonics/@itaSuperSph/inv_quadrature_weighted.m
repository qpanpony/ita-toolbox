function this = inv_quadrature_weighted(this)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% TODO: implement for higher dimensions (as in inv_least_squares_weighted)

dataS2 = this.data;
this.data = zeros(size(dataS2,1), size(this.s.Y,2));
for ind = 1:size(this.data,1)
    dataVector = dataS2(ind,:).';
    weightedData = dataVector .* this.spatialSampling.weights;        
    this.data(ind,:) = (this.spatialSampling.Y' * weightedData).';
end