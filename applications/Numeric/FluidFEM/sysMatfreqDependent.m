function [S, Mc, A, erg] = sysMatfreqDependent(SysMat,GroupMaterial, fluid,limFreq, deep, diff)
% Function gets a struct with systemmatrices and vectors (SysMat), a cell
% with boundary conditions (GroupMaterial), an object itaMeshFluid with
% the initial fluid informations (fluid), the biggest frequency (limFreq), 
% the number of calls of the recursive function splitFreq (deep) and a
% precentage boundary for the approximation of the boundary conditions (diff)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
DataTemp =cell(0,0);
l_N = length(SysMat.S);
counter = 1;
passivA = cell(0,0);


%% Calculation of the admittance matrix
for i1 = 1:length(GroupMaterial)
    TypeTmp = GroupMaterial{i1}{2}.Type;
    if strcmp(TypeTmp,'Admittance') || strcmp(TypeTmp,'Impedance') ||...
            strcmp(TypeTmp,'Reflection') || strcmp(TypeTmp,'Absorption')
        if strcmp(TypeTmp,'Admittance') && length(GroupMaterial{i1}{2}.Value) == 1 ...
                && GroupMaterial{i1}{2}.Value == 0
        else
            DataTemp{i1} = getValueAtFrequency(GroupMaterial{i1}{2}, GroupMaterial{i1}{2}.Freq);
            f{counter} = GroupMaterial{i1}{2}.Freq';
            Yr{counter} = real(DataTemp{i1})';
            Yi{counter} = imag(DataTemp{i1})';
            passivA{counter} = SysMat.A{i1};
            counter = counter+1;
        end
    else
        disp(['No passive or pressure boundary condition: ' GroupMaterial{i1}{2}.Type]);
    end
end


%% Interpolation of the frequency dependent boundary conditions
l = length(f);
k = zeros(l,1);
fMax = zeros(l,1);
limFreq = fix(limFreq);
newF = 10:limFreq;

for i1=1:l
    k(i1) = length(f{i1});
    fMax(i1) = f{i1}(end);
    fMin = min(f{i1});
    
    if k(i1)>1 % interpolation only if boundary conditions are frequency dependent
        if fMax(i1)<limFreq        % upper interpolation of the frequency dependent boundary condition
            pointInt = k(i1) - ceil(0.15*k(i1));
            YrTmp2 = Yr{i1}(pointInt:end);
            YiTmp2 = Yi{i1}(pointInt:end);
            fTmp2  = f{i1}(pointInt:end);
            pIntR  = polyfit(fTmp2,YrTmp2,2);
            pIntI  = polyfit(fTmp2,YiTmp2,2);
            fTmp3 =  f{i1}(k(i1))+1: limFreq;
            YrTmp3 = polyval(pIntR,fTmp3);
            YiTmp3 = polyval(pIntI,fTmp3);
            YrTmp{i1} = [Yr{i1}, YrTmp3];
            YiTmp{i1} = [Yi{i1}, YiTmp3];
            fTmp{i1}  =  [f{i1}, fTmp3];
            clear YrTmp2 YiTmp2 YrTmp3 YiTmp3 fTmp2;
        else
            ind = find(f{i1} <= limFreq,1,'last');
            YrTmp{i1} = Yr{i1}(1:ind);
            YiTmp{i1} = Yi{i1}(1:ind);
            fTmp{i1}  = f{i1}(1:ind);
        end
        
        if fMin>10 % lower interpolation of the frequency dependent boundary condition
            pointInt = ceil(0.15*k(i1));
            if pointInt <3 && k(i1)>2
                pointInt = 3;
            end
            YrTmp2 = Yr{i1}(1:pointInt);
            YiTmp2 = Yi{i1}(1:pointInt);
            fTmp2  = f{i1}(1:pointInt);
            pIntR  = polyfit(fTmp2,YrTmp2,2);
            pIntI  = polyfit(fTmp2,YiTmp2,2);
            fTmp4 = 10: f{i1}(1)-1;
            YrTmp3 = polyval(pIntR,fTmp4);
            YiTmp3 = polyval(pIntI,fTmp4);
            YrTmp{i1} = [YrTmp3, YrTmp{i1}];
            YiTmp{i1} = [YiTmp3, YiTmp{i1}];
            fTmp{i1}  = [fTmp4, fTmp{i1}];
            clear YrTmp2 YiTmp2 YrTmp3 YiTmp3 fTmp2 fTmp4;
        elseif fMin<10
            ind = find(f{i1}<1);
            YrTmp{i1}(ind) = [];
            YiTmp{i1}(ind) = [];
            fTmp{i1}(ind)  = [];
        end
        
        % bring all boundary condition to the same vector length
        YrTmp1(i1,:) = interp1(fTmp{i1},YrTmp{i1},newF,'cubic');
        YiTmp1(i1,:) = interp1(fTmp{i1},YiTmp{i1},newF,'cubic');
        if ~isempty(find(isnan(YrTmp1(i1,:))==1,1)) ||  ~isempty(find(isnan(YiTmp1(i1,:))==1,1));
            warning('Wrong interpolation: Element(s) are NAN!')
        end
    else
        YrTmp1(i1,:) = Yr{i1}*ones(size(newF));
        YiTmp1(i1,:) = Yi{i1}*ones(size(newF)); %#ok<*AGROW>
    end
