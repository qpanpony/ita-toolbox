function [DTF, comm] = test_rbo_DTF_itaHRTF(data)
% 'azRing' -> only HRTFs on the ring of el = 90°
% 'Output': 'DTF', 'HRTF', 'comm'
% varargout: left TF, right TF
% Middlebrooks, John C.; Green, David M. (1990): Directional dependence of interaural envelope delays. In: The Journal of the Acoustical Society of America 87, S. 2149.

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



switch data.sphereType
    case 'undefind', error('For Sphere Type ''undefind'' DTF is not possible! ')
end
%% Sampling on the sphere
s = ita_sph_sampling_V000H000(rad2deg(data.phi_Unique),rad2deg(data.theta_Unique));
s.r = ones(s.nPoints,1)*data.dirCoord.r(1);


if strcmpi(data.sphereType,'ring')
    thetaU = 90;
    phiU = unique(round(s.phi_deg));    
    
    s = itaCoordinates;
    s.sph = ones(numel(phiU),3);
    s.theta_deg = ones(numel(phiU),1)*thetaU;
    s.phi_deg = phiU;
    
    weight = ones(numel(phiU),1)/numel(phiU);
    idxSortCoord = s.findnearest(data.dirCoord);
else
    thetaU = unique(s.theta);
    phiU = unique(s.phi);
    
    deltaTheta = mean(gradient(thetaU));
    deltaPhi= mean(gradient(phiU));
    weight = (deltaPhi*(cos(s.theta - deltaTheta/2) -  cos(s.theta + deltaTheta/2)))./(4*pi); % r = 1
    weight(s.theta_deg ==0) = (deltaPhi*(cos(s.theta(s.theta_deg ==0) ) -  cos(s.theta(s.theta_deg ==0) + deltaTheta/2)))./(4*pi);
    weight(s.theta_deg ==180) = (deltaPhi*(cos(s.theta(s.theta_deg ==180) - deltaTheta/2) -  cos(s.theta(s.theta_deg ==180) )))./(4*pi);
    
    % normalize for caps: better ideas?
    weight = weight/sum(weight);
    idxSortCoord = s.findnearest(data.dirCoord);
end

%% Weighting
weight = weight(idxSortCoord);

weightBin = zeros(2*numel(weight),1);
weightBin(1:2:end) = weight;
weightBin(2:2:end) = weight;

weightedEnergy = data;
weightedEnergy.freqData = bsxfun(@times,abs(data.freqData).^2,weightBin');

energySumL = sum(weightedEnergy.freqData(:,weightedEnergy.EarSide=='L'),2);
energySumR = sum(weightedEnergy.freqData(:,weightedEnergy.EarSide=='R'),2);

%% Common part   
comm = data;
comm.freqData(:,1:2:numel(weightBin)) = repmat(sqrt(energySumL),1,numel(weight));
comm.freqData(:,2:2:numel(weightBin)) = repmat(sqrt(energySumR),1,numel(weight));

% adding phase: could be nicer...
comm.freqData = comm.freqData.*exp(1j*abs( hilbert(-log(abs(comm.freqData)))));
comm.TF_type = 'Common';
%% DTF and Comm part
if data.nDirections>1000
    ita_verbose_info(' Wait a few seconds for regularization and nicer IR!', 0);
end
DTF = ita_divide_spk(data,comm,'regularization',[0 20000]);

DTF.channelNames = data.channelNames;
DTF.TF_type = 'DTF';

