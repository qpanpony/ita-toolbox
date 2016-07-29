function IDX = ita_tpa_DOF2index(selectDOF,nPoints,DOF)

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

IDX = [];
for idx = 1:nPoints
    IDX = [IDX (idx-1)* DOF + selectDOF];
end
end