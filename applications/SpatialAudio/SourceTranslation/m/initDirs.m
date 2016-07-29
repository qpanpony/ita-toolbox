function dirs = initDirs(params);
% Author: Noam Shabtai
% Institution of Technical Acoustics 
% RWTH Aachen University,
% 15.10.2013
%

% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

% params = initDirs(params)
% Initialize directories and file names.
%
% Input Parameters:
%   params -
%           Configured and initialized input parameters.
%
% Output Parameters:
%   dirs - 
%           Struct of directories and file names.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cancel warning of mkdir.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off MATLAB:MKDIR:DirectoryExists

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define parent directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parent_dir = setParentDir;
dirs.parent_dir = parent_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define slash according to operating system.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[slash, home_dir] = setSlash;
dirs.slash = slash;
dirs.home_dir = home_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define database dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
database_dir = '/media/database';
dirs.database_dir = database_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define musical instruments directivity dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cube_dir = params.fft.cube_dir;
cube_dir = [cube_dir, slash, params.cube.mode];
cube_filename = [params.mode.instrument, '_et_' params.mode.volume];
dirs.cube_dir = cube_dir;
dirs.cube_filename = cube_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define microphone directivity dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mic_dir = 'surrounding_micarray_singleMic';
dirs.mic_dir = mic_dir;
mic_filename = 'surrounding_micarray_singleMic_windowedCrop.h5';
dirs.mic_filename = mic_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define mat dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mat_dir = 'mat';
mkdir(parent_dir, mat_dir);
if params.mode.simulated_cnm
    mode = 'simulated_cnm';
else
    mode = 'measured_p';
end
mat_dir = [mat_dir, slash, mode];
mkdir(parent_dir, mat_dir);
dirs.mat_dir = mat_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define filnename pattern
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if params.mode.simulated_cnm
    filename_pattern = params.mode.simulated_case;
    if params.source.freq_dep_loc
        filename_pattern = [filename_pattern, '_freq_dep_loc'];
    end
    filename_pattern = [filename_pattern, '_Nc_', num2str(params.source.N)];
    filename_pattern = [filename_pattern, '_Narray_', num2str(params.array.N)];
else
    filename_pattern = cube_filename;
    if params.mode.compensate_for_mic_directivity
        filename_pattern = [filename_pattern, '_mic_directivity'];
    end
    filename_pattern = [filename_pattern, '_tone_', num2str(params.fft.tone_index)];
end
dirs.filename_pattern = filename_pattern;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define reference_p filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reference_p_filename = 'reference_p';
reference_p_filename = [reference_p_filename, '_', filename_pattern];
dirs.reference_p_filename = reference_p_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define translate filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
translate_filename = 'translate';
translate_filename = [translate_filename, '_', filename_pattern];
dirs.translate_filename = translate_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define sampling filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sampling_filename = 'sampling';
sampling_filename = [sampling_filename, '_', filename_pattern];
dirs.sampling_filename = sampling_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define interp_after_sampling filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interp_after_sampling_filename = 'interp_after_sampling';
interp_after_sampling_filename = [interp_after_sampling_filename, '_', filename_pattern];
dirs.interp_after_sampling_filename = interp_after_sampling_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define microphone filter filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mic_filter_filename = 'mic_filter';
mic_filter_filename = [mic_filter_filename, '_', filename_pattern];
dirs.mic_filter_filename = mic_filter_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define microphone-directivity compensated signal filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mic_compensate_filename = 'mic_compensate';
mic_compensate_filename = [mic_compensate_filename, '_', filename_pattern];
dirs.mic_compensate_filename = mic_compensate_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define slide_source filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
slide_source_filename = 'slide_source';
slide_source_filename = [slide_source_filename, '_', filename_pattern];
dirs.slide_source_filename = slide_source_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define errors filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
errors_filename = 'errors';
errors_filename = [errors_filename, '_', filename_pattern];
dirs.errors_filename = errors_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define normalized errors filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
norm_err_filename = 'norm_err';
norm_err_filename = [norm_err_filename, '_', filename_pattern];
dirs.norm_err_filename = norm_err_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define results filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
results_filename = 'results';
results_filename = [results_filename, '_', filename_pattern];
dirs.results_filename = results_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define RAVEN results filename
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
raven_results_filename = 'raven';
raven_results_filename = [raven_results_filename, '_', filename_pattern];
dirs.raven_results_filename = raven_results_filename;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define eps dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
eps_dir = 'eps';
mkdir(parent_dir, eps_dir);
dirs.eps_dir = eps_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define jpg dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
jpg_dir = 'jpg';
mkdir(parent_dir, jpg_dir);
dirs.jpg_dir = jpg_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define fig dir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fig_dir = 'fig';
mkdir(parent_dir, fig_dir);
dirs.fig_dir = fig_dir;
