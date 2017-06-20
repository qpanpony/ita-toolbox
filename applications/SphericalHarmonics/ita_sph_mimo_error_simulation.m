function varargout = ita_sph_mimo_error_simulation(varargin)
%ITA_SPH_MIMO_ERROR_SIMULATION - Simulate aliasing and noise errors in
%  spherical MIMO systems.
%  This function simulates the mismatch errors from noise, sampling dispacement and aliasing 
%  for a MIMO system comprised of a spherical loudspeaker array and a spherical microphone
%  array.
%
%  Syntax:
%   itaResult = ita_sph_mimo_error_simulation(options)
%
%   Options (default):
%           'SNR'				(60)	: SNR at each transducer
%           'nRuns'				(5)		: calculate average of nRuns number of source-receiver orientations
%           'dirMeasurementFile' ( [] ) : Filename for a directivity file that is to be included
%
%  Directivity files need to be in hdf5 format. The name of data fields need to be 'fullDirRe' and 
%  'fullDirIm' for the real and imaginary part respectively.
%
%  Example:
%   [individualTerms, allTerms, totalError] = ita_sph_mimo_error_simulation(sourceParams, receiverParams, opts)
%
%  See also:
%   ita_toolbox_gui, ita_read, ita_write, ita_generate
%
%   Reference page in Help browser 
%        <a href="matlab:doc ita_sph_mimo_error_simulation">doc ita_sph_mimo_error_simulation</a>

% <ITA-Toolbox>
% This file is part of the ITA-Toolbox. Some rights reserved. 
% You can find the license for this m-file in the license.txt file in the ITA-Toolbox folder. 
% </ITA-Toolbox>


% Author: Marco Berzborn -- Email: marco.berzborn@akustik.rwth-aachen.de
% Created:  29-Mar-2016 


sArgs = struct('pos1_source','struct',...
               'pos2_receiver','struct',...
               'fftDegree',ita_preferences('fftDegree'),...
               'samplingRate',ita_preferences('samplingRate'),...
               'freqRange',[20 ita_preferences('samplingRate')/2],...
               'samplingDisplacement',[],...
			   'samplingDisplacementAbsolute',false,...
               'nRuns',1,...
               'SNR',60,...
               'sma',true,...
               'sla',true,...
               'regulParam',[],...
               'regulPower',1,...
               'simWNG',false,...
               'simDI',false,...
               'dirMeasurementFile',[]);
[source,receiver,sArgs] = ita_parse_arguments(sArgs,varargin);

% save all struct fields as variables for speed improvements in the parfor loop
receiverNmax = receiver.Nmax;
receiverSampling = receiver.sampling;

sourceNmax = source.Nmax;
sourcerMem = source.rMem;
sourceSampling = source.sampling;
sourceSamplingR = sourceSampling.r;

simSMA = sArgs.sma;
simSLA = sArgs.sla;

SNR = sArgs.SNR;
samplingDisplacement = sArgs.samplingDisplacement;
displacementType = sArgs.samplingDisplacementAbsolute;

ao = ita_generate_impulse('fftDegree',sArgs.fftDegree,'samplingRate',sArgs.samplingRate);
freqVec = ao.freqVector(ao.freq2index(sArgs.freqRange(1)):ao.freq2index(sArgs.freqRange(2)));
kVec = freqVec*2*pi/double(ita_constants('c'));


sourceNmaxAlias = floor(2*pi/double(ita_constants('c'))*sArgs.freqRange(2)*max(sourceSampling.r));
receiverNmaxAlias = floor(2*pi/double(ita_constants('c'))*sArgs.freqRange(2)*max(receiverSampling.r));

simDI = sArgs.simDI;
simWNG = sArgs.simWNG;

yMIMOgroundTruth = zeros(sArgs.nRuns,1,numel(kVec));

