%% Measurement Tutorial
%
% <<../pics/ita_toolbox_logo_wbg.png>>
%
% This tutorial requires understanding of ita_tutorial_measurement. 
% Finally, we measure the ITA-V0-Box.
%
% *HAVE FUN! and please report bugs* 
%
% _2012 - Pascal Dietrich_
% toolbox-dev@akustik.rwth-aachen.de
%
% <<../pics/toolbox_bg.png>>a = 
% 

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Please have a look at the Measurement Tutorial first
edit ita_tutorial_measurement

%% testing measurement box for ITA-V0-Box ********************************************
% Please connect the box to your ITA robo front-end that should be connected to your sound card. 
MS = itaMSTF('useMeasurementChain',false,'inputChannels',3,'outputChannels',3,'samplingRate',44100,...
            'fftDegree', 15, 'freqRange', [40 18000], 'type', 'exp', 'stopMargin', 0.1, ...
            'outputamplification', '-10dB', 'comment', 'MessBOX', 'pause', 0, 'averages', 1);

ita_robocontrol('20dB','norm','0db');

%% measurements
% Now we measure all 6 settings of the Box with different amplication
for set_idx = 1:6
    
    h = helpdlg(['Please switch to setting ' num2str(set_idx) '.'],'Selection');
    uiwait(h);
    clear a
    MS.comment = ['setting ' num2str(set_idx)];

    ampl = -20:5:0; % go thru all levels of excitation
    close all;
    for idx = 1:length(ampl);
        MS.outputamplification = [num2str(ampl(idx)) 'dB'];
        a(set_idx,idx) = MS.run;  %#ok<SAGROW>
        a(set_idx,idx).channelNames{1} = [a(set_idx,idx).channelNames{1} ' (' MS.outputamplification ')']; %#ok<SAGROW>
        close all
    end
    data = merge(a(set_idx,:));
    final_result(set_idx) = data; %#ok<SAGROW>
    filename = [MS.comment '.ita'];
    ita_write(data,filename);
    
    ita_plot_freq_phase(data);
    ita_plottools_cursors('off')
    ita_plot_time_dB(data);
    ita_plottools_cursors('off')
    
end
