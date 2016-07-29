function [ T ] = ita_HRTFarc_ht_DHtrafo( theta, d, a, alpha )
%TEST_ZILLEKENS_HT_DHTRAFO Homogeneous transformation matrix via
%Denavit-Hartenberg (DH) parameter
%
% T = TEST_ZILLEKENS_HT_DHTRAFO( theta, d, a, alpha )
% 
% Rot('z_-1',theta) * Trans([0,0,d]) * Trans([a,0,0]) * Rot('x',aplpha) 
% 
% Rot(axis,angle)  rotation around axis of coordinate system with angle
% Trans([x,y,z])  translation in x, y, z direction.
% 
% angles in radiant
% 
% EXAMPLE:
%       T = test_zillekens_ht_DHtrafo( -pi, 1, 0, pi/8 )
% 
% See also TEST_ZILLEKENS_HT_TRANS TEST_ZILLEKENS_HT_ROT

% Author: Stefan Zillekens
% Created: 2013-07-30

% References:
%   [1] Roßmann, Jürgen: Mensch-Maschine-Interaktion und Robotik I,
%   Institut für Mensch-Maschine-Interaktion, Aachen, 2007

T =   ita_HRTFarc_ht_rot('z',theta) ...
    * ita_HRTFarc_ht_trans([0,0,d]) ...
    * ita_HRTFarc_ht_trans([a,0,0]) ...
    * ita_HRTFarc_ht_rot('x',alpha);

%%
% T = zeros(4);
% T(1:2,1) = [ cos(theta)             sin(theta)                            ];
% T(1:3,2) = [ -cos(alpha)*sin(theta) cos(alpha)*cos(theta)   sin(alpha)    ];
% T(1:3,3) = [ sin(alpha)*sin(theta)  -sin(alpha)*cos(theta)  cos(alpha)    ];
% T(:,4)   = [ a*cos(theta)           a*sin(theta)            d           1 ];           


end

