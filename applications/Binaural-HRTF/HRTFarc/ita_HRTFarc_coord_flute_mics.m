function [ coord_mics ] = ita_HRTFarc_coord_flute_mics( phi, r_z, d, a, h, gamma, beta, alpha,xOff,yOff)
%TEST_ZILLEKENS_COORD_FLUTE_MICS returns an itaCoordinates containing the position of the 
%flutes mics
% 
% coord_mics = TEST_ZILLEKENS_COORD_FLUTE_MICS(phi, r_z, d)
% coord_mics = TEST_ZILLEKENS_COORD_FLUTE_MICS(phi, r_z, d, a)
% coord_mics = TEST_ZILLEKENS_COORD_FLUTE_MICS(phi, r_z, d, a, h)
% coord_mics = TEST_ZILLEKENS_COORD_FLUTE_MICS(phi, r_z, d, a, h, gamma, beta, alpha)
% 
%       phi     -   vector of the angles phi
%       r_z     -   distance of the mics to center of flute
%       d       -   length of boom arm
% 
%   optional:
%       a       -   distance between joint and boom arm
%       h       -   height of stand to joint in center of turntable (default 0)
% 
%   optional uncertainties: 
%       gamma   -   angle between mic holder and flute (default 0)
%       beta    -   angle between mic stand and mic boom arm (default 0)
%       alpha   -   angle offset of reference point of turntable (default 0)
% 
% See also TEST_ZILLEKENS_HT_DHTRAFO TEST_ZILLEKENS_ERROR_DISTANCE_LS

% Author: Stefan Zillekens
% Created: 2013-09-02

if(nargin < 6)
    gamma       =   0;          % angle beetween mic holder and flute
    beta        =   0;          % angle beetween mic stand and mic boom
    alpha       =   0;          % angle offset of reference point of motor
end
if(nargin < 5)
    h = 0;          
end
if(nargin < 4)
    a = 0;          
end

% init
npos        = numel(phi);
nmic        = numel(r_z);
coord_mics  = itaCoordinates(npos*nmic);
XYZ         = zeros(npos*nmic,3);

for idp = 1:npos;
    for idm = 1:nmic;
        
        % homogeneous transformation matrices:
        T1 = ita_HRTFarc_ht_DHtrafo(-pi/2+phi(idp)+alpha, h, 0, beta);
        T2 = ita_HRTFarc_ht_DHtrafo(+pi/2,a,d,gamma);
        T3 = ita_HRTFarc_ht_DHtrafo(0, r_z(idm), 0, 0);
        T  = T1 * T2 * T3;

        XYZ((idp-1)*nmic+idm, :) = T(1:3,4)';
    end
end
coord_mics.cart = XYZ;
coord_mics.x = coord_mics.x+xOff;
coord_mics.y = coord_mics.y+yOff;

end

