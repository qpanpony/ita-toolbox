function varargout = test_rbo_checkMAA_results(varargin)

type = 'subject';
sortOut = [];
if nargin ~= 0
    type = varargin{1};
    if nargin >= 2,        sortOut = varargin{2};    end
        if nargin >= 3,        startD = varargin{3};   
        else startD = 10;
        end
end

% <ITA-Toolbox>
% This file is part of the application ListeningTests for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Infos about subjects
% Andreas Roese:        manchmal von hinten gehört zu haben
% Thomas Maintz:        Hinten
% Rebekka:
% Alfred:
% Forian Giebel:        (?)
%% Read data
path = '\\verdi\Scratch\stockmann\fürRamona\Results_RealtiveMAA';
%path = '\\verdi\Scratch\bomhardt\fürAnne';
dataTmp = dir( fullfile(path,'*.mat') );
for iD = 1: numel(dataTmp)
    data(iD) = load([path '\' dataTmp(iD).name ]  ); %#ok<AGROW>
end
[nameSubj, stat, maaC,~] = calcMAA4all(data,startD);

trialMAA = maaC(:,[1 2]);
trialMAA(sortOut,:) = [];
switch type
    case 'subject'
        %% eval data
        lDataPos = 1200;
        fgh = figure('position',[50 50 1500 1000],'Visible','off');
        
        h.hSubjects = uicontrol('Style','listbox',...
            'String',nameSubj,...
            'Position',[lDataPos,500,100,300],'Callback',{@plot_SubjData_CB},'UserData',data);
        
        
        h.hA = axes('Units','Pixels','Position',[50,50,1000,800]);
        align([h.hSubjects],'Center','None');
        
        %Make the GUI visible.
        set(fgh,'Visible','on');
        guidata(fgh,h);
        
    case 'all'
        maaC(:,[5,6]) =[];
        if ~isempty(sortOut)
            maaC(sortOut,:) = [];
            stat(:,sortOut) = [];
        else
            idx10 = unique(ceil(find(maaC'==10)/size(maaC,2)));
            maaC(idx10,:) = [];
        end
        newResults(maaC)
    case 'ref'
        if ~isempty(sortOut)
            maaC(sortOut,:) = [];
        else
            idx10 = unique(ceil(find(maaC'==10)/size(maaC,2)));
            maaC(idx10,:) = [];
        end
       refResults(maaC)
    case 'combine'
        %maaC(:,[5,6]) =[];
        maaC(sortOut,:) = [];
        midRunOld = test_rbo_willem_eval('false');
        combinedResults(maaC,midRunOld)
end

disp(['Total number of subjects: ' num2str(size(maaC,1))]);
disp(['ear :  ' num2str(sum(stat(4,:))) ' left']);
disp(['HRTF:  ' num2str(sum(stat(3,:))) ' experienced']);
disp(['Sex :  ' num2str(sum(sum(stat(1,:)))) ' male']);
disp(['Age :  ' num2str(round(mean(stat(2,:)))) ' +/- ' num2str(round(std(stat(2,:))))]);
disp(['Trial: ' num2str(sum(stat(5,:))) ' right side started'])
if nargout == 1;
    varargout{1} = maaC;
elseif nargout ==2
    varargout{1} = maaC;
    varargout{2} = trialMAA;
end
end

function combinedResults(midRunNew,midRunOld)

sN = size(midRunNew,1);
sO = size(midRunOld,1);
 
if sN < sO
    midRunNew = [midRunNew; ones(sO-sN,size(midRunNew,2))*NaN];
elseif sN > sO
    midRunOld = [midRunOld; ones(sN-sO,size(midRunOld,2))*NaN];
end


refNew = zeros(numel(midRunNew(:,5)),1);
refNew(midRunNew(:,5)<=midRunNew(:,6)) = midRunNew(midRunNew(:,5)<=midRunNew(:,6),5);
refNew(midRunNew(:,6)<=midRunNew(:,5)) = midRunNew(midRunNew(:,6)<=midRunNew(:,5),6);
midRunNew(:,[5,6]) = [];
%%
%  midRunND = bsxfun(@minus,midRunNew,refNew);
% midRunOD = bsxfun(@minus,midRunOld(:,2:4),midRunOld(:,1));
% midRunND = bsxfun(@rdivide,midRunNew,refNew);
% midRunOD = bsxfun(@rdivide,midRunOld(:,2:4),midRunOld(:,1));
midRunND = midRunNew;
midRunOD = midRunOld(:,2:4);

midRun = [midRunOD(:,1) midRunND(:,[1,2]) midRunOD(:,2) midRunND(:,[3,4]) midRunOD(:,3)];
%midRun = [midRunOld(:,1) midRunNew(:,[1,2]) midRunOld(:,2) midRunNew(:,[3,4]) midRunOld(:,3)];

roomIDs     = [70 75 79 80 83 86 90];

%% plots
figure;
boxplot(midRun); hold all; 
grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('Mid Run')

%pause(1)
%% ANOVA
h = zeros(2, numel(roomIDs));
testNiveau = 0.05;
for i1 = 1:numel(roomIDs)
    h(1,i1) = kstest(midRun(:,i1),'alpha',testNiveau); %ok
    h(2,i1) = lillietest(round(midRun(:,i1)),'alpha',testNiveau);
    nameRoom{i1} = num2str(roomIDs(i1));
end
figure;
nbins = min(round(midRun(:))) : max(round(midRun(:)));
subplot(2,2,1);hist(round(midRun(:,1)),nbins); title(nameRoom{1}); xlim([0 10])
subplot(2,2,2);hist(round(midRun(:,2)),nbins); title(nameRoom{2}); xlim([0 10])
subplot(2,2,3);hist(round(midRun(:,3)),nbins); title(nameRoom{3}); xlim([0 10])
subplot(2,2,4);hist(round(midRun(:,4)),nbins); title(nameRoom{4}); xlim([0 10])

disp('      kR kD kM chiR chiD chiM')
disp(num2str([str2double(nameRoom); h ]'))
[~,~,st] = anova1(midRun,nameRoom,'off');
%[~,~,st] = anova1(deltaMidRun,nameRoom,'off');
%[~,m] = multcompare(st,'alpha',0.05,'ctype','lsd','display','on');
[~,m] = multcompare(st,'alpha',0.05,'ctype','scheffe','display','on');
end
function refResults(midRun)
ref = zeros(numel(midRun(:,5)),1);
ref(midRun(:,5)<=midRun(:,6)) = midRun(midRun(:,5)<=midRun(:,6),5);
ref(midRun(:,6)<=midRun(:,5)) = midRun(midRun(:,6)<=midRun(:,5),6);

midRun(:,[5,6]) = [];

relMidRun   = bsxfun(@rdivide, midRun,ref);
deltaMidRun = bsxfun(@minus, midRun,ref);
roomIDs     = [75 79 83 86];


%% plots
figure;
sf = subplot(3,1,1);
boxplot(sf,midRun);grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('Mid Run')

sf = subplot(3,1,2);
boxplot(sf,relMidRun);grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('Relative Mid Run (per Person)')

sf = subplot(3,1,3);
boxplot(sf,deltaMidRun);grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('\Delta Mid Run (per Person)')
pause(1)
%% ANOVA
h = zeros(6, numel(roomIDs));
testNiveau = 0.05;
for i1 = 1:numel(roomIDs)
    h(1,i1) = kstest(relMidRun(:,i1),'alpha',testNiveau); %ok
    h(2,i1) = kstest(deltaMidRun(:,i1),'alpha',testNiveau); %nok
    h(3,i1) = kstest(midRun(:,i1),'alpha',testNiveau); %ok
    h(4,i1) = lillietest(relMidRun(:,i1),'alpha',testNiveau);
    h(5,i1) = lillietest(deltaMidRun(:,i1),'alpha',testNiveau);
    h(6,i1) = lillietest(round(midRun(:,i1)),'alpha',testNiveau);
    nameRoom{i1} = num2str(roomIDs(i1));
end
figure;
nbins = min(round(midRun(:))) : max(round(midRun(:)));
subplot(2,2,1);hist(round(midRun(:,1)),nbins); title(nameRoom{1}); xlim([0 10])
subplot(2,2,2);hist(round(midRun(:,2)),nbins); title(nameRoom{2}); xlim([0 10])
subplot(2,2,3);hist(round(midRun(:,3)),nbins); title(nameRoom{3}); xlim([0 10])
subplot(2,2,4);hist(round(midRun(:,4)),nbins); title(nameRoom{4}); xlim([0 10])

disp('      kR kD kM chiR chiD chiM')
disp(num2str([str2double(nameRoom); h ]'))
[~,~,st] = anova1(midRun,nameRoom,'off');
%[~,~,st] = anova1(deltaMidRun,nameRoom,'off');
%[~,m] = multcompare(st,'alpha',0.05,'ctype','lsd','display','on');
[~,m] = multcompare(st,'alpha',0.05,'ctype','scheffe','display','on');
end

function newResults(midRun)
relMidRun   = bsxfun(@rdivide, midRun,mean(midRun,2));
deltaMidRun = bsxfun(@minus, midRun,mean(midRun,2));
roomIDs     = [75 79 83 86];

%% plots
figure;
sf = subplot(3,1,1);
boxplot(sf,midRun);grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('Mid Run')

sf = subplot(3,1,2);
boxplot(sf,relMidRun);grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('Relative Mid Run (per Person)')

sf = subplot(3,1,3);
boxplot(sf,deltaMidRun);grid on;
set(gca,'xTick', 1:numel(roomIDs),'xTickLabel', roomIDs)
title('\Delta Mid Run (per Person)')
pause(1)
%% ANOVA
h = zeros(6, numel(roomIDs));
testNiveau = 0.05;
for i1 = 1:numel(roomIDs)
    h(1,i1) = kstest(relMidRun(:,i1),'alpha',testNiveau); %ok
    h(2,i1) = kstest(deltaMidRun(:,i1),'alpha',testNiveau); %nok
    h(3,i1) = kstest(midRun(:,i1),'alpha',testNiveau); %ok
    h(4,i1) = lillietest(relMidRun(:,i1),'alpha',testNiveau);
    h(5,i1) = lillietest(deltaMidRun(:,i1),'alpha',testNiveau);
    h(6,i1) = lillietest(round(midRun(:,i1)),'alpha',testNiveau);
    nameRoom{i1} = num2str(roomIDs(i1));
end
figure;
nbins = min(round(midRun(:))) : max(round(midRun(:)));
subplot(2,2,1);hist(round(midRun(:,1)),nbins); title(nameRoom{1}); xlim([0 10])
subplot(2,2,2);hist(round(midRun(:,2)),nbins); title(nameRoom{2}); xlim([0 10])
subplot(2,2,3);hist(round(midRun(:,3)),nbins); title(nameRoom{3}); xlim([0 10])
subplot(2,2,4);hist(round(midRun(:,4)),nbins); title(nameRoom{4}); xlim([0 10])

disp('      kR kD kM chiR chiD chiM')
disp(num2str([str2double(nameRoom); h ]'))
[~,~,st] = anova1(deltaMidRun,nameRoom,'off');
%[~,~,st] = anova1(deltaMidRun,nameRoom,'off');
%[~,m] = multcompare(st,'alpha',0.05,'ctype','lsd','display','on');
[~,m] = multcompare(st,'alpha',0.05,'ctype','scheffe','display','on');

end

function [nameSubj, statistic, maaC,subjDataTmp] = calcMAA4all(varargin)
    subjData = varargin{1};

if nargin ~= 1
    startD = varargin{2};
else
            startD = 1;
end
nRooms = 6;
nameSubj    = cell(numel(subjData),1);
subjDataC   = cell(numel(subjData),1);
maaC        = zeros(numel(subjData),nRooms );

statistic = zeros(5,numel(subjData));

for iSubjN = 1:numel(subjData)
    % names
    nameSubj{iSubjN} = subjData(1,iSubjN).subjectData.name;
    if strcmp(subjData(1,iSubjN).subjectData.sex,'male'),   statistic(1,iSubjN)  = 1; end
    statistic(2,iSubjN)  = subjData(1,iSubjN).subjectData.age;
    statistic(3,iSubjN)  = subjData(1,iSubjN).subjectData.hrtfExperienced;
    if strcmp(subjData(1,iSubjN).subjectData.preferedSide	,'left')
    statistic(4,iSubjN)  = 1;
    end
	statistic(5,iSubjN) = subjData(1,iSubjN).subjectData.firstTrainingSide;
    
    % results
    subjDataTmp      = zeros(numel(subjData(1).subjectData.resultRoom75(:,3)),6);
    subjDataTmp(:,1) = subjData(iSubjN).subjectData.resultRoom75(:,3);
    subjDataTmp(:,2) = subjData(iSubjN).subjectData.resultRoom79(:,3);
    subjDataTmp(:,3) = subjData(iSubjN).subjectData.resultRoom83(:,3);
    subjDataTmp(:,4) = subjData(iSubjN).subjectData.resultRoom86(:,3);
    subjDataTmp(:,5) = subjData(iSubjN).subjectData.resultTrainLeft(:,3);
    subjDataTmp(:,6) = subjData(iSubjN).subjectData.resultTrainRight(:,3);
    
    subjDataC{iSubjN} = subjDataTmp;
    for iRoom = 1:nRooms
        maaC(iSubjN,iRoom) = maa_midrun_estimation(subjDataTmp(startD:end,iRoom),[1 3]);
        %maaC(iSubjN,iRoom) = maa_midrun_estimation(subjDataTmp(startD:end,iRoom));
    end
end


end

function plot_SubjData_CB(source,~)
% Display surf plot of the currently selected data.
guiData = guidata(source);
subjData = get(guiData.hSubjects,'UserData');
selectData = get(guiData.hSubjects,'Value');

[~, ~, maaC,cSubjData] = calcMAA4all(subjData(selectData));

% Plot data
trialV = 1:size(cSubjData,1);
plot(trialV,cSubjData(:,1:4)','-x','linewidth',2); grid on; hold all
plot(trialV,cSubjData(:,5:6)',':o'); hold on

legend('0.75','0.79','0.83','0.86','Left','Right','location','best')
plot(size(cSubjData,1)+5,maaC','*','MarkerSize',20);
title(['ID ' num2str(selectData)])
ylim([0 10]); xlim([trialV(1) trialV(end)+10]);
xlabel('Trials plus midrun estimate (*)');
ylabel('MAA')
hold off
end