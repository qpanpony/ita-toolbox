function p = MAkomplex(SysMat, GUI, dMax, groupMaterial, fluid)
% Calculation of pressure with modalanalysis with eigenvectors of the
% undamped system
% Function needs systemmatrices (SysMat), GUI data (GUI), maximal distance
% of the modell (dMax), group material data (groupMaterial) and fluid
% properties (fluid)
% Function returns pressure (p)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Initialization
omega = GUI.Freq*2*pi; % frequency
p = zeros(size(SysMat.S,1),length(omega)); % pressure
aYn = sparse(size(SysMat.S,1),size(SysMat.S,2)); % admittance matrix
fdependent = 0; % (no) frequency dependent boundary conditions

% admittance matrix
for i1 = 1: length(groupMaterial)
    if length(groupMaterial{i1}{2}.Freq)>1 && ~isempty(SysMat.A{i1})
        fdependent = 1;
        break;
    elseif ~isempty(SysMat.A{i1})
        Yn = getValueAtFrequency(groupMaterial{i1}{2},omega(1)/(2*pi));
        if Yn ~= 0
            aYn =aYn+Yn *fluid.rho*SysMat.A{i1};
        end
    end
end

% number of eigenvectors (cuboid)
fGr = max(GUI.Freq);
V = sum(sum(SysMat.M));
Surf = 6*V^(2/3); 
L = 6*(V^(1/3)+dMax/sqrt(3));
deltaFreqMax = 1./(12*pi*V*fGr^2/fluid.c^3 + pi*Surf*fGr/fluid.c^2 + L/(8*fluid.c));
omegaO = 2*pi*(fGr+deltaFreqMax);

if fdependent == 0  % no frequency dependent boundary conditions
    % eigenvalues / eigenvectors
    [eVector, eValue] = polyeig(SysMat.S,1i*aYn,-SysMat.M/fluid.c^2);
    h = waitbar(0,'Complex Modulation: Pressure calculation is running...');
    tic
    % sort eigenvectors
    [~, pos2] = sort(real(eValue));
    eVecR = eVector(:,pos2); eVal = eValue(pos2);

    % left eigenvectors
    J = diag(eVal);
    tmp = inv([eVecR; eVecR*J]);sizeS = size(SysMat.S,1);
    % eVecL = ([eVecR; eVecR*J]\[zeros(size(SysMat.M)); eye(size(SysMat.M))])/(-SysMat.M/fluid.c^2);
    eVecL = tmp(:,sizeS+1:end)/(-SysMat.M/fluid.c^2);

    lEVec = size(eVecR,2);

    % pressure 
    t1 = toc; tic
    
    p = zeros(length(eValue)/2,length(omega));
    nZero = find(eVal<0,1,'last');  % find first positive eigenvalue 
    for i1 = 1:length(omega)
        waitbar(i1/length(omega));
        
        % reduce number of eigenvectors
        nfMax = find(eVal< 2*pi*GUI.Freq(i1),1,'last');
        
        ind2 = 10;
        
        if nfMax-ind2>nZero;
            eVecRo = eVecR(:,nfMax-(ind2-1):nfMax+ind2);
            eVecLo = eVecL(nfMax-(ind2-1):nfMax+ind2,:);
            eValo = eVal(nfMax-(ind2-1):nfMax+ind2);

            eVecRu = eVecR(:,lEVec-nfMax-(ind2-1):lEVec-nfMax+ind2);
            eVecLu = eVecL(lEVec-nfMax-(ind2-1):lEVec-nfMax+ind2,:);
            eValu = eVal(lEVec-nfMax-(ind2-1):lEVec-nfMax+ind2);
            
            eVecRTmp = [eVecRu,eVecRo];eVecLTmp = [eVecLu;eVecLo];
            eValTmp = diag([eValu;eValo]);
        else
            eVecRTmp = eVecR(:,lEVec-nfMax-ind2:nfMax+ind2+1);
            eVecLTmp = eVecL(lEVec-nfMax-ind2:nfMax+ind2+1,:);
            eValTmp = diag(eVal(lEVec-nfMax-ind2:nfMax+ind2+1));
        end
        
        sizeV = size(eVecRTmp,2);
        
        % frequency dependent load vector
        fVn = zeros(size(SysMat.M,1),1);
        for i2 = 1: length(groupMaterial)
            if ~isempty(SysMat.f{i2})
                vn = 1i*omega(i1)*getValueAtFrequency(groupMaterial{i2}{2},omega(i1)/(2*pi));
                fVn = fVn + SysMat.f{i2}*vn*fluid.rho;
            end
        end
        warning off all;
        
        % pressure calculation
        p(:,i1)=  (eVecRTmp/(omega(i1)*eye(sizeV, sizeV)-eValTmp)*eVecLTmp)*(-1i*omega(i1)*fVn);
    end
    t2 = toc;
    disp(' ');
    disp('Time complex');
    disp('-------------------------------------------------------------------');
    disp(['Sorting: ' num2str(t1)]);
    disp(['Loop   : ' num2str(t2)]);
    disp(['Total  : ' num2str(t1+t2)]);
    disp(' ');
    close(h)
