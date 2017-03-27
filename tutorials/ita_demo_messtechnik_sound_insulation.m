%% Akustische Messtechnik lecture sound insulation demo
% mbe/jck/mgu 2017

%% Init
ccx;

%% Measurement Setup for Dode sub and mid-range
% Script for itaMSTF with HD2 and Dode. Comments for itaMSTFbandpass.
freqRange        = [50 10000]; % [50 5000]
% freqRangeSweep   = [freqRange(1) / 2 178; 178 freqRange(2) *2];
bandsPerOctave   = 3;
averages         = 2;

MS = itaMSTF; % itaMSTFbandpass
MS.inputChannels        = 1;
MS.outputChannels       = 1;
MS.freqRange            = freqRange;%freqRangeSweep;
MS.outputamplification  = 30;
MS.fftDegree            = 20;
MS.stopMargin           = 2.5;
MS.latencysamples       = 8303;


%% Reverb
% Source:   Receiver Room
% Receiver: Receiver Room
pause(5)
receiverRoomRIR = MS.run;
receiverRoomRIR = ita_time_window(receiverRoomRIR,[4 5], 'time', 'crop');

%% Compute and plot
ra = ita_roomacoustics(receiverRoomRIR, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave, 'T20');
RT =  ra.T20;
RT.plot_freq

%% Receiver Room Level
% Source:   Source Room
% Receiver: Receiver Room
pause(5)
for idm = 1:averages
    receiverRoom(idm) = MS.run;
end
receiverRoom                    = merge(receiverRoom);
receiverRoom.channelNames       = ita_sprintf('Receiver Room %i', 1:receiverRoom.nChannels); 
receiverRoom.channelUnits(:)    = {'Pa'};

%% Source Room Level
% Source:   Source Room
% Receiver: Source Room
pause(5)
for idm = 1:averages
    sourceRoom(idm) = MS.run; %#ok<*SAGROW>
end

sourceRoom                  = merge(sourceRoom);
sourceRoom.channelNames     = ita_sprintf('Senderaum %i', 1:sourceRoom.nChannels);
sourceRoom.channelUnits(:)  = {'Pa'};

%% Levels
receiverRoom_level = ita_spk2frequencybands(receiverRoom, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave);
receiverRoom_level.bar

sourceRoom_level = ita_spk2frequencybands(sourceRoom, 'freqRange', freqRange, 'bandsPerOctave', bandsPerOctave);
sourceRoom_level.bar

%% Mean of Levels
sourceRoom_level_mean       = sqrt(mean( abs(sourceRoom_level)^2 ));
receiverRoom_level_mean     = sqrt(mean( abs(receiverRoom_level)^2 ));

bar(merge(sourceRoom_level_mean, receiverRoom_level_mean))

%% Difference
% Level difference between source and receiver room

D = sourceRoom_level_mean / receiverRoom_level_mean;
D.bar

%% Ri
% Receiver room data
V = 154;   % Volume
S = 194;    % Wall surface

% Equivalent absorption area
A = 0.163  * V ./ RT.freqData;

% Calculate R
R = 20*log10(D.freqData) + 10*log10( S ./ A);

% Plot Ri
figure('position', get(0,'ScreenSize')*0.8 +25)
semilogx(D.freqVector, R, 'linewidth',2)
xlim(freqRange);
xlabel('Frequency in Hz');
ylabel('Ri in dB');
grid on;
set(gca, 'Xtick', D.freqVector)

%% Define limits
freqVecLimits = [100 125 155 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150]';
Ref_spektrum  = [33 36 39 42 45 48 51 52 53 54 55 56 56 56 56 56]';

%% Get Rw single value according to ISO
%adjust ISO offset by hand (mark offset value and use Strg + Mouse wheel while plot is visible )

% Dock plot and editor in MATLAB window.
% Mark the value of the offset variable in the script in the line below and
% change it with CTRL + mouse wheel. The plot will be updated and the curve
% will be shifted.
offset = -10;


[freqVec_Ri, ~, idx2take] = intersect(freqVecLimits,  D.freqVector);
Ri_in_dB   = R(idx2take);

clf;
semilogx(freqVec_Ri, Ref_spektrum+offset ,'-',  'linewidth', 3)
hold all; 
semilogx(D.freqVector, R,'-',  'linewidth', 3)
semilogx(freqVec_Ri, Ref_spektrum,'--',  'linewidth', 1, 'color', [1 1 1]*0.7); 
hold off
grid on;
xlabel('Frequency in Hz');
ylabel('Level in dB');
xlim(D.freqVector([1 end]));
set(gca, 'xtick', D.freqVector)
legend({'Reference' 'Measured R_i'}, 'location', 'northwest');

deviation = max(Ref_spektrum + offset  - Ri_in_dB,0);

title(sprintf('Offset %2.1f dB: Error %2.2f dB - %2.1f', offset, sum(deviation)))

% result
Rw = Ref_spektrum(8)+offset;