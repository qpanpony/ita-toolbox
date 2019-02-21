function varargout = ita_plot_quantile_freq(varargin)
%ITA_PLOT_FREQ_PHASE - Plot spectrum amplitude and phase
%  This function plots the spectrum and the phase in a two subwindow plot.
%  According to the options, one can select a part of the plot('axis'), or
%  the aspectratio of the axis ('aspectratio') -> see Options for more
%  details.
%
%  Syntax: fgh = ita_plot_freq_phase(data_struct)
%  Syntax: fgh = ita_plot_freq_phase(data_struct,'Option',value)
%  Syntax: fgh = ita_plot_freq_phase(data_struct,'figure_handle',ref,'nodB')
%
%  Options: (standard: -> )
%   'precise' ('on'|->'off') : Plots all data, no decimation
%   'unwrap' ('on'|->'off')  : Unwraps phase
%   'figure_hadle' ([])      : Sets the figure_handle
%   'xlim' ([])              : Sets the limits for the x axis
%   'ylim' ([])              : Sets the limits for the y axis
%   'axis' ([])              : Sets the limts for both axis
%   'aspectratio' ([])       : Sets the ratio of the axis
%   'hold' ('on'|->'off')    : Sets hold
%
%  Examples:
%  Two plots in one figure using hold
%  [fig axes] = ita_plot_freq_phase(ita_Audio_1);
%  ita_plot_freq_phase(ita_Audio_2,'hold','on','figure_handle',fig,'axes_handle',axes);
%
%  ita_plot_freq_phase(data_struct,'axis',[20 100 -60 -40]) plots in both windows
%  on the X axis from 20 to 100 and on the Y axis from -60 to -40
%
%  ita_plot_freq_phase(data_struct,'aspectratio',0.5) Sets the ratio of the
%  axis Y and X to 0.5
%
%  Syntax: ita_plot_freq_phase(itaAudio)
%
%  Options:
%       precise (false) - plot all data, no decimation
%       unwrap (false) - unwrap phase
%
%   See also ita_plot_freq_groupdelay, ita_plot_freq, ita_plot_time, ita_plot_time_dB, ita_plot_freq.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot_freq_phase">doc ita_plot_freq_phase</a>
%

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


%  Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Created:  21-Jan-2019

%% Initialization
sArgs = struct('pos1_data','itaSuper','nodb',true,'figure_handle',[],'axes_handle',[],'linfreq','off','linewidth',ita_preferences('linewidth'),...
    'fontname',ita_preferences('fontname'), 'xlim',[],'ylim',[],'axis',[],'aspectratio',[],'hold','off','precise',true,'ylog',false,'plotargs',[],...
    'shadeAreas',false,'deleteLines',true,'quantileOptions','minmax25reduced'); % additional for quantile plot
[data, sArgs] = ita_parse_arguments(sArgs, varargin);
% if numel(data) > 1
%     ita_verbose_info([thisFuncStr 'There is more than one instance stored in that object. Plotting the first one only.'],0);
%     varargin{1} = data(1);
% end

% set default if the linewidth is not set correct
if isempty(sArgs.linewidth) || ~isnumeric(sArgs.linewidth) || ~isfinite(sArgs.linewidth)
    sArgs.linewidth = 1;
end

%% determine quantile lines in frequency domain
quantile_lines = ita_quantile_lines(data,sArgs.quantileOptions); % use reduced as standard
if strcmpi(sArgs.quantileOptions,'minmax25reduced')
    rangeNames{1} = '25/75% quantile';
    rangeNames{2} = 'min/max';
elseif strcmpi(sArgs.quantileOptions,'minmax25')
    rangeNames{1} = '2.5/97.5% quantile';
    rangeNames{2} = '25/75% quantile';
    rangeNames{3} = 'min/max';
elseif strcmpi(sArgs.quantileOptions,'tukey')
    rangeNames{1} = '25/75% quantile';
    rangeNames{2} = 'Bound IQD'; % bound for inter quantile distance
    %     rangeNames{3} = 'Outliers'; %?
end

[figHandle, axesHandles] = ita_plot_freq(quantile_lines); % align phases based on 100 Hz, more robust than 0 Hz

% iterate over axes handles to apply shading for magnitude and phase
if sArgs.shadeAreas
    for idy = 1:length(axesHandles)
        axesObj = axesHandles(idy);
        axesChildrenSaved = axesObj.Children(3:end);
        
        median_id = ceil(quantile_lines.nChannels / 2);
        median_color = axesChildrenSaved(median_id).Color;
        
        % creates patches for all ranges apart from the median
        numRanges = (median_id-1);
        for idx = 1:numRanges
            % get range line ids
            range_ids = median_id + idx*[-1, 1];
            
            % extract lines
            lowerBound = axesChildrenSaved(range_ids(1));
            upperBound = axesChildrenSaved(range_ids(2));
            
            % extract data
            xDataLower = lowerBound.XData;
            yDataLower = lowerBound.YData;
            xDataUpper = upperBound.XData;
            yDataUpper = upperBound.YData;
            
            %calc alpha
            alphaRange = [0.25,0.75];
            alphaFill = max(alphaRange) - diff(alphaRange) / numRanges * idx;
            
            % create filled transparent space
            %     h = fill(axesObj,[xDataLower flip(xDataUpper)],[yDataLower flip(yDataUpper)],'k','LineStyle','none','FaceColor',median_color,'FaceAlpha',alphaFill);
            h = patch(axesObj,[xDataLower flip(xDataUpper)],[yDataLower flip(yDataUpper)],'k','LineStyle','none','FaceColor',median_color,'FaceAlpha',alphaFill);
            
            % adjust names
            h.DisplayName = rangeNames{idx};
        end
        
        % delete unused lines
        if sArgs.deleteLines
            numChild = length(axesObj.Children);
            ids_vec = 3:numChild; %ignore the first two cursors
            ids_vec2 = setdiff(ids_vec,numRanges+2+median_id); % ignore cursers and new ranges
            delete(axesObj.Children(ids_vec2));
        end
    end
end


varargout{1} = figHandle;
varargout{2} = axesHandles;

end