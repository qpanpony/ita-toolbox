function index = popup_string_to_index(List,String)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

List = ['|' List '|'];
String = ['|' String '|'];
tokens = [0 strfind(List,'|')];
StrIdx = strfind(List,String);

if ~isempty(StrIdx)
    index = find(tokens<StrIdx,1,'Last');
else % No Match, StrIdx is empty
    index = 1;
end
