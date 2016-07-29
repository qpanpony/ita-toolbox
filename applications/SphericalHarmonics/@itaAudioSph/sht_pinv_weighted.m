function this = sht_least_squares_weighted(this)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% preable (copy this block if you make your own transform)
if ~strcmp(this.spatialDomain,'SH')
    return;
end
s = this.spatialSampling;
data = this.data;
this.data = zeros(size(data,1),size(s.Y,2));

%% algorithm
for ind = 1:size(data,1)
    dataVector = data(ind,:).';
    this.data(ind,:) = lscov(s.Y, dataVector, s.weights);
end
this.spatialDomain = 'SH';
end