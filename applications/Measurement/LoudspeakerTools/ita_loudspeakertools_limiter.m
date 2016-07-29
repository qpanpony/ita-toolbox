function varargout = ita_loudspeakertools_limiter(varargin)
%ITA_LOUDSPEAKERTOOLS_LIMITER - performs limiting function for loudspeakers
%  This function uses the thiele-small parameters of a loudspeaker to model
%  its behavior and perform a limitation of an input signal to achieve a
%  given maximum membrane excursion.
%
%  Modeling and limitation are done in time-discrete processing. The
%  block size and limiter settings can be specified with options.
%
%  Syntax:
%   audioObjOut = ita_loudspeakertools_limiter(TSparamIn,audioObjIn, options)
%
%   Options (default):
%           'limit' (Inf)           : limiter threshold
%           'blockSize' (8)         : block size in samples
%           'attackSamples' (48)    : attack duration
%           'holdSamples' (512)     : hold duration
%           'releaseSlope' (50)     : release slope in dB/s
%           'model' ('R_e')         : which loudspeaker model (R_e or none)
%
%  Example:
%   [limiterSignal,limitedExcursion] = ita_loudspeakertools_limiter(TS,input,'limit',3e-3)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_loudspeakertools_limiter">doc ita_loudspeakertools_limiter</a>

% <ITA-Toolbox>
% This file is part of the application LoudspeakerTools for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  23-May-2014


%% Initialization and Input Parsing
sArgs = struct('pos1_TS', 'itaThieleSmall', 'pos2_input', 'itaAudio', 'limit', Inf, 'blockSize', 8, 'attackSamples', 48, 'holdSamples', 512, 'releaseSlope', 50, 'model', 'Re');
[TS, input, sArgs] = ita_parse_arguments(sArgs, varargin);
% possible models: none, Re

fs = input.samplingRate;
blockSize = sArgs.blockSize;
attackSamples = sArgs.attackSamples;
holdThreshold = 10^(-1/20); % 1 dB to limiter threshold
holdSamples = sArgs.holdSamples;
releaseSlope = sArgs.releaseSlope;
% release slope
releaseFactor = releaseSlope*0.02*(10^(50/20/fs)-1);

%% build LS IIR filter from Thiele-Small parameters
% H(z) = X(z)/U(z) = (b0 + b1*z^-1 ...)/(a0 + a1*z^-1 ...)
% x(k)  = b(1)*u(k) + b(2)*u(k-1) + b(3)*u(k-2) + b(4)*u(k-3) - (a(1)*x(k-1) + a(2)*x(k-3) + a(3)*x(k-3))
% coefficients will be normalised by a0

% extract thiele-small parameters
R  = double(TS.R_e);
M  = double(TS.M);
n  = double(TS.n);
m  = double(TS.m);
w  = double(TS.w);

% if enclosure parameters are specified, do the necessary calculations
if ~isempty(TS.n_g)
    n = n*double(TS.n_g)/(n + double(TS.n_g));
end

if ~isempty(TS.w_g)
    w = w + double(TS.w_g);
end

% either no model (limit input voltage) or simple loudspeaker model
switch sArgs.model
    case 'none'
        b = [1 0];
        a = [1 0];
        
    case 'Re'
        omega0 = 1/sqrt(m*n);
        w0 = omega0/(2*fs);
        Qtot = sqrt(m/n)/(w + M^2/R);
        
        a0 = 1 + 1/w0^2 + 1/(w0*Qtot);
        a1 = 2*(1 - 1/w0^2);
        a2 = 1 + 1/w0^2 - 1/(w0*Qtot);
        
        a = [a0 a1 a2]./a0;
        b = M.*n./R.*[1 2 1]./a0;
    otherwise
        error('wrong model type, can only be: none or Re');
end

% how many samples of IIR delay
order = numel(a)-1;

% delay by 1 block size + attack time + order
nBlock = ceil((order+blockSize+attackSamples+input.nSamples)/blockSize);
totalSamples = nBlock*blockSize;
extraSamples = totalSamples - (input.nSamples+attackSamples+blockSize+order);

%% apply to input
% input signal
rawInput            = [zeros(order,1); input.time; zeros(totalSamples - input.nSamples - order,1)];
% input signal shifted by attack time (+ 1 block size + order)
shiftedInput        = [zeros(order+blockSize+attackSamples,1); input.time; zeros(extraSamples,1)];
% calculated limiter signal
limiterSignal       = ones(size(shiftedInput));
% input limited by previous limiter value
limitedInput        = zeros(size(shiftedInput));
% output calculated with limited input
limitedOutput       = zeros(size(shiftedInput));
% limiter applied to shifted input
limitedShiftedInput = zeros(size(shiftedInput));
% output calculated with limited shifted input
limitedShiftedOutput = zeros(size(shiftedInput));

