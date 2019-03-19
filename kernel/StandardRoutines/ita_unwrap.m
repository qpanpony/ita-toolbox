function varargout = ita_unwrap(varargin)
% Customized unwrap function with more options
%
% INPUT:
%   in:             Input phase function, can be a matrix (no itaAudio)
%   cutoff:         cutoff option of the MATLAB unwrap function - basically gives
%                   you control of the minimum jump distance to perform an unwrap
%                   Default: pi
%   dim:            Dimension to unwrap over - same functionally als MATLAB unwrap
%                   Default: 1
%   'align' (1)             
%   'refZeroBin':     Referenz bin, which is used for the alignment near to 0°
%   (additional)    Default: Bin 2, as bin 1 often is a little off 
%   'unwrap_range':   Restrict the unwrapping to a specific range
%   (additional)    Default: [inf,-inf]
%                   Useful values: e.g. [0,-2pi] for causal systems
%   'allowInvert':    Allow inverting. Corresponds to additional 180° shift,
%   (additional)    to wrap nearer to 0°
%                   Default: false
%
%
%
% OUTPUT:
%   out:            Unwrapped phase data

% Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
% Created:  21-Jan-2019
% TODO:
% - implement smoothing for unwrapping?
%   'useSmoothing'  Uses a smoothed version of the phase to determine the
%                   frequencies when to unwrap
%                   Possible values: 'lin','log'
%                   Default: 'none'
%                   see ita_smooth
% - Apply AlignPhase to arbitrary dimension
% - ! generate single channel reference by exp. weighting - causal cepstrum (for all zeros inside the unit circle)


%% get inputs and set defaults
sArgs = struct('pos1_data1','numeric','cutoff',pi,'dim',1,'align',1,'refZeroBin',-1,'unwrap_range',[inf,-inf],'allowInvert',false);
[data1,sArgs] = ita_parse_arguments(sArgs, varargin);

    %% unwrap and align
    if sArgs.align
        [phase_aligned] = AlignPhase_Local(data1, 1, sArgs.cutoff, sArgs.dim); % what about other dimensions
%         [phase_aligned] = AlignPhaseExpWeight_Local(data1, 1, sArgs.cutoff, sArgs.dim, 0.01, 48000, 'LinTimeSec');

        if sArgs.dim ~= 1
           error('not implemented yet') 
        end
    end


    %% align with reference bin
    if sArgs.refZeroBin > 0
        phase_aligned = applyFuncToDim(@LocalShift,phase_aligned,sArgs.dim,sArgs.refZeroBin);
    end

    %% allow Inversion if desired
    for idy = 1:size(data1,(1-(sArgs.dim-1))+1) % the other dim
        if sArgs.allowInvert
            % substracting pi brings you nearer to 0
            warning('only accepts dimension: signallength x channels')
            if( abs(phase_aligned(sArgs.refZeroBin,idy) - pi) < abs(phase_aligned(sArgs.refZeroBin,idy)) )
                phase_aligned(:,idy) = phase_aligned(:,idy) - pi;
            end
            if( abs(phase_aligned(sArgs.refZeroBin,idy) + pi) < abs(phase_aligned(sArgs.refZeroBin,idy)) )
                phase_aligned(:,idy) = phase_aligned(:,idy) + pi;
            end
        end
    end

    %% wrap the unwrap to a self chosen range
    if(~any(isinf(sArgs.unwrap_range))) % check if none of the ranges are inf % TODO implement when only when side is restricted
        dist = abs(diff(sArgs.unwrap_range));
        lift = max(0,-min(sArgs.unwrap_range));
        phase_aligned = mod(phase_aligned+lift,dist)-lift;
    end


%% assign output
varargout{1} = phase_aligned;

% figure;plot(data1(:,1,1));hold all;plot(phase(:,1,1));plot(phase_aligned(:,1,1))
end

%% subfunction



function out = LocalShift(in, refZeroBin)

if(nargin<2)
    refZeroBin = 2;
end

%adjust phase start value
shift = round(in(refZeroBin)/(2*pi)); % take second value, because first one is something off
% shift = shift + (out(2,:) > 0);
out = in - repmat(shift*2*pi,size(in,1),1);
% H_list_phase = H_list_phase - cumsum(diff([H_list_phase(1,:);H_list_phase]) > 2.5)*pi; % optional correction of jumps

