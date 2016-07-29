function String = popup_index_to_string(List,index)

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>

List = ['|' List '|'];

if size(List,1) == 1
    tokens = strfind(List,'|');
    %tokens = [0 tokens length(List)+1];
    %index = index+1;
    StrIdx = max(tokens(index)+1,1):min(tokens(index+1)-1,length(List));
    String = List(StrIdx);
else
    String = List(:,index);
    
end