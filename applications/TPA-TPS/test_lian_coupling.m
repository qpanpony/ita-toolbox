%% This script constructs different matrices. Taking some coordinates off
%In the end pressure and velocity are abtained
% Lian Gomes - 15/7/2011
% lian.cercal.gomes@gmailcom
%% Reading Data

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>

folder = '\\verdi\scratch\gomes\für Pascal\Results&Scripts\System Plate_Beam\Results\';
Yr = ita_read([folder 'Plate\Placa.ita']);
Ys = ita_read([folder 'BeamMobility\VigaMobility.ita']);
TP = ita_read('\\verdi\scratch\gomes\für Pascal\Results&Scripts\System Source_Plate_Box\Results\CoupledSystem-PlateBox\BoxNumeric.ita');
vf = ita_read([folder 'BeamFreeVelocity\VigaFree.ita']);
Fb = ita_read([folder 'BeamBlocked\VigaBlock.ita']);
YcS = ita_read([folder 'PlateBeam\PlacaViga.ita']);

%% TP Interpolation
for idx=1:54
    TP(idx).signalType = 'energy';
    TP(idx) = ita_interpolate_spk(ita_interpolate_dat(TP(idx),Yr(3,3).samplingRate),Yr(3,3).fftDegree);
    TP(idx).freq = TP(idx).freq(1:length(TP(idx).freq)-1);
end

%% DIFFERENTIATE - to get velocity
Yr = ita_differentiate(Yr);
Ys = ita_differentiate(Ys);
Fb = ita_differentiate(Fb);
TP = ita_differentiate(TP);


%% COMPLETE matrix
tol = eps*10^10; %tolerance for pseudo invertation
NAmplitude = 0.2; %amplitude for noise

K = pinv(Yr+Ys)*Ys; 
F_insitu = K*Fb;
TP = [TP(1:6) ;TP(19:24); TP(37:42)] ;

for idx=1:18
   TP2(1,idx) = TP(idx,1);
end

TP = TP2;

% Sumation - Change the sum to work with itaAudioMatrix is better

for idx = 1:18
    F_insitu_sum(idx,1) = sum(F_insitu(idx,:).merge);
end

p = TP*F_insitu_sum;
v = Yr*F_insitu_sum;

for idx = 1:6
    v_sum(idx,1) = v(idx)+v(6+idx)+v(12+idx);
end

% v_noise = test_lian_tps_add_noise(v, NAmplitude);

% res = ita_otpa(p.merge,v_sum.merge)

%% NO MOMENTS
m=1:6:18;
m=sort([m m+1 m+2]);
Yrm = Yr(m,m);
Ysm = Ys(m,m);
F_bm = Fb(m,m);

Km = pinv(Yrm + Ysm,tol)*Ysm;
F_insitum = Km*F_bm;
vm = Yrm*F_insitum;
vm_noise = test_lian_tps_add_noise(vm, NAmplitude); %PDI does not work

TPm = TP (m);
for idx = 1:numel(TPm)
    pm(idx) = sum(TPm(idx) * F_insitum(idx));
    pm(idx).comment = 'No Moments'
end

%% NO MOMENTS IN K
Kam = K(m,m);
F_insituam = Kam*F_bm;
vam = Yram*F_insituam; %PDI:YRAm does not exist
vam_noise = test_lian_tps_add_noise(vam, NAmplitude);

TPam = TP (m);
for idx = 1:numel(TPam)
    pam(idx) = sum(TPam(idx) * F_insituam(idx));
    pam(idx).comment = 'No Moments in K'
end

%% ONLY NORMAL
n=3:6:18;
Yrn = Yr(n,n);
Ysn = Ys(n,n);
F_bn = Fb(n,n);

Ycn =  pinv(pinv(Yrn,tol)+pinv(Ysn,tol),tol);

Kn = pinv(Yrn + Ysn,tol)*Ysn;
F_insitun = Kn*F_bn;
vn = Yrn*F_insitun;
vn_noise = test_lian_tps_add_noise(vn, NAmplitude);

TPn = TP (n);
for idx = 1:numel(TPn)
    pn(idx) = sum(TPn(idx) * F_insitun(idx));
    pn(idx).comment = 'Only Normal'
end

%% ONLY FZ;MX;MY
o=3:6:18;
o=sort([o o+1 o+2]);
Yro = Yr(o,o);
Yso = Ys(o,o);
F_bo = Fb(o,o);

Ko = pinv(Yro + Yso,tol)*Yso;
F_insituo = Ko*F_bo;
vo = Yro*F_insituo;
vo_noise = test_lian_tps_add_noise(vo, NAmplitude);

TPo = TP (o);
for idx = 1:numel(TPo)
    po(idx) = sum(TPo(idx) * F_insituo(idx));
    po(idx).comment = 'Only most important (Fz,Mx,My)'
end


%% Compare Pressure Caused by normal direction
compare(1) = p(3);
compare(2) = pm(3);
compare(3) = pam(3);
compare(4) = pn(1);
compare(5) = po(1);
compare.merge.plot_spk

%% Compare Pressure Sum
compareS(1) = sum(p);
compareS(2) = sum(pm);
compareS(3) = sum(pam);
compareS(4) = sum(pn);
compareS(5) = sum(po);
compareS.merge.plot_spk
%% Compare F_insitu

compareF(1) = F_insitu(3,3);
compareF(2) = F_insitum(3,3);
compareF(3) = F_insituam(3,3);
compareF(4) = F_insitun(1,1);
compareF(5) = F_insituo(1,1);