% check if source and receiver sampling have a unique radius within a certain tolerance
if numel(unique(sourceSampling.r)) > 1
    uniRSort = sort(unique(sourceSampling.r));
    if uniRSort(1) > uniRSort(end)*(1-2*eps) && uniRSort(end) < uniRSort(1)*(1+2*eps)
        sourceSampling.r = repmat(mean(uniRSort),size(sourceSampling.r));
    end
end
receiverSamplingUniqueRad = ~(numel(unique(receiverSampling.r)) > 1);

if numel(unique(receiverSampling.r)) > 1
    uniRSort = sort(unique(receiverSampling.r));
    if uniRSort(1) > uniRSort(end)*(1-2*eps) && uniRSort(end) < uniRSort(1)*(1+2*eps)
        receiverSampling.r = repmat(mean(uniRSort),size(receiverSampling.r));
    end
end

% include measured source directivity
dirMeasurementFile = sArgs.dirMeasurementFile;

% initialize constant variables
receiverYalias = ita_sph_base(receiverSampling,receiverNmaxAlias);
sourceYalias = ita_sph_base(sourceSampling,sourceNmaxAlias);
sourceGalias = ita_sph_aperture_function_sla(sourceSampling,sourceNmaxAlias,sourcerMem);

sourceG = sourceGalias(:,1:(sourceNmax+1)^2);
sourceY = sourceYalias(:,1:(sourceNmax+1)^2);
receiverY = receiverYalias(:,1:(receiverNmax+1)^2);

% declare non constant variables
eMismatchReceiver = zeros(sArgs.nRuns,1,numel(freqVec));
eAliasReceiver = zeros(sArgs.nRuns,1,numel(freqVec));
eMismatchSource = zeros(sArgs.nRuns,1,numel(freqVec));
eAliasSource = zeros(sArgs.nRuns,1,numel(freqVec));
elapsedTime = zeros(sArgs.nRuns,1);
receiverWNG = zeros(sArgs.nRuns,1,numel(freqVec));
receiverDI = zeros(sArgs.nRuns,1,numel(freqVec));
sourceWNG = zeros(sArgs.nRuns,1,numel(freqVec));
sourceDI = zeros(sArgs.nRuns,1,numel(freqVec));

% order dependent tikhonov regularization parameter
% for regulVec = zeros(...) this simplifies to the standard tikhonov
% regularization
regulPower = sArgs.regulPower;
orderVec = ita_sph_eye(receiverNmax,'n-nm').' * (0:receiverNmax).';
regulMatReceiver = diag(1 + orderVec.*(orderVec + 1).^regulPower);
orderVec = ita_sph_eye(sourceNmax,'n-nm').' * (0:sourceNmax).';
regulMatSource = diag(1 + orderVec.*(orderVec + 1).^regulPower);
regulParam = sArgs.regulParam;

