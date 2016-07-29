function [ T_trans ] = test_rbo_zillekens_ht_trans( coord )
%TEST_ZILLEKENS_HT_TRANS Homogenous transformation matrix for a translation 
%
% Ttrans = TEST_ZILLEKENS_HT_TRANS( coord ) 
% Ttrans = TEST_ZILLEKENS_HT_TRANS( itaCoordinates )
% 
% EXAMPLE:
%       Ttrans = test_zillekens_ht_trans( [1, 0, 0] )
%       % Translation of 1 in x direction
%       Ttrans = test_zillekens_ht_trans( itaCoordinates )
% 
% See also TEST_ZILLEKENS_HT_ROT TEST_ZILLEKENS_HT_DHTRAFO

% Author: Stefan Zillekens
% Created: 2013-08-22

% References:
%   [1] Roßmann, Jürgen: Mensch-Maschine-Interaktion und Robotik I,
%   Institut für Mensch-Maschine-Interaktion, Aachen, 2007

% convert from itaCoordinates
% if isa(coord, 'itaCoordinates')
%     coord = coord.cart;
% end
% 
% coord = coord(:);

if ~isvector(coord) || length(coord)~= 3;
    error('Invalid size of input data. Expecting [x,y,z] or an itaCoordinate')
end

T_trans = eye(4);
T_trans(1:3,4) = coord;
       

end

