function res = ita_preferences_roomacoustics()

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if nargout == 0 % Show GUI
    ita_roomacoustics_parameters();
else
    % ITA_PREFERENCES_ROOMACOUSTICS - preferences for roomacoustics
    res = {'roomacousticParameters',ita_roomacoustics_parameters('getDefaultStruct'),'*struct','Parameters','roomacoustic parameters',3;...
%         'roomacousticEquipment',ita_roomacoustics_equipment('values'),'*int','Equipment','roomacoustic equipment',3;...
        'RoomAcousticsPreferences','ita_roomacoustics_parameters','simple_button','App: Room Acoutics','empty is for full screen, any other number will result in a fixed ratio of height and width.',4;...
        };
end