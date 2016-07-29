%% ***********************************************************************
% ************************************************************************
% ************************* plots , additional script ********************
% ************************************************************************
% ************************************************************************
%
% Author Pascal Dietrich 2011 - pdi@akustik.rwth-aachen.de
% For BOSCH Report
%   --- CONFIDENTIAL ---
%
% ************************************************************************
% ************************************************************************
% ************************************************************************
% ************************************************************************

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Yc test
Yr_in_raw = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Yr_backup,   'fftDegree',fftDegree,'samplingRate',sr);
Ys_in_raw = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys_backup,   'fftDegree',fftDegree,'samplingRate',sr);
Yr_in_raw(1,1).comment = 'Yr';
Ys_in_raw(1,1).comment = 'Ys';
ita_disp('conversion done.')
ext = '';
ylimits = [-60 -30];

%% all DOF
close all
comment  = 'All DOFs';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = Yr_in_raw;
Ys2 = Ys_in_raw;
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
count = 0;
clear aux
for idx = 1:3:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end

Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

%cond number
cYr2 = ita_tpa_plot_matrix_condition_number(Yr2);
cYr2.channelNames = {'Yr'};

cYs2 = ita_tpa_plot_matrix_condition_number(Ys2);
cYs2.channelNames = {'Ys'};

cYc2 = ita_tpa_plot_matrix_condition_number(Yc);
cYc2.channelNames = {'Yc'};

ita_plot_spk(merge(cYs2, cYr2, cYc2),'nodb')

%% all DOF - no foot coupling Yr Ys
close all
comment  = 'All DOFs -- No Coupling Between Feet (Yr, Ys)';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = diag(Yr_in_raw,[],3);
Ys2 = diag(Ys_in_raw,[],3);
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
count = 0;
clear aux
for idx = 1:3:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end

Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

% all DOF - no foot coupling Yr
close all
comment  = 'All DOFs -- No Coupling Between Feet (Yr)';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = diag(Yr_in_raw,[],3);
Ys2 = Ys_in_raw;
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
count = 0;
clear aux
for idx = 1:3:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end

Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

% all DOF - no foot coupling Ys
close all
comment  = 'All DOFs -- No Coupling Between Feet (Ys)';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = Yr_in_raw;
Ys2 = diag(Ys_in_raw,[],3);
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
count = 0;
clear aux
for idx = 1:3:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end

Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

% all DOF - no foot coupling - no DOF coupling
close all
comment  = 'All DOFs -- No Coupling Between DOF';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = diag(Yr_in_raw,3);
Ys2 = diag(Ys_in_raw,3);
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
count = 0;
clear aux
for idx = 1:3:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end
Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

% all DOF - no foot coupling - no DOF coupling
close all
comment  = 'All DOFs -- No Coupling Between Feet (Yr, Ys) and Between DOF';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = diag(Yr_in_raw);
Ys2 = diag(Ys_in_raw);
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
count = 0;
clear aux
for idx = 1:3:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end
Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

%% normal direction only - Should be the same as "all DOF - no foot coupling - no DOF coupling"
close all
comment  = 'Normal Direction Only';
filename = comment(isstrprop(comment,'alpha'));
Yr2 = diag(Yr_in_raw(1:3:end,1:3:end));
Ys2 = diag(Ys_in_raw(1:3:end,1:3:end));
Yc = Yr2*pinv(Yr2 + Ys2)*Ys2;
Yc(1,1).comment = 'Yc';
ita_tpa_plot_matrix({Ys2, Yr2,Yc},'freqVector',200,'filename',filename,'ticksF',{'FZ'} ,'ticksV',{'UZ'} )
count = 0;
clear aux
for idx = 1:1:size(Yc,1)
    count = count + 1;
    aux(count) = Yc(idx,idx);
end
Yc_noFoot_selected = aux.merge;
Yc_noFoot_selected.plot_spkphase('ylim',ylimits);
title(comment)
ita_savethisplot_gle('filename',[filename ext]);