else % frequency dependent boundary conditions
    % calculation of the systemmatrices for frequency dependent boundary
    % condition
    
    %deep = 3; diff = 0.1;
    deep = 1;
    diff = Inf;
    [S Mc A erg] = sysMatfreqDependent(SysMat,groupMaterial, fluid,omegaO/(2*pi), deep, diff);
    numIt = length(S);
    ind2 = 10;
    
    % eigenvalues / eigenvectors 
    for i1 = 1:numIt       
        [eVectorTmp, eValueTmp] = polyeig(S{i1},A{i1},Mc{i1});
        
        % sort eigenvectors
        [~, pos2] = sort(real(eValueTmp));
        eVecR{i1} = eVectorTmp(:,pos2); eVal{i1} = eValueTmp(pos2);

        % left eigenvectors
        J = diag(eVal{i1});
        eVecL{i1} = ([eVecR{i1}; eVecR{i1}*J]\[zeros(size(SysMat.M)); eye(size(SysMat.M))])/Mc{i1};
        
        lEVec = size(eVecR{i1},2);
      
        % pressure
        p = zeros(length(eValueTmp)/2,length(omega));
        nZero = find(eVal{i1}<0,1,'last'); % find first positive eigenvalue 
        
    end
    h = waitbar(0,'Pressure calculation is running...');
    % modulation coefficients and pressure
    for i1 = 1:length(omega)
        waitbar(i1/length(omega));
        % find responsible matrices
        ind = find(omega(i1)/(2*pi)>= erg.fBegin,1,'first'); %test

        % reduce number of eigenvectors
        %nfMax = find(eVal{ind}< 2*pi*GUI.Freq(i1),1,'last'); 
        nfMax = find(eVal{ind}< 2*pi*GUI.Freq(end),1,'last'); 
        if nfMax-ind2>nZero;
            eVecRo = eVecR{ind}(:,nfMax-(ind2-1):nfMax+ind2);
            eVecLo = eVecL{ind}(nfMax-(ind2-1):nfMax+ind2,:);
            eValo = eVal{ind}(nfMax-(ind2-1):nfMax+ind2);

            eVecRu = eVecR{ind}(:,lEVec-nfMax-(ind2-1):lEVec-nfMax+ind2);
            eVecLu = eVecL{ind}(lEVec-nfMax-(ind2-1):lEVec-nfMax+ind2,:);
            eValu = eVal{ind}(lEVec-nfMax-(ind2-1):lEVec-nfMax+ind2);

            eVecRTmp = [eVecRu,eVecRo];eVecLTmp = [eVecLu;eVecLo];
            eValTmp = diag([eValu;eValo]);
        else
            eVecRTmp = eVecR{ind}(:,lEVec-nfMax-ind:nfMax+ind2+1);
            eVecLTmp = eVecL{ind}(lEVec-nfMax-ind:nfMax+ind2+1,:);
            eValTmp = diag(eVal{ind}(lEVec-nfMax-ind:nfMax+ind2+1));
        end

        % frequency dependent load vector
        fVn = zeros(size(SysMat.M,1),1);
        for i2 = 1: length(groupMaterial)
            if ~isempty(SysMat.f{i2})
                vn = 1i*omega(i1)*getValueAtFrequency(groupMaterial{i2}{2},omega(i1)/(2*pi));
                fVn = fVn + SysMat.f{i2}*vn*fluid.rho;
            end
        end
        sizeV = size(eVecRTmp,2);
        warning off all;
        
        % pressure calculation
        p(:,i1)=  (eVecRTmp/(omega(i1)*eye(sizeV, sizeV)-eValTmp)*eVecLTmp)*(-1i*omega(i1)*fVn);
    end
    close(h)
end