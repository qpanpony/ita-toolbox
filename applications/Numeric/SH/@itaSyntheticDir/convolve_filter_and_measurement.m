function out = convolve_filter_and_measurement(this, filter, filemask)

apertures = filter.channelUserData;
if isempty(apertures)
    error('I got no channelUserData, now I have a problem');
end

myWaitbar(filter.nChannels+1);

for idxF = 1:length(this.measurementDataFolder)
   if ~numel(dir([this.measurementDataFolder{idxF} filesep filemask '*']))
       error('you filemask does not seem to work');
   end
end

for idxC = 1:filter.nChannels
    myWaitbar(idxC);
    
    TRC = this.aperture2idxTiltRotCh(apertures{idxC},:);  %tilt rotation angle
    FF  = this.idxTiltRot2idxFolderFile{TRC(1),TRC(2)}; %folder file
    
    data = ita_read([this.measurementDataFolder{FF(1)} filesep filemask int2str(FF(2)) '.ita']);
    data = data.ch(TRC(3));
    
    if idxC == 1 %only the first time
        if data.nSamples < filter.nSamples
            nSamples_original = data.nSamples;
        else
            nSamples_original = 0;
            filter = ita_time_window(filter, round(filter.nSamples/2+[-0.005*filter.samplingRate 0]),'samples','symmetric');
            filter = ita_extend_dat(filter, data.nSamples,'symmetric');
            filter = filter';
        end
        
        outData = zeros(data.nBins,1);
    end
    if nSamples_original, %only if filter is longer than the data
        data = ita_extend_dat(data, filter.nSamples);
    end
    
    outData = outData + data.freqData .* filter.ch(idxC).freqData;
end

% conclude
myWaitbar(filter.nChannels+1);

out = data;
out.freqData = outData;

if nSamples_original
    out = ita_time_crop(out,[1 nSamples_original]);
end

out.channelNames = {' '};
out.channelCoordinates.cart = nan(1,3);
% out = ita_time_window(out, out.nSamples + [-300 0],'samples');

if ~isempty(filter.userData)
out = ita_time_shift(out, filter.userData{1}.timeShift, 'samples');
end
%

myWaitbar([]);
end

function myWaitbar(in)
persistent WB maxN;

if ~exist('maxN','var') || isempty(maxN)...
        || exist('WB','var') && ~ishandle(WB);
    maxN = in;
    WB = waitbar(0, 'convolve (initialize)');

elseif in < maxN
    waitbar(in/maxN, WB, ['convolve (proceed channel ' int2str(in) ' / ' int2str(maxN-1) ')']);
else
    waitbar(1, WB, ['convolve (finish)']);
end

if isempty(in)
    close(WB);
end
end