%% Scene
n1  = [-1, 1, 0];
n2  = [ 1, 1, 0];
loc = [ 0, 4, 0];
dir = [ 0, 1, 0];
screenNormal = [-1, 0, 0];
screen = itaSemiInfinitePlane(screenNormal, loc, dir);
rectWedge = itaInfiniteWedge(n1, n2, loc);

S0 = [-10, 0,  2]; 
S1 = [-10, 0, -2]; % image source specular reflected source on ground
S2 = [-20, 0,  0];
R  = [ 10, 0,  2];

diffrResult = itaAudio();
diffrResult.samplingRate = 44100;
diffrResult.fftDegree = 12;

path0 = itaAudio();
path0.samplingRate = 44100;
path0.fftDegree = 12;

path1 = itaAudio();
path1.samplingRate = 44100;
path1.fftDegree = 12;

freq = diffrResult.freqVector;
c = 344; % speed of sound

%% Diffraction simulation UTD
[tf_path0, D1, A1] = ita_diffraction_utd(screen, S0, R, freq, c);
[tf_path1, D2, A2] = ita_diffraction_utd(screen, S1, R, freq, c);

total_tf = tf_path0 + tf_path1;

path0.freqData = tf_path0;
path1.freqData = tf_path1;
diffrResult.freqData = total_tf;

% % %% Diffraction simulation BTMS
% % [tf_btms_path0, offs0] = ita_diffraction_btms(screen, S0, R, fs, 2049, c);

