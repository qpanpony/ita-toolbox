function varargout = ita_beam_beamforming(varargin)
%ITA_BEAM_BEAMFORMING - beamforming with different algorithms
%  This function performs beamforming calculations over a frequency range
%  defined by the input data. Input arguments are objects specifying the
%  array geometry, the frequency response recorded with the array and the
%  scanning mesh.
%  The optional fourth argument specifies the algorithm:
%
%  types:
%           (0) conventional with phase (for e.g. auralization)
%           (1) conventional           -- default
%           (2) Minimum-Variance Distortionless Response (MVDR)
%           (3) MUSIC
%           (4) Subspace Beamforming
%           (5) Functional Beamforming
%           (6) CLEAN
%           (7) CLEAN-SC
%           (8) DAMAS
%           (9) SparseDAMAS
%
%
%  The returned object contains the result mapped onto the scanning mesh
%  for direct plotting.
%
%  Syntax: beam = ita_beam_beamforming(array,p,scanmesh,options)
%  Options (default):
%  'type' (1):
%  'wavetype' (2):                            (1) infinite distance focus (plane waves)
%                                             (2) finite distance focus (spherical waves)
%
%  'mic_radius' (0):                          used for mic directivity error
%  'soundspeed' (double(ita_constants('c'))): soundspeed
%
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_beam_beamforming">doc ita_beam_beamforming</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  22-Jan-2009 / re-implementation:  02-Nov-2016

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs = struct('pos1_array','itaMicArray','pos2_p','itaSuper','pos3_scanmesh','itaCoordinates','type',ita_beam_evaluatePreferences('Method'),'wavetype',ita_beam_evaluatePreferences('SteeringType'),'soundspeed',double(ita_constants('c')),'exp_alpha',0.1,'steeringVector',[],'CSM',itaSuper());
[array,p,scanmesh,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Preparations
f = p.freqVector;
k = 2*pi.*f./sArgs.soundspeed;
P = p.freq.';

% positions of array microphones
arrayPositions = array.cart;

% coordinates of the scan points
nodes          = scanmesh.ID(:); % nodeIDs
scanPositions  = scanmesh.cart;
nScanPoints    = size(scanPositions,1); % # scan points

if isempty(sArgs.steeringVector)
    steeringVector = ita_beam_steeringVector(k,arrayPositions,scanPositions,sArgs.wavetype);
    steeringVector = permute(steeringVector,[2 3 1]);
else
    steeringVector = sArgs.steeringVector;
end

B      = zeros(nScanPoints,p.nBins); % result
nMics  = size(P,1); % # of mics or channels
if isempty(sArgs.CSM)
    CSM = zeros(nMics,nMics,p.nBins); % result
    exp_alpha = 1.0;
else
    CSM = permute(sArgs.CSM.freq,[2 3 1]);
    exp_alpha = sArgs.exp_alpha;
end
idxVec = zeros(16,p.nBins);

%% do the actual computation
%
if ~sArgs.type
    typeStr = 'Delay-and-Sum w/o CSM';
    ita_verbose_info([thisFuncStr 'Computing beamforming using type ''' typeStr ''''],1);
    B = squeeze(sum(bsxfun(@times,conj(permute(steeringVector,[3 1 2])),P.'),2)).';
else
    switch sArgs.type
    case 1
        functionHandle = @delayAndSum;
        typeStr = 'Conventional Delay-and-Sum';
    case 2
        functionHandle = @MVDR;
        typeStr = 'MVDR';
    case 3
        functionHandle = @MUSIC;
        typeStr = 'MUSIC';
    case 4
        functionHandle = @SubspaceBeam;
        typeStr = 'Subspace Beamforming';
    case 5
        functionHandle = @FunctionalBeam;
        typeStr = 'Functional Beamforming';
    case 6
        functionHandle = @CLEAN;
        typeStr = 'CLEAN';
    case 7
        functionHandle = @CLEAN_SC;
        typeStr = 'CLEAN-SC';
    case 8
        functionHandle = @DAMAS;
        typeStr = 'DAMAS';
    case 9
        functionHandle = @SparseDAMAS;
        typeStr = 'SparseDAMAS';
    otherwise
        error('unknown beamforming type');
    end
    ita_verbose_info([thisFuncStr 'Computing beamforming using type ''' typeStr ''''],1);
    % now do this for each frequency
    for iFreq = 1:size(CSM,3)
        [B(:,iFreq),CSM(:,:,iFreq),idxVec(:,iFreq)] = functionHandle(CSM(:,:,iFreq),P(:,iFreq),steeringVector(:,:,iFreq),exp_alpha);
    end
end

% correct to obtain source strengths
if sArgs.type
    B = sqrt(max(0,real(B)));
end
B = B.*4*pi;

% create the audio object
if isa(p,'itaAudio')
    B = itaAudio(B.',p.samplingRate,'freq');
else
    B = itaResult(B.',f,'freq');
end
B.channelUnits = repmat(p.channelUnits(1),nScanPoints,1);
B.channelNames = cellstr(num2str((1:nScanPoints).'));
B.userData = {'nodeN',nodes(:)};

B = ita_mapDataToMesh(B,scanmesh);

%% Add history line
B = ita_metainfo_add_historyline(B,mfilename,varargin);

varargout(1) = {B};
if nargout == 2
    % create the audio object
    if isa(p,'itaAudio')
        CSM = itaAudio(permute(CSM,[3 1 2]),p.samplingRate,'freq');
    else
        CSM = itaResult(permute(CSM,[3 1 2]),f,'freq');
    end
    varargout(2) = {CSM};
end
%end function
end

%% beamforming subfunctions
%% 1
function [B,CSM,idxVec] = delayAndSum(CSM,P,manifoldVector,exp_alpha)
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    B = sum(conj(manifoldVector).*(CSM*manifoldVector),1).';
    idxVec = zeros(16,1);
    [~,maxIdx] = max(B);
    idxVec(1) = 1;
    idxVec(2) = maxIdx;
end % delay and sum

%% 2
function [B,CSM,idxVec] = MVDR(CSM,P,manifoldVector,exp_alpha)
    % inverse of CSM with diagonal loading
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    [U,s] = eig(CSM);
    s = flip(diag(s));
    U = flip(U,2);
    CSMinv = U*diag(1./(1e-3.*max(s) + s))*U';
    B = sum(conj(manifoldVector).*(CSMinv*manifoldVector),1).';
    B = 1./abs(squeeze(sum(abs(manifoldVector).^2).^2).'.*B);
    idxVec = zeros(16,1);
    [~,maxIdx] = max(B);
    idxVec(1) = 1;
    idxVec(2) = maxIdx;
end % MVDR

%% 3
function [B,CSM,idxVec] = MUSIC(CSM,P,manifoldVector,exp_alpha)
    % projection onto noise subspace, no level information left
    nMics = size(manifoldVector,1);
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    [U,s] = eig(CSM);
    s = flip(diag(s));
    U = flip(U,2);
    sigIdx = find(s > max(s).*1e-3,1,'last'); % 60 dB dynamic
    CSM_M = eye(nMics) - U(:,1:sigIdx)*U(:,1:sigIdx)';
    B = 1./sum(conj(manifoldVector).*(CSM_M*manifoldVector),1).';
    idxVec = zeros(16,1);
    [~,maxIdx] = max(B);
    idxVec(1) = 1;
    idxVec(2) = maxIdx;
end % MUSIC

%% 4
function [B,CSM,idxVec] = SubspaceBeam(CSM,P,manifoldVector,exp_alpha)
    % separate source types through eigendecomposition
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    [U,s] = eig(CSM);
    s = flip(diag(s));
    U = flip(U,2);
    sigIdx = min(find(s > max(s).*1e-3,1,'last'),15); % 60 dB dynamic
    idxVec = zeros(16,1);
    if ~isempty(sigIdx)
        idxVec(1) = sigIdx;
    end
    B = zeros(size(manifoldVector,2),1);
    for iEigen = 1:sigIdx
        CSM_e = U(:,iEigen)*s(iEigen)*U(:,iEigen)';
        B_0 = real(sum(conj(manifoldVector).*(CSM_e*manifoldVector),1));
        [B0_max,maxIdx] = max(B_0);
        idxVec(iEigen+1) = maxIdx;
        B(maxIdx) = B(maxIdx) + B0_max;
    end
end % Subspace beamforming

%% 5
function [B,CSM,idxVec] = FunctionalBeam(CSM,P,manifoldVector,exp_alpha)
    % better localisation by raising eigenvales by a power factor
    nu = 20;
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    [U,s] = eig(CSM);
    s = flip(diag(s));
    U = flip(U,2);
    sigIdx = find(s > max(s).*1e-3,1,'last'); % 60 dB dynamic
    CSM_f = U(:,1:sigIdx)*diag(s(1:sigIdx).^(1/nu))*U(:,1:sigIdx)';
    B = sum(conj(manifoldVector).*(CSM_f*manifoldVector),1).';
    B = abs((squeeze(sum(abs(manifoldVector).^2,1)).'.^(1-nu)).*real(B).^nu);
    idxVec = zeros(16,1);
    [~,maxIdx] = max(B);
    idxVec(1) = 1;
    idxVec(2) = maxIdx;
end % Functional beamforming

%% 6
function [B,CSM,idxVec] = CLEAN(CSM,P,manifoldVector,exp_alpha)
    % iteratively remove source contributions
    % start iterative process
    safetyFactor = 0.6;
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    % original delay and sum map (dirty map)
    B_c = real(sum(conj(manifoldVector).*(CSM*manifoldVector),1)).';
    Bsum = 2*sum(abs(B_c));
    iter = 0;
    B = zeros(size(B_c));
    idxVec = zeros(16,1);
    while (all(B_c >= 0) && (sum(abs(B_c)) < Bsum) && (iter < 15))
        iter = iter + 1;
        [B0_max,maxIdx] = max(safetyFactor.*B_c);
        B(maxIdx) = B(maxIdx) + B0_max;
        idxVec(iter+1) = maxIdx;
        Bsum = sum(abs(B_c));
        % remove source contribution of this iteration
        w_max = manifoldVector(:,maxIdx)./sum(abs(manifoldVector(:,maxIdx)).^2);
        B_c = B_c - B0_max.*abs(manifoldVector'*w_max).^2;
    end
    idxVec(1) = iter;
    B = B./safetyFactor;
end % CLEAN

%% 7
function [B,CSM,idxVec] = CLEAN_SC(CSM,P,manifoldVector,exp_alpha)
    % iteratively remove source contributions, include source coherence information
    % start iterative process
    safetyFactor = 0.6;
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    CSM_c = CSM;
    B_c = real(sum(conj(manifoldVector).*(CSM*manifoldVector),1)).';
    Bsum = 2*sum(B_c);
    iter = 0;
    B = zeros(size(B_c));
    idxVec = zeros(16,1);
    while (all(B_c >= 0) && (sum(B_c) < Bsum) && (iter < 15))
        iter = iter + 1;
        [B0_max,maxIdx] = max(safetyFactor.*B_c);
        B(maxIdx) = B(maxIdx) + B0_max;
        idxVec(iter+1) = maxIdx;
        Bsum = sum(B_c);
        h = CSM_c*manifoldVector(:,maxIdx)./B0_max; % for full CSM
        CSM_c = CSM_c - B0_max.*(h*h');
        % remove source contribution of this iteration
        % B_c = real(sum(conj(v).*(CSM_c*v),1));
        B_c = B_c - B0_max.*abs(manifoldVector'*h).^2;
    end
    idxVec(1) = iter;
    B = B./safetyFactor;
end % CLEAN-SC

%% 8 DAMAS
function [B,CSM,idxVec] = DAMAS(CSM,P,manifoldVector,exp_alpha)
    % deconvolution approach, solve iteratively (Gauss-Seidel method)
    nScan = size(manifoldVector,2);
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    CSM_c = CSM;
    % original delay and sum map (dirty map)
    b = real(sum(conj(manifoldVector).*(CSM_c*manifoldVector),1)).';
    % get a guess for initial x
    x = 0.*b;
    [maxVal,maxIdx] = max(b);
    x(maxIdx) = maxVal;
    % solve A*x = b using Gauss-Seidel method
    A = zeros(nScan,nScan);
    for iScan = 1:nScan
        A(:,iScan) = abs(manifoldVector'*manifoldVector(:,iScan)./sum(abs(manifoldVector(:,iScan)).^2)).^2;
    end
    %     B(:,iFreq) = gauss_seidel(A,b,x,1e-3,5000,0);
    B = max(0,lsqr(A,b,1e-3,50,[],[],x));
%     B = lsqnonneg(A,b);
    B(isinf(B)) = 0;
    idxVec = zeros(16,1);
    [~,maxIdx] = max(B);
    idxVec(1) = 1;
    idxVec(2) = maxIdx;
end % DAMAS

%% 9 Sparse DAMAS
function [B,CSM,idxVec] = SparseDAMAS(CSM,P,manifoldVector,exp_alpha)
    % deconvolution approach, solve iteratively with sparse constraint (FOCUSS)
    % start iterative process
    nScan = size(manifoldVector,2);
    % original delay and sum map (dirty map)
    CSM = (1-exp_alpha).*CSM + exp_alpha.*(P*P');
    CSM_c = CSM;
    % original delay and sum map (dirty map)
    b = real(sum(conj(manifoldVector).*(CSM_c*manifoldVector),1)).';
    % get a guess for initial x
    x = 0.*b;
    [maxVal,maxIdx] = max(b);
    x(maxIdx) = maxVal;
    A = zeros(nScan,nScan);
    for iScan = 1:nScan
        A(:,iScan) = abs(manifoldVector'*manifoldVector(:,iScan)./sum(abs(manifoldVector(:,iScan)).^2)).^2;
    end
    % solve A*x = b using FOCUSS method (sparse solution)
    B = focuss(A,b,x,1e-3,100,0);
    B(isinf(B)) = 0;
    idxVec = zeros(16,1);
    [~,maxIdx] = max(B);
    idxVec(1) = 1;
    idxVec(2) = maxIdx;
end % SparseDAMAS