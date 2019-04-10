function ita_ModeSolveManualInput(GUI)
% this function is called from ita_ModeSolve and checks all manual inputs
% -------------------------------------------------------------------------
% - propertyFilename (cell): is a cell which contains structs with boundary
%   conditions for each group (a txt file is also possible (old version))
%   - ID (double): ID of group
%   - GroupName (char): Name of group
%   - Type (char): type of group (Admittance, Impedance, Reflection, Absorption,
%     Displacement, Velocity, Acceleration, Pressure, Point Source)
%   - Value (double): Value vector of the boundary condition
%   - Freq (double): Frequency vector of the boundary condition
%   - GroupFilename (char): filename of the boundary condition or default 'none'
% - Freq (double): Frequency Vector
% - resultFilename (char): Path and name of the result file
% - logFilename (char): Path and name of the log file
% - meshFilename (char): Path and name of the mesh file
% - solveMode (char): kind of solution (particular, komplex, real, eigs real,
%   eigs komplex)
%
% - Thresh (double):  eigs komplex needs some extra information if some boundary
%   conditions are frequency dependent. Thresh is the threshold for the
%   approximation of the boundary condition.
% - NumInt (double):  eigs komplex needs some extra information if some boundary
%   conditions are frequency dependent. NumInt gives the maximum of
%   iterations for the boundary condition.

% <ITA-Toolbox>
% This file is part of the application FluidFEM for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

%% Initialization
% -------------------------------------------------------------------------
if isstruct(GUI)
    entries = fieldnames(GUI);
    if length(entries)>5
        if (~iscell(GUI.(entries{1})) && ~ischar(GUI.(entries{1}))) || ~strcmp(entries{1},'propertyFilename')
            error('ita_ModeSolve: First struct arguments fieldname is propertyFilename (cell) or in a older version a char!')
        elseif iscell(GUI.(entries{1}))
            for i1 = 1:length(GUI.(entries{1}))
                entries2 = fieldnames(GUI.(entries{1}){i1});
                if length(entries2)==6
                    if ~strcmp(entries2{1},'ID') || ~isnumeric(GUI.(entries{1}){i1}.(entries2{1}))
                        error('ita_ModeSolve: One of the structs from cell propertyFilename has a wrong identifier or type!')
                    end
                    if ~strcmp(entries2{2},'GroupName') || ~ischar(GUI.(entries{1}){i1}.(entries2{2}))
                        error('ita_ModeSolve: One of (the structs from cell propertyFilename has a wrong identifier or type!')
                    end
                    if ~strcmp(entries2{3},'Type') || ~ischar(GUI.(entries{1}){i1}.(entries2{3}))
                        error('ita_ModeSolve: One of the structs from cell propertyFilename has a wrong identifier or type!')
                        % addition: control type of Type!
                    end
                    if ~strcmp(entries2{4},'Value') || ~isnumeric(GUI.(entries{1}){i1}.(entries2{4}))
                        error('ita_ModeSolve: One of the structs from cell propertyFilename has a wrong identifier or type!')
                    end
                    if ~strcmp(entries2{5},'Freq') || ~isnumeric(GUI.(entries{1}){i1}.(entries2{5}))
                        error('ita_ModeSolve: One of the structs from cell propertyFilename has a wrong identifier or type!')
                    end
                    if ~strcmp(entries2{6},'GroupFilename') || ~ischar(GUI.(entries{1}){i1}.(entries2{6}))
                        error('ita_ModeSolve: One of the structs from cell propertyFilename has a wrong identifier or type!')
                    end
                else
                    error('ita_ModeSolve: One of the structs from cell propertyFilename has not enougth elements!')
                end
            end
        end
        if ~isnumeric(GUI.(entries{2})) || ~strcmp(entries{2},'Freq')
            error('ita_ModeSolve: Second struct arguments fieldname is Freq (double)!')
        end
        if (~ischar(GUI.(entries{3})) && ~isempty(GUI.(entries{3}))) || ~strcmp(entries{3},'resultFilename')
            error('ita_ModeSolve: Third struct arguments fieldname is resultFilename (char)!')
        end
        if (~ischar(GUI.(entries{4})) && ~isempty(GUI.(entries{4}))) || ~strcmp(entries{4},'logFilename')
            error('ita_ModeSolve: Fourth struct arguments fieldname is logFilename (char)!')
        end
        if ~ischar(GUI.(entries{5})) || ~strcmp(entries{5},'meshFilename')
            error('ita_ModeSolve: Fifth struct arguments fieldname is meshFilename (char)!')
        end
        if ~ischar(GUI.(entries{6})) || ~strcmp(entries{6},'solveMode')
            error('ita_ModeSolve: Sixth struct arguments fieldname is solveMode (char)!')
        elseif ~strcmp(GUI.(entries{6}),'particular') && ~strcmp(GUI.(entries{6}),'komplex') && ~strcmp(GUI.(entries{6}),'real')...
                && ~strcmp(GUI.(entries{6}),'eigs real') && ~strcmp(GUI.(entries{6}),'eigs komplex')
            error('ita_ModeSolve: Wrong solve mode!')
        end
        if strcmp(GUI.(entries{6}),'eigs komplex')
            freqDepBC = 0;
            for i1 = 1:length(GUI.(entries{1}))
                if ~strcmp(GUI.propertyFilename{i1}.GroupFilename,'none')
                    freqDepBC = 1;
                end
            end
            if  freqDepBC==1
                if length(entries)~=8
                    error('ita_ModeSolve: Your input struct is not valid! Something is missing!')
                elseif ~strcmp(entries{7},'Thresh') ||  ~strcmp(entries{8},'NumInt')
                    error('ita_ModeSolve: Seventh struct arguments fieldname is Thresh and eighth numInt!')
                elseif ~isnumeric(GUI.(entries{7})) || ~isnumeric(GUI.(entries{8}))
                    error('ita_ModeSolve: Seventh struct arguments fieldname is Thresh (double) and eighth numInt (double)!')
                end
            end
        elseif length(entries)~=6
            error('ita_ModeSolve: Your input struct is not valid! Something is missing!')
        end
    else
        error('ita_ModeSolve: Your input struct is not valid! Something is missing!')
    end
else
    error('ita_ModeSolve: Input must be a struct')
end
