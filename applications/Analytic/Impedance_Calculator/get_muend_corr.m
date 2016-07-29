function muend_corr = get_muend_corr(shape, a, b, f, c)

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Berechnung der Mündungskorrektur für Schlitz und Kreisöffnungen
% shape = 0 (Schlitz, regelmäßige Anordnung), 1 (Kreis, regelmäßige Anordnung), 2 (quadr. Mündung in Wand), 3 (Kreis in ebener Platte)
% siehe Mechel: Schallabsorber Bd.2, S.682 ff
% a = Kreisdurchmesser bzw. Schlitzbreite
% b = Loch- bzw. Schlitzabstand

if shape == 0
    sig = a/b;
    x = log10(sig);
    muend_corr = -0.395450*x + 0.346161*x^2 + 0.141928*x^3 + 0.0200128*x^4; 
elseif shape == 1
    sig = pi*a^2/(2*b)^2;
    muend_corr = 0.395 * ( 1 - 1.47*sig^(1/2) + 0.47*sig^(3/2) );
elseif shape == 2
    beta = 1;
    muend_corr = 1/2 * ( 2/(3*pi)*( beta + (1-(1+beta.^2).^1.5)./(beta.^2) ) + ...
            2/pi*( 1./beta.*log( beta + sqrt(1+beta.^2)) + ...
            log(1./beta.*(1+sqrt(1+beta.^2))) ) );
elseif shape == 3
    k = 2*pi*f/c;
    muend_corr = 4/(3*pi)*(1-1/15*k*a+2/525*(k*a)^2);
end