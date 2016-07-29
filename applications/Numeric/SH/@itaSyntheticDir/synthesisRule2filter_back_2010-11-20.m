function varargout = synthesisRule2filter(this, a, varargin)
sArgs = struct('format','ita','method','rationalfit','bandwidth_filter',[]);
if nargin > 2
   sArgs = ita_parse_arguments(sArgs,varargin); 
end

if ~isempty(sArgs.bandwidth_filter) && sArgs.bandwidth_filter.nSamples ~= a.nSamples;
    erros('signal an bandwidth filter must have equal number of samples');
end

if a.nChannels > 1
    %% split channels
    freqData = zeros(size(a.freqData));
    WB = waitbar(0,' ');
    for idxC = 1:a.nChannels
        if idxC == 1 || ~mod(idxC,10)
            waitbar(idxC/a.nChannels, WB, ['smooth filter using polynomes (' num2str(idxC/a.nChannels*100, 2) '% )']);
        end
        if sum(abs(a.ch(idxC).freqData));
            freqData(:,idxC) =  this.polynomial_smoothing(a.ch(idxC), 'format', 'matrix', 'method', sArgs.method, 'bandwidth_filter', sArgs.bandwidth_filter);
        end
    end
    close(WB);
else
    if strcmpi(sArgs.method,'rationalfit')
        freq_range = a.freqVector([find(abs(a.freqData), 1, 'first') find(abs(a.freqData), 1, 'last')]);
        dum = ita_audio2zpk_rationalfit(a, 'degree',20,'mode','lin','freqRange',freq_range);
        freqData = dum.freqData;
    else
        %% Abschnittsweises Polynomfitten
        
        overlap = 1/3;
        oct = 1.5;
        
        freq_range = a.freqVector([find(a.freqData ~=0, 1, 'first') find(a.freqData ~=0, 1, 'last')]);
        idx_FR = a.freq2index(freq_range);
        
        if ~isempty(sArgs.bandwidth_filter)
            id = idx_FR(1):idx_FR(2);
            a.freqData(id) = a.freqData(id)./sArgs.bandwidth_filter.freqData(id);
        end
        
        fitSecF = [];
        for idx = 0:log2(max(freq_range)/min(freq_range))*oct
            fitSecF = [fitSecF min(freq_range)*2^(idx/oct)]; %#ok<AGROW>
        end
        if max(freq_range)/max(fitSecF) < 2^(1/oct)
            fitSecF = [fitSecF(1:end-1) max(freq_range)];
        else
            fitSecF = [fitSecF max(freq_range)];
        end
        
        fitSecN = [3 15*ones(1,ceil(length(fitSecF)/2))...
            19*ones(1,floor(length(fitSecF)/2)) 4];
        
        idxFitSec = zeros(length(fitSecF)+1,2);
        
        for idx = 1:length(fitSecF)+1
            if idx == 1
                idxFitSec(idx,:) = [1 a.freq2index(fitSecF(idx)*2^overlap)];
            elseif idx <= length(fitSecF)
                idxFitSec(idx,:) = [a.freq2index(max(min(freq_range), fitSecF(idx-1)*2^(-overlap)))...
                    a.freq2index(min(max(freq_range), fitSecF(idx)*2^overlap))];
            else
                idxFitSec(idx,:) = [a.freq2index(fitSecF(idx-1)*2^(-overlap)) a.nBins];
            end
        end
        
        %% Zuerst die Abschnitte glätten, die berechnet wurden ...
        newStuff = zeros(a.nBins, size(idxFitSec,1));
        
        for idxS = 2:size(idxFitSec,1)-1
            indices = (idxFitSec(idxS,1):idxFitSec(idxS,2)).';
            projIndices = (indices - mean(indices))/ std(indices);
            [P S muX] = polyfit(projIndices, a.freqData(indices), fitSecN(idxS)); %#ok<ASGLU>
            
            newStuff(indices,idxS) = polyval(P, (projIndices-muX(1))/muX(2));
        end
        
       
        %% ...dann Anfang ...
        
        idxCut = a.freq2index(60);
        nAddPoints = 4; %even number
        indices = (idxFitSec(2,1):idxFitSec(1,2)).';
        addPoints = [1:nAddPoints/2 idxCut+(1:nAddPoints/2-1)].';
        addPoints = addPoints(addPoints < indices(1));
        data = a.freqData(indices);
        indices = [addPoints; indices];
        
        data = [ repmat(mean(abs(a.freqData(idx_FR(1):idx_FR(2)))), length(addPoints), 1);  data];
        
        [P S muX] = polyfit(indices,data , fitSecN(1));
        indices = min(indices):max(indices);
        newStuff(indices,1) = polyval(P, (indices-muX(1))/muX(2));
        
        %% ... und Ende des Frequenzbereichs ergänzen
        indices = (idxFitSec(end,1):idxFitSec(end-1,2)).';
        data = a.freqData(indices);
       
        p1 = 0.25*max(indices)+0.75*a.nBins; pe = a.nBins;
        addPoints = (round(p1) : round((pe-p1)/(nAddPoints)) : round(pe)).';
        addPoints(end) = a.nBins;
        indices = [indices; addPoints];
        data = [data; repmat(mean(abs(a.freqData(idx_FR(1):idx_FR(2)))), length(addPoints), 1)];
        
        [P S muX] = polyfit(indices,data , fitSecN(end));
        indices = min(indices):max(indices);
        newStuff(indices,end) = polyval(P, (indices-muX(1))/muX(2));
        
        %% xover über Abschnitte
        freqData = newStuff(:,1);
        for idxS = 1:size(newStuff,2)-1
            xover = ones(size(newStuff,1),2);
            xover(idxFitSec(idxS,2)+1:end,1) = 0;
            xover(1:idxFitSec(idxS+1,1)-1,2) = 0;
            
            lX = idxFitSec(idxS,2)-idxFitSec(idxS+1,1);
            xover(idxFitSec(idxS+1,1):idxFitSec(idxS,2),2) = (0:lX)/lX;
            xover(idxFitSec(idxS+1,1):idxFitSec(idxS,2),1) = 1-xover(idxFitSec(idxS+1,1):idxFitSec(idxS,2),2);
            
            freqData = sum(xover .* [freqData newStuff(:,idxS+1)],2);
        end
        
        
        freqData(1) = 0;
        freqData(end) = freqData(end)/2;
        freqData = freqData*sqrt(2)/a.nSamples;
        
        if ~isempty(sArgs.bandwidth_filter)
            freqData = freqData .* sArgs.bandwidth_filter.freqData;
        end
        
    end
end
    
if strfind(sArgs.format,'it')
    varargout{1} = a;
    varargout{1}.freqData = freqData;
else
    varargout{1} = freqData;
end
