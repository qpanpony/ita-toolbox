function SH = ita_sph_mirror(SH,x,y,z)
%ITA_SPH_MIRROR - applies a mirrowing on a wall normal to x, y and z
% 
% Mirrows a spherical function given by its SH coefficients on walls
% perpendicular to the x, y or z axis. SH can be a vector or matrix.
% 
%   x, y and z are logicals and state if there is a reflection or not
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
narginchk(4,4);

% make sure we are dealing with logicals
x = logical(x);
y = logical(y);
z = logical(z);

% check for row vector and correct it
if size(SH,1) == 1 && length(SH) > 1
    SH = SH.';
end

% anything to do?
if ~(x||y||z)
    return;
end

nSH = size(SH,1);
% check for partially filled order and fill them up with zeros
maxOrder = sqrt(nSH) - 1;
if ~isnatural(maxOrder);
    nSH_target = (ceil(maxOrder) + 1).^2;
    SH = cat(1,SH,zeros(nSH_target - nSH, size(SH,2)));
    nSH = size(SH,1);
end 
[n,m] = ita_sph_linear2degreeorder(1:nSH);

if z
    SH = bsxfun(@times, SH, (-1).^(n.'-m.'));
end

if y
    SH = bsxfun(@times, SH, (-1).^(m.'));
    x = ~x;
end

if x
    matrixSH = ita_sph_vector2matrix(SH);
    SH = ita_sph_matrix2vector(flipdim(matrixSH,2));
end    