end

erg.fBegin = [];erg.fEnd = []; erg.p =[]; erg.Delta =[];
ergSort = erg;
eValue =[]; %#ok<*NASGU>
eVector =[];
ind =1;

% recursiv function the split the boundary conditions in single polynomials
% of second order
erg = splitFreq(newF,[YrTmp1;YiTmp1],diff,ind,deep,erg);

% sort the sections of the boundary conditions frequency dependent
lTmp = erg.fEnd-erg.fBegin+1;
while ~isempty(erg.p)
    [V ind] = max(erg.fEnd);
    ergSort.fBegin = [ergSort.fBegin, erg.fBegin(ind)];
    ergSort.fEnd = [ergSort.fEnd, V];
    ergSort.p = [ergSort.p, erg.p(:,3*ind-2:3*ind)];
    
    sumEnd = sum(lTmp(1:ind)); sumBegin = sum(lTmp(1:ind-1))+1;
    ergSort.Delta = [ergSort.Delta, erg.Delta(:,sumBegin:sumEnd)]; %oder nach Frequenzen ordnen
    lTmp(ind)=[]; erg.Delta(:,sumBegin:sumEnd)=[];
    erg.fBegin(ind) =[];erg.fEnd(ind) =[];
    erg.p(:,3*ind-2:3*ind) = [];
end

erg = ergSort;

%% Calculation of the eigenmodes frequency dependent
lGroup = length(passivA);
lIntervall = length(erg.fBegin);
pR = erg.p(1:counter-1,:); pI = erg.p(counter:2*(counter-1),:);
% DeltaR =  erg.Delta(1:counter-1,:); DeltaI = erg.Delta(counter:2*(counter-1),:);

A = cell(lIntervall,1);
S = cell(lIntervall,1);
Mc= cell(lIntervall,1);
% disp('Eigenmodes:');
% disp('-----------');
for i1 =1:length(erg.fBegin)
    A{i1} = sparse(l_N,l_N);
    S{i1} = SysMat.S;
    Mc{i1}= -SysMat.M/fluid.c^2;
    for i2 = 1:lGroup
        S{i1}  = S{i1} + j*fluid.rho*2*pi*(pR(i2,i1*3) + j*pI(i2,i1*3))*passivA{i2}; %#ok<*IJCL>
        Mc{i1} = Mc{i1}+ j*fluid.rho/(2*pi)*(pR(i2,i1*3-2) + j*pI(i2,i1*3-2))*passivA{i2};
        A{i1}  = A{i1} + j*fluid.rho*(pR(i2,i1*3-1) + j*pI(i2,i1*3-1))*passivA{i2};
    end
end

