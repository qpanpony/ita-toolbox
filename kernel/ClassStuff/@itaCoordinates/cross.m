function n = cross(v1,v2)
% calculate the cross product of two vectors, delivering the perpendicular
% vector to these two vectors.

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


n = itaCoordinates(1);
n.cart = cross(v1.cart,v2.cart);
end %eof