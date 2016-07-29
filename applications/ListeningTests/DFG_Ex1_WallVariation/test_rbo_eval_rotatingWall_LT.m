function test_rbo_eval_rotatingWall_LT

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Info
% -------------------------------------------------------------------------
% Groups ------------------------------------------------------------------
% -------------------------------------------------------------------------
%    tau [ms]   alpha [°]   L [dB]
% 1: 30         40          6
% 2: 30         40          9
% 3: 30         40          12
% 4: 30         20          9
% 5: 30         60          9
% 6: 30         80          9
% 7: 15         40          9
% 8: 45         40          9
% -------------------------------------------------------------------------
%% Load data
path        = 'C:\Users\bomhardt\Desktop\zeug\Projekte\2014_DFG Antrag - Geometrie\2014_RotatingWall\Ergebnisse\ergebnisse_141126\Results';
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
for iD = 1: nSubj
    subjectData{iD} = dataTmp2{idxSorted(iD)}.subjectData;
    subjectName{iD} = subjectData{iD}.name;
    age(iD) = subjectData{iD}.age;
    if strcmpi(subjectData{iD}.sex,'female')
        gender(iD) = 1;
    end
    if strcmpi(subjectName{iD},'stefanie ossenkamp')
        iDout = iD;
    end
    if strcmpi(subjectName{iD},'grassmann')
        iDout = [iDout iD];
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
nGroups = 8;
cRes    = zeros(nSubj,nGroups);

for idxS = 1:nSubj
    for idxG = 1:nGroups
        try
            cRes(idxS,idxG) = mean(subjectData{idxS,1}.results{1,idxG}(20,1));
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
h.hA7   = axes('Units','Pixels','Position',[scrsz(3)*0.5 ,  scrsz(4)*0.55,  scrsz(3)*0.2,   scrsz(4)*0.1]);
h.hA8   = axes('Units','Pixels','Position',[scrsz(3)*0.5 ,  scrsz(4)*0.7,  scrsz(3)*0.1,   scrsz(4)*0.1]);
h.hA9   = axes('Units','Pixels','Position',[scrsz(3)*0.75,  scrsz(4)*0.7,  scrsz(3)*0.2,   scrsz(4)*0.15]);

% male vs. female
iF = logical(gender);
iM = logical(abs(gender-1));
if sum(iF)>sum(iM)
    cResF =  mean(cRes(iF,:),2);
    cResM = [mean(cRes(iM,:),2); ones(sum(iF)-sum(iM),1)*NaN];
else
    cResM =  mean( cRes(iM,:),2);
    cResF = [mean(cRes(iF,:),2); ones(sum(iM)-sum(iF),1)*NaN];
end
boxplot(h.hA9,[ cResF cResM],'labels',{'female', 'male'});
set(h.hA9,'YGrid','on');hold(h.hA9, 'on')
plot(h.hA9,[mean(cResF) mean(cResM(~isnan(cResM)))],'d');
ylabel(h.hA9,'Wall Angle in Degree');
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
yMax        = 30;

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

levelGroup  = [1 2 3];
alphaGroup  = [4 2 5 6];
tauGroup    = [7 2 8];

levels      = [ 6 9 12];
alphas      = [ 20 40 60 80];
taus        = [ 15 30 45];
%% Meta data
metaData = getSubjectsData(subjData{selectData});
set(guiData.hSubjData, 'String',metaData);

%% Plot data
axes(guiData.hA1)
plot(1:nAns,angleRes(:,levelGroup),'o'); hold on
plot(1:nAns,cAns(:,levelGroup).*angleRes(:,levelGroup),'x');
grid on; legend(num2str(levels')); ylim([1 yMax]);xlim([ 1 trialMax]);
title([subjData{selectData}.name ' \Delta L (1, 2, 3)']);
ylabel('Wall rotation in Degree'); xlabel('Decision')
hold off

axes(guiData.hA2)
plot(1:nAns,angleRes(:,alphaGroup),'o'); hold on
plot(1:nAns,cAns(:,alphaGroup).*angleRes(:,alphaGroup),'x');
grid on; legend(num2str(alphas'));ylim([1 yMax]);xlim([ 1 trialMax]);
title('\Delta \alpha (4, 2, 5, 6)');ylabel('Wall rotation in Degree'); xlabel('Decision')
hold off

axes(guiData.hA3)
plot(1:nAns,angleRes(:,tauGroup),'o'); hold on
plot(1:nAns,cAns(:,tauGroup).*angleRes(:,tauGroup),'x');
grid on; legend(num2str(taus'));ylim([1 yMax]);xlim([ 1 trialMax]);
title('\Delta \tau (7, 2, 8)');ylabel('Wall rotation in Degree'); xlabel('Decision')
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
boxplot(h.hA4,cRes(:,1:3),'labels',{'6dB', '9dB', '12dB'});
set(h.hA4,'YGrid','on');hold(h.hA4, 'on')
mCres = mean(cRes(:,1:3));
plot(h.hA4,mCres ,'d');
ylabel(h.hA4,'Wall Angle in Degree'); title(h.hA4,'\Delta L')
hold(h.hA4, 'off')

boxplot(h.hA5,cRes(:,[4 2 5 6]),'labels',{'20°', '40°', '60°','80°'});
set(h.hA5,'YGrid','on');hold(h.hA5, 'on')
plot(h.hA5,mean(cRes(:,[4 2 5 6])),'d');
ylabel(h.hA5,'Wall Angle in Degree');title(h.hA5,'\Delta \alpha')
hold(h.hA5, 'off')

mCres = cRes(:,[7 2 8]);
mmCres = zeros(1,3);
for idxR = 1:3
    mmCres(idxR) = mean(mCres(~isnan(mCres(:,idxR)),idxR));
end
boxplot(h.hA6,mCres,'labels',{'15ms', '30ms', '45ms'});
set(h.hA6,'YGrid','on');hold(h.hA6, 'on')
plot(h.hA6,mmCres,'d');
ylabel(h.hA6,'Wall Angle in Degree');title(h.hA6,'\Delta \tau')
hold(h.hA6, 'off')

xlabel(h.hA6,['Total Median:' num2str(round(100*median(cRes(~isnan(cRes))))/100)]);

for idxPos = 1:8
    [hyp(idxPos),p(idxPos)] = lillietest(cRes(:,idxPos));
%[hyp(idxPos),p(idxPos)] = jbtest(cRes(:,idxPos));
%[hyp(idxPos),p(idxPos)] = kstest(cRes(:,idxPos));
end
bar(h.hA7,[hyp*0.05;p]');
set(h.hA7,'YGrid','on');
set(h.hA7,'XTickLabel',{'6dB','9dB','12dB','20°','60°','80°','15ms','45ms'});
title(h.hA7,'H0: Is a normal distribution');

%% ANOVA
% figure
p = zeros(8,8);
alpha = 0.05;
for idxPosX =  1:8
    for idxPosY = 1:8
        p(idxPosX,idxPosY) = anova1(cRes(:,[idxPosX, idxPosY]),{'1', '2'},'off');
    end
end
pPlot = zeros(8,8);
pPlot(p<=alpha) =1;

axes(h.hA8)
imagesc(pPlot);
set(h.hA8,'XTickLabel',{'6','9','12','20','60','80','15','45'},...
    'xtick',1:8);
set(h.hA8,'YTickLabel',{'6dB','9dB','12dB','20°','60°','80°','15ms','45ms'},...
 'ytick',1:8);
 grid on
end