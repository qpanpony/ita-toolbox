function varargout = ita_read_collada(varargin)
%WRW3D_READ_COLLADA Summary of this function goes here
%   Detailed explanation goes here

%#ok<*ST2NM>
%#ok<*AGROW>
file = varargin{1};
if nargin >1,     out_classtype = varargin{2}; % possible types: IS & WRW
else out_classtype = 'WRW';
end

global xml;
global list_id_and_material;

xml = xml2struct(file);

if ~strcmp(xml.COLLADA.asset.up_axis.Text, 'Z_UP'), warning('wrw3d_read_collada: Axis might be permuted.'); end

list_id_and_material = {};
% Read materials:
if isfield(xml.COLLADA, 'library_materials')
    for j = 1:length(xml.COLLADA.library_materials.material)
        new_id2material = read_material(xml.COLLADA.library_materials.material(j));
        list_id_and_material(end+1,1:2) = new_id2material;
    end
end

% Look up index of instantiated visual scene:
%%%%% hier noch weitere tesst:
visual_scene = get_element_by_id(xml.COLLADA.library_visual_scenes.visual_scene,...
    xml.COLLADA.scene.instance_visual_scene.Attributes.url);

% Read visual scenes:

geometries = read_node(visual_scene.node);
% Adjust unit:
unit = str2double(xml.COLLADA.asset.unit.Attributes.meter);
for g = 1:length(geometries)
    for b = 1:length(geometries(g).boundaries)
        geometries(g).boundaries(b).polygon = geometries(g).boundaries(b).polygon * unit;
    end
end

% Check for portals:
for gA = 1:length(geometries)
    for gB = gA+1:length(geometries)
        for bA = 1:length(geometries(gA).portals)
            for bB = 1:length(geometries(gB).portals)
                if is_backside(geometries(gA).portals(bA).polygon,...
                        geometries(gB).portals(bB).polygon);
                    geometries(gA).portals(bA).backside = geometries(gB).portals(bB);
                    geometries(gB).portals(bB).backside = geometries(gA).portals(bA);
                end
            end
        end
    end
end

% Store Materials:
materials = [list_id_and_material{:,2}];

switch out_classtype
    case 'WRW',
        varargout{1} = geometries;
        varargout{2} = materials;
    case 'IS',
        coord   =   [];
        nCoord  =   size(geometries.boundaries(1).polygon,1);
        nCoordTri = 3;
        nBound  =   numel(geometries.boundaries);
        if nCoord ==5
            elem    = reshape(1:numel(geometries.boundaries)*2*nCoordTri, nCoordTri,nBound*2)';
            orderElem2 = [1 3 4];           
        elseif nCoord == 4 ||nCoord == 3
            elem    = reshape(1:numel(geometries.boundaries)*nCoordTri, nBound,nCoordTri);
        end
        normal  = [];
        
        for idxB = 1: nBound
            coordTMP = geometries.boundaries(idxB).polygon; 

            if nCoord ==5
%                 disp([num2str(2*idxB-1) ' Elem1'])
%                 disp(coordTMP(1:3,:))
%                  disp([num2str(2*idxB) ' Elem2'])
%                 disp(coordTMP(orderElem2,:))
                coord   = [coord ;coordTMP(1:3,:)];
                coord   = [coord ;coordTMP(orderElem2,:)];
                
                normal = [normal; geometries.boundaries(idxB).normal(1:3,:)];
                normal = [normal; geometries.boundaries(idxB).normal(orderElem2,:)];
                
                elem(2*idxB-1,:)  = elem(2*idxB-1,geometries.boundaries(idxB).elements(1:3));
                cID     = geometries.boundaries(idxB).elements(orderElem2);
                elem(2*idxB,:) = elem(2*idxB,[cID(1) cID(2)-1 cID(3)-1]);

            elseif nCoord == 4
                coord = [coord ;coordTMP(1:3,:)];
                elem(idxB,:)  = elem(idxB,geometries.boundaries(idxB).elements(1:3));
                normal(idxB,:) = geometries.boundaries(idxB).normal(1,:);
            elseif nCoord == 3
                coord = [coord ;coordTMP];
                elem(idxB,:)  = elem(idxB,geometries.boundaries(idxB).elements(1:3));
                normal(idxB,:) = geometries.boundaries(idxB).normal(1,:);
            end
        end
%         
%         coordRed = coord;
%         coordNew = ones(size(coord))*NaN;
%         counter = 1;
%         for idxC = 1:numel(coord)/3
%             idxCC = find(coord(idxC,1) == coordRed(:,1)&coord(idxC,2) == coordRed(:,2) & coord(idxC,3) == coordRed(:,3));
%             if ~isempty(idxCC)
%                 coordNew(counter,:) = coord(idxC,:); 
%                 coordRed(idxCC,:) =[];
%                 counter = counter+1;
% %             else
% %                 idxCC = find(coord(idxC,1) == coordNew(:,1)&coord(idxC,2) == coordNew(:,2) & coord(idxC,3) == coordNew(:,3));
%             end
%         end
%         coordNew(isnan(coordNew(:,1)),:)=[];
%         
%         for idxCN = 1:size(elem,1)
%             for idx2 = 1:size(elem,2)
%                 coordC = coord(elem(idxCN,idx2),:);
%                 idxCCN = find(coordC(1,1) == coordNew(:,1)&coordC(1,2) == coordNew(:,2) & coordC(1,3) == coordNew(:,3));
%                 elem(idxCN,idx2) = idxCCN;
%             end
%         end
        
        varargout{1} = itaImageSourcesGeometry('ID',1,'name',file,'coordinates',coord,...
            'normals',normal,'elements',[elem elem(:,1)]);
        varargout{2} = materials;
