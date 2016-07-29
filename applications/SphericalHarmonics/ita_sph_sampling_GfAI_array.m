function [s, sensitivity] = ita_sph_sampling_GfAI_array(filename)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


fid = fopen(filename);
tline = fgetl(fid);

ind = 0;
while ischar(tline)
%     disp(tline)
    if strcmp(tline,'Typ: ArrayMic')
        while numel(tline)
            tline = fgetl(fid);
            if numel(tline > 3)
                if strcmp(tline(1:4),'xPos')
                    ind = ind + 1;
                    x(ind) = str2double(tline(7:end));
                elseif strcmp(tline(1:4),'yPos')
                    y(ind) = str2double(tline(7:end));
                elseif strcmp(tline(1:4),'zPos')
                    z(ind) = str2double(tline(7:end));
                elseif strcmp(tline(1:5),'Trans')
                    sensitivity(ind) = str2double(tline(8:end));
                end
            end
        end
    end
    tline = fgetl(fid);
end

s = itaSamplingSph(numel(x));
s.x = x; s.y = y; s.z = z;
end