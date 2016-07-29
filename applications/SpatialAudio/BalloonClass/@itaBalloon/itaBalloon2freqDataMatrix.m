function bigMatrix = itaBalloon2freqDataMatrix(itaBall,varargin)
%exports all data in a matrix
% size(matrix) = [number of points, number of channels, number of frequency bins ]

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

sArgs = struct('channels',itaBall.channels, 'points', 1:itaBall.nPoints);
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

bigMatrix = itaBal.mData.get_data(sARgs.points, sArgs.channels, 1:itaBal.nBins);
bigMatrix = itaBal.deequalize(this, bigMatrix, sArgs.channels);
end
