function this = sht_exact(this)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

dataS2 = this.data;
this.data = zeros(size(data,1),size(s.Y,2));
for ind = 1:size(data,1)
    dataVector = dataS2(ind,:).';
    weightedData = dataVector .* this.spatialSampling.weights;        
    this.data(ind,:) = (this.spatialSampling.Y' * weightedData).';
end