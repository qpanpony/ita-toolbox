function varargout = ita_itaHRTFCoordinates2SOFACoordinates(hrtfObj,sofaObj)
%ITA_ITAHRTFCOORDINATES2SOFACOORDINATES - +++ Transformes and sets itaHRTFCoordinates to Sofa +++
%  TODO: Full and logical SOFA support. This is just a test
%

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@akustik.rwth-aachen.de
% Created:  30-Sep-2014 



%% main
% get the number of positions
hrtfLeft = hrtfObj.getEar('L');
coordinates = hrtfLeft.channelCoordinates;
numPositions = coordinates.nPoints;
data = zeros(numPositions,3);

% spherical system
data(:,1) = coordinates.phi_deg;
data(:,2) = coordinates.theta_deg -90;
data(:,3) = coordinates.r;



%% set sofa object

%as the hrtf object does not have view and up vectors (yet) just, set the
%standart values

sofaObj.ListenerPosition = [0 0 0];
sofaObj.ListenerView = [1 0 0];
sofaObj.ListenerUp = [0 0 1];

sofaObj.SourcePosition = data;


%% Set Output
varargout(1) = {sofaObj}; 

%end function
end