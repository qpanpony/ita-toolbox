function string = ita_utils_matrix_to_string(A, order, format_string, sep_string)


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

if nargin < 2
    order = 'column-major';
end

if nargin < 3
    format_string = '%.3e';
end

if nargin < 4
    sep_string = ' ';
end

switch order
    case 'row-major'
        string = row_major(A, format_string, sep_string);
    case 'column-major'
        string = sprintf([format_string sep_string], A);
        string = string(1:end-1);
end

end

function string = row_major(A, format_string, sep_string)
    D = size(A);
    if numel(D) > 2
        tmp = nan(D(2:end));
        substrings = {}; %cell(1, D(1));
        for m = 1:D(1)
            tmp(:) = A(m,:);
            substrings = [substrings {row_major(tmp, format_string, sep_string)}];
        end
    else
        substrings = {}; %cell(1, D(1) * D(2));
        for m = 1:D(1)
            for n = 1:D(2)
                substrings = [substrings {sprintf(format_string, A(m,n))}];
            end
        end
    end
    string = strjoin(substrings, sep_string);
end