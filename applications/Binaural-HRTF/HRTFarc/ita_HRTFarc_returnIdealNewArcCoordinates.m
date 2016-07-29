function coord = ita_HRTFarc_returnIdealNewArcCoordinates
% Returns an itaCoordinates according to the ideal sampling of the HRTF arc 2.0.
% 
% equiangular sampling with elevation values of 2.52
% this is simmilar to a gaussian sampling with order 70
% the sampling is taken up to 160 deg elevation (64 loudspeakers)
% coord = test_richter_returnIdealNewArcCoordinates
% 
% 
% See also ITACOORDINATES

% Author: Jan Richter
% Created: 2015-05-27
%% ideal Position of LS
radius              =   1.2; 
nLS                 =   64;
sampling            =   ita_generateSampling_equiangular(45,2.52);  %this slows it down
thetaValues         =   unique(sampling.theta_deg)+2.52/2;
thetaValues         =   thetaValues(thetaValues <161);
% sampling                   =   [sampling(nLS:-2:2); sampling(1:2:nLS)];

coord               =   itaCoordinates(nLS);
coord.theta_deg         =   flipud(thetaValues);
coord.r             =   radius;
coord.phi_deg           =   0*ones(nLS,1);

end