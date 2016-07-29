function cells = bindb_indexcells( length, error )
% Synopsis:
%   cells = bindb_indexcells( length, error )
% Description:
%   Creates a cell array containing indices or error if length < 1.
% Parameters:
%   (int) length
%	Amount of indices in cells.
%   (string) error
%	The content of cells if length < 1.
% Returns:
%   (cell array) cells
%   List of indices from 1 to length, or error if length < 1.

% <ITA-Toolbox>
% This file is part of the application bindb for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Create cells
if length == 0
    cells = { error };
else
    cells = [];
    for index = 1:length
        cells = [cells, {num2str(index)}];
    end
end

