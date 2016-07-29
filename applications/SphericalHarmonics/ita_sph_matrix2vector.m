function vec = ita_sph_matrix2vector(mat)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% converts a SH in matrix notation back to vectorial notation
%  the upper corners of the matrix are ignored

% Author: Martin Pollow <mpo@akustik.rwth-aachen.de>

n = size(mat,1)-1;
nSH = ita_sph_degreeorder2linear(n,n);

[n,m] = ita_sph_linear2degreeorder(1:nSH);

vec = zeros(nSH,1);

for ind = 1:nSH
    vec(ind) = mat(n(ind)+1,m(ind)+n(end)+1);
end

end
