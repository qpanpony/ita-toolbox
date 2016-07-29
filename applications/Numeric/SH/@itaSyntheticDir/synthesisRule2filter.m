function varargout = synthesisRule2filter(this, ao, varargin)
sArgs = struct('outputType','ita','bandwidth_filter',[], 'method', 'rationalfit','waitbar',true,'extend_only',false);
if nargin > 2
   sArgs = ita_parse_arguments(sArgs,varargin); 
end

if ~isempty(sArgs.bandwidth_filter) && sArgs.bandwidth_filter.nSamples ~= a.nSamples;
    erros('signal an bandwidth filter must have equal number of samples');
end

if ao.nChannels > 1 
    % recursive, call function again for each channel
    %% split channels
    freqData = zeros(size(ao.freqData));
    if sArgs.waitbar, WB = waitbar(0,' '); end
    
    % change 'outputType'
    idxMethod = find(strcmpi(varargin,'outputType'));
    if isempty(idxMethod)
        varargin = [varargin {'outputType','matrix'}];
    else
        varargin{idxMethod+1} = 'matrix';
    end
    
    for idxC = 1:ao.nChannels
        if idxC == 1 || ~mod(idxC,10)
            if sArgs.waitbar, waitbar(idxC/ao.nChannels, WB, ['approximate synthesis using polynomes (' num2str(idxC/ao.nChannels*100, 2) '% )']); end
        end
        freqData(:,idxC) =  this.synthesisRule2filter(ao.ch(idxC),varargin{:});
    end
    
    if sArgs.waitbar, close(WB); end
    
    
    
else % the function
    if strcmpi(sArgs.method, 'rationalfit')
        
        dum = ao;
        dum.freqData = zeros(size(dum.freqData));
        
        %% rational fit
        find(abs(ao.freqData) > 0, 1, 'first')
        f_low  = ao.freqVector(find(abs(ao.freqData) > 0, 1, 'first')+1);
        f_high = ao.freqVector(find(abs(ao.freqData) > 0, 1, 'last')-1);
        
        % low extension of the (intern) frequency range
        [ext_low] = ita_audio2zpk_rationalfit(ao,'degree',7,'mode','log', 'freqRange', f_low*[1 2]);
        out = ext_low';
