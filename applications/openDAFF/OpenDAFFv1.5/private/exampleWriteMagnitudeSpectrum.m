
%
%  Before you can write a DAFF file, your main task is to define
%  its content. Therefore you must provide the writer script a
%  so called generator function, which delivers it the content
%  for a certain direction.
%
%  Here we use the example generator: TODO
%

% <ITA-Toolbox>
% This file is part of the application openDAFF for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Before writing you can define some metadata for the file, like this:

metadata = [];
metadata = daff_metadata_addKey(metadata, 'Description', 'String', 'Example directivity');
metadata = daff_metadata_addKey(metadata, 'Temperature_Degree_Celsius', 'Float', 21.3);
metadata = daff_metadata_addKey(metadata, 'Averages', 'Int', 12);
metadata = daff_metadata_addKey(metadata, 'Windowed', 'Bool', false);

%
% Now you can write the entire magnitude spectrum DAFF file
%
% The writer will call your generator function for getting the data.
% You provide the writer script the necessary information.
% The following arguments are mandatory:
%
% filename, content, datafunc, channels
%
% All options are documented here: TODO
%

daff_write('filename', 'ms.daff',...
           'content', 'ms', ...
           'datafunc', @dfFrontalHemisphereMS, ...
           'channels', 1, ...
           'alphares', 5, ...
           'betares', 5, ...
           'orient', [0 0 0], ...
           'metadata', metadata);

%
% The writer script will inform you about the progress and problems
% If everything went fine, you get the message:
%
% DAFF file 'ms.daff' successfully written
%
