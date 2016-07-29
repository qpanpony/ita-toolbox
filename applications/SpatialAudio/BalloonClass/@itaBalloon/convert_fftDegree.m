function son = convert_fftDegree(this, new_fftDegree, new_balloonFolder)
%son = convert_fftDegree(this, newFftDegree, newBalloonFolder)
% creates a new itaBalloon-object with fftDegree "new_fftDegree"
% in the directory "new_balloonFolder" (default : [this.balloonFolder '_d'])

% <ITA-Toolbox>
% This file is part of the application BalloonClass for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


if ~strcmpi(this.inputDataType, 'itaAudio') || isempty(this.fftDegree)
    error('your input data were no "itaAudios", so conversion of fftDegree makes no sense');
end
if nargin == 1
    error('give me at least a fftDegree');
end

% initialize new balloon
save(this);
son = itaBalloon(this);
if exist('new_balloonFolder','var')
    son.balloonFolder = new_balloonFolder;
else
    son.balloonFolder = [this.balloonFolder '_d'];
end


if ~son.mData.isempty
    error('there are already balloonData in this folder !!');
end


for idxC = 1: this.nChannels %faster to do channel by channel than point by point :-)
    if this.nChannels > 1
        ita_verbose_info(['itaBalloon:convert_fftDegree:procceed channel ' int2str(idxC)],0);
    end
    % number of points which are proceeded at a time
    % if you have problems with 
    %                        "out of memory" , 
    % decrease that number
    blocksize = 8000; 
    
    for idxPB = 1: ceil(this.nPoints/blocksize)
        idPoints = (idxPB-1)*blocksize+1 : min(idxPB*blocksize, this.nPoints);
        
        %read data
        ao = this.idxPoint2itaAudio(idPoints, 'sum_channels', true, 'normalized', 'channels', idxC);
        
        %adapt ftDegree
        if new_fftDegree > this.fftDegree
            ao = ita_time_window(ao, round(ao.nSamples/2+[-0.005*ao.samplingRate 0]),'samples','symmetric', 'dc', false);
            ao = ita_extend_dat(ao, round(2^new_fftDegree), 'symmetric');
        else
            ao = ita_extract_dat(ao, round(2^new_fftDegree), 'symmetric');
            ao = ita_time_window(ao, round(ao.nSamples/2 + [-0.005*ao.samplingRate 0]),'samples','symmetric', 'dc', false);
        end
        
        
        % set son's data sructure
        if idxPB == 1
            son.fftDegree = new_fftDegree;
            son.freqVector = ao.freqVector;
            son.nBins = length(son.freqVector);
            son.mData = itaFatSplitMatrix([son.nPoints, son.nChannels, son.nBins], 3, son.precision);
            son.mData.folder = son.balloonFolder;
            son.mData.dataFolderName = 'balloonData';
            son.mData.dataFileName   = 'freqData_';
        end
        son.mData.set_data(idPoints, idxC , 1:son.nBins, permute(ao.freqData, [2 3 1]));%[freq point] -> [point channel freq]
    end
end

% if original balloon has some spherical harmonic coefficients,
% calculate them also for the son
if isa(this, 'itaBalloonSH') && this.existSH
    if isa(this.positions, 'itaSamplingSphReal')
        son.makeSH(this.nmax, 'type','real');
    else
        son.makeSH(this.nmax);
    end
end

save(son);
end