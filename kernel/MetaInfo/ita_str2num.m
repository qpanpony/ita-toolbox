function output = ita_str2num(input)
%ITA_STR2NUM - convert string to numeric
%  This function converts a string to a numeric using matlabs eval. Function
%  accepts points and commas for decimal mark, prefixes (i.e. k or m) or 
%  simple calculations (for example 1/3, srqt(2) or pi/2). 
% 
%  Syntax:
%   value  = ita_str2num(string)
%   values = ita_str2num(cellOfStrings)
%
%
%  Example:
%       testAll = ita_str2num({'2.1' '2,1' '0,0021k' '0,0021 k' '2100m' '21/10' '21 / 10' '21000k / 10M' '2^16/48000 + 551 / 750' });
%       all(testAll == 2.1)
%
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_str2num">doc ita_str2num</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  01-Oct-2010



%% 

if ischar(input)
    if size(input,1) == 1
        output = myStr2Value(input);
    else   % more than one line
        output = zeros(size(input,1),1);
        for iLine = 1:size(input,1)
            output(iLine) = myStr2Value(input(iLine,:));
        end
    end
elseif iscell(input)
    %     output = cell(size(input));
    output = zeros(size(input));
    for iCell = 1:length(input)
        if ischar(input{iCell})
             output(iCell) = myStr2Value(input{iCell});
        elseif isnumeric(input{iCell})
            output(iCell) = input{iCell};
        else 
            error('wrong datatype')
        end
    end
elseif isnumeric(input)
    output = input;
end



%end function
end
 
% convert one string to value 
function value = myStr2Value(str)

if isempty(strrep(str, ' ', '')) % empty string => NaN
    value = nan; 
else
    str = strrep(str, ',', '.');    % use ponit for decimal mark
    
    str = strrep(str, 'm', 'e-3');
    str = strrep(str, 'k', 'e3');
    str = strrep(str, 'M', 'e6');
    
    str = strrep(str, ' e', 'e');
    
    value = eval([ '[ ' str ']']);  % eval also allows calculations...
    
end
end