% Letzte nderung 21.03.2011

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

j = sqrt(-1);
Prandtl = 0.6977;
% Diese Datei enthlt die Eingangsdaten fr die Impedanzberechnung

% Kenndaten von Luft %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp = 20;                                                       % Temperatur in Grad Celsius
statPres = 101300;                                               % statischer Ruhedruck
c = ita_constants('c', 'medium', 'air', 'T', temp, 'p', statPres); % Schallgeschwindigkeit in m/s
c_0 = c.value;
rho_0 = 1.205;                                                   % Ruhedichte von Luft in kg/m^3
Z_0 = rho_0 * c_0;                                               % charakteristscher Wellenwiderstand fr Luft
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Betriebsmodus auswhlen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0 = Berechung der Eingangsimpedanz, -Admittanz, Reflektionsfaktor, Absorptionsgrad
%     fr Anordnung mit festgelegtem Abschluss
% 1 = Berechnung der Matrixparameter fr eine geschichtete Absorberanordnung
%     Kettenmatrix, Impedanz-/Admittanzmatrix

%matrixModus = get(handles.rb_ber_mat,'Value');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Eingangsdaten fr Berechnung  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allgemeine Parameter
M             = anzahlLagen;            % M = Anzahl der Lagen im Absorber
Abschluss     = abschlussArt;           % legt Art des Abschlusses fest; 0 = schallharter Abschluss
%                                1 = Freifeldabschluss
%                                2 = Vakuumabschluss

Einfalls_Art  =1- saveIt.sea.senk;   % 0 = Einfall unter Winkel
% 1 = diffuser Schalleinfall.
if ~Einfalls_Art
    theta_o = saveIt.sea.winkel;
    theta_u = theta_o;
    theta_step = 1;
else
    theta_u        = 0;                              % Untergrenze des Einfallswinkels, falls Einfalls_Art = 1, Winkelangabe in Grad
    theta_o        = saveIt.sea.bis;       % Obergrenze des Einfallswinkels, falls Einfalls_Art = 1, Winkelangabe in Grad
    theta_step     = saveIt.sea.step;  % Winkelschrittweite, Angabe in Grad
end
f_u           = saveIt.fb.unten;       % Untergrenze fr betrachteten Frequenzbereich in Hz
f_o           = saveIt.fb.oben;        % Obergrenze fr betrachteten Frequenzbereich in Hz
log_f         = 1-saveIt.fb.lin;    % legt fest ob Frequenzschrittweite logarithmisch(1) oder linear (0)
f_step        = saveIt.fb.step;        % falls log_f = 1: Frequenzschritte als Anteil einer Oktave (z.B.: 1/3 = ein Drittel Oktav Schritte => Terzen)
% falls log_f = 0: Frequenzschrittweite in Hz

