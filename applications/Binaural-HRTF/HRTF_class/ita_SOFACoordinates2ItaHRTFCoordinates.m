function varargout = ita_SOFACoordinates2ItaHRTFCoordinates(handleSofa)
% - +++ Short Description here +++
%  TODO: Full and logical SOFA support. This is just a test


% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Jan Gerrit Richter -- Email: jan.richter@akustik.rwth-aachen.de
% Created:  13-May-2014 


%% Initialization and Input Parsing

%% TODO: check the handle


%% main
% get the number of positions
numPositions = length(handleSofa.SourcePosition);

coordinates = itaCoordinates(numPositions);

data = handleSofa.SourcePosition;

if ~(strcmp('spherical',handleSofa.SourcePosition_Type))
   % cartesian system
    ita_verbose_info('No spherical coordinate system. Not tested');
    coordinates.x = data(:,1);
    coordinates.y = data(:,2);
    coordinates.z = data(:,3);
else
    % spherical system
    coordinates.phi_deg = data(:,1);
    coordinates.theta_deg = data(:,2)+90;
    coordinates.r = data(:,3);
end


listenerView = handleSofa.ListenerView;
if ~(length(handleSofa.ListenerView) == 3)
  ita_verbose_info('view vector dimensions are funky - There might be a problem');  
  listenerView = handleSofa.ListenerView(1,:);
end
    
if sum(listenerView == logical([1 0 0])) ~= 3
    ita_verbose_info('Non standard view vector. Not implemented - Coordinate System probably wrong');
end





%% Set Output
varargout(1) = {coordinates}; 

%end function
end