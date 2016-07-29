function ao = extendFreqRange(this, ao)
%
% this function smoothes and extends the a calculated frequency response
% using rational fit (must be improoved) or polynomes
%



overlap = 1/3; % overlap of sections
fitSecDegree = [3 18];

%% initialize
freqData   = ao.freqData;
outData    = zeros(size(freqData), this.precision);

% estimate frequency range
channel = 1;
while ~sum(abs(freqData(:,channel))) && channel < ao.nChannels
    channel = channel + 1;
end
idx_FR  = [find(abs(freqData(:,channel))>0, 1, 'first'),...
    find(abs(freqData(:,channel))>0, 1, 'last')];

% mean amplitude
meanAmp = mean(abs(freqData(idx_FR(1):idx_FR(2),:)), 1);

if idx_FR(1) > 1
    % indicees to extend the first part of the frequency range ...
    ids_fit = ao.freq2index(ao.freqVector(idx_FR(1)*[1 2^overlap]));
    nAddPs = floor(min(length(ids_fit), ids_fit(1)/2)/2)*2;
    ids_all = [(1:nAddPs).'; ids_fit];
    newIds = ids_all(1):ids_all(end);
    extend_low = true;
    fitSecDegree(1) = min(fitSecDegree(1), length(ids_all)-1);
else
    extend_low = false;
    ids_fit    = [1 1];
end
if idx_FR(2) < ao.nBins
    % indicees to extend the end of the frequency range
    ide_fit = ao.freq2index(ao.freqVector(idx_FR(2)*[2^(-overlap) 1]));
    nAddPe = length(ide_fit);
    p1 = 0.25*ide_fit(end) + 0.75*ao.nBins; pe = ao.nBins;
    addPe = (round(p1) : round((pe-p1)/(nAddPe)) : round(pe)).';
    addPe(end) = ao.nBins;
    ide_all = [ide_fit; addPe];
    newIde = ide_all(1):ide_all(end);
    extend_high = true;
    fitSecDegree(2) = min(fitSecDegree(2), length(ide_all)-5);
else
    extend_high = false;
    ide_fit     = [1 1]*ao.nBins;
end
%% xover
xover = zeros(size(freqData,1),2, this.precision);
xover(1:ids_fit(1)         ,1) = 1;
xover(ids_fit(2):ide_fit(1),2) = 1;
xover(ide_fit(2):end,       3) = 1;

if extend_low
    % first X
    lX = ids_fit(2)-ids_fit(1);
    xover(ids_fit(1):ids_fit(2),1) = 1 - (0:lX)/lX;
    xover(ids_fit(1):ids_fit(2),2) = (0:lX)/lX;
end
if extend_high
    % second X
    lX = ide_fit(2)-ide_fit(1);
    xover(ide_fit(1):ide_fit(2),2) = 1 - (0:lX)/lX;
    xover(ide_fit(1):ide_fit(2),3) = (0:lX)/lX;
end
nBins = ao.nBins;
for idxC = 1:ao.nChannels
    newStuff = zeros(nBins,2, this.precision);
    if extend_low
        % extend the first part of the frequency range ...
        datas     = freqData(ids_fit, idxC);
        [P S muX] = polyfit(ids_all, [repmat(meanAmp(idxC), nAddPs, 1);  datas] , fitSecDegree(1)); %#ok<ASGLU>
        newStuff(newIds,1) = polyval(P, (newIds-muX(1))/muX(2));
    end
    if extend_high
        % extend the second part of the frequency range ...
        datae = freqData(ide_fit, idxC);
        [P S muX] = polyfit(ide_all, [datae; repmat(meanAmp(idxC), length(addPe), 1)], fitSecDegree(2)); %#ok<ASGLU>
        newStuff(newIde,2) = polyval(P, (newIde-muX(1))/muX(2));
    end
    %% xover über Abschnitte
    outData(:,idxC) = sum([newStuff(:,1) freqData(:,idxC) newStuff(:,2)] .* xover, 2);
end
ao.freqData = outData;
