function MS = ita_measurement(varargin)
% ITA_MEASUREMENT - main function for starting a measurement
% This is the starting function to use when you like to do a measurement of
% any kind. A GUI will guide you thru the entire process of measurement
% setup, calibration and measurement itself.
% Choose:
%   'Signals': if you like to measure signals only without doing a playback
%              at the same time, e.g. record a concert with several microphones
%   'Transfer Function': to measure a transfer function/FRF/impulse
%             response with deconvolution of the excitation signal (e.g. sweep or MLS)
%
%   'Impedance': to measure a loudspeaker impedance with ROBO or ModulITA
%
% Syntax:
%     MS = ita_measurement() - let the GUI guide you
%
% See also:
%     itaMeasurementSetupSuper, itaMeasurementTasks, ita_generate,
%     ita_measurement_setup_transferfunction
%

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich - 2009

%% Initialization
MS           = [];
mpos         = get(0,'Monitor');
width        = 410;

% do some automatic positioning etc.
nButtons = 3;
callBacks = {@RecordButtonCallback,@PlaybackRecordButtonCallback,@TransferfunctionButtonCallback,@ImpedanceButtonCallback};
titleStr = {'Record','Playback and Record','Transferfunction','Impedance'};
colors = [1 0 0; 0.9 .9 0.1; 0.1 0.9 0.1; 0.9 0.9 0.9];

if exist('itaMSimpedance.m','file')
    nButtons = 4;
end

height = 50 + nButtons*100;
w_position   = (mpos(1,length(mpos)-1)/2)-(width/2);
h_position   = (mpos(1,length(mpos))/2)-(height/2);

MainPosition = [w_position h_position width height];

clear figSet
hMainFigure = figure( ...       % the main GUI figure
    'MenuBar','none', ...
    'Toolbar','none', ...
    'HandleVisibility','on', ...
    'Name', 'What do you want to measure today?', ...
    'NumberTitle','off', ...
    'Position' , MainPosition, ...
    'Color', [0.8 0.8 0.8]);

figSet.hMainFigure = hMainFigure;

%% ITA toolbox logo
a_im = importdata(which('ita_toolbox_logo.jpg'));
image(a_im);axis off
set(gca,'Units','pixel', 'Position', [10 10 350 65]*0.6); %TODO: later set correctly the position

%% pushbuttons - ui control elements
for iButton = 1:nButtons
    uicontrol(...
    'Parent', hMainFigure, ...
    'Position',[10 height-iButton*100 395 95],...
    'String', titleStr{iButton},...
    'FontWeight','bold',...
    'FontSize',21,...
    'Style', 'pushbutton',...
    'BackgroundColor', colors(iButton,:),...
    'Callback', callBacks{iButton});

end

% Make the GUI blocking
uiwait(figSet.hMainFigure);

% TODO: Ask for reference measurement HERE.

%----------------------------------------------------------------------
    function PlaybackRecordButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        close gcf;
        MS = itaMSPlaybackRecord;
        MS.edit;
    end
%----------------------------------------------------------------------
    function RecordButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        close gcf;
        MS = itaMSRecord;
        MS.edit;
    end

%----------------------------------------------------------------------
    function TransferfunctionButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        close gcf;
        MS = itaMSTF;
        MS.edit;
    end
%----------------------------------------------------------------------
    function ImpedanceButtonCallback(hObject, eventdata) %#ok<INUSD,INUSD>
        close gcf;
        MS = itaMSImpedance;
        MS.freqRange(1) = 5;
        MS.fftDegree = 18;
        MS.edit;
    end
end %end function
