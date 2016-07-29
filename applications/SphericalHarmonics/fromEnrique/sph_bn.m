function bn = sph_bn(n,kr,type)
% Computation of b_n(kr), which depends on sphere type
%   see Rafaely 2008: 'Spatial sampling and beamforming for spherical
%   microphone arrays', HSCMA 2008

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if nargin < 3, type = 'rigid'; end

jn  = sph_jn(n,kr);
jn1 = sph_jn(n-1,kr);
jnp = jn1 -((n+1)./kr).*jn;
hn  = sph_hn1(n,kr);
hn1 = sph_hn1(n-1,kr);
hnp = hn1-((n+1)./kr).*hn;
F   = jn-(jnp./hnp).*hn;
W   = F.*hnp;   % el wronskiano es i/(kr)^2

switch type
    case 'rigid'            % single rigid sphere
        bn  = 4*pi*(+1i)^n*F;  
    case 'open'             % single open sphere
        bn  = 4*pi*(+1i)^n*jn;      
    case 'cardioid'         % single open sphere with cardioid microphones
        bn  = 4*pi*(+1i)^n*(jn-1i*jnp);    
    otherwise
        error([mfilename 'non-valid sphere type']);                         
end

end

% jn(x) : Spherical Bessel Function of 1st-kind (n order)
function y=sph_jn(n,x)
    y = sqrt(pi./(2*x)).*besselj(n+0.5,x);
end

% yn(x) : Spherical Bessel Function of 2st-kind (n order)
function y=sph_yn(n,x)
    y = sqrt(pi./(2*x)).*bessely(n+0.5,x);
end

% hn(x) : Spherical Hankel Function of 1st-kind (n order)
function y=sph_hn1(n,x)
    y = sph_jn(n,x) + 1i*sph_yn(n,x);
end
