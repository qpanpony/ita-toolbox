function [idNoTw, idAll2idNoTw] = kill_multiple_points(coord,tol)
%function [idNoTw, idAll2idNoTw] = kill_multiple_points(coord,tol)
%
% eleminates identical points of an itaCoordinate
%
%idNoTw : indices of all non multiple points
%         -> coordNoTwins = coord.n(idNoTw);
%idAll2idNoTw : roots all points of coord 2 the new sampling
% Martin Kunkemoeller
% 10.10.2010

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>



if ~exist('tol','var')
    tol = 0;
end

idNoTw       = (1:coord.nPoints).';
idAll2idNoTw = (1:coord.nPoints).';

x = coord.x;
y = coord.y;
z = coord.z;

for idx = 1 : length(idNoTw)-1
    %Bitmask the entries in idNoTw(idx+1:end), which must be killed (twins)
    kill = ...
        sum(abs([x(idNoTw(idx+1:end)) - x(idNoTw(idx)), ...
                 y(idNoTw(idx+1:end)) - y(idNoTw(idx)), ...
                 z(idNoTw(idx+1:end)) - z(idNoTw(idx))]).^2,2) <= tol^2; %squar minimal distance
                 
	twins = idNoTw(idx+1:end) .* kill; 
    twins = twins(twins~=0);
    
    idAll2idNoTw([idNoTw(idx); twins]) = idx;
    
    idNoTw(idx+1:end) = idNoTw(idx+1:end) .* ~kill;
    idNoTw = idNoTw(idNoTw~=0);
   
    
    if idx == length(idNoTw)
        break;
    end
end