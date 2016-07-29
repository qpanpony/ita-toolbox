function ita_save_xml_material_for_raven(varargin)
%ita_save_xml_material_for_raven(filename, [arguments])
%   
%Optional parameters and default values:
%     
%     'id', '', 
%     'name', '', 
%     'description', '', 
%     
%     'reflection_factor', [], 
%     'absorption_coeff', [], 
%     'scatter_coeff', [], 
%     'impedance', [], 
%     
%     'frequency', [], 
%     'frequency_type', [],  % {'none', 'equidistant', 'third-octave', 'octave'}
%     'theta_in', [], 
%     'theta_out', [], 
%     'phi_in', [], 
%     'phi_out', [], 
%     
%     'order', 'column-major', 
%     'mode', 'write',   % {'write', 'append', 'replace'}
%     'root', 'material'  % {'material', 'material_db'}
%

% <ITA-Toolbox>
% This file is part of the application Raven for the ITA-Toolbox. All rights reserved.
% You can find the license for this m-file in the application folder.
% </ITA-Toolbox>


%% Parse input arguments

args = struct(...
    'pos1_filepath', '', ...
    ...
    'id', '', ...
    'name', '', ...
    'description', '', ...
    ...
    'reflection_factor', [], ...
    'absorption_coeff', [], ...
    'scatter_coeff', [], ...
    'impedance', [], ...
    ...
    'frequency', [], ...
    'frequency_type', [], ...
    'theta_in', [], ...
    'theta_out', [], ...
    'phi_in', [], ...
    'phi_out', [], ...
    ...
    'temperature', [], ...
    'huminity', [], ...
    'c', [], ...
    ...
    'order', 'column-major', ...
    'mode', 'write', ...
    'root', 'material');

[filepath, args] = ita_parse_arguments(args, varargin);

switch args.mode
    case {'write'}
        switch args.root
            case {'material'}
                document = com.mathworks.xml.XMLUtils.createDocument('material');
            case {'material_db'}
                document = com.mathworks.xml.XMLUtils.createDocument('material_db');
            otherwise
                % Error: not a valid root node
                exception = MException('fdda:inputTypeError', ...
                    sprintf('%s not a valid root node. Options are {material|material_db}', args.root) ...
                    );
                throw(exception);
        end
    case {'append', 'replace'}
        document = xmlread(filepath);
        document = xml_remove_empty_lines(document);
    otherwise
        % Error: not a valid mode
        exception = MException('fdda:inputTypeError', ...
            sprintf('%s not a valid mode. Options are {write|append|replace}', args.mode) ...
            );
        throw(exception);
end

root_node = document.getDocumentElement;

switch xml_get_node_name(root_node)
    case {'material_db'}
        try
            material_nodes = xml_get_node(root_node, 'material');
        catch ME
            if strcmp(ME.identifier, 'fdda:xml:invalidPathError')
                material_node = create_material_node(document, args.id, 'name', args.name, 'description', args.description);
                root_node.appendChild(material_node);
                material_nodes = material_node;
            else
                rethrow(ME);
            end
        end
        if ~iscell(material_nodes)
            material_nodes = {material_nodes};
        end
        material_ids = xml_get_attribute_value(material_nodes, 'id');
        first_match = find(strcmp(args.id, material_ids), 1);
        if ~isempty(first_match)
            material_node = material_nodes{first_match};
        else
            material_node = create_material_node(document, args.id, 'name', args.name, 'description', args.description);
            root_node.appendChild(material_node);
        end
    case {'material'}
        material_node = root_node;
        attr_id = document.createAttribute('id');
        attr_id.setValue(args.id);
        material_node.setAttributeNode(attr_id);
        if ~isempty(args.name)
            material_node.appendChild(xml_create_string_node(document, 'name', args.name));
        end
        if ~isempty(args.description)
            material_node.appendChild(xml_create_string_node(document, 'description', args.description));
        end
    otherwise
        exception = MException('fdda:inputTypeError', ...
            sprintf('%s not a valid root node. Options are {material|material_db}', args.root) ...
            );
        throw(exception);
end


