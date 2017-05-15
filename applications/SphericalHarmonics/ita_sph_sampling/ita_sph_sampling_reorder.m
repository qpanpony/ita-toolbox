function s = ita_sph_sampling_reorder(s, type)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


switch type
    case 'theta+'
        [s.coord, ix] = sort(s.coord(:,1),1);
    case 'theta-'
        [s.coord, ix] = sort(s.coord(:,1),1,'descend');
    case 'phi+'
        [s.coord, ix] = sort(s.coord(:,2),1);
    case 'phi-'
        [s.coord, ix] = sort(s.coord(:,2),1,'descend');
end

% if isfield(s,'weights'), ...