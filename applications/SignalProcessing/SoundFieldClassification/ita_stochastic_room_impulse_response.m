function [result, all_mirror_sources] = ita_stochastic_room_impulse_response(varargin)
%ITA_BINAURAL_DIFFUSE_RIR - Calculate random impulse response
%  This function will calculate a stochastic binaural impulse response based on the formulas from Kuttruffs 'Room Acoustics'
%
%  Syntax:
%   audioObj = ita_binaural_diffuse_rir(Options)
%
%       Options: (default)
%           hrtf ('')           - HRTF-Database to use, posibilities are: The HRTF itself, the name of an HRTF-Var in your Base-Workspace, or a filename. If no HRTF is specified, an ideal impulse is used
%           sourceposition ()   - Position of source relative to receiver, in itaCoordinates, and in the same orientation as the HRTF
%           alpha               - Average absorption coefficient of the room or itaAudio with specified alpha
%           t60                 - Average t60 of the room or itaAudio with specified reverberation time (e.g. t60 from ita_roomacoustics, or ita_din18041_reverberation_times)
%           'V'                 - Room volume
%           'S'                 - Room surface
%           'm'                 - Air absorption
%           'first_reflection' (-1) - Factor for waylength of first reflection in reference to direct sound (use -1 for auto-mode)
%
%
%
%  Example:
%
% ita_stochastic_room_impulse_response('V',40, 'S',76,'t60',0.1,'sourceazimuth',270)
% ita_stochastic_room_impulse_response('T60',0.8,'V',10000,'sourceposition',itaCoordinates([10 0 0]))
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_binaural_diffuse_rir">doc ita_binaural_diffuse_rir</a>

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Roman Scharrer -- Email: rsc@akustik.rwth-aachen.de
% Created:  11-May-2009


%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions
tic;
dbpath = [ita_preferences('DataPath') filesep 'ITA HRTF Datenbank'];
%% Initialization and Input Parsing
sArgs        = struct('hrtf','','sourceposition',itaCoordinates([1 pi/2 0],'sph'),'dynamic',60,'alpha',[],'alphastd',0.1,'t60',0.2,'v',150,'s',175,'m',0,'first_reflection',-1,'max_reflections_per_second',1000,'memory',300);
sArgs = ita_parse_arguments(sArgs,varargin); 

sArgs.s = max(sArgs.s, 4*pi*(sArgs.v * 3 / (4*pi))^(2/3));

% Try to find the HRTF
hrtf_given = true;
HRTF = [];
if isa(sArgs.hrtf,'itaDirectivity') % Argument is the HRTF
    HRTF = sArgs.hrtf;
end
if isempty(HRTF) && ischar(sArgs.hrtf) && ~isempty(sArgs.hrtf) % try to get from base
    HRTF = ita_getfrombase(sArgs.hrtf);
end
if isempty(HRTF) && ischar(sArgs.hrtf) && ~isempty(which(sArgs.hrtf)) % try to load file
    HRTF = ita_read(sArgs.hrtf);
end
if isempty(HRTF) % Absolutely no HRTF
    ita_verbose_info([thisFuncStr ' No HRTF given, using uniform (impulse) HRTF ' ],0); 
    hrtf_given = false;
    impulse = (ita_mpb_filter(ita_generate('flat',1,44100,10),[20 21000]));
    HRTF = itaDirectivity();
    HRTF.freq = impulse.freq;
    HRTF.directions = itaCoordinates([0 0 0],'cart');
end
sArgs = rmfield(sArgs,'hrtf');

if sArgs.first_reflection < 0
    sArgs.first_reflection = sqrt(1+((2*1.5)^2/sArgs.sourceposition.r^2));
end

%% Ensure frequency domain of HRTF
HRTF = ita_fft(HRTF);
%HRTF.directions = build_search_database(HRTF.directions);
HRTF.dataTypeOutput = HRTF.dataType; % no typecast
precision = HRTF.dataTypeOutput;

%% Copy some vars for better Layout
blocksize = 100; 

nCh = HRTF.nChannels;
fftsize = HRTF.nSamples;
nBins = HRTF.nBins;
fs = HRTF.samplingRate;
HRTF_front_time_delay = ita_groupdelay_ita(HRTF.getNearest(itaCoordinates([1 pi/2 0],'sph')));
HRTF_front_time_delay = mean(mean(HRTF_front_time_delay.freq2value(900:1100)));
if HRTF_front_time_delay < 0
    HRTF_front_time_delay = double(HRTF.trackLength) + HRTF_front_time_delay;
end

c = double(ita_constants('c'));
rho0 = double(ita_constants('rho_0'));

m = sArgs.m;

