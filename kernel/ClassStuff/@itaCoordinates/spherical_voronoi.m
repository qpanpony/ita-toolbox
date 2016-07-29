function [voronoiNodes, weights, sam2vor] = spherical_voronoi(sampling)
% function [voronoiNodes, weights, sam2vor] = spherical_voronoi(sampling)
% calculates a spherical sampling's the voronoi diagramm to and gives you:
%
% output:
% voronoiNodes : a itaSamplingSph that contains the nodes of 
%                the voronoi diagramm
% weights      : the weights for each sampling point calculated via the
%                size of the voronoi areas. if there are identical sampling
%                points p_x1 p_x2, they 'share' a voronoi area's weight
%                w(p_x1) = w(p_x2) = w_x/2;
%                -> sum(weights) = 4*pi;
%
%                If you want to get the real size of a voronoi area proceed:
%                - make shure, there are no multiple sampling points by
%                  sampling = sampling.n(sampling.kill_multple_points);
%                - [vN, weights] = sampling.spherical_voronoi;
%                - area_size = weights*sampling.r(1)^2;
%
% sam2vor{idxP} : the indices of the voronoi nodes arround a sampling point
%
%
%  Voronoi-Diagramm: Konstruktion allgemein
%  Je drei Sampling-Punkte spannen ein Dreieck auf, auf dem kein anderer
%  Samplingpunkt liegt.
%  Diese drei Punkte liegen auf einem Kreis, dessen Mittelpunkt ein Knoten
%  des Voronoidiagramms ist.
%
%  Die Voronoipunkte, die um einen Samplingpunkt herum liegen, spannen ein
%  Polygon auf, dessen Fläche dem Gewicht des Sampling-Punktes entspricht
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Martin Kunkemoeller
% 10.10.2010

%% delete multiple points ("twins")
[samNoTw2sam sam2samNoTw] = sampling.kill_multiple_points(1e-4);
samplingNoTw = sampling.n(samNoTw2sam);

%% Voronoi Diagramm
%triangularisation of the sampling
DT = DelaunayTri(samplingNoTw.cart).convexHull;
triangles = TriRep(DT, samplingNoTw.cart);

%center of those triangles -> voronoi nodes
voronoiNodes = itaSamplingSph(size(triangles,1));
voronoiNodes.cart = triangles.circumcenters;

%kill multiple voronoi nodes
[vorNoTw2vor vor2vorNoTw] = voronoiNodes.kill_multiple_points(1e-4);
voronoiNodes = voronoiNodes.n(vorNoTw2vor);

%% root sampling points to the sourrounding voronoi nodes : samNoTw2vor and sam2vor
%indices of all voronoi nodes around a samplingNoTw's point : samNoTw2vor
samNoTw2vor = cell(samplingNoTw.nPoints,1);
allIdxVor   = (1:size(DT,1)).';
for idxP = 1:samplingNoTw.nPoints
    %bitmask all the triangles the point samplingNoTw.n(idxP) is an edge of
    idxP2idxVor_dum = allIdxVor .* sum(DT == idxP, 2);
   
    idxP2idxVor = idxP2idxVor_dum(idxP2idxVor_dum ~= 0);
    %maybe one of the voronoi nodes was replaced by its twin...
    idxP2idxVor = vor2vorNoTw(idxP2idxVor);
    for idx = 1:length(idxP2idxVor)
        %bitmaks multiple nodes arround a sampling point
        idxP2idxVor(idx+1:end) = idxP2idxVor(idx+1:end) .* (idxP2idxVor(idx+1:end) ~= idxP2idxVor(idx));
        if idx == length(idxP2idxVor)
            break;
        end
    end
    samNoTw2vor{idxP} = idxP2idxVor(idxP2idxVor ~= 0);
end

sam2vor = cell(sampling.nPoints,1);
for idxP = 1:sampling.nPoints
    sam2vor{idxP} = samNoTw2vor{sam2samNoTw(idxP)};
end


%% weights
% weights of samplingNoTw's points
weightsNoTw = zeros(samplingNoTw.nPoints,1);
for idxP = 1:samplingNoTw.nPoints;    
    % voronoi nodes arround current sampling point
    cN = voronoiNodes.n(samNoTw2vor{idxP});
   
    if cN.nPoints < 3
        error('001');
    end
    
    %cut voronoi region into triangles
    cN_sph = cN.sph;
    tr = DelaunayTri([cN_sph(:,3) cN_sph(:,2)]).Triangulation;
    
    %sum those triangle's area
    cN_cart = cN.cart; %speedup
    for idxT = 1:size(tr,1)
        weightsNoTw(idxP) = weightsNoTw(idxP) + 0.5*norm(cross( ...
            cN_cart(tr(idxT,1),:)-cN_cart(tr(idxT,2),:) , cN_cart(tr(idxT,1),:)-cN_cart(tr(idxT,3),:)));
    end
end

% weights of sampling's points
weights = zeros(sampling.nPoints,1);
for idxP = 1:sampling.nPoints
    weights(idxP) = weightsNoTw(sam2samNoTw(idxP)) / length(sam2samNoTw(sam2samNoTw == sam2samNoTw(idxP)));
end

%convert to bogenmaß
weights = weights/sum(weights)*4*pi;
