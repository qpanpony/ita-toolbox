function file = bindb_fileidpath( location, id )
% Synopsis:
%   file = bindb_fileidpath( location, id )
% Description:
%   Recretes the full path to the file.
% Parameters:
%   (string) location
%	Can have five values, 
%   'rir'       for a room impule response file on the filestorage,
%   'outbox'    for a local room impule response file in the outbox folder,
%   'rirlocal'  for a local room impule response file in the measurements folder,
%   'localdata' any file in the localdata directory (local) or
%   'root'      any file in the bindb root folder. 
%   (int) id
%	Id of the file.
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
file = bindb_filepath(location, [num2str(id) '.mat']);

