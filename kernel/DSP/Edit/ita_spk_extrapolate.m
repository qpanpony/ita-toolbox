function varargout = ita_spk_extrapolate(varargin)
%ITA_SPK_EXTRAPOLATE - calculate extrapolation values for frequencydata
%  This function extrapolates your data in frequency domain.
%
%  Syntax:
%   audioObj = ita_spk_extrapolate(audioObj, options)
%   Options (default): 
%    'lower' ([]):          lower limit
%    'lowerslope' (0):      % TODO HUHU Documentation
%    'upper' ([]):          upper limit
%
%  Example:
%   audioObj = ita_spk_extrapolate(audioObj)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_spk_extrapolate">doc ita_spk_extrapolate</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  18-Aug-2009 

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     %#ok<NASGU> Use to show warnings or infos in this functions

%% Initialization and Input Parsing
%narginchk(1,1);
sArgs        = struct('pos1_data','itaAudio','lower',[],'lowerslope',0,'upper',[]);
[data,sArgs] = ita_parse_arguments(sArgs,varargin); 
data = data';

%% Lower Limit
if ~isempty(sArgs.lower)
    freqs = data.freqVector;
    iLow = find(min(sArgs.lower) < freqs,1,'first');
    iHigh = find(max(sArgs.lower) < freqs,1,'first');
    
    spk = data.data(iLow:iHigh,:);
    mabs = mean(abs(spk),1);
    df = (freqs(2)-freqs(1));
    gpdly = -1. / (2*pi) * diff(unwrap(angle(data.data))) / df;
    mgpdly = mean(gpdly(iLow:iHigh,:),1);
    
    newphase = -2*pi*mgpdly;
    newphase = repmat(newphase,iLow,1);
    f = 0:df:(iLow-1)*df;
    f = repmat(f.',1,size(newphase,2));
    
    newphase = newphase .* f;
    
    newphase = newphase - repmat((newphase(end,:) - angle(spk(1,:))),iLow,1);
    
    slope = 10.^(sArgs.lowerslope * (log10(f) - log10(f(end)))/20);
    
    mabs = repmat(mabs,iLow,1) .* slope;
    
    newspk = mabs .* exp(1j * newphase);
    
    
    data.data(1:iLow,:) = newspk;
end

%% Upper Limit
if ~isempty(sArgs.upper)
    %ToDo
    error('Sorry: ToDo');
end

result = data;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
varargout(1) = {result};

%end function
end