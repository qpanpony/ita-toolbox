function varargout = ita_decimate_spk(varargin)
%ITA_DECIMATE_SPK - Decimate in Frequency domain
%  This function processes data similar to pitch shifting. Compress in
%  frequency domain.
%
%  Syntax:
%   audioObj = ita_decimate_spk(audioObj)
%
%  Example:
%   audioObj = ita_decimate_spk(audioObj)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_decimate_spk">doc ita_decimate_spk</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  22-Jul-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(2,2);
sArgs        = struct('pos1_data','itaAudioFrequency','pos2_dec','int');
[result,dec_factor,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% Decimation in Frequency domain
sr    = result.samplingRate;
nBins = result.nBins;

gdly = ita_groupdelay(result);
gdly = gdly(:,1:dec_factor:nBins) / 2;

bin_dist  = result.samplingRate ./ (2 .* (result.nBins - 1));

%reconstruct old phase
phase_rec =  [0 cumsum(gdly(:,2:end-1),2) 0] *(bin_dist * dec_factor * 2*pi);
comp_phase = exp(1i * phase_rec );


result.data = result.data(1:dec_factor:nBins,:) .* comp_phase.';
result.samplingRate = sr / dec_factor;

%% Add history line
result.header = ita_metainfo_add_historyline(result.header,mfilename,varargin);

%% Check header
%result = ita_metainfo_check(result);

%% Find output parameters
    % Write Data
    varargout(1) = {result}; 
%end function
end