function params = initParams(params)
% initParams.m
% Author: Noam Shabtai
% ITA-RWTH, 15.10.2013
%
% <ITA-Toolbox>
% This file is part of the application SourceTranslation for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>
% params = initParams(params, dirs)
% Initialize input parameters.
%
% Input Parameters:
%   params -
%           Configured input parameters,
%               which are the output of configParams.
%
% Output Parameters:
%   params - 
%           Further initialized input parameters.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Operation mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~params.mode.simulated_cnm
    params.mode.sampling_scheme = 'berlin';
end
if params.mode.simulated_cnm & params.mode.compensate_for_mic_directivity
    error('Simulated field does not require microphone directivities. simulated_cnm and mic_directivity cannont both be active.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stages:
%   0 - Return before stage.
%   1 - Perform stage with calculation.
%   2 - Load calculated value from file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~params.mode.simulated_cnm
    params.stages.calculate_reference_p = 0;
end
if ~params.stages.calculate_reference_p
    params.stages.calculate_translation = 0;
end
if ~params.stages.calculate_translation
    params.stages.sampling = 0;
end
if (params.mode.simulated_cnm & ~params.stages.sampling) |...
    params.mode.compensate_for_mic_directivity
    params.stages.interpolate_p_after_sampling = 0;
end
if ~params.mode.compensate_for_mic_directivity
    params.stages.mic_directivity.extract = 0;
end
if ~params.stages.mic_directivity.extract
    params.stages.mic_directivity.compensate = 0;
end
if ~params.stages.interpolate_p_after_sampling & ...
    (params.mode.compensate_for_mic_directivity & ~params.stages.mic_directivity.compensate)
    params.stages.slide_source = 0;
end
if ~params.stages.slide_source
    params.stages.errors.calculate = 0;
end
if ~params.stages.errors.calculate
    params.stages.errors.normalize = 0;
end
if ~params.stages.errors.normalize
    params.stages.output_results = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display mode: 1 - display, 0 - don't display.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~params.stages.calculate_reference_p
    params.display.p_ref = 0;
end
if ~params.stages.calculate_translation
    params.display.p_trans = 0;
end
if ~params.stages.interpolate_p_after_sampling
    params.display.p_samp.show = 0;
end
if ~params.stages.slide_source
    params.display.p_slide = 0;
end
if ~params.stages.errors.normalize
    params.display.errors.show = 0;
end
if ~params.stages.output_results
    params.display.results.show = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate params
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if params.display.headers
    fprintf('Calculate initial params...\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sampling frequency of analysis[Hz].
params.fft.fs = params.fft.maxf * 2;

if params.mode.simulated_cnm
    % Number of points in the FFT of the hrir. 
    params.fft.N = 2^params.fft.Q; 
    % Skip frequency points near DC.
    params.fft.first_fft_ind = 1;
    if params.display.headers
        fprintf('skipping %d points near DC\n', params.fft.first_fft_ind);
    end
    % Create digital frequency range [fft indices k (not wave number)].
    params.fft.fft_range = (params.fft.first_fft_ind : params.fft.N/2) .';
    % f/fs=k/N Create frequency range in [Hz].
    params.fft.f = params.fft.fft_range*params.fft.fs/params.fft.N;  
else
    % Correct array order and radius
    params.array.N = 4;
    params.array.r = 2.1;
    % Load frequencies and spectrum.
    parent_dir = setParentDir();
    cube_dir = fullfile(parent_dir,params.fft.cube_dir,params.cube.mode);
    cube_filename = [params.mode.instrument, '_et_' params.mode.volume];
    load(fullfile(cube_dir,cube_filename));
    % Create shortcuts to long variable names.
    vals = peaks_tensor;
    freqs = measured_freq_matrix(:,:,1);
    % Find valid frequencies.
    valid_freq_ind = find(~isnan(freqs(:,1,1)));
    vals = vals(valid_freq_ind,:,:);
    freqs = freqs(valid_freq_ind,:);
    % Focus on desired tone
    if isempty(params.fft.tone_frequency)
        params.fft.tone_frequency = freqs(params.fft.tone_index,1);
    else
        [dummy,params.fft.tone_index]=min(abs(freqs(:,1)-params.fft.tone_frequency));
    end
    vals = vals(params.fft.tone_index,:,:);
    freqs = freqs(params.fft.tone_index,:);
    % Store frequencies in params.
    params.fft.f = freqs.';
    % Store spectrum values in params.
    params.fft.p = permute(vals,[3,2,1]);
end


% Angular frequency range in [rad/s].
params.fft.w = 2*pi*params.fft.f;                         

% Wave number in [rad * m / sec^2].
params.fft.k = params.fft.w / params.fft.c;% wave number
params.fft.K = length(params.fft.k);        % Num of wave numbers. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate radiation pattern display properties.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grid: [grid.theta, grid.phi] is of size num_angles x 2
% TODO change to gaussian sampling
% TODO ita_sph_sampling_equiangular(order)
% TODO Fraz Zotter Disertation (samplint efficiency)
% TODO Hyperinterpolation. 
params.display.grid = ita_generateSampling_equiangular(...
                                    params.display.az_res,...
                                    params.display.el_res);
params.display.grid.r = params.array.r;

% Spherical Harmonics: num_angels x (Nc+1)^2.
params.display.Ynm = ita_sph_base(params.display.grid,...
                                  params.source.N);

% Build up a reverse grid.
th = params.display.grid.theta;
ph = params.display.grid.phi;
params.display.th_sm_pi_div_2_ind = find(th<pi/2);
params.display.th_bg_pi_div_2_ind = find(th>=pi/2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of the central source 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc = params.source.loc;
K = params.fft.K;
freq_loc = repmat(loc, K, 1);
if params.source.freq_dep_loc
    D = params.source.loc_span;
    offset = - repmat(D/2,K,1);
    k_fact = (0:K-1).'/K;
    freq_loc = freq_loc  + offset + k_fact*D;
end
params.source.freq_loc = freq_loc;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch params.mode.sampling_scheme
case 'gaussian'
    params.array.grid = ita_sph_sampling_gaussian(params.array.N);
case 'berlin'
    params.array.N = 4;
    params.array.grid = ita_sph_sampling_mic32berlin(params.array.N);
end
params.array.mics = params.array.grid.nPoints;  % Number of microphones

% Spherical Harmonics: num_angels x (Narray+1)^2.
params.array.Ynm = ita_sph_base(params.array.grid,...
                                params.array.N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters that are relative to the center 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
params.center.kr_freqs_x_1 = params.fft.k * params.array.r;  

% Simulated cnm of the source as seen by the array if the source is on the center.
% (Nc+1)^2 x freqs
if params.mode.simulated_cnm
    cnm = zeros((params.source.N+1)^2, params.fft.K);
    switch params.mode.simulated_case
    case 'monopole'
        cnm(1,:) = i.*params.fft.k*params.source.A;
    case 'dipole'
        cnm(1,:) = 1;
        cnm(3,:) = 5;
    case 'non_symmetric_dipole'
        cnm(1,:) = 1;
        cnm(2,:) = 3;
        cnm(4,:) = 5;
    case 'highorder'
        n = 0 : params.mode.simulated_order;
        cnm(n.^2+n+1,:) = 1;
    case 'non_symmetric_highorder'
        n = 1 : (params.mode.simulated_order+1)^2;
        cnm(n,:) = repmat(n.',1,params.fft.K);
    otherwise
        error('no such simulation case');
    end
    params.center.cnm = cnm;
end

%   Matrix H for constant r, disPoints x (Nc+1)^2 x freqs.
hn_freqs_x_N = ita_sph_besselh([0:params.source.N], 1, params.center.kr_freqs_x_1);
hn_freqs_x_NMs = ita_sph_extend_n_to_nm(hn_freqs_x_N, 2);
Ynm = params.display.Ynm;
K = params.fft.K;
nPoints = params.display.grid.nPoints;

for k_ind = 1 : K
    H(:,:,k_ind) = repmat(hn_freqs_x_NMs(k_ind,:),nPoints,1) .* Ynm;
end
params.center.hn_freqs_x_NMs = hn_freqs_x_NMs;
params.center.H = H;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of source slide
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
locs = [];
D = params.slide.span;
d = params.slide.delta;
for x = D(1,1) : d(1) : D(2,1)
    for y = D(1,2) : d(2) : D(2,2)
        for z = D(1,3) : d(3) : D(2,3)
            locs = [locs; x, y, z];
        end
    end
end
params.slide.locs = locs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters of error function 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = (0:params.array.N)';
n = ita_sph_extend_n_to_nm(n,1);
params.errors.high_order.n = n;
