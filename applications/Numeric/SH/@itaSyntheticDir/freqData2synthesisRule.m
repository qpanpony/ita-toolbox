function [out maintainedChannels] = freqData2synthesisRule(this, inputData, idxFreqMinMax, varargin)

% inputData       : like itaAudio or itaResult...
% idxFreqMinMax   : minimal and maximal frequency index of the given input
%                   data. The index refers to "this.freqVector", 
%                   not to "this.speaker.freqVector" !!

sArgs = struct('muteChannels',[], 'nmax', this.nmax, ...
    'optimize_freq_range',[], 'freqRange',  this.freqRange,'encoded',false);
if nargin > 3
    sArgs = ita_parse_arguments(sArgs, varargin);
end

%init, check input
if size(inputData,2) ~=(sArgs.nmax+1)^2
    error(['size(inputData,2) must be equal to the number of basefunctions : (nmax+1)^2']);
end

if size(inputData,1) == 1
    freqDependendInput = false;
    idxFreqMinMax = this.freq2idxFreq(sArgs.freqRange .*2.^[-0.5 0.5]);
    
elseif size(inputData,1) == length(idxFreqMinMax(1):idxFreqMinMax(2))
    freqDependendInput = true;
else
    error(['Dimension of input data mismatch']);
end

idFreqOffSet = length(this.speaker.freqVector(this.speaker.freqVector < this.freqVector(1)));


%kill silent input data
maxValue = max(max(abs(inputData)));
inputData(:, mean(abs(inputData),1) < maxValue*1e-6) = 0;

inputData = inputData.'; % switch dimensionality [coef frequency] %%%

% kill redundant apertures %%%%
if this.target_tolerance
    
    % estimate frequency bins for optimization
    nOptimisationFreq = 10;
    if isempty(sArgs.optimize_freq_range) 
        %default optimization range: last half octave of frequency range
        idMin = this.freq2idxFreq(this.freqVector(idxFreqMinMax(2))/sqrt(2));
        idMax = idxFreqMinMax(2);
        
    else 
        idMin = max(this.freq2idxFreq(sArgs.optimize_freq_range(1)), idxFreqMinMax(1));
        idMax = min(this.freq2idxFreq(sArgs.optimize_freq_range(2)), idxFreqMinMax(2)); 
    end
    idxOptFreq = idMin : round((idMax-idMin)/(nOptimisationFreq-1)) : idMax;
    
    % get data for optimization
    firstBlock = this.freq2coefSH_synthSpeaker(this.freqVector(idxOptFreq), 'nmax',sArgs.nmax, 'normalized');
    firstBlock(:,sArgs.muteChannels,:) = 0;
    if sArgs.encoded
        firstBlock = this.encodeCoefSH(firstBlock);
    end
    
    % kill
    if ~freqDependendInput, idxOptFreq = 1; end
    maintainedChannels = killApertures(this, firstBlock, inputData(:,idxOptFreq));
    
else
    if sArgs.encoded
        maintainedChannels = 1:(this.encode_nmax+1)^2;
    else
        maintainedChannels = 1:this.nApertures;
    end
end

% initialize outputData %%
% can refer to both, an not encoded or encoded synthSpeaker
outputData = zeros(length(this.speaker.freqVector), length(maintainedChannels));

% proceed all data   %%%%%
for idxB = 1:this.nDataBlock
    %indices for synthSpeaker, input and output
    actIdFreq   = this.block2idxFreq(idxB);
    actIdFreq   = actIdFreq(actIdFreq >= idxFreqMinMax(1) & actIdFreq <= idxFreqMinMax(2));
    actIdInput  = actIdFreq - idxFreqMinMax(1) + 1;
    actIdOutput = actIdFreq + idFreqOffSet;
    
    if ~isempty(actIdFreq)
        id_blockFreq = this.idxFreq2block(actIdFreq); 
        id_blockFreq = id_blockFreq(:,2);
        
        block = this.read([this.folder filesep 'synthSuperSpeaker' filesep 'freqDataSH_' int2str(idxB)]);
        block = block(1:(sArgs.nmax+1)^2,:,id_blockFreq);
        block(:,sArgs.muteChannels,:) = 0;
        if sArgs.encoded
            block = this.encodeCoefSH(block);
        end
        block = block(:,maintainedChannels,:);
        
        outputData(actIdOutput,:) = ...
            synthFilter(this, block, inputData(:,actIdInput), this.nIterations);
    end
end

