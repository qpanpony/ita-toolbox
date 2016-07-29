%% about nonlinearities in room acoustics (DAGA2013 Paper)
%
%  Exp. Sweep measurements are simulated using an emulation of the
%  measurement chain with nonlinerities.
%
%  Thanks for using this tutorial. Please feel free to contact us and
%  distribute the URL to the open source ITA-Toolbox (www.ita-toolbox.org)
%  if you like.
%
%  Authors: Pascal Dietrich / Martin Guski - March 2013

% <ITA-Toolbox>
% This file is part of the application RoomAcoustics for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Please see the References for Details and plots:
%
% @INPROCEEDINGS{pdiNonlinearitiesDAGA2013,
%   author = {Pascal Dietrich and Martin Guski and Michael Vorländer},
%   title = {Influence of Loudspeaker Distortion on Room Acoustic Parameters},
%   booktitle = DAGA2013,
%   year = {2013}}
%
% @INPROCEEDINGS{pdiToolboxDAGA2013,
%   author = {Pascal Dietrich and Martin Guski and Johannes Klein and Markus Müller-Trapet
% 	and Martin Pollow and Roman Scharrer and Michael Vorländer},
%   title = {Measurements and Room Acoustic Analysis with the ITA-Toolbox for
% 	MATLAB},
%   booktitle = DAGA2013,
%   year = {2013}}


%% clean everything
ccx

%% initialize parameters -- measurement parameters
sr                       = 44100;
freqRange                = [100 16000];
fftDegree                = 18; % length of impulse response / frequency resolution
bandsPerOctave           = 3; % third octave bands
outAmp_list              = -40:5:0; % in dBFS
nonlinearCoefficients{1} = [1 1]; % even polynom
nonlinearCoefficients{2} = [1 0 1]; % odd polynom

%% dummy measurement class
MS                       = itaMSTFdummy; % measurement transfer function class, with emulated measurement chain
MS.fftDegree             = fftDegree; % number of samples = 2^fftDegree
MS.outputamplification   = 0; % full level (dBFS)
MS.stopMargin            = 2; % Time to wait until the system decays
MS.freqRange             = freqRange; % Frequency range for the measurement
MS.averages              = 1; % number of measurements to be averaged to get a mean result
MS.samplingRate          = sr; % sampling Rate of the system
MS.lineardeconvolution   = false; % better to separate harmonics from fundamental
MS.minimumphasedeconvolution = false; % fundamental and harmonic IRs will no longer be symmetric
MS.filter                = true; % use extra filter to suppress noise and artefacts outside the frequency range
MS.precision             = 'double'; %use double precision float variables 64bit or single 32bit

%% simulate room impulse response
L           = [8 5 3]; % room geometry in meters
fmax        = 1000; % highest eigenfreuency
r_source    = [5 3 1.2]; % position of the sound source in meters
r_receiver  = [0 0 0]; % position of the microphone
T           = 1; %reverberation time of each eigenmode -> definition of modal damping
RIR         = ita_roomacoustics_analytic_FRF(itaCoordinates(L), itaCoordinates(r_source), itaCoordinates(r_receiver),'f_max',fmax,'T',T);
RIR         = itaAudioAnalyticRational(RIR);
RIR.samplingRate = sr;
RIR.fftDegree = fftDegree;
tic
ita_disp('calculating RIR...')
RIR                 = RIR'; %compile to freq domain
toc
win_vec             = [1.5 2]; % time window parameters in seconds
RIR_cut             = ita_time_window(RIR,win_vec,'time');
RIR_cut             = ita_normalize_dat(RIR_cut); % to obtain a scale just below 0dB in the end only for demonstration purposes
MS.systemresponse   = RIR_cut;

%% Add nonlinearities and plot in-out-diagram
colors = {'r','b'}; %colors for even and odd orders of polynomial coeffiecients
clc, close all

