function SHfilter2SHrir(this)
% This function extends the frequency range of the filters, calculated by
% itaSphSynthDirectivity.makeSHfilter, and convolve them with the
% measurement.
%
% The result is first saved in a big matrix 'rirData' and then exportet in
% itaAudio-format into the directory this.folder/SH_RIR
%
% see also: itaSphSynthDirectivity, makeSynthArray, makeSHfilter, convolve_itaBalloon_and_SHfilter

if ~strcmpi(this.outputFormat, 'itaAudio')
    error(' ');
end

%check measurement data files
for idxD = 1:length(this.measurementDataFolder)
    testFile = [this.measurementDataFolder{idxD} filesep this.filemask '1.ita']; 
    if ~exist(testFile,'file');
        error(['There is no such file: "' testFile '.ita"']);
    end
end

nmax_l = (this.nmax+1)^2;

actFF = [0 0]; %index Folder and File of the current measurementdata in the memory
freqOffset = length(this.array.freqVector(this.array.freqVector < this.freqVector(1)));

this.myWaitbar(this.nSpeakers+1, 'SHfilter2SHrir');

for idxS = 1:this.nSpeakers
    this.myWaitbar(idxS);
   
    % parse filter data 2 itaAudio
    filter = itaAudio('samplingRate',this.array.samplingRate, 'signalType','energy',...
        'dataType', this.precision);
    filter.freqData     = zeros(this.array.nBins, nmax_l, this.precision);
    filter.freqData(freqOffset+(1:this.nBins),:) = ...
        permute(this.mFilterData.get_data(1:this.nBins, idxS, 1:nmax_l), [1 3 2]);
   
    filter = this.extendFreqRange(filter);
    
    %read measurement data
    TRC = this.speaker2idxTiltRotCh(idxS,:);  %tilt & rotation angle, channel
    FF  = this.idxTiltRot2idxFolderFile{TRC(1),TRC(2)}; %folder file
    if sum(actFF == FF) ~= 2
        % only load if neccessary
        data = ita_read([this.measurementDataFolder{FF(1)} filesep this.filemask int2str(FF(2)) '.ita']);
        actFF = FF;
    end
    
    % initialize output's freqData
    if idxS == 1        
        rirData = zeros(data(1).nBins, nmax_l, data(1).nChannels, this.precision);
        nMic    = data(1).nChannels;
    end
    
    %adapt length of filter and data
    if data(1).nSamples ~= filter.nSamples
        if data(1).nSamples < filter.nSamples
            % that should never happen
            error('sorry, I did not expect that, maybe you could code that?');
        else
            filter = filter.';
            filter = ita_time_window(filter, round(filter.nSamples/2+[-0.005*filter.samplingRate 0]),'samples','symmetric');
            filter = ita_extend_dat(filter, data(1).nSamples,'symmetric');
            filter = filter';
        end
    end
    
    % convolve
    for idxM = 1:nMic
        rirData(:,:,idxM) = rirData(:,:,idxM) + bsxfun(@times, cast(data(TRC(3)).freqData(:,idxM), this.precision), filter.freqData);
    end    
    clear filter;
end

this.myWaitbar(this.nSpeakers+1);

% initialize output objects
if ~isdir([this.folder filesep 'SH_RIR']), 
    mkdir([this.folder filesep 'SH_RIR']);
end


for idxD = 1:nMic
    out = itaAudio;
    out.samplingRate = this.array.samplingRate;
    out.signalType = 'energy';
    out.dataType = this.precision;
    out.freqData = rirData(:,:,idxD);
    
    out.comment = ['SH - RIR (' data(1).channelNames{idxD} ')'];
    out.userData = struct('freqRange', this.freqRange);
    for idxC = 1:out.nChannels
        [n m] = ita_sph_linear2degreeorder(idxC);
        out.channelNames{idxC} = ['sph ' int2str(n) ', ' int2str(m)];
    end
    ita_write(out, [this.folder filesep 'SH_RIR' filesep 'SH_RIR_Mic' int2str(idxD) '.ita']);
end

this.myWaitbar([]);
