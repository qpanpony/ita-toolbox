function ita_sfa_mediaDB_export2spss(varargin)
%% Get MDB Results

% <ITA-Toolbox>
% This file is part of the application SoundFieldClassification for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

MDBfolder = ita_preferences('SFC_MediaDBFolder');
load([MDBfolder filesep 'MDBevaluation_tmp.mat']);

%% only part of the data ?
evalsfc = allsfc;

%% Prepare for export
clear fullMDBinfo;
for idx = 1:numel(allMDBinfo)
    fullMDBinfo(idxTable == idx,1:size(evalsfc,2)) = allMDBinfo(idx);
end

%% Infos from MediaDB
MDBinfocell = struct2cell(fullMDBinfo);
MDBinfocell = reshape(MDBinfocell, size(MDBinfocell,1) , [] , 1);
MDBinfocell = cat(2,fieldnames(allMDBinfo) ,MDBinfocell);

%% Infos from SFC
linSFC = reshape(evalsfc,[],4);
SFCinfo = num2cell(linSFC.');
SFCinfo = cat(2,result.sf(1).sfc.channelNames ,SFCinfo);

%% Merge MDB and SFC
MDBinfocell = cat(1,MDBinfocell,SFCinfo); 

%% Export
clear fullMDBinfo result SFCinfo;
dlmcell('test.txt',MDBinfocell.','; ')
