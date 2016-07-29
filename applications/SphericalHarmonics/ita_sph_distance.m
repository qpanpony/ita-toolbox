function result = ita_sph_distance(point1, point2)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


lat1 = point1(:,1);
lon1 = point1(:,2);

lat2 = point2(:,1);
lon2 = point2(:,2);

result = distance([pi/2 - lat1 lon1], [pi/2 - lat2 lon2], 'radians');