function erg = splitFreq(f,YTmp,diff,ind,deep,erg)
% This is a recursive function to split the frequency dependent boundary
% condition in frequency dependent boundary which can descriped by
% polynomes of second order.
% Function get a frequency vector (f), all frequency dependent admittance
% vectors from the boundary conditions (YTmp), number of maximum calls of
% the recursive function splitFreq (deep), a precentage boundary for the
% approximation of the boundary conditions (diff) and the results with the
% intervals of the approximated polynomials (erg) and gives back (erg).

for i1 =1:length(YTmp(:,1))
    p(i1,:) = polyfit(f,YTmp(i1,:).*f,2);
    YTmpInt(i1,:) =(p(i1,1)*f.^2 + p(i1,2).*f +p(i1,3))./f;
    Delta(i1,:) = abs((YTmp(i1,:)-YTmpInt(i1,:))./YTmp(i1,:));
end
totDiffMax = max(Delta);

% split frequency domain
if ~isempty(find(totDiffMax > diff,1)) && ind < deep
    % calculation of the median delivers a threshhold for the intervals
    DiffMedian  = median(totDiffMax);
    halfPosDiff = ceil(length(totDiffMax)/2);
    DiffU = totDiffMax(1:halfPosDiff);
    posU  = find(DiffU>DiffMedian,1,'last');
    DiffO = totDiffMax(halfPosDiff+1:end);
    posO  = find(DiffO>DiffMedian,1,'first');
    [diffHP posmax] = max([halfPosDiff-posU,posO-halfPosDiff]);
    if posmax == 1
        split = posU;
    else
        split = posO;
    end

    % if the frequency domain is not splitted by median the frequency
    % domain is splitted in the middle   
    if diffHP < 2
        fU = f(1:ceil(length(f)/2));indU = ind+1;
        YTmpU = YTmp(:,1:ceil(length(f)/2));
        fO = f(ceil(length(f)/2)+1:end);indO = ind+1;
        YTmpO = YTmp(:,ceil(length(f)/2)+1:end);
        split = ceil(length(f)/2);
    else
        fU = f(1:split);indU = ind+1;
        YTmpU = YTmp(:,1:split);
        fO = f(split+1:end);indO = ind+1;
        YTmpO = YTmp(:,split+1:end);
    end


    if fU(end)<20 || isempty(find(DiffU > diff,1)) || length(fU)<11
        % - frequencies under 20Hz are not regarded
        % - difference DiffU is smaller than diff.
        erg.fBegin = [erg.fBegin, fU(1)];
        erg.fEnd = [erg.fEnd, fU(end)];
        erg.p =[erg.p, p];
        erg.Delta =[erg.Delta, Delta(:,1:split)];
        if length(fO)>10 || isempty(find(DiffU > diff,1))
            erg = splitFreq(fO,YTmpO,diff,indO,deep,erg);
        elseif length(fO)<11
            erg.fBegin = [erg.fBegin, fO(1)];
            erg.fEnd = [erg.fEnd, fO(end)];
            erg.p =[erg.p, p];
            erg.Delta =[erg.Delta, Delta(:,split+1:end)];
        end
    elseif isempty(find(DiffO > diff,1)) || length(fO)<11
        % - difference Diff0 is bigger than diff.
        erg.fBegin = [erg.fBegin, fO(1)];
        erg.fEnd = [erg.fEnd, fO(end)];
        erg.p =[erg.p, p];
        erg.Delta =[erg.Delta, Delta(:,split+1:end)];
        if length(fU)>10
            erg = splitFreq(fU,YTmpU,diff,indU,deep,erg);
        elseif length(fU)<11
            erg.fBegin = [erg.fBegin, fU(1)];
            erg.fEnd = [erg.fEnd, fU(end)];
            erg.p =[erg.p, p];
            erg.Delta =[erg.Delta, Delta(:,1:split)];
        end
    else
        erg = splitFreq(fU,YTmpU,diff,indU,deep,erg);
        erg = splitFreq(fO,YTmpO,diff,indO,deep,erg);
    end
else
    erg.fBegin = [erg.fBegin, f(1)];
    erg.fEnd = [erg.fEnd, f(end)];
    erg.p =[erg.p, p];
    erg.Delta =[erg.Delta, Delta];
end
