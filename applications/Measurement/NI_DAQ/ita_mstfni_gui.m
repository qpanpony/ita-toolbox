function varargout = ita_mstfni_gui(varargin)
%ITA_MSTFNI_GUI - Edit a measurement setup for transfer functions (NI hardware)

% <ITA-Toolbox>
% This file is part of the application Measurement for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Markus Mueller-Trapet -- Email: markus.mueller-trapet@nrc.ca
% Created:  10-May-2017


pList = [];
argList = [];
%GUI Init

if nargin == 1
    MS = varargin{1};
else
    MS = itaMSTFni;
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
pList{ele}.description  = 'Input Channels';
pList{ele}.helptext     = 'Vector with the input channel numbers. The order specified here is respected!';
pList{ele}.datatype     = 'int_result_button';
pList{ele}.default      = MS.inputChannels;
if isempty(pList{ele}.default)
    pList{ele}.default  = 1;
end
pList{ele}.callback     = 'ita_channelselect_gui_ni([$$],[],''onlyinput'')';
argList = [argList {'inputChannels'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Output Channels';
pList{ele}.helptext     = 'Vector with the output channel numbers. The order specified here is respected!';
pList{ele}.datatype     = 'int_result_button';
pList{ele}.default      = MS.outputChannels;
if isempty(pList{ele}.default)
    pList{ele}.default  = 1;
end
pList{ele}.callback     = 'ita_channelselect_gui_ni([],[$$],''onlyoutput'')';
argList = [argList {'outputChannels'}];


ele = numel(pList)+1;
pList{ele}.datatype     = 'line';

ele = numel(pList)+1;
pList{ele}.datatype     = 'text';
pList{ele}.description  = 'Signal Specifications';

ele = numel(pList)+1;
pList{ele}.description  = 'FFT Degree';
pList{ele}.helptext     = 'Length of the signal (2^fft_degree samples)';
pList{ele}.datatype     = 'int';
pList{ele}.default      = MS.fftDegree;
argList = [argList {'fftDegree'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Frequency Limits [Hz]';
pList{ele}.helptext     = 'The sweep will start at low frequency and rise up to high frequency';
pList{ele}.datatype     = 'int';
pList{ele}.default      = MS.freqRange;
argList = [argList {'freqRange'}];

ele = numel(pList)+1;
pList{ele}.description  = 'Signal Type';
pList{ele}.helptext     = 'Exponential/logarithmic sweeps and linear sweeps can be choosen.)';
pList{ele}.datatype     = 'char_popup';
pList{ele}.default      = MS.type;
pList{ele}.list         = 'exp|lin|noise';
argList = [argList {'type'}];

ele = numel(pList)+1;
pList{ele}.description  = 'Stop Margin [s]';
pList{ele}.helptext     = 'This is the time of silence in the end of the sweep. It should be longer than the reverberation time at the highest frequency.';
pList{ele}.datatype     = 'int';
pList{ele}.default      = MS.stopMargin;
argList = [argList {'stopMargin'}];


ele = numel(pList)+1;
pList{ele}.description  = 'Output Amplification [dBFS]';
pList{ele}.helptext     = 'Attenuate your sweep by this value in dB Full Scale. Compensation will follow, we will take care of this.';
pList{ele}.datatype     = 'char';
pList{ele}.default      = MS.outputamplification;
argList = [argList {'outputamplification'}];


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
pList{ele}.description  = 'Linear Deconvolution';
pList{ele}.helptext     = 'Standard is cyclic deconvolution. To seperate distortion from the noise tail use linear deconvolution. Signal length is therefore doubled.';
pList{ele}.datatype     = 'bool';
pList{ele}.default      = MS.lineardeconvolution;
argList = [argList {'lineardeconvolution'}];

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
pList = ita_parametric_GUI(pList,[mfilename ' - Modify an itaMSTF']);
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


