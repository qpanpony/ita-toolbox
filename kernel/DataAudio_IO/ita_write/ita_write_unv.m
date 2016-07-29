function result = ita_write_unv(varargin)
%ITA_WRITE_UNV - writes data into unv-files
%  This function is the superfunction for all ita_writeunv... functions and 
%  accepts an audioObject and the name of a unv-file as an input argument.
%
%  Syntax:
%   ita_write_unv(audioObjIn, string, options)
%
%   Options (default):
%           'type'      (58)        : determine whether to write response
%                                     per mesh node or response for all mesh 
%                                     nodes per frequency
%           'action'    (replace)   : replace file or add to existing file
%
%  Example:
%   ita_write_unv(audioObjIn,unvFilename)
%   ita_write_unv(audioObjIn,unvFilename,'type',2414)
%   ita_write_unv(audioObjIn,unvFilename,'action','add')
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q, ita_batch_processor, ita_readunv.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_writeunv">doc ita_write_unv</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  29-Sep-2009

%% Initialization and Input Parsing
if nargin == 0 % Return possible argument layout
    result{1}.extension = '*.unv';
    result{1}.comment = 'Universal files (*.unv)';
    return;
end

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

narginchk(2,6);
sArgs        = struct('pos1_data','anything','pos2_unvFilename','string','type',58,'action','replace');
[data,unvFilename,sArgs] = ita_parse_arguments(sArgs,varargin); 

% determine what to write
if isa(data,'itaCoordinates')
    ita_verbose_info([thisFuncStr 'these are (mesh) coordinates, calling ITA_WRITEUNV15'],1);
    ita_writeunv15(data,unvFilename);
elseif isa(data,'itaSuper')
    if sArgs.type == 58
        ita_verbose_info([thisFuncStr 'this is a frequency response, calling ITA_WRITEUNV58'],1);
        ita_writeunv58(data,unvFilename,'action',sArgs.action);
    elseif sArgs.type == 2414
        ita_verbose_info([thisFuncStr 'this is a frequency response, calling ITA_WRITEUNV2414'],1);
        ita_writeunv2414(data,unvFilename,'action',sArgs.action);
    else
        ita_verbose_info([thisFuncStr 'sorry, I cannot write this data (yet)!'],1);
    end
else
    ita_verbose_info([thisFuncStr 'sorry, I cannot write this data (yet)!'],1);
end
result = 1;
%end function
end