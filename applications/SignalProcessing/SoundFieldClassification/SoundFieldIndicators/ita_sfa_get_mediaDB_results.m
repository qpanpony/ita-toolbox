function ita_sfa_get_mediaDB_results
%% Settings

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

meanblocks = 1 .* 460;
broadbandMean = false;

%% Get MediaDB folder
MDBfolder = ita_preferences('SFC_MediaDBFolder');

%% Read results
resultfiles = rdir([MDBfolder filesep '**' filesep 'sfresult.mat']);

allsfc = [];
idxTable = [];
for idx = 1:numel(resultfiles)
    disp(idx./numel(resultfiles).*100);
    result = load(resultfiles(idx).name);
    result = result.result;
    
    % SFC
    for idsf = 1:numel(result.sf)
        thissfc = result.sf(idsf).sfc.time;
        if broadbandMean 
            thissfc = nanmedian(thissfc,2); % Freq-Mean
        end
        nBlocks = floor(size(thissfc,1)/meanblocks)+1;
        thissfc_rest = thissfc(((nBlocks-1)*meanblocks)+1:end,:,:); % The samples that dont fit into blocks of size meanblocks
        thissfc = thissfc(1:((nBlocks-1)*meanblocks),:,:);
        if isempty(thissfc) % Signal shorter than meanblocks
            thissfc = nanmedian(thissfc_rest,1);
        else
            thissfc = cat(1, reshape(nanmedian(reshape(thissfc, meanblocks, [], 4),1),[],size(thissfc,2),size(thissfc,3)), nanmedian(thissfc_rest,1)); % Mean blocks
        end
        %thissfc = reshape(thissfc,[],4);
        allsfc = cat(1, allsfc, thissfc);
        idxTable((end+1):(end+nBlocks)) = idx;
    end
    
    % MDBinfo
    allMDBinfo(idx) = result.MDBinfo;
    
end

filename = [MDBfolder filesep 'Results'];

filename = [filename '_SFC' int2str(result.sfc_method) '_SFD' int2str(result.sfd_method) '_comp' int2str(result.compensate), '_autocomp' int2str(result.autocompensate)];

if broadbandMean
    filename = [filename '_BB'];
end


filename = [filename '.mat'];
save(filename);

end