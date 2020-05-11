function  weights = ita_vbap_pan(pos_LS,pos_VS,varargin)
%panVBAP - Calculate weights for VBAP
%
%  This function receives the position of the loudspeakers and the position
%  of the virtual source. Both input must be given as objects of the class
%  itaCoordinates.
%
%  The output is the set of frequency independent weights used to pan the
%  virtual source on the given array.
%
%  Call:  weights = panVBAP(pos_LS,pos_VS)
%
% Author: Michael Kohnen -- Email: mko@akustik.rwth-aachen.de
% Former author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  13-Jun-2011
% Last modified: 10-july-2019
%$ENDHELP$

%% Preliminary tests
opts.distanceloss = true;
opts.normalizationGain=1;
opts.minimumDistance=0.25;
opts=ita_parse_arguments(opts,varargin);

% Init
weights = zeros(pos_VS.nPoints,pos_LS.nPoints);

if pos_VS.r == 0
    error('No direction for Virtual Source was given!')
end

pos_VS.r( pos_VS.r<opts.minimumDistance ) = opts.minimumDistance;

origDistances = pos_VS.r;

pos_VS.r=mean(pos_LS.r);



%% Find the closest loudspeakers
% Calculate the distance of each loudspeaker to the virtual source with the
% help of the itaCoordinate overloaded function itaCoordinate.r.
% To sort the distance in ascending value, use the function sort.
aux = pos_LS - pos_VS;
dist = aux.r;
[junk,index] = sort(dist,'ascend');
index = index(1:3);

active_loudspeakers = pos_LS.n(index);

%% Calculate the weights for the active loudspeakers
% Create a base matrix with the direction of the active loudspeakers and
% multiply the direction of the virtual source with the inverse of this
% matrix.
% Don't forget to normalize yor results with C = 1;
for idx = 1:pos_VS.nPoints
    p = pos_VS.n(idx).cart;
    L = active_loudspeakers.cart;
    g = p*pinv(L);
    % Re-normalize
    g = abs(g)/norm(g);
    weights(idx,index) = (g./origDistances(idx).*pos_LS.r(index)');
end