V = sArgs.v; % Room volume
S = sArgs.s; % Room surface
n = (c*S)/(4*V); % Average number of reflections per second for one ray
n_max = sArgs.max_reflections_per_second;

if isnumeric(sArgs.alpha) && ~isempty(sArgs.alpha)
    alpha = itaAudio;
    alpha.freq = repmat(sArgs.alpha,513,1);
    alpha.freq([1 513],:) = 0.999;
elseif isa(sArgs.alpha,'itaAudio') && ~isempty(sArgs.alpha)
    alpha = sArgs.alpha;
end

if isnumeric(sArgs.t60) && ~isempty(sArgs.t60)
    t60 = itaAudio;
    t60.freq = repmat(sArgs.t60,513,1);
    t60.freq([1 513],:) = 0.001;
elseif isa(sArgs.t60,'itaAudio') && ~isempty(sArgs.t60)
    t60 = sArgs.t60;
end


%% Get alpha and T60
if isempty(sArgs.t60) && isempty(sArgs.alpha)
    error('I need a reverberation time or average absorption coefficient');
elseif isempty(sArgs.t60) && ~isempty(sArgs.alpha)
    t60 = ita_sabine('c',c,'v',V,'m',m,'s',S,'alpha',alpha);
elseif ~isempty(sArgs.t60) && isempty(sArgs.alpha)
    alpha = ita_sabine('c',c,'v',V,'m',m,'s',S,'t60',t60);
else
    error('I need a reverberation time OR average absorption coefficient, not both!');
end

t_soll = max(max(sArgs.dynamic/60*max(t60.freqData)*1.2));
s_soll = t_soll .* fs;

if hrtf_given
    % Make sure alpha and t60 are as long as the HRTF
    t60 = ita_interpolate_spk(t60,log2(fftsize));
    alpha = ita_interpolate_spk(alpha,log2(fftsize));
    alpha = ita_zerophase(alpha);
else
    % Extend all to t_soll
    t60 = ita_interpolate_spk(t60,(log2(s_soll)));
    alpha = ita_interpolate_spk(alpha,(log2(s_soll)));
    HRTF = ita_extend_dat(HRTF,(log2(s_soll)));
end

% Extract spk only
t60 = t60.freqData;
alpha = alpha.freqData;




%% Make sourceposition itaCoordinates
if isnumeric(sArgs.sourceposition)
    sArgs.sourceposition = itaCoordinates(sArgs.sourceposition,'sph');
end

if sArgs.sourceposition.r <= 0
    error('rsc_binaural_diffuse_rir: source distance can''t be smaller or equal zero');
end

%% Some calcultaion to the possible mirror source placement
d_max = max(max(c*sArgs.dynamic/60*t60));
d_min = sArgs.sourceposition.r .* sArgs.first_reflection;
%t_soll = max(max(sArgs.dynamic/60*max(t60)*1.2));
t_return = t_soll./1.2;



%final_rir = zeros(round(max(t_soll*fs)),nCh,precision); %Allocate Memory for result
firstrun = true;


result = itaAudio;
result.samplingRate = HRTF.samplingRate;
result.channelNames = HRTF.channelNames;
result.time = zeros(round(max(t_soll*fs)),nCh);
% [result, HRTF] = ita_extend_dat(result, HRTF);
% HRTF = fft(HRTF);

%% Some more check
if any(~isreal(t60)) || any(~isreal(alpha)) || any(isinf(t60)) || any(isnan(t60)) || any(isinf(alpha)) || any(isnan(alpha))
    %error([mfilename ' Some input is wrong (t60 or alpha)']);
end

result_freqVector = result.freqVector;
HRTF_freqVector = HRTF.freqVector;

final_freq = result.freq;



%% Create random mirror sources
t_limit = mean(sqrt(n_max .* V ./ (4.*pi.*c^3))) + sArgs.sourceposition.r/c;
d_limit = t_limit * c;
d_limit = max(d_limit, d_min);

n_r1 = round(approximate_number_of_reflections(max(t_limit),V,c)); %Total number of reflections in first (exact) part of impulse response
n_r2 = ceil((t_soll-t_limit)*n_max); %Total number of reflections in second (non-exact) part of impulse response
n_r = n_r1+n_r2; % Total number of reflections

