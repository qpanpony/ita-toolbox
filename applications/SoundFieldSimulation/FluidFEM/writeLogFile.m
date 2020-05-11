function writeLogFile(logFilename,meshFilename,GUI,coord,elements,groupMaterial)

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization

totNumNodes = num2str(length(coord.ID));
totNumElem  = num2str(length(elements{1}.ID));
totNumSurf  = num2str(length(elements{2}.ID));
totNumGroups= length(groupMaterial);

NumFluidElem  = num2str(totNumElem);  % number of fluid elements
NumStructElem = num2str(0);           % number of structure elements
NumShellElem  = num2str(0);           % number of shell elements
NumNetElem    = num2str(0);           % number of network elements


%% Info
fid = fopen(logFilename,'at');
if fid ~= -1
    fprintf(fid,'%s\n','SIMULATION LOGFILE:');
    fprintf(fid,'%s\n','===================');
    fprintf(fid,'%s\n',['unv-mesh filename               : ' meshFilename]);
    fprintf(fid,'%s\n','');
    % Info Material Data Elementgroups
    %----------------------------------------------------------------------
    fprintf(fid,'%s\n','INFO AND MATERIAL DATA FOR ELEMENT- AND NODEGROUPS:');
    fprintf(fid,'%s\n','---------------------------------------------------');

    for i1=1:totNumGroups
        fprintf(fid,'%s\n',['Boundary Condition for Elementgroup ' groupMaterial{i1}{2}.Name ]);
        if length(groupMaterial{i1}{2}.Value)==1
            Value = num2str(groupMaterial{i1}{2}.Value);
        else
            Value = [num2str(groupMaterial{i1}{2}.Value(1)) ' ... ' num2str(groupMaterial{i1}{2}.Value(end)) ' (' ...
                num2str(groupMaterial{i1}{2}.Freq(1)) ' ... ' num2str(groupMaterial{i1}{2}.Freq(end)) 'Hz)' ];
        end
        
        lType = length([groupMaterial{i1}{2}.Type ' (Value)']);
        if lType < 31
            lSpace = 31-lType;
            space= [groupMaterial{i1}{2}.Type ' (Value)'];
            for i2 =1:lSpace
                space = [space ,' '];
            end
        end
        fprintf(fid,'%s\n',[space ' : ' Value]);
        
        if ~isempty(groupMaterial{i1}{2}.Freq)
            fprintf(fid,'%s\n',['Filename                        : ' groupMaterial{i1}{2}.FreqInputFilename]);
        end
        fprintf(fid,'%s\n','');
    end
    % Info Mesh
    %----------------------------------------------------------------------
    fprintf(fid,'%s\n','MESH INFO:');
    fprintf(fid,'%s\n','----------');
    fprintf(fid,'%s\n','Mesh Information:');
    fprintf(fid,'%s\n',['Total number of nodes           : ' totNumNodes]);
    fprintf(fid,'%s\n',['Total number of elements        : ' totNumElem ]);
    fprintf(fid,'%s\n',['- Number of fluid elements      : ' NumFluidElem ]);
    fprintf(fid,'%s\n',['- Number of structure elements  : ' NumStructElem]);
    fprintf(fid,'%s\n',['- Number of shell elements      : ' NumShellElem ]);
    fprintf(fid,'%s\n',['- Number of network elements    : ' NumNetElem   ]);
    fprintf(fid,'%s\n','');
    fprintf(fid,'%s\n','Mesh dimension:');
    fprintf(fid,'%s\n',['Total number of surface elements: ' totNumSurf ]);
    fprintf(fid,'%s\n',['Total number of element groups  : ' num2str(totNumGroups)]);
    fprintf(fid,'%s\n','');
    if totNumGroups~=0
        fprintf(fid,'%s\n','Element group information:');
        for i1=1:length(groupMaterial)
            ID = num2str(groupMaterial{i1}{1}.ID');
            numElem = num2str(length(groupMaterial{i1}{1}.ID));
            if strcmp(groupMaterial{i1}{2}.Type,'Point Source')
                fprintf(fid,'%s\n',['- Name of node group            : ' groupMaterial{i1}{2}.Name]);
                fprintf(fid,'%s\n',['- # Elements in node group      : ' numElem]);
                fprintf(fid,'%s\n',['- IDs                           : ' ID]);
            else
                fprintf(fid,'%s\n',['- Name of element group         : ' groupMaterial{i1}{2}.Name]);
                fprintf(fid,'%s\n',['- # Elements in element group   : ' numElem]);
                fprintf(fid,'%s\n',['- IDs                           : ' ID]);
            end
        end
    end
    
    fprintf(fid,'%s\n','');
    % Info Eigenmodes
    %----------------------------------------------------------------------
    fprintf(fid,'%s\n','Solvermode INFO:');
    fprintf(fid,'%s\n','----------------');
    fprintf(fid,'%s\n',['Solution                        : ' GUI.solveMode]);
    fprintf(fid,'%s\n','');
    % Info Coupling
    %----------------------------------------------------------------------
    fprintf(fid,'%s\n','COUPLING INFO:');
    fprintf(fid,'%s\n','--------------');
    fprintf(fid,'%s\n','Uncoupled model!');
    fprintf(fid,'%s\n','');
    % Info Frequency
    %----------------------------------------------------------------------
    fprintf(fid,'%s\n','FREQUENCY INFO:');
    fprintf(fid,'%s\n','---------------');
    fprintf(fid,'%s\n','model solved of frequencies with:');
    fprintf(fid,'%s\n',['Startfrequency                  : ' num2str(GUI.Freq(1)) 'Hz']);
    fprintf(fid,'%s\n',['Stopfrequency                   : ' num2str(GUI.Freq(end)) 'Hz']);
    if length(GUI.Freq)==1
        steps = '1';
    else
        steps = num2str((GUI.Freq(end)-GUI.Freq(1))/(length(GUI.Freq)-1));
    end
    fprintf(fid,'%s\n',['Frequency step                  : ' steps 'Hz']); 
    fclose(fid);
else
    error('writeuff2414::cannot create file');
end