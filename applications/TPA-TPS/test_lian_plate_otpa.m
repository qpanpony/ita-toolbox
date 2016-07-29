%% Script to OTPA evaluation. Use the  analytic solution for plate out
% of plane vibrations. Make TPS. Test OTPA
% Lian Gomes - 15/7/2011
% lian.cercal.gomes@gmailcom

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%PDI: not finished yet

%% init
sr = 1500;
fmax = 500;
fftDegree = 16;

%% ****************************** source ****************************
%% Plate Geometry
lxs  = .3; %dimension in x direction
lys  = .3; %dimension in y direction
ts   = 1e-3; % thickness

Geoms = itaCoordinates([lxs lys ts]); %create itaCoordinates

%% Response Points
h = figure;
P = itaCoordinates(3);
P.x = [lxs/3 2*lxs/3 3*lxs/8];
P.y = [lys/4 lys/4 lys/1.5];
P.z = zeros(1,3);
P.scatter %plot points

% plot geometry
line([0 lxs],[0 0],[0 0])
line([0 lxs],[lys lys],[0 0])

line([0 0],[0 lys],[0 0])
line([lxs lxs],[0 lys],[0 0])

view(0,90)
ylim([-lys , 2*lys])
xlim([-lxs , 2*lxs])
grid off

%% Excitation Point
E = itaCoordinates(2);
E.x = [lxs/4 2*lxs/5];
E.y = [lys/3 lys/2];
E.z = zeros(1,2);

figure(h); hold on
E.scatter('filled')

%% Material Properties
EX    = .7e11 ;
PRXY  = .346 ;
DMPR  = 2e2 ;
RHO   = 2710 ;

%% Calculate Ys
for idx = 1:3
    for jdx = 1:3
        Ys_cell{idx,jdx} = ita_tps_mobility_plate(Geoms,P.n(jdx),P.n(idx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end

Ys = [Ys_cell{1,1} Ys_cell{1,2} Ys_cell{1,3} ; Ys_cell{2,1} Ys_cell{2,2} Ys_cell{2,3} ; Ys_cell{3,1} Ys_cell{3,2} Ys_cell{3,3}];

%% Calculate iif - internal transfer path
for idx = 1:2
    for jdx = 1:3
        
        iif_cell{idx,jdx} = ita_tps_mobility_plate(Geoms,E.n(idx),P.n(jdx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end
iif = [iif_cell{1,1} iif_cell{2,1}; iif_cell{1,2} iif_cell{2,2}; iif_cell{3,1} iif_cell{3,2}];

%% %% %% Receiver %% %% %%
%% %% Plate Geometry
lxr = .7 ; %dimension in x direction
lyr = .8 ; %dimension in y direction
tr  = 2e-3; % thickness
DMPR  = 2 ;


Geomr = itaCoordinates([lxr lyr tr]); %create itaCoordinates

%% Response Points
%Must be the same points
P.scatter
view(0,90)
ylim([0 , lyr])
xlim([0 , lxr])

%% Transfer Point
T = itaCoordinates([lxr/2 lyr/3 0]);
T.scatter
view(0,90)
ylim([0 , lyr])
xlim([0 , lxr])

%% Calculate Yr
for idx = 1:3
    for jdx = 1:3
        Yr_cell{idx,jdx} = ita_tps_mobility_plate(Geomr,P.n(jdx),P.n(idx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end

Yr = [Yr_cell{1,1} Yr_cell{1,2} Yr_cell{1,3} ; Yr_cell{2,1} Yr_cell{2,2} Yr_cell{2,3} ; Yr_cell{3,1} Yr_cell{3,2} Yr_cell{3,3}];

Ns = 2; %number of sources
N = 3; % number of independent internal source signals
%% Calculate Hr - final transfer path
for idx = 1:3
    Hr_cell{idx} = ita_tps_mobility_plate(Geomr,P.n(idx),T.n,EX,PRXY,RHO,DMPR,'f_max',fmax);
end
Hr = [Hr_cell{1} , Hr_cell{2}, Hr_cell{3}];

%% ita_AudioAnalyticRationalMatrix2itaAudioMatrix
Yr = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Yr,'fftDegree',fftDegree,'samplingRate',sr);
Ys = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys,'fftDegree',fftDegree,'samplingRate',sr);
Hr = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Hr,'fftDegree',fftDegree,'samplingRate',sr);
iif = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(iif,'fftDegree',fftDegree,'samplingRate',sr);

%% Only the most wanted coordinates! 1f+2m
o=3:6:18;
o=sort([o o+1 o+2]);
o2 = repmat([3 4 5],1,3);
Yr = Yr(o,o);
Ys = Ys(o,o);
Hr = Hr([3 4 5],o);
iif = iif(o,[3 4 5]);

%% Signals

for idx = 1:3
    for jdx = 1:2
        S(idx,jdx) = ita_generate('noise',1,iif(1,1).samplingRate,fftDegree);
    end
end

%% Blocked Force - with internal transfer path
Fb = iif*S;

%% TPS
yrysinv = pinv(Yr+Ys);
Fc = yrysinv*Ys*Fb;
vc = Yr*Fc;
Yc = Yr*yrysinv*Ys;

%% Multiply the Transferpath up to the receiving point - here it is velocity on the plate
v_receiver = Hr * Fc;

%% otpa

RHotpa = ita_otpa(v_receiver.merge,vc.merge,'blocksize',4096,'overlap',0.5,'tol',10^10*eps);
RHotpa_theory = Hr * pinv(Yr);

RHr_otpa = RHotpa*Yr; % is it the same as Hr??
RHc_otpa = RHotpa*Yc; % is it the same as Hc??

%% Comparing Results

RHotpa.merge.plot_spk
title('Hotpa')
RHotpa_theory.merge.plot_spk
title('Hotpa_theory')
RHr_otpa.merge.plot_spk
title('Hr_otpa_')
RHc_otpa.merge.plot_spk
title('Hc_otpa')

%% Plots
return
Ys.merge.plot_spk
Yr.merge.plot_spk
iif.merge.plot_spk
Fb.merge.plot_spk





