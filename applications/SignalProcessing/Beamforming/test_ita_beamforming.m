function test_ita_beamforming()

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%
%
%

%% test for the external mex file
if exist(['ita_beam_manifoldVectorMex.' mexext],'file') ~= 3
    comeFrom = pwd;
    cd([fileparts(which(mfilename)) filesep]);
    mex ita_beam_manifoldVectorMex.cpp;
    cd(comeFrom);
end

%% test array function
array = ita_beam_makeArray('spiral','N',36,'d',0.11);
array = ita_beam_makeArray(array,'weightType','taylor');

%% test the parameter computation
f = ita_ANSI_center_frequencies([200,5000],1);
params = ita_beam_computeParameters(array,f);
ita_plot_freq(params,'ylim',[-50 60]);

%% test the actual beamforming
plotFreq = 2000;
source = itaMicArray([-1 0.5 -10; 2 0.5 -10],'cart');
source.w(:) = [1; 1]; % linear sound pressure
[B1,p1] = ita_beam_simulate(array,'source',source,'type',3,'wavetype',1);
B2 = ita_beam_beamforming(array,p1,B1.channelCoordinates,'type',2,'wavetype',1);
figure;
subplot(1,2,1);
ita_plot_2D(B1,plotFreq,'newFigure',false);
subplot(1,2,2);
ita_plot_2D(B2,plotFreq,'newFigure',false);

%% line plot
goalIndex = find(abs(B1.channelCoordinates.y - 0.5) == min(abs(B1.channelCoordinates.y - 0.5)));
tmp = B1.freq2value(plotFreq);
tmp = tmp(goalIndex);
tmp = tmp./max(abs(tmp));
tmp2 = B2.freq2value(plotFreq);
tmp2 = tmp2(goalIndex);
tmp2 = tmp2./max(abs(tmp2));
figure;
plot(B1.channelCoordinates.x(goalIndex),20.*log10(abs(tmp)));
hold all
plot(B2.channelCoordinates.x(goalIndex),20.*log10(abs(tmp2)));

%% also for strange scanning grids
f = (100:100:5000).';
p = itaResult(5.*randn(numel(f),36),f,'freq');
p.userData = {'nodeN',array.ID};
mesh = array;
mesh.z = 5;
B = ita_beam_beamforming(array,p,mesh,'type',2);
ita_plot_freq(mean(B));

%%
close all;
