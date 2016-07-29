function bindb_setadmin( mode )
% Synopsis:
%   bindb_setadmin( mode )
% Description:
%   Turns the admin mode on and off. Admin functions can only be used if in
%   admin mode. These functions all start with 'bindb_admin_'.
% Parameters:
%   (int) mode
%	If true, enter admin mode.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Set admin mode
bindb_data.Settings.AdminMode = mode;

% Display warnings
if mode == 1
    bindb_addlog('system', 'You are now in admin mode. It is now possible to run functions that can severly damage the global data stored with this toolbox.', 1);
else
    bindb_addlog('system', 'Admin mode is off. All functions with names like ''bindb_admin_*'' will not execute.', 1);
end

