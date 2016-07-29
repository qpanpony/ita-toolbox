function v = manifoldVector(k,arrayPos,scanPos,type)

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

if nargin < 4
    type = 2;
end
nMics = size(arrayPos,2);
nScanPoints = size(scanPos,2);
% get centroid of array and shift array and scanmesh accordingly
r_0      = (round((10^4).*mean(arrayPos,2))./10^4);
scanPos  = scanPos - r_0(:,ones(1,nScanPoints));
arrayPos = arrayPos - r_0(:,ones(1,nMics));
d_scan = sqrt(sum(abs(scanPos).^2));
% % create manifold vector
try
    v = ita_beam_manifoldVectorMex(k,arrayPos,scanPos,d_scan,type);
catch %#ok<CTCH>
    switch type
        case 1 % plane waves
            d = ((arrayPos.'*scanPos))./d_scan(ones(nMics,1),:);
            v = exp(1i*k.*d);
        case 2 % spherical waves
            d = zeros(nMics,nScanPoints);
            for i=1:nMics
                d(i,:) = d_scan-sqrt(sum(abs(repmat(arrayPos(:,i),1,nScanPoints) - scanPos).^2));
            end
            v = exp(1i*k.*d).*d_scan(ones(nMics,1),:)./(d_scan(ones(nMics,1),:)-d);
        case 3 % spherical w/o 1/r
            d = zeros(nMics,nScanPoints);
            for i=1:nMics
                d(i,:) = d_scan-sqrt(sum(abs(repmat(arrayPos(:,i),1,nScanPoints) - scanPos).^2));
            end
            v = exp(1i*k.*d);
        otherwise
            error([upper(mfilename) ':type of manifold vector not valid']);
    end
end
end