function ita_plot_TPA(varargin)
%ITA_PLOT_TPA - TPA Contribution plot
%  This function realizes a common plot in TPA/TPS to show contributions of
%  serveral paths in comparison and over frequency in one plot
%
%  Syntax:
%   audioObjOut = ita_plot_TPA(audioObjIn, options)
%
%  See also:
%   ita_plot_tpa_plot_matrix, ita_plot_tpa_plot_matrix_condition_number
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_TPA">doc ita_plot_TPA</a>

% <ITA-Toolbox>
% This file is part of the application TPA-TPS for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  29-Jun-2010


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaAudio', 'opt1', true);
[input,sArgs] = ita_parse_arguments(sArgs,varargin); %#ok<NASGU>

% third octave band levels
levels = ita_spk2frequencybands(input.merge);

%%
ita_plottools_figure();
plotData = levels.freqData_dB.'; 
plotData = [plotData; plotData(end,:)];
plotData = [plotData, plotData(:,end)];

pcolor(plotData)

for idx = 1:levels.nChannels
    yticklabel{idx} = [num2str(idx) ' [' levels.channelUnits{idx} ']'] ;
end

freqVec = levels.freqVector;
set(gca,'XTick',(1:numel(freqVec))+0.5)
set(gca,'XTickLabel',freqVec)
set(gca,'YTick',1.5:(levels.nChannels+0.5))
set(gca,'YTickLabel',yticklabel)

ylabel('Transfer Paths')
xlabel('Frequency in Hz')
title('TPA Plot in dB')
colorbar
climits = (get(gca,'CLim')/10);
climits(2) = ceil(climits(2));
climits(1) = max (ceil(climits(1)) , climits(2) - 5 ) ;


set(gca,'CLim',climits*10);
setappdata(gca,'PlotType','spectrogram')    %Types: time, mag, phase, gdelay
ita_plottools_colormap('artemis');
ita_plottools_cursors('on',[],gca);
setappdata(gca,'FigureHandle',gcf); %pdi: saver to write this, than to estimate via parent / GUI problem
setappdata(gcf,'AxisHandles',gca);

%end function
end