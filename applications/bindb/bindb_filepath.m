function file = bindb_filepath( location, name )
% Synopsis:
%   file = bindb_filepath( location, name )
% Description:
%   Recretes the full path to the file.
% Parameters:
%   (string) location
%	Can have five values, 
%   'rir'           for a room impule response file on the network folder,
%   'outbox'        for a local room impule response file in the outbox folder,
%   'measurements'  for a local room impule response file in the measurements folder,
%   'scripts'       for a script file in the scripts folder,
%   'localdata'     any file in the localdata directory (local) or
%   'root'          any file in the bindb root folder.
%   (string) name
%	Name of the file.
% Returns:
%   (string) file
%	The full path to the file.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Recreate path
if strcmp(location, 'root')    
    % Local file in root folder
    file = fullfile(bindb_data.Settings.BindbPath, name);  
elseif strcmp(location, 'localdata')  
    % Local file in localdata folder
    file = fullfile(bindb_data.Settings.BindbPath, 'localdata', name);
elseif strcmp(location, 'outbox')    
     % Local room impulse response file in outbox folder
    file = fullfile(bindb_data.Settings.BindbPath, 'outbox', name); 
elseif strcmp(location, 'measurements')    
     % Local room impulse response file in measurements folder
    file = fullfile(bindb_data.Settings.MeasurementsPath, name); 
elseif strcmp(location, 'scripts')
    file = fullfile(bindb_data.Settings.BindbPath, 'scripts', name(1:end-2));
else
    % Room impulse response file on network folder
    file = fullfile(bindb_data.ImpulseResponsePath, name);  
end