% First part (cubic distribution of reflections
distance1 = rand(n_r1,1,'single');
distance1 = distance1.^(1/3);
distance1 = distance1.*(max(d_limit));
distance1(distance1 < d_min) = []; % No reflections prior to direct sound
%distance1 = distance1+d_min;
distance1 = [sArgs.sourceposition.r; distance1];

% Second part (equal distribution)
distance2 = rand(n_r2,1,'single');
distance2 = distance2.*(max(d_max)-d_limit) + d_limit;

distance = [distance1; distance2];

all_level_adjust(1:numel(distance1)) = 1;
all_level_adjust(end+(1:numel(distance2))) = (distance2 ./ d_limit).^1;

n_r = numel(distance);

all_mirror_sources = itaCoordinates(numel(distance)).random;
all_mirror_sources.sph(:,1) = distance;
all_mirror_sources.sph(1,:) = sArgs.sourceposition.sph; %Simply include direct sound on first run
%all_level_adjust(1) = 1; % no level adjust for direct sound
t_direct = all_mirror_sources.r(1)./c; % Save time delay of direct sound, needed for correct 'n*log(1-alpha) * t' calculation


%% Calculate impulse response (in some iterations to save memory)

timeStarted = now;
iterations = ceil(n_r/blocksize);
lastind = 1;
blocksize = floor(n_r / iterations); %True blocksize so same reflections in every block
for idloop = 1:iterations
%     n_r = n_r - blocksize; % Number of reflections left
%     if n_r < 0
%         blocksize = round(blocksize + n_r);
%         n_r = 0;
%     end
%     
    mirror_sources = itaCoordinates(blocksize);
        lastind = (idloop-1)*blocksize+1;

    mirror_sources.sph = all_mirror_sources.sph(lastind+(0:(blocksize-1)),:); %#ok<*PFBNS>
    level_adjust = all_level_adjust(lastind+(0:(blocksize-1)));
    distance = squeeze(mirror_sources.r);
    mirror_sources.r = min(mirror_sources.r,max(HRTF.directions.r));
        
    %% Calculate frequency response
    t = distance./c; %Time delay for each reflection
    thisalpha = bsxfun(@plus,alpha, bsxfun(@times,(randn(size(t.')) .* sArgs.alphastd).^((t.' ./t_direct) ) , alpha) );
    thisalpha = max(min(thisalpha,1),0);
    s_p = bsxfun(@times,bsxfun(@times,(level_adjust)./(c .* t.') .* exp((-m./2.*c.*t.')), exp(bsxfun(@times,(n./2.*(t-t_direct)).',log(1-thisalpha)))),HRTF.getNearestFreqData(mirror_sources)); % H according to rsc@daga2010
    s_p(isnan(s_p)) = 0;
    if hrtf_given
        % Interpolate as HRTF usually has not the necessary resolution
        s_p_2 = zeros([size(result_freqVector,1), size(s_p,2), HRTF.nChannels]) .* (1+1i);
        for idrep = 1:HRTF.nChannels
            s_p_2(:,:,idrep) = interp1(HRTF_freqVector,abs(s_p(:,:,idrep)),result_freqVector,'spline') .* ...
                exp(1i * interp1(HRTF_freqVector,unwrap(angle(s_p(:,:,idrep))),result_freqVector,'spline'));
            %s_p_2(:,:,idrep) = interp1(HRTF_freqVector,(s_p(:,:,idrep)),result_freqVector,'spline');
        end
    else
        s_p_2 = s_p;
    end
    
    % Time shift
    s_p_2 = bsxfun(@times, s_p_2,  exp(-1i.* bsxfun(@times,t.' ,2*pi*result_freqVector)));
    
    % Sum over all reflections
    final_freq = final_freq+squeeze(sum(s_p_2,2));
    time_elapsed = (now - timeStarted)*24*60*60;
    timeleft = (iterations-idloop) * time_elapsed / idloop;
    ita_verbose_info([int2str(floor(timeleft/60/60)) ' h - ' int2str(floor(mod(timeleft/60,60))) ' min - ' int2str(mod(timeleft,60)) 's left'],1);
    %disp(idloop);
end

final_freq(isinf(final_freq) | isnan(final_freq)) = 0;

%% Post-Processing, Keep information
result = itaAudio;
result.domain = 'freq';
result.samplingRate = fs;
result.freqData = final_freq;
result.signalType = 'energy';
result.comment = num2str(mean(t60));
result.channelNames = HRTF.channelNames(1:nCh);
result.channelUnits = HRTF.channelUnits(1:nCh);

resultsamples = ceil(t_return*fs);
resultsamples = resultsamples - mod(resultsamples,2);

result = ita_extract_dat(result,resultsamples);

%% Filter
%result = ita_mpb_filter(result,[20 20000],'zerophase');

%% Keep some information
result.userData{1} = t60;
result.userData{2} = sArgs.sourceposition;

%% Add history line
result = ita_metainfo_add_historyline(result,mfilename,varargin);

%% Find output parameters
if nargout == 0 %User has not specified a variable
    % Do plotting?
    ita_plot_dat(result);
    ita_roomacoustics_EDC(result);
else
end

%end function
end

function n = approximate_number_of_reflections(t_60,V,c)
n = 4/3*pi*c^3*t_60.^3/V;
end
