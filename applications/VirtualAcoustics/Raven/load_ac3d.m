classdef load_ac3d
    % Class for GA model info

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>

    
    properties (GetAccess = 'public', SetAccess = 'public')
        nodes = [];              % numeric array with x,y,z coords of nodes with size(n,3)
    end
    
    properties (GetAccess = 'private', SetAccess = 'private')
        modelFilename = '';
        polygons = {};           % cell-array, each cell specifies all
        % nodes of one polygon in a numeric array
        bcGroups = {};           % of class type: gaGroup()
        totalVolume = -1;
        totalSurface = -1;
        
        transparency = 0.1;
    end
    
    methods
        
        % CONSTRUCTOR
        function obj = load_ac3d(filename)
            if nargin > 0
                obj = obj.readAc3DModelFile(filename);
            end
        end % Constructor
        
        % OTHER FUNCTIONS
        function obj = readAc3DModelFile(obj, fullFilename)
                       
            % new read method for loading ac3d file 
            % (works also with Matlab 2016 and newer)
            
            if exist(fullFilename, 'file')
                obj.modelFilename = fullFilename;
                fileID = fopen(fullFilename);
                allRows = textscan(fileID, '%s','Delimiter', '\n');
                
                maxLengthRow=0;
                for iRows=1:length(allRows{1})
                    if (~isempty(allRows{1}{iRows}))
                        currentLine = textscan(allRows{1}{iRows},'%s','Delimiter', ' ');
                        if length(currentLine{1}) > maxLengthRow
                            maxLengthRow = length(currentLine{1});
                        end
                    end
                end
                
                ac3d = cell(length(allRows{1}),maxLengthRow);
                
                for iRows=1:length(allRows{1})
                    if (~isempty(allRows{1}{iRows}))
                        currentLine = textscan(allRows{1}{iRows},'%s','Delimiter', ' ');
                        ac3d(iRows,1:length(currentLine{1})) = currentLine{1}';
                    end
                end
                fclose(fileID);
            else
                error('The specified file does not exist!');
            end
      
            % Materialnamen und Farben
            
            mat_rows  = find(strcmp(ac3d,'MATERIAL')==1);  % Zeilenindizes der Materialien
            MatNames  = ac3d(mat_rows,2);                  % Cell der Material Namen
            MatColors = str2double(ac3d(mat_rows,4:6));    % Matrix der RGB Material Farben

                        
            % Vertizes Koordinaten finden
            
            % Es wird davon ausgegangen, dass bei jedem Objekt einmal der Begriff
            % "numvert" auftaucht, die L�nge von vert_rows ist daher auch mit der
            % Anzahl der Objekte in der ac3d Datei identisch.
            % Die find Funktion liefert dabei die Zeilennummer, in der "numvert" steht.
            % In die vertex_cell werden f�r jedes Objekt alle Koordinaten der Vertizes
            % geschrieben.
            % Hierbei wird �ber die ac3d Dateistruktur der Anfang und das Ende der
            % Liste der Vertizes �ber die jeweilige Anzahl der Vertizes pro Objekt
            % angegeben.
            
            % Orientierung der Koordinatenbasis            
            loc_rows       = find(strcmp(ac3d,'loc')==1);             % Zeilenindizes der Basen
            vert_rows      = find(strcmp(ac3d,'numvert')==1);    % findet die Zeilenindizes der Zeilen mit 'numvert'
            numVertsInObj  = str2double(ac3d(vert_rows,2));
            vertex_cell    = cell(1, length(vert_rows));         % preallocation of memory
            translation_vector = cell(1, length(vert_rows)); % preallocation of memory
            
            for i = 1:length(vert_rows)
                % Speichere alle Vertex Koordinaten in (nx3) numerical arrays.
                % Jede Cell in vertex_cell enth�lt die Knoten f�r ein Objekt
                vertex_cell{i} = str2double(ac3d((vert_rows(i)+1):(vert_rows(i)+numVertsInObj(i)),1:3));
                
                if size(vert_rows,1) == size(loc_rows,1)
                    translation_vector{i} = str2double(ac3d(loc_rows(i),2:4));
                else
                    translation_vector{i} = [0 0 0];
                end
            end
            
            %wird sp�ter f�r die richtige Zuordnung der Knoten Liste ben�tigt
            globalNumOfFirstVertexInObj = ones(length(vertex_cell),1);
            for i = 2:length(globalNumOfFirstVertexInObj)
                globalNumOfFirstVertexInObj(i) = sum(numVertsInObj(1:(i-1))) + 1;
            end
            
            % Material zuordnen
            
            % Hier werden den unterschiedlichen Polygonen die verschiedenen Materialien
            % zugeordnet.
            % Jedesmal wenn ein "mat" in der ac3d Datei auftaucht, handelt es sich um
            % ein neues Polygon (zumindest in den meisten Dateien).
            % In matnum_rows befinden sich alle Zeilennummern, in denen ein "mat"
            % auftaucht.
            % in matnum_rows_cell sind diese Zeilennummern den unterschiedlichen
            % Materialien zugeordnet.
            
            matnum_rows = find(strcmp(ac3d,'mat')==1);           % alle Materialzuordnungen f�r die einzelnen Polygone finden
            matnum_rows_cell = cell(1, length(MatNames));
            for i = 1:length(MatNames)                           % speichert zeilen der unterschiedlichen mat NUMMER f�r die unterschiedlichen Materialien ab
                % jede cell in matnum_rows enth�lt die Zeilenindizes aller Polygone,
                % die zum Material mit der Nummer i geh�ren
                matnum_rows_cell{i} = matnum_rows( strcmpi(ac3d(matnum_rows,2),num2str(i-1)) );
            end
            
            % Datenstruktur erzeugen
            
            for i=1:length(MatNames)
                obj.bcGroups{i}.name     = MatNames{i};
                obj.bcGroups{i}.color    = MatColors(i,:);
                obj.bcGroups{i}.polygons = cell( length(matnum_rows_cell{i}),1);
                obj.bcGroups{i}.surface  = 0;
            end
            
            obj.nodes = [];
            
            for i = 1:length(vertex_cell)
                localCoordToWorldCoord = vertex_cell{i} + ones(size(vertex_cell{i},1),1)*translation_vector{i};
                obj.nodes = [obj.nodes; localCoordToWorldCoord];
            end
            
            
            % Bestimmung von Anfangs und Endzeilen der Objekte in der ac3d Datei �ber numvert
            
            object_start = vert_rows;
            object_end   = vert_rows;
            for i = 1:(length(vert_rows)-1)
                object_end(i) = object_start(i+1);
            end
            object_end(end) = length(ac3d(:,1));
            
            
            % Alle Daten der Datenstruktur zuordnen
            % hier wird �ber die objID sichergestellt, dass die richtigen Vertizes
            % verwendet werden
            globalIdx = 1;
            for matID = 1:length(MatNames) %Materialien durchgehen
                for objID = 1:length(vert_rows) %ac3d objekte durchgehen
                    for polyID = 1:length(matnum_rows_cell{matID}) % Anzahl der Polygone des Materials
                        if matnum_rows_cell{matID}(polyID) < object_end(objID) && matnum_rows_cell{matID}(polyID) > object_start(objID) %Vertex vom richtigen Objekt
                            numNodesOfPoly = str2double( ac3d(matnum_rows_cell{matID}(polyID)+1,2));
                            lineIdxOfFirstPolyNode = matnum_rows_cell{matID}(polyID) + 2;
                            lineIdxOfLastPolyNode  = matnum_rows_cell{matID}(polyID) + 1 + numNodesOfPoly;
                            localNodeObjectIDs = str2double( ac3d( lineIdxOfFirstPolyNode : lineIdxOfLastPolyNode ,1) );
                            obj.bcGroups{matID}.polygons{polyID} = localNodeObjectIDs + globalNumOfFirstVertexInObj(objID);
                            obj.polygons{globalIdx} = localNodeObjectIDs + globalNumOfFirstVertexInObj(objID);
                            globalIdx = globalIdx+1;
                        end
                    end
                end
            end
            
            
            % Dreiecksberechnung und Fl�chenberechnung
            % durch Triangulisieren und Satz des Heron
            % Triangulisation: Polygon wird in Dreiecke unterteilt
            % Satz des Heron: Fl�che eines Dreiecks A = 1/4 sqrt( (a+b+c)*(a+b-c)*(-a+b+c)*(a-b+c) )
            
            triaID = 1;
            for matID = 1:length(obj.bcGroups)
                for polyID = 1:length(obj.bcGroups{matID}.polygons)
                    for vertID = 1:(length(obj.bcGroups{matID}.polygons{polyID}(:,1))-2)
                        
                        node1 = obj.nodes(obj.bcGroups{matID}.polygons{polyID}(1       ),:);
                        node2 = obj.nodes(obj.bcGroups{matID}.polygons{polyID}(vertID+1),:);
                        node3 = obj.nodes(obj.bcGroups{matID}.polygons{polyID}(vertID+2),:);
                        
                        % Dreieck nach Triangulation abspeichern
                        triangles{triaID} = [node1;node2;node3];
                        
                        % Fl�chenberechnung f�r Dreieck
                        a = norm( node1  - node2 );
                        b = norm( node1  - node3 );
                        c = norm( node2  - node3 );
                        surfTriangles(triaID) = real( 1/4 * sqrt( (a+b+c) * (-a+b+c) * (a-b+c) * (a+b-c) ) );
                        
                        % Normalenberechnung f�r Dreieck
                        if norm( cross( (node2-node1), (node3-node1) ) ) == 0 % Schutz gegen Kr�ppel Linien Polygone
                            normals{triaID} = [0 0 0];
                        else
                            normals{triaID} = cross( (node2-node1), (node3-node1) ) / norm( cross( (node2-node1), (node3-node1) ) );
                        end
                        
                        obj.bcGroups{matID}.surface = obj.bcGroups{matID}.surface + surfTriangles(triaID);
                        
                        % Index inkrement
                        triaID = triaID+1;
                    end
                end
            end
            
            obj.totalSurface = sum(surfTriangles);
            
            % Volumenberechnung aus Dreiecken nach
            % http://de.wikipedia.org/wiki/Volumen
            volume = 0;
            
            for i = 1:length(triangles)
                %     for j = 1:3
                volume = volume + 1/3 * surfTriangles(i) * normals{i} * sum(triangles{i})';
                %     end
            end
            volume = volume/3;
            obj.totalVolume = volume;
            
        end  % function readAc3DModelFile()
        
        
        function plotModel(obj, axes2Plot, component2axesMapping, wireframe)
            
            % colors = [ 1.0 0.0 0.0 0.5 0.5 0.0 0.5 0.5 1.0 1.0 0.0 0.5 0.0 0.5 1.0 0.1 0.3 0.5 0.7 0.9;
            %     0.0 1.0 0.0 0.5 0.0 0.5 0.5 1.0 0.5 0.5 1.0 0.0 0.5 1.0 0.0 0.1 0.3 0.5 0.7 0.9;
            %     0.0 0.0 1.0 0.0 0.5 0.5 1.0 0.5 0.5 0.0 0.5 1.0 1.0 0.5 0.5 0.1 0.3 0.5 0.7 0.9  ];
            
            if nargin < 4
                wireframe = 0;
            end
            
            if nargin < 3
                component2axesMapping = [3 1 2];    % x y z -> z x y  (openGL has Y pointing upwards while matlab has Z pointing upwards
            end
            
            invertAxes = sign(component2axesMapping);
            component2axesMapping = abs(component2axesMapping);
            
            % Determine where to Plot
            if (nargin > 1)
                ax = axes2Plot;
                set(gcf, 'CurrentAxes', ax);
                cameratoolbar(gcf, 'show')
                set(gcf, 'Renderer', 'OpenGL');
%                 cla(ax, 'reset');
            else
                h_fig = figure;
                ax = axes;
                set(h_fig, 'CurrentAxes', ax);
                cameratoolbar(h_fig, 'show')
                set(h_fig, 'Renderer', 'OpenGL');
            end
            
            if wireframe
                % display wireframe model
                hold all;
                for polyID = 1:numel(obj.polygons)
                    polyNodes = obj.polygons{polyID}(:,1);
                    line( obj.nodes([polyNodes; polyNodes(1)],component2axesMapping(1)) * invertAxes(1), ...
                        obj.nodes([polyNodes; polyNodes(1)],component2axesMapping(2)) * invertAxes(2), ...
                        obj.nodes([polyNodes; polyNodes(1)],component2axesMapping(3)) * invertAxes(3), ...
                        'Color', [.3 .7 .3]);
                end
            else
                % display GA model
                hold all
                for polyID = 1:numel(obj.polygons)
                    polyNodes = obj.polygons{polyID}(:,1);
                    patch( obj.nodes(polyNodes,component2axesMapping(1)) * invertAxes(1), ...
                        obj.nodes(polyNodes,component2axesMapping(2)) * invertAxes(2), ...
                        obj.nodes(polyNodes,component2axesMapping(3)) * invertAxes(3), ...
                        [0.5 0.5 0.5], ...
                        'FaceAlpha', obj.transparency );
                end

                % Plot Boundary Groups
                for groupID = 1:numel(obj.bcGroups)
                    for polyID = 1:length(obj.bcGroups{groupID}.polygons)
                        patch( obj.nodes(obj.bcGroups{groupID}.polygons{polyID}(:,1),component2axesMapping(1)) * invertAxes(1), ...
                            obj.nodes(obj.bcGroups{groupID}.polygons{polyID}(:,1),component2axesMapping(2)) * invertAxes(2), ...
                            obj.nodes(obj.bcGroups{groupID}.polygons{polyID}(:,1),component2axesMapping(3)) * invertAxes(3), ...
                            obj.bcGroups{groupID}.color, ...
                            'FaceAlpha', obj.transparency );
                    end
                end
%                 alpha( gca, obj.transparency );
            end
            
             axis(ax, 'off');
             axis(ax, 'equal');
            
        end
        
        function V = getVolume(obj)            
            V = obj.totalVolume;
        end
        
        function S = getSurface(obj)
            S = obj.totalSurface;
        end
        
        function SMat = getMaterialSurface(obj,materialName)
            
             % sometimes multiple materials with the same name are defined. in this case, sum up all of them
            matchingMatIDs = [];   
            SMat = 0;
            for matID = 1:length(obj.bcGroups)
                if (strcmp(obj.bcGroups{matID}.name, materialName))
                    matchingMatIDs = [matchingMatIDs matID];
                    SMat = SMat + obj.bcGroups{matID}.surface;     
                end
            end
            
            if isempty(matchingMatIDs)
                error(['Material "' materialName '" is not part of the model. Please check materialname and or your *.ac file']);
            end
            
           
        end
        
        
        function [A, S] = getEquivalentAbsorptionArea_sabine(obj, material_path, portal_surface_materials)
            if nargin < 2
                material_path = fullfile('..', 'RavenDatabase', 'MaterialDatabase');
            end
            countPortals = 1;
            
            S = 0; %surface area (scalar)
            for matID = 1:length(obj.bcGroups)
                S = S + obj.bcGroups{matID}.surface;                % scalar
            end
            
            A = 0; %equivalent absorption area (vector over frequency)
            for matID = 1:length(obj.bcGroups)
                if isempty(strfind(obj.bcGroups{matID}.name, 'Portal'))
                    absorption = readRavenMaterial(obj.bcGroups{matID}.name, material_path);
                    if isempty(absorption)
                        error(['Material "' obj.bcGroups{matID}.name '" is not defined yet. Unable to compute absorption.']);
                    end
                else
                    if nargin < 3
                        error('Error! This model has portals, but no materialnames were given for the portal surface materials.');
                    end
                    absorption = readRavenMaterial(portal_surface_materials{countPortals}, material_path);
                    countPortals = countPortals + 1;
                    if isempty(absorption)
                        error(['Material "' portal_surface_materials{countPortals} '" is not defined yet. Unable to compute absorption.']);
                    end
                end                
                
                A = A + obj.bcGroups{matID}.surface .* absorption;   % vector                
            end            
        end

        function [A, S] = getEquivalentAbsorptionArea_eyring(obj, material_path, portal_surface_materials)
            if nargin < 2
                material_path = fullfile('..', 'RavenDatabase', 'MaterialDatabase');
            end
            countPortals = 1;
            
            S = 0; %surface area (scalar)
            for matID = 1:length(obj.bcGroups)
                S = S + obj.bcGroups{matID}.surface;                % scalar
            end
            
            A_tmp = 0; %equivalent absorption area (vector over frequency)
            for matID = 1:length(obj.bcGroups)
                if isempty(strfind(obj.bcGroups{matID}.name, 'Portal'))
                    absorption = readRavenMaterial(obj.bcGroups{matID}.name, material_path);
                    if isempty(absorption)
                        error(['Material "' obj.bcGroups{matID}.name '" is not defined yet. Unable to compute absorption.']);
                    end
                else
                    if nargin < 3
                        error('Error! This model has portals, but no materialnames were given for the portal surface materials.');
                    end
                    absorption = readRavenMaterial(portal_surface_materials{countPortals}, material_path);
                    countPortals = countPortals + 1;
                    if isempty(absorption)
                        error(['Material "' portal_surface_materials{countPortals} '" is not defined yet. Unable to compute absorption.']);
                    end
                end                
                
                A_tmp = A_tmp + obj.bcGroups{matID}.surface .* absorption ./ S;   % vector                
            end
            A = -S .* log(1 - A_tmp);            
        end
        

        
        function [A, S] = getEquivalentAbsorptionArea(obj)
            [A, S] = obj.getEquivalentAbsorptionArea_sabine();
        end
        
        function RT = getReverbTime(obj, material_path, sabine_or_eyring, airAbsorption, portal_surface_materials)
            if nargin < 3
                airAbsorption = zeros(1,31);
            end
            if nargin < 3
                sabine_or_eyring = 'eyring';
            end
            if nargin < 2
                material_path = fullfile('..', 'RavenDatabase', 'MaterialDatabase');
            end
               
            if nargin > 4
                if strcmp(sabine_or_eyring, 'eyring')
                    [A, S] = obj.getEquivalentAbsorptionArea_eyring(material_path, portal_surface_materials);
                else
                    if ~strcmp(sabine_or_eyring, 'sabine')
                        disp('Given method not found. Define "sabine" or "eyring" as method. Using Sabine'' formula now.');
                    end
                    [A, S] = obj.getEquivalentAbsorptionArea_sabine(material_path, portal_surface_materials);
                end
            else
                if strcmp(sabine_or_eyring, 'eyring')
                    [A, S] = obj.getEquivalentAbsorptionArea_eyring(material_path);
                else
                    if ~strcmp(sabine_or_eyring, 'sabine')
                        disp('Given method not found. Define "sabine" or "eyring" as method. Using Sabine'' formula now.');
                    end
                    [A, S] = obj.getEquivalentAbsorptionArea_sabine(material_path);
                end
            end
            
            %RT = 0.163 .* obj.totalVolume ./ A;
           % RT = (2.76 / sqrt(273.15 + room_temperature)) .* (obj.totalVolume ./ A);
            RT = 0.163 .* obj.totalVolume ./ (A + 4*airAbsorption*obj.totalVolume);
        end
        
        % get surface area of given material
        function S = getSurfaceArea(obj, material)
            
            S = 0; %surface area (scalar)
            for matID = 1:length(obj.bcGroups)
                if (strfind(obj.bcGroups{matID}.name, material))
                        S = S + obj.bcGroups{matID}.surface;                % scalar
                end        
                       
            end
        end
        
        function materialNames = getMaterialNames(obj)
            
            % check if path model has absolute or relative path
			% On Windows machines a absolute path will have a ':' as the second character,
			% On UNIX machines an absolute path will either start with a '/' or '~/'
            if ((~strcmp(obj.modelFilename(2),':') && ispc) || ...
					((~strcmp(obj.modelFilename(1), filesep) && ~strcmp(obj.modelFilename(1), '~')) && isunix))
                pathToModel = fullfile(pwd, obj.modelFilename);
            else
                pathToModel = obj.modelFilename;
            end
                                
            if exist(pathToModel, 'file') 
                ac3d_file = fopen(pathToModel, 'r');
            else
                error('The specified file does not exist!');
            end
            
            % preallocation
            materialNames = [];
            
            fgetl(ac3d_file); % HEADER ('AC3D' or 'AC3Db' etc.)
            
            count = 1;
            tline = fgetl(ac3d_file);
            while ~isempty(strfind(tline, 'MATERIAL'))
                matNameTmp = textscan(tline, '%s', 'Delimiter', '"');
                materialNames{count} = matNameTmp{1}{2};
                count = count + 1;
                
                tline = fgetl(ac3d_file);
            end
            
            fclose(ac3d_file);
        end
                
        function setMaterialNames(obj, materialNamesCell)
            % check if path model has absolute or relative path
			% On Windows machines a absolute path will have a ':' as the second character,
			% On UNIX machines an absolute path will either start with a '/' or '~/'
            if ((~strcmp(obj.modelFilename(2),':') && ispc) || ...
					((~strcmp(obj.modelFilename(1), filesep) && ~strcmp(obj.modelFilename(1), '~')) && isunix))
                pathToModel = fullfile(pwd, obj.modelFilename);
            else
                pathToModel = obj.modelFilename;
            end
                                
            if exist(pathToModel, 'file') 
                ac3d_file = fopen(pathToModel, 'r');
            else
                error('The specified file does not exist!');
            end
            
            % READ FILE
            matRows = [];
            iRow = 0;
            while ~feof(ac3d_file)
                iRow = iRow + 1;
                tline{iRow} = fgetl(ac3d_file);
                
                if ~isempty(strfind(tline{iRow}, 'MATERIAL'))
                    matRows = [matRows iRow];
                end
            end
            fclose(ac3d_file);
            
            if numel(materialNamesCell) ~= numel(matRows)
                error(['Error! ' num2str(numel(matNames)) ' material names given vs. ' num2str(numel(matRows)) ' material entries in the file.']);
            end
            
            % WRITE FILE WITH CHANGES TO MATERIAL NAMES
            if exist(pathToModel, 'file') 
                ac3d_file = fopen(pathToModel, 'w');
            else
                error('The specified file does not exist!');
            end
            
            count = 0;
            for iRow = 1 : numel(tline)
                if matRows(matRows == iRow)
                    % we are in a material definition row -> update name
                    try
                        lineTmp = textscan(tline{iRow}, '%s', 'Delimiter', '"');
                        count = count + 1;
                        lineTmp{1}{2} = materialNamesCell{count};
                        fprintf(ac3d_file, '%s\r\n', [lineTmp{1}{1} '"' lineTmp{1}{2} '" ' lineTmp{1}{3}]);
                    catch
                        disp(['Error during writing process in AC3D File: ' fullFilename]);
                        fprintf(ac3d_file, '%s\r\n', tline{iRow});
                    end
                else
                    fprintf(ac3d_file, '%s\r\n', tline{iRow});
                end
            end
            fclose(ac3d_file);
        end
        
        function bc_groups = getBcGroups(obj)
            bc_groups = obj.bcGroups;
        end
        
    end % methods
    
end % classdef