lastPeakRel = 0;
gainReductionFactor = 1; % defines attack slope
% timers
attackTimer = 0;
holdTimer = 0;
% duration of release period (determined by current output)
releaseSamples = 0;
filterStates = zeros(order,1);
filterStatesShifted = zeros(order,1);
tmpLimiter = ones(blockSize,1);

for iBlock = 1:nBlock
    sampleIdxLin = min(order + (1:blockSize) + (iBlock-1)*blockSize,totalSamples);
    
    if ~isinf(sArgs.limit)
        % get limiter state from last block and limited signal ...
        lastLimiterValue = tmpLimiter(end);
        limitedInput(sampleIdxLin) = lastLimiterValue.*rawInput(sampleIdxLin);
        % ... and use it to calculate displacement
        [limitedOutput(sampleIdxLin),filterStates] = filter(b,a,limitedInput(sampleIdxLin),filterStates);
        % now determine limiter for current displacement
        peakRel = max(abs(limitedOutput(sampleIdxLin)))/sArgs.limit;
        
        tmpLimiter = ones(blockSize,1);
        % get a dynamic release factor
        releaseFactorDyn = 1 + releaseFactor;
        
        % only if new peak is observed
        if peakRel > 1 && peakRel > lastPeakRel
            lastPeakRel = peakRel;
            gainReductionFactor = peakRel.^(-1/attackSamples);
            % reset timers
            releaseSamples = 0;
            holdTimer   = 0;
            attackTimer = attackSamples;
        end
        
        % attack state
        if attackTimer > 0
            attackSamplesLeft = min(attackTimer,blockSize);
            % apply reduction factor during attack time
            tmpLimiter(1:attackSamplesLeft) = lastLimiterValue.*(gainReductionFactor.^(1:attackSamplesLeft));
            attackTimer = attackTimer - attackSamplesLeft;
            
            % start hold phase in this block
            if attackTimer == 0
                holdTimer = holdSamples - (blockSize - attackSamplesLeft);
                tmpLimiter((attackSamplesLeft+1):blockSize) = tmpLimiter(attackSamplesLeft);
                lastPeakRel = 0;
            end
            % hold state
        elseif attackTimer == 0 && holdTimer > 0
            if peakRel > holdThreshold
                holdTimer = holdSamples;
            end
            holdSamplesLeft = min(holdTimer,blockSize);
            % hold last value during hold time
            tmpLimiter(1:holdSamplesLeft) = lastLimiterValue;
            holdTimer = holdTimer - holdSamplesLeft;
            
            % start release phase in this block
            if holdTimer == 0
                % get current value ...
                releaseVal = min(1,tmpLimiter(holdSamplesLeft));
                % ... and determine release duration
                releaseSamples = ceil(-log(releaseVal)/log(releaseFactorDyn));
                releaseSamplesLeft = min(releaseSamples,blockSize-holdSamplesLeft);
                % apply release factor
                tmpLimiter(holdSamplesLeft+(1:releaseSamplesLeft)) = releaseVal.*(releaseFactorDyn.^(1:releaseSamplesLeft));
                releaseSamples = releaseSamples - releaseSamplesLeft;
            end
        elseif holdTimer == 0 && releaseSamples > 0
            releaseSamplesLeft = min(releaseSamples,blockSize);
            % apply release factor
            tmpLimiter(1:releaseSamplesLeft) = lastLimiterValue.*(releaseFactorDyn.^(1:releaseSamplesLeft));
            releaseSamples = releaseSamples - releaseSamplesLeft;
        end
    end
    
    % limiterSignal is complete
    limiterSignal(sampleIdxLin) = tmpLimiter;
    % now apply to shifted input ...
    limitedShiftedInput(sampleIdxLin) = shiftedInput(sampleIdxLin).*tmpLimiter;
    % ... and get final limited excursion output
    [limitedShiftedOutput(sampleIdxLin),filterStatesShifted] = filter(b,a,limitedShiftedInput(sampleIdxLin),filterStatesShifted);
end

limiter = itaAudio(limiterSignal(:),fs,'time');
limOut = itaAudio(limitedShiftedOutput(:),fs,'time');

%% Add history line
limiter = ita_metainfo_add_historyline(limiter,mfilename,varargin);
limOut = ita_metainfo_add_historyline(limOut,mfilename,varargin);

%% Set Output
varargout(1) = {limiter};
varargout(2) = {limOut};

%end function
end