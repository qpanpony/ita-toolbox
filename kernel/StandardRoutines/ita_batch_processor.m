function ita_batch_processor(varargin)
%ITA_BATCH_PROCESSOR - Runs a task for several files
%  This function runs a batch script on a specified folder. Your batch
%  script m-File should work on a variable labeled data of type itaAudio.
%  The ita_batch_processor loads the audio files consecutively and saves
%  the audio object in the variable 'data'. After calling your script the
%  variable data should contain the processed data. Afterwards the data is
%  saved unter the same filename inside a different folder specified. If no
%  folder is specified the subfolder 'batch_processor' will be created and
%  used.
%
%  Syntax:
%   audioObjOut = ita_batch_processor(script_name.m, options)
%
%   Options (default):
%           'filemask' ('*.ita') :                              only use these files
%           'inputfolder' (cd)   :                              use files in this folder
%           'outputfolder'([cd filesep 'batch_processor']) :    save processed files here
%
%  Example:
%   ita_batch_processor('testBatchScript.m','filemask','measurement*.ita')
%
%   See also: ita_compile_developer, ita_wavread_continuous.m, ita_generate_documentation, ita_measurement_sensortypes, ita_measurement_sensortypes, ita_portaudio_deviceID2struct, ita_portaudio_string2deviceID, ita_demosound, play, ita_casa, ccx_plot, ita_hrtf_conv, ita_hrtf_get, ita_binaural_diffuse_rir, ita_hrtf_loadinmemory, ita_coherence_time, ita_italian_setup, ita_sort_channels, ita_split_frequencies, ita_freqfromchannelname, ita_inverse_sweep, ita_parametric_GUI, ita_measurement_getlatency, ita_reduce_spk, ita_kundt_gui, ita_measurement_impedance_with_robo, ita_toolbox_path, ita_guisupport_getworkspacelist, ita_main_window, ita_getfrombase, ita_write_gui, ita_guisupport_domainlist, ita_guisupport_currentdomain, ita_clear_workspace, ita_parse_arguments_gui, ita_kundt_gui, ita_kundt_run, ita_kundt_setup, ita_kundt_calc, ita_kundt_save, ita_menucallback_KundtsTube, mf, ita_menucallback_Rememberwindowposition, ita_menucallback_Rememberwindowposition, ita_menucallback_Portaudio, test_its_parse_arguments_gui, ita_quantize_gui, ita_metainfo_GUI, ita_guisupport_audiolistdialog, ita_measurement_calibration, ita_frequency_dependent_time_window, ita_measurement_hammer, ita_blockwise_processing, ita_menucallback_Normalize, ita_extract, ita_plottools_colormap, ita_upcontrol_cutting_phase, ita_pitch_shift, ita_upcontrol_split_frequency_bands, ita_freq2bin, ita_double, ita_decimate_spk, ita_upcontrol_exp_average, ita_upcontrol_draw_cutting_line, ita_ANSI_center_frequencies, ita_plottools_change_font_in_eps, ita_kurtosis, ita_roomacoustics_uncertainty, ita_pointsource_p2Q.
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_batch_processor">doc ita_batch_processor</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  07-Sep-2009

%% Get ITA Toolbox preferences and Function String
thisFuncStr  = [upper(mfilename) ':'];          %Use to show warnings or infos in this functions

%% Initialization and Input Parsing
narginchk(0,10);

if nargin == 0
   ita_batch_processor_GUI(); 
   return;
end

sArgs        = struct('pos1_scriptname','char','inputfolder',pwd,'outputfolder','','filemask','*.ita','saveformat','ita','endtime','false');
[scriptname,sArgs] = ita_parse_arguments(sArgs,varargin);

%% check input folder
if ~exist(sArgs.inputfolder,'dir')
    error([thisFuncStr 'Input folder not valid: ' sArgs.inputfolder])
end
% cd(sArgs.inputfolder)
if isempty(sArgs.outputfolder)
    sArgs.outputfolder = [sArgs.inputfolder filesep 'batch_processor'];
end

%% check output folder
if ~exist(sArgs.outputfolder,'dir')
    mkdir(sArgs.outputfolder)
end

%% check for m-file
if ~(exist(scriptname,'file'))
    error([thisFuncStr 'Script does not exist or is not in Matlab path'])
end
ita_verbose_info(['Using Script ' which(scriptname) '.'],1)

%% input filelist
filelist = dir([sArgs.inputfolder filesep sArgs.filemask]); %please no ls in here

if isempty(filelist)
    ita_verbose_info([thisFuncStr 'Sorry, there are no file to be processed in this folder.'],0);
    return;
end
showEndTime = sArgs.endtime;
if numel(filelist) > 100
    showEndTime = true;
    if numel(filelist) > 1000
        showInterval = round(numel(filelist) / 200);
    else
        showInterval = 10;
    end
    tic
end

persistent result

for idx = 1:numel(filelist);
    disp(['  Processing file ' num2str(idx) ' of ' num2str(size(filelist,1))]);
    filename = filelist(idx).name;
    [dirname filename_raw fileext] = fileparts(filename); %#ok<NASGU>
    filename_abs = [sArgs.inputfolder filesep filename];
    % load
    data = ita_read(filename_abs);
    
    % call batchfile
    run(which(scriptname))
    
    % save
    ita_write(data,[sArgs.outputfolder filesep filename_raw '.' sArgs.saveformat],'overwrite');
    
    
    if sArgs.endtime || showEndTime
        if sArgs.endtime || isnatural(idx/showInterval) || idx == 2
            disp([num2str(toc/60/idx * (numel(filelist) - idx)) ' minutes remaining']);
        end
    end
    
    
end

assignin('base','result',result)

%% Finished
disp('*** batch processing completed successfully ***')


%end function
end