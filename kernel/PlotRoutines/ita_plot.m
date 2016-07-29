function [varargout] = ita_plot(varargin)
%ITA_PLOT - plots some data in the most simple way
%  This function chooses a suitable plot routine and calls it.
%
%  Call: ita_plot(audioData)
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plot">doc ita_plot</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Martin Pollow -- Email: mpo@akustik.rwth-aachen.de
% Created:  12-Sep-2008


%% Initialization
if nargin == 0;
    ita_plot_gui();
    return;
end

sArgs = struct('pos1_data','itaAudio','figure_handle',[]);
[audioObj, sArgs] = ita_parse_arguments(sArgs,varargin);

% default is no polar data
isPolar = false;

% is it polar data?
if (numel(audioObj) > 20)
    for n = 1:numel(audioObj)
        if strcmp(audioObj{n}.Filename, 'V000H000')
            isPolar = true;
            break;
        end
    end
end

if isPolar
    fgh = ita_plot_spherical(audioObj);
else % no polar data
    domain = audioObj(1).domain;
    audioObj = merge(audioObj);
    switch domain
        case 'time'
            if strcmpi(audioObj.signalType,'energy') || isequal(audioObj.signalType,1)
                %energy signals will be plotted in dB
                fgh = ita_plot_time_dB(audioObj,'figure_handle',sArgs.figure_handle);
            else
                fgh = ita_plot_time(audioObj,'figure_handle',sArgs.figure_handle);
            end
        case 'freq'
            if sum(strcmpi(audioObj.channelUnits{1},{'kg/s','s/kg'})) %pdi: this is an impedance
                fgh = ita_plot_freq_phase(audioObj,'figure_handle',sArgs.figure_handle);
            else
                fgh = ita_plot_freq(audioObj,'figure_handle',sArgs.figure_handle);
            end
    end
end

%% Return the figure handle
varargout(1) = {fgh};