function [fun, funcplx] = ita_curvefit_enclosure(b,freqVec,TS)
%ITA_CURVEFIT_ENCLOSURE
%   called by ita_enclosure_fit
%   creates functions for ita_enclosure_fit

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  31-Mar-2014 

omega = 2*pi.*freqVec;
s = 1i.*omega;


Lces = TS.n*TS.M^2;
Res  = TS.M^2/TS.w;
Cmes = TS.m/TS.M^2;

if ~isfield(TS, 'f_s')
    TS.f_s = 1/(2*pi*Lces*Cmes);
end

if isfield(TS, 'lambda')
    Lces = Lces*(1-TS.lambda.*log10(1i*freqVec./TS.f_s));
    
elseif isfield(TS, 'k') && isfield(TS, 'f_min')
    Lces = Lces.*(1-TS.k.*log10(1i.*(freqVec./TS.f_min).*exp(-1i.*atan(freqVec./TS.f_min))./(sqrt(1+(freqVec./TS.f_min).^2))));
end

Lencl = b(1)*TS.M^2;
Lces = Lces.*Lencl ./ (Lces + Lencl);

switch numel(b)
    case 1
        Res = TS.M^2/TS.w;
    case 2 % b(2) = w_g
        Res = TS.M^2/(TS.w + b(2));
    otherwise % nothing
end

Zp = Lces.*s./(Lces.*Cmes.*(s.^2) +  Lces./Res.*s + 1);
Ze = TS.L_e.*s + TS.R_e;

if isfield(TS,'L_2') && isempty(TS.L_2)
    Ze = Ze + s.*TS.L_2.*TS.R_2./(s.*TS.L_2 + TS.R_2);
end

Z = Ze + Zp;
% Hx = Zp./(TS.M.*s.*Z);

funcplx = Z;
fun = [real(Z) imag(Z)];

end