end

end



function id_and_material = read_material(xml_material)
global xml;
xml_material = uncell(xml_material);

material_id = xml_material.Attributes.id;

material = WRW3D_Material();
material.name = xml_material.Attributes.name;

if isfield(xml_material, 'instance_effect');
    % Get effect by id:
    effect_id = xml_material.instance_effect.Attributes.url;
    effect = get_element_by_id(xml.COLLADA.library_effects.effect, effect_id);
    % Read effect:
    effect = uncell(effect);
    if isfield(effect, 'profile_COMMON') && ...
            isfield(effect.profile_COMMON, 'technique') && ...
            isfield(effect.profile_COMMON.technique, 'lambert') && ...
            isfield(effect.profile_COMMON.technique.lambert, 'diffuse') && ...
            isfield(effect.profile_COMMON.technique.lambert.diffuse, 'color')
        rgba = str2num(effect.profile_COMMON.technique.lambert.diffuse.color.Text);
        material.rgb = rgba(1:3);
    end
end

id_and_material = {material_id, material};
end


function geometries = read_node(node)
node = uncell(node);
geometries = WRW3D_Geometry.empty();
if isfield(node, 'instance_geometry')
    new_geometry = WRW3D_Geometry();
    for j = 1:length(node.instance_geometry)
        new_boundaries = read_instance_instance(node.instance_geometry(j));
        new_geometry.boundaries(end+1:end+length(new_boundaries)) = new_boundaries;
    end
    geometries(end+1) = new_geometry;
end
if isfield(node, 'node')
    for j = 1:length(node.node)
        new_geometries = read_node(node.node(j));
        geometries(end+1:end+length(new_geometries)) = new_geometries;
    end
end
if isfield(node, 'matrix')
    matrix = reshape(str2num(node.matrix.Text), 4, 4);
    for g = 1:length(geometries)
        for b = 1:length(geometries(g).boundaries)
            polygon = geometries(g).boundaries(b).polygon;
            polygon(:,end+1) = ones(size(polygon,1),1);
            polygon = polygon * matrix;
            polygon = polygon(:,1:3) ./ repmat(polygon(:,4),1,3);
            geometries(g).boundaries(b).polygon = polygon;
        end
    end
end

end

function boundaries = read_instance_instance(instance_geometry)
global xml;
global list_id_and_material;
instance_geometry = uncell(instance_geometry);
list_symbol_and_material = {};

if isfield(instance_geometry, 'bind_material')
    material_symbol = instance_geometry.bind_material.technique_common.instance_material.Attributes.symbol;
    material_id = instance_geometry.bind_material.technique_common.instance_material.Attributes.target;
    material_id = material_id(2:end);
    material = list_id_and_material{strcmp(list_id_and_material(:,1), material_id), 2};
    list_symbol_and_material(end+1,:) = {material_symbol, material};
end

geometry = get_element_by_id(xml.COLLADA.library_geometries.geometry,...
    instance_geometry.Attributes.url);
boundaries = read_geometry(geometry, list_symbol_and_material);
end


function boundaries = read_geometry(geometry, list_symbol2material)
geometry = uncell(geometry);
boundaries = WRW3D_Boundary().empty;
for j = 1:length(geometry.mesh)
    new_boundaries = read_mesh(geometry.mesh(j), list_symbol2material);
    boundaries(end+1:end+length(new_boundaries)) = new_boundaries;
end
end


