function varargout = ita_beam_beamforming(varargin)
%ITA_BEAM_BEAMFORMING - beamforming with different algorithms
%  This function performs beamforming calculations over a frequency range
%  defined by the input data. Input arguments are objects specifying the
%  array geometry, the frequency response recorded with the array and the
%  scanning mesh.
%  The optional fourth argument specifies the algorithm:
%
%  types:
%           (1) conventional           -- default
%           (2) conventional           w/o autospectra
%           (3) minimum-variance distortionless response
%           (4) MUSIC
%           (5) CLEAN                  w/o autospectra
%           (6) CLEAN-SC               w/o autospectra
%           (7) Orthogonal Beamforming
%           (8) Functional Beamforming
%
%  The returned  contains the result mapped onto the scanning mesh
%  for direct plotting.
%
%  Syntax: beam = ita_beam_beamforming(array,p,scanmesh,options)
%  Options (default):
%  'type' (1):                                  (1) conventional           -- default
%                                               (2) conventional           w/o autospectra
%                                               (3) minimum-variance distortionless response
%                                               (4) eigenanalysis
%                                               (5) CLEAN                  w/o autospectra
%
%  'wavetype' (2):                              (1) infinite distance focus (plane waves)
%                                               (2) finite distance focus (spherical waves)
%
%  'mic_radius' (0):                            used for mic directivity error
%  'soundspeed' (double(ita_constants('c'))):   soundspeed
%
%
%  See also ita_beam_beamforming.m
%
%   Reference page in Help browser
%        <a href="matlab:doc ita_beam_beamforming">doc ita_beam_beamforming</a>

% <ITA-Toolbox>
% This file is part of the application Beamforming for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Author: MMT -- Email: mmt@akustik.rwth-aachen.de
% Created:  22-Jan-2009

%% Get ITA Toolbox preferences and Function String
verboseMode  = ita_preferences('verboseMode');  %#ok<NASGU> Use to show additional information for the user
thisFuncStr  = [upper(mfilename) ':'];     % Use to show warnings or infos in this functions

%% Initialization and Input Parsing
sArgs        = struct('pos1_array','itaMicArray','pos2_p','itaSuper','pos3_scanmesh','itaCoordinates','type',ita_beam_evaluatePreferences('Method'),'wavetype',ita_beam_evaluatePreferences('ManifoldType'),'mic_radius',0,'soundspeed',double(ita_constants('c')));
[array,p,scanmesh,sArgs] = ita_parse_arguments(sArgs,varargin);

%% Preparations
if numel(sArgs.type) > 1
    v = sArgs.type;
    varargin{5} = 99;
    sArgs.type = 99;
end

switch sArgs.type
    case 1
        typeStr = 'Conventional Delay-and-Sum';
    case 2
        typeStr = 'Conventional Delay-and-Sum w/o Autospectra';
    case 3
        typeStr = 'Minimum-Variance Distortionless Response';
    case 4
        typeStr = 'MUSIC';
    case 5
        typeStr = 'CLEAN w/o Autospectra';
    case 6
        typeStr = 'CLEAN-SC w/o Autospectra';
    case 7
        typeStr = 'Orthogonal Beamforming';
    case 8
        typeStr = 'Functional Beamforming';
    case 10
        typeStr = 'Delay-and-Sum with mic directivity';
    case 99
        typeStr = 'Delay-and-Sum with precomputed manifoldVector';
    otherwise
        typeStr = 'unknown type';
end

f         = p.freqVector;
k         = 2*pi.*f./sArgs.soundspeed;
p_vec     = p.freq.';

% positions of array microphones
arrayPositions  = array.cart.';
weights = array.w(:);

% coordinates of the scan points
nodes   = scanmesh.ID(:); % nodeIDs
scanPositions = scanmesh.cart.';
nScanPoints = size(scanPositions,2); % # scan points

B = zeros(nScanPoints,p.nBins); % result
nMics = size(p_vec,1); % # of mics or channels

