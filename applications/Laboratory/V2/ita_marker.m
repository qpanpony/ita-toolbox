function varargout = ita_marker(varargin)
%ITA_MARKER - adds markers to lines
%  This function ++++ FILL IN INFO HERE +++
%
%  Syntax:
%   audioObjOut = ita_marker(audioObjIn, options)
%
%   Options (default):
%           'opt1' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_marker(audioObjIn)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_header_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q, ita_batch_processor, ita_randomize_phase, ita_copy_phase, ita_sbs_mean, ita_sbs_std, ita_sbs_align_peaks, ita_sbs_cut_at_zero_crossing, ita_sbs_set_name, ita_sbs_plot_coordinates, ita_plottools_buttonpress_personal, ita_sbs_p_from_v1_v2_v3, ita_sbs_save_bgn_over_time, ita_sbs_splratio_3x3v1, ita_sbs_set_amplitude2zero, ita_sbs_hammer_average, ita_sbs_f2MotorF, ita_sbs_rdir2list, ita_sbs_mean_ratio, ita_sbs_plot_selection.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_marker">doc ita_marker</a>

% <ITA-Toolbox>
% This file is part of the application Laboratory for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


% Author: Matthias Lievens -- Email: mli@akustik.rwth-aachen.de
% Created:  02-Jun-2010 

%% Initialization and Input Parsing
error(nargchk(0,10,nargin,'string'));
sArgs        = struct('linevector',[],'marker','s','markersize',5);
[sArgs] = ita_parse_arguments(sArgs,varargin); 

%% +++Body - Your Code here+++ 'result' is an audioStruct and is given back 

% lines=findobj(gca,'type','line');
lines=getappdata(gca,'ChannelHandles');
if isempty(sArgs.linevector)
	sArgs.linevector = 1:length(lines);
end

for iLine = sArgs.linevector
set(lines(iLine),'marker',sArgs.marker,'markersize',sArgs.markersize)
end


%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    
else
    % Write Data
    varargout(1) = {result}; 
end

%end function
end