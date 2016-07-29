function result = ita_kurtosis(varargin)
%ITA_KURTOSIS - Calculates the kurtosis of a time signal
%  This function calculates the kurtosis of a time signal.
%  If no block length is given, the function calculates the kurtosis of the
%  entire signal. Otherwise it does a moving block kurtosis.
%
%  Syntax:
%   audioObj = ita_kurtosis(audioObj,[block length])
%
%  Example:
%   audioObj = ita_kurtosis(audioObj)
%   audioObj = ita_kurtosis(audioObj,2^10)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_kurtosis">doc ita_kurtosis</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Bruno Masiero -- Email: bma@akustik.rwth-aachen.de
% Created:  04-Jun-2010


%% Initialization and Input Parsing
narginchk(1,2);
blockLength = [];
if nargin == 2
    blockLength = varargin{2};
end

data = varargin{1}; 
if ~isa(data,'itaAudio')
    error('This function requires a itaAudio as input parameter.')
end

if isempty(blockLength)
    aux = kurtosis(data.timeData,1,1);
else
    % do block kurtosis
    aux = floor((blockLength-1)/2);
    blockLength = 2*aux+1;
    expandedData = [data.timeData(end-aux+1:end,:); data.timeData; data.timeData(1:aux,:)];
    aux = zeros(size(data.timeData));
    for idx = 1:data.nSamples
%         aux(idx,:) = kurtosis(expandedData((1:blockLength)+(idx-1),:),1,1);
        x = expandedData((1:blockLength)+(idx-1),:);
        x0 = bsxfun(@minus,x,nanmean(x,1));
        s2 = nanmean(x0.^2,1); % this is the biased variance estimator
        
        aux(idx,:) = x0((blockLength+1)/2,:).^4 ./ s2.^2;
    end
end

result = itaResult();
result.timeData = aux;
result.abscissa = data.timeVector;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

end