end

function [ q ] = applyFuncToDim( func, p, dim, extraArgs )
ni = nargin;
if ni<4
    extraArgs = [];
end

% Treat row vector as a column vector (unless DIM is specified)
rflag = 0;
if ni<3 && isrow(p)
   rflag = 1; 
   p = p.';
end

% Initialize parameters.
nshifts = 0;
perm = 1:ndims(p);
switch ni
case 1
   [p,nshifts] = shiftdim(p);
   cutoff = pi;     % Original UNWRAP used pi*170/180.
case 2
   [p,nshifts] = shiftdim(p);
otherwise    % nargin == 3
   perm = [dim:max(ndims(p),dim) 1:dim-1];
   p = permute(p,perm);
end
   
% Reshape p to a matrix.
siz = size(p);
p = reshape(p, [siz(1) prod(siz(2:end))]);

% Unwrap each column of p
q = p;
for j=1:size(p,2)
   % Find NaN's and Inf's
   indf = isfinite(p(:,j));
   % Unwrap finite data (skip non finite entries)
   q(indf,j) = func( p(indf,j), extraArgs );
end

% Reshape output
q = reshape(q,siz);
q = ipermute(q,perm);
q = shiftdim(q,-nshifts);
if rflag
   q = q.'; 
end

end


function p = LocalUnwrap(p,cutoff) 
%LocalUnwrap   Unwraps column vector of phase values.
% based on MATLAB code - SL

m = length(p);

% Unwrap phase angles.  Algorithm minimizes the incremental phase variation 
% by constraining it to the range [-pi,pi]
dp = diff(p,1,1);                % Incremental phase variations

% Compute an integer describing how many times 2*pi we are off:
% dp in [-pi, pi]: dp_corr = 0,
% elseif dp in [-3*pi, 3*pi]: dp_corr = 1,
% else if dp in [-5*pi, 5*pi]: dp_corr = 2, ...
dp_corr = dp./(2*pi);

% We want to do round(dp_corr), except that we want the tie-break at n+0.5
% to round towards zero instead of away from zero (that is, (2n+1)*pi will
% be shifted by 2n*pi, not by (2n+2)*pi):
roundDown = abs(rem(dp_corr, 1)) <= 0.5;
dp_corr(roundDown) = fix(dp_corr(roundDown));

dp_corr = round(dp_corr);

% Stop the jump from happening if dp < cutoff (no effect if cutoff <= pi)
dp_corr(abs(dp) < cutoff) = 0;

% Integrate corrections and add to P to produce smoothed phase values
p(2:m,:) = p(2:m,:) - (2*pi)*cumsum(dp_corr,1);
end


function [PhaseAligned] = AlignPhaseExpWeight_Local(Phase, doUnwrap, cutoff, dim, tau, fs, warpType)
%ALIGNPHASEEXPWEIGHT Align phase of multiple transfer functions to minimize the
%Euclidean distance for each frequency bin.
% Wrapper for ALIGNPHASE
% Introduces additional exponential time-domain smoothing for every
% channels
%
%   'input':    'Phase' matrix of phase functions
%               'doUnwrap' (default: 1) true if phase should be unwrapped
%               'cutoff' (default: []) tolerance for unwrapping jumps
%               'dim' (default: 1) dimension to that the unwrap is applied
%               'tau' (10): control the exponential time weighting
%               'warpType' ('LinTimeSec'): weighting done with warping? 'LinTimeSec' or 'LogFreqOctave1'
%   'output':   'PhaseAligned' matrix with aligned phase functions

%  Author: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Created:  16-Mar-2019

warning('requires twosided phase response')

if nargin < 2
    doUnwrap = 1;
end
if nargin < 3
    cutoff = [];
end
if nargin < 4
    dim = 1;
end
if nargin < 5
    tau = 10;
end
if nargin < 6
    warning('Assuming fs=1')
    fs = 1;
end
if nargin < 7
    warpType = 'LinTimeSec';
end
PhaseAligned = zeros(size(Phase));