% if speaker was encoded, now decode :-)
if sArgs.encoded
    outputData = (this.decodeCoefSH(outputData.', maintainedChannels)).';
    % from now on, "maintainedChannels" refers again to real and not to encoded channels
    maintainedChannels = 1:this.nApertures; 
end

% deEqualize synthSpeaker
if ~isempty(this.speaker.sensitivity)
    realChannels = this.aperture2idxTiltRotCh(maintainedChannels,3);
    outputData = bsxfun(@rdivide, outputData, this.speaker.sensitivity.value(realChannels));
end

% if ~isempty(sArgs.response) %vielleicht mal wo anders unterbringen...
%     outputData(idFreqOffSet+(1:length(this.freqVector)),:) = ...
%     bsxfun(@times, outputData(idxOffset+(1:length(this.freqVector)),:), ...
%         sArgs.response.freqData(sArgs.response.freq2index(this.freqVector)));
% end

out = itaAudio;
out.samplingRate = this.speaker.samplingRate;
out.signalType = 'energy';
out.dataType = 'single';
out.freqData = outputData;
for idxC = 1:out.nChannels
    % set channelUserData so itaSyntheticDir.convolve will find the proper RIR
    out.channelUserData{idxC} = maintainedChannels(idxC);  
    out.channelNames{idxC} = ['aperture ' int2str(maintainedChannels(idxC))];
end
end

%%
function out = synthFilter(this, speaker, inputData, nIterations)
out = zeros(size(speaker,3), size(speaker,2)); % nFreq, nChannels

input = inputData(:,1);

% solve the invertation problem for every frequency
for idxF = 1:min(size(speaker,3),size(inputData,2)) 
    
    %choose proper input data
    if size(inputData,2) > 1
       input = inputData(:,idxF);
    end
    
    % invert the speaker (tikhonov)
    A = squeeze(speaker(:,:,idxF));
    invSpeaker = pinv(A'*A + this.regularization*eye(size(A,2)), 1e-8)* A';
    
    % if condition was too bad... (is this still necessary ???)
    if ~isempty(find(isnan(invSpeaker),1))
        disp(['sorry, had to kill a frequency due to a miserable condition'])
        invSpeaker = 0;
    end
    
     
    if ~nIterations    
        out(idxF,:) = (invSpeaker * input).';
    else
        % if the invertation was ambiguous, get the solution which is close
        % to only half of the speakers switched on.
        dum = zeros(size(speaker,2),1);
        thresh = 1e-6;
        
        vector_1 = invSpeaker*input;
        matrix_2 = eye(size(speaker,2)) - invSpeaker*speaker(:,:,idxF);
        
        for idxI = 1:this.nIterations
            dum =  vector_1 + matrix_2*dum;
            meanAmplitude = mean(abs(dum).^2,2);
            while(1)
                if length(meanAmplitude/max(meanAmplitude) < thresh) < 0.5*size(dum,2)
                    thresh = thresh*increase_threshold(1);
                else
                    dum(meanAmplitude/max(meanAmplitude) < thresh,:) = 0;
                    break;
                end
            end
        end
        out(idxF,:) = (vector_1 + matrix_2*dum).';
    end
end
end

%%
function switchedOn = killApertures(this, speaker, inputData)
%%
switchedOn = 1:size(speaker,2); %indicees of the apertures that are not muted
nFreq = size(speaker,3);

% theoretically achievable result (no aperture muted)
actFilter = synthFilter(this, speaker, inputData, 0).';
idealResult = zeros(nFreq,1);
for idxF = 1:nFreq
    idealResult(idxF) = inner_product(speaker(:,:,idxF)*actFilter(:,idxF), inputData(:,idxF));
end

%%
could_kill = [1 1];
method = 0;

%iterative killing redundant apertures
while(1)
    
    %kill under two assumptions
    method = mod(method,2)+1;
    could_kill(2) = could_kill(1); %short fifo-buffer
    switch method
        case 1  % method 1: kill silent speaker
            meanP = mean(abs(actFilter).^2, 2);
            thres = 10^(-60/10); %start at -60 dB
            maybeSwitchedOn = switchedOn(meanP/max(meanP) > thres);
            while length(maybeSwitchedOn) > 0.8* length(switchedOn)
                thres = thres*10^0.5;
                maybeSwitchedOn = switchedOn(meanP/max(meanP) > thres);
            end
            
        case 2 % method 2: kill speaker which are similar to the loudest one
            if length(switchedOn) > 1
            [dum idxMax] = max(sum(abs(actFilter).^2, 2)); %#ok<ASGLU>
            correlation = zeros(1,length(switchedOn));
            for idxA = 1:length(switchedOn)
                correlation(idxA) = inner_product(squeeze(speaker(:, switchedOn(idxA), :)), squeeze(speaker(:,switchedOn(idxMax),:)));
            end
            [dum idxMaintain] = sort(correlation, 'ascend'); %#ok<ASGLU>
            idxMaintain = idxMaintain(idxMaintain ~= idxMax); %don't kill the loudest one itself :-)
            idxMaintain = [idxMaintain(1:round(0.8*length(idxMaintain))) idxMax];
            maybeSwitchedOn = switchedOn(sort(idxMaintain));
            else
                maybeSwitchedOn = [];
            end
    end
    
    %check if the result is still better than the given tolerance, if so
    %accept the elemination
    if ~isempty(maybeSwitchedOn)
        maybeFilter = synthFilter(this, speaker(:, maybeSwitchedOn, :), inputData, 0).';
        maybeResult = zeros(nFreq,1);
        for idxF = 1:nFreq
            maybeResult(idxF) = inner_product(speaker(:,maybeSwitchedOn,idxF)*maybeFilter(:,idxF), inputData(:,idxF));
        end
        
        % 90% of the synthesized frequencies must be better than given
        % tolerance
        if sum(maybeResult/mean(idealResult) > 10^(this.target_tolerance/10))/length(idealResult) > 0.9
            switchedOn = maybeSwitchedOn;
            actFilter = maybeFilter;
            could_kill(1) = 1;
            
            disp(['method ' int2str(method) ' : number of apertures reduced to ' int2str(length(switchedOn))]);
            if length(switchedOn) < 6
                disp(['  speaker : ' int2str(switchedOn)]);
            end
        else
            could_kill(1) = 0;
        end
    else
        could_kill(1) = 0;
    end
    
    if ~sum(could_kill) % test case || length(switchedOn) < 80
        break;
    end
end
end

function coef = inner_product(A,B)
    %returns the mean normalized inner product of the columns of A and B
    coef = mean(abs(sum(conj(A) .* B, 1))./sqrt(sum(abs(A).^2, 1).*sum(abs(B).^2, 1)));
end

