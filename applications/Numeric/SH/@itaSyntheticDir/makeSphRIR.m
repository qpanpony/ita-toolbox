function out = makeSphRIR(this,varargin)
% calculates filter for the synthesis of the single spherical harmonics and
% convolves it with the measured data
%
% input: 
% -  filemask    : name-extention of the measurement data (for best, give it
%                  all the extentions off all data at a time, that saves time, for example:
%                  {'md_M1_', 'md_M2_', 'md_M3_'}
% (optional)
% -  nmax        : maximum order of synthesized function
% 
% - freq_range   : the range in in which you want to use the array (the
%                  function will extend it a bit, so you have space for filtering
% - encoded      : false/(true) encoded controling of the chassis
% - muteChannels : mute single speaker
% 
% output:
% -  out(idx)    : an itaAudio with the RIRs of all the estimated
%                  basefunctions, measured by the mic specified by the filemask{idx}
% The RIRs and the filters will also be saved in "this.folder"
%
% see also: itaSyntheticDir, itaSyntheticDir.getPositions,
% itaSyntheticDir.makeSynthSpeaker itaSyntheticDir.convolve_itaBalloon_and_sphRIR
 
% Author: Martin Kunkemoeller, 13.12.2010

% initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sArgs = struct('nmax', this.nmax,'filemask', {''}, ...
    'freqRange', this.freqRange, 'encoded', false, 'muteChannels', []);

if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

if isempty(sArgs.filemask), error('I need  filemasks'); end

% make directories
if ~isdir([this.folder filesep 'sphRIR'])
    mkdir([this.folder filesep 'sphRIR']);
end
if ~isdir([this.folder filesep 'sphFilter'])
    mkdir([this.folder filesep 'sphFilter'])
end
if ~isdir([this.folder filesep 'filterData'])
    mkdir([this.folder filesep 'filterData']); %temporary directory
end

%check measurement data files
if ~iscell(sArgs.filemask), sArgs.filemask = {sArgs.filemask}; end
FF = this.idxTiltRot2idxFolderFile{1,1};
for idxD = 1:length(sArgs.filemask)
    if ~exist([this.measurementDataFolder{FF(1)} filesep sArgs.filemask{idxD} int2str(FF(2)) '.ita'],'file');
        error(['There is no such file: "' this.measurementDataFolder{FF(1)} filesep sArgs.filemask{idxD} int2str(FF(2)) '.ita"']);
    end
end

% maximum order (linear)
nmax_l = (this.nmax+1)^2;
nmax_rir = (sArgs.nmax+1)^2;

%indicees of frequencies (refered to the data in the synth object)
idxFreqMinMax = this.freq2idxFreq(sArgs.freqRange .* [1/sqrt(2) sqrt(2)]);
%when mapping indicees to itaAudios, this.speaker etc. always add this
idxFreqOffset = length(this.speaker.freqVector(this.speaker.freqVector < this.freqVector(1)));


% invert the speaker (tikhonov) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ita_verbose_info('itaSyntheticDir:makeSphRIR:Calculate frequency dependent weights for each speaker',1);

% the big filter matrix:
filterData = single(zeros(idxFreqMinMax(2)-idxFreqMinMax(1)+1, this.nApertures, nmax_rir));

for idxB = 1:this.nDataBlock

    %indices for synthSpeaker
    actIdFreq   = this.block2idxFreq(idxB);
    actIdFreq   = actIdFreq(actIdFreq >= idxFreqMinMax(1) & actIdFreq <= idxFreqMinMax(2));
    %indices for filterData
    actIdOut    = actIdFreq-idxFreqMinMax(1)+1;
    if ~isempty(actIdFreq)
        id_blockFreq = this.idxFreq2block(actIdFreq);
        id_blockFreq = id_blockFreq(:,2);

        block = this.read([this.folder filesep 'synthSuperSpeaker' filesep 'freqDataSH_' int2str(idxB)]);
        block = block(1:nmax_l,:,id_blockFreq);
        block(:,sArgs.muteChannels,:) = 0;
        if sArgs.encoded
            block = this.encodeCoefSH(block);
        end

        for idxF = 1:size(block,3)
            % the invertation itself (tikhonov)
            A = squeeze(block(:,:,idxF));
            invSpeaker = pinv(A'*A + this.regularization*eye(size(A,2)), 1e-8)* A';

            if sArgs.encoded
                filterData(actIdOut(idxF),:,:) = single(permute(this.decodeCoefSH(invSpeaker(:,1:nmax_rir,:), 1:(this.encode_nmax+1)^2), [3 1 2]));
            else
                filterData(actIdOut(idxF),:,:) = single(permute(invSpeaker(:,1:nmax_rir,:), [3 1 2]));
            end
        end
    end
end

% unnormalize synthSpeaker
if ~isempty(this.speaker.sensitivity)
    realChannels = this.aperture2idxTiltRotCh(:,3);
    filterData = bsxfun(@rdivide, filterData, this.speaker.sensitivity.value(realChannels));
end

% make sphFilter (serves only for evaluation purposes) %%%%%%%%%%%%%%
for idxC = 1:nmax_rir
    filter = itaAudio;
    filter.samplingRate = this.speaker.samplingRate;
    filter.signalType = 'energy';
    filter.dataType   = 'single';
        freqData = zeros(length(this.speaker.freqVector), this.nApertures);
        freqData(idxFreqOffset+(idxFreqMinMax(1):idxFreqMinMax(2)),:) = filterData(:,:,idxC);
    filter.freqData = freqData;
    filter.channelUserData{1} = 1:this.nApertures;

    [n m] = ita_sph_linear2degreeorder(idxC);
    filter.comment = ['filter for synthesis of sph ' int2str(n) ', ' int2str(m) ' (not smoothed)'];
    ita_write(filter, [this.folder filesep 'sphFilter' filesep 'filter_' int2str(idxC) '.ita' ])
end



% If you have a computer with fantastic much memory, you can set 'nInBlock' to a
% fantastic big number (won't give you a big speedup, bottle neck is somewhere else)
nInBlock = 100;
for idxB = 1:ceil(this.nApertures/nInBlock)
    data = filterData(:,(idxB-1)*nInBlock+1 : min(idxB*nInBlock, this.nApertures),:); %#ok<NASGU>
    save([this.folder filesep 'filterData' filesep 'filterData_' int2str(idxB)],'data');
end
clear('invSpeaker','block','A','data','filterData');

% proceed all measurement data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - make filters 
% - convolve these filters and the data and add it to the final result 'rirData'
% nomenclature : filter.ch(idxN) weights speaker idxA when 
%               basefunction idxN is beeing synthesized
ita_verbose_info('itaSyntheticDir:makeSphRIR:extend filters frequency range and convolve it with the measurements',1);

data = itaAudio(length(sArgs.filemask),1);

actFF = [0 0]; %index Folder and File of the current measurementdata in the memory
actIdxFilter = 0;
for idxA = 1:this.nApertures
    ita_verbose_info([' proceed measurement ' int2str(idxA) ' / ' int2str(this.nApertures)],1);
    
    %read measurement data
    TRC = this.aperture2idxTiltRotCh(idxA,:);  %tilt & rotation angle, channel
    FF  = this.idxTiltRot2idxFolderFile{TRC(1),TRC(2)}; %folder file
    if sum(actFF == FF) < 2
        clear data;
        data = itaAudio(length(sArgs.filemask),1);
        for idxD = 1:length(sArgs.filemask)% proceed all microphone channels at a time
            data(idxD) = ita_read([this.measurementDataFolder{FF(1)} filesep sArgs.filemask{idxD} int2str(FF(2)) '.ita']);
            actFF = FF;
        end
    end
    
    % read filter data and smooth it
    if actIdxFilter ~= ceil(idxA/nInBlock)
        actIdxFilter = ceil(idxA/nInBlock);
        filterData = this.read([this.folder filesep 'filterData' filesep 'filterData_' int2str(actIdxFilter)]);
    end
    
    % (initialize this object always new due to speedup reasons)
    filter = itaAudio;
    filter.samplingRate = this.speaker.samplingRate;
    filter.signalType = 'energy';
    filter.dataType = 'single';
        freqData = zeros(length(this.speaker.freqVector), nmax_rir);
        freqData(idxFreqOffset+(idxFreqMinMax(1):idxFreqMinMax(2)),:) = ...
            squeeze(filterData(:,mod(idxA-1,nInBlock)+1,:));
    filter.freqData = freqData;
    % extend frequency range, no polymomial smoothing
    filter = this.synthesisRule2filter(filter, 'method', 'polyfit','waitbar',false,'extend_only',true);
 
    % initialize output's freqData
    if idxA == 1
        rirData = single(zeros(data(1).nBins, nmax_rir, length(sArgs.filemask)));
    end
    
    %adapt length of filter and data
    if data(1).nSamples ~= filter.nSamples
        if data(1).nSamples < filter.nSamples, error('sorry, I did not expect that, maybe you could code that?'); end;
        filter = ita_time_window(filter, round(filter.nSamples/2+[-0.005*filter.samplingRate 0]),'samples','symmetric');
        filter = ita_extend_dat(filter, data(1).nSamples,'symmetric');
    end
    
    % convolve
    for idxD = 1:length(sArgs.filemask)
        rirData(:,:,idxD) = rirData(:,:,idxD) + single(bsxfun(@times, data(idxD).freqData(:,TRC(3)), filter.freqData));
    end
    
    clear filter;
end

% rmdir([this.folder filesep 'filterData']);
save([this.folder filesep 'rirData'],'rirData'); %developer stuff
%%


% set output object
out = itaAudio(length(sArgs.filemask),1);
for idxD = 1:length(sArgs.filemask)
    out(idxD).samplingRate = this.speaker.samplingRate;
    out(idxD).signalType = 'energy';
    out(idxD).dataType = 'single';
    out(idxD).freqData = rirData(:,:,idxD);
    
    out(idxD).comment = 'RIR of all the basefunctions';
    out(idxD).userData = struct('freqRange', sArgs.freqRange);
    for idxC = 1:out(idxD).nChannels
        [n m] = ita_sph_linear2degreeorder(idxC);
        out(idxD).channelNames{idxC} = ['sph ' int2str(n) ', ' int2str(m)];
    end
    ita_write(out(idxD), [this.folder filesep 'sphRIR' filesep sArgs.filemask{idxD} 'sphRIR.ita']);
end