if ~isempty(args.reflection_factor)

    if ~isempty(args.frequency)
        f = args.frequency;
    else
        f = args.reflection_factor.freqVector;
    end

    node = create_data_node(document, 'reflection_factor', args.reflection_factor.freq, ...
        'frequency', f, ...
        'frequency_type', args.frequency_type, ...
        'theta_in', args.theta_in, ...
        'theta_out', args.theta_out, ...
        'order', args.order);
    material_node.appendChild(node);

end


if ~isempty(args.absorption_coeff)

    if ~isempty(args.frequency)
        f = args.frequency;
    else
        f = args.absorption_coeff.freqVector;
    end

    node = create_data_node(document, 'absorption_coeff', args.absorption_coeff.freq, ...
        'frequency', f, ...
        'frequency_type', args.frequency_type, ...
        'theta_in', args.theta_in, ...
        'theta_out', args.theta_out, ...
        'order', args.order);
    material_node.appendChild(node);

end


if ~isempty(args.scatter_coeff)

    if ~isempty(args.frequency)
        f = args.frequency;
    else
        f = args.scatter_coeff.freqVector;
    end

    node = create_data_node(document, 'scatter_coeff', args.scatter_coeff.freq, ...
        'frequency', f, ...
        'frequency_type', args.frequency_type, ...
        'theta_in', args.theta_in, ...
        'theta_out', args.theta_out, ...
        'order', args.order);
    material_node.appendChild(node);

end


xmlwrite(filepath, document);
edit(filepath);

end

function node = create_material_node(varargin)

args = struct(...
    'pos1_document', '', ...
    'pos2_id', '', ...
    'name', [], ...
    'description', []);

[document, id, args] = ita_parse_arguments(args, varargin);

node = document.createElement('material');
attr_id = document.createAttribute('id');
attr_id.setValue(id);
node.setAttributeNode(attr_id);

if ~isempty(args.name)
    node.appendChild(xml_create_string_node(document, 'name', args.name));
end

if ~isempty(args.description)
    node.appendChild(xml_create_string_node(document, 'description', args.description));
end

end


function node = create_data_node(varargin)

args = struct(...
    'pos1_document', '', ...
    'pos2_type', '', ...
    'pos3_data', '', ...
    'theta_in', [], ...
    'theta_out', [], ...
    'phi_out', [], ...
    'frequency', [], ...
    'frequency_type', [], ...
    'order', 'column-major');

[document, type, data, args] = ita_parse_arguments(args, varargin);

measurement_type = 'normal';

child_nodes = {};

if ~isempty(args.frequency)
    child_nodes = [child_nodes {xml_create_real_array_node(document, 'frequency', args.frequency, args.order)}];
end

if ~isempty(args.frequency_type) && ismember(args.frequency_type, {'none', 'equidistant', 'third-octave', 'octave'})
    child_nodes = [child_nodes {xml_create_string_node(document, 'frequency_type', args.frequency_type)}];
end

if ~isempty(args.theta_in)
    child_nodes = [child_nodes {xml_create_real_array_node(document, 'theta_in', args.theta_in, args.order)}];
    measurement_type = 'angle-dependent';
end

if ~isempty(args.theta_out)
    child_nodes = [child_nodes {xml_create_real_array_node(document, 'theta_out', args.theta_out, args.order)}];
    measurement_type = 'bidirectional';
end

if ~isempty(args.theta_out)
    child_nodes = [child_nodes {xml_create_real_array_node(document, 'theta_out', args.theta_out, args.order)}];
end

child_nodes = [child_nodes {xml_create_string_node(document, 'data_type', measurement_type)}];

switch type
    case {'reflection_factor', 'impedance'}
        child_nodes = [child_nodes {xml_create_complex_array_node(document, 'data', data, args.order)}];
    case {'absorption_coeff', 'scatter_coeff'}
        child_nodes = [child_nodes {xml_create_real_array_node(document, 'data', data, args.order)}];
    otherwise
        exception = MException('fdda:inputValueError', ...
            sprintf('%s not a valid type. Options are {reflection_factor|impedance|absorption_coeff|scatter_coeff}', type) ...
            );
        throw(exception);
end

node = document.createElement(type);

for index = 1:numel(child_nodes)
    node.appendChild(child_nodes{index});
end

end

function string = shape_to_string(shape)
    if numel(shape) > 1
        string = [sprintf('%d ', shape(1:end-1)) sprintf('%d', shape(end))];
    else
        string = sprintf('%d', shape);
    end
end