function p = MAreal(SysMat, GUI, dMax, groupMaterial,fluid)
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
omega = GUI.Freq*2*pi;
p = zeros( size(SysMat.S,1),length(omega));

% number of eigenvectors (cuboid)
fGr = max(GUI.Freq);
V = sum(sum(SysMat.M));
Surf = 6*V^(2/3); 
L = 6*(V^(1/3)+dMax/sqrt(3));
deltaFreqMax = 1./(12*pi*V*fGr^2/fluid.c^3 + pi*Surf*fGr/fluid.c^2 + L/(8*fluid.c));
fTmp = (fGr+deltaFreqMax); 
n = ceil((4*pi*V*fTmp^3/fluid.c^3 + pi/2*Surf*fTmp^2/fluid.c^2 + L*fTmp/(8*fluid.c)));
n = 2*n; % double number of eigenvectors to produce a better result 

% number of eigenvector (schroeder) 
%--------------------------------------------------------------------------
% genau = 0.01;
% alphaM = alpha_iO/Surf;
% T  = -0.163*V/(Surf*log(1-alphaM));
% fSchroeder = 2000*sqrt(T/V);
% Z0 = fluid.rho*fluid.c;
% alpha_iO = 0;
% for i1 =1:length(SysMat.A)
%     if ~isempty(SysMat.A{i1})
%         rb = sum(groupMaterial{i1}{2}.Value)/(length(groupMaterial{i1}{2}.Value));
%         switch groupMaterial{i1}{2}.Type
%             case 'Admittance', alpha_i =  1-(abs((1-Z0*rb)/(1+Z0*rb)))^2;
%             case 'Impedance',  alpha_i = 1./( 1-(abs((1-Z0*rb)/(1+Z0*rb)))^2);
%             case 'Reflection', alpha_i =  1 - abs(rb)^2;
%             case 'Absorption', alpha_i = rb;
%         end
%         alpha_iO = alpha_iO + sum(sum(SysMat.A{i1}))*alpha_i;
%     end
% end
% nO = fGr/fSchroeder*2*sqrt(log(genau)/log(1/sqrt(2)));
% nT = ceil((4*pi*V*fGr^3/fluid.c^3 + pi/2*Surf*fGr^2/fluid.c^2 + L*fGr/(8*fluid.c)));
% nS = 2*nT+ceil(10*nO);
% nDeltaS = 2*n + ceil(10*nO);
%--------------------------------------------------------------------------


% eigenvalues / eigenvectors
[eVector, eValue] = eigs(SysMat.S,SysMat.M/fluid.c^2,n,'sm'); display(num2str(n));
h = waitbar(0,'Real Modulation: Pressure calculation is running...');
eValue = diag(eValue);
tic
% gerneralized matrices
fPhi = cell(size(SysMat.f));
aPhi = cell(size(SysMat.A));

for i1 = 1:length(groupMaterial)
    if ~isempty(SysMat.f{i1})
        fPhi{i1} = eVector'*SysMat.f{i1};
    elseif ~isempty(SysMat.A{i1})
        aPhi{i1} = eVector'*SysMat.A{i1}*eVector;
    end
end

sPhi = diag(eValue);
mPhi = eye(size(sPhi));
%zTmp = zeros(n,length(omega));

% modulation coefficients and pressure
for i1 = 1:length(omega)
    waitbar(i1/length(omega));

    fPhiVn = zeros(size(sPhi,1),1);
    aPhiY = zeros(size(sPhi));
    for i2 = 1: length(groupMaterial)
        if ~isempty(fPhi{i2})
            vn = 1i*omega(i1)*getValueAtFrequency(groupMaterial{i2}{2},omega(i1)/(2*pi));
            fPhiVn = fPhiVn + fPhi{i2}*vn*fluid.rho;
        elseif ~isempty(aPhi{i2})
            Yn = getValueAtFrequency(groupMaterial{i2}{2},omega(i1)/(2*pi));
            aPhiY = aPhiY + Yn*fluid.rho*aPhi{i2}; % kann noch herausgezogen werden, falls unabhängig von der Frequenz
        end
    end
    
    warning off all;
    z = (sPhi+1i*omega(i1)*aPhiY-omega(i1)^2*mPhi)\(-1i*omega(i1)*fPhiVn); % modulation coefficients
    %zTmp(:,i1) =z; % only for figure(7)
    p(:,i1)= eVector*z; % pressure
end

% plot modulation coefficients
% if length(omega)>1
%     eValueBlubb = real(sqrt(eValue))/(2*pi);  
%     figure(7); contourf(GUI.Freq,1:length(eValueBlubb) ,abs(zTmp),25,'EdgeColor','none');xlabel('f [Hz]'); ylabel('|z|');colorbar;
%     xlim([min(GUI.Freq) max(GUI.Freq)]); ylim([1 length(eValueBlubb)]); grid on; 
%     set(gca,'YTick',1:length(eValueBlubb));
%     set(gca,'YTickLabel',num2Str(round(eValueBlubb)))
%     title(GUI.meshFilename)
% end
close(h);
