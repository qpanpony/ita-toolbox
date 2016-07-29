function result = ita_sph_convS2(F, G)
%ITA_SPH_CONVS2 - spatial convolution on sphere
% function result = ita_sph_convS2(F, G)
% 
% computes the spatial convolution of two functions on the 2-sphere
% in the spherical harmonic domain
%
% the function F can have higher dimentions and each of them is computed
% 
% the definition was taken from:
% Driscoll and Healy, "Computing Fourier Transforms and Convolutions on the
% 2-D Sphere", Advances in Applied Mathematics, 15, 202-250, 1994
%
% Martin Pollow (mpo@akustik.rwth-aachen.de)
% Institute of Technical Acoustics, RWTH Aachen, Germany
% 03.09.2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


if size(F,1) ~= size(G,1)
    error('coefficients vectors must have the same size');
end

linear_index = (1:length(F)).';
degree_index = ceil(sqrt(linear_index))-1;

% calculate a linear index which points to the zero order coefficients
lin_index_zero_order = ita_sph_eye(degree_index(end), 'nm-n0') * linear_index;

conv_factor = 2*pi * sqrt(4*pi./(2*repmat(degree_index,[1 size(F,2)])+1));

result = conv_factor .* F(linear_index,:) .* repmat(G(lin_index_zero_order), [1 size(F,2)]);    
