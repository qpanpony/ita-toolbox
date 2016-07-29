function [ err ] = ita_HRTFarc_error_distance_LS( x, toa, phi, r_z, SR )
%TEST_ZILLEKENS_ERROR_DISTANCE_LS returns the result of a least-mean square
%error
% 
% err = TEST_ZILLEKENS_ERROR_DISTANCE_LS( x, toa, phi, r_z )
% err = TEST_ZILLEKENS_ERROR_DISTANCE_LS( x, toa, phi, r_z, SR )
% 
% x     -   containg a vector of LS coordinates, latency sample between DA
%           converters, alpha, beta, gamma, d, height, speed of sound
% toa   -   vector of time of arrivals
% phi   -   vector of phi position of flute mics
% r_z   -   vector with distances of mics to center of flute
% SR    -   sampling rate
% 
% See also TEST_ZILLEKENS_COORD_FLUTE_MICS TEST_ZILLEKENS_OPTIMIZE_COORD_ARCLS

% Author: Stefan Zillekens
% Created: 2013-09-09

if nargin < 5
    SR = 44100;
end

nopt = 8;   % number of values to optimize
npos = numel(phi);
nmic = numel(r_z);
nLS  = (numel(x)-nopt)/3;
if numel(toa) ~= nLS*npos*nmic;
    error('Dimensions do not fit')
end

%% uncertainties:
a           =   x(end-7);      % distance from joint to boom arm          ~4cm
d           =   x(end-6);       % length of boom arm
% height  = x(end-4);
c_meas      =   x(end-5);       % Speed of Sound
alpha       =   x(end-4);       % angle offset of reference point of TT    ~0
% alpha   =  0;
beta        =   x(end-3);       % angle between mic stand and mic boom     ~pi/2
gamma       =   x(end-2);       % angle between mic holder and flute       ~0
xOff        =   x(end-1);
yOff        =   x(end);
% latency     =   x(end-4:end);   % relative changes in latency of D/A converter
latency     =   zeros(1,8);
%% calculate mic coordinations via homogeneous transforms
 height  = 0;
coord_mics = ita_HRTFarc_coord_flute_mics(phi,r_z,d,a,height,gamma,beta,alpha,xOff,yOff);

c_meas = 344;
%% error calculation
micsCart = coord_mics.cart;


% tao MxLSxP
 toa_reshape = reshape(toa,nmic,nLS,npos);

% only for the measurements from 28/29.05
% toa_reshape(:,8:8:32,:) = 0;
% toa_reshape(:,19:20,:) = 0;
toa_corrected = reshape(toa_reshape,1,nmic*nLS*npos);
%p1 3xMxLSxP
micPos = reshape(micsCart.',3,nmic,1,npos);
micPos = repmat(micPos,[1,1,nLS,1]);
micPos = reshape(micPos,3,nLS*npos*nmic);
%p2 3xMxLSxP
lsPos = reshape(x(1:end-nopt),3,nLS);
lsPos = repmat(lsPos,[1,1,nmic,npos]);
lsPos_reshape = permute(lsPos,[1 3 2 4]);
lsPos = reshape(lsPos_reshape,3,nLS*npos*nmic);

diffMatrix = lsPos-micPos;
dist = sqrt(diffMatrix(1,:).^2+diffMatrix(2,:).^2+diffMatrix(3,:).^2);

dist_reshape = reshape(dist,nmic,nLS,npos);
% dist_reshape(:,8:8:32,:) = 0;
% dist_reshape(:,19:20,:) = 0;
dist_corrected = reshape(dist_reshape,1,nmic*nLS*npos);

err = (dist_corrected-toa_corrected/SR*c_meas).';
end




