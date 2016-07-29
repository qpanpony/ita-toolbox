function g = ita_sph_green_freefield(k,n,m,sph,hankelflag,sr)

% See Williams, 'Fourier Acoustics', p. 198

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargin == 4
    hankelflag = true;
    sr = 0; %sampling rate used to shift reflections to exact samples
end

if iscolumn(k)
    k = k.';
end
%% Create SH vector
%     C = 414/sqrtrr(4*pi);
C = 1/sqrt(4*pi); %C00

%% Hankel - radiation
%% TODO: WHY 1st KIND!?!?
% Hankel terms. Every row for one sph.r and all k
r = sph.r;
if sr
    c = 2*pi*sr/2/k(end); %guess speed of sound
    t = round(r / c*sr)/sr;
    r = t*c;
end

kr = bsxfun(@times,r,k);


if hankelflag
    hankelTerm = besselh(n + 0.5, 2, kr);
    hankelTerm = bsxfun(@times, sqrt(0.5 .* pi ./ kr), hankelTerm); % due to MATLAB definition in besselh
    hankel = 1i .* bsxfun(@times,hankelTerm,k.^(n+1)); % TODO why -1?
    if any(k==0) % only if it occurs
        hankel(:,k==0) = -1i*(-1i)^(n+1)*1i^n*factorial(2*n)./(r.^(n+1)*factorial(n)*2^n); %zero-frequency fix
    end
else
    hankel = bsxfun(@mtimes,-bsxfun(@rdivide, exp(-1i*kr),r),k.^(n));
end

C_rad = bsxfun(@times,C,hankel);

%% SH Base - directivity
Pn  = legendre(n,cos(sph.theta.'),'norm').';
Pnm = bsxfun(@times,(-1).^(n)/sqrt(2*pi),Pn(1)); %TODO why end or 1?
Ynm = Pnm .* exp(1i*sph.phi.*m);

%% Result
g = bsxfun(@times,Ynm,C_rad);

end



% %% check formula 6.59b) handwritten  - williams
% n = 3;
% m = 0:n;
% 1i.^(m).*factorial(n+m) ./ factorial(m) ./ factorial(n-m) ./ 2.^m