%%
for idxRun = 1:sArgs.nRuns
    timerRuns = tic;
    % positionig parameters
    distSourceReceiver = 4;
    posSource = itaCoordinates([1 0 0]);
    posReceiver = ceil(rand(1,3)*10);
    posReceiver = posSource.cart+(posSource.cart-posReceiver)/norm(posSource.cart-posReceiver)*distSourceReceiver;
    posReceiver = itaCoordinates(posReceiver);
    [receiverLookDir,sourceLookDir,distSourceReceiver] = array_orientation(posReceiver,posSource);
    
    equalizationRadSource = 2;
    
    % room transfer function (free field assumption at this point)
    Psi = sph_transfer_path(posReceiver,receiverNmaxAlias,posSource,sourceNmaxAlias,kVec,...
        'r',distSourceReceiver,'r_eq',equalizationRadSource,'norm',false);

    PsiAliasReceiver = Psi(1:(receiverNmaxAlias+1)^2,1:(sourceNmax+1)^2,:);
    PsiAliasSource = Psi(1:(receiverNmax+1)^2,1:(sourceNmaxAlias+1)^2,:);
    Psi = Psi(1:(receiverNmax+1)^2,1:(sourceNmax+1)^2,:);
    
    
    if ~isempty(samplingDisplacement) && isempty(SNR)
        % rest happens inside loop, only here in case of an error
        % inititialization needed here since parfor otherwise throws a
        % runtime error
        irReceiver = zeros(1,numel(freqVec));
        irSource = zeros(1,numel(freqVec));
    elseif ~isempty(SNR) && isempty(samplingDisplacement)
        noiseReceiver = ones(receiverSampling.nPoints,numel(freqVec));
        irReceiver = add_awgn(noiseReceiver,SNR,'fftDegree',sArgs.fftDegree,...
            'samplingRate',sArgs.samplingRate,'freqRange',sArgs.freqRange);
        
        noiseSource = ones(sourceSampling.nPoints,numel(freqVec));
        irSource = add_awgn(noiseSource,SNR,'fftDegree',sArgs.fftDegree,...
            'samplingRate',sArgs.samplingRate,'freqRange',sArgs.freqRange);
    else
        disp('MIMO_ERRORS:: I cannot simulate both sampling displacement and transducer noise!')
        varargout = cell(1,nargout);
        return;
    end

    % random beam pattern weigths
    receiverRandPattern = rand((receiverNmax+1)^2,1) + 1i*rand((receiverNmax+1)^2,1);
    sourceRandPattern = rand((sourceNmax+1)^2,1) + 1i*rand((sourceNmax+1)^2,1);
    
    parfor idxFreq=1:numel(freqVec)
        sourceBalias = [];
        dirMat = [];
        EreceiverMismatch = [];
        EsourceMismatch = [];
        
        if simSLA
            if isempty(dirMeasurementFile)
                sourceBalias = ita_sph_modal_strength(sourceSampling,sourceNmaxAlias,kVec(idxFreq),'rigid','transducer','ls');
                sourceB = sourceBalias(1:(sourceNmax+1)^2,1:(sourceNmax+1)^2);
                if numel(unique(sourceSampling.r)) == 1
                    Msource = sourceB * (sourceG.'.*sourceY');
                else
                    Msource = sourceB .* (sourceG.'.*sourceY');
                end
            else
				% include measured source directivity
                dirMat = h5read(dirMeasurementFile,'/dir/fullRe',[1,1,idxFreq],[sourceSampling.nPoints,(sourceNmaxAlias+1)^2,1]) +...
                    1i* h5read(dirMeasurementFile,'/dir/fullIm',[1,1,idxFreq],[sourceSampling.nPoints,(sourceNmaxAlias+1)^2,1]);
                Msource = dirMat(:,1:(sourceNmax+1)^2).';
            end
        else
            Msource = [];
            sourceBalias = [];
        end
        if simSMA
            receiverBalias = ita_sph_modal_strength(receiverSampling,receiverNmaxAlias,kVec(idxFreq),'rigid');
            if receiverSamplingUniqueRad
                receiverB = receiverBalias(1:(receiverNmax+1)^2,1:(receiverNmax+1)^2);
                Mreceiver = receiverY*receiverB;
            else
                receiverB = receiverBalias(:,1:(receiverNmax+1)^2);
                Mreceiver = receiverB.*receiverY;
            end
        else
            Mreceiver = [];
            receiverBalias = [];
        end
        
              
        % apply regularization to the equalization problem
        if ~isempty(regulParam)
            if simSMA
                MreceiverInv = pinv(Mreceiver'*Mreceiver+regulParam^2*regulMatReceiver)*Mreceiver';
            else
                MreceiverInv = [];
            end
            if simSLA
                MsourceInv = Msource'*pinv(Msource*Msource'+regulParam^2*regulMatSource);
            else
                MsourceInv = [];
            end
        % if no regulization parameter is given use the Moore Penrose
        % inverse
        else
            if simSMA
                MreceiverInv = pinv(Mreceiver);
            else
                MreceiverInv = [];
            end
            if simSLA
                MsourceInv = pinv(Msource);
            else
                MsourceInv = [];
            end
        end
        
        if simSMA
            if numel(unique(receiverSampling.r)) == 1
                EreceiverAlias = receiverYalias*receiverBalias;
            else
                EreceiverAlias = receiverYalias.*receiverBalias;
            end
        else
            EreceiverAlias = [];
        end
        if simSLA
            if isempty(dirMeasurementFile)
                EsourceAlias = sourceBalias*(sourceGalias.'.*sourceYalias');
            else
                EsourceAlias = dirMat.';
            end
        else
            EsourceAlias = [];
        end
        
        % use random weighting coefficients for simulation
        sourceLambda = sourceRandPattern / norm(sourceRandPattern) .* ita_sph_base(sourceLookDir,sourceNmax)' * 4*pi/(sourceNmax+1)^2;
        receiverLambda = receiverRandPattern / norm(receiverRandPattern) .* ita_sph_base(receiverLookDir,receiverNmax)' * 4*pi/(receiverNmax+1)^2;
        
        
        if ~isempty(samplingDisplacement) && isempty(SNR)
            
            if simSMA
                receiverSamplingErroneous = ita_sph_sampling_displacement(receiverSampling,samplingDisplacement,'absolute',displacementType);
                receiverYmismatch = ita_sph_base(receiverSamplingErroneous,receiverNmax);
                EreceiverMismatch = ita_sph_modal_strength(receiverSamplingErroneous,receiverNmax,kVec(idxFreq),'rigid');
                if receiverSamplingUniqueRad
                    EreceiverMismatch = receiverYmismatch*EreceiverMismatch - Mreceiver;
                else
                    EreceiverMismatch = receiverYmismatch.*EreceiverMismatch - Mreceiver;
                end
            else
                EreceiverMismatch = [];
            end
            if simSLA
                sourceSamplingErroneous = ita_sph_sampling_displacement(sourceSampling,samplingDisplacement,'absolute',displacementType);
                sourceYmismatch = ita_sph_base(sourceSamplingErroneous,sourceNmax);
                sourceGmismatch = ita_sph_aperture_function_sla(sourceSamplingErroneous,sourceNmax,sourcerMem,'r',unique(sourceSamplingR));
                EsourceMismatch = ita_sph_modal_strength(sourceSamplingErroneous,sourceNmax,kVec(idxFreq),'rigid','transducer','ls');
                if numel(unique(sourceSampling.r)) == 1
                    EsourceMismatch = (EsourceMismatch * (sourceGmismatch.'.*sourceYmismatch')) - Msource;
                else
                    EsourceMismatch = (EsourceMismatch.' .* (sourceGmismatch.'.*sourceYmismatch')) - Msource;
                end
            else
                EsourceMismatch = [];
            end
            
        elseif ~isempty(SNR) && isempty(samplingDisplacement)
            if simSMA
                EreceiverMismatch = (diag(irReceiver(:,idxFreq))-diag(ones(receiverSampling.nPoints,1)))*Mreceiver;
            else
                EreceiverMismatch = [];
            end
            if simSLA
                EsourceMismatch = Msource*(diag(irSource(:,idxFreq))-diag(ones(sourceSampling.nPoints,1)));
            else
                EsourceMismatch = [];
            end
        end

        if simSMA
            eMismatchReceiver(idxRun,:,idxFreq) = receiverLambda' * MreceiverInv * EreceiverMismatch * Psi(:,:,idxFreq) * sourceLambda;
            % aliasing only by setting n<N_sampling = 0
            eAliasReceiver(idxRun,:,idxFreq) = receiverLambda' * MreceiverInv * [zeros(receiverSampling.nPoints,(receiverNmax+1)^2),EreceiverAlias(:,(receiverNmax+1)^2+1:end)] ...
                * PsiAliasReceiver(:,:,idxFreq) * sourceLambda;
            if simDI
                receiverDI(idxRun,:,idxFreq) = 4*pi* sum(abs(receiverLambda'*MreceiverInv*Mreceiver*ita_sph_base(receiverLookDir,receiverNmax)').^2)/sum(abs(receiverLambda'*MreceiverInv*Mreceiver).^2);
            end
            if simWNG
                receiverWNG(idxRun,:,idxFreq) = 1 / norm(receiverLambda' * (MreceiverInv' * MreceiverInv) * receiverLambda);
            end
        end
        if simSLA
            eMismatchSource(idxRun,:,idxFreq) = receiverLambda' * Psi(:,:,idxFreq) * EsourceMismatch * MsourceInv * sourceLambda;
            % aliasing only by setting n<N_sampling = 0
            eAliasSource(idxRun,:,idxFreq) = receiverLambda' * PsiAliasSource(:,:,idxFreq) ...
                * [zeros((sourceNmax+1)^2,sourceSampling.nPoints);EsourceAlias((sourceNmax+1)^2+1:end,:)] * MsourceInv * sourceLambda;
            if simDI
                sourceDI(idxRun,:,idxFreq) = 4*pi* sum(abs(ita_sph_base(sourceLookDir,sourceNmax)*Msource*MsourceInv*sourceLambda).^2)/sum(abs(Msource*MsourceInv*sourceLambda).^2);
            end
            if simWNG
                sourceWNG(idxRun,:,idxFreq) = 1 / norm(sourceLambda' * (MsourceInv' * MsourceInv) * sourceLambda);
            end
        end
        
        %% groundthruth and errors
        yMIMOgroundTruth(idxRun,:,idxFreq) = receiverLambda'* Psi(:,:,idxFreq) * sourceLambda;

    end
    elapsedTime(idxRun) = toc(timerRuns);
    approxRemain = (sArgs.nRuns-idxRun)*sum(elapsedTime)/idxRun;
    disp(['MIMO_ERRORS:: finished run ', num2str(idxRun), ' of ', num2str(sArgs.nRuns),' after ',num2str(sum(elapsedTime)/60),' min - approx. remaining: ',num2str(approxRemain/60),' min']);
end

if simWNG
    receiverWNG = itaResult(permute(mean(receiverWNG(1,1,:),1),[3,1,2]),freqVec,'freq');
    sourceWNG = itaResult(permute(mean(sourceWNG(1,1,:),1),[3,1,2]),freqVec,'freq');
    wng = merge(receiverWNG,sourceWNG);
    wng.channelNames = {'Receiver','Source'};
else
    wng = [];
end

if simDI
    receiverDI = itaResult(permute(mean(receiverDI(1,1,:),1),[3,1,2]),freqVec,'freq');
    sourceDI = itaResult(permute(mean(sourceDI(1,1,:),1),[3,1,2]),freqVec,'freq');
    di = merge(receiverDI,sourceDI);
    di.channelNames = {'Receiver','Source'};
else
    di = [];
end

% init errorverctors
errorMismatchReceiver = zeros(sArgs.nRuns,numel(freqVec));
errorAliasReceiver = zeros(sArgs.nRuns,numel(freqVec));
errorMismatchSource = zeros(sArgs.nRuns,numel(freqVec));
errorAliasSource = zeros(sArgs.nRuns,numel(freqVec));


for idxRun = 1:sArgs.nRuns
    for idxFreq = 1:numel(freqVec)
        if simSMA
            errorMismatchReceiver(idxRun,idxFreq) = (norm(eMismatchReceiver(idxRun,:,idxFreq) ./ yMIMOgroundTruth(idxRun,:,idxFreq)));
            errorAliasReceiver(idxRun,idxFreq) = (norm(eAliasReceiver(idxRun,:,idxFreq) ./ yMIMOgroundTruth(idxRun,:,idxFreq)));
        end
        if simSLA
            errorMismatchSource(idxRun,idxFreq) = (norm(eMismatchSource(idxRun,:,idxFreq) ./ yMIMOgroundTruth(idxRun,:,idxFreq)));
            errorAliasSource(idxRun,idxFreq) = (norm(eAliasSource(idxRun,:,idxFreq) ./ yMIMOgroundTruth(idxRun,:,idxFreq)));
        end
    end
end

errorMismatchReceiver = itaResult(mean(errorMismatchReceiver).',freqVec,'freq');
errorMismatchReceiver.channelNames = {'mismatch receiver'};
errorAliasReceiver = itaResult(mean(errorAliasReceiver).',freqVec,'freq');
errorAliasReceiver.channelNames = {'alias receiver'};

errorMismatchSource = itaResult(mean(errorMismatchSource).',freqVec,'freq');
errorMismatchSource.channelNames = {'mismatch source'};
errorAliasSource = itaResult(mean(errorAliasSource).',freqVec,'freq');
errorAliasSource.channelNames = {'alias source'};

errorAliasSourceAliasReceiver = errorAliasSource * errorAliasReceiver;
errorAliasSourceAliasReceiver.channelNames = {'alias receiver, alias source'};
errorAliasSourceMismatchReceiver = errorAliasSource * errorMismatchReceiver;
errorAliasSourceMismatchReceiver.channelNames = {'mismatch receiver, alias source'};
errorMismatchSourceAliasReceiver = errorMismatchSource * errorAliasReceiver;
errorMismatchSourceAliasReceiver.channelNames = {'alias receiver, mismatch source'};
errorMismatchSourceMismatchReceiver = errorMismatchSource * errorMismatchReceiver;
errorMismatchSourceMismatchReceiver.channelNames = {'mismatch receiver, mismatch source'};

cmp = ita_merge(errorMismatchReceiver,errorMismatchSource,errorAliasReceiver,errorAliasSource);
cmpAll = ita_merge(errorMismatchReceiver,errorMismatchSource,errorAliasReceiver,errorAliasSource,errorAliasSourceAliasReceiver,errorAliasSourceMismatchReceiver,errorMismatchSourceAliasReceiver,errorMismatchSourceMismatchReceiver);

errorSum = sum(cmpAll);

varargout{1} = cmp;
varargout{2} = cmpAll;
varargout{3} = errorSum;
varargout{4} = wng;
varargout{5} = di;
end


function Psi = sph_transfer_path(varargin)
% calculates the transfer path from a source to a receiver in the spherical
% harmonic domain
%
% [Psi] = nSH_R x nSH_S x nBins

sArgs = struct('pos1_receiverCoords','itaCoordinates',...
               'pos2_receiverNmax','integer',...
               'pos3_sourceCoords','itaCoordinates',...
               'pos4_sourceNmax','integer',...
               'pos5_k','double',...
               'r',[],...
               'r_eq',1,...
               'norm',false);
[receiverCoords,receiverNmax,sourceCoords,sourceNmax,k,sArgs] = ita_parse_arguments(sArgs,varargin);

[receiverLookDirection, sourceLookDirection,r] = array_orientation(receiverCoords,sourceCoords);
yReceiver = ita_sph_base(receiverLookDirection,receiverNmax)';
ySource = ita_sph_base(sourceLookDirection,sourceNmax)';

% avoid sArgs in parfor since it is a broadcast variable
if ~isempty(sArgs.r)
    dist = double(sArgs.r);
else
    dist = r;
end

r_eq = sArgs.r_eq;

Psi = zeros((receiverNmax+1)^2,(sourceNmax+1)^2,numel(k));

if sArgs.norm
    % normalization according to the spherical harmonic addition theorem
    % normFactor = 1/norm(yReceiver*ySource');
    normFactor = 4*pi/((receiverNmax+1)*(sourceNmax+1));
else
    normFactor = 1;
end

parfor idxFreq = 1:numel(k)
    Psi(:,:,idxFreq) = yReceiver  * ySource' .* normFactor .* (exp(-1i*(k(idxFreq)*(dist-r_eq)))/dist*r_eq);
end

end


function varargout = array_orientation(receiverPos,sourcePos)
% calculate the orientation vectors for two arrays in a 3 dimensional
% domain

dist = norm(receiverPos.cart-sourcePos.cart);
orientationSource = (receiverPos.cart-sourcePos.cart) / dist;
orientationReceiver = (sourcePos.cart-receiverPos.cart) / dist;

varargout{1} = itaCoordinates(orientationReceiver,'cart');
varargout{2} = itaCoordinates(orientationSource,'cart');
varargout{3} = dist;


end


function data = add_awgn(varargin)
% add awgn to a frequency domain signal
% data may be 2 dimensional or 3 dimensional. 
% frequency axis along the last dimension

sArgs = struct('pos1_data','double',...
               'pos2_snr','double',...
               'samplingRate',ita_preferences('samplingRate'),...
               'fftDegree',ita_preferences('fftDegree'),...
               'freqRange',[20 ita_preferences('samplingRate')/2],...
               'ref',20);
[data,snr,sArgs] = ita_parse_arguments(sArgs,varargin);

switch numel(size(data))
    case 2
        % insert singleton dimension
        data = permute(data,[3,1,2]);
        dim = 2;
    case 3
        % everything already correct, nothing to be done here
        % data = permute(data,[2,1,3]);
        dim = 3;
    otherwise
        ita_verbose_info('Invalid dimension of data.',0);
        data = [];
        return;
end

% take the upper nyquist for the sweep generation because of the high pass
% shelving filter in the sweep function
sweep = ita_generate_sweep('stopMargin',0,'samplingRate',sArgs.samplingRate,'fftDegree',...
        sArgs.fftDegree,'freqRange',[sArgs.freqRange(1), sArgs.samplingRate/2],'bandwidth',0);
upperIdx = sweep.freq2index(sArgs.freqRange(2));
lowerIdx = sweep.freq2index(sArgs.freqRange(1));


% extract all needed data from the audio object and delete afterwards
sweepTime = permute(repmat(sweep.timeData,1,size(data,2)),[2,1]);
freqData = permute(repmat(sweep.freqData(lowerIdx:upperIdx),1,size(data,2)),[2,1]);
nSamples = sweep.nSamples;

% generate noisy ir and convolve with the input data
for idxDimOne=1:size(data,1)
    noise = randn(size(data,2),nSamples);
    noise = bsxfun(@rdivide,noise,rms(noise,2)) * 10^(-snr/sArgs.ref);
    noise = mbe_fft(permute(sweepTime + noise,[2,1]));
    irMicrophone = noise(lowerIdx:upperIdx,:).' ./ freqData;
    data(idxDimOne,:,:) = data(idxDimOne,:,:) .* permute(irMicrophone,[3,1,2]);
end

% if data was 2 dimensional restore the matrix format by removing the
% singleton dimension
if dim == 2
    data = permute(data,[2,3,1]);
end

end


function data =  mbe_fft(data,varargin)
% now multidimensional, fft will be calculated along the 1st dimension

% dimension one are the samples
nSamples = size(data,1);

if mod(nSamples,2) == 0
    isEven = true;
else
    isEven = false;
end

if nargin == 2
    signalType = varargin{1};
else
    signalType = 'power';
end

data = fft(data);

if isEven
    data = data(1:(nSamples+2)/2,:,:);
else
    disp('MBE_FFT:: Be careful with odd numbers of time samples!');
    data = data(1:(nSamples+1)/2,:,:);
end

% is power signal divide by number of samples
if strcmp(signalType,'power')
    data = data/nSamples;
    % divide by sqrt(2) to get the effective values
    if isEven
        data(end,:,:) = data(end,:,:)./sqrt(2);
        data(2:end-1,:,:) = data(2:end-1,:,:).*sqrt(2);
    else
        data(2:end,:,:) = data(2:end,:,:).*sqrt(2);
    end
end

end
