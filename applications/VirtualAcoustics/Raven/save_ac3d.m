function save_ac3d(polygonset, materialNames, ac3dFilename)
%save_ac3d(polygonset, materialNames, ac3dFilename)
%
%   polygonset: struct with elements
%               .vertices
%               .material_id
%
%   OR:
%   
%   polygonset: cell array (see load_ac3d)
%               - each cell contains a list with ID of vertices
%               - 4th parameter "nodes" contains Nx3 array with vertex
%               coordinates
%               - parameter "materialNames" can be left empty as materials
%               are read from the cell array

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


if iscell(polygonset)
    error('Model format not recognized.');
else
    polyIDs = polygonset;
    polygonset=[];
    polygonset(numel(polyIDs.bcGroups)).vertices = polyIDs.nodes;
    materialNames = cell(numel(polyIDs.bcGroups), 1);
    for iMaterialGroup = 1 : numel(polyIDs.bcGroups) 
        polygonset(iMaterialGroup).vertices = polyIDs.nodes;
        for iPoly = 1 : numel(polyIDs.bcGroups{iMaterialGroup}.polygons)
            polygonset(iMaterialGroup).refs(iPoly,:) = (polyIDs.bcGroups{iMaterialGroup}.polygons{iPoly}') - 1; % matlab starts counting at 1, ac3d at 0
            polygonset(iMaterialGroup).material_id(iPoly) = iMaterialGroup-1;
        end        
        materialNames{iMaterialGroup} = polyIDs.bcGroups{iMaterialGroup}.name;
    end
end

fid = fopen(ac3dFilename, 'wt');

% create header
fprintf(fid, 'AC3Db\n');

% create material map
rgb_color_map = hsv(numel(materialNames));
for i = 1 : numel(materialNames)
    fprintf(fid, 'MATERIAL "');
    fprintf(fid, materialNames{i});
    fprintf(fid, '" rgb ');
    fprintf(fid, '%.2f ', rgb_color_map(i, :));
    fprintf(fid, '  amb 0.2 0.2 0.2  emis 0 0 0  spec 0.2 0.2 0.2  shi 128  trans 0\n');
end

% create world
fprintf(fid, 'OBJECT world\n');
fprintf(fid, 'kids ');
fprintf(fid,  num2str(numel(polygonset)));
fprintf(fid, '\n');

% create children, thus polygons
for i = 1 : numel(polygonset)
    fprintf(fid,  'OBJECT poly\n');
    fprintf(fid,  ['name "polygon' num2str(i) '"\n']);
    fprintf(fid,  ['numvert ' num2str(size(polygonset(i).vertices, 1)) '\n']);
    for j = 1 : size(polygonset(i).vertices, 1)
        % einkopieren der koordinaten
        fprintf(fid,  [num2str(polygonset(i).vertices(j, 1)) ' ']);
        fprintf(fid,  [num2str(polygonset(i).vertices(j, 2)) ' ']);
        fprintf(fid,  [num2str(polygonset(i).vertices(j, 3)) '\n']);
    end
    numSurf = size(polygonset(i).refs, 1);
    fprintf(fid,  ['numsurf ' num2str(numSurf) '\n']);
    for iSurf = 1 : numSurf
        fprintf(fid,  'SURF 0x10\n');
        fprintf(fid,  ['mat ' num2str(polygonset(i).material_id(iSurf)) '\n']);
        numRefs = size(polygonset(i).refs, 2);
        fprintf(fid,  ['refs ' num2str(numRefs) '\n']);
        for iRef = 1 : numRefs
            fprintf(fid,  [num2str(polygonset(i).refs(iSurf, iRef)) ' 0 0\n']);
        end        
    end
    fprintf(fid, 'kids 0\n');
end

fclose(fid);

end
