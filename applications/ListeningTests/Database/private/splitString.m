function [stringOutput] = splitString (stringInput, pattern)

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%%
%splits a string into stringelements, which are seperated by cuts
%result is saved in a string cell and returned

if isempty(stringInput)
    stringOutput = '';
    return
end

%cut off first patterns
while stringInput(1) == ' ' || stringInput(1) == pattern
    stringInput = stringInput(2:end);
end

cuts = strfind(stringInput, pattern);
cuts = [1 cuts];
n = length(cuts);
stringOutput = repmat({''},n,1);

for k = 2:n
    stringOutput{k-1} = stringInput(cuts(k-1):cuts(k));
    %eleminate ' ' and ','
    while stringOutput{k-1}(1) == ' ' || stringOutput{k-1}(1) == pattern
        stringOutput{k-1} = stringOutput{k-1}(2:end);
    end
    while stringOutput{k-1}(end) == ' ' || stringOutput{k-1}(end) == pattern
        stringOutput{k-1} = stringOutput{k-1}(1:end-1);
    end
    
end

stringOutput{n} = stringInput(cuts(n):end);
%eleminate ' ' and ','
while stringOutput{n}(1) == ' ' || stringOutput{n}(1) == pattern
    stringOutput{n} = stringOutput{n}(2:end);
 end
 while stringOutput{n}(end) == ' ' || stringOutput{n}(end) == pattern
    stringOutput{n} = stringOutput{n}(1:end-1);
 end