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

%% get inputs and set defaults
sArgs = struct('pos1_data1','numeric','cutoff',pi,'dim',1,'refZeroBin',2,'unwrap_range',[inf,-inf],'allowInvert',false);
[data1,sArgs] = ita_parse_arguments(sArgs, varargin);
    
%% main function
fw_test = LocalUnwrap(data1,sArgs.cutoff);
fw = unwrap(data1,sArgs.cutoff,sArgs.dim);

%% align with reference bin
fw_aligned = applyFuncToDim(@LocalShift,fw,sArgs.dim,sArgs.refZeroBin);

%% allow Inversion if desired
for idy = 1:size(data1,(1-(sArgs.dim-1))+1) % the other dim
    if sArgs.allowInvert
        % substracting pi brings you nearer to 0
        warning('only accepts dimension: signallength x channels')
        if( abs(fw_aligned(sArgs.refZeroBin,idy) - pi) < abs(fw_aligned(sArgs.refZeroBin,idy)) )
            fw_aligned(:,idy) = fw_aligned(:,idy) - pi;
        end
        if( abs(fw_aligned(sArgs.refZeroBin,idy) + pi) < abs(fw_aligned(sArgs.refZeroBin,idy)) )
            fw_aligned(:,idy) = fw_aligned(:,idy) + pi;
        end
    end
end

%% wrap the unwrap to a self chosen range
if(~any(isinf(sArgs.unwrap_range))) % check if none of the ranges are inf % TODO implement when only when side is restricted
    dist = abs(diff(sArgs.unwrap_range));
    lift = max(0,-min(sArgs.unwrap_range));
    fw_aligned = mod(fw_aligned+lift,dist)-lift;
end

%% assign output
varargout{1} = fw_aligned;

% figure;plot(data1(:,1,1));hold all;plot(fw(:,1,1));plot(fw_aligned(:,1,1))
end



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