%% do the actual computation
ita_verbose_info([thisFuncStr 'Computing beamforming using type ''' typeStr ''''],1);
%
switch sArgs.type
    case 1 % delay-and-sum
        for iFreq = 1:p.nBins
            v = bsxfun(@times,weights(:),manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype));
            B(:,iFreq) = bsxfun(@rdivide,v,sum(abs(v).^2))'*p_vec(:,iFreq);
        end
    case 2 % delay-and-sum w/o autospectra
        E = ones(nMics) - eye(nMics);
        for iFreq = 1:p.nBins
            R = E.*(p_vec(:,iFreq)*p_vec(:,iFreq)');
            v = bsxfun(@times,weights(:),manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype));
            for iScanPoint = 1:nScanPoints
                w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                B(iScanPoint,iFreq) = w'*R*w;
            end
        end
        B = abs(B);
    case 3 % capon (MVDR)
        for iFreq = 1:p.nBins
            R = p_vec(:,iFreq)*p_vec(:,iFreq)';
            S = csvd(R);
            Rinv = (R + 1e-6.*max(S(:))*eye(nMics))^(-1);
            v = manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype);
            for iScanPoint = 1:nScanPoints
                v(:,iScanPoint) = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                w = (Rinv*v(:,iScanPoint))./(v(:,iScanPoint)'*Rinv*v(:,iScanPoint));
                B(iScanPoint,iFreq) = w'*R*w;
            end
        end
        B = abs(B);
    case 4 % MUSIC
        for iFreq=1:p.nBins
            R = p_vec(:,iFreq)*p_vec(:,iFreq)';
            [U,S,V] = csvd(R);
            sigIdx = rank(R,max(S(:))./1000); % 60 dB dynamic
            R = eye(nMics) - U(:,1:sigIdx)*U(:,1:sigIdx)';
            v = bsxfun(@times,weights,manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype));
            for iScanPoint=1:nScanPoints
                w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                B(iScanPoint,iFreq) = 1./(w'*R*w);
            end
        end
        B = abs(B);
    case 5 % CLEAN w/o autospectra
        safetyFactor = 0.1;
        E = ones(nMics) - eye(nMics);
        for iFreq = 1:p.nBins
            R = E.*(p_vec(:,iFreq)*p_vec(:,iFreq)');
            Rlast = R;
            v = manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype);
            B_0 = zeros(1,nScanPoints);
            for iScanPoint = 1:nScanPoints
                w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                B_0(iScanPoint) = w'*R*w;
            end
            iter = 0;
            while ((sum(abs(R(:))) <= sum(abs(Rlast(:)))) && (iter < 20))
                iter = iter + 1;
                [B0_max,maxIdx] = max(abs(B_0));
                B(maxIdx,iFreq) = B(maxIdx,iFreq) + B0_max;
                Rlast = R;
                R = Rlast - safetyFactor.*B0_max*(v(:,maxIdx)*v(:,maxIdx)');
                for iScanPoint = 1:nScanPoints
                    w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                    B_0(iScanPoint) = w'*R*w;
                end
            end
        end
    case 6 % CLEAN-SC w/o autospectra
        safetyFactor = 1;
        E = ones(nMics) - eye(nMics);
        for iFreq = 1:p.nBins
            R = E.*(p_vec(:,iFreq)*p_vec(:,iFreq)');
            Rlast = R;
            v = manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype);
            B_0 = zeros(1,nScanPoints);
            for iScanPoint = 1:nScanPoints
                w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                B_0(iScanPoint) = w'*R*w;
            end
            iter = 0;
            while ((sum(abs(R(:))) <= sum(abs(Rlast(:)))) && (iter < 20))
                iter = iter + 1;
                [B0_max,maxIdx] = max(abs(B_0));
                B(maxIdx,iFreq) = B(maxIdx,iFreq) + B0_max;
                Rlast = R;
                w_max = v(:,maxIdx)./sum(abs(v(:,maxIdx)).^2);
                h = v(:,maxIdx);
                for iIterH = 1:5
                    % h = R*w_max./B0_max; % for full matrix
                    h = 1./sqrt(1 + w_max'*diag(abs(h).^2)*w_max).*(R*w_max./B0_max + diag(abs(h).^2)*w_max);
                end
                R = Rlast - safetyFactor.*B0_max*(h*h');
                for iScanPoint = 1:nScanPoints
                    w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                    B_0(iScanPoint) = w'*R*w;
                end
            end
        end
    case 7 % Orthogonal Beamforming
        for iFreq=1:p.nBins
            R = p_vec(:,iFreq)*p_vec(:,iFreq)';
            [U,S,V] = csvd(R);
            sigIdx = 10; % rank(R,max(S).*1e-6); % 120 dB dynamic
            v = bsxfun(@times,weights,manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype));
            B_0 = zeros(1,nScanPoints);
            for iEigen = 1:sigIdx
                R = U(:,iEigen)*S(iEigen)*U(:,iEigen)';
                for iScanPoint=1:nScanPoints
                    w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                    B_0(iScanPoint) = w'*R*w;
                end
                [B0_max,maxIdx] = max(abs(B_0));
                B(maxIdx,iFreq) = B(maxIdx,iFreq) + B0_max;
            end
        end
    case 8 % Functional Beamforming
        for iFreq=1:p.nBins
            nu = 10;
            R = p_vec(:,iFreq)*p_vec(:,iFreq)';
            [U,S,V] = csvd(R);
            R = U*diag(S.^(1/nu))*V';
            v = bsxfun(@times,weights,manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype));
            for iScanPoint=1:nScanPoints
                w = v(:,iScanPoint)./sum(abs(v(:,iScanPoint)).^2);
                B(iScanPoint,iFreq) = abs(w'*R*w).^nu;
            end
        end
    case 10 % delay-and-sum with microphone directivity
        theta = (0:180).';
        sintheta = sin(theta.*pi/180);
        b = sArgs.mic_radius*0.0254;
        [sintheta,K] = ndgrid(sintheta,k(:).');
        u = K.*b.*sintheta;
        G = 2.*besselj(1,u)./u; G(isnan(G) == 1) = 1;
        err = abs(G);
        micerr = zeros(p.nBins,nMics,nScanPoints);
        for iMic = 1:nMics
            tmp = array.n(iMic) - scanmesh;
            tmpTheta = round(tmp.theta.*180/pi)+1;
            for iScanPoint = 1:nScanPoints
                micerr(:,iMic,iScanPoint) = err(tmpTheta(iScanPoint),:).';
            end
        end
        for iFreq= 1:p.nBins
            v = squeeze(micerr(iFreq,:,:)).*bsxfun(@times,weights,manifoldVector(k(iFreq),arrayPositions,scanPositions,sArgs.wavetype));
            B(:,iFreq) = bsxfun(@rdivide,v,sum(abs(v).^2))'*p_vec(:,iFreq);
        end
    case 99 % Delay-and-Sum with precomputed manifoldVectors
        for iFreq= 1:p.nBins
            w_vecs = bsxfun(@rdivide,weights,squeeze(v(iFreq,:,:)));
            B(:,iFreq) = bsxfun(@rdivide,w_vecs,sum(abs(w_vecs).^2))'*p_vec(:,iFreq);
        end
    otherwise
        B = nan(nScanPoints,p.nBins);
end

% all algorithms except the Delay-and-Sum give power output
if ~ismember(sArgs.type,[1,10,99])
    B = sqrt(B);
end


% c is the scaling factor to compensate for the beam width of the
% beamformer c^2 = 2.94 * (D*f/c)^2
% tmp = array - itaCoordinates(mean(array.cart));
% D = 2.*(max(max(abs(tmp.x(:))),max(abs(tmp.y(:)))));
% B = bsxfun(@times,B,sqrt(2.94).*(D.*k(:).'./(2*pi)));

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
%end function
end