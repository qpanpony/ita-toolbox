function weights = ita_spherical_weights_equiangular(coordObj, varargin)
%ita_spherical_weights_equiangular - Calculates the weights for a spherical
%equiangular sampling.
% Also works for spherical sectors (non full sphere coords) andif there is
% an oversampling at the poles (pseude equiangular samplings)
%
%   Syntax:
%   weights = ita_spherical_weights_equiangular(coordObj, 'tolerance', 0.1)
%
%   Options (default):
%   tolerance (0.1): Absolute tolerance in degrees to find unique angles

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

%% Initialization and Input Parsing
sArgs        = struct('tolerance',0.1);
sArgs = ita_parse_arguments(sArgs,varargin); 

%% Init Tolerance
toleranceAbs = sArgs.tolerance; %deg
toleranceRelTheta = toleranceAbs / max( abs( coordObj.theta_deg ));
toleranceRelPhi = toleranceAbs / max( abs( coordObj.phi_deg ));

%% Init Theta
[theta,~] = sort( uniquetol(coordObj.theta,toleranceRelTheta) );
resolutionTheta = mean(diff(theta));

%% Limits for theta integration
deltaTheta = resolutionTheta/2;
th1 = theta - deltaTheta;
th2 = theta + deltaTheta;

% theta is only defined from 0 to 180 deg, bring out-values to the border
th1(th1 < 0) = 0; 
th2(th2 > deg2rad(180)) = deg2rad(180); 

%% Weights for Theta
weightsTheta = (cos(th1)-cos(th2));             % absolute weight for every theta
weightsTheta = weightsTheta./sum(weightsTheta); % normalize


%% Weights along Phi
[~,idx] = ismembertol(coordObj.theta,theta, toleranceRelTheta);
weights = weightsTheta(idx);


% Compensation if number of poles < number of phi values
% (e.g. no duplicates at pole)
idxNorthPole = abs(coordObj.theta_deg - 0) < toleranceAbs;
idxSouthPole = abs(coordObj.theta_deg - 180) < toleranceAbs;
idxNotAtPole = ~(idxNorthPole | idxSouthPole);

nPolesNorth = sum(idxNorthPole);
nPolesSouth = sum(idxSouthPole);
nPhi = numel( uniquetol(coordObj.phi, toleranceRelPhi) );

%Normalize
weights(idxNorthPole) = weights(idxNorthPole) ./ nPolesNorth;
weights(idxSouthPole) = weights(idxSouthPole) ./ nPolesSouth;
weights(idxNotAtPole) = weights(idxNotAtPole) ./ nPhi;

end