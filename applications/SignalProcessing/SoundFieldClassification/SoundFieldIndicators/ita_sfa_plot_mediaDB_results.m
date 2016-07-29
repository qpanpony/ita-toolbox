function ita_sfa_plot_mediaDB_results(varargin)

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

evalFeatures = {{'Environment'}...
    ,{'NrOfSources'}...
    ,{'SceneType'}...
    ,{'SourceType'}...
    ,{'Environment', 'SceneType'}...
    ,{'Environment', 'NrOfSources'}...
    ,{'Environment', 'SourceType'}...
    ,{'Environment', 'Subenvironment'}...
    };
MDBfolder = ita_preferences('SFC_MediaDBFolder');

plotfiles = rdir([MDBfolder filesep 'Results_SFC5_SFD2_comp0_autocomp1.mat']);

errorbarwidth = 2;
fontscale = 1;
Filters = {'';'bar';'cafe';'car';'concert hall';'factory'; 'living room'; 'restaurant';'stadium'; 'street'};

plotHist = true;

for idFilter = 1:numel(Filters)
Filter = Filters{idFilter};
for idf = 1:numel(plotfiles)
    for iFeature = 1:numel(evalFeatures)
        
        
        clear nSrcs nSrcsCell;
        allsfc = [];
        load(plotfiles(idf).name);
        
        Features = evalFeatures{iFeature};
        [~, name] = fileparts(plotfiles(idf).name);
        fname = [name '-' genvarname(Filter) '-' [Features{:}]];
        %% Prep input
        clear IDs;
        
        %% BB Mean
        evalsfc = median(allsfc,2);
        
        %% Prep Features
        
        %IDs = upper({allMDBinfo.Environment});
        %IDs = {allMDBinfo.SceneType};
        %IDs = cellstr(num2str([allMDBinfo.NrOfSources].'));
        %IDs = {allMDBinfo.SourceStrength};
        
        % Scale nSrcsToText
        if isfield(allMDBinfo,'NrOfSources')
            nSrcs = [allMDBinfo.NrOfSources].';
            if ~exist('nSrcsCell','var')
                nSrcsCell = cellstr(num2str([allMDBinfo.NrOfSources].'));
                nSrcsCell(nSrcs <3) = {'few'};
                nSrcsCell(nSrcs >=3 & nSrcs < 4) = {'some'};
                nSrcsCell(nSrcs >= 4) = {'xmany'};
                for idx = 1:numel(allMDBinfo)
                    if isnumeric(allMDBinfo(idx).NrOfSources)
                        allMDBinfo(idx).NrOfSources = nSrcsCell{idx};
                    end
                end
            end
        end
        
        for idx = 1:numel(allMDBinfo)
            if strcmpi(allMDBinfo(idx).Environment,'café')
                allMDBinfo(idx).Environment = 'cafe';
            end
            %allMDBinfo(idx).Environment = strrep(allMDBinfo(idx).Environment,' ','-');
        end
        
        IDs = cell(numel(allMDBinfo),1);
        IDs(:) = {''};
        combinations = {};
        for idx = 1:numel(allMDBinfo)
            %    IDs{idx} = [allMDBinfo(idx).Environment ' - ' allMDBinfo(idx).SceneType];
            %    IDs{idx} = [allMDBinfo(idx).Environment ' - ' allMDBinfo(idx).Subenvironment];
            %    IDs{idx} = [allMDBinfo(idx).Environment ' - ' nSrcsCell{idx}];
            %   IDs{idx} = [allMDBinfo(idx).Environment ' - ' nSrcsCell{idx} ' - ' allMDBinfo(idx).SourceStrength];
            IDs{idx} = allMDBinfo(idx).(Features{1});
            for idF = 2:numel(Features)
                if isnan(allMDBinfo(idx).(Features{idF}))
                    allMDBinfo(idx).(Features{idF}) = '';
                end
                IDs{idx} = [IDs{idx} ' - ' allMDBinfo(idx).(Features{idF})];
            end
            
            if ~ischar(IDs{idx})
                IDs{idx} = 'unknown';
            end
        end
        
        uniqueIDs = unique(IDs);
        
        allIDs = cell(size(idxTable,1),size(evalsfc,2));
        for idx = 1:numel(IDs)
            allIDs(idxTable == idx,1:size(evalsfc,2)) = IDs(idx);
        end
        
        IDs = reshape(allIDs,[],1);
        
        evalsfc = reshape(evalsfc,[],4);
        
        % Kick NaNs
        IDs(any(isnan(evalsfc),2)) = [];
        evalsfc(any(isnan(evalsfc),2),:) = [];
        
        if ~isempty(Filter)
            kick = ~strncmpi(IDs,Filter,numel(Filter));
            evalsfc(kick,:) = [];
            IDs(kick) = [];
            if numel(Features) < 2
                IDs = [];
            end
            
        end
        uniqueIDs = unique(IDs);

        %% Mean classification for each environment
        plotsfc = [];
        plotstd = [];
        
        for idx = 1:numel(uniqueIDs)
            plotsfc(idx,:) = nanmean(reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4)); %#ok<*AGROW>
            plotstd(idx,:) = nanstd(reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4));
            sfcmedian(idx,:) = nanmedian(reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4));
            sfcperc25(idx,:) = prctile((reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4)),25);
            sfcperc75(idx,:) = prctile((reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4)),75);
            sfcperc025(idx,:) = prctile((reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4)),2.5); %#ok<*NASGU>
            sfcperc975(idx,:) = prctile((reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4)),97.5);
            
        end
        
        
        %% Bar
        % fh2 = figure();
        % ah2 = axes('Parent',fh2);
        %
        % bar(ah2,1:numel(uniqueIDs), plotsfc + plotstd);
        % hold all;
        % bar(ah2,1:numel(uniqueIDs), plotsfc,'LineWidth',1);
        % hold all;
        % bar(ah2,1:numel(uniqueIDs), plotsfc - plotstd,'w','LineWidth',1,'EdgeColor',[0 0 0]);
        %
        % legend(result.sf(1).sfc.channelNames);
        % %title(uniqueIDs{idx});
        % %set(ah2,'YTick',1:numel(uniqueIDs));
        % %set(ah2,'YTickLabel',uniqueIDs);
        % ylim([0 1]);
        
        %% Errorbar
        if ~isempty(uniqueIDs)
        fh2 = figure();
        ah2 = axes('Parent',fh2);
        
        %bar(ah2,1:4, plotsfc.' + plotstd.');
        %hold all;
        bh = bar(ah2,1:4, plotsfc.','LineWidth',1);
        hold all;
        %figure()
        
        for idb = 1:numel(bh)
            xPos = mean(get(get(bh(idb),'Children'),'XData'),1);
            line_color = get(bh(idb),'FaceColor');
            
            if ~iscell(line_color)
                line_color = {line_color};
            end
            colors = colormap;
            colors = colors(round(linspace(1,size(colors,1),numel(bh))),:);
            if strcmpi(line_color{1},'flat')
                line_color(1) = {colors(idb,:)};
            end
            %lh = boxplot(ah2,reshape(evalsfc(strcmpi(IDs,uniqueIDs{idb}),:,1),[],4).' );
            %lh = errorbar(ah2, xPos , plotsfc(idb,:), plotstd(idb,:),'+','Color',line_color{1});
            %lh = errorbar(ah2, xPos , sfcmedian(idb,:), sfcperc025(idb,:)-sfcmedian(idb,:),sfcmedian(idb,:)-sfcperc975(idb,:),'+','Color',line_color{1},'LineWidth',0.5);
            lh = errorbar(ah2, xPos , sfcmedian(idb,:), sfcperc25(idb,:)-sfcmedian(idb,:),sfcmedian(idb,:)-sfcperc75(idb,:),'+','Color',line_color{1},'LineWidth',errorbarwidth);
            
            
        end
        delete(bh);
        %bar(ah2,1:4, plotsfc.' - plotstd.','w','LineWidth',1,'EdgeColor',[0 0 0]);
        
        %legend(upper(uniqueIDs));
        legend(uniqueIDs);
        %title(uniqueIDs{idx});
        set(ah2,'XTick',1:4);
        set(ah2,'XTickLabel',result.sf(1).sfc.channelNames);
        ylim([0 1]);
        xlim([0.5 4.5]);
        
        if numel(Features) == 1
            template = 'line_1column';
        else
            template = 'line_2column';
        end
        ita_savethisplot_gle('fileName',[fname '_errorbar'],'output','pdf','legend_position','tr','template',template);
        end
        close all;
        %         %% plot (scatter3)
        %         fh1 = figure();
        %         ah1 = axes();
        %
        %         for idx = 1:numel(uniqueIDs)
        %             plotsfc = evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:);
        %             plotsfc = reshape(plotsfc,[],4);
        %             scatter3(ah1,plotsfc(:,1),plotsfc(:,2),plotsfc(:,3),5);
        %             hold(ah1,'all');
        %         end
        %         axes(ah1); %#ok<MAXES>
        %         xlim([0 1]); ylim([0 1]); zlim([0 1])
        %         xlabel(result.sf(1).sfc.channelNames{1});
        %         ylabel(result.sf(1).sfc.channelNames{2});
        %         zlabel(result.sf(1).sfc.channelNames{3});
        %         legend(upper(uniqueIDs));
        %         close all;
        
        %% Plot hist for each environment
        % fh2 = figure();
        %
        % plotsfc = [];
        %
        % for idx = 1:numel(uniqueIDs)
        %     plotsfc{idx} = reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4);
        %     ah2(idx) = subplot(ceil(sqrt(numel(uniqueIDs))),ceil(sqrt(numel(uniqueIDs))),idx);
        %     [N,X] = hist(plotsfc{idx},0:0.01:1);
        %     bar(ah2(idx),X,N);
        %     xlim(ah2(idx),[-0.01 1])
        %     ylim(ah2(idx),[0 1.2*max(max(N(X>.1,:),[],1))]);
        %     hold(ah2(idx),'all');
        %     legend(result.sf(1).sfc.channelNames);
        %     title(upper(uniqueIDs{idx}));
        % end
        
        %% Save hist for each environment
        %evalsfc = evalsfc(:,:,:);
        if isempty(Filter) && plotHist
            plotsfc = [];
            for idx = 1:numel(uniqueIDs)
                fh2 = figure();
                plotsfc{idx} = reshape(evalsfc(strcmpi(IDs,uniqueIDs{idx}),:,:),[],4);
                ah2(idx) = axes('Parent',fh2);
                [N,X] = hist(plotsfc{idx},0:0.02:1);
                bar(ah2(idx),X,N);
                xlim(ah2(idx),[-0.01 1])
                ylim(ah2(idx),[0 1.2*max(max(N(X>.1,:),[],1))]);
                hold(ah2(idx),'all');
                legend(result.sf(1).sfc.channelNames);
                title(upper(uniqueIDs{idx}));
                ita_savethisplot_gle('fileName',[fname '_hist_' genvarname(uniqueIDs{idx})],'output','pdf');
                close(fh2)
            end
        end
        close all
        
        %% Plot (hist)
        if isempty(Filter) && plotHist
            if iFeature == 1 %Only necessary once, same for all Features!
                figure();
                [N,X] = hist(evalsfc,0:0.02:1);
                bar(X,N);
                xlim([-0.01 1])
                ylim([0 1.2*max(max(N(X>.1,:),[],1))]);
                legend(result.sf(1).sfc.channelNames);
                ita_savethisplot_gle('fileName',[fname '_hist_' 'all'],'output','pdf','legend_position','tr');
                
            end
        end
        % %% Hist of hard classification
        % [bla class] = max(evalsfc,[],2);
        %
        % figure();
        % ah2 = axes();
        % hist(class,1:4);
        % %legend(result.sf(1).sfc.channelNames);
        % set(ah2,'XTick',1:4);
        % set(ah2,'XTickLabel',result.sf(1).sfc.channelNames);
        close all
    end
end
end
