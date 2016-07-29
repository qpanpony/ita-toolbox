

% <ITA-Toolbox>
% This file is part of the application SphericalHarmonics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

dbstop if error

as = itaAudioSph;
nmax = 4;
as.fftDegree = 5;
as.s = ita_sph_sampling_gaussian(nmax);
as.time = zeros(2^as.fftDegree,as.s.nPoints);

nSamples = size(as.s.Y,1);
as.freq = 1./sqrt(4*pi) .* ones(size(as.freq));
as.freq(1,:) = 0 .*as.freq(1,:);

as = as';

%% 

eps = 10^(-14);
eps = 10^(-10);

%%
tic
asSH = as.sht;
asRe = asSH.isht;
all(max(abs(as.data(:) - asRe.data(:))) < eps)
toc

%%

tic
asMP = asSH.apply_iHankel;
asSHRe = asMP.applyHankel;
all(max(abs(asSH.data(:) - asSHRe.data(:))) < eps)
toc

%%

tic
asMP = as.mpt;
asRe = asMP.impt;
all(max(abs(as.data(:) - asRe.data(:))) < eps)
toc

%%
as.s.r(1) = 2.*as.s.r(1);
%%
tic
asMP = as.mpt;
asRe = asMP.impt;
all(max(abs(as.data(:) - asRe.data(:))) < eps)
toc

%%
figure; surf(as, as.freq2value(1000));
figure; surf(asSH, asSH.freq2value(1000));
figure; surf(asSH, asSH.spatialSampling.Y * asSH.freq2value(1000).')