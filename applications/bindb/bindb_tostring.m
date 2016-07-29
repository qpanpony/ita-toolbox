function out = bindb_tostring( charmat )
% Synopsis:
%   out = bindb_tostring( charmat )
% Description:
%   Converts a multiline char into a string.
% Parameters:
%   (char) charmat
%	The char matrix that will be converted.
% Returns:
%   (string) out 
%	The resulting string

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


out = '';

% Concatenate lines
for index = 1:size(charmat, 1)
    out = [out strtrim(charmat(index, :))];
    if index < size(charmat, 1)
        out = [out '\n'];
    end
end
