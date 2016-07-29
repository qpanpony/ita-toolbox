function coef = ita_sph_cartesian_derivation(coef, nDiff, k)
%ITA_SPH_CARTESIAN_DERIVATION - calculates the derivations in cartesian coordinates
%
% This functions calculates the derivation of the spherical harmonic
% coeficients coef in cartesian coordinates. nDiff = [nx ny nz] states
% how many time we take the derivative in [x y z] directions. Definition
% taken from "Recursions for the computation of multipole translation and
% rotation coefficients for the 3-D Helmholtz equation", Gumerov / Duraiswami
%
% Example:   coef = ita_sph_cartesian_derivation(coef, [nx ny nz])
%               calculates for the wavenumber k
%                   coef = (d/dy)^ny .* (d/dy)^ny .* (d/dz)^nz .* coef
%
% (works in the source strength (multipole) domain)

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  12-Jul-2011

% swap SH convention first, later re-swap them
coef = ita_sph_swap_SH_convention(coef);

% check for correct input
if nargin ~= 3 || numel(nDiff) ~= 3, error('Please check syntax'); end
% check for trick 17
if any(nDiff < 0), disp('Sorry, I cannot integrate for you'); return; end
% check if there is work to be done
if sum(nDiff) == 0, disp('nothing to do'); return; end

% SH coefs are first dimension
if min(size(coef)) == 1
    coef = coef(:);
end
nSH = size(coef,1);
nmax = sqrt(nSH) - 1;

disp(['will calculate ' num2str(sum(nDiff)) ' recurence relations']);

% extend the SH vector/matrix
nmaxAfter = (sum(nDiff) + nmax);
nSH_new = (nmaxAfter + 1).^2;
nZeros = nSH_new - nSH;

% extend coef with zeros
nDim = size(coef,2);
% coef_orig = coef;
coef = [coef; zeros(nZeros,nDim)];

%% and convert to matrix
F = ita_sph_vector2matrix(coef);

[n,m] = ita_sph_linear2degreeorder(1:nSH_new); %#ok<BDSCI>

% just calc what we need
if sum(nDiff(1:2)) > 0
    b = ita_sph_vector2matrix(calc_b(n,m));
end
if nDiff(3) > 0
    a = ita_sph_vector2matrix(calc_a(n,m));
end

if nargin < 3
    disp('using k = 1')
    k = 1;
end

%% d/dx
for ind = 1:nDiff(1)
    term1 = calc_term1(F,b);
    term2 = calc_term2(F,b);    
    F = k ./ 2 .* (term1 + term2);
end

%% d/dy
for ind = 1:nDiff(2)
    term1 = calc_term1(F,b);
    term2 = calc_term2(F,b);
    % minus added because of different sign convention
    F = k .* -1i./2 .* (term2 - term1);
end

%% d/dz
for ind = 1:nDiff(3)
    term3 = calc_term3(F,a);
    F = k .* term3;
end

%% convert back

coef = ita_sph_matrix2vector(F);

% and swap back
coef = ita_sph_swap_SH_convention(coef);

%% done, return

    function result = calc_term1(F,b)
        % the minus of the second term was swopped by accident
        result = displace(fliplr(b),1,1) .* displace(F,1,1) + b .* displace(F,-1,1);
    end
    function result = calc_term2(F,b)
        % the minus of the second term was swopped by accident
        result = displace(b,1,-1) .* displace(F,1,-1) + fliplr(b) .* displace(F,-1,-1);
    end
    function result = calc_term3(F,a)
        % the minus of the first term was swopped by accident
        result = -displace(a,-1,0) .* displace(F,-1,0) - a .* displace(F,1,0);
    end
    function a = calc_a(n,m)
        absM = abs(m);
        a = sqrt((n+1+absM).*(n+1-absM)./(2*n+1)./(2*n+3));
    end
    function b = calc_b(n,m)
        isNeg = m < 0;
        
        b = sqrt( (n-m-1).*(n-m) ./ (2*n-1)./(2*n+1) );
        b(isNeg) = -b(isNeg);
    end

    function F = displace(F,dn,dm)
        % displace a matrix (fills the new fields with zeros)
        % shift up the order by dn and the degree by dm

        % change shift directions
        dn = -dn; dm = -dm;
        F = circshift(F,[dn dm]);
        
        % overwrite the overlapping parts with zeros
        if dn > 0
            F(1:dn,:) = 0;
        else
            F((end+dn+1):end,:) = 0;
        end
        if dm > 0
            F(:,1:dm) = 0;
        else
            F(:,(end+dm+1):end) = 0;
        end        

    end

end
