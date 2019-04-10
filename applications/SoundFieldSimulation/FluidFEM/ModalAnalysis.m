function [p, GUI] = ModalAnalysis(varargin)
% Function gets a struct with systemmatrices and vectors (SysMat), a struct
% with informations from ita_GUIModeSolve (GUI), a double with the maximal
% distance of the body (dMax), a cell with boundary conditions 
% (groupMaterial) and an object itaMeshFluid with the initial fluid 
% informations (fluid).
% Functions calculates pressure (p) with the eigenmodes of the body
% (Modalanalysis). As addition the struct with informations of the solver
% methode is given back (GUI).

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Initialization
SysMat = varargin{1};
GUI = varargin{2};
dMax = varargin{3};
groupMaterial = varargin{4};
fluid = varargin{5};

if nargin <6
    mode = GUI.solveMode;
else
    if isnan(varargin{6})
        mode = varargin{6};
        if ~strcmp(mode,'complex') && ~strcmp(mode,'matrix')
            error('ModalAnalysis:: Wrong input Parameter mode!')
        end
    else
        error('ModalAnalysis:: Wrong number of input Parameter!')
    end
end
    

%% Modal Analysis
noEx=0;fTmp=0;
for i2=1:length(SysMat.f),fTmp = fTmp +sum(SysMat.f{i2});end
if fTmp == 0, noEx=1; end

if noEx==0
    switch mode % solver method
        case 'complex' % Modal analysis with complex eigenvectors
            try
                ind = 0;
                for i1 = 1:length(SysMat.A)
                    if isempty(SysMat.A{i1}), ind = ind+1;end
                end
                if ind == length(SysMat.A)
                    p = MAreal(SysMat, GUI,  dMax,groupMaterial, fluid);
                    disp('Solution: modal analysis real');
                    disp('=============================');
                else
                    p = MAkomplex(SysMat, GUI, dMax, groupMaterial, fluid);
                    disp('Solution: modal analysis complex');
                    disp('================================');
                end
            catch
                close(gcf);
                warning('Your mesh is too big or my code has a mistake.');
                p = MAreal(SysMat, GUI,  dMax,groupMaterial, fluid);
                GUI.solveMode = 'real';
                disp('Solution: modal analysis real');
                disp('=============================');
            end
        case 'real' % Modal analysis with real eigenvectors
            p = MAreal(SysMat, GUI,  dMax,groupMaterial, fluid);
            disp('Solution: modal analysis real');
            disp('=============================');
    end
else % no exitation
    p=zeros(size(SysMat.M,1),length(GUI.Freq));
end
