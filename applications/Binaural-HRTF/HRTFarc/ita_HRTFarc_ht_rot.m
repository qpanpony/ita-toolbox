function [ T_rot ] = ita_HRTFarc_ht_rot( rot_axis, phi )
%TEST_ZILLEKENS_HT_ROT Homogenous transformation matrix for a rotation 
%
% T_rot = TEST_ZILLEKENS_HT_TRANS( 'rot_axis', angle ) 
% 
% rot_axis  -  rotatation axis { 'x', 'y', 'z' }
% phi       -  rotation angle in radiant
% 
% EXAMPLE:
%       T_rot = test_zillekens_ht_rot( 'z', pi )
%       % Rotation around z-axis with the angle pi
% 
% See also  TEST_ZILLEKENS_HT_TRANS TEST_ZILLEKENS_HT_DHTRAFO

% Author: Stefan Zillekens
% Created: 2013-07-30

% References:
%   [1] Roßmann, Jürgen: Mensch-Maschine-Interaktion und Robotik I,
%   Institut für Mensch-Maschine-Interaktion, Aachen, 2007

if  ~isscalar(phi)
    error('Expecting a scalar')
end

T_rot = eye(4);

if      rot_axis == 'x'
    T_rot(2:3,2:3)       = [ cos(phi), -sin(phi); ...
                            sin(phi),  cos(phi)  ];
elseif  rot_axis == 'y'
    T_rot(1:2:3,1:2:3)   = [ cos(phi),  sin(phi); ...
                           -sin(phi),  cos(phi)  ];
elseif  rot_axis == 'z'
    T_rot(1:2,1:2)       = [ cos(phi), -sin(phi); ...
                            sin(phi),  cos(phi)  ];   
else
    error('Rotation axis should be x, y or z.')
end   

end

