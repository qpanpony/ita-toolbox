function bindb_mmtcommit( mmt )
% Synopsis:
%   bindb_measurement_update( varargin )
% Description:
%   Update the online version of the given measurement with the current
%   local data.
% Parameters:
%   (bindb_measurement) measurement
%	The local emasurement used to update the online version.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register gloals
global bindb_data;

% Check if bindb is initialized
if isfield(bindb_data, 'Settings')
    if bindb_isonline()
        if nargin == 1
            bindb_gui_measurement_commit(mmt);
        else
            bindb_gui_measurement_commit();
        end
    else
        fprintf(1, 'not conencted to bindb database, run <a href="matlab:bindb_connect">bindb_connect</a> first\n');
    end
else
    fprintf(1, 'bindb is not initialized, run <a href="matlab:bindb_setup">bindb_setup</a> first\n');
end


end
