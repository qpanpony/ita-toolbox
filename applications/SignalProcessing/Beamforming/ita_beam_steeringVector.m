function v = ita_beam_steeringVector(k,arrayPositions,scanPositions,waveType)

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

if nargin < 4
    waveType = 2;
end

%% distance vectors only computed once
d0 = get_distances(scanPositions,mean(arrayPositions,1));

%% calculate plane wave distance differently for phase term
if waveType == 1
    scanPositions = bsxfun(@minus,scanPositions,mean(arrayPositions,1));
    arrayPositions = bsxfun(@minus,arrayPositions,mean(arrayPositions,1));
    di = bsxfun(@rdivide,scanPositions*arrayPositions.',d0);
else
    di = get_distances(scanPositions,arrayPositions);
end

%% across frequency
v = zeros(numel(k),size(arrayPositions,1),size(scanPositions,1));
for iScan = 1:size(scanPositions,1)
    % calculate manifold vector
    v(:,:,iScan) = steering_vector_sub(k,di(iScan,:),d0(iScan),waveType);
end
v = bsxfun(@rdivide,v,sum(abs(v).^2,2));

end

%% subfunctions
function v = steering_vector_sub(k,di,d0,type)
% calculate manifold vector for all wave types
v = exp(-1i*bsxfun(@times,k,di));
switch type
    case 1 % plane waves
        v = 1./v;
    case 2 % spherical waves
        v = bsxfun(@rdivide,v,di);
    case 3 % spherical waves, relative to array center, d0 term for level cancels out during normalization
        v = bsxfun(@rdivide,v,bsxfun(@times,exp(-1i*bsxfun(@times,k,d0)),di));
    case 4 % spherical waves relative to array center w/o 1/r
        v = bsxfun(@rdivide,v,exp(-1i*bsxfun(@times,k,d0)));
    otherwise
        error([upper(mfilename) ':type of manifold vector not valid']);
end
end % function