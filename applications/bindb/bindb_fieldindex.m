function index = bindb_fieldindex( name )
% Synopsis:
%   index = bindb_fieldindex( name )
% Description:
%   Returns the index of a given field as depicted in the bindb_data.Fields
%   array.
% Parameters:
%   (string) name
%	The name of the field.
% Returns:
%   (int) index
%	The index of the field. Returns 0 if the field is not found.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

% Search field
for index=1:length(bindb_data.Fields)
    if strcmp(bindb_data.Fields(index).Name, name)
        return;
    end    
end

index = 0;
