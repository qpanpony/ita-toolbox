function f_SH = ita_sph_SHT(f, g, type)
%ITA_SPH_SHT - spherical harmonic transform
% function f_SH = ita_sph_SHT(f, g)
%
% performs an spherical harmonic transform
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


size_f = size(f);

higher_dimentions = numel(f)./size_f(1);

% reshape to the size of two dimentions
f_dim2 = reshape(f, [size(f,1) higher_dimentions]);

if size(f_dim2) == size(g.weights)
    f_dim2_weighted = f_dim2 .* g.weights;
else
    f_dim2_weighted = f_dim2 .* repmat(g.weights(:),1,higher_dimentions);
end

if exist('type','var') && strcmp(type,'pinv')
    disp('using pseudo-inverse');
    f_SH_dim2 = pinv(g.Y) * f_dim2_weighted;
else
    f_SH_dim2 = g.Y' * f_dim2_weighted;
end

f_SH = reshape(f_SH_dim2, [size(g.Y,2) size_f(2:end)]);
