%% itaHRTF

% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

ccx
ccx
ccx
%%
dataP = 'C:\Users\bomhardt\Documents\MATLAB\ITA-Toolbox\applications\TODOunfinished\test_marcia\DATA\HRTF_individ\HRTF__Ramona_foam_20140116_15_56h';
dataP = 'C:\Users\bomhardt\Documents\MATLAB\ITA-Toolbox\applications\TODOunfinished\test_marcia\DATA\HRTF_individ\HRTF_Frank_20140120_12_35h';
%dataP = 'C:\Users\bomhardt\Documents\MATLAB\ITA-Toolbox\applications\TODOunfinished\test_marcia\DATA\HRTF_individ\KK_20140116_21_38h';

dataM = 'C:\Users\bomhardt\Documents\MATLAB\ITA-Toolbox\applications\TODOunfinished\test_marcia\DATA\HRTF_individ\ref_KE3LR_foam_20140116_13_40h';
%dataM = 'C:\Users\bomhardt\Documents\MATLAB\ITA-Toolbox\applications\TODOunfinished\test_marcia\DATA\HRTF_individ\ref_KK_20140117_09_52h';
uiopen('C:\Users\bomhardt\Documents\MATLAB\ITA-Toolbox\pinkNoise.ita',1)

HRTF_Tmp = test_rbo_postprocessing_HRTF_arc_CropDiv('dataPath',dataP,...
    'path_micLeft',dataM,'path_micRight',dataM,'TF_type','HRTF');

HRTF = itaHRTF(HRTF_Tmp,'HRTF');
ita_write(HRTF,'dummyBogen.ita')
%%
ccx
ccx
ccx

HRTF = ita_read('testHRTF.ita');

%% itaAnthroHRTF

an0 = itaAnthroHRTF('head',[0.07, 0.08, 0.09]);
an0.calcEllipsoid = true;
an0.plot_freqSlice

an0 = itaAnthroHRTF(HRTF,'head',[0.07, 0.08, 0.09]);
an0.plot_ITD

%% itaAnthroHRTF & itaHRTF
HRTFring = HRTF.sphericalSlice('theta_deg',90);
w = 0.05:0.005:0.06;
t0anL = zeros(HRTFring.nDirections,numel(w));
t0anR = t0anL;

for iW = 1:numel(w)
    an0 = itaAnthroHRTF(HRTFring,'h', 0.1,'w',w(iW),'d',0.1);
    an0.calcEllipsoid = true;
    an0S = ita_time_shift(an0);
    t0anL(:,iW) = an0S.meanTimeDelay('L');
    t0anR(:,iW) = an0S.meanTimeDelay('R');
end

HRTFringS = ita_time_shift(HRTFring);
t0measL = HRTFringS.meanTimeDelay('L');
t0measR = HRTFringS.meanTimeDelay('R');

t180 = t0measL(HRTFring.dirCoord.phi_deg ==180)- t0measR(HRTFring.dirCoord.phi_deg ==180);
str = ['meas' repmat(' ',1,size(num2str(w'),2)-numel('meas'))];

phi = an0.dirCoord.phi_deg;

phiInterp = phi(1):359;
ITD_meas = t0measL-t0measR;
tMax= interp1(phi,ITD_meas,phiInterp);

idx75 = find(phiInterp==75);
idx105 = find(phiInterp==105);
idx255 = find(phiInterp==255);
idx285 = find(phiInterp==275);

[~,idxMax]  = max(tMax(idx75:idx105));
[~, idxMin] = min(tMax(idx255:idx285));
[~, idx0] = min(tMax(1:idx75));

phiShiftMax = phiInterp(idxMax+75)-90;
phiShiftMin = phiInterp(idxMin+255)-270;
phiShift0 = phiInterp(idx0);

phiInterp = [phiInterp(idx0:end) phiInterp(1:idx0-1)];
if idx0~=1
tMax = [tMax(idx0:end) tMax(1:idx0-1)];
end

figure
plot(phi,t0anL-t0anR,phi(1):359,tMax,'--');
ylim([-1e-3 1e-3])
xlim([min(phi) 360])
grid on

legend([num2str(w'); str]);
% test_rbo_HRTF_correlation(HRTFring,an0);

%%
an1 = itaAnthroHRTF(HRTF,'h', 0.07,'w',0.08,'d',0.09);
an2 = itaAnthroHRTF(HRTF,'h', 0.07,'w',0.07,'d',0.09);

an.direction(10).pf
an1.pressureEllipsoid;
an2.pressureEllipsoid;

anthroDiff = ita_divide_spk(anthro1,anthro2);
anthroDiff.plot_ITD
%an.plot_ITD
%%
