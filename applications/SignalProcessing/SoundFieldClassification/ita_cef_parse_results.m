function [mcef_db,lT,lDRR,lSNR,lREP,bs] = ita_cef_parse_results(varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>



sArgs = struct('fileNameFilter','*SFC.mat','saveResult',false,'frange',[400 4000]);
sArgs = ita_parse_arguments(sArgs,varargin);

fileList = rdir(sArgs.fileNameFilter);


T = nan(numel(fileList),1);
DRR = T;
SNR = T;
REP = T;

for idx = 1:numel(fileList)
    [~,fileName] = fileparts(fileList(idx).name);
    tmp = sscanf(fileName,'T_%f_DRR_%f_SNR_%f_rep_%i_SFC');
    T(idx) = tmp(1);
    DRR(idx) = tmp(2);
    SNR(idx) = tmp(3);
    REP(idx) = tmp(4);
end


lT = unique(T);
lDRR = unique(DRR);
lSNR = unique(SNR);
lREP = unique(REP);


%% Build CEF Database

data = load(fileList(1).name);
freqVector = data.sfc_result.cef.freqVector;
FreqIdx = freqVector >= min(sArgs.frange) & freqVector <= max(sArgs.frange);
bs = str2double(data.sfc_result.cef.channelNames);

%cef_db = nan(numel(lT),numel(lDRR),numel(lSNR),numel(lREP),sum(FreqIdx),numel(bs)) + 1i * nan(numel(lT),numel(lDRR),numel(lSNR),numel(lREP),sum(FreqIdx),numel(bs));
mcef_db = nan(numel(lT),numel(lDRR),numel(lSNR),numel(lREP),numel(bs));

%% Fill Database
wb = itaWaitbar(numel(fileList));
for idx = 1:numel(fileList)
    wb.inc();
    try
        data = load(fileList(idx).name);
        idT = find(lT == T(idx),1,'first');
        idDRR = find(lDRR == DRR(idx),1,'first');
        idSNR = find(lSNR == SNR(idx),1,'first');
        idREP = find(lREP == REP(idx),1,'first');
        %cef = (squeeze(nanmean(data.sfc_result.cef.getFreq(100,10000).time(round(data.sfc_result.cef.nSamples/3*2):end,:,:),1)));        
        mcef_db(idT,idDRR,idSNR,idREP,:) = squeeze(abs(nanmean(nanmean(data.sfc_result.cef.getFreq(100,10000).time(round(data.sfc_result.cef.nSamples/3*2):end,:,:),1),2))).';        
        %mcef_db(idT,idDRR,idSNR,idREP,:) = squeeze(nanmean(nanmean(data.sfc_result.cef.getFreqBand(FreqIdx).abs.time(round(data.sfc_result.cef.nSamples/3*2):end,:,:),1),2)).';        

    catch errmsg
       disp(['Could not process: ' fileList(idx).name]); 
    end
end
wb.close();

%% Save Database
if sArgs.saveResult
save('mcef.mat','mcef_db','lT','lDRR','lSNR','lREP','bs','frange')
end

