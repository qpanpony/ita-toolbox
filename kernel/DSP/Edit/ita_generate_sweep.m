function varargout = ita_generate_sweep(varargin)
%ITA_GENERATE_SWEEP - Generate nice sweeps for measurements
%  This function generates nice sweeps (lin or exp) used for measurements.
%
%  Syntax:
%   [audioObjOut,sweeprate] = ita_generate_sweep(options)
%
%   Options (default):
%           'fftDegree'    (16):          fftDegree / or number of samples
%           %#jtu: ! minimum value: 8 (if stopmargin 0)
%           'mode'         ('exp'):       'lin' or 'exp'
%           'samplingRate' (44100):       samplingRate
%           'stopMargin'   (0.1):         stopMargin
%           'freqRange'    ([5 20000]):   start and stop frequency
%           'bandwidth'    (2/12):        Extend the frequency range by this bandwidth
%           'phi'          (0)            constant phase offset of the sweep signal
%           'sweeprate'    ([])           generate a sweep with a fixed sweep rate instead of a fixed time duration, 
%                                         consequently, no fftDegree needs to be specified (was ita_generate_exact_sweep)
%           'novakround'   (false)        generate a sweep as proposed by Antonin Novak (was ita_generate_sweep_novak)
% 
%  Example:
%   audioObjOut = ita_generate_sweep()
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_generate_sweep">doc ita_generate_sweep</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Pascal Dietrich -- Email: pdi@akustik.rwth-aachen.de
% Created:  20-Apr-2011

% Marco Berzborn 04/2015: Merged ita_generate_sweep_novak and 
%                         ita_generate_exact_sweep into this function. 

%% Initialization and Input Parsing
sArgs   = struct('mode',         'exp',...
                 'fftDegree',    ita_preferences('fftDegree'),...
                 'samplingRate', ita_preferences('samplingRate'),...
                 'stopMargin',   0.1,...
                 'freqRange',    [5 20000],...
                 'bandwidth',    2/12,...
                 'sweeprate',    [],...
                 'phi',          0,...
                 'novakround',   false,...
                 'gui',          false);
[sArgs] = ita_parse_arguments(sArgs,varargin);

if ~isempty(sArgs.sweeprate) && sArgs.novakround
    ita_verbose_info('The options sweeprate and novakround cannot be used simultaneously!',0);
    varargout{1} = [];
    varargout{2} = [];
    return;
end

%% generate automatic gui
if sArgs.gui
    sArgs.varname = 'outputVariableName';
    [sArgs] = ita_parse_arguments_gui(sArgs);
    if isempty(sArgs) % user has cancelled
        ita_verbose_info('Operation cancelled by user',1);
        return;
    end
end

%%
switch lower(sArgs.mode)
    case {'lin','linear'}
        methodStr = 'linear';
    case {'exp','exponential','log','logarithmic'}
        methodStr = 'exponential';
    otherwise
        ita_verbose_info('I do not know this type of sweep signal!',0)
        varargout{1} = [];
        varargout{2} = [];
        return;
end

% include bandwidth constraints
f1 = sArgs.freqRange(1)*2^(-sArgs.bandwidth);
f2 = min(sArgs.freqRange(2)*2^(sArgs.bandwidth),sArgs.samplingRate/2);

% check lower bound
if sArgs.freqRange(1) <= 1e-6
    ita_verbose_info('The lowest frequency has to be greater than 1e-6 ',1);
    sArgs.freqRange(1) = 1e-6 * 2^(sArgs.bandwidth); %bma
end

% nSamples depends on sweep type
% if sweeprate is set use it to generate the sweep signal
if ~isempty(sArgs.sweeprate)
    L = 1/sArgs.sweeprate/log(2);
    T = L*log(f2/f1);
    nSamples = round(T*sArgs.samplingRate);
else
    nSamples   = ita_nSamples(sArgs.fftDegree);
    tmpSamples = nSamples;
    % subtract stop margin samples
    nSamples   = nSamples - round(sArgs.stopMargin.*sArgs.samplingRate./2)*2;
    if nSamples <= 0;
        ita_verbose_info(['Stop margin is too long. Maximum is ' num2str(tmpSamples ./ sArgs.samplingRate) '.'],0);
    end
end 


%% generate sweep and settings for itaAudio
audioObj = itaAudio;
audioObj.samplingRate = sArgs.samplingRate;
audioObj.nSamples    = nSamples;

% decide between linear and exponential sweep
switch methodStr
    case 'linear'
        % chirp function in matlab uses a cosine sweep
        sArgs.phi = sArgs.phi - 90;
        audioObj.timeData = chirp(audioObj.timeVector,f1,audioObj.timeVector(end),f2,methodStr,sArgs.phi);
        sweeprate = [];
    case 'exponential'
        if sArgs.novakround
            L =  round(f1*audioObj.timeVector(end)/log(f2/f1))/f1;
            sweeprate = 1/L/log(2);
            nSamples = (L * log(f2/f1)) * sArgs.samplingRate;
            audioObj.nSamples = nSamples;
        elseif ~isempty(sArgs.sweeprate)
            % L has already been used to generate the number of samples
            sweeprate = sArgs.sweeprate;
        else
            L = audioObj.timeVector(end)/log(f2/f1);
            sweeprate = 1/L/log(2);
        end
        % generate the time data of the sweep signal
        audioObj.timeData = sin(2*pi*f1*L .*(exp(audioObj.timeVector/L)-1) + sArgs.phi);
    otherwise 
        ita_verbose_info('I do not know this type of sweep signal!',0)
        return;
end

audioObj.channelNames{1} = sprintf('%s Sweep %1.2f to %1.2f Hz', methodStr,f1,f2);

%% post processing

% CAREFUL smoothing in the end 
high_fade_sample_vec = [-round(100*sArgs.samplingRate/f2 + 2), 0]+audioObj.nSamples;
audioObj             = ita_time_window(audioObj, high_fade_sample_vec, 'samples');

% extend by stopmargin
if ~isempty(sArgs.sweeprate) || sArgs.novakround
    extendSamples = ceil((nSamples + sArgs.stopMargin * sArgs.samplingRate)/2)*2;
else
    extendSamples = ita_nSamples(sArgs.fftDegree);
end

audioObj = ita_extend_dat(audioObj,extendSamples);

% filter to avoid sidelobes above f2
if f2 < sArgs.samplingRate/2
    f2_final = max(min(f2^sArgs.bandwidth,sArgs.samplingRate/2*0.95),f2);
    audioObj = ita_mpb_filter(audioObj,[0 f2_final],'order',14);
end

% normalize data
audioObj = ita_normalize_dat(audioObj);

%% Add history line
audioObj = ita_metainfo_add_historyline(audioObj,mfilename,varargin);

%% Set Output
if sArgs.gui
   ita_setinbase(sArgs.varname,audioObj); 
end
varargout{1} = audioObj;
varargout{2} = sweeprate;
%end function
end