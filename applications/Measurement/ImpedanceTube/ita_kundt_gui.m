function ita_kundt_gui(varargin)
%ITA_KUNDT_GUI - GUI for measurements in Kundts Tube
%
%  Syntax:
%   ita_kundt_gui()
%
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_kundt_gui">doc ita_kundt_gui</a>

% <ITA-Toolbox>
% This file is part of the application Kundt for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  20-Jun-2009 

%%

if nargin == 1
    switch varargin{1}
        case 3
            ita_verbose_info('Using three microphones.')
            nMics = 3;
        case 4
            ita_verbose_info('Using four microphones.')
            nMics = 4;
        otherwise
            error('Wrong input argument. Only three and four microphones supported. ')
            
    end
else
    nMicString = questdlg('How many microphones do you use?', ...
        'Mic selection', ...
        '3','4','3');
    nMics = str2double(nMicString);
end

%% Default Kundt_Setup
KundtSetup.timewindow   = true;
KundtSetup.timeframe    = [0.2 0.3];
KundtSetup.saverawdata  = true;
KundtSetup.saveresult   = true;
KundtSetup.savesetup    = true;
KundtSetup.keepresult   = true;
KundtSetup.nMics        = nMics;
KundtSetup.tube         = '';
% KundtSetup.what = 'Allrefl';
KundtSetup.dist = [];


%% Default Measurement Setup

fftDegree   = 17;
freqRange   = [20,12000];
type  = 'exp';
stopMargin  = 0.1;

inputCh      = 1;                    
outputCh     = 3;   

outputamplification = -20;

commentStr = ['Kundt''s tube measurement (' datestr(now)  ')'];

pauseTime           = 0.1;
averages            = 4;


%% create MFTF object

MeasurementSetup = itaMSTF('freqRange', freqRange, 'fftDegree', fftDegree, 'stopMargin', stopMargin, 'useMeasurementChain', false,'inputChannels', inputCh, 'outputChannels', outputCh, 'averages', averages, 'pause' , pauseTime, 'comment', commentStr, 'type', type, 'outputamplification', outputamplification );
MeasurementSetup.edit    % allow user to edit...

%%

% shelf filter to amplify high frequencies
% MeasurementSetup.excitation = ita_filter(MeasurementSetup.excitation, 'shelf',   'high',[50 8000],'order', 6);
% ita_verbose_info('Using Shelf-Filter',0)


ita_setinbase('Kundt_Measurement_Setup',MeasurementSetup);
ita_setinbase('Kundt_Kundt_Setup',KundtSetup);

clear MeasurementSetup KundtSetup tmp;

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back 
idx = 1;
pList{idx}.description = 'Setup';
pList{idx}.datatype    = 'text';

% idx = idx+1;
% pList{idx}.description = 'Measurement Setup';
% pList{idx}.datatype    = 'simple_button';
% pList{idx}.helptext    = 'Call Measurement Setup'; %this text should be shown when the mouse moves over the textfield for the description
% pList{idx}.callback    = 'ita_setinbase(''Kundt_Measurement_Setup'',ita_measurement_setup_transferfunction(ita_getfrombase(''Kundt_Measurement_Setup'')))';

idx = idx+1;
pList{idx}.description = 'Kundt Setup';
pList{idx}.datatype    = 'simple_button';
pList{idx}.helptext    = 'Call Measurement Setup'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.callback    = 'ita_setinbase(''Kundt_Kundt_Setup'',ita_kundt_setup(ita_getfrombase(''Kundt_Kundt_Setup'')))';

idx = idx+1;
pList{idx}.datatype    = 'line';

idx = idx+1;
pList{idx}.description = 'Probe';
pList{idx}.datatype    = 'text';

idx = idx+1;
pList{idx}.description = 'Probe Name';
pList{idx}.helptext    = 'Name of the probe';
pList{idx}.datatype    = 'char';
pList{idx}.default    = 'test';

idx = idx+1;
pList{idx}.description = 'Data Path';
pList{idx}.helptext    = 'Path where the results will be stored';
pList{idx}.datatype    = 'path';
pList{idx}.default    = ita_preferences('DataPath');

idx = idx+1;
pList{idx}.datatype    = 'line';

idx = idx+1;
pList{idx}.description = 'Measurement Run';
pList{idx}.datatype    = 'text';

for idmic = 1:nMics
    idx = idx+1;
    pList{idx}.description = ['Mic' int2str(idmic)];
    pList{idx}.datatype    = 'simple_button';
    pList{idx}.helptext    = ['Run measurement at microphone position ' int2str(idmic)]; %this text should be shown when the mouse moves over the textfield for the description
    pList{idx}.callback    = @ita_kundt_run;
end

idx = idx+1;
pList{idx}.datatype    = 'line';

idx = idx+1;
pList{idx}.description = 'Calculation';
pList{idx}.datatype    = 'text';

idx = idx+1;
pList{idx}.description = 'Go';
pList{idx}.datatype    = 'simple_button';
pList{idx}.helptext    = 'Run rohrbert'; %this text should be shown when the mouse moves over the textfield for the description
pList{idx}.callback    = @ita_kundt_calc;

% idx = idx+1;
% pList{idx}.description = 'Plot Results';
% pList{idx}.datatype    = 'simple_button';
% pList{idx}.helptext    = 'Plot results'; %this text should be shown when the mouse moves over the textfield for the description
% pList{idx}.callback    = 'ita_plot_gui(''name'',''Kundt_Result'');';
%     
% idx = idx+1;
% pList{idx}.description = 'Save Results';
% pList{idx}.datatype    = 'simple_button';
% pList{idx}.helptext    = 'Save results'; %this text should be shown when the mouse moves over the textfield for the description
% pList{idx}.callback    = @ita_kundt_save;


%
%   pList{3}.description = 'showInfo'; %this text will be shown in the GUI
%   pList{3}.helptext    = 'Show some verbose Info'; %this text should be shown when the mouse moves over the textfield for the description
%   pList{3}.datatype    = 'bool'; %based on this type a different row of elements has to drawn in the GUI
%   pList{3}.default     = false; %default value, could also be empty, otherwise it has to be of the datatype specified above
%
%   pList{4}.datatype    = 'line'; %just draw a simple line
%
%   pList{5}.description = 'Just a simple text'; %this text will be shown in the GUI
%   pList{5}.datatype    = 'text'; %only show text

disabledmenuentries = {'workspace','domain'};
ita_parametric_GUI(pList,'Kundt','wait','off','ita_menu_disable',disabledmenuentries,'ita_menu','off');

%% Add history line
%result.header = ita_metainfo_add_historyline(result.header,mfilename,varargin);

%% Check header
%%result = ita_metainfo_check(result);

%% Find output parameters
%varargout(1) = {result}; 
%end function
end