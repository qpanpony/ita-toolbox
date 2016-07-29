function this = inv_least_squares_weighted_regularizedDuraiswami(this)
% as used in Pollow et al.:
% Calculation of head-related transfer functions for arbitrary field
% points using spherical harmonics decomposition

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
    
    H_diagW_H = this.s.Y' * bsxfun(@times, this.s.weights, this.s.Y);
    
    D = eye(size(this.s.Y,2));
    n = ita_sph_linear2degreeorder(1:size(this.s.Y,2));
    D = bsxfun(@times, D, (1 + n.*(n + 1)));
    eps = 1e-6;
    
    % this is not D, but we want to save memory
    D = H_diagW_H + eps .* D;
    clear H_diagW_H;
    
    % this is not weightedData, but we want to save memory
    weightedData = this.s.Y' * weightedData;
    fMP = D \ weightedData;
    clear D;
%     fMP = ((H_diagW_H + eps .* D) * Y') \ weightedData;
    
    this.data(ind,:) = fMP.';
end