for idx = 1:numel(nonlinearCoefficients) % go thru all sets of pol. coeffs
    MS.nonlinearCoefficients = nonlinearCoefficients;
    figure;
    %plot nonlinear curve
    coeffs = nonlinearCoefficients{idx};
    u_in = -1:0.001:1;
    u_out = polyval([coeffs(end:-1:1) 0],u_in);
    plot(u_in,u_out,colors{idx})
    hold on
    %plot linear curve
    u_out_lin = polyval([coeffs(1) 0],u_in);
    plot(u_in,u_out_lin,'black')
    %make figure nice :)
    xlabel('normalized input amplitude, $x$')
    ylabel('normalized output amplitude, $y$')
    legend({'non-linear system','linear system'})
    grid on
    coeffStr = ita_nonlinear_polycoeff2string(coeffs);
    title(coeffStr)
    ylim([max(abs(ylim))].*[-1 1])
    %     %ita_savethisplot_gle(['nonlin' num2str(idx) 'inout'])
end

%% Lin vs. non-linear Impulse Response
% impulse response - linear system;
MS.nonlinearCoefficients = [1]; % this is the linear impulse response of the systems/measurement chain
h_lin = MS.run;
h_lin.channelNames{1} = 'linear';

% impulse repsonse - non-linear system
MS.nonlinearCoefficients = nonlinearCoefficients{1};
h_nonlin = MS.run;
h_nonlin.channelNames{1}    = ['nonlinear (even):' num2str(MS.nonlinearCoefficients)];

MS.nonlinearCoefficients = nonlinearCoefficients{2};
h_nonlin(2) = MS.run;
h_nonlin(2).channelNames{1} = ['nonlinear (odd):' num2str(MS.nonlinearCoefficients)];

% Difference ?
h_diff = h_lin - h_nonlin.merge;
res = merge(h_lin,h_nonlin.merge,h_diff);
res.ptd
ylimits = [-80 10];
ylim(ylimits)

%% Seperate plots for poster
close all
clc
h_lin.ptd('ylim',ylimits,'plotargs','black')
legend off;
title(['linear system ' ita_nonlinear_polycoeff2string([1])]);
%ita_savethisplot_gle('IR_lin');

% nonlinear IRs
close all
h_nonlin(1).ptd('ylim',ylimits,'plotargs',colors{1})
legend off;
title(['non-linear system ' ita_nonlinear_polycoeff2string(nonlinearCoefficients{1})]);
%ita_savethisplot_gle('IR_nonlin1');

h_nonlin(2).ptd('ylim',ylimits,'plotargs',colors{2})
legend off;
title(['non-linear system ' ita_nonlinear_polycoeff2string(nonlinearCoefficients{2})]);
% %ita_savethisplot_gle('IR_nonlin2');

% diff IRs
close all
h_diff.ch(1).ptd('ylim',ylimits,'plotargs',colors{1})
legend off;
title(['difference linear and non-linear system ' ita_nonlinear_polycoeff2string(nonlinearCoefficients{1})]);
% %ita_savethisplot_gle('IR_diff_nonlin1');

h_diff.ch(2).ptd('ylim',ylimits,'plotargs',colors{2})
legend off;
title(['difference linear and non-linear system ' ita_nonlinear_polycoeff2string(nonlinearCoefficients{2})]);
% %ita_savethisplot_gle('IR_diff_nonlin2');

%% DIFFERENT LEVELS - calculate room acoustic parameter in frequency bands
clear h
clear raPar
clear EDT
clear C80
close all
MS.systemresponse   = RIR_cut;

for nonlin_idx = 1:numel(nonlinearCoefficients)
    MS.nonlinearCoefficients = nonlinearCoefficients{nonlin_idx};
    MS.comment = ita_nonlinear_polycoeff2string(MS.nonlinearCoefficients);
    for idx = 1:numel(outAmp_list)
        MS.outputamplification  = outAmp_list(idx);
        h(idx)                  = MS.run; % get impulse response of nonlinear system
        h(idx).channelNames{1}  = MS.outputamplification; % write the current level for later use
        % no noisedetect
        h(idx) = ita_extract_dat(h(idx));
        raPar(idx)  = ita_roomacoustics(h(idx), 'freqRange', [ freqRange(1) fmax], 'bandsPerOctave', bandsPerOctave, 'EDT', 'C80', 'edcmethod', 'noCut');
        
        EDT(idx)    = raPar(idx).EDT;
        C80(idx)    = raPar(idx).C80;
    end
    
    % plot EDT
    res = EDT.merge;
    res.comment = MS.comment;
    
    
    correct_res = merge(repmat(res.ch(1),1,res.nChannels));
    res_dev = (res - correct_res)/res.ch(1)*100;
    res_dev.comment = MS.comment;
    res_dev.channelNames = res.channelNames;
    res_dev.bar('ylim',[-5 5])
    ylabel('rel. error (EDT) in $%$')
    %ita_savethisplot_gle(['EDT_nonlin_' num2str(nonlin_idx)])
    
    
    % plot C80
    res = C80.merge;
    res.comment = MS.comment;
    
    correct_res = merge(repmat(res.ch(1),1,res.nChannels));
    res_dev = (res - correct_res)/res.ch(1)*100;
    res_dev.channelNames = res.channelNames;
    res_dev.comment = MS.comment;
    res_dev.bar('ylim',[-3 3])
    ylabel('abs. error of $C_{80}$ in dB')
    
    %ita_savethisplot_gle(['C80_nonlin_' num2str(nonlin_idx)])
    
