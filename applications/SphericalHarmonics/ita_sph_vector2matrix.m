function mat = ita_sph_vector2matrix(vec,type)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

% converts a SH vector into matrix notation
%  the upper corners of the matrix are filled with zeros

% Author: Martin Pollow <mpo@akustik.rwth-aachen.de>

% first dim should be SH coefs
% check for transversed vector
sizeVec = size(vec);
if sizeVec(1) == 1 && sizeVec(2) > 1
    vec = vec.';
    sizeVec = size(vec);
end
nSH = sizeVec(1);

[n,m] = ita_sph_linear2degreeorder(1:nSH);

matSize = [n(end)+1 2*n(end)+1 sizeVec(2)];
if nargin > 1 && strcmpi(type,'nan')
    mat = nan(matSize);
else
    mat = zeros(matSize);
end

for ind = 1:nSH
    for indF = 1:sizeVec(2)
        mat(n(ind)+1,m(ind)+n(end)+1,indF) = vec(ind,indF);
    end
end

end
