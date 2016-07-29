function varargout = ita_sph_beamforming(varargin)
%ITA_SPH_BEAMFORMING - perform beamforming in SH domain
%  This function performs beamforming calculations in the SH domain, using
%  either a plane wave or spherical wave model. For the moment only open
%  sphere arrays are considered.
%
%  Syntax:
%   audioObjOut = ita_sph_beamforming(audioObjIn, options)
%
%   Options (default):
%           'c' (defaultopt1) : description
%           'opt2' (defaultopt1) : description
%           'opt3' (defaultopt1) : description
%
%  Example:
%   audioObjOut = ita_sph_beamforming(audioObjIn)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_sph_beamforming">doc ita_sph_beamforming</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved.
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder.
% </ITA-Toolbox>


% Author: Markus Mueller Trapet -- Email: mmt@akustik.rwth-aachen.de
% Created:  10-Mar-2015


%% Initialization and Input Parsing
sArgs        = struct('pos1_data','itaSuper', 'pos2_scanPositions', 'itaCoordinates', 'spatialSampling',[], 'c', ita_constants('c'),'waveType','plane', 'dualLayerFactor',[]);
[input,scanPositions,sArgs] = ita_parse_arguments(sArgs,varargin);

k = 2*pi*input.freqVector/double(sArgs.c);

try
    channelCoordinatesEmpty = isempty(input.channelCoordinates.Y);
catch
    channelCoordinatesEmpty = true;
end

try
    samplingEmpty = isempty(sArgs.spatialSampling.Y);
catch
    samplingEmpty = true;
end

if channelCoordinatesEmpty
    if samplingEmpty
        error('I need a spatial sampling for this to work, either as channelCoordinates or as option');
    else
        s = sArgs.spatialSampling;
        % do not need to waste too much memory
        sArgs.spatialSampling = [];
    end
else
    s = input.channelCoordinates;
    % do not need to waste too much memory
    input.channelCoordinates.Y = [];
end

r1 = mean(s.r);
Nmax = floor(sqrt(input.nChannels)-1);
n = ita_sph_linear2degreeorder(1:(Nmax+1)^2);
[uniqueN,uniqueIdx,uniqueExpansionIdx] = unique(n); %#ok<ASGLU>

%% find ids for scanPositions in the array
% we do not calculate new SH functions but use the ones of the array
nScanPositions = scanPositions.nPoints;
Rscan = scanPositions.r;
Y = ita_sph_base(scanPositions,s.nmax);

%% dual layer or not, calculate array bessel coefficients
if ~isempty(sArgs.dualLayerFactor)
    r2 = r1*sArgs.dualLayerFactor;
    jn1 = ita_sph_besselj(uniqueN,k.*r1);
    jn2 = ita_sph_besselj(uniqueN,k.*r2);
    beta = (1 + sign(abs(jn2) - abs(jn1)))./2;
    jn = (1 - beta).*jn1 + beta.*jn2;
else
    jn = ita_sph_besselj(uniqueN,k.*r1);
end

%% beamforming calculation
result = zeros(input.nBins,nScanPositions);

for iScan = 1:nScanPositions
    % which wavetype to use for beamforming, can be plane or spherical
    % calculate source coefficients
    if strcmpi(sArgs.waveType,'plane')
        bn = 4*pi*bsxfun(@times,(1i).^uniqueN,jn);
    elseif strcmpi(sArgs.waveType,'spherical')
        hn = ita_sph_besselh(uniqueN,2,k.*Rscan(iScan));
        bn = bsxfun(@times,hn,-1i.*k(:)).*jn;
    else
        error('I do not know that waveType');
    end
    wn_bf = bsxfun(@times,conj(bn(:,uniqueExpansionIdx)),Y(iScan,:)); % nBins x nSH
    % apply
    result(:,iScan) = sum(input.freq.*wn_bf,2)/(4*pi);
    % correct level
    if strcmpi(sArgs.waveType,'spherical')
        result(:,iScan) = result(:,iScan).*(4*pi*Rscan(iScan))^2;
    else
        result(:,iScan) = result(:,iScan).*4*pi*Rscan(iScan).*exp(1i.*k.*Rscan(iScan));
    end
end

input.freq = result;
input.channelCoordinates = scanPositions;

%% Add history line
input = ita_metainfo_add_historyline(input,mfilename,varargin);

%% Set Output
varargout(1) = {input};

%end function
end