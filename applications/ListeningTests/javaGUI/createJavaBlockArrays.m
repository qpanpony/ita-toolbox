      function[azimuthArray, elevationArray, widthArray, addWidthArray] = ...

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

                createJavaBlockArrays (nAzimuth, nElevation, minElevation, maxElevation)
           
            %check for input errors
            if minElevation >= 180 || minElevation < 0
                minElevation = 0;
            end
            if maxElevation <= 0 || maxElevation > 180
                maxElevation = 180;
            end
            if minElevation > maxElevation
               temp = minElevation; 
               minElevation = maxElevation;
               maxElevation = temp;
            end
            
            stepAzimuth = 360/nAzimuth;
            stepElevation = (maxElevation-minElevation)/(nElevation-1);
            
            azimuth = 0:stepAzimuth:359;
            azimuthArray = [];
            for idxElevation = 1:nElevation                
                azimuthArray = [azimuthArray, azimuth];
            end
            
            elevation = maxElevation:(-stepElevation):minElevation;
            elevationArray = zeros(1, nElevation*nAzimuth);
            for idxElevation = 0:nElevation-1 
                elevationArray(idxElevation*nAzimuth+1:nAzimuth*(idxElevation+1)) = elevation(idxElevation+1);
            end
            
            width = min(stepAzimuth, stepElevation)/2;
            
            widthArray = zeros(1, nElevation*nAzimuth);
            widthArray = widthArray+width;
            
            addWidthArray = widthArray;
        end