function [fun, funcplx] = ita_curvefit_thiele_small(b,freqVec,TS)
%ITA_CURVEFIT_THIELE_SMALL
%   called by ita_thiele_small_fit
%   creates functions for ita_thiele_small_fit

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@rwth-aachen.de
% Created:  23-Jan-2014 


omega = 2*pi.*freqVec;
s = 1i.*omega;
Re = double(TS.R_e);
Le = b(1);
Lces = b(2);
Res = b(3);
Cmes = b(4);
M = b(5);

if ~isfield(TS, 'f_s')
    fs = 1/(2*pi*sqrt(Lces*Cmes));
else
    fs = double(TS.f_s);
end

switch numel(b)
    case 6 
        lambda = b(6);
%         fs = 1/(2*pi*sqrt(b(3)*b(5)));
%         Lces = Lces*(1-lambda.*log10(freqVec./fs)); % Klippel model
        Lces = Lces*(1-lambda.*log10(1i*freqVec./fs)); % Knudsen model
    case 7 
        k = b(6);
        fmin = b(7);
        Lces = Lces.*(1-k.*log10(1i.*(freqVec./fmin).*exp(-1i.*atan(freqVec./fmin))./sqrt(1+(freqVec./fmin).^2)));
end

if isfield(TS, 'n_g')
    Lces = Lces.*(TS.n_g.value*M.^2) ./ (Lces + (TS.n_g.value*M.^2));
end

Zp = Lces.*s./(Lces.*Cmes.*(s.^2) +  Lces./Res.*s + 1);
Z = Le.*s + Re + Zp;
Hx = (Zp./(M.*s.*Z)).*TS.factor;

funcplx = [Z Hx];
fun = [real(Z) imag(Z) real(Hx) imag(Hx)];

end