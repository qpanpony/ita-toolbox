function varargout = ita_msplaybackrecord_gui(varargin)
%ITA_MSTF_GUI - Edit a measurement setup for playback and recording

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  16-Nov-2011


pList = [];
argList = [];
%GUI Init

if nargin == 1
    MS = varargin{1};
else
    MS = itaMSPlaybackRecord;
end

ele = numel(pList)+1;
pList{ele}.datatype     = 'line';

ele = numel(pList)+1;
pList{ele}.datatype     = 'text';
pList{ele}.description  = 'Basic settings';
pList{ele}.color        = 'black';

ele = numel(pList)+1;
pList{ele}.description  = 'Preferences';
pList{ele}.helptext     = 'Call ita_preferences()';
pList{ele}.datatype     = 'simple_button';
pList{ele}.default      = '';
pList{ele}.callback     = 'ita_preferences();';

ele = numel(pList)+1;
pList{ele}.description  = 'ROBO';
pList{ele}.helptext     = 'Call ita_robocontrol() GUI';
pList{ele}.datatype     = 'simple_button';
pList{ele}.default      = '';
pList{ele}.callback     = 'ita_robocontrol();';

ele = numel(pList)+1;
pList{ele}.description  = 'ModulITA';
pList{ele}.helptext     = 'Call ita_modulita_control() GUI';
pList{ele}.datatype     = 'simple_button';
pList{ele}.default      = '';
pList{ele}.callback     = 'ita_modulita_control();';

ele = numel(pList)+1;
pList{ele}.description  = 'Aurelio';
pList{ele}.helptext     = 'Call ita_aurelio_control() GUI';
pList{ele}.datatype     = 'simple_button';
pList{ele}.default      = '';
pList{ele}.callback     = 'ita_aurelio_control();';

ele = numel(pList)+1;
pList{ele}.description  = 'Input Channels';
pList{ele}.helptext     = 'Vector with the input channel numbers. The order specified here is respected!';
pList{ele}.datatype     = 'int_result_button';
pList{ele}.default      = MS.inputChannels;
if isempty(pList{ele}.default)
    pList{ele}.default  = 1;
end;
pList{ele}.callback     = 'ita_channelselect_gui([$$],[],''onlyinput'')';
argList = [argList {'inputChannels'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Output Channels';
pList{ele}.helptext     = 'Vector with the output channel numbers. The order specified here is respected!';
pList{ele}.datatype     = 'int_result_button';
pList{ele}.default      = MS.outputChannels;
if isempty(pList{ele}.default)
    pList{ele}.default  = 1;
end;
pList{ele}.callback     = 'ita_channelselect_gui([],[$$],''onlyoutput'')';
argList = [argList {'outputChannels'}];


ele = numel(pList)+1;
pList{ele}.datatype     = 'line';

ele = numel(pList)+1;
pList{ele}.datatype     = 'text';
pList{ele}.description  = 'Signal Specifications';


ele = numel(pList)+1;
pList{ele}.description = 'Playback signal'; %this text will be shown in the GUI
pList{ele}.helptext    = 'This is the signal which will be played'; %this text should be shown when the mouse moves over the textfield for the description
pList{ele}.datatype    = 'itaAudio'; %based on this type a different row of elements has to drawn in the GUI
pList{ele}.default     = ''; %default value, could also be empty, otherwise it has to be of the datatype specified above
argList = [argList {'excitation'}];

ele = numel(pList)+1;
pList{ele}.description  = 'Output Amplification [dBFS]';
pList{ele}.helptext     = 'Attenuate your signal by this value in dB Full Scale. Compensation will follow, we will take care of this.';
pList{ele}.datatype     = 'char';
pList{ele}.default      = MS.outputamplification;
argList = [argList {'outputamplification'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Frequency Limits [Hz]';
pList{ele}.helptext     = 'Bandfilter the recorded signal';
pList{ele}.datatype     = 'int';
pList{ele}.default      = MS.freqRange;
argList = [argList {'freqRange'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Apply Bandpass';
pList{ele}.helptext     = 'Apply the bandpass';
pList{ele}.datatype     = 'bool';
pList{ele}.default      = MS.applyBandpass;
argList = [argList {'applyBandpass'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Comment';
pList{ele}.helptext     = 'Give your child a name';
pList{ele}.datatype     = 'char_long';
pList{ele}.default      = MS.comment;
argList = [argList {'comment'}];

ele = numel(pList)+1;
pList{ele}.datatype     = 'line';

ele = numel(pList)+1;
pList{ele}.datatype     = 'text';
pList{ele}.description  = 'Advanced settings';
pList{ele}.color        = 'red';

ele = numel(pList)+1;
pList{ele}.description  = 'Pause before measurements';
pList{ele}.helptext     = 'Time in seconds the routine waits before each measurement';
pList{ele}.datatype     = 'int';
pList{ele}.default      = MS.pause;
argList = [argList {'pause'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Number of Averages';
pList{ele}.helptext     = 'How many measurements should be averaged for the final results?';
pList{ele}.datatype     = 'int';
pList{ele}.default      = MS.averages;
argList = [argList {'averages'}];

ele = numel(pList)+1;
pList{ele}.description  = 'Output Equalization';
pList{ele}.helptext     = 'Do a broadband output equalization (only with calibrated output measurement chain)';
pList{ele}.datatype     = 'bool';
pList{ele}.default      = MS.outputEqualization;
argList = [argList {'outputEqualization'}];

ele = numel(pList)+1;
pList{ele}.description  = 'Measurement Chain';
pList{ele}.helptext     = 'Whether to use the measurement chain functionality (calibration)';
pList{ele}.datatype     = 'bool';
pList{ele}.default      = MS.useMeasurementChain;
argList = [argList {'useMeasurementChain'}];

ele = numel(pList)+1;
pList{ele}.datatype     = 'line';

%call gui
pList = ita_parametric_GUI(pList,[mfilename ' - Modify an itaMSPlaybackRecord']);
pause(0.02); %wait for GUI to close first

% Check output amplifiction
if isempty(pList) %user cancelled
    varargout{1} = [];
    return;
end

%% settings to MSTF
%reorder first, useMeasurementChain does not work otherwise
pList = [pList(end) pList(1:end-1)];
argList = [argList(end) argList(1:end-1)];

for idx = 1:numel(pList)
    MS.(argList{idx}) = pList{idx};
end

varargout{1} = MS;


