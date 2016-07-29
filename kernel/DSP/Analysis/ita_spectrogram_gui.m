function  ita_spectrogram_gui(varargin)
%ITA_SPECTROGRAM_GUI - +++ Short Description here +++
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_spectrogram_gui(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_spectrogram_gui(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_spectrogram_gui">doc ita_spectrogram_gui</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Martin Guski -- Email: mgu@akustik.rwth-aachen.de
% Created:  03-Jun-2014


%% Initialization and Input Parsing
sArgs          = struct('pos1_data','itaAudio', 'figure_handle', [], 'axes_handle', []);
[input, sArgs] = ita_parse_arguments(sArgs,varargin);

%%
if isempty(sArgs.axes_handle) % create new figure with axes
    screenSize = get(0, 'screenSize');
    h.fgh = figure('position', [100 100 screenSize(3:4) /1.2]);
    h.ax  = axes('parent', h.fgh);
else
    h.ax = sArgs.axes_handle;
    if isempty(sArgs.figure_handle)
        h.ax = get(sArgs.axes_handle, 'parent');
    else
        h.fgh = sArgs.figure_handle;
    end
end
     


gData = struct('audio', input, 'currentChannel', 1 , 'handles', h);
guidata(gData.handles.fgh, gData)
set(gData.handles.fgh, 'KeyPressFcn', @keyPressCallback)

% plot first channel 
result = ita_spectrogram_mgu(gData.audio.ch(gData.currentChannel));
plotData = 20*log10(abs(result.data)) - 20*log10(2e-5);
pcolor(gData.handles.ax, result.timeVector, result.freqVector, plotData);
set(gData.handles.ax, 'YScale', 'log'); % TODO: besser nicht gca
shading interp;
title(gData.audio.channelNames{gData.currentChannel})
ylim([20 22050])
colorbar
xlabel('time (in s)')
ylabel('frequency (in Hz)')




%% Set Output
% varargout(1) = {};

%end function
end




function keyPressCallback(src, event)

gData = guidata(src);


switch event.Character
    
    case '*'
        gData.currentChannel = gData.currentChannel + 1;
        
    case '/'
        gData.currentChannel = gData.currentChannel - 1;
        
    case 'd'
        oldValues = [axis(gData.handles.ax) get(gData.handles.ax, 'clim')];
        newValues = ita_plottools_zoom(oldValues, {'time' 'frequency' 'level'});
        axis(gData.handles.ax, newValues([ 1 4 2 5]));
        set(gData.handles.ax, 'clim', newValues(3,:))
        return
    otherwise
        fprintf([ 'unknown character: ' event.Character '\n'])
        disp(event)
        return
end

gData.currentChannel = rem(gData.currentChannel -1+gData.audio.nChannels, gData.audio.nChannels)+1;

oldAxis = axis;

% plot first channel 
result = ita_spectrogram_mgu(gData.audio.ch(gData.currentChannel));
plotData = 20*log10(abs(result.data)) - 20*log10(2e-5);
pcolor(gData.handles.ax, result.timeVector, result.freqVector, plotData);
set(gData.handles.ax, 'YScale', 'log'); % TODO: besser nicht gca
shading interp;
title(gData.audio.channelNames{gData.currentChannel})
% ylim([20 22050])
colorbar
xlabel('time (in s)')
ylabel('frequency (in Hz)')
axis(oldAxis)

guidata(src, gData);


end