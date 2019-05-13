%% init
%params
c = 344;
fs = 44100;
fftDegree = 12;

% wedges
n1 = [ 1, 0, 0];
n2 = [-1, 0, 0];
apexStart = [0, 1, -4];
apexEnd   = [0, 1,  4];
apexLen = norm(apexEnd -apexStart);
apexDir = (apexEnd -apexStart) / apexLen;

infScreen = itaSemiInfinitePlane(n1, apexStart, apexDir);
finScreen = itaFiniteWedge(n1, n2, apexStart, apexLen);
finScreen.aperture_direction = apexDir;
finScreen.aperture_end_point = apexEnd;

% interaction points
src = [-3, 0, 0];
rcv = [ 3, 0, 0];

% result variables
diffr_tf = itaAudio();
diffr_tf.fftDegree = fftDegree;
diffr_tf.samplingRate = fs;
diffr_tf_maekawa = diffr_tf;
diffr_tf_utd = diffr_tf;
diffr_tf_btms = diffr_tf;

%% diffraction
diffr_tf_maekawa.freqData = ita_diffraction_maekawa(infScreen, src, rcv, diffr_tf_maekawa.freqVector, c);
diffr_tf_utd.freqData = ita_diffraction_utd(infScreen, src, rcv, diffr_tf_maekawa.freqVector, c);
diffr_tf_btms.timeData = ita_diffraction_btms(finScreen, src, rcv, fs, diffr_tf_maekawa.nSamples, c);

diffr_tf = ita_merge(diffr_tf_maekawa, diffr_tf_utd, diffr_tf_btms);
diffr_tf_norm = ita_normalize_spk(diffr_tf, 'allchannels');

%% plot
diffr_tf.pf;
title('diffraction filters unnormalized');
legend('maekawa', 'utd', 'btms');

diffr_tf_norm.pf;
title('diffraction filters normalized');
legend('maekawa', 'utd', 'btms');