% Schichten-Parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:anzahlLagen
    typelist(k)       = Lagen{k,3}.ausbreitungsArt;     % Eintrge in typelist legen fest ob Schicht lokal (0) oder lateral (1) wirksam ist
    ts_list(k)        = Lagen{k,3}.dicke;               % Liste enthlt die Schichtdicken ts in meter (ts_list(i) < 0 -> keine Schicht vorhanden)
    matlist(k)        = Lagen{k,3}.schichtModell;       % 1 = Luftschicht, 2 = por. Abs. nach klassischer Theorie,
    % 3 = por. Abs. nach empirischer Kennwertrelation, 4 = por. Absorber nach Komatsu-Modell,
    % 5 = por. Abs. nach Delany Bazley Modell, 6 = por. Abs. nach Miki Modell
    
    % allgemeine Parameter fr porse Absorbermaterialien
    Xis_list(k)       = Lagen{k,3}.stroemungsResistanz; % Liste enthlt Strmungsresistanzen fr Absorberschichten in Pa s/m
    RG_list(k)        = Lagen{k,3}.raumGewicht;         % Liste enthlt die Raumgewichte der Absorberschichten in kg/m
    por_list(k)       = Lagen{k,3}.porositaet;          % Liste enthlt die Volumen-Porsitten der Absorbermaterialien
    
    % aus klassischer Theorie des homogenen Mediums (siehe Schallabsorber Bd. 2, S. 85-100)
    chi_list(k)       = Lagen{k,3}.strukturFaktor;      % Liste enthlt den Strukturfaktor fr die Schichten (chi = Volumenporsitt/Flchenporsitt -> default = 1)
    kappa_eff_list(k) = Lagen{k,3}.adiabatenKoeff;      % Liste enthlt den effektiven Adiabatenkoeffizienten (Betrag zwischen 1.4 fr omega*tau->0 und 1 fr omega*tau->Inf (default = 1)),
    % dieser berechnet sich durch die Korrektur von Kappa mit der Relaxationszeit tau
    
    % aus empirischer Kennwertrelation nach Schallabsorber Bd. 2, Gl.(17.15) und Tabelle (17.6)
    kappa1(k) = Lagen{k,3}.kappa1re + j*Lagen{k,3}.kappa1im;
    kappa2(k) = Lagen{k,3}.kappa2re + j*Lagen{k,3}.kappa2im;
    b_11(k)   = Lagen{k,3}.b11;
    b_12(k)   = Lagen{k,3}.b12;
    b_21(k)   = Lagen{k,3}.b21;
    b_22(k)   = Lagen{k,3}.b22;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Parameter fr Belge %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    belag_type(k)    = Lagen{k,1}.belagsTyp;            % 1 = Massenbelag (luftdicht), 2 = Massenbelag (luftdurchlssig), 3 = Platte, 4 = MPP (mit Plattenparameter), 5 = MPP (ohne Plattenparameter)
    tb_list(k)       = Lagen{k,1}.dicke;                % Liste enthlt die Belagsdicken tb in Meter; tb = -1 => kein Belag vorhanden, alle anderen Parameter spielen dann keine Rolle
    rho_list(k)      = Lagen{k,1}.dichte;               % Liste enthlt die Dichten in kg/m^3
    
    E_modul_list(k)  = Lagen{k,1}.eModul;               % Liste enthlt E-Module in Pa=N/m zur Berechnung des Biegemoduls B
    nu_list(k)       = Lagen{k,1}.querKontraktionsZahl; % Liste enthlt die Querkontraktionszahlen nu
    eta_list(k)      = Lagen{k,1}.verlustFaktor;        % Verlustfaktor zur Beschreibung innerer Verluste im Belag -> default = 0
    % B -> B(1+j*eta) typische Werte zwischen 0.001 und 0.1
    
    Xib_list(k)  = Lagen{k,1}.stroemungsResistanz;  % Liste enthlt die Strmungsresistanzen Xi in Pa s/m^2 (Xi*ts = Strmungswiderstand)
    
    %specific parameters for MPP absorber plates
    dia_MPP_list(k)   = Lagen{k,1}.lochDurchmesser;     % diameter of holes of MPP absorber
    sigma_MPP_list(k) = Lagen{k,1}.perforationsRatio;   % Perforation ratio of microperforated panel absorber
    
    % hieraus berechnete Parameter
    m_list(k) = rho_list(k) .* tb_list(k);                                   % Liste der Flchenmassen in kg/m^2
    B_list(k) = E_modul_list(k).*tb_list(k).^3 ./ (12.*(1-nu_list(k).^2));   % Liste der Biegemodule
    f_cr_list(k) = sqrt(m_list(k) ./ B_list(k)) .* c_0.^2 ./ (2*pi);         % Liste der Koinzidenzgrenzfrequenzen
    Rf_list(k) = (Xib_list(k) .* tb_list(k)) ./ Z_0;                         % auf Z_0 normierter Strmungswiderstand
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Parameter fr Loch- bzw. Schlitzplatten %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    d_lp(k)        = Lagen{k,2}.dicke;                  % Liste enthlt die Dicken der Lochplatten in m
    shape_list(k)  = Lagen{k,2}.lochTyp;                % Liste legt fest ob es sich um eine Schlitz- (0) oder Kreis-Lochplatte (1) handelt
    a_list(k)      = Lagen{k,2}.lochSchlitzAbmessung;   % Liste enthlt Kreisdurchmesser bzw. Schlitzbreiten in m
    b_list(k)      = Lagen{k,2}.lochSchlitzAbstand;     % Liste enthlt Loch- bzw. Schlitzabstand in m
    side_list(k)   = Lagen{k,2}.side;                   % Liste legt fest ob sich die Folie(i) vor (0) oder hinter (1) der Lochplatte befindet
    
    % hieraus berechnete Parameter
    if shape_list(k) == 0
        sigma_lp(k) = a_list(k)/b_list(k);
    elseif shape_list(k) == 1
        sigma_lp(k) = pi/4*(a_list(k)/b_list(k))^2;
    elseif shape_list(k) == 2
        sigma_lp(k) = (a_list(k)/b_list(k))^2;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end

