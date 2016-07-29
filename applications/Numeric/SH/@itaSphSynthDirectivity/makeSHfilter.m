function makeSHfilter(this,varargin)
% calculates filter for the synthesis of the single spherical harmonics and
% convolves it with the measured data
%
% input: 
% - encoded      : false/(true) encoded controling of the chassis
% - muteChannels : mute single speaker
% 
% output:
% The RIRs and the filters will also be saved in "this.folder"
%
% see also: itaSyntheticDir, itaSyntheticDir.getPositions,
% itaSyntheticDir.makeSynthSpeaker itaSyntheticDir.convolve_itaBalloon_and_sphRIR
 
% Author: Martin Kunkemoeller, 13.12.2010

% initialize %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sArgs = struct('encoded', false, 'muteChannels', []);
if nargin > 1
    sArgs = ita_parse_arguments(sArgs, varargin);
end

if isnan(this.nmax), error('You must set a maximum order for this synthesis'); end

% maximum order (linear)
nmax_l = (this.nmax+1)^2;

% the big filter matrix (tmp):  format like itaAudio.freqData

this.myWaitbar(this.nBins+1, 'makeSHfilter : calculate filter');

filterData_tmp                  = itaFatSplitMatrix([this.nBins, this.nSpeakers, nmax_l], 1, this.precision);
filterData_tmp.folder           = this.folder;
filterData_tmp.dataFolderName   = 'filterData_tmp';
filterData_tmp.MBytesPerSegment = this.MBytesPerSegment;   



for idxF = 1:this.nBins
    this.myWaitbar(idxF);
    
    D = cast(this.freq2coefSH_synthArray(this.freqVector(idxF), 'nmax', this.nmax), this.precision);
    D(:,sArgs.muteChannels) = 0;
    if sArgs.encoded
        D = this.encodeCoefSH(D);
    end
    
    % matrix invertation, Tikhonov regularization
    invD = (D'*D + this.regularization*eye(size(D,2)))\D';
    
    if sArgs.encoded
        data = permute(this.decodeCoefSH(invD, 1:(this.encode_nmax+1)^2), [3 1 2]);
    else
        data = permute(invD, [3 1 2]);
    end
    filterData_tmp.set_data(idxF, 1:this.nSpeakers, 1:nmax_l, data);
end

this.myWaitbar([]);

%% copy to other split dimension (-> speaker)
this.mFilterData                  = itaFatSplitMatrix([this.nBins, this.nSpeakers, nmax_l], 2, this.precision);
this.mFilterData.dataFolderName   = 'filterData';
this.mFilterData.MBytesPerSegment = this.MBytesPerSegment;   
this.mFilterData.folder           = this.folder;

maxBlockSize_MB = max(400, this.MBytesPerSegment); % if there are problems with "out of memory", decrease this number!!

nBlock = round(maxBlockSize_MB*2^20 / this.nBins / nmax_l / 2);

this.myWaitbar(length(1:nBlock:this.nBins)+1, 'makeSHfilter : sort your data')
for idxF = 1:nBlock:this.nSpeakers
    this.myWaitbar(idxF);
    
    indicees = idxF : idxF+nBlock-1;
    indicees = indicees(indicees <= this.nSpeakers);
    this.mFilterData.set_data(1:this.nBins, indicees, 1:nmax_l, ...
        filterData_tmp.get_data(1:this.nBins, indicees, 1:nmax_l));
end

remove(filterData_tmp);
save(this);
this.myWaitbar([]);
