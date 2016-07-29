function varargout = ita_sph_rotate_complex_valued_spherical_harmonics(input, euler)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% if "value" is a matrix of coefficients (size(value) == [nmax_lin, ~]) , which weights some real valued spherical
% basefunctions, this function returns the coeficients of the rotated
% function.
% if value == nmax, it returns a rotation matrix 
% (newCoef = marix * oldCoef)
%
% rotation is proceeded along euler-angel
%   first: euler(1,1) - rotation arround the z-axis
%   then:  euler(1,2) - rotation arround the y-axis
%   then:  euler(1,3) - rotation arround the z-axis
%   then the function continues with euler(2,1) ...
%
% attention: - there are also other definitions of euler-angles!!
%            - all angles must be [rad]
%
% author: martin kunkemoeller, 16.11.2010
% according to Dis Zotter, chapter 3.1.4

ita_verbose_obsolete('Marked as obsolete. Please report to mpo, if you still use this function.');

if length(input) == 1
    nmax = input;
    value = [];
elseif ~mod(sqrt(size(input,1))-1, 1)
    nmax = sqrt(size(input,1))-1;
    value = input;
else
    error('can  not handle your input!');
end



if size(euler,2) ~= 3
    error('size(euler,2) must be 3');
end


%proceed rotation
ROT = eye((nmax+1)^2);

if sum(abs(euler(:,2)))
    for idxE = 1:size(euler,1)
        ROT = ROT...
            *ROT_z(nmax,euler(idxE,1))...
            *ROT_y(nmax,euler(idxE,2))...
            *ROT_z(nmax,euler(idxE,3));
    end
else
    for idxE = 1:size(euler,1)
        ROT = ROT...
            *ROT_z(nmax,euler(idxE,1) + euler(idxE,3));
    end
end

if isempty(value)
    %not the coordnate system is rotation, but the function ...
    varargout{1} = ROT.';
else
    varargout{1} = ROT.'*value;
end
end

function matrix = ROT_z(nmax,phi)
matrix = ita_sph_wignerD(nmax, [-phi 0 0]);
end

function matrix = ROT_y(nmax, phi)
matrix = ita_sph_wignerD(nmax, [0 -phi 0]);
end