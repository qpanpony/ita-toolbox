function varargout = ita_plottools_colormap(varargin)
%ITA_PLOTTOOLS_COLORMAP - colormap
%  This function creates a colormap... TODO HUHU Documentation
%
%  Syntax:
%   colormap = ita_plottools_colormap('artemis')
%
%  Example:
%   audioObj = ita_plottools_colormap('artemis')
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_plottools_colormap">doc ita_plottools_colormap</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>

% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  16-Jul-2009


%% Initialization and Input Parsing
narginchk(1,1);
sArgs        = struct('pos1_mode','string');
[mode,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioObj and is given back

switch(lower(mode))
    case {'jet', 'hsv' 'hot' 'cool' 'spring' 'summer' 'autumn' 'winter' 'gray' 'invertedgraycolormap' 'bone' 'copper' 'pink' 'lines' 'artemis' 'ita_colormap'}
        result = colormap(mode);
    otherwise
        error('mode is not valid')
end

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    colormap(result)
else
    % Write Data
    varargout(1) = {result};
end

%end function
end