%% Ys invert due to ts
fmax = 2000;
sr   = 5000;
close all
clc
ts = 5e-3;
Geoms = itaCoordinates([lxs lys ts]); %create itaCoordinates / dimensions
Ys = repmat(itaAudioAnalyticRational,coordFeet.nPoints*DOF,coordFeet.nPoints*DOF);
for idx = 1:coordFeet.nPoints
    for jdx = 1:coordFeet.nPoints
        Ys((idx-1)*DOF+(1:DOF),(jdx-1)*DOF+(1:DOF)) = ita_tps_mobility_plate(Geoms,coordFeet.n(jdx),coordFeet.n(idx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end
nModes = numel(Ys(1,1).analyticData.f);
Ys(1,1) = 'Ys';
Ys      = Ys(idxF,idxF);
Ys      = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys,   'fftDegree',fftDegree,'samplingRate',sr);
Ys.merge.plot_spkphase('ylim',[-40 70])


fileStr = num2str(ts);
fileStr = fileStr(isstrprop(fileStr,'alphanum'));

titleStr = ['ts: ' num2str(ts) ' - ' num2str(nModes) ' Modes'];
title(titleStr)
ita_savethisplot_gle('filename',['YSts' fileStr ])

ita_tpa_plot_matrix({Ys},'freqVector',200,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
ita_plottools_aspectratio(1)
ita_savethisplot('matrix_0005.png')


ita_tpa_plot_matrix_condition_number(Ys);
title(titleStr)
ita_savethisplot_gle('filename',['condNumberts' fileStr ])

% % ita_tpa_plot_matrix({Ys},0,'freqVector',200,'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'} )
% % ita_plottools_aspectratio(1)
% % print('-dpng','-r300',['matrix_' num2str(ts) '.png'])



close all
clc
ts = 1e-3;
Geoms = itaCoordinates([lxs lys ts]); %create itaCoordinates / dimensions
Ys = repmat(itaAudioAnalyticRational,coordFeet.nPoints*DOF,coordFeet.nPoints*DOF);
for idx = 1:coordFeet.nPoints
    for jdx = 1:coordFeet.nPoints
        Ys((idx-1)*DOF+(1:DOF),(jdx-1)*DOF+(1:DOF)) = ita_tps_mobility_plate(Geoms,coordFeet.n(jdx),coordFeet.n(idx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end
nModes = numel(Ys(1,1).analyticData.f);
Ys(1,1) = 'Ys';
Ys      = Ys(idxF,idxF);
Ys      = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys,   'fftDegree',fftDegree,'samplingRate',sr);
Ys.merge.plot_spkphase('ylim',[-40 70])


fileStr = num2str(ts);
fileStr = fileStr(isstrprop(fileStr,'alphanum'));

titleStr = ['ts: ' num2str(ts) ' - ' num2str(nModes) ' Modes'];
title(titleStr)
ita_savethisplot_gle('filename',['YSts' fileStr ])

ita_tpa_plot_matrix_condition_number(Ys);
title(titleStr)
ita_savethisplot_gle('filename',['condNumberts' fileStr ])



close all
clc
ts = 0.1e-3;
Geoms = itaCoordinates([lxs lys ts]); %create itaCoordinates / dimensions
Ys = repmat(itaAudioAnalyticRational,coordFeet.nPoints*DOF,coordFeet.nPoints*DOF);
for idx = 1:coordFeet.nPoints
    for jdx = 1:coordFeet.nPoints
        Ys((idx-1)*DOF+(1:DOF),(jdx-1)*DOF+(1:DOF)) = ita_tps_mobility_plate(Geoms,coordFeet.n(jdx),coordFeet.n(idx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end
nModes = numel(Ys(1,1).analyticData.f);
Ys(1,1) = 'Ys';
Ys      = Ys(idxF,idxF);
Ys      = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys,   'fftDegree',fftDegree,'samplingRate',sr);
Ys.merge.plot_spkphase('ylim',[-40 70])


fileStr = num2str(ts);
fileStr = fileStr(isstrprop(fileStr,'alphanum'));

titleStr = ['ts: ' num2str(ts) ' - ' num2str(nModes) ' Modes'];
title(titleStr)
ita_savethisplot_gle('filename',['YSts' fileStr ])

ita_tpa_plot_matrix_condition_number(Ys);
title(titleStr)
ita_savethisplot_gle('filename',['condNumberts' fileStr ])


%% condition number and damping
% close all
clc
sr = 5000; 
fmax = 2000;
ts = 0.1e-3;
DMPR = 10;
% DMPR  = 1e2;   %damping

Geoms = itaCoordinates([lxs lys ts]); %create itaCoordinates / dimensions
Ys = repmat(itaAudioAnalyticRational,coordFeet.nPoints*DOF,coordFeet.nPoints*DOF);
for idx = 1:coordFeet.nPoints
    for jdx = 1:coordFeet.nPoints
        Ys((idx-1)*DOF+(1:DOF),(jdx-1)*DOF+(1:DOF)) = ita_tps_mobility_plate(Geoms,coordFeet.n(jdx),coordFeet.n(idx),EX,PRXY,RHO,DMPR,'f_max',fmax);
    end
end

eigenFreq = Ys(1,1).analyticData.f;

nModes = numel(Ys(1,1).analyticData.f);
Ys(1,1) = 'Ys';
Ys      = Ys(idxF,idxF);
Ys      = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys,   'fftDegree',fftDegree,'samplingRate',sr);
% Ys.merge.plot_spkphase('ylim',[-40 70])

titleStr = ['ts: ' num2str(ts) ' - damping: ' num2str(DMPR) ' - ' num2str(nModes) ' Modes'];

fileStr = [num2str(ts) '_' num2str(DMPR) ];
fileStr = fileStr(isstrprop(fileStr,'alphanum'));

ita_tpa_plot_matrix_condition_number(Ys,eigenFreq);
title(titleStr)
legend off
ylim([0 5e5])

ita_savethisplot_gle('filename',['condNumbertDamping' fileStr ])


%% ***********************
%% *************** PLATE-BEAM ******************************************
% % ccx
% This link has to be adapted!
% % load('F:\pdi_daten\MATLAB\BoschReport\ANSYS_plate_beam\workspace_data.mat')

% unitsit
mulfac  = 3;
v_units = [repmat(itaValue(1,'m/s'),1,mulfac) repmat(itaValue(1,'1/s'),1,mulfac)];
F_units = [repmat(itaValue(1,'N'),1,mulfac)   repmat(itaValue(1,'N m'),1,mulfac)];
units   = repmat(itaValue,2*mulfac,2*mulfac); % just init

for idx = 1:numel(v_units)
    for jdx = 1:numel(F_units)
        aux = itaValue(v_units(idx)) / itaValue(F_units(jdx));
        units(jdx,idx) = aux;
    end
end
units = repmat(units,3,3)

%% get velocity
DOF = 6;
for idx = 1:DOF*3
    for jdx = 1:DOF*3
        Placa (idx,jdx)        = ita_differentiate( Placa (idx,jdx));
        Placa (idx,jdx).channelUnits = units(idx,jdx);
        PlacaViga (idx,jdx)    = ita_differentiate( PlacaViga (idx,jdx));
        PlacaViga (idx,jdx).channelUnits = units(idx,jdx);
        VigaMobility (idx,jdx) = ita_differentiate( VigaMobility (idx,jdx));
        VigaMobility (idx,jdx).channelUnits = units(idx,jdx);
    end
end

%% select DOF
selectDOF = 1:6;
% selectDOF = [3 4 5];
idxF = ita_tpa_DOF2index(selectDOF,3,DOF);
idxR = ita_tpa_DOF2index(selectDOF,3,DOF);
Ys = VigaMobility(idxF,idxR);
Yr = Placa(idxF,idxR);
Yc = PlacaViga(idxF,idxR);
Yc_sim = Yr*pinv(Yr + Ys,1e-5)*Ys;
% Yc2_sim = Yr2*pinv(Yr2 + Ys2)*Ys2;

%% naming
% Yc = Yc(idxF, idxR);
Yc(1,1).comment = 'Yc ANSYS';
% Yc_sim = Yc_sim(idxF, idxR);
Yc_sim(1,1).comment = 'Yc calculated';

%% save
save(['admittance_data_plate_beam_' num2str(numel(selectDOF)) 'DOF.mat'],'Yr','Ys','Yc','Yc_sim')

%%
if numel(selectDOF,3)
    ita_tpa_plot_matrix({Ys, Yr, Yc, Yc_sim},'filename',['ansys_numerik_' num2str(numel(selectDOF)) 'DOF'],'ticksF',{'FZ','MX','MY'} ,'ticksV',{'UZ','RX','RY'},'freqVector',350)
else
    ita_tpa_plot_matrix({Ys, Yr, Yc, Yc_sim},'filename',['ansys_numerik_' num2str(numel(selectDOF)) 'DOF'],'freqVector',350)
end

%% windowing
Ys_win = ita_matrixfun(@ita_time_window,Ys,[0.4 0.6],'time','symmetric');
Yr_win = ita_matrixfun(@ita_time_window,Yr,[0.4 0.6],'time','symmetric');

Yc_sim_win = Yr_win*pinv(Yr_win + Ys_win,1e-5)*Ys_win;

%%
ita_tpa_plot_matrix_condition_number(Yc)
legend off
ylim([0 4e8])
ita_savethisplot_gle('ansys_condnumber_yc')

%%
ita_tpa_plot_matrix_condition_number(Ys)
legend off
ylimits = ylim;
ylim([0 1e11])
ita_savethisplot_gle('ansys_condnumber_ys')

%%
ita_tpa_plot_matrix_condition_number(Yr)
legend off
ylimits = ylim;
ylim([0 4e10])
ita_savethisplot_gle('ansys_condnumber_yr')

%%
count = 0
clear aux
for idx = 1:3:size(Ys,1)
    count = count + 1;
    aux(count) = Yc_sim(idx,idx);
end
aux.merge.plot_spkphase();

%% Ys fit
for idx = 1:size(Ys,1)
    for jdx = 1:size(Ys,2)
        Ys_fit(idx,jdx) = ita_audio2zpk_rationalfit((Ys(idx,jdx)),'degree',15,'freqRange',[100 2000],'tendstozero',false);
    end
end
Ys2 = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Ys_fit,   'fftDegree',Ys(1,1).nSamples,'samplingRate',4000);

%%
for idx = 1:size(Ys,1)
    for jdx = 1:size(Ys,2)
        Ys(idx,jdx).signalType = 'energy';
        Ys_fit(idx,jdx).fftDegree = 16;
        Yr_fit(idx,jdx).fftDegree = 16;
        
        Ys_fit(idx,jdx).samplingRate = Ys(1,1).samplingRate;
        Yr_fit(idx,jdx).samplingRate = Ys(1,1).samplingRate;
        
    end
end

%%
for idx = 1:size(Ys,1)
    disp([num2str(idx)  ' of ' num2str(size(Ys,1))])
    for jdx = 1:size(Ys,2)
        Yr_fit(idx,jdx) = ita_audio2zpk_rationalfit((Yr(idx,jdx)),'degree',[200],'freqRange',[20 2000],'tendstozero',false);
    end
end
Yr2 = ita_AudioAnalyticRationalMatrix2itaAudioMatrix(Yr_fit,   'fftDegree',Ys(1,1).nSamples,'samplingRate',4000);

%% transpose?
Yr_trans = ita_tpa_matrix_transpose(Yr);
test = Yr.merge/Yr_trans.merge

%%
data = Yr
ita_plot_spkphase(merge(data(1,1),data(4,4), data(7,7)))
legend off
ylim([-80 20])
ita_savethisplot_gle('ansys_spkphase_Yr')

%%
data = Yr_fit;
ita_plot_spkphase(merge(data(1,1)',data(4,4)', data(7,7)'))
legend off
ylim([-80 20])
ita_savethisplot_gle('ansys_spkphase_Yr_fit')

%%
Yr_fit2 = Yr_fit';
Ys_fit2 = Ys_fit';
Yc_fit  = Yr_fit2 * pinv( Yr_fit2 + Ys_fit2) * Ys_fit2;








