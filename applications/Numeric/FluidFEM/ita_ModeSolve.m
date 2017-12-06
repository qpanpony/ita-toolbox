function varargout = ita_ModeSolve(varargin)
% This function is the main function from the fe solver.
% It can be used from gui or by manual data (see function manualInput).
% When this function is used by gui no data is given back and when it is
% used by manual data input a struct with the calculated pressure
% (ModeSolveOut.p) and solver data (ModeSolveOut.data) is given back

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% object of coordinates, elements, groups, group porperties and fluid
sArgs  = struct('pos1_data',[], 'display', 1, 'SystemMatrix',[]);
[GUI,sArgs]   = ita_parse_arguments(sArgs,varargin);

if ~isstruct(GUI)
    error('Wrong input parameter!')
end
structField = fieldnames(GUI);
if isempty(strfind(structField{1},'coord')) % old or manual version
    ita_ModeSolveManualInput(GUI);
    [coord, elements, groupMaterial] = niceObject(GUI.meshFilename, GUI.propertyFilename); % generate coordinate, element and group material objects
    if size(elements{2}.nodes,2)<10
        elements = {elements{1} elements{2}};
    else
        elements = {elements{2} elements{1}};
    end
    if nargout ~= 1
        error('Wrong number of outputs');
    end
else % GUI version: This version uses renumberated groups and elements
    coord = GUI.coord;
    elements ={GUI.volElem, GUI.surfElem};
    groupMaterial = GUI.groupMaterial;
end

fluid = itaMeshFluid(1,'ModeSolve',343.7,1.2);


%% System matrices
if isempty(sArgs.SystemMatrix)
    SysMat = sys_mat(coord, elements, groupMaterial);
else
    SysMat = sArgs.SystemMatrix;
end
%% Pressure calculation
if strcmp(GUI.solveMode,'particular') % particular solution of fe- helmholtzequation
    [p] = particularS(GUI,SysMat, coord, elements, groupMaterial, fluid);
elseif strcmp(GUI.solveMode,'complex') || strcmp(GUI.solveMode,'real')  % pressure calculation with modalanalysis
    dMax = sqrt((max(coord.x)-min(coord.x))^2+(max(coord.y)-min(coord.y))^2+(max(coord.z)-min(coord.z))^2);
    [p, GUI] = ModalAnalysis(SysMat, GUI, dMax, groupMaterial, fluid);
else  % eigenvalue and frequency calculation
    dMax = sqrt((max(coord.x)-min(coord.x))^2+(max(coord.y)-min(coord.y))^2+(max(coord.z)-min(coord.z))^2);
    [p, GUI] = niceEigenModes(SysMat,groupMaterial, fluid,GUI, dMax);
end


%% Output
if isempty(strfind(structField{1},'coord')) || sArgs.display == 0 % old or manual version
    pRes = itaResult;
    pRes.freqVector = GUI.Freq';
    pRes.freqData   = p.';
    pRes.resultType = 'simulation';
    pRes.channelUnits(1:coord.nPoints) ={'Pa'};
    
    for i1 =1:coord.nPoints
        pRes.channelNames(i1) = {num2str(coord.ID(i1))};
    end
    pRes.channelCoordinates = coord;
    
    ModeSolveOut.SysMat = SysMat;
    ModeSolveOut.p      = pRes;
    ModeSolveOut.data   = GUI;
    varargout{1}        = ModeSolveOut;
else % GUI version
    OutGUI.p = p;
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
    ita_GUIModeSolve(OutGUI)
end
