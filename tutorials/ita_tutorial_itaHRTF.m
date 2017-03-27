% <ITA-Toolbox>
% This file is part of the application HRTF_class for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%% Init object
coord   =  ita_sph_sampling_equiangular(11,36);
coord.r = 0.1;
pSphere = test_rbo_pressureSphere('sph',coord,'fftDeg',8);

HRTF_sphere    = ita_time_shift(itaHRTF(pSphere),pSphere.trackLength/2,'time');

%% Find Functions 
coordF          = itaCoordinates([1 pi/2 pi/2; 1 pi/2 pi/4],'sph');

HRTF_find       = HRTF_sphere.findnearestHRTF(coordF); % findet das Objekt zu den gegebenen Koordinaten
HRTF_dir        = HRTF_sphere.direction([11 15 17]); % wie itaAudio.ch(x) nur für itaHRTF

% Slice of the TF function
slicePhi        = HRTF_sphere.sphericalSlice('theta_deg',90);
sliceTheta      = HRTF_sphere.sphericalSlice('phi_deg',0);

%% Plot Functions 
% plot frequency domain in dependence of the angle (elevation or azimuth)
sliceTheta.plot_freqSlice
pause(5)
close gcf
slicePhi.plot_freqSlice('earSide','R')
pause(5)
close gcf

% plot ITD
slicePhi.plot_ITD('method','xcorr','plot_type','line')

% plot time or freq. domain
HRTF_find.pt
HRTF_find.pf
HRTF_find.getEar('R').pf
%% Play gui
pinkNoise = ita_generate('pinknoise',1,44100,12)*10;
HRTF_find.play_gui(pinkNoise); 

%% Binaural parameters
ITD = slicePhi.ITD;  % different methods are available: see method in itaHRTF
%ILD = slicePhi.ILD;
 
%% Modifications
% calculate DTF
DTF_sphere = HRTF_sphere.calcDTF;

HRTFvsDTF = ita_merge(DTF_sphere.findnearestHRTF(90,90),HRTF_sphere.findnearestHRTF(90,90));
HRTFvsDTF.pf
legend('DTF left','DTF right','HRTF left','HRTF right')

% interpolate HRTF
phiI     = deg2rad(0:5:355);
thetaI   = deg2rad(15:15:90);
[THETA_I, PHI_I] = meshgrid(thetaI,phiI);
rI       = ones(numel(PHI_I),1);
coordI   = itaCoordinates([rI THETA_I(:) PHI_I(:)],'sph'); % itaCoordinates object

HRTF_interp = HRTF_sphere.interp(coordI);


%% Write and init
nameDaff_file = 'HRTF_sphere.daff';
HRTF_sphere.writeDAFFFile(nameDaff_file);

%HRTF_daff = itaHRTF('daff',nameDaff_file);

nameDaff_file2 = 'yourHRTF.daff';
if ~strcmp(nameDaff_file2,'yourHRTF.daff')
    HRTF_daff2 = itaHRTF('daff',nameDaff_file2);
    HRTF_daff2.plot_freqSlice
else
   ita_disp('use an existing daff-file') 
end