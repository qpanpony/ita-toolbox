function erg=Impedanz(saveIt, matrixModus, Lagen, anzahlLagen, abschlussArt)

% <ITA-Toolbox>
% This file is part of the application Impedance_Calculator for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Paramter einlesen
Parameter_mit_GUI;

if (log_f == 0)
    f = f_u : f_step : f_o;
elseif (log_f == 1)
    f(1) = f_u;
    i = 2;
    while (f(i-1) < f_o)
        f(i) = f(i-1)*2^(f_step);
        i=i+1;
    end
end

theta = theta_u : theta_step : theta_o;

%Initialisierung der verwendeten Parameter

p_vorne = zeros(length(f), length(theta));
v_vorne = zeros(length(f), length(theta));
Z     = zeros(length(f), length(theta));
Y     = zeros(length(f), length(theta));
R     = zeros(length(f), length(theta));
R_bau = zeros(length(f), length(theta));
alpha = zeros(length(f), length(theta));
tau   = zeros(length(f), length(theta));

a11   = zeros(length(f), length(theta));
a12   = zeros(length(f), length(theta));
a21   = zeros(length(f), length(theta));
a22   = zeros(length(f), length(theta));
det_A = zeros(length(f), length(theta));

y11   = zeros(length(f), length(theta));
y12   = zeros(length(f), length(theta));
y21   = zeros(length(f), length(theta));
y22   = zeros(length(f), length(theta));

z11   = zeros(length(f), length(theta));
z12   = zeros(length(f), length(theta));
z21   = zeros(length(f), length(theta));
z22   = zeros(length(f), length(theta));

Z_diff     = zeros(length(f), 1);
Y_diff     = zeros(length(f), 1);
R_diff     = zeros(length(f), 1);
R_bau_diff = zeros(length(f), 1);
alpha_diff = zeros(length(f), 1);
tau_diff   = zeros(length(f), 1);
ref        = zeros(length(f),1);

airAttenuationItaValue = ita_constants('m', 'medium', 'air', 'T', temp, 'f' ,f , 'p', statPres);
airAttenuation = airAttenuationItaValue.value;

k_a = zeros(numel(f),M);
Z_out = zeros(numel(f),M);

