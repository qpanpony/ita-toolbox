function [s, sensitivity] = ita_sph_sampling_GfAI_array_xml(filename)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


x = []; y = []; z = [];
sensitivity = [];

s = xml2struct(filename);
connector = s.AC_ARRAY.CONNECTORS;
cons = fieldnames(connector);
for indC = 1:numel(cons)
    microphones = connector.(cons{indC}).MICROPHONES;
    mics = fieldnames(microphones);
    for indM = 1:numel(mics)
        %#ok<*AGROW> % keine Warnung für wachsende Variablen
        x = [x; str2double(microphones.(mics{indM}).POS_X.Attributes.Value)];
        y = [y; str2double(microphones.(mics{indM}).POS_Y.Attributes.Value)];
        z = [z; str2double(microphones.(mics{indM}).POS_Z.Attributes.Value)];
        sensitivity = [sensitivity; ...
            str2double(microphones.(mics{indM}).TRANSFORMFACTOR.Attributes.Value)];
    end
end

s = itaSamplingSph(numel(x));
s.x = x; s.y = y; s.z = z;

end