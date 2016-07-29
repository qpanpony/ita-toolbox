function varargout = ita_normxcorr2(varargin)
%ITA_NORMXCORR2 - calculates the normalized 2D cross-correlation
%  This function takes two audio objects and calculates their normalized 2D
%  cross-correlation.
%
%  Syntax:
%   audioObjOut = ita_normxcorr2(audioObj1, audioObj2)
%
%  Example:
%   audioObjOut = ita_normxcorr2(audioObj1,audioObj2)
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q, ita_batch_processor, ita_randomize_phase, ita_copy_phase, ita_errorlog_add, ita_errorlog_show, ita_errorlog_clear, ita_save2workspace, ita_generate_setlist.
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_normxcorr2">doc ita_normxcorr2</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  04-Nov-2009 

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(1,2);
if nargin == 1 % autocorrelation
   varargin = [varargin,varargin]; 
end
    
sArgs        = struct('pos1_data1','itaSuper','pos2_data2','itaSuper');
[data1,data2,sArgs] = ita_parse_arguments(sArgs,varargin); 

%% check consistency
if ~strcmpi(data1.domain,data2.domain) || data1.nBins ~= data2.nBins || prod(data1.dimensions) ~= prod(data2.dimensions)
    error('%sthese objects will not work together!',thisFuncStr);
elseif numel(data1.dimensions) < 2 || numel(data2.dimensions) < 2
    error('%snot enough dimensions for 2D cross-correlation!',thisFuncStr);
elseif numel(data1.dimensions) > 2 || numel(data2.dimensions) > 2
    error('%stoo many dimensions for 2D cross-correlation!',thisFuncStr);    
end

%% some preparations
data1Mat = data1.(data1.domain);
data2Mat = data2.(data2.domain);
Nx = size(data1Mat,2);
Ny = size(data1Mat,3);
doInterpolation = false;
% if the number of sampling points in one direction is even
% the zero shift position will be undefined -> interpolate
if ~mod(Nx,2)
    ita_verbose_info([thisFuncStr 'interpolating to ensure odd number of sampling points'],1);
    doInterpolation = true;
    [x,y] = meshgrid(-(Nx-1)/2:(Nx-1)/2,-(Ny-1)/2:(Ny-1)/2);
    [xi,yi] = meshgrid(-Nx/2:Nx/2,-Ny/2:Ny/2);
    if ~mod(Ny,2)
        Ny = Ny+1;
    end
    Nx = Nx+1;
elseif ~mod(Ny,2)
    ita_verbose_info([thisFuncStr 'interpolating to ensure odd number of sampling points'],1);
    doInterpolation = true;
    [x,y] = meshgrid(-(Nx-1)/2:(Nx-1)/2,-(Ny-1)/2:(Ny-1)/2);
    [xi,yi] = meshgrid(-Nx/2:Nx/2,-Ny/2:Ny/2);
    Ny = Ny+1;
end

% output is itaResult
result = itaResult(data1);
corrMat = zeros(size(data1Mat,1),2*Nx-1,2*Ny-1);

%% calculation
% for each time or frequency sample do the cross-correlation
for i = 1:size(data1Mat,1)
    tmp1Mat = squeeze(data1Mat(i,:,:));
    tmp2Mat = squeeze(data2Mat(i,:,:));
    if doInterpolation
        % splitting re and im for interpolation is safer
        % using *spline for equally space and monotonic xi,yi
        tmp1Mat = interp2(x,y,real(tmp1Mat),xi,yi)+1i.*interp2(x,y,imag(tmp1Mat),xi,yi,'*spline');
        tmp2Mat = interp2(x,y,real(tmp2Mat),xi,yi)+1i.*interp2(x,y,imag(tmp2Mat),xi,yi,'*spline');
    end
    tmp1Mat(~isfinite(tmp1Mat)) = 0;
    tmp2Mat(~isfinite(tmp2Mat)) = 0;
    % the correlation using the builtin matlab function
    corrMat(i,:,:) = normxcorr2(abs(tmp1Mat),abs(tmp2Mat));
end

result.(data1.domain) = corrMat;
result.channelUnits(:) = {'1'};
result.channelNames(:) = {'normalized cross-correlation'};
% store the xy indices, TODO: allow user input?
result.userData = {'x',-(Nx-1):(Nx-1),'y',-(Ny-1):(Ny-1)};

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
% Write Data
varargout(1) = {result};
%end function
end