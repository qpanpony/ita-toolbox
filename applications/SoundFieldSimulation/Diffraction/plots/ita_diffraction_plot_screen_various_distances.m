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
src = [
       %-0.1, 0, 0; ...
       -1.0, 0, 0; ...
       %-10 , 0, 0; ...
       %-100, 0, 0;
       ];
rcv = [
       % 0.1, 0, 0; ...
        1.0, 0, 0; ...
        10 , 0, 0; ...
        100, 0, 0;
        ];

% result variables
diffr_tf = itaAudio();
diffr_tf.fftDegree = fftDegree;
diffr_tf.samplingRate = fs;
diffr_temp = diffr_tf;


%% diffraction
% maekawa diffraction
for i = 1:size(src, 1)
    for j = 1:size(rcv, 1)
        diffr_temp.freqData = ita_diffraction_maekawa(infScreen, src(i, :), rcv(j, :), diffr_tf.freqVector, c);
        diffr_temp.channelNames = {['maekawa: S pos ', num2str(i), ', R pos ', num2str(j)]};
        if i == 1 && j == 1
            diffr_tf_maekawa = diffr_temp;
        else
            diffr_tf_maekawa = ita_merge(diffr_tf_maekawa, diffr_temp);
        end
    end
end

% utd
for i = 1:size(src, 1)
    for j = 1:size(rcv, 1)
        diffr_temp.freqData = ita_diffraction_utd(infScreen, src(i, :), rcv(j, :), diffr_tf.freqVector, c);
        diffr_temp.channelNames = {['utd: S pos ', num2str(i), ', R pos ', num2str(j)]};
        if i == 1 && j == 1
            diffr_tf_utd = diffr_temp;
        else
            diffr_tf_utd = ita_merge(diffr_tf_utd, diffr_temp);
        end
    end
end

% btms diffraction
for i = 1:size(src, 1)
    for j = 1:size(rcv, 1)
        diffr_temp.timeData = ita_diffraction_btms(finScreen, src(i, :), rcv(j, :), fs, diffr_tf.nSamples, c);
        diffr_temp.channelNames = {['btms: S pos ', num2str(i), ', R pos ', num2str(j)]};
        if i == 1 && j == 1
            diffr_tf_btms = diffr_temp;
        else
            diffr_tf_btms = ita_merge(diffr_tf_btms, diffr_temp);
        end
    end
end

diffr_tf = ita_merge(diffr_tf_maekawa, diffr_tf_utd, diffr_tf_btms);
diffr_tf_norm = ita_normalize_spk(diffr_tf, 'allchannels');

% naming normalized channels
for k = 1 : numel(diffr_tf_norm.channelNames)
    diffr_tf_norm.channelNames{k} = ['normalized ', diffr_tf_norm.channelNames{k}];
end

% diffr_tf = ita_merge(diffr_tf, diffr_tf_norm);

%% plot
diffr_tf_norm.pf;
title('diffraction filters at simple screen with various distances');
ylim auto