%         a = out;
        
        %% main_part
        % cut in to peaces
        oct = 1;
        if f_high/f_low < 2^(1/oct)
            freq = [f_low f_high];
        else
            freq = [];
            for idx = 0:log2(f_high/f_low)*oct
                freq = [freq; f_low*2^(idx/oct)]; %#ok<AGROW>
            end
            freq = [freq(1:end-1)*2^(-1/3) freq(2:end)*2^(1/3)];
            freq(1) = f_low; freq(end) = f_high;
        end
        idxFreq = [ao.freq2index(freq(:,1)) ao.freq2index(freq(:,2))];
        
        % fit with common polynomes
        part = itaAudio;
        for idx = 1:length(idxFreq)
            part.freqData = zeros(ao.nBins,1);
            ind = (idxFreq(idx,1):idxFreq(idx,2)).';
            projInd = (ind - mean(ind))/ std(ind);
            [P S muX] = polyfit(projInd, ao.freqData(ind), min(ceil(length(ind)*0.3), 15)); %#ok<ASGLU>
            part.freqData(ind) = polyval(P, (projInd-muX(1))/muX(2));
            
            
            if idx == 1
                out = ita_xfade_spk(out, part, [f_low f_low*sqrt(2)]);
            else
                out = ita_xfade_spk(out, part, [freq(idx,1) freq(idx-1,2)]);
            end
        end
        
        % high extension of the (intern) frequency range
        [ext_high] = ita_audio2zpk_rationalfit(ao,'degree',30,'mode','log', 'freqRange', f_high*[0.5 1]);
        out = ita_xfade_spk(out, ext_high', f_high*[1/sqrt(2) 1]);
        
        out.freqData(1) = 0;
        
        
        
    else
        %% polynomial approximation (part wise)
         
        oct = 2;     % sections per octave
        overlap = 1/3; % overlap of sections 
        
        idx_FR = [find(abs(ao.freqData)>0, 1, 'first') find(abs(ao.freqData)>0, 1, 'last')];
        f_low  = ao.freqVector(idx_FR(1));
        f_high = ao.freqVector(idx_FR(2));
        freqData = ao.freqData;
        
        if ~isempty(sArgs.bandwidth_filter)
            id = idx_FR(1):idx_FR(2);
            freqData(id) = freqData(id)./sArgs.bandwidth_filter.freqData(id);
        end
        
        % edge frequencies of the sections
        idx = 0:log2(f_high/max(f_low,1))*oct;
        fitSecF = f_low*2.^(idx/oct); 
        if f_high/fitSecF(end) < 2^(1/oct)
            fitSecF = [fitSecF(1:end-1) f_high];
        else
            fitSecF = [fitSecF f_high];
        end
        
        % indices of the sections's first and last frequency bin, including overlaping
        idxFitSec = [[1; max(ao.freq2index(fitSecF*2^(-overlap/2)), idx_FR(1))], [min(ao.freq2index(fitSecF*2^(overlap/2)), idx_FR(2)); ao.nBins]];
        
        % default polynome degrees
        fitSecDegree = min([3; round(0.3*(idxFitSec(:,2) - idxFitSec(:,1))); 3],18);
        
        % first smooth calculatet parts ...
        newStuff = zeros(ao.nBins, size(idxFitSec,1));
        
        for idxS = 2:size(idxFitSec,1)-1
            if ~sArgs.extend_only
                ind = (idxFitSec(idxS,1):idxFitSec(idxS,2)).';
                [P S muX] = polyfit(ind, freqData(ind), fitSecDegree(idxS)); %#ok<ASGLU>
                
                newStuff(ind,idxS) = polyval(P, (ind-muX(1))/muX(2));
            else
                ind = (idxFitSec(idxS,1):idxFitSec(idxS,2)).';
                newStuff(ind,idxS) = freqData(ind);
            end
        end
        
        meanAmp = mean(abs(freqData(idx_FR(1):idx_FR(2))));
        
        % ... then extend the first part of the frequency range ...
        ind = (idxFitSec(2,1):idxFitSec(1,2)).';
        
        nAddPoints = floor(min(length(ind), ind(1)/2)/2)*2;
        data = freqData(ind);
        
        ind = [(1:nAddPoints).'; ind];
        data = [repmat(meanAmp, nAddPoints, 1);  data];
        
        [P S muX] = polyfit(ind, data , fitSecDegree(1)); %#ok<ASGLU>
        newInd = ind(1):ind(end);
        newStuff(newInd,1) = polyval(P, (newInd-muX(1))/muX(2));
        
        % ... and extend the end of the frequency range 
        ind = (idxFitSec(end,1):idxFitSec(end-1,2)).';
        nAddPoints = length(ind); 
        p1 = 0.25*ind(end) + 0.75*ao.nBins; pe = ao.nBins;
        addPoints = (round(p1) : round((pe-p1)/(nAddPoints)) : round(pe)).';
        addPoints(end) = ao.nBins;
        
        data = freqData(ind);
        
        ind = [ind; addPoints];
        data = [data; repmat(meanAmp, length(addPoints), 1)];
        
        [P S muX] = polyfit(ind, data , fitSecDegree(end)); %#ok<ASGLU>
        newInd = ind(1):ind(end);
        newStuff(newInd,end) = polyval(P, (newInd-muX(1))/muX(2));
        
        
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
        
        freqData(1) = 0; %no DC
        
    end
end

% select output type
if strcmpi(sArgs.outputType, 'matrix')
    if strcmpi(sArgs.method, 'rationalfit')
        varargout{1} = out.freqData;
    else
        varargout{1} = freqData;
    end
else
    varargout{1} = ao;
    if strcmpi(sArgs.method, 'rationalfit')
        varargout{1}.freqData = out.freqData;
    else
        varargout{1}.freqData = freqData;
    end
    
end



