function [absorp, scatter] = readRavenMaterial(materialName, pathToMaterials)


% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    if nargin < 2
        pathToMaterials = '..\RavenDatabase\MaterialDatabase';
    end    

    if isequal(materialName(end-4:end), '.mat')
        materialName = materialName(1:end-4);
    end

    ini = IniConfig();    
    ini.ReadFile(fullfile(pathToMaterials, [materialName '.mat']));

    absorp = ini.GetValues('Material', 'absorp');
    
    if nargout > 1
        scatter = ini.GetValues('Material', 'scatter');
    end
end
