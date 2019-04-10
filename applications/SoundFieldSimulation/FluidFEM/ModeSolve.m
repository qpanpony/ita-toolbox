function ModeSolve(GUI)
% function fetches the meshes and the properties from the object and
% calculating the system matrices as well as writing a logfile
% Equation: (S_F - omega^2 * M_F + j*omega* A_F) *p = f_F
% function gets a frequency (freq), filename of  mesh (meshFilename), optional filename of result
% (resultFilename), filename of property (propertyFilename) and optional
% filename of logfile (logFilename)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved. 
% You can find the license for this m-file in the application folder. 
% </ITA-Toolbox>


%% Initialization
% -------------------------------------------------------------------------
[coord, elements, groupMaterial] = niceObject(GUI.meshFilename, GUI.propertyFilename); % generate coordinate, element and group material objects
fluid = itaMeshFluid(1,'ModeSolve',343.7,1.2);

if size(elements{2}.nodes,2)<10
    elements = {elements{1} elements{2}};
else
    elements = {elements{2} elements{1}};
end

%% System matrices
SysMat = sys_mat(coord, elements, groupMaterial);

%% Pressure calculation
if strcmp(GUI.solveMode,'particular') % particular solution of fe- helmholtzequation
    [p] = particularS(GUI,SysMat, coord, elements, groupMaterial, fluid);
    for i1 =1:length(SysMat)
    end
elseif strcmp(GUI.solveMode,'komplex') || strcmp(GUI.solveMode,'real')  % pressure calculation with modalanalysis
    dMax = sqrt((max(coord.x)-min(coord.x))^2+(max(coord.y)-min(coord.y))^2+(max(coord.z)-min(coord.z))^2);
    [p GUI] = ModalAnalysis(SysMat, GUI, dMax, groupMaterial, fluid);
else  % eigenvalue and frequency calculation
    dMax = sqrt((max(coord.x)-min(coord.x))^2+(max(coord.y)-min(coord.y))^2+(max(coord.z)-min(coord.z))^2);
    [p GUI] = niceEigenModes(SysMat,groupMaterial, fluid,GUI, dMax);
end


%% Output
% write *.unv
for i1=1:length(GUI.Freq)
    Data.p_real = real(p(:,i1)); Data.p_imag = imag(p(:,i1)); Data.freq = GUI.Freq(i1);
    Data.nodes  = coord.ID;
    Data.Type   = 'pressure';
    Data.eigenValues = []; 
    if ~isempty(GUI.resultFilename)
        writeuff2414(GUI.resultFilename,Data);
    end
end

% write logfile
if ~isempty(GUI.logFilename)
    writeLogFile(GUI,coord,elements,groupMaterial);
end

% GUI output
OutGUI.p = p; 
OutGUI.surfElem = elements{2};
OutGUI.volElem = elements{1};
OutGUI.coord = coord;
OutGUI.groups = groupMaterial;
OutGUI.gui = GUI;
farField = zeros(size(GUI.Freq));
for i1 = 1:length(SysMat.f) % far field distance
    if length(groupMaterial{i1})==2 && ~isempty(groupMaterial{i1}{2})
        if strcmp(groupMaterial{i1}{2}.Type, 'Point Source') && ~isempty(SysMat.f{i1})
            farField = fluid.c./(2*pi*real(GUI.Freq));
        elseif ~isempty(SysMat.f{i1})
            Surf = 0;
            for i2= 1:length(SysMat.A)
                if ~isempty(SysMat.A{i2})
                    Surf = sum(sum(SysMat.A{i2}))/length(groupMaterial{i2}{1}.ID)*length(groupMaterial{i1}{1}.ID);
                    break
                end
            end
            if Surf == 0, Surf = sum(sum(SysMat.M))^(1/3)*6; end
            farField = Surf*real(GUI.Freq)/fluid.c;
        end
    end
end    
OutGUI.farField =farField;
% sends data to gui
GUIModeSolve(OutGUI)