% construct phase transfer function (allpass)
phaseTF = 1 * exp(1i*Phase);
phaseIR = ifft(phaseTF);

% do exponential weighting in the time domain
for idCh = 1:size(phaseTF,2)
    phaseIR_expWeight = exp_weighting_time(phaseIR(:,idCh),fs,tau,warpType);
    phaseTF_expWeight = fft(phaseIR_expWeight);
    phase_expWeight = angle(phaseTF_expWeight);
    phaseToAlign = [Phase(:,idCh),phase_expWeight]; %combine with exponentially smoothed version
    AlignResult = AlignPhase_Local(phaseToAlign, doUnwrap, cutoff, dim); % what about other dimensions
    PhaseAligned(:,idCh) = AlignResult(:,1); % second channel is the exponentially weighted
end
AlignResultOrig = AlignPhase_Local(Phase, doUnwrap, cutoff, dim); % what about other dimensions
 
id=1;figure;hold all;plot(Phase(:,id));plot(PhaseAligned(:,id));plot(AlignResultOrig(:,id));set(gca,'XScale','log');legend('Wrapped','ExpAligned','Aligned');

id=1;figure;hold all;plot(Phase);plot(PhaseAligned);set(gca,'XScale','log');


end

function [PhaseAligned] = AlignPhase_Local(Phase, doUnwrap, cutoff, dim)
%ALIGNPHASE Align phase of multiple transfer functions to minimize the
%Euclidean distance for each frequency bin.
%   'input':    'Phase' matrix of phase functions
%               'doUnwrap' (default: 1) true if phase should be unwrapped
%               'cutoff' (default: []) tolerance for unwrapping jumps
%               'dim' (default: 1) dimension to that the unwrap is applied
%   'output':   'PhaseAligned' matrix with aligned phase functions

%  Author: Johannes Fabry (IKS) -- Email: fabry@iks.rwth-aachen.de
%  Created:  01-Aug-2018
%  Modified by: Stefan Liebich (IKS) -- Email: liebich@iks.rwth-aachen.de
%  Created:  15-Mar-2019

if nargin < 2
    doUnwrap = 1;
end
if nargin < 3
    cutoff = [];
end
if nargin < 4
    dim = 1;
end

% handle NaN
Phase(isnan(Phase)) = 0;
Phase(isinf(Phase)) = 0;

% Get size
numBins = size(Phase, 1);
numPaths = size(Phase, 2);

% Initialize
meanMinVar = zeros(numBins, 1);

% Find mean value for minimum variance
for i = 1:numBins
    possibleMeans = median(Phase(i, :)) + pi/numPaths * (-numPaths:numPaths-1)';
    
    minVar = inf;
    minIndex = 0;
    
    % Calculate minimum variance for all possible mean values
    for j = 1:length(possibleMeans)
        dPhase = Phase(i, :) - possibleMeans(j);
        PhaseTmp = Phase(i, :) - round(dPhase / (2*pi)) * 2*pi;
        
        curVar = var(PhaseTmp, 1);

        % Is minimum variance?
        if curVar < minVar
            minVar = curVar;
            minIndex = j;
        end
    end
    
    % Save mean value which gives minimum variance
    meanMinVar(i) = possibleMeans(minIndex);
end

% Center around zero
% meanMinVar = meanMinVar - round(meanMinVar / (2*pi)) * 2*pi;

% Apply k*2*pi offset around mean value to obtain phase alignment
dPhase = Phase - meanMinVar;
PhaseAligned = Phase - round(dPhase / (2*pi)) * 2*pi;

% Wrap/unwrap correction
if doUnwrap
    % Unwrap phase
    dMeanPhase = diff(mean(PhaseAligned, 2));
    phaseOffset = cumsum(round([0; dMeanPhase] / (2*pi)) * 2*pi);
    PhaseAligned = PhaseAligned - repmat(phaseOffset, [1, numPaths]);
else
    % Center around zero
    meanPhase = mean(PhaseAligned, 2);
    phaseOffset = round(meanPhase / (2*pi)) * 2*pi;
    PhaseAligned = PhaseAligned - repmat(phaseOffset, [1, numPaths]);
end


end

