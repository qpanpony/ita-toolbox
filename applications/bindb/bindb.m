function bindb()
% Synopsis:
%   bindb() or bindb
% Description:
%   Launch the bindb Toolbox feature.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Register globals
global bindb_data;

if isfield(bindb_data, 'Settings')
    % Launch gui
    bindb_gui();
else
    fprintf(1, 'bindb is not initialized, run <a href="matlab:bindb_setup">bindb_setup</a> first\n');
end

