function [fMax, fMean] = preprocessingMode(varargin)
% This functions gets two object from type itaMeshNodes and itaMeshElements
% and calculates the highest reasonable frequency for all elements of the 
% given mesh (fMean). As addition the highest reasonable frequency (fMax) 
% for the biggest element is given back.

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargin ==2
    if isa(varargin{1},'itaMeshNodes') && isa(varargin{2},'itaMeshElements')
        coord = varargin{1};
        elements = varargin{2};
    else
        error('preprocessingMode: Invalid inputs!')
    end
else
    error('preprocessingMode: Invalid number of inputs!')
end

%% Initialization
c=343.7;
dMin = sqrt((max(coord.x)-min(coord.x))^2+(max(coord.y)-min(coord.y))^2+(max(coord.z)-min(coord.z))^2); % maximale Größe als Startwert
dMean = 0;
dMax = 0;
fMean = 0; 
fMax = c/(3*dMin);
for i1 = 1:length(elements.nodes(:,1))
    % calculation of thelocal minimal and maximal distances
    elemTemp = elements.nodes(i1,:);
    try
    xTemp = coord.x(elemTemp); yTemp =  coord.y(elemTemp); zTemp= coord.y(elemTemp);
    catch
        disp('');
    end
    for i2 = 1:length(elements.nodes(1,:)) 
        for i3 = i2:length(elements.nodes(1,:))
            if i2~=i3
                dTemp =sqrt((xTemp(i2)-xTemp(i3))^2+(yTemp(i2)-yTemp(i3))^2+(zTemp(i2)-zTemp(i3))^2);
                if dTemp > dMax
                    dMax = dTemp;
                end
                if dTemp < dMin
                    fMax = c/(6*dTemp);
                    dMin = dTemp;
                end
                if dTemp > dMean
                    dMean = dTemp;
                end
            end
        end
    end
    fMean = fMean + c/(3*dMean*length(elements.nodes(:,1)));
    dMean = 0;
end