%% Schleife ber Frequenzen und Winkel starten
for r = 1:length(f)                 % Berechnung fr alle Frequenzen durchfhren
    for s = 1:length(theta)           % Berechnung fr alle Einfallswinkel
        
        % Listen fr Lngsimpedanzen und Queradmittanzen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        zlist = zeros(1,2*M);
        glist = zeros(1,2*M);
        Z_f = zeros(1,M); % Initialisierung der Folienimpedanzen
        Z_s = zeros(1,M); % Initialisierung der Schichtimpedanzen
        G_s = zeros(1,M); % Initialisierung der Schichtadmittanzen
        
        
        % Die Berechnung fr Belge und Schichten wird je nach Schalleinfallsart getrennt durchgefhrt, da die Formeln fr senkrechten Schalleinfall deutlich einfacher sind
        
        if (length(theta) == 1) && (theta(1)==0) % Berechnung von Belgen und Schichten in einer Schleife fr senkrechten Schalleinfall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for i=1:M
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Berechnung der Folienimpedanzen Z_f
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (tb_list(i) <= 0);                                                     % prfen ob Dummy-Belag
                    Z_f(i) = 0;
                else
                    omega = 2*pi*f(r);
                    switch belag_type(i)
                        case 1                                                            % Massenbelag (luftdicht)
                            m_eff = m_list(i);
                            if eta_list(i)<=0
                                Z_f(i) = 1i*omega*m_eff;
                            else
                                Z_f(i) = 1i*omega*m_eff * ( 1 / (1 + 1i * eta_list(i)) );
                            end
                        case 2                                                            % Massenbelag (luftdurchlssig)
                            m_eff = ( m_list(i) * Rf_list(i) ) / ...
                                ( (1i*omega*m_list(i)/Z_0) + Rf_list(i) );       % Parallelschaltung des Massenbelages mit seinem Strmungswiderstand
                            % siehe Mechel Bd. III, Formel (3.10), S.54
                            Z_f(i) = 1i*omega*m_eff;
                            
                        case 3                                                            % Platte (bei senkrechtem Schalleinfall spielen die Biegewellen auf der Platte keine Rolle)
                            % Einfluss der Koinzidenz auf effektive Masse kann bei senkrechtem Schalleinfall vernachlssigt werden
                            m_eff = m_list(i);
                            Z_f(i) = 1i*omega*m_eff;
                            
                        case {4,5}                                                        % MPP mit oder ohne Platteneigenschaften (spielt bei senkrechtem Schalleinfall keine Rolle)
                            % Microperforated Panel Absorber: Formulas taken from
                            % Maa, "Potential of microperforated panel absorber", JASA, 104 (5), 1998
                            t_MPP     = tb_list(i);
                            d_MPP     = dia_MPP_list(i);
                            sigma_MPP = sigma_MPP_list(i);
                            
                            nu_MPP  = 1.789e-5;                                           % Pa s Dynamic viscosity of air
                            k_MPP   = d_MPP * sqrt(omega*rho_0/(4*nu_MPP));
                            
                            k_r_MPP = (1 + (k_MPP^2)/32)^(1/2) + (sqrt(2)/32)*k_MPP*(d_MPP/t_MPP);
                            r_MPP   = (32*nu_MPP*t_MPP)/(sigma_MPP*Z_0*d_MPP^2) * k_r_MPP;
                            
                            k_m_MPP = 1 + (9 + (k_MPP^2)/2)^(-1/2) + 0.85*d_MPP/t_MPP;    % Achtung: die "9" in der Formel ist etwas umstritten. Maa, schreibt in einer Formel "9" und in der nchsten "1"
                            m_MPP   = t_MPP/(sigma_MPP*c_0) * k_m_MPP;                    % Irgendwo ist also ein Tippfehler. Da Sakagami, die Formel allerdings mehrfach mit der "9" zitiert, benutzen wir die "9"
                            
                            Z_MPP  = Z_0 * ( r_MPP + 1i*omega*m_MPP);                      % REMARK: The m_MPP mass term describes the air-piston which is moving in the hole, it has nothing to do with the plate mass!
                            
                            % Z_f(i) = Z_MPP;
                            Z_f(i) = (Z_MPP * 1i*omega*m_list(i)) / ...
                                (Z_MPP + (1i*omega*m_list(i)));                % Parallelschaltung von elastischer Masse und komplexem MPP Widerstand
                    end
                end
                zlist(2*i-1) = Z_f(i);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Berechnung der Lngsimpedanzen Z_s und der Queradmittanzen G_s der Schichten
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (ts_list(i) <= 0)                                                      % prfen ob Dummy-Schicht
                    zlist(2*i)   = 0;
                    glist(2*i-1) = 0;
                    glist(2*i)   = 0;
                else % tslist(i) > 0
                    if ( matlist(i) == 1 )                                                % Luftschicht
                        Z_a(i)     = rho_0 * c_0;
                        Gamma_a(i) = 1i*(2*pi*f(r)/c_0) + airAttenuation(r)/2;
                        % Gamma_a(i) = 1i*(2*pi*f(r)/c_0);
                        
                    elseif ( matlist(i) == 2 )                                            % Por. Abs nach  klassischer Theorie des homogenen Mediums
                        % (siehe Schallabsorber Bd. 2, S. 85-100)
                        Xis_eff    = (1i*2*pi*f(r)*RG_list(i)*Xis_list(i))/(1i*2*pi*f(r)*RG_list(i)+Xis_list(i));
                        % Xis_eff = Xis_list(i);
                        Z_a(i)     = Z_0/por_list(i)*sqrt(chi_list(i)/kappa_eff_list(i)*(1-1i*por_list(i)*Xis_eff/(chi_list(i)*2*pi*f(r)*rho_0)));
                        Gamma_a(i) = 1i*(2*pi*f(r)/c_0)*sqrt(chi_list(i)*kappa_eff_list(i)*(1-1i*por_list(i)*Xis_eff/(chi_list(i)*2*pi*f(r)*rho_0)));
                        
                    elseif ( matlist(i) == 3 )
                        % aus empirischer Kennwertrelation nach Schallabsorber Bd. 2, Gl.(17.15) und Tabelle (17.6)
                        porosity   = 0.95;
                        E          = rho_0*f(r)/Xis_list(i);
                        rho_eff1   = 1/( 1 - tan(sqrt(-6*pi*1i*b_11(i)*E))/sqrt(-6*pi*1i*b_11(i)*E) );
                        C_eff1     = 1 + ((kappa1(i) - 1) * tan(sqrt(-6*pi*1i*kappa1(i)*Prandtl*b_21(i)*E)) / sqrt(-6*pi*1i*kappa1(i)*Prandtl*b_21(i)*E));
                        rho_eff2   = 1/( 1 - tan(sqrt(-6*pi*1i*b_12(i)*E))/sqrt(-6*pi*1i*b_12(i)*E) );
                        C_eff2     = 1 + ((kappa2(i) - 1) * tan(sqrt(-6*pi*1i*kappa2(i)*Prandtl*b_22(i)*E)) / sqrt(-6*pi*1i*kappa2(i)*Prandtl*b_22(i)*E));
                        
                        Z_a(i)     = Z_0/porosity * sqrt(rho_eff2/C_eff2);
                        Gamma_a(i) = 1i*(2*pi*f(r)/c_0)*sqrt(rho_eff1*C_eff1);
                        
                    elseif ( matlist(i) == 4 )
                        % aus dem von Takeshi Komatsu optimierten Delany-Bazley-Modell fr faserartige Absorbermaterialien mit hohen Porsitten.
                        % siehe Acoustic Science & Technology 29, 2 (2008)! Das ursprngliche Modell unter Applied Acoustics, 3, 105-116 (1970)
                        Z_a(i)     = Z_0 * ((1 + 0.00027*(2-log10(f(r)/Xis_list(i)))^(6.2)) - 1i*0.0047*(2-log10(f(r)/Xis_list(i)))^(4.1));
                        Gamma_a(i) = 2*pi*f(r)/c_0 * ((0.0069*(2-log10(f(r)/Xis_list(i)))^(4.1)) + 1i*(1+0.0004*(2-log10(f(r)/Xis_list(i)))^(6.2)));
                        
                    elseif ( matlist(i) == 5 )
                        % Das Original Delany Bazley Modell (siehe Komatsu Paper Acoustic Science & Technology 29, 2 (2008), da ist es sauber aufgeschrieben)
                        % Original Verffentlichung: Applied Acoustics, 3, 105-116 (1970)
                        
                        % Coefficients
                        aa =  0.0497; cc =  0.0758; pp =  0.1690; rr =  0.0858;
                        bb = -0.7540; dd = -0.7320; qq = -0.5950; ss = -0.7000;
                        
                        % Real and Imaginary Part of characteristic impedance and propagation constant
                        R_db     =  Z_0            * ( 1 + aa * ( f(r)/Xis_list(i) )^bb );
                        X_db     = -Z_0            * (     cc * ( f(r)/Xis_list(i) )^dd );
                        alpha_db = (2*pi*f(r)/c_0) * (     pp * ( f(r)/Xis_list(i) )^qq );
                        beta_db  = (2*pi*f(r)/c_0) * ( 1 + rr * ( f(r)/Xis_list(i) )^ss );
                        
                        Z_a(i)     = R_db + 1i*X_db;
                        Gamma_a(i) = alpha_db + 1i*beta_db;
                        
                    elseif ( matlist(i) == 6 )
                        % Das Miki Modell (siehe Komatsu Paper Acoustic Science & Technology 29, 2 (2008), da ist es sauber aufgeschrieben)
                        % Es handelt sich um eine Abwandlung des Delany Bazley Modells
                        % Original Verffentlichung: J. Acoust. Soc. Jpn., 11, pp.19-24 (1990)
                        
                        % Coefficients
                        aa =  0.0699; cc =  0.1070; pp =  0.1600; rr =  0.1090;
                        bb = -0.6320; dd = -0.6320; qq = -0.6180; ss = -0.6180;
                        
                        % Real and Imaginary Part of characteristic impedance and propagation constant
                        R_db     =  Z_0            * ( 1 + aa * ( f(r)/Xis_list(i) )^bb );
                        X_db     = -Z_0            * (     cc * ( f(r)/Xis_list(i) )^dd );
                        alpha_db = (2*pi*f(r)/c_0) * (     pp * ( f(r)/Xis_list(i) )^qq );
                        beta_db  = (2*pi*f(r)/c_0) * ( 1 + rr * ( f(r)/Xis_list(i) )^ss );
                        
                        Z_a(i)     = R_db + 1i*X_db;
                        Gamma_a(i) = alpha_db + 1i*beta_db;
                        
                    elseif (matlist(i) == 7)
                        %% Modell nach Attenborough
                        % "Modeling and optimization of two layer porous
                        % asphalt roads" von Kuijpers, van Blokland
                        % Xi Strmungswiderstand
                        % Chi Grad der Gewundenheit der Transportwege in den Poren porser Materialien
                        % sigma Porositt
                        
                        % N_pr = 220; % Erdl
                        N_pr = 0.7179; % N_Pr Prandtl Zahl  Luft
                        
                        omega = 2*pi*f(r);
                        
                        lambda_omega = sqrt(3*rho_0*omega*chi_list(i)/(por_list(i)*Xis_list(i)));
                        gamma = c_0^2*rho_0/statPres;
                        
                        rho_omega = chi_list(i)*rho_0/por_list(i)./... % groer Bruch
                            (1-1./(lambda_omega*sqrt(-1i)).*tanh(lambda_omega*sqrt(-1i)));
                        
                        K_omega = rho_0*c_0^2/por_list(i)./... % groer Bruch
                            (1+(gamma-1)./(lambda_omega*sqrt(-N_pr*1i)).*tanh(lambda_omega*sqrt(-N_pr*1i)));
                        
                        Z_a(i) = sqrt(rho_omega.*K_omega);
                        Gamma_a(i) = omega.*sqrt(rho_omega./K_omega);
                    end
                    
                    k_a(r,i) = Gamma_a(i)/1i;
                    Z_out(r,i) = Z_a(i);
                    
                    % Z_s(i) und G_s(i) berechnen und in zlist einsortieren
                    if (typelist(i) == 0) || (typelist(i) == 1)                % lokale oder laterale Schicht ist bei senkrechtem Schalleinfall egal
                        Gamma_a_(i) = Gamma_a(i);
                        Z_a_(i)     = Z_a(i);
                    end
                    
                    % Netzwerkelemente fr Schichten berechnet nach Mechel Bd. III, Gl. (3.8)
                    Z_s(i)  = Z_a_(i) * sinh( Gamma_a_(i) * ts_list(i) );
                    G_s(i)  = ( cosh( Gamma_a_(i) * ts_list(i) ) - 1 ) / ...
                        ( Z_a_(i) * sinh( Gamma_a_(i) * ts_list(i) ) );
                    
                    zlist(2*i)   = Z_s(i);
                    glist(2*i-1) = G_s(i);
                    glist(2*i)   = G_s(i);
                end
                
            end % end: Berechnung von Belgen und Schichten in einer Schleife fr senkrechten Schalleinfall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        else % Berechnung von Belgen und Schichten in einer Schleife fr winkligen Schalleinfall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Die Schallwelle wird in den geschichteten Absorber hineingebrochen.
            % Bei einer lokal reagierenden Schicht, wird die Schallwelle auf das Lot gebrochen
            % Bei lateral reagierenden Schichten muss allerdings bercksichtigt werden, dass
            % sich der Schalleinfallswinkel von Schicht zu Schicht ndert. Dies hat Auswirkungen auf
            % die Schallausbreitung in den Schichten sowie auf den Schalldurchgang durch Platten (Belge)
            theta_in = [];
            cos_theta_in = [];
            Gamma_prev =[];
            theta_in(1)     = theta(s)/180*pi;                 % Initialisierung des Schalleinfallswinkels
            cos_theta_in(1) = cos(theta_in(1));
            Gamma_prev(1)   = 1i*(2*pi*f(r)/c_0);               % die Ausbreitungskonstante vor dem geschichteten Absorber ist gleich derjenigen in Luft
            % Die Variable Gamma_prev enthlt die Ausbreitungskonstante im Vorgngermaterial zur
            % Berechnunung des Brechungswinkels in die nchste Schicht mit Hilfe des Snellschen
            % Brechungsgesetzes. Die Ausbreitungskonstante ist einfallswinkelunabhngig
            for i=1:M
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Berechnung der Folienimpedanzen Z_f
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (tb_list(i) <= 0);                                                     % prfen ob Dummy-Belag
                    Z_f(i) = 0;
                else
                    omega = 2*pi*f(r);
                    switch belag_type(i)
                        case 1                                                            % Massenbelag (luftdicht)
                            m_eff = m_list(i);
                            if eta_list(i)<=0
                                Z_f(i) = 1i*omega*m_eff;
                            else
                                Z_f(i) = 1i*omega*m_eff * ( 1 / (1 + 1i * eta_list(i)) );
                            end
                            
                        case 2                                                            % Massenbelag (luftdurchlssig)
                            m_eff = ( m_list(i) * Rf_list(i) ) / ...
                                ( (1i*omega*m_list(i)/Z_0) + Rf_list(i) );       % Parallelschaltung des Massenbelages mit seinem Strmungswiderstand
                            % siehe Mechel Bd. III, Formel (3.10), S.54
                            Z_f(i) = 1i*omega*m_eff;
                            
                        case 3                                                            % Platte
                            % Berechnung der korrigierten elastischen Masse,
                            % Einfluss der Koinzidenz auf effektive Masse wird bercksichtigt
                            
                            % siehe Mechel Band III, Gleichung (10.39)
                            m_eff = m_list(i) * ( ...
                                ( (-1i) * ( eta_list(i) * (f(r)/f_cr_list(i))^2 * (sin(theta_in(i)))^4 ) )  + ...
                                ( 1 - (f(r)/f_cr_list(i))^2 * (sin(theta_in(i)))^4                      ) ...
                                );
                            Z_f(i) = 1i*omega*m_eff;
                            
                        case 4                                                            % MPP mit Platteneigenschaften
                            % Microperforated Panel Absorber: Formulas taken from
                            % Maa, "Potential of microperforated panel absorber", JASA, 104 (5), 1998
                            t_MPP     = tb_list(i);
                            d_MPP     = dia_MPP_list(i);
                            sigma_MPP = sigma_MPP_list(i);
                            
                            nu_MPP  = 1.789e-5;                                           % Pa s Dynamic viscosity of air
                            k_MPP   = d_MPP * sqrt(omega*rho_0/(4*nu_MPP));
                            
                            k_r_MPP = (1 + (k_MPP^2)/32)^(1/2) + (sqrt(2)/32)*k_MPP*(d_MPP/t_MPP);
                            r_MPP   = (32*nu_MPP*t_MPP)/(sigma_MPP*Z_0*d_MPP^2) * k_r_MPP;
                            
                            k_m_MPP = 1 + (9 + (k_MPP^2)/2)^(-1/2) + 0.85*d_MPP/t_MPP;    % Achtung: die "9" in der Formel ist etwas umstritten. Maa, schreibt in einer Formel "9" und in der nchsten "1"
                            m_MPP   = t_MPP/(sigma_MPP*c_0) * k_m_MPP;                    % Irgendwo ist also ein Tippfehler. Da Sakagami, die Formel allerdings mehrfach mit der "9" zitiert, benutzen wir die "9"
                            
                            Z_MPP  = Z_0 * ( r_MPP + 1i*omega*m_MPP);                      % REMARK: The m_MPP mass term describes the air-piston which is moving in the hole, it has nothing to do with the plate mass!
                            
                            % Berechnung der effektiven Masse unter Bercksichtigung der Plattenbiegeschwingungen
                            % siehe Mechel Band III, Gleichung (10.39)
                            m_eff = m_list(i) * ( ...
                                ( (-1i) * ( eta_list(i) * (f(r)/f_cr_list(i))^2 * (sin(theta_in(i)))^4 ) )  + ...
                                ( 1 - (f(r)/f_cr_list(i))^2 * (sin(theta_in(i)))^4                      ) ...
                                );
                            
                            Z_f(i) = (Z_MPP * 1i*omega*m_eff) / ...
                                (Z_MPP + (1i*omega*m_eff));                    % Parallelschaltung von elastischer Masse und komplexem MPP Widerstand
                            
                        case 5                                                            % MPP ohne Platteneigenschaften
                            % Microperforated Panel Absorber: Formulas taken from
                            % Maa, "Potential of microperforated panel absorber", JASA, 104 (5), 1998
                            t_MPP     = tb_list(i);
                            d_MPP     = dia_MPP_list(i);
                            sigma_MPP = sigma_MPP_list(i);
                            
                            nu_MPP  = 1.789e-5;                                           % Pa s Dynamic viscosity of air
                            k_MPP   = d_MPP * sqrt(omega*rho_0/(4*nu_MPP));
                            
                            k_r_MPP = (1 + (k_MPP^2)/32)^(1/2) + (sqrt(2)/32)*k_MPP*(d_MPP/t_MPP);
                            r_MPP   = (32*nu_MPP*t_MPP)/(sigma_MPP*Z_0*d_MPP^2) * k_r_MPP;
                            
                            k_m_MPP = 1 + (9 + (k_MPP^2)/2)^(-1/2) + 0.85*d_MPP/t_MPP;    % Achtung: die "9" in der Formel ist etwas umstritten. Maa, schreibt in einer Formel "9" und in der nchsten "1"
                            m_MPP   = t_MPP/(sigma_MPP*c_0) * k_m_MPP;                    % Irgendwo ist also ein Tippfehler. Da Sakagami, die Formel allerdings mehrfach mit der "9" zitiert, benutzen wir die "9"
                            
                            Z_MPP  = Z_0 * ( r_MPP + 1i*omega*m_MPP);                      % REMARK: The m_MPP mass term describes the air-piston which is moving in the hole, it has nothing to do with the plate mass!
                            
                            % Z_f(i) = Z_MPP;
                            Z_f(i) = (Z_MPP * 1i*omega*m_list(i)) / ...
                                (Z_MPP + (1i*omega*m_list(i)));                % Parallelschaltung von elastischer Masse und komplexem MPP Widerstand
                    end
                end
                zlist(2*i-1) = Z_f(i);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Berechnung der Lngsimpedanzen Z_s und der Queradmittanzen G_s der Schichten
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (ts_list(i) <= 0)                                                      % prfen ob Dummy-Schicht
                    zlist(2*i)   = 0;
                    glist(2*i-1) = 0;
                    glist(2*i)   = 0;
                    theta_in(i+1) = theta_in(i);
                    cos_theta_in(i+1) = cos_theta_in(i);
                    Gamma_prev(i+1) = Gamma_prev(i);
                else % tslist(i) > 0
                    if ( matlist(i) == 1 )                                                % Luftschicht
                        Z_a(i)     = rho_0 * c_0;
                        Gamma_a(i) = 1i*(2*pi*f(r)/c_0) + airAttenuation(r)/2;
                        % Gamma_a(i) = 1i*(2*pi*f(r)/c_0);
                        
                    elseif ( matlist(i) == 2 )                                            % Por. Abs nach  klassischer Theorie des homogenen Mediums
                        % (siehe Schallabsorber Bd. 2, S. 85-100)
                        Xis_eff    = (1i*2*pi*f(r)*RG_list(i)*Xis_list(i))/(1i*2*pi*f(r)*RG_list(i)+Xis_list(i));
                        % Xis_eff = Xis_list(i);
                        Z_a(i)     = Z_0/por_list(i)*sqrt(chi_list(i)/kappa_eff_list(i)*(1-1i*por_list(i)*Xis_eff/(chi_list(i)*2*pi*f(r)*rho_0)));
                        Gamma_a(i) = 1i*(2*pi*f(r)/c_0)*sqrt(chi_list(i)*kappa_eff_list(i)*(1-1i*por_list(i)*Xis_eff/(chi_list(i)*2*pi*f(r)*rho_0)));
                        
                    elseif ( matlist(i) == 3 )
                        % aus empirischer Kennwertrelation nach Schallabsorber Bd. 2, Gl.(17.15) und Tabelle (17.6)
                        porosity   = 0.95;
                        E          = rho_0*f(r)/Xis_list(i);
                        rho_eff1   = 1/( 1 - tan(sqrt(-6*pi*1i*b_11(i)*E))/sqrt(-6*pi*1i*b_11(i)*E) );
                        C_eff1     = 1 + ((kappa1(i) - 1) * tan(sqrt(-6*pi*1i*kappa1(i)*Prandtl*b_21(i)*E)) / sqrt(-6*pi*1i*kappa1(i)*Prandtl*b_21(i)*E));
                        rho_eff2   = 1/( 1 - tan(sqrt(-6*pi*1i*b_12(i)*E))/sqrt(-6*pi*1i*b_12(i)*E) );
                        C_eff2     = 1 + ((kappa2(i) - 1) * tan(sqrt(-6*pi*1i*kappa2(i)*Prandtl*b_22(i)*E)) / sqrt(-6*pi*1i*kappa2(i)*Prandtl*b_22(i)*E));
                        
                        Z_a(i)     = Z_0/porosity*sqrt(rho_eff2/C_eff2);
                        Gamma_a(i) = 1i*(2*pi*f(r)/c_0)*sqrt(rho_eff1*C_eff1);
                        
                    elseif ( matlist(i) == 4 )
                        % aus dem von Takeshi Komatsu optimierten Delany-Bazley-Modell fr faserartige Absorbermaterialien mit hohen Porsitten.
                        % siehe Acoustic Science & Technology 29, 2 (2008)! Das ursprngliche Modell unter Applied Acoustics, 3, 105-116 (1970)
                        Z_a(i)     = Z_0 * ((1 + 0.00027*(2-log10(f(r)/Xis_list(i)))^(6.2)) - 1i*0.0047*(2-log10(f(r)/Xis_list(i)))^(4.1));
                        Gamma_a(i) = 2*pi*f(r)/c_0 * ((0.0069*(2-log10(f(r)/Xis_list(i)))^(4.1)) + 1i*(1+0.0004*(2-log10(f(r)/Xis_list(i)))^(6.2)));
                        
                    elseif ( matlist(i) == 5 )
                        % Das Original Delany Bazley Modell (siehe Komatsu Paper Acoustic Science & Technology 29, 2 (2008), da ist es sauber aufgeschrieben)
                        % Original Verffentlichung: Applied Acoustics, 3, 105-116 (1970)
                        
                        % Coefficients
                        aa =  0.0497; cc =  0.0758; pp =  0.1690; rr =  0.0858;
                        bb = -0.7540; dd = -0.7320; qq = -0.5950; ss = -0.7000;
                        
                        % Real and Imaginary Part of characteristic impedance and propagation constant
                        R_db     =  Z_0            * ( 1 + aa * ( f(r)/Xis_list(i) )^bb );
                        X_db     = -Z_0            * (     cc * ( f(r)/Xis_list(i) )^dd );
                        alpha_db = (2*pi*f(r)/c_0) * (     pp * ( f(r)/Xis_list(i) )^qq );
                        beta_db  = (2*pi*f(r)/c_0) * ( 1 + rr * ( f(r)/Xis_list(i) )^ss );
                        
                        Z_a(i)     = R_db + 1i*X_db;
                        Gamma_a(i) = alpha_db + 1i*beta_db;
                        
                    elseif ( matlist(i) == 6 )
                        % Das Miki Modell (siehe Komatsu Paper Acoustic Science & Technology 29, 2 (2008), da ist es sauber aufgeschrieben)
                        % Es handelt sich um eine Abwandlung des Delany Bazley Modells
                        % Original Verffentlichung: J. Acoust. Soc. Jpn., 11, pp.19-24 (1990)
                        
                        % Coefficients
                        aa =  0.0699; cc =  0.1070; pp =  0.1600; rr =  0.1090;
                        bb = -0.6320; dd = -0.6320; qq = -0.6180; ss = -0.6180;
                        
                        % Real and Imaginary Part of characteristic impedance and propagation constant
                        R_db     =  Z_0            * ( 1 + aa * ( f(r)/Xis_list(i) )^bb );
                        X_db     = -Z_0            * (     cc * ( f(r)/Xis_list(i) )^dd );
                        alpha_db = (2*pi*f(r)/c_0) * (     pp * ( f(r)/Xis_list(i) )^qq );
                        beta_db  = (2*pi*f(r)/c_0) * ( 1 + rr * ( f(r)/Xis_list(i) )^ss );
                        
                        Z_a(i)     = R_db + 1i*X_db;
                        Gamma_a(i) = alpha_db + 1i*beta_db;
                    elseif (matlist(i) == 7)
                        %% Modell nach Attenborough
                        % "Modeling and optimization of two layer porous
                        % asphalt roads" von Kuijpers, van Blokland
                        % Xi Strmungswiderstand
                        % Chi Grad der Gewundenheit der Transportwege in den Poren porser Materialien
                        % sigma Porsitt
                        % p_0 Normaldruck
                        % N_Pr Prandtl Zahl (wird hier fr Erdl/ Bitumen
                        % angenommen N_pr = 220
                        
                        N_pr = 220;
                        omega = 2*pi*f(r);
                        
                        lambda_omega = sqrt(3*rho_0*omega*chi_list(i)/(por_list(i)*Xis_list(i)));
                        gamma = c_0^2*rho_0/statPres;
                        
                        rho_omega = chi_list(i)*rho_0/por_list(i)./... % groer Bruch
                            (1-1./(lambda_omega*sqrt(-1i)).*tanh(lambda_omega*sqrt(-i)));
                        
                        K_omega = rho_0*c_0^2/por_list(i)./... % groer Bruch
                            (1+(gamma-1)./(lambda_omega*sqrt(-N_pr*1i)).*tanh(lambda_omega*sqrt(-N_pr*i)));
                        
                        Z_a(i) = sqrt(rho_omega.*K_omega);
                        Gamma_a(i) = omega*sqrt(rho_omega./K_omega);
                        
                    end
                    
                    k_a(r,i) = Gamma_a(i)/1i;
                    Z_out(r,i) = Z_a(i);
                    
                    % Bercksichtigung des Einfallswinkels auf die Absorberschicht
                    if typelist(i) == 0             % lokale Schicht
                        % Die Definition von Z_a_ wurde hier abweichend von Mechel Bd. 3 S.53 [Z_a_ = Z_a/cos(theta(s)/180*pi)] gewhlt,
                        % da es sich hier um einen Fehler handelt (Dies wird auch durch Berechnung der Absorption in Bild 3.11 klar).
                        % Fr die lokale Schicht breitet sich im Absorber ausschlielich ein Schallfeld senkrecht zur Absorberflche aus.
                        % Die Feldimpedanz sollte folglich auch unabhngig vom Einfallswinkel sein!
                        % Auerdem sollte der lokal reagierende Absorber den Grenzfall des lateral reagierenden Absorbers darstellen, mit theta_a -> 0
                        % Nhere Infos siehe Unterlagen
                        
                        Gamma_a_(i) = Gamma_a(i);
                        Z_a_(i)     = Z_a(i);              % siehe Kommentar oben
                        
                        % In einer lokal reagierenden Schicht wird der Schall aufs
                        % Lot gebrochen... der Ausfallswinkel ist also = 0
                        % Initialisierung fr nchste Schicht:
                        theta_in(i+1) = 0;
                        cos_theta_in(i+1) = 1;
                        Gamma_prev(i+1) = Gamma_a(i);
                        
                    elseif typelist(i) == 1          % laterale Schicht
                        % Zur Definition von lokalen und lateralen Schichten siehe Mechel Bd. I S.39ff und S.23ff
                        % Achtung: Das MINUS in der Wurzel ist richtig... siehe Formel 3.20 in Mechel Bd.1
                        cos_theta_a = sqrt( 1 - (Gamma_prev(i)/Gamma_a(i))^2 * ( 1 - cos_theta_in(i)^2 ) );
                        Gamma_a_(i) = Gamma_a(i)*cos_theta_a;
                        Z_a_(i)     = Z_a(i)/cos_theta_a;
                        % Im gedmpften porsen Absorber ist cos_theta_a komplex und damit auch der Ausfallswinkel. Fr die Bercksichtigung
                        % der Koinzidenz bei der Berechnung der Folienimpedanzen sind wir allerdings nur an der Ausbreitungsrichtung der Welle
                        % im Absorber interessiert. Hierzu berechnen wir die Richtung der Ausbreitungsterme der transmittierten Wellen, mit dem
                        % Ansatz in Mechel Bd. I, Gl. 3.18 ...
                        % die eigene Herleitung befindet sich handschriftlich in den Unterlagen zum Impedanzprogramm
                        sin_theta_a = sqrt( 1-(cos_theta_a)^2 );
                        theta_a_propagation = atan( imag(Gamma_a(i)*sin_theta_a) / imag(Gamma_a(i)*cos_theta_a) ); % in radiant
                        
                        % In einer lateral reagierenden Schicht wird der Schall nicht zwangslufig
                        % aufs Lot gebrochen... wir mssen uns den Ausfallswinkel merken... denn er ist Einfallswinkel
                        % an der nchsten Grenzschicht
                        % Initialisierung fr nchste Schicht:
                        theta_in(i+1) = theta_a_propagation;
                        cos_theta_in(i+1) = cos_theta_a;
                        Gamma_prev(i+1) = Gamma_a(i);
                        
                    end
                    
                    % Netzwerkelemente fr Schichten berechnet nach Mechel Bd. III, Gl. (3.8)
                    Z_s(i)  = Z_a_(i) * sinh( Gamma_a_(i) * ts_list(i) );
                    G_s(i)  = ( cosh( Gamma_a_(i) * ts_list(i) ) - 1 ) / ...
                        ( Z_a_(i) * sinh( Gamma_a_(i) * ts_list(i) ) );
                    
                    zlist(2*i)   = Z_s(i);
                    glist(2*i-1) = G_s(i);
                    glist(2*i)   = G_s(i);
                end
            end % end: Berechnung von Belgen und Schichten in einer Schleife fr winkligen Schalleinfall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Berechnung der Impedanzen und Admittanzen von Lochblechen und
        % einsortieren in die Listen, es kann jeweils maximal 1 Lochblech
        % pro Lage eingefgt werden
        % Einfallswinkel spielt hier keine Rolle
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for i=M:-1:1
            if (d_lp(i) > 0) % Dummy_Lochplatten knen ignoriert werden
                omega = 2*pi*f(r);
                % Es ist nicht ganz klar ob die Ersatzimpedanzen fr das Lochleitungsstck mit der Porsitt der Lochplatte gewichtet werden mssen,
                % aus Mechel geht dies nicht eindeutig hervor. Dafr spricht aber die Testrechnung auf Hilfsblatt 2
                
                % Mit Gewichtung mit Porositt
                Z_loch = (1/sigma_lp(i)) * 1i * Z_0 * (1-cos(omega/c_0*d_lp(i))) / (sin(omega/c_0*d_lp(i)));
                G_loch = (sigma_lp(i))   * 1i * sin(omega/c_0*d_lp(i)) / Z_0;
                
                % Ohne Gewichtung mit Porositt
                % Z_loch = 1i * Z_0 * (1-cos(omega/c_0*d_lp(i))) / (sin(omega/c_0*d_lp(i)));   %
                % G_loch = 1i * sin(omega/c_0*d_lp(i)) / Z_0;                                  %
                
                % muend_corr = 0.4;  % Mndungskorrektur aus TA-Skript fr Helmholtzresonator
                muend_corr = get_muend_corr(shape_list(i), a_list(i), b_list(i), f(r), c_0);
                
                % Berechnung der mitschwingenden Mediumsmassen vor und hinter der Lochplatte:
                
                % Ausbreitungskonstante und charakteristische Wellenimpedanz fr Schicht VOR der Lochplatte holen
                if i ~= 1 % Falls nicht in der ersten Lage
                    Z_an_lpv  = Z_a(i-1) / Z_0;
                    Gamma_lpv = Gamma_a(i-1) / (omega/c_0);
                elseif i == 1           % fr ein Lochblech vor der ersten Absorberschicht muss die freie Mitschwing-Impedanz berechnet werden
                    % siehe Mechel, Bd. II, S. 744 Z_msh0
                    Z_an_lpv  = 1;
                    Gamma_lpv = 1i;
                end
                
                % Gegebenenfalls Ausbreitungskonstante und charakteristische Wellenimpedanz fr Schicht HINTER der Lochplatte holen
                if ( ts_list(i) > 0 ) % Prfen ob Schicht hinter Lochplatte definiert, theoretisch sind auch Strmungswiderstandsbelge direkt
                    % vor und hinter der Lochplatte erlaubt
                    Z_an_lph  = Z_a(i) / Z_0;
                    Gamma_lph = Gamma_a(i) / (omega/c_0);
                elseif ( (ts_list(i) <= 0) && (i ~= M) )
                    % Es exisitert keine Schicht unmittelbar hinter der Lochplatte. Dies ist nur dann sinnvoll, wenn vor und
                    % hinter der Lochplatte ein Belag ist. In diesem Fall muss die bernchste Schicht fr die hintere
                    % mitschwingende Mediumsmasse bercksichtigt werden
                    Z_an_lph  = Z_a(i+1) / Z_0;
                    Gamma_lph = Gamma_a(i+1) / (omega/c_0);
                elseif ( (ts_list(i) <= 0) && (i == M) )
                    % Es gibt keine Absorberschicht hinter der letzten
                    % Lochplatte, damit ist die Lochplatte vor Freifeld
                    Z_an_lph  = 1;
                    Gamma_lph = 1i;
                end
                
                Z_mv   = 1 / sigma_lp(i) * Z_0 * omega/c_0 * a_list(i) * muend_corr * (Gamma_lpv * Z_an_lpv);
                Z_mh   = 1 / sigma_lp(i) * Z_0 * omega/c_0 * a_list(i) * muend_corr * (Gamma_lph * Z_an_lph);
                Z_pv   = Z_mv + Z_loch;
                Z_ph   = Z_mh + Z_loch;
                
                glist(2*i:length(glist)+1) = glist(2*i-1:length(glist));
                glist(2*i-1) = G_loch;
                
                zlist(2*i:length(zlist)+1) = zlist(2*i-1:length(zlist));
                if     side_list(i) == 0         % Folie vor Lochplatte
                    zlist(2*i-1) = zlist(2*i-1)/sigma_lp(i) + Z_pv;
                    zlist(2*i)   = Z_ph;
                elseif side_list(i) == 1         % Folie hinter Lochplatte
                    zlist(2*i-1) = Z_pv;
                    zlist(2*i)   = zlist(2*i)/sigma_lp(i) + Z_ph;
                end
            end
        end
        % end: Berechnung Lochplatten senkrechter und winkliger Schalleinfall %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Fr matrixModus 0 muss der Abschluss noch bercksichtigt werden:
        % Zur Berechnung der Eingangsimpedanz wird immer mit einem normierten
        % Schalldruck p(N+1)=1 am Ende des geschichteten Absorbers gerechnet,
        % Eine mgliche Lastimpedanz muss deshalb als Admittanz zur hinteren
        % Queradmittanz der hintersten Schicht hinzuaddiert werden
        if matrixModus == 0
            if Abschluss == 0                               % schallharter Abschluss
                % nix tun; unproblematisch da Lastimpedanz = unendlich
                % und demnach die hinzuzuaddierende Admittanz = 0;
            elseif Abschluss == 1                           % Freifeld Abschluss
                % Freifeld-Admittanz hinzuaddieren
                % Auch hier muss die Ausfallsrichtung hinter dem Absorber
                % bercksichtigt werden, diese ist i.d.R. nicht identisch mit der
                % Einfallsrichtung vor dem Absorber
                if (length(theta) == 1) && (theta(1)==0)
                    glist(length(glist)+1) = 1/Z_0;
                else % winkliger Schalleinfall
                    glist(length(glist)+1) = cos(theta_in(M+1))/Z_0;
                end
                zlist(length(zlist)+1) = 0;
            elseif Abschluss == 2                           % Vakuum Abschluss
                % das macht nur Sinn, wenn die letzte Lage mit einem Belag
                % abgeschlossen ist (Dies muss im GUI abgefangen werden!)
                % Dies fhrt zu einem Sonderfall, da hier eine unendliche Admittanz zum letzten Querzweig addiert
                % werden msste. Deshalb rutscht die hinterste Belagsimpedanz in den Querzweig.
                % Formel fr tau, funktioniert dann nicht, deshalb wird tau per
                % if-Abfrage in diesem Fall zu Null gesetzt (siehe unten)
                if ( zlist(length(zlist)-1) ~= 0 )
                    glist(length(glist)) = glist(length(glist)) + 1/zlist(length(zlist)-1);
                    zlist(length(zlist)-1) = 0;
                else
                    glist(length(glist)) = glist(length(glist)) + 1/eps;
                    zlist(length(zlist)-1) = 0;
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Berechnung der Absorberimpedanz durch Iteration
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        N = length(glist);
        
        % matrixModus 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ( matrixModus == 0 )
            if ( M ~= 0 )
                % Initialisierung der Vektoren fr die Schalldrcke und Schnellen im Netzwerk
                % Startwerte fr Rckwrtsiteration: p(N+1) = 1, v_l(N+1) = 0;
                p = zeros(1,N+1); p(N+1) = 1;
                v_l = zeros(1,N+1);
                v_q = zeros(1,N);
                
                for n = N:-1:1
                    v_q(n) = glist(n)*p(n+1);
                    v_l(n) = v_q(n) + v_l(n+1);
                    p(n) = p(n+1) + zlist(n)*v_l(n);
                end
                
                p_vorne(r,s) = p(1);
                v_vorne(r,s) = v_l(1);
                % Impedanz Z(freq, theta)
                Z(r,s) = p(1)/v_l(1);
                
                % Transmissionsgrad tau(theta)
                % TODO!!!
                % ACHTUNG!!! Das stimmt nicht so 100% wenn der Ausfallwinkel
                % hinter dem geschichteten Absorber anders ist als der
                % Einfallswinkel vor dem Absorber!!! Siehe Mechel Bd III
                % S.51... das muss noch gendert werden
                if Abschluss == 1
                    tau(r,s) = 4 * abs(p(N+1)/p(1))^2 * abs( 1 + ( (Z_0/cos(theta(s)/180*pi)) / Z(r,s) ) )^(-2);
                    R_bau(r,s) = 10*log10(1/tau(r,s));
                else
                    tau(r,s) = 0;
                end
                
                
                % Admittanz Y(f,theta)
                if Z(r,s) ~= 0
                    Y(r,s) = 1/Z(r,s);
                else
                    Y(r,s) = 1/eps;
                end
                
                % Reflektionsfaktor R(f,theta)
                R(r,s)     = (Z(r,s)*cos(theta(s)/180*pi) - Z_0) / (Z(r,s)*cos(theta(s)/180*pi) + Z_0);
                
                % Absorptionsgrad alpha(f,theta)
                alpha(r,s)     = 1 - (abs(R(r,s)))^2;
                
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % matrixModus 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Berechnung der Kettenmatrix-Parameter
        if (matrixModus == 1)
            if ( M ~= 0 )
                % Initialisierung der Vektoren fr die Schalldrcke und Schnellen im Netzwerk
                % Startwerte fr Rckwrtsiteration: p(N+1) = 1, v_l(N+1) = 0;
                % Leerlauffall: p(1) = a11 und v_l(1) = a21
                p = zeros(1,N+1); p(N+1) = 1;
                v_l = zeros(1,N+1);
                v_q = zeros(1,N);
                
                for n = N:-1:1
                    v_q(n) = glist(n)*p(n+1);
                    v_l(n) = v_q(n) + v_l(n+1);
                    p(n) = p(n+1) + zlist(n)*v_l(n);
                end
                
                % Kettenmatrixparameter a11, a21
                a11(r,s) = p(1);
                a21(r,s) = v_l(1);
                
                % Initialisierung der Vektoren fr die Schalldrcke und Schnellen im Netzwerk
                % Startwerte fr Rckwrtsiteration: p(N+1) = 0, v_l(N+1) = 1;
                % Kurzschlussfall: p(1) = a12 und v_l(1) = a22
                p = zeros(1,N+1);
                v_l = zeros(1,N+1); v_l(N+1) = 1;
                v_q = zeros(1,N);
                
                for n = N:-1:1
                    v_q(n) = glist(n)*p(n+1);
                    v_l(n) = v_q(n) + v_l(n+1);
                    p(n) = p(n+1) + zlist(n)*v_l(n);
                end
                
                % Kettenmatrixparameter a12, a22
                a12(r,s) = p(1);
                a22(r,s) = v_l(1);
                
                det_A(r,s) = a11(r,s)*a22(r,s) - a12(r,s)*a21(r,s);
                
                % Umrechnung der Kettenmatrix-Parameter in Admittanzmatrix-Parameter
                if (a12(r,s) ~= 0)
                    y11(r,s) = a22(r,s)/a12(r,s);
                    y12(r,s) = -det_A(r,s)/a12(r,s);
                    y21(r,s) = -1/a12(r,s);
                    y22(r,s) = a11(r,s)/a12(r,s);
                else % a12(r,s) == 0
                    % alle Eintrge der ymatrix gehen gegen unendlich
                    y11(r,s) = a22(r,s)/eps;
                    y12(r,s) = -det_A(r,s)/eps;
                    y21(r,s) = -1/eps;
                    y22(r,s) = a11(r,s)/eps;
                end
                % Umrechnung der Kettenmatrix-Parameter in Impedanzmatrix-Parameter
                if (a21(r,s) ~= 0)
                    z11(r,s) = a11(r,s)/a21(r,s);
                    z12(r,s) = det_A(r,s)/a21(r,s);
                    z21(r,s) = 1/a21(r,s);
                    z22(r,s) = a22(r,s)/a21(r,s);
                else % a21(r,s) == 0
                    % alle Eintrge der ymatrix gehen gegen unendlich
                    z11(r,s) = a11(r,s)/eps;
                    z12(r,s) = det_A(r,s)/eps;
                    z21(r,s) = 1/eps;
                    z22(r,s) = a22(r,s)/eps;
                end
            end
        end
    end
end

% zusatzliche Parameter fuer diffusen Schalleinfall %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diffusfeldabsorptions und Transmissionsgrad und Diffusfeldschalldmmma
% siehe Mechel Bd.I, 4.91 - 4.93 (insbesondere die Anpassung der Formel, falls theta_o ~= 90)
% ACHTUNG: Die Formeln fr die Diffusfeldparameter mssen noch vollstndig
% verifiziert werden, siehe hierzu MECHEL Bd.I, Formeln (4.91)-(4.93)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( matrixModus == 0 && Einfalls_Art == 1 )
    
    for r = 1:length(f)
        for s = 1:(length(theta)-1)
            x1    = theta(s)  /180*pi;
            x2    = theta(s+1)/180*pi;
            
            % alpha_diff and tau_diff are calculated according to Mechel Bd. I
            func1a = alpha(r,s) * cos(x1)   * sin(x1);
            func2a = alpha(r,s+1) * cos(x2) * sin(x2);
            alpha_diff(r) = alpha_diff(r) + ( func1a + 1/2*(func2a - func1a) )*( x2 - x1 );
            
            func1t = tau(r,s) * cos(x1)   * sin(x1);
            func2t = tau(r,s+1) * cos(x2) * sin(x2);
            tau_diff(r) = tau_diff(r) + ( func1t + 1/2*(func2t - func1t) )*( x2 - x1 );
            
            % REMARK: It is debatable if the cos-Term has to be considered
            % in the integration for the diffuse field admittance. For more information please see the ACTA
            % Paper on FEM boundaries by Marc Aretz and the herein mentioned references
            
            % func1y = Y(r,s) * cos(x1)   * sin(x1);
            % func2y = Y(r,s+1) * cos(x2) * sin(x2);
            % func1ref = cos(x1)   * sin(x1);
            % func2ref = cos(x2) * sin(x2);
            
            func1y = Y(r,s) * sin(x1);
            func2y = Y(r,s+1) * sin(x2);
            % func1z = Z(r,s) * sin(x1);
            % func2z = Z(r,s+1) * sin(x2);
            func1r = R(r,s) * sin(x1);
            func2r = R(r,s+1) * sin(x2);
            func1ref = sin(x1);
            func2ref = sin(x2);
            
            Y_diff(r) = Y_diff(r) + ( func1y + 1/2*(func2y - func1y) )*( x2 - x1 );
            % Z_diff(r) = Z_diff(r) + ( func1z + 1/2*(func2z - func1z) )*( x2 - x1 );
            R_diff(r) = R_diff(r) + ( func1r + 1/2*(func2r - func1r) )*( x2 - x1 );
            ref(r) = ref(r) + ( func1ref + 1/2*(func2ref - func1ref) )*( x2 - x1 );
        end
        
        alpha_diff(r) = alpha_diff(r)*2/((sin(theta_o/180*pi))^2);
        
        tau_diff(r)   = tau_diff(r)*2/((sin(theta_o/180*pi))^2);
        R_bau_diff(r) = 10*log10(1/tau_diff(r));
        
        Y_diff(r)     = Y_diff(r)/ref(r);
        % Z_diff(r)     = Z_diff(r)/ref(r);
        R_diff(r)     = R_diff(r)/ref(r);
    end
    
    Z_diff = 1./Y_diff;
    
end
%Speichern der Ergebnisse in struct erg

% dlmwrite('impedanceMatrix.txt', [ NaN, theta ; [ f.' , Z]], '\t');

erg.Z=Z;
erg.Y=Y;
erg.R=R;
erg.alpha=alpha;
erg.tau=tau;
erg.R_bau=R_bau;

erg.Z_diff=Z_diff;
erg.Y_diff=Y_diff;
erg.R_diff=R_diff;
erg.alpha_diff=alpha_diff;
erg.tau_diff=tau_diff;
erg.R_bau_diff=R_bau_diff;

erg.a11=a11;
erg.a12=a12;
erg.a21=a21;
erg.a22=a22;
erg.det_A=det_A;

erg.y11=y11;
erg.y12=y12;
erg.y21=y21;
erg.y22=y22;

erg.z11=z11;
erg.z12=z12;
erg.z21=z21;
erg.z22=z22;

erg.modus=matrixModus;
erg.f=f;
erg.theta=theta;

erg.k_a = k_a;
erg.Z_a = Z_out;