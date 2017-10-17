function [p] = particularS(GUI,SysMat, coord, elements, groupMaterial, fluid)
% function calculates particular solution of fe system (p). Therefor gui data (GUI),
% systemmatrices (SysMat), coordinates (coord), elements (elements),
% boundary condition (groupMaterial) and fluid data (fluid) are needed.

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
l_N  = length(coord.ID);  % number of nodes
dirichlet = zeros(length(groupMaterial),2); % checks if a pressure boundary condition exists
omega = 2*pi*GUI.Freq;

h = itaWaitbar(length(GUI.Freq),'Pressure calculation ...','Particular Solution');
tic
%% Main
for i1 = 1:length(GUI.Freq) % loop over all frequencies
    % init admittancematrix and weightvector
    A    = sparse(l_N,l_N);      % admittance matrix
    f    = sparse(l_N,1);        % weight vector
    
    % multiplication with displacement- or admittancevalue
    for i4=1:length(groupMaterial)
        if length(groupMaterial{i4})==2 && ~isempty(groupMaterial{i4}{2})
            valueAtFreq = getValueAtFrequency(groupMaterial{i4}{2},GUI.Freq(i1));
            if isnan(valueAtFreq)
                valueAtFreqTmp = getValueAtFrequency(groupMaterial{i4}{2},groupMaterial{i4}{2}.Freq);
                valueAtFreq = valueAtFreqTmp(1);
            end
            if ~isempty(SysMat.A{i4})
                A = A+SysMat.A{i4}.*valueAtFreq;
            elseif ~isempty(SysMat.f{i4})
                if strcmp(groupMaterial{i4}{2}.Type,'Pressure')
                    dirichlet(i4,:)=[i4,valueAtFrequency];
                else
                    f = f+SysMat.f{i4}.*valueAtFreq;
                end
            end
        end
    end
    
    if nnz(dirichlet) == 0 && nnz(f)==0 % neumann boundary condition
        warning('ModeSolve:: No excitation'); %#ok<*WNTAG>
        p=zeros(length(f),i1);
    elseif nnz(dirichlet(:,1)) ~= 0 % dirichlet boundary condition
        for i4 =1:nnz(dirichlet(:,1))
            if i4>1
                error('ModeSolve:: Multiple pressure excitation not possible yet');
            end
            K = (SysMat.S-(omega(i1)./fluid.c)^2.*SysMat.M+1j*omega(i1)*fluid.rho.*A);
            p_unknownElem = zeros(length(coord.x),1);
            
            p_knownElem = unique(elements{2}(groupMaterial{dirichlet(i4,1)}.ID,:));
            p_unknownElem(p_knownElem) = [];
            
            K_temp = K;
            l_knownElem = length(p_knownElem);
            K_temp(p_knownElem,p_knownElem) = eye(l_knownElem,l_knownElem);
            K_temp(p_knownElem,p_unknownElem) = zeros(length(p_knownElem),length(p_unknownElem));
            K_temp(p_unknownElem,p_knownElem) = zeros(length(p_unknownElem),length(p_knownElem));
            
            p_const = sparse(1,length(coord.x));
            p_const(p_knownElem) = dirichlet(i4,2);
            p_const(p_unknownElem) = f(p_unknownElem)-K(p_unknownElem,p_knownElem)*p_const(p_knownElem).';

            p = K_temp\p_const.';
        end
    else % neumann boundary condition
        p(:,i1) = (SysMat.S-(omega(i1)./fluid.c)^2.*SysMat.M+1j.*omega(i1).*fluid.rho*A)\(omega(i1)^2.*fluid.rho.*f);
    end
    
    h.inc();
end
close(h);

t = toc;
disp('Time particular');
disp('-------------------------------------------------------------------');
disp(['Total   : ' num2str(t)]);
disp(' ');