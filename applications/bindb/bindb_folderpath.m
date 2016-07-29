function folder = bindb_folderpath( location )
% Synopsis:
%   file = bindb_folderpath( location )
% Description:
%   Recretes the full path to the file.
% Parameters:
%   (string) location
%	Can have five values, 
%   'rir'           for a room impule response file on the network folder,
%   'outbox'        for a local room impule response file in the outbox folder,
%   'measurements'  for a local room impule response file in the measurements folder,
%   'localdata'     any file in the localdata directory (local) or
%   'root'          any file in the bindb root folder.
% Returns:
%   (string) folder
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
    folder = bindb_data.Settings.BindbPath;  
elseif strcmp(location, 'localdata')  
    % Local file in localdata folder
    folder = fullfile(bindb_data.Settings.BindbPath, 'localdata');
elseif strcmp(location, 'outbox')    
     % Local room impulse response file in outbox folder
    folder = fullfile(bindb_data.Settings.BindbPath, 'outbox'); 
elseif strcmp(location, 'measurements')    
     % Local room impulse response file in measurements folder
    folder = bindb_data.Settings.MeasurementsPath; 
elseif strcmp(location, 'scripts')    
     % Local room impulse response file in measurements folder
    folder = fullfile(bindb_data.Settings.BindbPath, 'scripts');   
else
    % Network folder path
    folder = bindb_data.ImpulseResponsePath;  
end