function boundaries = read_mesh(mesh, list_symbol2material)
mesh = uncell(mesh);
boundaries = WRW3D_Boundary().empty;
for j = 1:length(mesh.polylist)
    [position_indices, vertices_id, new_material] = read_polylist(mesh.polylist(j), list_symbol2material);
    vertices = get_element_by_id(mesh.vertices, vertices_id);
    vertices = uncell(vertices);
    source_id = get_id_by_semantic_of_input(vertices.input, 'POSITION');
    normal_id = get_id_by_semantic_of_input(vertices.input, 'NORMAL');
    
    source = get_element_by_id(mesh.source, source_id);
    source = uncell(source);
    
    normal = get_element_by_id(mesh.source, normal_id);
    normal = uncell(normal);
    
    % Check technique_common:
    if ~str2double(source.technique_common.accessor.Attributes.stride)==3 ...
            || ~strcmp(source.technique_common.accessor.param{1}.Attributes.name, 'X') ...
            || ~strcmp(source.technique_common.accessor.param{2}.Attributes.name, 'Y') ...
            || ~strcmp(source.technique_common.accessor.param{3}.Attributes.name, 'Z')
        error('wrw3d_read_collada: Positions are stored in a format not readable by this function.');
    end
    if ~str2double(normal.technique_common.accessor.Attributes.stride)==3 ...
            || ~strcmp(normal.technique_common.accessor.param{1}.Attributes.name, 'X') ...
            || ~strcmp(normal.technique_common.accessor.param{2}.Attributes.name, 'Y') ...
            || ~strcmp(normal.technique_common.accessor.param{3}.Attributes.name, 'Z')
        error('wrw3d_read_collada: Positions are stored in a format not readable by this function.');
    end
    
    % Read positions:
    positions = str2num(source.float_array.Text);
    positions = reshape(positions,3,[])';
    
    positions_norm = str2num(normal.float_array.Text);
    positions_norm = reshape(positions_norm,3,[])';
    
    % Assemble boundaries:
    for k = 1:length(position_indices);
        polygon = positions(position_indices{k},:);
        polygon_norm = positions_norm(position_indices{k},:);
        if size(unique(polygon, 'rows'),1)>2
            new_boundary = WRW3D_Boundary();
            new_boundary.polygon = polygon;
            new_boundary.normal  = polygon_norm;
            new_boundary.elements= uncell(position_indices);
            if ~isempty(new_material)
                if strcmp(new_material.name, 'Portal')
                    new_boundary.is_portal = true;
                else
                    new_boundary.material = new_material;
                end
            end
            boundaries(end+1) = new_boundary;
        else
            warning('wrw3d_read_collada: Ignore incorrect polygon.');
        end
    end
    
end
end


function [position_indices, vertices_id, material] = read_polylist(polylist, list_symbol2material)
polylist = uncell(polylist);

[vertices_id, input_index] = get_id_by_semantic_of_input(polylist.input, 'VERTEX');
input = uncell(polylist.input(input_index));
offset = str2double(input.Attributes.offset);

number_of_inputs = length(polylist.input);
p = str2num(polylist.p.Text);
vcount = str2num(polylist.vcount.Text);

if ~(sum(vcount)*number_of_inputs==length(p)), error('wrw3d_read_collada: function is unable to read indices of vertices.'); end

all_position_indices_indices = (0:number_of_inputs:length(p)-1) + offset + 1;
all_position_indices = p(all_position_indices_indices) + 1;

position_indices = cell.empty();
splitter = 0;
for j = 1:length(vcount);
    position_indices_indices = splitter+1 : splitter+vcount(j);
    splitter = splitter + vcount(j);
    position_indices{j} = all_position_indices(position_indices_indices);
end

% Material
if isfield(polylist.Attributes, 'material')
    material_symbol = polylist.Attributes.material;
    material = list_symbol2material{strcmp(material_symbol, list_symbol2material(:,1)), 2};
else
    material = WRW3D_Material.empty();
end
end


function element = get_element_by_id(cell_list, id)
if id(1)~='#', error('wrw3d_read_collada: ID seached for has to begin with #.'); end
id = id(2:end);

if iscell(cell_list)
    index = 1;
    while ~strcmp(cell_list{index}.Attributes.id, id)
        index = index + 1;
        if index>length(cell_list), error('wrw3d_read_collada: ID searched for not found.'); end
    end
    element = cell_list(index);
else
    if ~strcmp(cell_list.Attributes.id, id), error('wrw3d_read_collada: ID searched for not found.'); end
    element = cell_list;
end

end


function [id, index] = get_id_by_semantic_of_input(input_list, semantic)
if iscell(input_list)
    index = 1;
    while ~strcmp(input_list{index}.Attributes.semantic, semantic)
        index = index + 1;
        if index>length(input_list), error('wrw3d_read_collada: Semantic seached for not found.'); end
    end
    id = input_list{index}.Attributes.source;
else
    if ~strcmp(input_list.Attributes.semantic, semantic), error('wrw3d_read_collada: Semantic seached for not found.'); end
    index = 1;
    id = input_list.Attributes.source;
end
end


function x = uncell(x)
if iscell(x)
    x = x{1};
end
end


function bool = is_backside(polygonA, polygonB)
% Set return value to false:
bool = false;
% Test sizes:
if ~(size(polygonA,1)==size(polygonB,1))
    return;
end
% Find first vertex of polygonA in polygonB:
[indexB] = find(polygonA(1,1)==polygonB(:,1)...
    & polygonA(1,2)==polygonB(:,2)...
    & polygonA(1,3)==polygonB(:,3), 1, 'first');
if isempty(indexB)
    return;
end
% Ensure that polygons are not closed:
if all(polygonA(1,:)==polygonA(end,:)), polygonA(end,:)=[]; end
if all(polygonB(1,:)==polygonB(end,:)), polygonB(end,:)=[]; end
% Test further vertices:
for indexA = 1:length(polygonA)
    if any(polygonA(indexA,:)~=polygonB(indexB,:))
        return;
    end
    indexB = indexB - 1;
    if indexB<1
        indexB = length(polygonB);
    end
end
% All test successful:
bool = true;
end


