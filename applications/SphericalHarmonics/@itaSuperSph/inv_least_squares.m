function this = inv_least_squares(this)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

dims = this.dimensions;
nChannelsSpatial = dims(1);
nChannelsOther = prod(dims(2:end));
% nChannels = nChannelsSpatial .* nChannelsOther;

dataS2 = this.data;
pinvY = pinv(this.spatialSampling.Y);
nSH = size(pinvY,1);
this.data = zeros(size(this.data,1),nSH);

for ind = 1:size(this.data,1)
    dataVector = reshape(dataS2(ind,:).',nChannelsSpatial,nChannelsOther);
    for iCh = 1:nChannelsOther                
        this.data(ind,(1:nSH) + (iCh-1)*nSH) = pinvY * dataVector(:,iCh);
    end
end

this.dimensions = [nSH, dims(2:end)];
