function params = configParams()
% Author: Noam Shabtai
% Institution of Technical Acoustics 
% RWTH Aachen University,
% 15.10.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
%
% params = configParams()
% Config input parameters.
%
% Input Parameters:
%   none.
%
% Output Parameters:
%   params - Input parameters of main simulation.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Operation mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.mode.simulated_cnm = false; 
params.mode.instrument = 'git_m';                   % See in ../../DirectivityMeasurementsCalibration/m/configParams.m, params.electrical.alias
params.mode.volume = 'pp';                          % Can be pp (pianissimo) or ff (fortissimo).
params.mode.compensate_for_mic_directivity = false; 
params.mode.sampling_scheme = 'berlin';             % Can be gaussian, berlin.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulated case, can be:
%    monopole, dipole, non_symmetric_dipole or highorder.
%    highorder. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.mode.simulated_case = 'monopole';
params.mode.simulated_order = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of limiting the frequency to which the pattern is centralized
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.mode.limit_frequency_for_centralization = true;
params.mode.max_frequency_for_centralization = 1000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stages:
%   0 - Return before stage.
%   1 - Perform stage with calculation.
%   2 - Load calculated value from file.
%   3 - take values from master tensor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.stages.calculate_reference_p = 1;        % Calculate the reference pressure when the source is in the center.
params.stages.calculate_translation = 1;        % Calculate initial translation of the source.
params.stages.sampling = 1;                     % Sample the translated wave.
params.stages.phase_correction = 0;             % Apply phase correction to sampled data.
params.stages.interpolate_p_after_sampling = 1; % Interpolate sampled pressure function.
params.stages.mic_directivity.extract = 0;      % Extract microhpone directivities to compensate with every assumed postion of the source.
params.stages.mic_directivity.compensate = 0;   % Compensate with every assumed postion of the source.
params.stages.slide_source = 0;                 % Slide the position of the source and calculate errors.
params.stages.errors.calculate = 0;             % Calculate the error for each assumed position.
params.stages.errors.normalize = 0;             % Calculate the error for each assumed position.
params.stages.output_results = 0;               % Output the resulting directivity.
params.stages.output_results_for_raven = 0;     % Output results to be used on RAVEN software.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display mode: 1 - display, 0 - don't display.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.display.headers = 1;             % Display text headers.
params.display.az_res = 5;              % Resolution of azimuthal display in degrees.
params.display.el_res = 5;              % Resolution of elevation display in degrees.
params.display.p_ref = 0;               % Display reference p(k,th,ph).
params.display.p_trans = 0;             % Display translated p(k,th,ph).
params.display.p_samp.show = 1;         % Display sampled radiation pattern of the source.
params.display.p_samp.k = [1:10];        % Frequency indices to show.
params.display.p_slide = 0;             % Display slided radiation pattern of the source.
params.display.errors.show = 0;         % Display error function of the slided source.
params.display.errors.rows_err_res = 2; % Number of rows to display errors in subplots.
params.display.errors.indices = [...    
                                    2,1,2,3;...
                                    2,2,3,1;...
                                    2,1,3,2;...
%                                    8,1,2,3;...
%                                    8,2,3,1;...
%                                    8,1,3,2;...
                                    4,1,2,3;...
                                    5,2,3,1;...
                                    6,1,3,2;...
%                                    11,1,2,3;...
%                                    12,2,3,1;...
%                                    13,1,3,2;...
                                ];      % Indices and axis of displayed errors.
                                        % First column is the error index.
                                        % Second and third columns form two dimensions. 
                                        % Figure changes with the third dimension on the fourth column.
                                        % Error Index Legend:
                                        %  0-3 = high-order cnm errors J0-J3 from Ben Hagai et al.
                                        %  4 = Shabtai & Vorlaender in x-y
                                        %  5 = Shabtai & Vorlaender in y-z 
                                        %  6 = Shabtai & Vorlaender in x-z 
                                        %  8-10 = J0-J3 with pnm instead of cnm
                                        %  11 = Shabtai & Vorlaender in x-y with cnm instead of pnm
                                        %  12 = Shabtai & Vorlaender in y-z with cnm instead of pnm 
                                        %  13 = Shabtai & Vorlaender in x-z with cnm instead of pnm 
params.display.errors.separate = 0;     % Display each error in one plot
params.display.errors.k = 1:4;        % Frequency indices to show error results for.
params.display.errors.one_dim = 0;
params.display.results.show = 0;            % Display output directivity in baloon plot.
params.display.results.indices = [-1,2,4];  % Indices of error function according which output baloon is displayed. -1 Shows also reference baloon.
params.display.results.separate = 0;        % Display each baloon in one plot
params.display.results.k = 1:10;           % Frequency indices to show error results for.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.fft.maxf = 1e3;          % Maximum analysis frequency [Hz].
params.fft.Q = 4;               % 2^Q points in the FFT.
params.fft.c = 343;             % Speed of sound [m/s] to calculate k from f.
params.fft.tone_index = 1;      % The index of the played tone, applicable if ~params.mode.simulated_cnm. 
params.fft.tone_frequency = [185]; % If not empty, this is the frequency of the fundamental frequency. Then tone_index is set again in initParams.
params.fft.cube_dir = 'cubes';  % Directory of frequency cubes that store the measurements.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of the central source 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.source.N = 6;                    % Highest non-zero harmonic order of c.
params.source.A = 1;                    % Amplitude of simulated radiation pattern.
params.source.loc = [0.40 0.0 0.20];   % Initial location of the source.
params.source.freq_dep_loc = 0;         % 1 for frequency dependent location.
params.source.loc_span = [0.2, 0, 0];   % Center span For frequency dependent location.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of spherical array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.array.N = 4;      % Order of microphone array.
params.array.r = 2;      % Radius of the array.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of source sliding 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.slide.span = [-0.6 -0.6 -0.6; 0.6 0.6 0.6];  % Uncertainty span around the center [Dx,Dy,Dz] [m].
params.slide.delta = [0.05 0.05 0.05];                 % Spatial resolution in this uncertainty span [dx,dy,dz] [m].
params.slide.display_locs = [...
                      0.60 -0.40 -0.00;...
                      0.60 -0.40 -0.20;...
                      0.60 -0.40 -0.40;...
                      ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of error calculateion 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.errors.high_order.Nfirst = 2;              % First orders to take into account in the calculation of J2.
params.errors.direct.rotate_for_each_frquency = 1;% Perform different rotation to each frequency.  
params.errors.display_z = 0;          % Error displayed on x-y plane for these z values.
params.errors.display_y = 0.3;                  % Error displayed on x line for display_z and display_y values.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frequency cube parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.cube.mode = 'spectrum';      % can be spectrum or overtones.
