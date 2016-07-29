function test_rbo_eval_movingWall_LT

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Info
% -------------------------------------------------------------------------
% Groups ------------------------------------------------------------------
% -------------------------------------------------------------------------
% 1	Gepulstes Rauschen kurz
% 2	Gepulstes Rauschen lang
% 3	Sprache: Zahl
% 4	Sprache: Schreck
% 5	Musik Gitarre
% 6	Musik Trommel
% 7	Musik Trompete
% -------------------------------------------------------------------------
%% Load data
path        = 'C:\Users\bomhardt\Desktop\zeug\Projekte\2014_DFG Antrag - Geometrie\2015_WallMove';
%path        = 'M:\ListeningTest\Saves\Results';
if exist(path)==0
    path = uigetdir(ita_toolbox_path,'Choose result folder...');
end
close all

dataTmp     = dir( fullfile(path,'*.mat') );
nSubj       = numel(dataTmp);
dataTmp2    = cell(nSubj,1);
subjectName = cell(nSubj,1);
subjectData = cell(nSubj,1);
groupID     = zeros(nSubj,1);
age         = zeros(nSubj,1);
gender      = zeros(nSubj,1);

for iIDs = 1:nSubj
    dataTmp2{iIDs}  = load([path '\' dataTmp(iIDs).name ]  );
    groupID(iIDs)   = dataTmp2{iIDs}.subjectData.ID;
end

[~, idxSorted] = sort(groupID);
iDout = [];
nameOut = {'suliang wang','Kapilan Thavarasa','Rodrigo da Silva','Nicole Mizera','Stanislav Kunt'};
nameOut = {'Kapilan Thavarasa','Rodrigo da Silva','Nicole Mizera','Stanislav Kunt'};
nameOut = {'suliang wang'};
for iD = 1: nSubj
    subjectData{iD} = dataTmp2{idxSorted(iD)}.subjectData;
    subjectName{iD} = subjectData{iD}.name;
    age(iD) = subjectData{iD}.age;
    if strcmpi(subjectData{iD}.sex,'female')
        gender(iD) = 1;
    end
    for iO = 1:numel(nameOut)
        if strcmpi(subjectName{iD},nameOut{iO})
            iDout(iO) = iD;
        end
    end
end

if ~isempty(iDout)
    subjectName(iDout)    = [];
    subjectData(iDout)    = [];
    gender(iDout)         = [];
    age(iDout)            = [];
end

% Subject Data
m.name      = subjectName;
m.age       = age;
m.gender    = gender;

metaDataA               = cell(4,1);
metaDataA{1}            = ['Total  : ' num2str(numel(subjectName))];
metaDataA{2}            = ['Age    : ' num2str(round(mean(age)*10)/10) ' +/- ' num2str(round(std(age)*10)/10) ' years'];
metaDataA{3}            = ['Male   : ' num2str(numel(subjectName)-sum(gender))];
metaDataA{4}            = ['Female : ' num2str(sum(gender))];

metaDataS               = getSubjectsData(subjectData{1});
%% eval data
scrsz = get(0,'ScreenSize');
fgh = figure('position',[10 50 scrsz(3)*0.98 scrsz(4)*0.9],'Visible','off');
uitoolbar(fgh);

% Names of Subjects
h.hSubjects     = uicontrol('Style','listbox',...
    'String',subjectName,...
    'Position',[scrsz(3)*0.5,   scrsz(4)*0.3,   scrsz(3)*0.1,   scrsz(4)*0.2],...
    'Callback',{@plot_SubjData_CB},'UserData',subjectData, 'Min',1, 'Max', nSubj);

% Data of current Subject
h.hSubjData     = uicontrol('Style','listbox',...
    'String',metaDataS,...
    'Position',[scrsz(3)*0.5,   scrsz(4)*0.15,  scrsz(3)*0.1,   scrsz(4)*0.1],...
    'Callback',{@plot_SubjData_CB},'UserData',subjectData);

% Data of all Subjects
h.hSubjDataA     = uicontrol('Style','listbox',...
    'String',metaDataA,...
    'Position',[scrsz(3)*0.5,   scrsz(4)*0.05, scrsz(3)*0.1,   scrsz(4)*0.05]);

% evaluation mode
h.hResMode      = uicontrol('Style','popup',...
    'String',{'Absolute','Relative','Percent'},...
    'Position',[scrsz(3)*0.5,   scrsz(4)*0.75, scrsz(3)*0.1,   scrsz(4)*0.1],...
    'Callback',@plot_SubjData_CB,'UserData',m);

% Results of a subject
h.hA1 = axes('Units','Pixels','Position',[50,scrsz(4)*0.05, scrsz(3)*0.4,   scrsz(4)*0.2]);
h.hA2 = axes('Units','Pixels','Position',[50,scrsz(4)*0.33, scrsz(3)*0.4,   scrsz(4)*0.2]);
h.hA3 = axes('Units','Pixels','Position',[50,scrsz(4)*0.6,  scrsz(3)*0.4,   scrsz(4)*0.2]);
align([h.hSubjects],'Center','None');


nSubj   = numel(subjectData);
nGroups = 7;
cRes    = zeros(nSubj,nGroups);

for idxS = 1:nSubj
    for idxG = 1:nGroups
        try
            cRes(idxS,idxG) = mean(subjectData{idxS,1}.results{1,idxG}(end-5:end,1));
        end
    end
end
cRes(cRes == 0) =NaN;
cResRel = zeros(size(cRes));
cResPer = zeros(size(cRes));
for idxS = 1:nSubj
    currentRes = cRes(idxS,:);
    cResPer(idxS,:) = currentRes./mean(currentRes(~isnan(currentRes)));
    cResRel(idxS,:) = currentRes-mean(currentRes(~isnan(currentRes)));
end

% Boxplots
h.hA4   = axes('Units','Pixels','Position',[scrsz(3)*0.75,  scrsz(4)*0.1,   scrsz(3)*0.2,   scrsz(4)*0.15]);
h.hA5   = axes('Units','Pixels','Position',[scrsz(3)*0.75,  scrsz(4)*0.3,  scrsz(3)*0.2,   scrsz(4)*0.15]);
h.hA6   = axes('Units','Pixels','Position',[scrsz(3)*0.75,  scrsz(4)*0.5,  scrsz(3)*0.2,   scrsz(4)*0.15]);
%h.hA7   = axes('Units','Pixels','Position',[scrsz(3)*0.5 ,  scrsz(4)*0.55,  scrsz(3)*0.2,   scrsz(4)*0.1]);
%h.hA8   = axes('Units','Pixels','Position',[scrsz(3)*0.5 ,  scrsz(4)*0.7,  scrsz(3)*0.1,   scrsz(4)*0.1]);
h.hA9   = axes('Units','Pixels','Position',[scrsz(3)*0.75,  scrsz(4)*0.7,  scrsz(3)*0.2,   scrsz(4)*0.15]);

% male vs. female
iF = logical(gender);
iM = logical(abs(gender-1));
if sum(iF)>sum(iM)
    cResF =  cRes(iF,:);
    cResM = [cRes(iM,:); ones(sum(iF)-sum(iM),nGroups)*NaN];
    mcResM = cRes(iM,:);
    mcResM = mcResM(:);
elseif sum(iF)<sum(iM)
    cResM =  mean( cRes(iM,:),2);
    cResF = [mean(cRes(iF,:),2); ones(sum(iM)-sum(iF),nGroups)*NaN];
else
    cResM =  mean( cRes(iM,:),2);
    cResF = mean(cRes(iF,:),2);
    mcResM = cRes(iM,:);
    mcResM = mcResM(:);
end

boxplot(h.hA9,[ cResF(:) cResM(:)],'labels',{'female', 'male'});
set(h.hA9,'YGrid','on');hold(h.hA9, 'on')
plot(h.hA9,[mean(cResF(:)) mean(mcResM)],'d');
ylabel(h.hA9,'Moved Wall in Meter');
ylim([0 5])
hold(h.hA9, 'off')

% init
plot_boxplot(h,cRes);
set(h.hSubjDataA,'UserData',[cRes,cResRel,cResPer]);

%Make the GUI visible.
set(fgh,'Visible','on');
guidata(fgh,h);

end

function plot_SubjData_CB(source,~)
%% Display surf plot of the currently selected data.
trialMax    = 25;

guiData     = guidata(source);
subjData    = get(guiData.hSubjects,'UserData');
selectDataC = get(guiData.hSubjects,'Value');
evalMode    = get(guiData.hResMode,'Value');


%if  evalMode ~=1
cResTmp     = get(guiData.hSubjDataA,'UserData');
cRes        = cResTmp(:,8*evalMode-7:8*evalMode);
if numel(selectDataC)>1
    plot_boxplot(guiData,cRes(selectDataC,:));
else
    plot_boxplot(guiData,cRes);
end
%end
%% info Box
m = get(guiData.hResMode ,'UserData');
metaDataA               = cell(4,1);
metaDataA{1}            = ['Total  : ' num2str(numel(selectDataC))];
metaDataA{2}            = ['Age    : ' num2str(round(mean(m.age(selectDataC))*10)/10),...
    ' +/- ' num2str(round(std(m.age(selectDataC))*10)/10) ' years'];
metaDataA{3}            = ['Male   : ' num2str(numel(selectDataC)-sum(m.gender(selectDataC)))];
metaDataA{4}            = ['Female : ' num2str(sum(m.gender(selectDataC)))];
set(guiData.hSubjDataA,'string',metaDataA);
%%
selectData  = selectDataC(end);

[angleRes, cAns, ~] = getCurrentSubjectResults(subjData{selectData});
nAns        = size(cAns,1);

noiseG  = [1 2];
musicG  = [5 6 7];
speechG    = [3 4];

music     = {'gitar  ' ,'drum    ' ,'trumpete'};
noise      = {'short','long '};
speech        = {'Zahl   ','Schreck'};
%% Meta data
metaData = getSubjectsData(subjData{selectData});
set(guiData.hSubjData, 'String',metaData);

%% Plot data
yTicks =     [ 0.1 0.2 0.3 0.4 0.7  1 2 3 4 7 10 20];
yTickLabel = round(yTicks*100)/100;
yLim = [0.07 21];

axes(guiData.hA1)
semilogy(1:nAns,angleRes(:,noiseG),'o'); hold on
semilogy(1:nAns,cAns(:,noiseG).*angleRes(:,noiseG),'x');
grid on; legend(noise); ylim(yLim);xlim([ 1 trialMax]);
set(gca,'ytick',yTicks,'yticklabel',yTickLabel);
title([subjData{selectData}.name ': Noise']);
ylabel('Moved Wall in Meter'); xlabel('Decision')
hold off

axes(guiData.hA2)
semilogy(1:nAns,angleRes(:,speechG),'o'); hold on
semilogy(1:nAns,cAns(:,speechG).*angleRes(:,speechG),'x');
grid on; legend(speech);ylim(yLim);xlim([ 1 trialMax]);
set(gca,'ytick',yTicks,'yticklabel',yTickLabel);
title([subjData{selectData}.name ': Speech']);ylabel('Moved Wall in Meter'); xlabel('Decision')
hold off

axes(guiData.hA3)
semilogy(1:nAns,angleRes(:,musicG ),'o'); hold on
semilogy(1:nAns,cAns(:,musicG ).*angleRes(:,musicG ),'x');
grid on; legend(music);ylim(yLim);xlim([ 1 trialMax]);
set(gca,'ytick',yTicks,'yticklabel',yTickLabel);
title([subjData{selectData}.name ': Music']);ylabel('Moved Wall in Meter'); xlabel('Decision')
hold off
end

function [angleRes, cAns, cOrder] = getCurrentSubjectResults(subjectData)
res     = subjectData.results;
cGroups = subjectData.configOrder;
nGroups = length(cGroups);
nAns    = length(res{1,2}(:,1));

angleRes= zeros(nAns,nGroups);
cAns    = zeros(nAns,nGroups);
cOrder  =  zeros(nAns,nGroups);
for idxG = 1:nGroups
    %idxCG               = find(cGroups == idxG,1,'first');
    idxCG = idxG;
    if ~isempty(res{idxCG})
        angleRes(:,idxG)    = res{idxCG}(:,1);
        cAns(:,idxG)        = res{idxCG}(:,3);
        cOrder(:,idxG)      = res{idxCG}(:,2);
    end
end
end

function metaData = getSubjectsData(subjectData)
metaData{1} = ['ID     : ' num2str(subjectData.ID)];
metaData{2} = ['group  : ' num2str(subjectData.group)];
metaData{3} = ['name   : ' subjectData.name];
metaData{4} = ['age    : ' num2str(subjectData.age)];
metaData{5} = ['gender : ' subjectData.sex];
metaData{6} = ['date   : ' subjectData.date];
metaData{7} = ['order  : ' num2str(subjectData.configOrder)];
end

function plot_boxplot(h,cRes)
if sum(sum(cRes(:,1:7)<0))>0
    ylimit = [-5 5];
else
    ylimit = [0 5];
end
mCres = cRes(:,1:2);
boxplot(h.hA4,mCres,'labels',{'noise short', 'noise long'});
set(h.hA4,'YGrid','on');hold(h.hA4, 'on')
mmCres = mean(mCres);
plot(h.hA4,mmCres ,'d');
ylabel(h.hA4,'Moved Wall in Meter'); title(h.hA4,'Noise')
hold(h.hA4, 'off'); ylim(h.hA4,ylimit)
xlabel(h.hA4,['Mean Noise: ' num2str(round(100*median(mCres(:)))/100) 'm']);

mCres = cRes(:,[3 4]);
boxplot(h.hA5,mCres,'labels',{'Zahl','Schreck'});
set(h.hA5,'YGrid','on');hold(h.hA5, 'on')
mmCres = mean(mCres);
plot(h.hA5,mmCres,'d');
ylabel(h.hA5,'Moved Wall in Meter');title(h.hA5,'Speech')
hold(h.hA5, 'off'); ylim(h.hA5,ylimit)
xlabel(h.hA5,['Mean Speech: ' num2str(round(100*median(mCres(:)))/100) 'm']);

mCres = cRes(:,[5 6 7]);
% mmCres = zeros(1,3);
% for idxR = 1:3
%     mmCres(idxR) = mean(mCres(~isnan(mCres(:,idxR)),idxR));
% end
boxplot(h.hA6,mCres,'labels',{'gitar  ' ,'drum    ' ,'trumpete'});
set(h.hA6,'YGrid','on');hold(h.hA6, 'on')
plot(h.hA6,mean(mCres),'d');
ylabel(h.hA6,'Moved Wall in Meter');title(h.hA6,'Music')
hold(h.hA6, 'off'); ylim(h.hA6,ylimit)
xlabel(h.hA6,['Mean Music: ' num2str(round(100*median(mCres(:)))/100) 'm']);

% xlabel(h.hA6,['Total Median:' num2str(round(100*median(cRes(~isnan(cRes))))/100)]);
end