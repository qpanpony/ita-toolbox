function [eigenP, GUI] = niceEigenModes(SysMat,groupMaterial, fluid,GUI,dMax)
% Function is called from ita_ModeSolve if eigenmodes should be calculated.
% Function gets a struct with systemmatrices and vectors (SysMat), a struct
% with informations from ita_GUIModeSolve (GUI), a double with the maximal
% distance of the body (dMax), a cell with boundary conditions 
% (groupMaterial) and an object itaMeshFluid with the initial fluid 
% informations (fluid).
% The output of the function are the eigenvectors (eigenP) of the body and
% as addition a struct with informations of the solver method and eigen-
% frequencies is given back (GUI).

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


% Approximation of the number eigenmodes 
V = sum(sum(SysMat.M));
Surf = 6*V^(2/3); 
L = 6*(V^(1/3)+dMax/sqrt(3));
fGr = max(GUI.Freq);
deltaFreqMax = 1./(12*pi*V*fGr^2/fluid.c^3 + pi*Surf*fGr/fluid.c^2 + L/(8*fluid.c));
fTmp = (fGr+deltaFreqMax); % Doppelte Anzahl an Frequenzen
n = ceil((4*pi*V*fTmp^3/fluid.c^3 + pi/2*Surf*fTmp^2/fluid.c^2 + L*fTmp/(8*fluid.c)));


if strcmp(GUI.solveMode,'eigs real') % Calculation of real eigenmodes 
    [eigenP, eValue] = eigs(SysMat.S,SysMat.M/fluid.c^2,n,'sm');
    eigenP = eigenP(:,end:-1:1);
    eValue = diag(eValue);
    GUI.Freq = sqrt(eValue(end:-1:1))/(2*pi);
    posFreq = find(GUI.Freq<=fGr,1,'last');
    GUI.Freq = GUI.Freq(1:posFreq);
    eigenP = eigenP(:,1:posFreq);
else % Calculation of komplex eigenmodes 
    numIt = 0; numIt2 = 0;
    % admittance matrix
    aYn = sparse(size(SysMat.S,1),size(SysMat.S,2));
    for i1 = 1: length(groupMaterial)
        if length(groupMaterial{i1}{2}.Freq)>1 &&  ~isempty(SysMat.A{i1})
            numIt2 = -1;
            break;
        elseif ~isempty(SysMat.A{i1})
            Yn = getValueAtFrequency(groupMaterial{i1}{2},GUI.Freq(1));
            if Yn ~= 0
                aYn =aYn+Yn *fluid.rho*SysMat.A{i1};
            else
                numIt = numIt+1;
            end
            numIt2 = numIt2+1;
        end
    end
    if numIt == numIt2 % eigenmodes are real
        GUI.solveMode = 'eigs real';
        [eigenP, GUI] = niceEigenModes(SysMat,groupMaterial, fluid,GUI,dMax);
    elseif isempty(GUI.Thresh) && isempty(GUI.NumInt) % eigenmodes are komplex with constant boundary conditions
        [eVector, eValue] = polyeig(SysMat.S,1i*aYn,-SysMat.M/fluid.c^2);
        [~, pos2] = sort(real(eValue));
        eVector = eVector(:,pos2);
        eValue = eValue(pos2);
        lEVec = size(eVector,2);
        if lEVec/2+n+2 > lEVec, n = lEVec/2-2;end
        eigenP = eVector(:,lEVec/2-n-1:lEVec/2+n+2);
        GUI.Freq = eValue(lEVec/2-n-1:lEVec/2+n+2)/(2*pi);
    else % eigenmodes are komplex with frequency dependent boundary conditions
        [S, Mc, A, erg] = sysMatfreqDependent(SysMat,groupMaterial, fluid,max(GUI.Freq), GUI.NumInt, GUI.Thresh);
        eValue = []; eVector = [];
        for i1 = 1:length(S);
            [eVectorTmp, eValueTmp] = polyeig(S{i1},A{i1},Mc{i1});
            omegaO = 2*pi*erg.fEnd(i1);
            omegaU = 2*pi*erg.fBegin(i1);
            [~, pos2] = sort(real(eValueTmp));
            eVectorTmp = eVectorTmp(:,pos2);
            eValueTmp = eValueTmp(pos2);

            % (Aus)Sortieren
            pos = find(real(eValueTmp)>omegaO);
            eValueTmp(pos)=[];    eVectorTmp(:,pos)=[]; % sort out upper frequencies
            pos2 = find(real(eValueTmp)<-omegaO);
            lPos2 = length(pos2);
            eValueTmp(1:lPos2)=[];    eVectorTmp(:,1:lPos2)=[]; % sort out lower frequencies
            pos3 = find(real(eValueTmp)>-omegaU & real(eValueTmp)<omegaU);
            eValueTmp(pos3)=[];    eVectorTmp(:,pos3)=[]; 
            eVector = [eVector, eVectorTmp];
            eValue = [eValue; eValueTmp/(2*pi)];
        end
        [~, pos2] = sort(real(eValue));
        eigenP = eVector(:,pos2);
        GUI.Freq = eValue(pos2);
    end
end