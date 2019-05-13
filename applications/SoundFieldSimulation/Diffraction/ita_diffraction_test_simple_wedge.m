%% init
%params
c = 344;
fs = 44100;
fftDegree = 12;

% wedges
n1 = [ 1, 1, 0];
n2 = [-1, 1, 0];
apexStart = [0, 1, -4];
apexEnd   = [0, 1,  4];
apexLen = norm(apexEnd -apexStart);
apexDir = (apexEnd -apexStart) / apexLen;

infScreen = itaSemiInfinitePlane(n1, apexStart, apexDir);
infWedge = itaInfiniteWedge(n1, n2, apexStart);
finWedge = itaFiniteWedge(n1, n2, apexStart, apexLen);

% interaction points
src = [-3, 0, 0];
rcv = [ 3, 0, 0];

% result variables
diffr_tf = itaAudio();
diffr_tf.fftDegree = fftDegree;
diffr_tf.samplingRate = fs;
diffr_tf_maekawa = diffr_tf;
diffr_tf_maekawa.channelNames = {'maekawa'};
diffr_tf_utd = diffr_tf;
diffr_tf_utd.channelNames = {'utd'};
diffr_tf_btms = diffr_tf;
diffr_tf_btms.channelNames = {'btms'};

%% diffraction
diffr_tf_maekawa.freqData = ita_diffraction_maekawa(infScreen, src, rcv, diffr_tf_maekawa.freqVector, c);
diffr_tf_utd.freqData = ita_diffraction_utd(infWedge, src, rcv, diffr_tf_maekawa.freqVector, c);
diffr_tf_btms.timeData = ita_diffraction_btms(finWedge, src, rcv, fs, diffr_tf_maekawa.nSamples, c);

diffr_tf = ita_merge(diffr_tf_maekawa, diffr_tf_utd, diffr_tf_btms);
diffr_tf_norm = ita_normalize_spk(diffr_tf, 'allchannels');
diffr_tf_norm.channelNames = [{'normalized maekawa'}; {'normalized utd'}; {'normalized btms'}];

diffr_tf = ita_merge(diffr_tf, diffr_tf_norm);

%% plot
diffr_tf.pf;
title('diffraction filters at simple rectangular wedge');
ylim auto
