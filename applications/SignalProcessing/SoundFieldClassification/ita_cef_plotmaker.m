function ita_cef_plotmaker(varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


sArgs = struct('T','*','DRR','*','SNR','*','REP','*','frange',[400 4000],'resultPath','.','mean',false,'legend','','smooth',3);
sArgs = ita_parse_arguments(sArgs,varargin);



fileNameFilter  = [sArgs.resultPath filesep 'T_' sArgs.T '_DRR_' sArgs.DRR '_SNR_' sArgs.SNR '_rep_' sArgs.REP '_SFC.mat'];

T = str2double(sArgs.T);
DRR = str2double(sArgs.DRR);
SNR = str2double(sArgs.SNR);
REP = str2double(sArgs.REP);



% Get Results
[mcef_db,lT,lDRR,lSNR,lREP,bs] = ita_cef_parse_results('fileNameFilter',fileNameFilter,'frange',sArgs.frange);


if ~isnan(T)
    idT = find(lT == T,1,'first');
else
    idT = 1:numel(lT);
end

if ~isnan(DRR)
    idDRR = find(lDRR == DRR,1,'first');
else
    idDRR = 1:numel(lDRR);
end

if ~isnan(SNR)
    idSNR = find(lSNR == SNR,1,'first');
else
    idSNR = 1:numel(lSNR);
end

if ~isnan(REP)
    idREP = find(lREP == REP,1,'first');
else
    idREP = 1:numel(lREP);
end

%mCEF = squeeze(mcef_db(idT,idDRR,idSNR,idREP,:));

figure();
sf = sArgs.smooth;
colors = colormap;
coloridx = 0;
sumplot = numel(idT)*numel(idDRR)*numel(idSNR);
for ida = 1:numel(idT)
    for idb =1:numel(idDRR)
        for idc = 1:numel(idSNR)
            coloridx = coloridx+1;
            plotthis = mcef_db(idT(ida),idDRR(idb),idSNR(idc),idREP,:);
            if sArgs.mean
               plotthis = cat(4,nanmean(plotthis,4),nanmean(plotthis,4)+nanstd(plotthis,0,4),nanmean(plotthis,4)-nanstd(plotthis,0,4)); 
               plotcolor = [0 0 coloridx/sumplot];
               plot(bs,smooth(squeeze(plotthis(:,:,:,1,:)),sf),'LineStyle','-','Color',plotcolor);
               hold on;
               plot(bs,smooth(squeeze(plotthis(:,:,:,2,:)),sf),'LineStyle',':','Color',plotcolor);
               plot(bs,smooth(squeeze(plotthis(:,:,:,3,:)),sf),'LineStyle',':','Color',plotcolor);
            
            else
                plotthis = squeeze(plotthis);
                plot(bs,plotthis);
            end
            hold all;
        end
    end
end

if ~isempty(sArgs.legend)
    switch sArgs.legend
        case 'T'
            legend(num2str(lT));
            
        otherwise
            legend(sArgs.legend)
    end
end