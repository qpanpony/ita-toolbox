%% BOSCH Topic - Fourpole (two-port) in matrix notation
% Author: Pascal Dietrich - 2011 - pdi@akustik.rwth-aachen.d
% CONFIDENTIAL
% 

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Init
ccx
sr          = 44100;
fftDegree   = 14;

%% Generate Scenario - Source: mass - Fourpole: additional mass - Receiver: spring
s = itaAudio();
s.fftDegree    = fftDegree;
s.samplingRate = sr;
s.freq = 1i * 2 * pi * s.freqVector;
s = s * itaValue('Hz');

%% Inits
Null = repmat(0*s/itaValue('Hz'),2,2);
Ys   = Null;
Yr   = Null;

%% Source
m1 = itaValue('0.1 kg');
m2 = itaValue('0.3 kg');
Ys(1,1) = 1 / (s * m1);
Ys(2,2) = 1 / (s * m2);

%% Receiver
n1 = itaValue(1e-7, 'm/N');
n2 = itaValue(1e-8, 'm/N');
Yr(1,1) = s * n1;
Yr(2,2) = s * n2;

%% resonances without two-port
ita_disp('Resonance frequencies without two port')
f1 = 1/(2 * pi * sqrt( (m1) * n1))
f2 = 1/(2 * pi * sqrt( (m2) * n2))

%% Yc without two-port
Yc = Yr * pinv(Yr + Ys) * Ys;
Yc(1,1).comment = 'Yc - no two-port';
Yc.merge.plot_spkphase

%% clean up
close all
clc

%% Two-port with mass
delta_m1 = itaValue(0.01,'kg');
delta_m2 = itaValue(0.01,'kg');
A  = 0*Null+eye(2);
B  = Null * itaValue('kg/s');
B(1,1) = - s * delta_m1;
B(2,2) = - s * delta_m2;
C  = Null * itaValue('s/kg');
D  = 0*Null+eye(2);
T1 = [A B; C D];

%% Two Port with spring
delta_n1 = itaValue(1e-5, 'm/N');
delta_n2 = itaValue(1e-5, 'm/N');
A  = 0*Null+eye(2);
B  = Null * itaValue('kg/s');
% B(1,1) = - 1/(s * delta_n1);
% B(2,2) = - 2/(s * delta_n2);
C  = Null * itaValue('s/kg');
C(1,1) =  -(s * delta_n1);
C(2,2) =  -(s * delta_n2);
D  = 0*Null+eye(2);
T2 = [A B; C D];

%% Multiplication of single two-ports
T3 = T1 * T2 * T1;
A = T3(1:2,1:2);
B = T3(1:2,3:4);
C = T3(3:4,1:2);
D = T3(3:4,3:4);

%% resonances including two-port
ita_disp('Resonance frequencies including two port')
f1 = 1/(2 * pi * sqrt( (m1 + delta_m1 ) * (n1 + delta_n1)))
f2 = 1/(2 * pi * sqrt( (m2 + delta_m2 ) * (n2 + delta_n2)))

%% two-port transformation equation - now isolator is included into the source
Ys_incl = ita_tps_two_port_transformation(Ys, A, B, C, D);
Ys_incl.merge.plot_spkphase

%% Ys_incl connected to structure Yr
Yc_tp = Yr * pinv(Yr + Ys_incl) * Ys_incl;
Yc_tp(1,1).comment = 'Yc - including two-port';
Yc_tp.merge.plot_spkphase

%% ********************** Isolators of AuralizationBox ********************
%% Inits
s = itaAudio();
s.fftDegree    = fftDegree;
s.samplingRate = sr;
s.freq = 1i * 2 * pi * s.freqVector;
s = s * itaValue('Hz');
Null = repmat(0*s/itaValue('Hz'),3,3);

%% units INIT
F_units = {'N','N m','N m'};
v_units = {'m/s','1/s','1/s'};
for idx = 1:numel(F_units)
    for jdx = 1:numel(v_units)
        Aunit(idx,jdx) = itaValue(0,ita_deal_units(F_units{idx}, F_units{jdx},'/'));
        Bunit(idx,jdx) = itaValue(0,ita_deal_units(F_units{idx}, v_units{jdx},'/'));
        Cunit(idx,jdx) = itaValue(0,ita_deal_units(v_units{idx}, F_units{jdx},'/'));
        Dunit(idx,jdx) = itaValue(0,ita_deal_units(v_units{idx}, v_units{jdx},'/'));
    end
end
Ainit = Null * Aunit + eye(3);
Binit = Null * Bunit;
Cinit = Null * Cunit;
Dinit = Null * Dunit + eye(3);

%% Two-port with mass / moment of inertia
% values
m = itaValue(0.01,'kg');
r = itaValue(0.005,'m');
l = itaValue(0.005,'m');
J = m *(r^2/4 + l^2/12);

A  = Ainit;B = Binit; C=Cinit;D = Dinit;

B(1,1) = - s * m;
B(2,2) = - s * J;
B(3,3) = - s * J;

T_mass = [A B; C D];


%% Two Port with spring
%values
n = itaValue(1e-5, 'm/N');
n_rot = itaValue(1e-5, '1/N m');

A  = Ainit;B = Binit; C=Cinit;D = Dinit;

C(1,1) =  -(s * n);
C(2,2) =  -(s * n_rot);
C(3,3) =  -(s * n_rot);

T_spring = [A B; C D];

%% Isolator
T_iso = T_mass * T_spring * T_mass;
A_iso = T3(1:2,1:2);
B_iso = T3(1:2,3:4);
C_iso = T3(3:4,1:2);
D_iso = T3(3:4,3:4);

m = itaValue(0.01,'kg');
n = itaValue(1e-5, 'm/N');
[A B C D] = ita_tpa_isolator(m,n,fftDegree,sr,{'N','N m','N m'},{'m/s','1/s','1/s'});

%%
m = itaValue(0,'kg');
n = itaValue(0, 'm/N');
[A B C D] = ita_tpa_isolator(m,n,fftDegree,sr,{'N','N m','N m'},{'m/s','1/s','1/s'})

