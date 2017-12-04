function d = dot(v1,v2)
% calculate the scalar product of two vectors

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


d = dot(v1.cart,v2.cart,2);
end %eof