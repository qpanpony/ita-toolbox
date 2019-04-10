function disp( obj )
% Displays itaZOOMSession

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

disp_str = '';
disp_str = [ disp_str sprintf( ' -- itaZOOMSession -----------\n' ) ];
disp_str = [ disp_str sprintf( '\tProject name: %s\n', obj.project_name ) ];
disp_str = [ disp_str sprintf( '\tPath: %s\n', obj.path ) ];
disp_str = [ disp_str sprintf( '\tStartdate: %s\n', datestr( obj.startdate ) ) ];

disp( disp_str )

end