% DISPLAY LAGEN FOR DEBUG PURPOSES
[M,N] = size(Lagen);
disp('---------------------------------------');
disp('---------------------------------------');
for m=1:M
    disp(['Lage ' num2str(m) ':']);
    disp(['Belag: ' Lagen{m,1}.name ':']);
    disp(Lagen{m,1});
    disp('---------------------------------------');
    disp(['Lochplatte: ' Lagen{m,2}.name ':']);
    disp(Lagen{m,2});
    disp('---------------------------------------');
    disp(['Schicht: ' Lagen{m,3}.name ':']);
    disp(Lagen{m,3});
    disp('---------------------------------------');
    disp('---------------------------------------');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Berechnung der Ausbreitungskonstante und des Wellenwiderstandes aus empirischen Regressionskonstanten
% mit E = rho_0*f/Xis_list(r);
%
%  Mineralfasern
%  Z_a     = beta_1M/E + beta_2M/sqrt(E) + beta_3M + beta_4M*sqrt(E) + beta5M*E + beta6M*E^(3/2);
%  Gamma_a = betq_1M/E + betq_2M/sqrt(E) + betq_3M + betq_4M*sqrt(E) + betq5M*E + betq6M*E^(3/2);
%
%  Glasfasern
%  Z_a     = beta_1G/E + beta_2G/sqrt(E) + beta_3G + beta_4G*sqrt(E) + beta5G*E + beta6G*E^(3/2);
%  Gamma_a = betq_1G/E + betq_2G/sqrt(E) + betq_3G + betq_4G*sqrt(E) + betq5G*E + betq6G*E^(3/2);
%
% Konstanten fr die Regression der Absorberkennwerte (Kenn-Ausbreitungskonstante, Kenn-Wellenwiderstand)
% % Mineralfasern
%
% % Xi = AA*RG^BB
% AA = 0.035916;
% BB = 1.5560734;
%
% betq_1M = -0.00355757 - j*0.0000164897;
% betq_2M =  0.421329   + j*0.342011;
% betq_3M = -0.507733   + j*0.086655;
% betq_4M = -0.142339   + j*1.25986;
% betq_5M =  1.29048    - j*0.0820811;
% betq_6M = -0.771857   - j*0.668050;
%
% beta_1M =  0.0026786  + j*0.00385761;
% beta_2M =  0.135298   - j*0.394160;
% beta_3M =  0.946702   + j*1.47653;
% beta_4M = -1.45202    - j*4.56233;
% beta_5M =  4.03171    + j*7.56031;
% beta_6M = -2.86993    - j*4.90437;
%
% % Glasfasern
%
% % Xi = AA*RG^BB
% AA = 0.1142509;
% BB = 1.418284;
%
% betq_1G = -0.00451836 - j*0.0000541333;
% betq_2G =  0.421987   + j*0.376270;
% betq_3G = -0.383809   - j*0.353780;
% betq_4G = -0.610867   + j*2.59922;
% betq_5G =  1.13341    - j*1.74819;
% betq_6G =  0;
%
% beta_1G = -0.00171387 + j*0.00119489;
% beta_2G =  0.283876   - j*0.292168;
% beta_3G = -0.463860   + j*0.188081;
% beta_4G =  3.12736    + j*0.941600;
% beta_5G = -2.10920    - j*1.32398;
% beta_6G =  0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