end
% raPar.C80.pf

%% get EDT and C80 without distortion
EDT(1).pf('ylim',[0 1.5])
ylabel('EDT')
%ita_savethisplot_gle(['EDT'])

C80(1).pf
ylabel('$C_{80}$')
%ita_savethisplot_gle(['C80'])

%% GAIN DEVIATION WITHOUT RIR
MS.systemresponse = []; % delete RIR and obtain the level change of the fundamental IR only (no overlapping at all!)
close all
clc
for nonlin_idx = 1:numel(nonlinearCoefficients)
    MS.nonlinearCoefficients = nonlinearCoefficients{nonlin_idx};
    MS.comment = ita_nonlinear_polycoeff2string(MS.nonlinearCoefficients);
    outAmp_list_fine = outAmp_list(1):1:outAmp_list(end);
    for idx = 1:numel(outAmp_list_fine)
        MS.outputamplification  = outAmp_list_fine(idx);
        h(idx)                  = MS.run; % get impulse response of nonlinear system
        h(idx).channelNames{1}  = MS.outputamplification; % write the current level for later use
        % no noisedetect
        h(idx)      = ita_time_window(h(idx),[ 0.1 0.2],'time','symmetric');
        gain(idx)   = h(idx).bar;
    end
    reference = h(1).bar;
    res       = gain.merge / reference;
    res.bar
    ylim([-1 1]*15)
    xlim([MS.freqRange])
    %     %ita_savethisplot_gle(['gainerror_noIR_' num2str(nonlin_idx)]);
    
    %% new plot without frequency dependence
    gain_values = 20*log10(abs(res.freq2value(1000)));
    figure;
    plot(outAmp_list_fine, gain_values,colors{nonlin_idx},'linewidth',2)
    grid
    ylim([0 5])
    xlabel('output amplification in dB')
    ylabel('gain error in dB')
    %ita_savethisplot_gle(['gainerror_noIR_' num2str(nonlin_idx)]);
    
end

%% WITH SYSTEM RESPONSE = RIR
MS.systemresponse = RIR_cut; % set RIR, we might experience level changes (odd orders) or overlapping (even and odd orders) depending on the sweep parameters
close all
clc
clear h;
clear gain;
for nonlin_idx = 1:numel(nonlinearCoefficients)
    MS.nonlinearCoefficients = nonlinearCoefficients{nonlin_idx};
    MS.comment = ita_nonlinear_polycoeff2string(MS.nonlinearCoefficients);
    for idx = 1:numel(outAmp_list)
        MS.outputamplification  = outAmp_list(idx);
        h(idx)                  = MS.run; % get impulse response of nonlinear system
        h(idx).channelNames{1}  = MS.outputamplification; % write the current level for later use
        % no noisedetect
        h(idx) = ita_time_window(h(idx),win_vec,'time','symmetric');
        gain(idx) = h(idx).bar;
    end
    reference = h(1).bar;
    res       = gain.merge / reference;
    res.channelNames = gain.merge.channelNames;
    res.bar
    ylim([-1 1]*15)
    xlim([MS.freqRange(1) fmax])
    %ita_savethisplot_gle(['gainerror_withIR_' num2str(nonlin_idx)]);
end

%% finish
ita_disp('script finished successfully')
% please report bugs to toolbox-dev@akustik.rwth-aachen.de


