function varargout = ita_quantize_gui(varargin)
%ITA_QUANTIZE_GUI - GUI for ita_quantize
%  This function prepares a GUI for ita_quantize
%
%  Syntax:
%   audioObj = ita_quantize_gui(audioObj)
%
%  Example:
%   audioObj = ita_quantize_gui(audioObj)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_quantize_gui">doc ita_quantize_gui</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  21-Jun-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
idpList = 1;
pList{idpList}.datatype = 'itaAudio';
pList{idpList}.description = 'pos1_data';
pList{idpList}.default = '';
pList{idpList}.helptext = '';

idpList = idpList + 1;
pList{idpList}.datatype = 'line';

idpList = idpList + 1;
pList{idpList}.datatype = 'double';
pList{idpList}.description = 'bits';
pList{idpList}.default = 24;
pList{idpList}.helptext = 'Number of bits used';

% idpList = idpList + 1;
% pList{idpList}.datatype = 'double';
% pList{idpList}.description = 'intervalls';
% pList{idpList}.helptext = 'Number of intervals';

idpList = idpList + 1;
pList{idpList}.datatype = 'line';

idpList = idpList + 1;
pList{idpList}.datatype = 'itaAudioResult';
pList{idpList}.description = 'Save result as';
pList{idpList}.helptext = 'What name should the result have?';
pList{idpList}.default = 'quantize_result';

pList = ita_parametric_GUI(pList,'Quantize');

result = ita_quantize(pList{1},'bits',pList{2});


%% Add history line
%result.header = ita_metainfo_add_historyline(result.header,mfilename,varargin);

%% Check header
%%result = ita_metainfo_check(result);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_setinbase(pList{3},result)
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end