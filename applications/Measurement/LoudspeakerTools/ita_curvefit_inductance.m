function [fun, funcplx] = ita_curvefit_inductance(b,freqVec,TS)
%ITA_CURVEFIT_INDUCTANCE
%   called by ita_inductance_fit
%   creates functions for ita_inductance_fit

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  23-Jan-2014 

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

if isfield(TS, 'n_g')
    Lencl = TS.n_g*TS.M^2;
    Lces = Lces.*Lencl ./ (Lces + Lencl);
end

Zp = Lces.*s./(Lces.*Cmes.*(s.^2) +  Lces./Res.*s + 1);
Ze = b(1).*s + TS.R_e;

switch numel(b)
    case 2 % b(2) = Rf
        Ze = Ze + b(2).*omega;
    case 3 % b(2) = R2, b(3) = L2
        Ze = Ze + b(2)*b(3).*s./(b(2) + b(3).*s);
    otherwise % nothing
end

Z = Ze + Zp;
% Hx = Zp./(TS.M.*s.*Z);

funcplx = Z;
fun = [real(Z) imag(Z)];

end